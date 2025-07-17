// Project imports:
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Adaptador para mapear dados do dashboard para formatos compatíveis com widgets de UI
class DashboardUiAdapter {
  /// Mapeia progresso do usuário para o formato de estatísticas da UI
  static Map<String, dynamic> mapUserProgressToStats(UserProgress progress) {
    return {
      'totalWorkouts': progress.totalWorkouts,
      'totalDuration': progress.totalDuration,
      'currentStreak': progress.currentStreak,
      'points': progress.totalPoints,
      'daysTrainedThisMonth': progress.daysTrainedThisMonth,
      'workoutsByType': progress.workoutsByType,
    };
  }
  
  /// Mapeia treinos recentes para o formato do calendário
  static Map<DateTime, List<Map<String, dynamic>>> mapWorkoutsToCalendar(
      List<WorkoutRecord> workouts) {
    final Map<DateTime, List<Map<String, dynamic>>> result = {};
    
    for (final workout in workouts) {
      // Normaliza a data para não ter horas/minutos/segundos
      final date = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );
      
      if (!result.containsKey(date)) {
        result[date] = [];
      }
      
      result[date]!.add({
        'id': workout.id,
        'name': workout.workoutName,
        'type': workout.workoutType,
        'duration': workout.durationMinutes,
        'intensity': workout.intensity,
      });
    }
    
    return result;
  }
  
  /// Mapeia progresso do desafio para formato de UI
  static Map<String, dynamic>? mapChallengeProgressToUiModel(
      ChallengeProgress? challengeProgress) {
    if (challengeProgress == null) return null;
    
    return {
      'challengeId': challengeProgress.challengeId,
      'challengeName': challengeProgress.challengeName ?? 'Desafio Atual',
      'userRank': challengeProgress.rank ?? 0,
      'totalParticipants': challengeProgress.totalParticipants ?? 0,
      'points': challengeProgress.points ?? 0,
      'progress': challengeProgress.progress ?? 0.0,
      'daysRemaining': challengeProgress.daysRemaining ?? 0,
    };
  }
  
  /// Mapeia o dashboard completo para uma estrutura compatível com a UI
  static Map<String, dynamic> mapDashboardToUiModel(DashboardData dashboard) {
    return {
      'stats': mapUserProgressToStats(dashboard.userProgress),
      'workoutCalendar': mapWorkoutsToCalendar(dashboard.recentWorkouts),
      'challengeProgress': mapChallengeProgressToUiModel(dashboard.challengeProgress),
      'lastUpdated': dashboard.lastUpdated,
    };
  }
  
  /// Verifica e retorna um modelo vazio se os dados forem nulos
  static Map<String, dynamic> getEmptyUiModelIfNeeded(DashboardData? dashboard) {
    if (dashboard == null) {
      return {
        'stats': {
          'totalWorkouts': 0,
          'totalDuration': 0,
          'currentStreak': 0,
          'points': 0,
          'daysTrainedThisMonth': 0,
          'workoutsByType': {},
        },
        'workoutCalendar': {},
        'challengeProgress': null,
        'lastUpdated': DateTime.now(),
      };
    }
    
    return mapDashboardToUiModel(dashboard);
  }
} 