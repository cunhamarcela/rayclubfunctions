import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/core/services/supabase_service.dart';
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal_expanded.dart';
import 'package:ray_club_app/features/goals/models/goal_period_filter.dart';

/// Repositório para gerenciar metas semanais expandidas
class WeeklyGoalExpandedRepository {
  final SupabaseService _supabaseService;

  WeeklyGoalExpandedRepository({
    SupabaseService? supabaseService,
  }) : _supabaseService = supabaseService ?? SupabaseService();

  /// Obtém ou cria meta semanal para o usuário
  Future<WeeklyGoalExpanded> getOrCreateWeeklyGoal({
    required String userId,
    GoalPresetType goalType = GoalPresetType.custom,
    GoalMeasurementType measurementType = GoalMeasurementType.minutes,
    double targetValue = 180,
    String goalTitle = 'Meta Semanal',
    String unitLabel = 'min',
  }) async {
    try {
      final response = await _supabaseService.supabase
          .rpc('get_or_create_weekly_goal_expanded', params: {
        'p_user_id': userId,
        'p_goal_type': goalType.value,
        'p_measurement_type': measurementType.value,
        'p_target_value': targetValue,
        'p_goal_title': goalTitle,
        'p_unit_label': unitLabel,
      });

      if (response == null || response.isEmpty) {
        throw AppException(message: 'Erro ao obter meta semanal');
      }

      final goalData = response[0] as Map<String, dynamic>;
      return _mapToWeeklyGoalExpanded(goalData);
    } catch (e) {
      throw AppException(message: 'Erro ao obter ou criar meta semanal: ${e.toString()}');
    }
  }

  /// Cria meta a partir de preset
  Future<WeeklyGoalExpanded> createPresetGoal({
    required String userId,
    required GoalPresetType presetType,
  }) async {
    try {
      final response = await _supabaseService.supabase
          .rpc('create_preset_weekly_goal', params: {
        'p_user_id': userId,
        'p_preset_type': presetType.value,
      });

      if (response == null) {
        throw AppException(message: 'Erro ao criar meta preset');
      }

      final goalId = response as String;
      
      // Buscar a meta criada
      return await getGoalById(goalId);
    } catch (e) {
      throw AppException(message: 'Erro ao criar meta preset: ${e.toString()}');
    }
  }

  /// Obtém meta por ID
  Future<WeeklyGoalExpanded> getGoalById(String goalId) async {
    try {
      final response = await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .select()
          .eq('id', goalId)
          .single();

      return _mapToWeeklyGoalExpanded(response);
    } catch (e) {
      throw AppException(message: 'Erro ao buscar meta: ${e.toString()}');
    }
  }

  /// Lista todas as metas do usuário
  Future<List<WeeklyGoalExpanded>> getUserWeeklyGoals(String userId) async {
    try {
      final response = await _supabaseService.supabase
          .rpc('get_user_weekly_goals', params: {
        'p_user_id': userId,
      });

      if (response == null) return [];

      return (response as List)
          .map((goalData) => _mapToWeeklyGoalExpanded(goalData))
          .toList();
    } catch (e) {
      throw AppException(message: 'Erro ao listar metas: ${e.toString()}');
    }
  }

  /// Obtém meta ativa da semana atual
  Future<WeeklyGoalExpanded?> getCurrentWeekGoal(String userId) async {
    try {
      final goals = await getUserWeeklyGoals(userId);
      
      // Retorna a primeira meta da semana atual
      for (final goal in goals) {
        if (goal.isCurrentWeek) {
          return goal;
        }
      }
      
      return null;
    } catch (e) {
      throw AppException(message: 'Erro ao buscar meta atual: ${e.toString()}');
    }
  }

  /// Atualiza progresso da meta
  Future<bool> updateGoalProgress({
    required String userId,
    required double addedValue,
    GoalMeasurementType measurementType = GoalMeasurementType.minutes,
  }) async {
    try {
      final response = await _supabaseService.supabase
          .rpc('update_weekly_goal_progress', params: {
        'p_user_id': userId,
        'p_added_value': addedValue,
        'p_measurement_type': measurementType.value,
      });

      return response == true;
    } catch (e) {
      throw AppException(message: 'Erro ao atualizar progresso: ${e.toString()}');
    }
  }

