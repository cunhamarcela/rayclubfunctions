// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_model.dart';

part 'workout_state.freezed.dart';

/// Estado dos treinos no ViewModel
@freezed
class WorkoutState with _$WorkoutState {
  const WorkoutState._();

  /// Estado inicial, sem dados carregados
  const factory WorkoutState.initial() = _WorkoutStateInitial;

  /// Estado de carregamento
  const factory WorkoutState.loading() = _WorkoutStateLoading;

  /// Estado com os treinos carregados
  const factory WorkoutState.loaded({
    @Default([]) List<Workout> workouts,
    @Default([]) List<Workout> filteredWorkouts,
    @Default([]) List<String> categories,
    @Default(WorkoutFilter()) WorkoutFilter filter,
  }) = _WorkoutStateLoaded;

  /// Estado com um treino específico selecionado
  const factory WorkoutState.selectedWorkout({
    required Workout workout,
    @Default([]) List<Workout> workouts,
    @Default([]) List<Workout> filteredWorkouts,
    @Default([]) List<String> categories,
    @Default(WorkoutFilter()) WorkoutFilter filter,
  }) = _WorkoutStateSelectedWorkout;

  /// Estado de erro
  const factory WorkoutState.error(String message) = _WorkoutStateError;

  /// Verifica se está em estado de carregando
  bool get isLoading => maybeWhen(
        loading: () => true,
        initial: () => true,
        orElse: () => false,
      );

  /// Lista de treinos atual (considerando filtros se aplicados)
  List<Workout> get currentWorkouts => maybeWhen(
        loaded: (workouts, filteredWorkouts, _, __) => 
            filteredWorkouts.isNotEmpty ? filteredWorkouts : workouts,
        selectedWorkout: (_, workouts, filteredWorkouts, __, ___) => 
            filteredWorkouts.isNotEmpty ? filteredWorkouts : workouts,
        orElse: () => [],
      );

  /// Treino atualmente selecionado
  Workout? get selectedWorkout => maybeWhen(
        selectedWorkout: (workout, _, __, ___, ____) => workout,
        orElse: () => null,
      );
} 
