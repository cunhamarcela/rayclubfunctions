// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/workouts/repositories/workout_repository.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Estado específico para a tela de progresso
class ProgressState {
  final bool isLoading;
  final AppException? error;
  final ChallengeProgress? userProgress;
  final List<Workout> workoutsForDate;
  final DateTime selectedDate;
  
  const ProgressState({
    this.isLoading = false,
    this.error,
    this.userProgress,
    this.workoutsForDate = const [],
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? const DateTime(2024, 1, 1);
  
  ProgressState copyWith({
    bool? isLoading,
    AppException? error,
    ChallengeProgress? userProgress,
    List<Workout>? workoutsForDate,
    DateTime? selectedDate,
  }) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userProgress: userProgress ?? this.userProgress,
      workoutsForDate: workoutsForDate ?? this.workoutsForDate,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// Provider para o ProgressViewModel
final progressViewModelProvider = StateNotifierProvider<ProgressViewModel, ProgressState>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  
  return ProgressViewModel(
    challengeRepository: challengeRepository,
    authRepository: authRepository,
    workoutRepository: workoutRepository,
  );
});

/// ViewModel para gerenciar o estado de progresso do usuário
class ProgressViewModel extends StateNotifier<ProgressState> {
  final ChallengeRepository _challengeRepository;
  final IAuthRepository _authRepository;
  final WorkoutRepository _workoutRepository;
  
  ProgressViewModel({
    required ChallengeRepository challengeRepository,
    required IAuthRepository authRepository,
    required WorkoutRepository workoutRepository,
  }) : _challengeRepository = challengeRepository,
       _authRepository = authRepository,
       _workoutRepository = workoutRepository,
       super(const ProgressState());
  
  /// Carrega o progresso do usuário para um desafio específico
  Future<void> getUserProgress(String challengeId) async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Verificar se o usuário está autenticado
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw const AppException(
          message: 'Usuário não autenticado',
          code: 'auth_required',
        );
      }
      
      // Buscar o progresso do usuário para o desafio
      final progress = await _challengeRepository.getUserProgress(
        userId: currentUser.id,
        challengeId: challengeId,
      );
      
      // Atualizar o estado com o progresso obtido
      state = state.copyWith(
        isLoading: false,
        userProgress: progress,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e : AppException(
          message: 'Erro ao carregar progresso: ${e.toString()}',
          code: 'progress_load_error',
        ),
      );
    }
  }
  
  /// Carrega os treinos do usuário para uma data específica
  Future<void> getWorkoutsForDate(DateTime date) async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Atualizar a data selecionada no estado
      state = state.copyWith(selectedDate: date);
      
      // Verificar se o usuário está autenticado
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw const AppException(
          message: 'Usuário não autenticado',
          code: 'auth_required',
        );
      }
      
      // Buscar os treinos do usuário para a data
      final workouts = await _workoutRepository.getUserWorkoutsForDate(
        userId: currentUser.id,
        date: date,
      );
      
      // Atualizar o estado com os treinos obtidos
      state = state.copyWith(
        isLoading: false,
        workoutsForDate: workouts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e : AppException(
          message: 'Erro ao carregar treinos: ${e.toString()}',
          code: 'workouts_load_error',
        ),
      );
    }
  }
  
  /// Altera a data selecionada e carrega os dados correspondentes
  Future<void> changeSelectedDate(DateTime date) async {
    // Atualiza a data no estado primeiro para refletir imediatamente na UI
    state = state.copyWith(selectedDate: date);
    
    // Busca os dados para a nova data
    await getWorkoutsForDate(date);
  }
} 