  /// Atualiza meta existente
  Future<WeeklyGoalExpanded> updateGoal({
    required String goalId,
    String? goalTitle,
    String? goalDescription,
    double? targetValue,
    String? unitLabel,
    GoalMeasurementType? measurementType,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (goalTitle != null) updateData['goal_title'] = goalTitle;
      if (goalDescription != null) updateData['goal_description'] = goalDescription;
      if (targetValue != null) updateData['target_value'] = targetValue;
      if (unitLabel != null) updateData['unit_label'] = unitLabel;
      if (measurementType != null) updateData['measurement_type'] = measurementType.value;
      
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .update(updateData)
          .eq('id', goalId)
          .select()
          .single();

      return _mapToWeeklyGoalExpanded(response);
    } catch (e) {
      throw AppException(message: 'Erro ao atualizar meta: ${e.toString()}');
    }
  }

  /// Marca meta como concluída
  Future<WeeklyGoalExpanded> completeGoal(String goalId) async {
    try {
      final response = await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .update({
            'completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .select()
          .single();

      return _mapToWeeklyGoalExpanded(response);
    } catch (e) {
      throw AppException(message: 'Erro ao completar meta: ${e.toString()}');
    }
  }

  /// Desativa meta
  Future<bool> deactivateGoal(String goalId) async {
    try {
      await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .update({
            'active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);

      return true;
    } catch (e) {
      throw AppException(message: 'Erro ao desativar meta: ${e.toString()}');
    }
  }

  /// Cria meta personalizada
  Future<WeeklyGoalExpanded> createCustomGoal({
    required String userId,
    required String goalTitle,
    String? goalDescription,
    required GoalMeasurementType measurementType,
    required double targetValue,
    required String unitLabel,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final response = await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .insert({
            'user_id': userId,
            'goal_type': GoalPresetType.custom.value,
            'measurement_type': measurementType.value,
            'goal_title': goalTitle,
            'goal_description': goalDescription,
            'target_value': targetValue,
            'unit_label': unitLabel,
            'week_start_date': weekStart.toIso8601String().split('T')[0],
            'week_end_date': weekEnd.toIso8601String().split('T')[0],
          })
          .select()
          .single();

      return _mapToWeeklyGoalExpanded(response);
    } catch (e) {
      throw AppException(message: 'Erro ao criar meta personalizada: ${e.toString()}');
    }
  }

  /// Obtém estatísticas do usuário
  Future<Map<String, dynamic>> getUserGoalStats(String userId) async {
    try {
      final goals = await getUserWeeklyGoals(userId);
      
      final totalGoals = goals.length;
      final completedGoals = goals.where((g) => g.completed).length;
      final currentWeekGoal = goals.firstWhere(
        (g) => g.isCurrentWeek,
        orElse: () => WeeklyGoalExpanded(
          id: '',
          userId: userId,
          weekStartDate: DateTime.now(),
          weekEndDate: DateTime.now(),
        ),
      );

      return {
        'total_goals': totalGoals,
        'completed_goals': completedGoals,
        'completion_rate': totalGoals > 0 ? (completedGoals / totalGoals * 100).round() : 0,
        'current_week_progress': currentWeekGoal.id.isNotEmpty ? currentWeekGoal.percentageCompleted : 0.0,
        'streak': _calculateStreak(goals),
      };
    } catch (e) {
      throw AppException(message: 'Erro ao obter estatísticas: ${e.toString()}');
    }
  }

  /// Calcula sequência de semanas com metas atingidas
  int _calculateStreak(List<WeeklyGoalExpanded> goals) {
    final completedGoals = goals
        .where((g) => g.completed)
        .toList()
      ..sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));

    int streak = 0;
    DateTime? lastWeek;

    for (final goal in completedGoals) {
      if (lastWeek == null) {
        streak = 1;
        lastWeek = goal.weekStartDate;
      } else {
        final expectedPreviousWeek = lastWeek.subtract(const Duration(days: 7));
        if (goal.weekStartDate.isAtSameMomentAs(expectedPreviousWeek)) {
          streak++;
          lastWeek = goal.weekStartDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// 📋 Obtém TODAS as metas ativas da semana atual
  Future<List<WeeklyGoalExpanded>> getAllCurrentWeekGoals(String userId) async {
    try {
      print('🔍 DEBUG: Buscando todas as metas da semana atual para userId: $userId');
      
      final allGoals = await getUserWeeklyGoals(userId);
      final currentWeekGoals = allGoals.where((goal) => goal.isCurrentWeek && goal.active).toList();
      
      print('🔍 DEBUG: ✅ Encontradas ${currentWeekGoals.length} metas ativas da semana atual');
      return currentWeekGoals;
    } catch (e) {
      print('🚨 DEBUG: Erro ao buscar metas da semana atual: $e');
      throw AppException(message: 'Erro ao buscar metas da semana atual: ${e.toString()}');
    }
  }

  /// 🗓️ Obtém metas filtradas por período
  Future<List<WeeklyGoalExpanded>> getGoalsByPeriod(String userId, GoalPeriodFilter filter) async {
    try {
      print('🔍 DEBUG: Buscando metas por período: ${filter.displayName} para userId: $userId');
      
      final allGoals = await getUserWeeklyGoals(userId);
      List<WeeklyGoalExpanded> filteredGoals;
      
      switch (filter) {
        case GoalPeriodFilter.currentWeek:
          filteredGoals = allGoals.where((goal) => goal.isCurrentWeek && goal.active).toList();
          break;
          
        case GoalPeriodFilter.lastWeek:
          final lastWeekStart = DateTime.now().subtract(const Duration(days: 7));
          filteredGoals = allGoals.where((goal) {
            final goalWeek = goal.weekStartDate;
            final isLastWeek = goalWeek.isAfter(lastWeekStart.subtract(const Duration(days: 7))) && 
                              goalWeek.isBefore(lastWeekStart.add(const Duration(days: 1)));
            return isLastWeek && goal.active;
          }).toList();
          break;
          
        case GoalPeriodFilter.last4Weeks:
          final fourWeeksAgo = DateTime.now().subtract(const Duration(days: 28));
          filteredGoals = allGoals.where((goal) {
            return goal.weekStartDate.isAfter(fourWeeksAgo) && goal.active;
          }).toList();
          break;
          
        case GoalPeriodFilter.allTime:
          filteredGoals = allGoals.where((goal) => goal.active).toList();
          break;
      }
      
      // Ordenar por data de criação (mais recente primeiro)
      filteredGoals.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      
      print('🔍 DEBUG: ✅ Encontradas ${filteredGoals.length} metas para o período: ${filter.displayName}');
      return filteredGoals;
    } catch (e) {
      print('🚨 DEBUG: Erro ao buscar metas por período: $e');
      throw AppException(message: 'Erro ao buscar metas por período: ${e.toString()}');
    }
  }

  /// 🔥 MÉTODO SIMPLES: Atualizar valor direto na tabela
  Future<void> updateGoalCurrentValue(String goalId, double newValue) async {
    try {
      print('🔥 Atualizando meta $goalId para valor $newValue na tabela weekly_goals_expanded');
      
      await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .update({
            'current_value': newValue,
            'completed': newValue >= 0, // Considerar como progresso
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
      
      print('🔥 ✅ Meta atualizada diretamente na tabela!');
    } catch (e) {
      print('🚨 ERRO ao atualizar meta diretamente: $e');
      throw AppException(message: 'Erro ao atualizar meta: ${e.toString()}');
    }
  }

  /// 🎯 Define progresso absoluto para check-ins (usado para bolinhas)
  Future<bool> setGoalProgressAbsolute({
    required String userId,
    required double absoluteValue,
    GoalMeasurementType measurementType = GoalMeasurementType.days,
  }) async {
    try {
      print('🔍 DEBUG: Definindo progresso absoluto: $absoluteValue para tipo: ${measurementType.value}');
      
      // Buscar meta ativa da semana atual
      final currentWeekGoals = await getAllCurrentWeekGoals(userId);
      final goal = currentWeekGoals.firstWhere(
        (g) => g.measurementType == measurementType,
        orElse: () => throw AppException(message: 'Meta não encontrada para o tipo especificado'),
      );
      
      // Atualizar usando o método direto
      await updateGoalCurrentValue(goal.id, absoluteValue);
      
      print('🔍 DEBUG: ✅ Progresso absoluto definido com sucesso!');
      return true;
    } catch (e) {
      print('🚨 DEBUG: ERRO ao definir progresso absoluto: $e');
      return false;
    }
  }



  /// 🗑️ Deletar meta
  Future<void> deleteGoal(String goalId) async {
    try {
      print('🗑️ Removendo meta $goalId');
      
      await _supabaseService.supabase
          .from('weekly_goals_expanded')
          .delete()
          .eq('id', goalId);
      
      print('🗑️ ✅ Meta removida com sucesso!');
    } catch (e) {
      print('🚨 ERRO ao remover meta: $e');
      throw AppException(message: 'Erro ao remover meta: ${e.toString()}');
    }
  }

  /// Mapeia dados do banco para modelo
  WeeklyGoalExpanded _mapToWeeklyGoalExpanded(Map<String, dynamic> data) {
    try {
      print('🔍 DEBUG: Mapeando dados do banco: $data');
      
      // 🛡️ PROTEÇÃO: Verificar campos obrigatórios
      final id = data['id']?.toString() ?? '';
      final userId = data['user_id']?.toString() ?? '';
      final goalType = data['goal_type']?.toString() ?? 'custom';
      final measurementType = data['measurement_type']?.toString() ?? 'minutes';
      final goalTitle = data['goal_title']?.toString() ?? 'Meta Sem Título';
      final unitLabel = data['unit_label']?.toString() ?? 'unidade';
      final weekStartDate = data['week_start_date']?.toString() ?? DateTime.now().toIso8601String().split('T')[0];
      final weekEndDate = data['week_end_date']?.toString() ?? DateTime.now().toIso8601String().split('T')[0];
      
      // 🛡️ PROTEÇÃO: Verificar números
      final targetValue = (data['target_value'] as num?)?.toDouble() ?? 1.0;
      final currentValue = (data['current_value'] as num?)?.toDouble() ?? 0.0;
      final completed = data['completed'] as bool? ?? false;
      final active = data['active'] as bool? ?? true;
      
      print('🔍 DEBUG: ✅ Mapeamento concluído - ID: $id, Título: $goalTitle');
      
      return WeeklyGoalExpanded(
        id: id,
        userId: userId,
        goalType: GoalPresetType.fromString(goalType),
        measurementType: GoalMeasurementType.fromString(measurementType),
        goalTitle: goalTitle,
        goalDescription: data['goal_description']?.toString(),
        targetValue: targetValue,
        currentValue: currentValue,
        unitLabel: unitLabel,
        weekStartDate: DateTime.parse(weekStartDate),
        weekEndDate: DateTime.parse(weekEndDate),
        completed: completed,
        active: active,
        createdAt: data['created_at'] != null 
            ? DateTime.parse(data['created_at'].toString())
            : null,
        updatedAt: data['updated_at'] != null 
            ? DateTime.parse(data['updated_at'].toString())
            : null,
      );
    } catch (e, stackTrace) {
      print('🚨 ERRO DEBUG: Falha ao mapear meta: $e');
      print('🚨 ERRO DEBUG: Stack trace: $stackTrace');
      print('🚨 ERRO DEBUG: Dados originais: $data');
      rethrow;
    }
  }
} 