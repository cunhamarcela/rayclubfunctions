// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/workout/models/workout_category.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';

/// Estado da tela de categorias de workout
class WorkoutCategoriesState {
  /// Se está carregando os dados
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;
  
  /// Lista de categorias de workout
  final List<WorkoutCategory> categories;

  /// Construtor
  const WorkoutCategoriesState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
  });

  /// Cria um estado inicial
  factory WorkoutCategoriesState.initial() => const WorkoutCategoriesState(isLoading: true);

  /// Cria uma cópia deste estado com os campos especificados atualizados
  WorkoutCategoriesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<WorkoutCategory>? categories,
  }) {
    return WorkoutCategoriesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
    );
  }

  /// Cria um estado de erro
  factory WorkoutCategoriesState.error(String message) => WorkoutCategoriesState(
    isLoading: false,
    errorMessage: message,
  );

  /// Cria um estado com categorias carregadas
  factory WorkoutCategoriesState.loaded(List<WorkoutCategory> categories) => WorkoutCategoriesState(
    isLoading: false,
    categories: categories,
  );
}

/// ViewModel para a tela de categorias de workout
class WorkoutCategoriesViewModel extends StateNotifier<WorkoutCategoriesState> {
  /// Repositório de workouts
  final WorkoutRepository _repository;

  /// Construtor
  WorkoutCategoriesViewModel(this._repository) 
      : super(WorkoutCategoriesState.initial()) {
    loadCategories();
  }

  /// Carrega as categorias de workout
  Future<void> loadCategories() async {
    try {
      debugPrint('🔍 WorkoutCategoriesViewModel: Iniciando carregamento de categorias...');
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      debugPrint('🔍 WorkoutCategoriesViewModel: Repositório tipo: ${_repository.runtimeType}');
      final categories = await _repository.getWorkoutCategories();
      
      debugPrint('✅ WorkoutCategoriesViewModel: ${categories.length} categorias carregadas');
      state = WorkoutCategoriesState.loaded(categories);
    } catch (e, stackTrace) {
      debugPrint('❌ WorkoutCategoriesViewModel: Erro ao carregar categorias: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      state = WorkoutCategoriesState.error('Erro ao carregar categorias: $e');
    }
  }
}

/// Provider que fornece acesso ao WorkoutCategoriesViewModel
final workoutCategoriesViewModelProvider = 
    StateNotifierProvider<WorkoutCategoriesViewModel, WorkoutCategoriesState>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutCategoriesViewModel(repository);
}); 