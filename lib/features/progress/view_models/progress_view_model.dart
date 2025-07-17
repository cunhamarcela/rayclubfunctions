import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/progress/models/progress_state.dart';
import 'package:ray_club_app/features/progress/providers/progress_providers.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/progress/repositories/user_progress_repository.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

// Providers temporários (remover quando implementar corretamente)
final userWorkoutStreakProvider = FutureProvider<int>((ref) async {
  // Retornar valor default para evitar erro
  return 0;
});

final userWorkoutCountProvider = FutureProvider.family<int, int>((ref, days) async {
  // Retornar valor default para evitar erro
  return 0;
});

// Provider para o gerenciamento de progresso
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserProgressRepository(supabase);
});

// Provider para obter workouts para uma data específica
final userWorkoutsForDateProvider = FutureProvider.family<List<dynamic>, DateTime>((ref, date) async {
  // Retornar lista vazia para evitar erros
  return [];
});

class ProgressViewModel extends StateNotifier<ProgressState> {
  final Ref _ref;
  
  ProgressViewModel(this._ref) : super(ProgressState.initial());

  void _initialize() async {
    final authState = _ref.read(authViewModelProvider);
    final isLoggedIn = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isLoggedIn) {
      state = state.copyWith(
        isLoading: false,
        error: const AppException(
          message: 'You need to be logged in to view your progress',
        ),
      );
      return;
    }
    
    // Carregar dados iniciais
    loadUserProgress();
  }
  
  /// Carrega o progresso completo do usuário
  Future<void> loadUserProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authState = _ref.read(authViewModelProvider);
      final user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
      
      if (user == null) {
        throw const AppException(message: 'Usuário não autenticado');
      }
      
      // Carregar o progresso do usuário utilizando o repositório
      final progressRepository = _ref.read(userProgressRepositoryProvider);
      final userProgress = await progressRepository.getProgressForUser(user.id);
      
      // Atualizar estado com o progresso carregado
      state = state.copyWith(
        isLoading: false,
        userProgress: userProgress,
        currentStreak: userProgress.currentStreak,
        workoutCount: userProgress.totalWorkouts,
      );
      
      // Carregar treinos para a data selecionada
      loadWorkoutsForDate(state.selectedDate);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(
          message: 'Erro ao carregar progresso: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadWorkoutsForDate(DateTime date) async {
    state = state.copyWith(isLoadingWorkouts: true, error: null);
    
    try {
      final workoutRecords = await _ref.read(
        userWorkoutsForDateProvider(date).future,
      );
      
      // Converter WorkoutRecord para Workout para compatibilidade com ProgressState
      final workouts = workoutRecords.map((record) => Workout(
        id: record.id,
        name: record.workoutName,
        description: '',
        imageUrl: '',
        type: record.workoutType ?? 'other',
        durationMinutes: record.durationMinutes,
        difficulty: 'medium',
        exerciseCount: 0,
        caloriesBurned: 0,
      )).toList();
      
      state = state.copyWith(
        isLoadingWorkouts: false,
        workouts: workouts,
        selectedDate: date,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingWorkouts: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingWorkouts: false,
        error: AppException(
          message: 'Failed to load workouts: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadWorkoutStreak() async {
    state = state.copyWith(isLoadingStreak: true, streakError: null);
    
    try {
      // Usar valor do progresso do usuário se disponível
      if (state.userProgress != null) {
        state = state.copyWith(
          isLoadingStreak: false,
          currentStreak: state.userProgress!.currentStreak,
        );
      } else {
        // Fallback para o método antigo
        final streak = await _ref.read(userWorkoutStreakProvider.future);
        
        state = state.copyWith(
          isLoadingStreak: false,
          currentStreak: streak,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingStreak: false,
        streakError: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStreak: false,
        streakError: AppException(
          message: 'Failed to load streak: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadWorkoutCount() async {
    state = state.copyWith(isLoadingCount: true, countError: null);
    
    try {
      // Usar valor do progresso do usuário se disponível
      if (state.userProgress != null) {
        state = state.copyWith(
          isLoadingCount: false,
          workoutCount: state.userProgress!.totalWorkouts,
        );
      } else {
        // Fallback para o método antigo
        final count = await _ref.read(userWorkoutCountProvider(30).future);
        
        state = state.copyWith(
          isLoadingCount: false,
          workoutCount: count,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingCount: false,
        countError: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCount: false,
        countError: AppException(
          message: 'Failed to load workout count: ${e.toString()}',
        ),
      );
    }
  }
  
  /// Sincroniza o progresso a partir dos registros de treino
  /// Útil para corrigir inconsistências ou após adicionar treinos manualmente
  Future<void> syncProgressFromWorkouts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authState = _ref.read(authViewModelProvider);
      final user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
      
      if (user == null) {
        throw const AppException(message: 'Usuário não autenticado');
      }
      
      // Sincronizar utilizando o repositório
      final progressRepository = _ref.read(userProgressRepositoryProvider);
      await progressRepository.syncProgressFromWorkoutRecords(user.id);
      
      // Recarregar os dados atualizados
      await loadUserProgress();
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(
          message: 'Erro ao sincronizar progresso: ${e.toString()}',
        ),
      );
    }
  }

  void selectDate(DateTime date) {
    if (state.selectedDate != date) {
      loadWorkoutsForDate(date);
    }
  }
}

final progressViewModelProvider =
    StateNotifierProvider<ProgressViewModel, ProgressState>((ref) {
  return ProgressViewModel(ref);
}); 