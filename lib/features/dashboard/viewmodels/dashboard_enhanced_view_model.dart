// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository_enhanced.dart';

/// Provider para o ViewModel do dashboard aprimorado
final dashboardEnhancedViewModelProvider = 
    StateNotifierProvider<DashboardEnhancedViewModel, AsyncValue<DashboardDataEnhanced>>((ref) {
  final repository = ref.watch(dashboardRepositoryEnhancedProvider);
  return DashboardEnhancedViewModel(repository);
});

/// ViewModel para gerenciar o estado do dashboard aprimorado
class DashboardEnhancedViewModel extends StateNotifier<AsyncValue<DashboardDataEnhanced>> {
  final DashboardRepositoryEnhanced _repository;
  
  DashboardEnhancedViewModel(this._repository) : super(const AsyncValue.loading()) {
    // Carrega os dados automaticamente ao inicializar
    loadDashboardData();
  }
  
  /// Carrega todos os dados do dashboard
  Future<void> loadDashboardData() async {
    try {
      state = const AsyncValue.loading();
      
      final data = await _repository.getDashboardData();
      
      state = AsyncValue.data(data);
    } on AppException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AppException(
          message: 'Erro ao carregar dashboard',
          code: 'LOAD_ERROR',
          originalError: e,
        ),
        stackTrace,
      );
    }
  }
  
  /// Atualiza o consumo de água
  Future<void> updateWaterIntake(int cups) async {
    try {
      // Atualiza localmente primeiro para resposta rápida
      state.whenData((data) {
        final updatedWaterIntake = data.waterIntake.copyWith(
          cups: cups,
          updatedAt: DateTime.now(),
        );
        
        state = AsyncValue.data(
          data.copyWith(waterIntake: updatedWaterIntake),
        );
      });
      
      // Depois salva no servidor
      await _repository.updateWaterIntake(cups);
      
    } catch (e) {
      // Se falhar, recarrega os dados
      await loadDashboardData();
      
      // E mostra o erro
      throw AppException(
        message: 'Erro ao atualizar consumo de água',
        code: 'UPDATE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Incrementa o consumo de água em 1 copo
  Future<void> incrementWaterIntake() async {
    state.whenData((data) async {
      final newCups = data.waterIntake.cups + 1;
      await updateWaterIntake(newCups);
    });
  }
  
  /// Decrementa o consumo de água em 1 copo
  Future<void> decrementWaterIntake() async {
    state.whenData((data) async {
      final newCups = (data.waterIntake.cups - 1).clamp(0, 999);
      await updateWaterIntake(newCups);
    });
  }
  
  /// Marca uma meta como completa
  Future<void> completeGoal(String goalId) async {
    try {
      // Atualiza localmente
      state.whenData((data) {
        final updatedGoals = data.goals.map((goal) {
          if (goal.id == goalId) {
            return goal.copyWith(
              isCompleted: true,
              updatedAt: DateTime.now(),
            );
          }
          return goal;
        }).toList();
        
        state = AsyncValue.data(
          data.copyWith(goals: updatedGoals),
        );
      });
      
      // Salva no servidor
      await _repository.completeGoal(goalId);
      
    } catch (e) {
      // Se falhar, recarrega
      await loadDashboardData();
      throw e;
    }
  }
  
  /// Atualiza o progresso de uma meta
  Future<void> updateGoalProgress(String goalId, double currentValue) async {
    try {
      // Atualiza localmente
      state.whenData((data) {
        final updatedGoals = data.goals.map((goal) {
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
        
        state = AsyncValue.data(
          data.copyWith(goals: updatedGoals),
        );
      });
      
      // Salva no servidor
      await _repository.updateGoalProgress(goalId, currentValue);
      
      // Se a meta foi completada, marca como completa
      state.whenData((data) {
        final goal = data.goals.firstWhere((g) => g.id == goalId);
        if (currentValue >= goal.targetValue && !goal.isCompleted) {
          completeGoal(goalId);
        }
      });
      
    } catch (e) {
      await loadDashboardData();
      throw e;
    }
  }
  
  /// Recarrega todos os dados do dashboard
  Future<void> refreshData() async {
    await loadDashboardData();
  }
  
  /// Obtém o percentual de conclusão do desafio atual
  double getChallengeCompletionPercentage() {
    return state.maybeWhen(
      data: (data) => data.challengeProgress?.completionPercentage ?? 0.0,
      orElse: () => 0.0,
    );
  }
  
  /// Verifica se o usuário tem um desafio ativo
  bool hasActiveChallenge() {
    return state.maybeWhen(
      data: (data) => data.currentChallenge != null,
      orElse: () => false,
    );
  }
  
  /// Obtém o número total de metas não completadas
  int getPendingGoalsCount() {
    return state.maybeWhen(
      data: (data) => data.goals.where((goal) => !goal.isCompleted).length,
      orElse: () => 0,
    );
  }
  
  /// Verifica se o usuário atingiu a meta de água do dia
  bool hasReachedWaterGoal() {
    return state.maybeWhen(
      data: (data) => data.waterIntake.cups >= data.waterIntake.goal,
      orElse: () => false,
    );
  }
} 