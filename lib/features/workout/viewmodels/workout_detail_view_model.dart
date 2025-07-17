// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import '../providers/workout_providers.dart';

/// Estado da tela de detalhes do workout
class WorkoutDetailState {
  /// Se está carregando os dados
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;
  
  /// Workout sendo visualizado
  final Workout? workout;

  /// Construtor
  const WorkoutDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.workout,
  });

  /// Cria um estado inicial
  factory WorkoutDetailState.initial() => const WorkoutDetailState(isLoading: true);

  /// Cria uma cópia deste estado com os campos especificados atualizados
  WorkoutDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    Workout? workout,
  }) {
    return WorkoutDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      workout: workout ?? this.workout,
    );
  }

  /// Cria um estado de erro
  factory WorkoutDetailState.error(String message) => WorkoutDetailState(
    isLoading: false,
    errorMessage: message,
  );

  /// Cria um estado com o workout carregado
  factory WorkoutDetailState.loaded(Workout workout) => WorkoutDetailState(
    isLoading: false,
    workout: workout,
  );
}

/// ViewModel para a tela de detalhes do workout
class WorkoutDetailViewModel extends StateNotifier<WorkoutDetailState> {
  /// Repositório de workouts
  final WorkoutRepository _repository;
  
  /// ID do workout a ser carregado
  final String workoutId;

  /// Construtor
  WorkoutDetailViewModel(this._repository, this.workoutId) 
      : super(WorkoutDetailState.initial()) {
    loadWorkout();
  }

  /// Carrega os detalhes do workout
  Future<void> loadWorkout() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final workout = await _repository.getWorkoutById(workoutId);
      
      if (workout != null) {
        state = WorkoutDetailState.loaded(workout);
      } else {
        state = WorkoutDetailState.error('Treino não encontrado');
      }
    } catch (e) {
      debugPrint('Erro ao carregar workout: $e');
      state = WorkoutDetailState.error('Erro ao carregar treino: $e');
    }
  }

  /// Favorita ou desfavorita o workout
  Future<void> toggleFavorite() async {
    if (state.workout == null) return;
    
    try {
      // Otimistic update
      final currentWorkout = state.workout!;
      final updatedWorkout = currentWorkout.copyWith(
        isFavorite: !currentWorkout.isFavorite
      );
      
      state = state.copyWith(workout: updatedWorkout);
      
      // Persiste a mudança
      await _repository.updateWorkout(updatedWorkout);
    } catch (e) {
      // Restaura o estado em caso de erro
      state = state.copyWith(workout: state.workout);
      debugPrint('Erro ao favoritar/desfavoritar workout: $e');
    }
  }
}

/// Provider que fornece acesso ao WorkoutDetailViewModel
final workoutDetailViewModelProvider = StateNotifierProvider.family<
    WorkoutDetailViewModel, WorkoutDetailState, String>((ref, workoutId) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutDetailViewModel(repository, workoutId);
}); 