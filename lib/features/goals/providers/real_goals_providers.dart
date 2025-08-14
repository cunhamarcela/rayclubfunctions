// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/providers/supabase_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../repositories/real_goals_repository.dart';
import '../models/real_backend_goal_models.dart';

/// **PROVIDERS REAIS DE METAS - RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 18:45
/// **Objetivo:** Conectar frontend com as funções SQL REAIS do backend
/// **Referência:** Sistema existente com 26 funções SQL já implementadas
/// 
/// IMPORTANTE: Estes providers usam as estruturas que JÁ FUNCIONAM

/// Provider para o repositório real de metas
final realGoalsRepositoryProvider = Provider<RealGoalsRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseRealGoalsRepository(supabaseClient);
});

/// Provider para metas de categoria do usuário (workout_category_goals)
/// Esta é a tabela que JÁ FAZ a integração treino→meta automaticamente!
final userCategoryGoalsProvider = FutureProvider<List<WorkoutCategoryGoal>>((ref) async {
  debugPrint('🎯 [Provider] ========== INICIANDO BUSCA DE METAS ==========');
  
  try {
    final repository = ref.watch(realGoalsRepositoryProvider);
    debugPrint('🎯 [Provider] Repository obtido: ${repository.runtimeType}');
    
    final userId = ref.watch(currentUserIdProvider);
    debugPrint('🎯 [Provider] User ID obtido: $userId');
    
    if (userId == null) {
      debugPrint('❌ [Provider] Usuário não autenticado');
      throw Exception('Usuário não autenticado');
    }
    
    debugPrint('🎯 [Provider] Chamando repository.getUserCategoryGoals...');
    final result = await repository.getUserCategoryGoals(userId);
    debugPrint('🎯 [Provider] Resultado obtido: ${result.length} metas');
    
    for (int i = 0; i < result.length; i++) {
      final goal = result[i];
      debugPrint('🎯 [Provider] Meta $i: ${goal.category} - ${goal.currentMinutes}/${goal.goalMinutes}min (${goal.percentageCompleted}%)');
    }
    
    debugPrint('✅ [Provider] ========== BUSCA CONCLUÍDA COM SUCESSO ==========');
    return result;
  } catch (e, stackTrace) {
    debugPrint('❌ [Provider] ========== ERRO NA BUSCA DE METAS ==========');
    debugPrint('❌ [Provider] Erro: $e');
    debugPrint('❌ [Provider] Tipo do erro: ${e.runtimeType}');
    debugPrint('❌ [Provider] Stack trace: $stackTrace');
    debugPrint('❌ [Provider] ================================================');
    rethrow;
  }
});

/// Provider para metas semanais expandidas (weekly_goals_expanded)
final userWeeklyGoalsProvider = FutureProvider<List<WeeklyGoalExpanded>>((ref) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }
  
  return repository.getUserWeeklyGoals(userId);
});

/// Provider para meta personalizada ativa (personalized_weekly_goals)
final userActiveGoalProvider = FutureProvider<PersonalizedWeeklyGoal?>((ref) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return null;
  }
  
  return repository.getUserActiveGoal(userId);
});

/// Provider para estatísticas das metas de categoria
final categoryGoalsStatsProvider = FutureProvider<CategoryGoalsStats>((ref) async {
  final categoryGoals = await ref.watch(userCategoryGoalsProvider.future);
  
  int totalGoals = categoryGoals.length;
  int completedGoals = categoryGoals.where((goal) => goal.completed).length;
  int totalMinutesGoal = categoryGoals.fold(0, (sum, goal) => sum + goal.goalMinutes);
  int totalMinutesCurrent = categoryGoals.fold(0, (sum, goal) => sum + goal.currentMinutes);
  
  double progressPercentage = totalMinutesGoal > 0 
      ? (totalMinutesCurrent / totalMinutesGoal * 100).clamp(0, 100)
      : 0;
  
  return CategoryGoalsStats(
    totalGoals: totalGoals,
    completedGoals: completedGoals,
    totalMinutesGoal: totalMinutesGoal,
    totalMinutesCurrent: totalMinutesCurrent,
    progressPercentage: progressPercentage,
  );
});

/// Provider para estatísticas das metas semanais
final weeklyGoalsStatsProvider = FutureProvider<WeeklyGoalsStats>((ref) async {
  final weeklyGoals = await ref.watch(userWeeklyGoalsProvider.future);
  
  int totalGoals = weeklyGoals.length;
  int completedGoals = weeklyGoals.where((goal) => goal.completed).length;
  double totalProgress = weeklyGoals.fold(0.0, (sum, goal) => sum + goal.currentValue);
  double totalTarget = weeklyGoals.fold(0.0, (sum, goal) => sum + goal.targetValue);
  
  double overallProgress = totalTarget > 0 
      ? (totalProgress / totalTarget * 100).clamp(0, 100)
      : 0;
  
  return WeeklyGoalsStats(
    totalGoals: totalGoals,
    completedGoals: completedGoals,
    totalProgress: totalProgress,
    totalTarget: totalTarget,
    overallProgress: overallProgress,
    currentWeekGoals: weeklyGoals.where((goal) => 
        goal.weekStartDate.isBefore(DateTime.now()) && 
        goal.weekEndDate.isAfter(DateTime.now())).toList(),
  );
});

