// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';

/// State para UserGoalsViewModel
class UserGoalsState {
  /// Lista de metas do usuário
  final List<UserGoal> goals;
  
  /// Indica se está carregando dados
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;

  /// Construtor
  UserGoalsState({
    required this.goals,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Cria uma cópia do estado com alguns campos alterados
  UserGoalsState copyWith({
    List<UserGoal>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserGoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel para gerenciar metas do usuário
/// PATCH: Corrigir bug 5 - Criar ViewModel separado para UserGoals
class UserGoalsViewModel extends StateNotifier<UserGoalsState> {
  final GoalRepository _repository;

  /// Construtor
  UserGoalsViewModel(this._repository) : super(UserGoalsState(goals: [])) {
    // Carregar metas ao inicializar
    loadUserGoals();
  }

  /// Carrega todas as metas do usuário
  Future<void> loadUserGoals() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final goals = await _repository.getUserGoals();
      
      state = state.copyWith(
        goals: goals,
        isLoading: false,
      );
      
      debugPrint('✅ Metas carregadas com sucesso: ${goals.length}');
    } catch (e) {
      debugPrint('❌ Erro ao carregar metas: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao carregar metas: ${e.toString()}',
      );
    }
  }

  /// Adiciona uma nova meta
  Future<UserGoal?> addGoal(UserGoal goal) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final createdGoal = await _repository.createGoal(goal);
      
      // Atualizar estado com a nova meta
      state = state.copyWith(
        goals: [...state.goals, createdGoal],
        isLoading: false,
      );
      
      debugPrint('✅ Meta criada com sucesso: ${createdGoal.title}');
      return createdGoal;
    } catch (e) {
      debugPrint('❌ Erro ao criar meta: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao criar meta: ${e.toString()}',
      );
      
      return null;
    }
  }

  /// Atualiza o progresso de uma meta
  Future<UserGoal?> updateGoalProgress(String goalId, double progress) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedGoal = await _repository.updateGoalProgress(goalId, progress);
      
      // Atualizar a meta específica na lista
      final updatedGoals = state.goals.map((goal) {
        return goal.id == goalId ? updatedGoal : goal;
      }).toList();
      
      state = state.copyWith(
        goals: updatedGoals,
        isLoading: false,
      );
      
      debugPrint('✅ Progresso da meta atualizado: ${updatedGoal.title} - ${updatedGoal.progress}/${updatedGoal.target}');
      return updatedGoal;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar progresso: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao atualizar progresso: ${e.toString()}',
      );
      
      return null;
    }
  }

  /// Exclui uma meta
  Future<bool> deleteGoal(String goalId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteGoal(goalId);
      
      // Remover a meta excluída da lista
      final updatedGoals = state.goals.where((goal) => goal.id != goalId).toList();
      
      state = state.copyWith(
        goals: updatedGoals,
        isLoading: false,
      );
      
      debugPrint('✅ Meta excluída com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao excluir meta: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao excluir meta: ${e.toString()}',
      );
      
      return false;
    }
  }
}

/// Provider para o ViewModel de metas do usuário
final userGoalsViewModelProvider = StateNotifierProvider<UserGoalsViewModel, UserGoalsState>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return UserGoalsViewModel(repository);
}); 