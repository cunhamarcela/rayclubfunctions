import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_videos_repository.dart';

// Provider para vídeos por categoria
final workoutVideosByCategoryProvider = FutureProvider.family<List<WorkoutVideo>, String>((ref, category) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return repository.getVideosByCategory(category);
});

// Provider para vídeos populares
final popularWorkoutVideosProvider = FutureProvider<List<WorkoutVideo>>((ref) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return repository.getPopularVideos();
});

// Provider para vídeos recomendados
final recommendedWorkoutVideosProvider = FutureProvider<List<WorkoutVideo>>((ref) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return repository.getRecommendedVideos();
});

// Provider para vídeos novos
final newWorkoutVideosProvider = FutureProvider<List<WorkoutVideo>>((ref) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return repository.getNewVideos();
});

// Provider para todos os vídeos
final allWorkoutVideosProvider = FutureProvider<List<WorkoutVideo>>((ref) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return repository.getAllVideos();
});

// State para filtros de busca
class WorkoutVideoFilters {
  final String? query;
  final String? category;
  final String? difficulty;
  final String? instructor;
  final int? maxDuration;

  WorkoutVideoFilters({
    this.query,
    this.category,
    this.difficulty,
    this.instructor,
    this.maxDuration,
  });

  WorkoutVideoFilters copyWith({
    String? query,
    String? category,
    String? difficulty,
    String? instructor,
    int? maxDuration,
  }) {
    return WorkoutVideoFilters(
      query: query ?? this.query,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      instructor: instructor ?? this.instructor,
      maxDuration: maxDuration ?? this.maxDuration,
    );
  }
}

// Provider para filtros
final workoutVideoFiltersProvider = StateProvider<WorkoutVideoFilters>((ref) {
  return WorkoutVideoFilters();
});

// Provider para busca com filtros
final filteredWorkoutVideosProvider = FutureProvider<List<WorkoutVideo>>((ref) async {
  final filters = ref.watch(workoutVideoFiltersProvider);
  final repository = ref.watch(workoutVideosRepositoryProvider);
  
  return repository.searchVideos(
    query: filters.query,
    category: filters.category,
    difficulty: filters.difficulty,
    instructor: filters.instructor,
    maxDuration: filters.maxDuration,
  );
});

// ViewModel principal
class WorkoutVideosViewModel extends StateNotifier<AsyncValue<void>> {
  final WorkoutVideosRepository _repository;
  final Ref _ref;

  WorkoutVideosViewModel(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Registra visualização de um vídeo
  Future<void> recordVideoView(String videoId, String userId) async {
    try {
      await _repository.recordVideoView(videoId, userId);
    } catch (e) {
      // Não bloqueia o usuário em caso de erro
      debugPrint('Erro ao registrar visualização: $e');
    }
  }

  /// Atualiza filtros de busca
  void updateFilters({
    String? query,
    String? category,
    String? difficulty,
    String? instructor,
    int? maxDuration,
  }) {
    final currentFilters = _ref.read(workoutVideoFiltersProvider);
    _ref.read(workoutVideoFiltersProvider.notifier).state = currentFilters.copyWith(
      query: query,
      category: category,
      difficulty: difficulty,
      instructor: instructor,
      maxDuration: maxDuration,
    );
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _ref.read(workoutVideoFiltersProvider.notifier).state = WorkoutVideoFilters();
  }

  /// Aplica filtro de categoria
  void filterByCategory(String category) {
    updateFilters(category: category);
  }

  /// Aplica filtro de dificuldade
  void filterByDifficulty(String difficulty) {
    updateFilters(difficulty: difficulty);
  }

  /// Busca por texto
  void searchVideos(String query) {
    updateFilters(query: query);
  }
}

// Provider do ViewModel
final workoutVideosViewModelProvider = StateNotifierProvider<WorkoutVideosViewModel, AsyncValue<void>>((ref) {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return WorkoutVideosViewModel(repository, ref);
}); 