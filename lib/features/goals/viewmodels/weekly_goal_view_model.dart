import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal.dart';
import 'package:ray_club_app/features/goals/repositories/weekly_goal_repository.dart';

/// Estado do ViewModel de metas semanais
class WeeklyGoalState {
  final WeeklyGoal? currentGoal;
  final List<WeeklyGoal> history;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  WeeklyGoalState({
    this.currentGoal,
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  WeeklyGoalState copyWith({
    WeeklyGoal? currentGoal,
    List<WeeklyGoal>? history,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return WeeklyGoalState(
      currentGoal: currentGoal ?? this.currentGoal,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

/// ViewModel para gerenciar metas semanais
class WeeklyGoalViewModel extends StateNotifier<WeeklyGoalState> {
  final WeeklyGoalRepository _repository;
  StreamSubscription<WeeklyGoal?>? _goalSubscription;

  WeeklyGoalViewModel(this._repository) : super(WeeklyGoalState()) {
    loadCurrentGoal();
    _watchCurrentGoal();
  }

  /// Carrega a meta semanal atual
  Future<void> loadCurrentGoal() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _repository.getOrCreateCurrentWeeklyGoal();
      state = state.copyWith(
        currentGoal: goal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Atualiza a meta semanal
  Future<void> updateGoal(int goalMinutes) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedGoal = await _repository.updateWeeklyGoal(goalMinutes);
      state = state.copyWith(
        currentGoal: updatedGoal,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  /// Atualiza a meta usando uma opção predefinida
  Future<void> updateGoalWithOption(WeeklyGoalOption option) async {
    if (option == WeeklyGoalOption.custom) {
      // Para opção customizada, não fazer nada aqui
      return;
    }
    await updateGoal(option.minutes);
  }

  /// Adiciona minutos de treino
  Future<void> addWorkoutMinutes(int minutes) async {
    try {
      final updatedGoal = await _repository.addWorkoutMinutes(minutes);
      state = state.copyWith(currentGoal: updatedGoal);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Carrega histórico de metas
  Future<void> loadHistory({int limit = 12}) async {
    try {
      final history = await _repository.getWeeklyGoalsHistory(limit: limit);
      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Escuta mudanças em tempo real
  void _watchCurrentGoal() {
    _goalSubscription?.cancel();
    _goalSubscription = _repository.watchCurrentWeeklyGoal().listen(
      (goal) {
        if (goal != null) {
          state = state.copyWith(currentGoal: goal);
        }
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  @override
  void dispose() {
    _goalSubscription?.cancel();
    super.dispose();
  }
}

/// Provider para o repository de metas semanais
final weeklyGoalRepositoryProvider = Provider<WeeklyGoalRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  
  return WeeklyGoalRepository(
    supabase: supabase,
  );
});

/// Provider para o ViewModel de metas semanais
final weeklyGoalViewModelProvider = StateNotifierProvider<WeeklyGoalViewModel, WeeklyGoalState>((ref) {
  final repository = ref.watch(weeklyGoalRepositoryProvider);
  return WeeklyGoalViewModel(repository);
}); 