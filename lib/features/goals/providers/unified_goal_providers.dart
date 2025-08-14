// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/providers/supabase_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../repositories/unified_goal_repository.dart';
import '../models/unified_goal_model.dart';

/// **PROVIDERS UNIFICADOS DE METAS RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 16:00
/// **Objetivo:** Provedores únicos para gerenciar todo o sistema de metas
/// **Referência:** Sistema de metas unificado Ray Club

/// Provider para o repositório unificado de metas
final unifiedGoalRepositoryProvider = Provider<UnifiedGoalRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseUnifiedGoalRepository(supabaseClient);
});

/// Provider para todas as metas do usuário logado
final userGoalsProvider = FutureProvider<List<UnifiedGoal>>((ref) async {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  
  if (authState.user?.id == null) {
    return [];
  }
  
  return await repository.getUserGoals(authState.user!.id);
});

/// Provider para metas ativas do usuário
final activeGoalsProvider = FutureProvider<List<UnifiedGoal>>((ref) async {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  
  if (authState.user?.id == null) {
    return [];
  }
  
  return await repository.getActiveGoals(authState.user!.id);
});

/// Provider para metas de modalidades de exercício
final workoutCategoryGoalsProvider = FutureProvider<List<UnifiedGoal>>((ref) async {
  final allGoals = await ref.watch(activeGoalsProvider.future);
  return allGoals.where((goal) => goal.type == UnifiedGoalType.workoutCategory).toList();
});

/// Provider para metas semanais
final weeklyGoalsProvider = FutureProvider<List<UnifiedGoal>>((ref) async {
  final allGoals = await ref.watch(activeGoalsProvider.future);
  return allGoals.where((goal) => goal.type == UnifiedGoalType.weeklyMinutes).toList();
});

/// Provider para metas de hábitos diários
final dailyHabitGoalsProvider = FutureProvider<List<UnifiedGoal>>((ref) async {
  final allGoals = await ref.watch(activeGoalsProvider.future);
  return allGoals.where((goal) => goal.type == UnifiedGoalType.dailyHabit).toList();
});

/// Provider para criar uma nova meta
final createGoalProvider = Provider((ref) {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  
  return (UnifiedGoal goal) async {
    final createdGoal = await repository.createGoal(goal);
    // Invalidar cache para recarregar as listas
    ref.invalidate(userGoalsProvider);
    ref.invalidate(activeGoalsProvider);
    return createdGoal;
  };
});

/// Provider para atualizar uma meta
final updateGoalProvider = Provider((ref) {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  
  return (UnifiedGoal goal) async {
    final updatedGoal = await repository.updateGoal(goal);
    // Invalidar cache para recarregar as listas
    ref.invalidate(userGoalsProvider);
    ref.invalidate(activeGoalsProvider);
    return updatedGoal;
  };
});

/// Provider para deletar uma meta
final deleteGoalProvider = Provider((ref) {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  
  return (String goalId) async {
    await repository.deleteGoal(goalId);
    // Invalidar cache para recarregar as listas
    ref.invalidate(userGoalsProvider);
    ref.invalidate(activeGoalsProvider);
  };
});

/// Provider para incrementar progresso de uma meta
final incrementGoalProgressProvider = Provider((ref) {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  
  return (String goalId, double increment) async {
    await repository.incrementGoalProgress(goalId, increment);
    // Invalidar cache para recarregar as listas
    ref.invalidate(userGoalsProvider);
    ref.invalidate(activeGoalsProvider);
  };
});

/// Provider para processar treino e atualizar metas automaticamente
final processWorkoutForGoalsProvider = Provider((ref) {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  
  return (String workoutType, int durationMinutes) async {
    if (authState.user?.id == null) return;
    
    await repository.updateGoalsFromWorkout(
      authState.user!.id,
      workoutType,
      durationMinutes,
    );
    
    // Invalidar cache para recarregar as listas
    ref.invalidate(userGoalsProvider);
    ref.invalidate(activeGoalsProvider);
  };
});

/// Provider para estatísticas das metas
final goalStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final allGoals = await ref.watch(userGoalsProvider.future);
  final activeGoals = await ref.watch(activeGoalsProvider.future);
  
  if (allGoals.isEmpty) {
    return {
      'total': 0,
      'active': 0,
      'completed': 0,
      'completion_rate': 0.0,
      'average_progress': 0.0,
    };
  }
  
  final completedGoals = allGoals.where((goal) => goal.isCompleted).length;
  final totalProgress = activeGoals.fold<double>(0.0, (sum, goal) => sum + goal.progressPercentage);
  final averageProgress = activeGoals.isNotEmpty ? totalProgress / activeGoals.length : 0.0;
  final completionRate = allGoals.isNotEmpty ? (completedGoals / allGoals.length) : 0.0;
  
  return {
    'total': allGoals.length,
    'active': activeGoals.length,
    'completed': completedGoals,
    'completion_rate': completionRate,
    'average_progress': averageProgress,
  };
});

/// Provider para criar metas pré-definidas facilmente
final createPresetGoalProvider = Provider((ref) {
  final createGoal = ref.watch(createGoalProvider);
  final authState = ref.watch(authStateProvider);
  
  return ({
    required String presetType,
    required Map<String, dynamic> params,
  }) async {
    if (authState.user?.id == null) {
      throw Exception('Usuário não autenticado');
    }
    
    final userId = authState.user!.id;
    UnifiedGoal goal;
    
    switch (presetType) {
      case 'workout_category':
        goal = UnifiedGoalFactory.createWorkoutCategoryGoal(
          userId: userId,
          category: GoalCategory.fromValue(params['category']),
          targetSessions: params['target_sessions'],
          endDate: params['end_date'],
        );
        break;
        
      case 'weekly_minutes':
        goal = UnifiedGoalFactory.createWeeklyMinutesGoal(
          userId: userId,
          targetMinutes: params['target_minutes'],
        );
        break;
        
      case 'daily_habit':
        goal = UnifiedGoalFactory.createDailyHabitGoal(
          userId: userId,
          title: params['title'],
          description: params['description'],
          targetDays: params['target_days'],
        );
        break;
        
      default:
        throw Exception('Tipo de meta pré-definida não suportado: $presetType');
    }
    
    return await createGoal(goal);
  };
}); 