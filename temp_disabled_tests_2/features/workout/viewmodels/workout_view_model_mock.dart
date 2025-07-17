// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';

/// Uma implementação simplificada do estado do WorkoutViewModel para testes
class TestWorkoutState {
  final List<Workout> workouts;
  final List<Workout> currentWorkouts;
  final List<String> categories;
  final bool isLoading;
  final String? errorMessage;
  final Workout? selectedWorkout;

  TestWorkoutState({
    required this.workouts,
    required this.currentWorkouts,
    required this.categories,
    required this.isLoading,
    this.errorMessage,
    this.selectedWorkout,
  });

  /// Estado inicial - carregando
  factory TestWorkoutState.initial() {
    return TestWorkoutState(
      workouts: [],
      currentWorkouts: [],
      categories: [],
      isLoading: true,
    );
  }

  /// Criar uma cópia do estado com valores atualizados
  TestWorkoutState copyWith({
    List<Workout>? workouts,
    List<Workout>? currentWorkouts,
    List<String>? categories,
    bool? isLoading,
    String? errorMessage,
    Workout? selectedWorkout,
    bool clearErrorMessage = false,
    bool clearSelectedWorkout = false,
  }) {
    return TestWorkoutState(
      workouts: workouts ?? this.workouts,
      currentWorkouts: currentWorkouts ?? this.currentWorkouts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      selectedWorkout: clearSelectedWorkout ? null : selectedWorkout ?? this.selectedWorkout,
    );
  }
}

/// Interface do repositório de workout para testes
abstract class IWorkoutRepository {
  Future<List<Workout>> getWorkouts();
  Future<Workout> getWorkoutById(String id);
  Future<Workout> createWorkout(Workout workout);
}

/// Implementação Mock do repositório de workout para testes
class MockWorkoutRepository extends Mock implements IWorkoutRepository {}

/// Implementação Mock do WorkoutViewModel para testes
class MockWorkoutViewModel extends StateNotifier<TestWorkoutState> {
  final IWorkoutRepository repository;
  final bool autoLoad;

  MockWorkoutViewModel(this.repository, {this.autoLoad = false}) 
      : super(TestWorkoutState.initial()) {
    if (autoLoad) {
      loadWorkouts(); // Carregar treinos automaticamente ao criar o ViewModel, se solicitado
    }
  }

  /// Carrega a lista de treinos do repositório
  Future<void> loadWorkouts() async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
      
      final workouts = await repository.getWorkouts();
      
      // Extrair categorias distintas dos treinos
      final categories = workouts
          .map((workout) => workout.type)
          .toSet()
          .toList();
      
      state = state.copyWith(
        workouts: workouts,
        currentWorkouts: workouts,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Falha ao carregar treinos: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Filtra os treinos por categoria
  void filterByCategory(String category) {
    if (category.isEmpty) {
      resetFilters();
      return;
    }
    
    final filteredWorkouts = state.workouts
        .where((workout) => workout.type == category)
        .toList();
    
    state = state.copyWith(currentWorkouts: filteredWorkouts);
  }

  /// Filtra os treinos por duração máxima (em minutos)
  void filterByDuration(int maxDuration) {
    if (maxDuration <= 0) {
      resetFilters();
      return;
    }
    
    final filteredWorkouts = state.workouts
        .where((workout) => workout.durationMinutes <= maxDuration)
        .toList();
    
    state = state.copyWith(currentWorkouts: filteredWorkouts);
  }

  /// Filtra os treinos por nível de dificuldade
  void filterByDifficulty(String difficulty) {
    if (difficulty.isEmpty) {
      resetFilters();
      return;
    }
    
    final filteredWorkouts = state.workouts
        .where((workout) => workout.difficulty == difficulty)
        .toList();
    
    state = state.copyWith(currentWorkouts: filteredWorkouts);
  }

  /// Limpa todos os filtros aplicados
  void resetFilters() {
    state = state.copyWith(currentWorkouts: state.workouts);
  }

  /// Seleciona um treino pelo ID
  Future<void> selectWorkout(String id) async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
      
      final workout = await repository.getWorkoutById(id);
      
      state = state.copyWith(
        selectedWorkout: workout,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Falha ao selecionar treino: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Limpa o treino selecionado
  void clearSelection() {
    state = state.copyWith(clearSelectedWorkout: true);
  }

  /// Cria um novo treino
  Future<void> createWorkout(Workout workout) async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
      
      final createdWorkout = await repository.createWorkout(workout);
      
      // Adicionar o novo treino à lista
      final updatedWorkouts = [...state.workouts, createdWorkout];
      
      // Extrair categorias atualizadas
      final updatedCategories = updatedWorkouts
          .map((w) => w.type)
          .toSet()
          .toList();
      
      state = state.copyWith(
        workouts: updatedWorkouts,
        currentWorkouts: updatedWorkouts,
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Falha ao criar treino: ${e.toString()}',
        isLoading: false,
      );
    }
  }
}

/// Provider para o MockWorkoutViewModel
final mockWorkoutViewModelProvider = StateNotifierProvider<MockWorkoutViewModel, TestWorkoutState>((ref) {
  final repository = MockWorkoutRepository();
  return MockWorkoutViewModel(repository, autoLoad: true);
}); 