/// Provider para criar meta de categoria
/// Usa a função SQL: set_category_goal()
final createCategoryGoalProvider = FutureProvider.family<WorkoutCategoryGoal, CreateCategoryGoalParams>((ref, params) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }
  
  final goal = await repository.createOrUpdateCategoryGoal(
    userId, 
    params.category, 
    params.goalMinutes,
  );
  
  // Invalidar cache para atualizar lista
  ref.invalidate(userCategoryGoalsProvider);
  
  return goal;
});

/// Provider para criar meta semanal
/// Usa a função SQL: get_or_create_weekly_goal_expanded()
final createWeeklyGoalProvider = FutureProvider.family<WeeklyGoalExpanded, CreateWeeklyGoalParams>((ref, params) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }
  
  final goal = await repository.createWeeklyGoal(
    userId,
    params.goalType,
    params.measurementType,
    params.title,
    params.targetValue,
    params.unitLabel,
  );
  
  // Invalidar cache para atualizar lista
  ref.invalidate(userWeeklyGoalsProvider);
  
  return goal;
});

/// Provider para criar meta preset
/// Usa a função SQL: create_preset_goal()
final createPresetGoalProvider = FutureProvider.family<PersonalizedWeeklyGoal, String>((ref, presetType) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }
  
  final goal = await repository.createPresetGoal(userId, presetType);
  
  // Invalidar cache para atualizar
  ref.invalidate(userActiveGoalProvider);
  
  return goal;
});

/// Provider para registrar check-in
/// Usa a função SQL: register_goal_checkin()
final registerCheckInProvider = FutureProvider.family<SqlFunctionResponse, CheckInParams>((ref, params) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  
  final response = await repository.registerCheckIn(
    params.goalId,
    params.userId,
    params.notes,
  );
  
  // Invalidar cache se sucesso
  if (response.success) {
    ref.invalidate(userActiveGoalProvider);
  }
  
  return response;
});

/// Provider para adicionar progresso
/// Usa a função SQL: add_goal_progress()
final addGoalProgressProvider = FutureProvider.family<SqlFunctionResponse, AddProgressParams>((ref, params) async {
  final repository = ref.watch(realGoalsRepositoryProvider);
  
  final response = await repository.addGoalProgress(
    params.goalId,
    params.userId,
    params.valueAdded,
    params.notes,
    params.source,
  );
  
  // Invalidar cache se sucesso
  if (response.success) {
    ref.invalidate(userActiveGoalProvider);
  }
  
  return response;
});

/// **CLASSES DE PARÂMETROS**

class CreateCategoryGoalParams {
  final String category;
  final int goalMinutes;
  
  CreateCategoryGoalParams({
    required this.category,
    required this.goalMinutes,
  });
}

class CreateWeeklyGoalParams {
  final String goalType;
  final String measurementType;
  final String title;
  final double targetValue;
  final String unitLabel;
  
  CreateWeeklyGoalParams({
    required this.goalType,
    required this.measurementType,
    required this.title,
    required this.targetValue,
    required this.unitLabel,
  });
}

class CheckInParams {
  final String goalId;
  final String userId;
  final String? notes;
  
  CheckInParams({
    required this.goalId,
    required this.userId,
    this.notes,
  });
}

class AddProgressParams {
  final String goalId;
  final String userId;
  final double valueAdded;
  final String? notes;
  final String? source;
  
  AddProgressParams({
    required this.goalId,
    required this.userId,
    required this.valueAdded,
    this.notes,
    this.source,
  });
}

/// **CLASSES DE ESTATÍSTICAS**

class CategoryGoalsStats {
  final int totalGoals;
  final int completedGoals;
  final int totalMinutesGoal;
  final int totalMinutesCurrent;
  final double progressPercentage;
  
  CategoryGoalsStats({
    required this.totalGoals,
    required this.completedGoals,
    required this.totalMinutesGoal,
    required this.totalMinutesCurrent,
    required this.progressPercentage,
  });
}

class WeeklyGoalsStats {
  final int totalGoals;
  final int completedGoals;
  final double totalProgress;
  final double totalTarget;
  final double overallProgress;
  final List<WeeklyGoalExpanded> currentWeekGoals;
  
  WeeklyGoalsStats({
    required this.totalGoals,
    required this.completedGoals,
    required this.totalProgress,
    required this.totalTarget,
    required this.overallProgress,
    required this.currentWeekGoals,
  });
} 