// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/workouts/repositories/workout_repository.dart';

/// Provider para acessar o repositório de treinos.
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

/// Provider para acessar todos os treinos disponíveis.
final allWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getAllWorkouts();
});

/// Provider para acessar treinos por tipo (categoria).
final workoutsByTypeProvider = FutureProvider.family<List<Workout>, String>((ref, type) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutsByType(type);
});

/// Provider para acessar os treinos do usuário atual.
final userWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  // Verificar se há um usuário autenticado
  if (currentUser == null) {
    throw const AppException(
      message: 'Usuário não autenticado',
      code: 'unauthenticated',
    );
  }
  
  return repository.getUserWorkouts(currentUser.uid);
});

/// Provider para acessar os treinos do usuário em uma data específica.
@Deprecated('Use o provider em lib/features/workout/providers/workout_providers.dart em vez disso')
final userWorkoutsForDateProvider = FutureProvider.family<List<Workout>, DateTime>((ref, date) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  // Verificar se há um usuário autenticado
  if (currentUser == null) {
    throw const AppException(
      message: 'Usuário não autenticado',
      code: 'unauthenticated',
    );
  }
  
  // Normalizar a data para incluir apenas dia/mês/ano (sem horas)
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  return repository.getUserWorkoutsForDate(currentUser.uid, normalizedDate);
});

/// Provider para acessar um treino específico por ID.
final workoutByIdProvider = FutureProvider.family<Workout, String>((ref, workoutId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final workout = await repository.getWorkoutById(workoutId);
  
  if (workout == null) {
    throw AppException(
      message: 'Treino não encontrado',
      code: 'not_found',
      details: {'workoutId': workoutId},
    );
  }
  
  return workout;
});

/// Provider para contar o total de treinos do usuário nos últimos X dias.
final userWorkoutCountProvider = FutureProvider.family<int, int>((ref, days) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  // Verificar se há um usuário autenticado
  if (currentUser == null) {
    throw const AppException(
      message: 'Usuário não autenticado',
      code: 'unauthenticated',
    );
  }
  
  final endDate = DateTime.now();
  final startDate = endDate.subtract(Duration(days: days));
  
  return repository.countUserWorkouts(
    userId: currentUser.uid,
    startDate: startDate,
    endDate: endDate,
  );
});

/// Provider para obter a sequência atual de dias de treino do usuário.
final userWorkoutStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  // Verificar se há um usuário autenticado
  if (currentUser == null) {
    throw const AppException(
      message: 'Usuário não autenticado',
      code: 'unauthenticated',
    );
  }
  
  return repository.getUserWorkoutStreak(currentUser.uid);
}); 