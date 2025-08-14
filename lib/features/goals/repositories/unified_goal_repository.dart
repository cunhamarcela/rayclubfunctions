// Package imports:
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/constants/workout_category_mapping.dart';
import '../models/unified_goal_model.dart';

/// **REPOSITÓRIO UNIFICADO DE METAS RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 15:45
/// **Objetivo:** Interface única para gerenciar todas as metas do sistema
/// **Referência:** Sistema de metas unificado Ray Club
/// 
/// Funciona com a tabela `user_goals` existente no Supabase

abstract class UnifiedGoalRepository {
  Future<List<UnifiedGoal>> getUserGoals(String userId);
  Future<List<UnifiedGoal>> getActiveGoals(String userId);
  Future<UnifiedGoal> createGoal(UnifiedGoal goal);
  Future<UnifiedGoal> updateGoal(UnifiedGoal goal);
  Future<void> deleteGoal(String goalId);
  Future<void> incrementGoalProgress(String goalId, double increment);
  Future<List<UnifiedGoal>> getGoalsForWorkoutCategory(String userId, String category);
  Future<void> updateGoalsFromWorkout(String userId, String workoutType, int durationMinutes);
}

/// Implementação do repositório usando Supabase
class SupabaseUnifiedGoalRepository implements UnifiedGoalRepository {
  final SupabaseClient _client;
  static const String _tableName = 'user_goals';

  SupabaseUnifiedGoalRepository(this._client);

  @override
  Future<List<UnifiedGoal>> getUserGoals(String userId) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Buscando metas para usuário: $userId');
      
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('📊 [UnifiedGoalRepository] Resposta do banco: ${response.length} metas');

