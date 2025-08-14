// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/models/user_goal_mapper.dart';

/// Interface do repositório para metas do usuário
abstract class GoalRepository {
  /// Obtém todas as metas do usuário atual
  Future<List<UserGoal>> getUserGoals();
  
  /// Cria uma nova meta
  Future<UserGoal> createGoal(UserGoal goal);
  
  /// Atualiza o progresso de uma meta existente
  Future<UserGoal> updateGoalProgress(String goalId, double currentValue);
  
  /// Exclui uma meta
  Future<void> deleteGoal(String goalId);
}

/// Implementação mock do repositório para desenvolvimento
class MockGoalRepository implements GoalRepository {
  @override
  Future<List<UserGoal>> getUserGoals() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockGoals = _getMockGoals();
    return mockGoals;
  }

  @override
  Future<UserGoal> createGoal(UserGoal goal) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Gerar ID simulado
    return goal.copyWith(
      id: 'goal-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserGoal> updateGoalProgress(String goalId, double currentValue) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final goals = _getMockGoals();
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    
    if (goalIndex == -1) {
      throw NotFoundException(
        message: 'Meta não encontrada',
        code: 'goal_not_found',
      );
    }
    
    final goal = goals[goalIndex];
    final updatedGoal = goal.copyWith(
      progress: currentValue,
      updatedAt: DateTime.now(),
    );
    
    return updatedGoal;
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final goals = _getMockGoals();
    final goalExists = goals.any((g) => g.id == goalId);
    
    if (!goalExists) {
      throw NotFoundException(
        message: 'Meta não encontrada',
        code: 'goal_not_found',
      );
    }
    
    // Em um repositório real, a meta seria excluída do banco de dados
    return;
  }
  
  /// Retorna lista de metas mockadas para desenvolvimento
  List<UserGoal> _getMockGoals() {
    final now = DateTime.now();
    
    return [
      UserGoal(
        id: 'goal-1',
        userId: 'user123',
        title: 'Treinar 5x por semana',
        target: 5,
        progress: 3,
        unit: 'vezes',
        type: GoalType.workout,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 21)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      UserGoal(
        id: 'goal-2',
        userId: 'user123',
        title: 'Perder 5kg',
        target: 5,
        progress: 2.5,
        unit: 'kg',
        type: GoalType.weight,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      UserGoal(
        id: 'goal-3',
        userId: 'user123',
        title: 'Completar 30 treinos',
        target: 30,
        progress: 12,
        unit: 'treinos',
        type: GoalType.workout,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }
}

/// Implementação com Supabase
class SupabaseGoalRepository implements GoalRepository {
  final SupabaseClient _supabaseClient;

  SupabaseGoalRepository(this._supabaseClient);

  @override
  Future<List<UserGoal>> getUserGoals() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('user_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => UserGoalMapper.fromSupabaseJson(json)).toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockGoalRepository().getUserGoals();
    }
  }

  @override
  Future<UserGoal> createGoal(UserGoal goal) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Garantir que o ID do usuário seja o do usuário atual
      final goalData = goal.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
      );
      
      final response = await _supabaseClient
          .from('user_goals')
          .insert(UserGoalMapper.toSupabaseJson(goalData))
          .select()
          .single();
      
      return UserGoalMapper.fromSupabaseJson(response);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao criar meta: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<UserGoal> updateGoalProgress(String goalId, double currentValue) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Buscar meta atual para verificar o valor alvo
      final goalResponse = await _supabaseClient
          .from('user_goals')
          .select()
          .eq('id', goalId)
          .eq('user_id', userId)
          .single();
      
      final goal = UserGoalMapper.fromSupabaseJson(goalResponse);
      final isCompleted = currentValue >= goal.target;
      
      // Atualizar o progresso
      final response = await _supabaseClient
          .from('user_goals')
          .update({
            'progress': currentValue,
            'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .eq('user_id', userId)
          .select()
          .single();
      
      return UserGoalMapper.fromSupabaseJson(response);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar meta: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      await _supabaseClient
          .from('user_goals')
          .delete()
          .eq('id', goalId)
          .eq('user_id', userId);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao excluir meta: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

/// Provider para o repositório de metas
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  // Em desenvolvimento, usar o repositório mock
  return MockGoalRepository();
  
  // Quando estiver pronto para produção:
  // final supabase = Supabase.instance.client;
  // return SupabaseGoalRepository(supabase);
}); 