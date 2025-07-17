// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/workout/models/user_workout.dart';
import 'package:ray_club_app/features/workout/repositories/user_workout_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Provider para o serviço de integridade de dados
final dataIntegrityServiceProvider = Provider<DataIntegrityService>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final workoutRepository = ref.watch(userWorkoutRepositoryProvider);
  return DataIntegrityService(challengeRepository, authRepository, workoutRepository);
});

/// Service responsible for validating and ensuring data integrity 
/// between related entities like workouts and challenges
class DataIntegrityService {
  final ChallengeRepository _challengeRepository;
  final IAuthRepository _authRepository;
  final UserWorkoutRepository _workoutRepository;
  
  DataIntegrityService(
    this._challengeRepository,
    this._authRepository,
    this._workoutRepository,
  );
  
  /// Validate the synchronization between workouts and challenges
  Future<ValidationReport> validateWorkoutChallengeSync({bool autoFix = false}) async {
    final report = ValidationReport(shouldFix: autoFix);
    final currentUser = await _authRepository.getCurrentUser();
    
    if (currentUser == null) {
      report.addError('User not authenticated');
      return report;
    }
    
    try {
      // Get recent workouts
      final recentWorkouts = await _workoutRepository.getRecentWorkouts(
        userId: currentUser.id,
        days: 14, // Check last 2 weeks
      );
      
      // Get active challenges
      final userChallenges = await _challengeRepository.getUserActiveChallenges(currentUser.id);
      
      // For each workout, verify corresponding check-ins
      for (final workout in recentWorkouts) {
        if (workout.completedAt == null) continue;
        
        for (final challenge in userChallenges) {
          // Check if workout is within challenge period
          if (_isWorkoutInChallengePeriod(workout, challenge)) {
            // Check if there's a check-in for this workout in this challenge
            final hasCheckIn = await _challengeRepository.hasCheckedInOnDate(
              currentUser.id,
              challenge.id,
              workout.completedAt!,
            );
            
            if (!hasCheckIn) {
              report.addMissingCheckIn(workout.id, challenge.id);
              
              // Fix the inconsistency if requested
              if (report.shouldFix) {
                await _fixMissingCheckIn(workout, challenge, currentUser.id);
              }
            }
          }
        }
      }
      
      return report;
    } catch (e) {
      report.addError('Failed to validate synchronization: $e');
      return report;
    }
  }
  
  /// Check if a workout is within a challenge period
  bool _isWorkoutInChallengePeriod(UserWorkout workout, Challenge challenge) {
    final workoutDate = workout.completedAt;
    if (workoutDate == null) return false;
    
    return workoutDate.isAfter(challenge.startDate) && 
           workoutDate.isBefore(challenge.endDate);
  }
  
  /// Fix a missing check-in
  Future<void> _fixMissingCheckIn(
    UserWorkout workout, 
    Challenge challenge, 
    String userId
  ) async {
    if (workout.completedAt == null) return;
    
    await _challengeRepository.recordChallengeCheckIn(
      challengeId: challenge.id,
      userId: userId,
      workoutId: workout.id,
      workoutName: workout.workoutName ?? 'Check-in Automático',
      workoutType: workout.workoutType ?? 'other',
      date: workout.completedAt!,
      durationMinutes: workout.durationMinutes ?? 30,
    );
    
    debugPrint('✅ Fixed: Added check-in for workout ${workout.id} in challenge ${challenge.id}');
  }
  
  /// Run a complete data integrity check
  Future<List<ValidationReport>> runFullIntegrityCheck({bool autoFix = false}) async {
    final reports = <ValidationReport>[];
    
    // Check workout-challenge synchronization
    final syncReport = await validateWorkoutChallengeSync(autoFix: autoFix);
    reports.add(syncReport);
    
    // Add other integrity checks here as needed
    
    return reports;
  }

  /// Valida um treino do usuário
  Map<String, String> validateUserWorkout(UserWorkout workout) {
    final errors = <String, String>{};
    
    // Validar nome do treino
    if (workout.workoutName.isEmpty) {
      errors['workoutName'] = 'Nome do treino é obrigatório';
    }
    
    // Validar duração
    if (workout.durationMinutes <= 0) {
      errors['duration'] = 'Duração deve ser maior que zero';
    }
    
    return errors;
  }
}

/// Report containing validation results
class ValidationReport {
  final List<String> errors = [];
  final List<CheckInIssue> missingCheckIns = [];
  final bool shouldFix;
  
  ValidationReport({this.shouldFix = false});
  
  void addError(String error) {
    errors.add(error);
  }
  
  void addMissingCheckIn(String workoutId, String challengeId) {
    missingCheckIns.add(CheckInIssue(workoutId, challengeId));
  }
  
  bool get hasIssues => errors.isNotEmpty || missingCheckIns.isNotEmpty;
  
  @override
  String toString() {
    final buffer = StringBuffer('ValidationReport:\n');
    
    if (errors.isNotEmpty) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln('- $error');
      }
    }
    
    if (missingCheckIns.isNotEmpty) {
      buffer.writeln('Missing check-ins:');
      for (final issue in missingCheckIns) {
        buffer.writeln('- Workout: ${issue.workoutId}, Challenge: ${issue.challengeId}');
      }
    }
    
    if (!hasIssues) {
      buffer.writeln('No issues found.');
    }
    
    return buffer.toString();
  }
}

/// Represents a check-in issue between a workout and a challenge
class CheckInIssue {
  final String workoutId;
  final String challengeId;
  
  CheckInIssue(this.workoutId, this.challengeId);
} 