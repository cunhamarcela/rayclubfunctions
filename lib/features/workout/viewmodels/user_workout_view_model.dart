import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async'; // Added for Completer
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../repositories/workout_repository.dart';
import '../providers/workout_providers.dart';
import '../models/user_workout.dart';
import '../../../services/workout_challenge_service.dart';

/// Provider para o UserWorkoutViewModel
final userWorkoutViewModelProvider = StateNotifierProvider<UserWorkoutViewModel, UserWorkoutState>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeService = ref.watch(workoutChallengeServiceProvider);
  return UserWorkoutViewModel(
    repository: repository, 
    authRepository: authRepository,
    challengeService: challengeService,
  );
});

/// ViewModel para gerenciar treinos do usuário
class UserWorkoutViewModel extends StateNotifier<UserWorkoutState> {
  final WorkoutRepository _repository;
  final IAuthRepository _authRepository;
  final WorkoutChallengeService _challengeService;

  UserWorkoutViewModel({
    required WorkoutRepository repository,
    required IAuthRepository authRepository,
    required WorkoutChallengeService challengeService,
  })  : _repository = repository,
        _authRepository = authRepository,
        _challengeService = challengeService,
        super(UserWorkoutState.initial());

  /// Inicia um treino para o usuário
  Future<void> startWorkout(String workoutId) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.startWorkout(workoutId, userId);
      
      state = UserWorkoutState.success(message: 'Treino iniciado com sucesso!');
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Completa um treino e registra pontos para desafios
  Future<void> completeWorkout(WorkoutRecord record) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Log para diagnóstico
      debugPrint('🔍 Registro de treino criado: $record');
      
      // Salvar o registro do treino
      final savedRecord = await _repository.saveWorkoutRecord(record);
      debugPrint('✅ Registro de treino salvo com sucesso: $savedRecord');
      
      // Processar o treino para os desafios ativos (verificar check-ins, etc.)
      debugPrint('🏋️ Processando treino concluído: ${record.workoutName}');
      int challengePoints = 0;
      
      try {
        // Usar o serviço dedicado para processar os pontos do desafio
        challengePoints = await _challengeService.processWorkoutCompletion(
          savedRecord,
        );
        
        // Refreshing workout history list
        await loadUserWorkoutHistory();
        
        debugPrint('✅ Desafios processados: ganhou $challengePoints pontos');
        
        // Define success message based on points earned
        String successMessage = 'Treino registrado com sucesso!';
        if (challengePoints > 0) {
          successMessage += ' Você ganhou $challengePoints pontos nos desafios ativos!';
        }
        
        state = state.copyWith(
          isLoading: false,
          successMessage: successMessage,
          errorMessage: null,
        );
      } catch (e) {
        // Se houver erro apenas nos desafios, ainda consideramos o treino como salvo
        // mas informamos o erro específico
        debugPrint('❌ Erro ao processar desafios: $e');
        
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Treino registrado com sucesso, mas houve um problema ao processar os pontos do desafio.',
          errorMessage: null,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao completar treino: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar treino: ${e.toString()}',
      );
    }
  }

  /// Atualiza o progresso de treino do usuário
  Future<void> updateWorkoutProgress(String workoutId, double progress) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.updateWorkoutProgress(workoutId, userId, progress);
      
      state = UserWorkoutState.success(message: 'Progresso atualizado!');
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega o histórico de treinos do usuário
  Future<void> loadUserWorkoutHistory() async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      final workouts = await _repository.getUserWorkoutHistory(userId);
      
      state = UserWorkoutState.success(
        message: 'Histórico carregado com sucesso!',
        workouts: workouts,
      );
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Extrai mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}

/// Estado para gerenciamento do UserWorkout
class UserWorkoutState {
  final List<UserWorkout> workouts;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const UserWorkoutState({
    this.workouts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Estado inicial
  factory UserWorkoutState.initial() => const UserWorkoutState();

  /// Estado de carregamento
  factory UserWorkoutState.loading() => const UserWorkoutState(isLoading: true);

  /// Estado de sucesso
  factory UserWorkoutState.success({
    List<UserWorkout> workouts = const [],
    String? message,
  }) => UserWorkoutState(
    workouts: workouts,
    successMessage: message,
  );

  /// Estado de erro
  factory UserWorkoutState.error({
    required String message,
  }) => UserWorkoutState(
    errorMessage: message,
  );

  UserWorkoutState copyWith({
    List<UserWorkout>? workouts,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return UserWorkoutState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
} 