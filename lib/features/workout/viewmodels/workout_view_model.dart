// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';

/// Provider para injeção do ViewModel de treinos
final workoutViewModelProvider = StateNotifierProvider<WorkoutViewModel, WorkoutState>((ref) {
  return WorkoutViewModel(
    repository: ref.watch(workoutRepositoryProvider),
  );
});

/// ViewModel responsável por gerenciar o estado dos treinos
/// 
/// **Documentação:** Gerencia carregamento, seleção e ordenação de treinos por data (mais recente primeiro).
/// Filtros foram removidos conforme solicitado - todos os treinos são mostrados ordenados cronologicamente.
class WorkoutViewModel extends StateNotifier<WorkoutState> {
  final WorkoutRepository _repository;

  WorkoutViewModel({
    required WorkoutRepository repository,
  })  : _repository = repository,
        super(const WorkoutState.initial()) {
    // Carrega treinos automaticamente na inicialização
    loadWorkouts();
  }

  /// Carrega todos os treinos do repositório
  /// 
  /// **Documentação:** Os treinos são carregados e ordenados por data de criação (mais recente primeiro)
  /// no próprio repositório. Não há aplicação de filtros.
  Future<void> loadWorkouts() async {
    try {
      state = const WorkoutState.loading();
      
      final workouts = await _repository.getWorkouts();
      final categories = await _repository.getWorkoutCategories();
      final categoryNames = categories.map((c) => c.name).toList();
      
      state = WorkoutState.loaded(
        workouts: workouts,
        filteredWorkouts: workouts,
        categories: categoryNames,
        filter: const WorkoutFilter(), // Filtro vazio sempre
      );
    } catch (e) {
      debugPrint('Erro ao carregar treinos: $e');
      state = WorkoutState.error('Erro ao carregar treinos: ${e.toString()}');
    }
  }

  /// Seleciona um treino específico para visualização detalhada
  /// 
  /// **Documentação:** Mantém o treino selecionado no estado para navegação.
  void selectWorkout(Workout workout) {
    state.maybeWhen(
      loaded: (workouts, filteredWorkouts, categories, filter) {
        state = WorkoutState.selectedWorkout(
          workout: workout,
          workouts: workouts,
          filteredWorkouts: workouts, // Sempre todos os treinos
          categories: categories,
          filter: const WorkoutFilter(), // Filtro vazio sempre
        );
      },
      orElse: () {},
    );
  }

  /// Limpa a seleção atual do treino
  /// 
  /// **Documentação:** Remove o treino selecionado e volta ao estado de lista.
  void clearSelection() {
    state.maybeWhen(
      selectedWorkout: (workout, workouts, filteredWorkouts, categories, filter) {
        state = WorkoutState.loaded(
          workouts: workouts,
          filteredWorkouts: workouts, // Sempre todos os treinos
          categories: categories,
          filter: const WorkoutFilter(), // Filtro vazio sempre
        );
      },
      orElse: () {},
    );
  }

  /// Recarrega a lista de treinos
  /// 
  /// **Documentação:** Força uma nova busca no repositório para atualizar a lista.
  Future<void> refreshWorkouts() async {
    await loadWorkouts();
  }
} 
