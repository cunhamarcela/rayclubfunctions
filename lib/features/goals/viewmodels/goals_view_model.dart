// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';

/// Provider para o ViewModel de metas
final goalsViewModelProvider = 
    StateNotifierProvider<GoalsViewModel, AsyncValue<List<GoalData>>>((ref) {
  return GoalsViewModel();
});

/// ViewModel para gerenciar metas do usuário
class GoalsViewModel extends StateNotifier<AsyncValue<List<GoalData>>> {
  final _supabase = Supabase.instance.client;
  
  GoalsViewModel() : super(const AsyncValue.loading()) {
    loadGoals();
  }
  
  /// Carrega todas as metas do usuário
  Future<void> loadGoals() async {
    try {
      state = const AsyncValue.loading();
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      final response = await _supabase
          .from('user_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final goals = (response as List)
          .map((json) => GoalData.fromJson(json))
          .toList();
      
      state = AsyncValue.data(goals);
      
    } on PostgrestException catch (e) {
      state = AsyncValue.error(
        AppException(
          message: 'Erro ao carregar metas',
          code: e.code ?? 'DATABASE_ERROR',
          originalError: e,
        ),
        StackTrace.current,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AppException(
          message: 'Erro inesperado',
          code: 'UNKNOWN_ERROR',
          originalError: e,
        ),
        stackTrace,
      );
    }
  }
  
  /// Cria uma nova meta
  Future<void> createGoal({
    required String title,
    required String category,
    required double targetValue,
    required String unit,
    String? description,
    DateTime? deadline,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      final newGoal = {
        'user_id': userId,
        'title': title,
        'category': category,
        'target_value': targetValue,
        'current_value': 0,
        'unit': unit,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('user_goals').insert(newGoal);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar meta',
        code: 'CREATE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Atualiza uma meta existente
  Future<void> updateGoal({
    required String goalId,
    required String title,
    required String category,
    required double targetValue,
    required String unit,
    String? description,
    DateTime? deadline,
  }) async {
    try {
      final updates = {
        'title': title,
        'category': category,
        'target_value': targetValue,
        'unit': unit,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase
          .from('user_goals')
          .update(updates)
          .eq('id', goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar meta',
        code: 'UPDATE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Atualiza o progresso de uma meta
  Future<void> updateGoalProgress(String goalId, double currentValue) async {
    try {
      // Atualiza localmente primeiro
      state.whenData((goals) {
        final updatedGoals = goals.map((goal) {
          if (goal.id == goalId) {
            final isCompleted = currentValue >= goal.targetValue;
            return goal.copyWith(
              currentValue: currentValue,
              isCompleted: isCompleted,
              updatedAt: DateTime.now(),
            );
          }
          return goal;
        }).toList();
        
        state = AsyncValue.data(updatedGoals);
      });
      
      // Atualiza no banco
      final isCompleted = await _checkIfCompleted(goalId, currentValue);
      
      await _supabase
          .from('user_goals')
          .update({
            'current_value': currentValue,
            'is_completed': isCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
      
    } catch (e) {
      // Se falhar, recarrega
      await loadGoals();
      throw AppException(
        message: 'Erro ao atualizar progresso',
        code: 'UPDATE_PROGRESS_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Marca uma meta como concluída
  Future<void> completeGoal(String goalId) async {
    try {
      await _supabase
          .from('user_goals')
          .update({
            'is_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
      
      // Registra conquista
      await _recordGoalAchievement(goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao completar meta',
        code: 'COMPLETE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Exclui uma meta
  Future<void> deleteGoal(String goalId) async {
    try {
      await _supabase
          .from('user_goals')
          .delete()
          .eq('id', goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao excluir meta',
        code: 'DELETE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Busca uma meta específica pelo ID
  Future<GoalData?> getGoalById(String goalId) async {
    try {
      final response = await _supabase
          .from('user_goals')
          .select()
          .eq('id', goalId)
          .maybeSingle();
      
      if (response != null) {
        return GoalData.fromJson(response);
      }
      
      return null;
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar meta',
        code: 'GET_GOAL_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Verifica se a meta foi completada baseado no valor atual
  Future<bool> _checkIfCompleted(String goalId, double currentValue) async {
    try {
      final response = await _supabase
          .from('user_goals')
          .select('target_value')
          .eq('id', goalId)
          .single();
      
      final targetValue = response['target_value'] as double;
      return currentValue >= targetValue;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Registra conquista de meta para gamificação
  Future<void> _recordGoalAchievement(String goalId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // Registra conquista
      await _supabase.from('user_achievements').insert({
        'user_id': userId,
        'achievement_type': 'goal_completed',
        'reference_id': goalId,
        'points': 10, // 10 pontos por completar meta
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Atualiza pontos do usuário
      await _supabase.rpc('increment_user_points', params: {
        'user_id_param': userId,
        'points_param': 10,
      });
      
    } catch (e) {
      // Não bloqueia o fluxo se falhar ao registrar conquista
      print('Erro ao registrar conquista de meta: $e');
    }
  }
} 