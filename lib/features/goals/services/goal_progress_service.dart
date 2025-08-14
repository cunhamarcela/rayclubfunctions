// Package imports:
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/constants/workout_category_mapping.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Serviço responsável por atualizar automaticamente as metas
/// quando um treino é registrado
/// 
/// **Data:** 2025-01-21 às 15:25
/// **Objetivo:** Conectar registro de exercícios às metas correspondentes
/// **Referência:** Sistema de metas automático Ray Club

class GoalProgressService {
  final SupabaseClient _supabaseClient;

  GoalProgressService({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Atualiza automaticamente as metas do usuário baseado no treino registrado
  /// 
  /// **Parâmetros:**
  /// - `userId`: ID do usuário
  /// - `workoutType`: Modalidade do exercício (ex: "Corrida", "Yoga")  
  /// - `durationMinutes`: Duração do treino em minutos
  /// - `workoutDate`: Data do treino
  /// 
  /// **Exemplo de uso:**
  /// ```dart
  /// await goalProgressService.updateGoalProgress(
  ///   userId: "user123",
  ///   workoutType: "Corrida", 
  ///   durationMinutes: 30,
  ///   workoutDate: DateTime.now(),
  /// );
  /// ```
  Future<Map<String, dynamic>> updateGoalProgress({
    required String userId,
    required String workoutType,
    required int durationMinutes,
    required DateTime workoutDate,
  }) async {
    try {
      debugPrint('🎯 [GoalProgressService] Atualizando metas automáticamente...');
      debugPrint('📊 Treino: $workoutType ($durationMinutes min) - User: $userId');
      
      // 1. Mapear modalidade do exercício para categoria de meta
      final goalCategory = WorkoutCategoryMapping.getGoalCategory(workoutType);
      debugPrint('🎯 Modalidade "$workoutType" → Categoria "$goalCategory"');
      
      // 2. Buscar metas ativas do usuário para esta categoria
      final activeGoals = await _findActiveGoalsForCategory(
        userId: userId,
        category: goalCategory,
        workoutDate: workoutDate,
      );
      
      if (activeGoals.isEmpty) {
        debugPrint('ℹ️ Nenhuma meta ativa encontrada para categoria "$goalCategory"');
        return {
          'updated_goals': 0,
          'category': goalCategory,
          'message': 'Nenhuma meta ativa para esta categoria',
        };
      }
      
      // 3. Atualizar cada meta encontrada
      final updatedGoals = <Map<String, dynamic>>[];
      
      for (final goal in activeGoals) {
        final updatedGoal = await _updateSingleGoal(
          goalId: goal['id'],
          currentValue: goal['current_value'] ?? 0.0,
          targetValue: goal['target_value'] ?? 1.0,
          durationMinutes: durationMinutes,
        );
        
        if (updatedGoal != null) {
          updatedGoals.add(updatedGoal);
          debugPrint('✅ Meta "${goal['title']}" atualizada: ${updatedGoal['current_value']}/${updatedGoal['target_value']} ${goal['unit']}');
        }
      }
      
      debugPrint('🎉 [GoalProgressService] ${updatedGoals.length} meta(s) atualizada(s) com sucesso!');
      
      return {
        'updated_goals': updatedGoals.length,
        'category': goalCategory,
        'goals': updatedGoals,
        'message': '${updatedGoals.length} meta(s) atualizada(s)',
      };
      
    } catch (e) {
      debugPrint('❌ [GoalProgressService] Erro ao atualizar metas: $e');
      
      // Não propagar erro para não quebrar o fluxo de registro de treino
      return {
        'updated_goals': 0,
        'error': e.toString(),
        'message': 'Erro ao atualizar metas',
      };
    }
  }

  /// Busca metas ativas do usuário para uma categoria específica
  Future<List<Map<String, dynamic>>> _findActiveGoalsForCategory({
    required String userId,
    required String category,
    required DateTime workoutDate,
  }) async {
    try {
      final response = await _supabaseClient
          .from('user_goals')
          .select('id, title, current_value, target_value, unit, goal_type, start_date, target_date')
          .eq('user_id', userId)
          .eq('goal_type', category)
          .eq('is_completed', false);
          
      if (response == null) return [];
      
      final goals = response as List;
      
      // Filtrar metas que estão dentro do período válido
      final activeGoals = goals.where((goal) {
        final startDate = DateTime.tryParse(goal['start_date'] ?? '');
        final targetDate = DateTime.tryParse(goal['target_date'] ?? '');
        
        // Se não há data de início, considerar como ativa
        if (startDate == null) return true;
        
        // Se não há data limite, verificar apenas se já começou
        if (targetDate == null) {
          return workoutDate.isAfter(startDate) || workoutDate.isAtSameMomentAs(startDate);
        }
        
        // Se há ambas as datas, verificar se está no período
        return (workoutDate.isAfter(startDate) || workoutDate.isAtSameMomentAs(startDate)) &&
               (workoutDate.isBefore(targetDate) || workoutDate.isAtSameMomentAs(targetDate));
      }).cast<Map<String, dynamic>>().toList();
      
      debugPrint('🔍 Encontradas ${activeGoals.length} meta(s) ativa(s) para categoria "$category"');
      return activeGoals;
      
    } catch (e) {
      debugPrint('❌ Erro ao buscar metas ativas: $e');
      return [];
    }
  }

  /// Atualiza uma meta específica com os minutos do treino
  Future<Map<String, dynamic>?> _updateSingleGoal({
    required String goalId,
    required double currentValue,
    required double targetValue,
    required int durationMinutes,
  }) async {
    try {
      // Converter minutos para valor compatível com a unidade da meta
      final minutesToAdd = durationMinutes.toDouble();
      final newCurrentValue = currentValue + minutesToAdd;
      
      // Calcular progresso
      final progressPercentage = targetValue > 0 ? (newCurrentValue / targetValue * 100) : 0.0;
      final isCompleted = newCurrentValue >= targetValue;
      
      // Atualizar no banco
      final response = await _supabaseClient
          .from('user_goals')
          .update({
            'current_value': newCurrentValue,
            'progress_percentage': progressPercentage,
            'is_completed': isCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .select('id, title, current_value, target_value, unit, progress_percentage, is_completed')
          .single();
      
      return response;
      
    } catch (e) {
      debugPrint('❌ Erro ao atualizar meta $goalId: $e');
      return null;
    }
  }

  /// Atualiza metas semanais (sistema existente)
  /// Mantém compatibilidade com o sistema de metas semanais já implementado
  Future<void> updateWeeklyGoal({
    required String userId,
    required int durationMinutes,
  }) async {
    try {
      debugPrint('📅 Atualizando meta semanal: +$durationMinutes min');
      
      await _supabaseClient.rpc('add_workout_minutes_to_goal', params: {
        'p_user_id': userId,
        'p_minutes': durationMinutes,
      });
      
      debugPrint('✅ Meta semanal atualizada com sucesso');
      
    } catch (e) {
      debugPrint('❌ Erro ao atualizar meta semanal: $e');
      // Não propagar erro
    }
  }

  /// Método principal para ser chamado quando um treino é registrado
  /// Atualiza tanto metas por categoria quanto metas semanais
  Future<Map<String, dynamic>> processWorkoutForGoals({
    required String userId,
    required String workoutType,
    required int durationMinutes,
    required DateTime workoutDate,
  }) async {
    debugPrint('🚀 [GoalProgressService] Processando treino para atualização de metas...');
    
    // Atualizar metas por categoria
    final categoryResult = await updateGoalProgress(
      userId: userId,
      workoutType: workoutType,
      durationMinutes: durationMinutes,
      workoutDate: workoutDate,
    );
    
    // Atualizar meta semanal (sistema existente)
    await updateWeeklyGoal(
      userId: userId,
      durationMinutes: durationMinutes,
    );
    
    return {
      ...categoryResult,
      'weekly_goal_updated': true,
    };
  }
} 