      return response.map((data) => _mapFromDatabase(data)).toList();
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao buscar metas: $e');
      throw AppException('Erro ao carregar metas: $e');
    }
  }

  @override
  Future<List<UnifiedGoal>> getActiveGoals(String userId) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Buscando metas ativas para usuário: $userId');
      
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .or('end_date.is.null,end_date.gte.${DateTime.now().toIso8601String()}')
          .order('created_at', ascending: false);

      debugPrint('📊 [UnifiedGoalRepository] Metas ativas encontradas: ${response.length}');

      return response.map((data) => _mapFromDatabase(data)).toList();
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao buscar metas ativas: $e');
      throw AppException('Erro ao carregar metas ativas: $e');
    }
  }

  @override
  Future<UnifiedGoal> createGoal(UnifiedGoal goal) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Criando nova meta: ${goal.title}');
      
      final goalData = _mapToDatabase(goal);
      goalData.remove('id'); // Remove ID para deixar o banco gerar
      goalData.remove('updated_at'); // Remove updated_at na criação

      final response = await _client
          .from(_tableName)
          .insert(goalData)
          .select()
          .single();

      debugPrint('✅ [UnifiedGoalRepository] Meta criada com ID: ${response['id']}');

      return _mapFromDatabase(response);
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao criar meta: $e');
      throw AppException('Erro ao criar meta: $e');
    }
  }

  @override
  Future<UnifiedGoal> updateGoal(UnifiedGoal goal) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Atualizando meta: ${goal.id}');
      
      final goalData = _mapToDatabase(goal);
      goalData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(goalData)
          .eq('id', goal.id)
          .select()
          .single();

      debugPrint('✅ [UnifiedGoalRepository] Meta atualizada: ${goal.id}');

      return _mapFromDatabase(response);
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao atualizar meta: $e');
      throw AppException('Erro ao atualizar meta: $e');
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Deletando meta: $goalId');
      
      await _client
          .from(_tableName)
          .delete()
          .eq('id', goalId);

      debugPrint('✅ [UnifiedGoalRepository] Meta deletada: $goalId');
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao deletar meta: $e');
      throw AppException('Erro ao deletar meta: $e');
    }
  }

  @override
  Future<void> incrementGoalProgress(String goalId, double increment) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Incrementando progresso da meta: $goalId (+$increment)');
      
      // Buscar meta atual
      final currentGoal = await _client
          .from(_tableName)
          .select()
          .eq('id', goalId)
          .single();

      final currentValue = (currentGoal['current_value'] ?? 0.0).toDouble();
      final targetValue = (currentGoal['target_value'] ?? 1.0).toDouble();
      final newValue = currentValue + increment;
      final isCompleted = newValue >= targetValue;

      // Atualizar valores
      final updateData = {
        'current_value': newValue,
        'is_completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isCompleted && currentGoal['completed_at'] == null) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _client
          .from(_tableName)
          .update(updateData)
          .eq('id', goalId);

      debugPrint('✅ [UnifiedGoalRepository] Progresso atualizado: $currentValue → $newValue (meta: $targetValue)');
      
      if (isCompleted) {
        debugPrint('🎉 [UnifiedGoalRepository] Meta completada!');
      }
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao incrementar progresso: $e');
      throw AppException('Erro ao atualizar progresso: $e');
    }
  }

  @override
  Future<List<UnifiedGoal>> getGoalsForWorkoutCategory(String userId, String category) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Buscando metas da categoria: $category');
      
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('goal_type', 'workout_category')
          .eq('category', category)
          .eq('is_completed', false)
          .eq('auto_increment', true);

      debugPrint('📊 [UnifiedGoalRepository] Metas encontradas para categoria $category: ${response.length}');

      return response.map((data) => _mapFromDatabase(data)).toList();
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao buscar metas da categoria: $e');
      return []; // Não propagar erro para não interromper fluxo de treino
    }
  }

  @override
  Future<void> updateGoalsFromWorkout(String userId, String workoutType, int durationMinutes) async {
    try {
      debugPrint('🎯 [UnifiedGoalRepository] Processando treino para metas automáticas...');
      debugPrint('📊 Treino: $workoutType ($durationMinutes min) - User: $userId');
      
      // 1. Mapear modalidade para categoria
      final goalCategory = WorkoutCategoryMapping.getGoalCategory(workoutType);
      debugPrint('🔄 Modalidade "$workoutType" → Categoria "$goalCategory"');
      
      // 2. Buscar metas de categoria específica
      final categoryGoals = await getGoalsForWorkoutCategory(userId, goalCategory);
      
      // 3. Buscar metas semanais de minutos
      final weeklyGoals = await _getWeeklyMinutesGoals(userId);
      
      final allGoalsToUpdate = [...categoryGoals, ...weeklyGoals];
      
      if (allGoalsToUpdate.isEmpty) {
        debugPrint('ℹ️ Nenhuma meta automática encontrada para processar');
        return;
      }
      
      // 4. Atualizar cada meta
      for (final goal in allGoalsToUpdate) {
        final increment = _calculateIncrement(goal, durationMinutes);
        if (increment > 0) {
          await incrementGoalProgress(goal.id, increment);
          debugPrint('✅ Meta "${goal.title}" atualizada: +$increment ${goal.unit.shortLabel}');
        }
      }
      
      debugPrint('🎉 [UnifiedGoalRepository] ${allGoalsToUpdate.length} meta(s) processada(s) com sucesso!');
      
    } catch (e) {
      debugPrint('❌ [UnifiedGoalRepository] Erro ao processar treino: $e');
      // Não propagar erro para não interromper fluxo de treino
    }
  }

  /// Busca metas semanais ativas
  Future<List<UnifiedGoal>> _getWeeklyMinutesGoals(String userId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .eq('goal_type', 'weekly_minutes')
        .eq('is_completed', false)
        .eq('auto_increment', true)
        .gte('end_date', DateTime.now().toIso8601String());

    return response.map((data) => _mapFromDatabase(data)).toList();
  }

  /// Calcula o incremento baseado no tipo de meta
  double _calculateIncrement(UnifiedGoal goal, int durationMinutes) {
    switch (goal.type) {
      case UnifiedGoalType.workoutCategory:
        return 1.0; // +1 sessão
      case UnifiedGoalType.weeklyMinutes:
        return durationMinutes.toDouble(); // +minutos
      case UnifiedGoalType.dailyHabit:
        return 1.0; // +1 dia (se aplicável)
      case UnifiedGoalType.custom:
        return 0.0; // Metas customizadas não são auto-incrementadas
    }
  }

  /// Converte dados do banco para modelo UnifiedGoal
  UnifiedGoal _mapFromDatabase(Map<String, dynamic> data) {
    return UnifiedGoal.fromDatabaseMap(data);
  }

  /// Converte modelo UnifiedGoal para dados do banco
  Map<String, dynamic> _mapToDatabase(UnifiedGoal goal) {
    return goal.toDatabaseMap();
  }
} 