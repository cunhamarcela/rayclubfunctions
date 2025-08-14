// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';
import 'package:ray_club_app/features/goals/viewmodels/user_goals_view_model.dart';

/// Provider para o repositório de metas do usuário
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseGoalRepository(supabaseClient);
});

/// Provider para o ViewModel de metas do usuário
final userGoalsViewModelProvider = 
    StateNotifierProvider<UserGoalsViewModel, UserGoalsState>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return UserGoalsViewModel(repository);
});

/// Provider para acessar apenas a lista de metas
final userGoalsListProvider = Provider<List<UserGoal>>((ref) {
  final goalsState = ref.watch(userGoalsViewModelProvider);
  return goalsState.goals;
});

/// Provider para metas ativas (não completadas)
final activeGoalsProvider = Provider<List<UserGoal>>((ref) {
  final allGoals = ref.watch(userGoalsListProvider);
  return allGoals.where((goal) => !goal.isCompleted).toList();
});

/// Provider para metas completadas
final completedGoalsProvider = Provider<List<UserGoal>>((ref) {
  final allGoals = ref.watch(userGoalsListProvider);
  return allGoals.where((goal) => goal.isCompleted).toList();
});

/// Provider para verificar se há erro no carregamento das metas
final goalsErrorProvider = Provider<String?>((ref) {
  final goalsState = ref.watch(userGoalsViewModelProvider);
  return goalsState.errorMessage;
});

/// Provider para verificar se as metas estão carregando
final goalsLoadingProvider = Provider<bool>((ref) {
  final goalsState = ref.watch(userGoalsViewModelProvider);
  return goalsState.isLoading;
}); 