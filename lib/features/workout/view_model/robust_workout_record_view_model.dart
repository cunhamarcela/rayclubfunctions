import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';

import '../repositories/workout_record_repository.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/challenges/repositories/challenge_repository.dart';
import '../../../features/dashboard/repositories/dashboard_repository.dart';
import '../../../shared/utils/logger.dart';
import '../models/workout_record.dart';

// ================================================================
// ESTADOS E MODELS ROBUSTOS
// ================================================================

@immutable
class RobustWorkoutRecordState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final String? workoutId;
  final DateTime? lastSubmissionTime;
  final Map<String, DateTime> submissionHistory;
  final Map<String, String> validationErrors;
  final int consecutiveErrors;
  final bool isRateLimited;

  const RobustWorkoutRecordState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.workoutId,
    this.lastSubmissionTime,
    this.submissionHistory = const {},
    this.validationErrors = const {},
    this.consecutiveErrors = 0,
    this.isRateLimited = false,
  });

  RobustWorkoutRecordState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    String? workoutId,
    DateTime? lastSubmissionTime,
    Map<String, DateTime>? submissionHistory,
    Map<String, String>? validationErrors,
    int? consecutiveErrors,
    bool? isRateLimited,
  }) {
    return RobustWorkoutRecordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      workoutId: workoutId ?? this.workoutId,
      lastSubmissionTime: lastSubmissionTime ?? this.lastSubmissionTime,
      submissionHistory: submissionHistory ?? this.submissionHistory,
      validationErrors: validationErrors ?? this.validationErrors,
      consecutiveErrors: consecutiveErrors ?? this.consecutiveErrors,
      isRateLimited: isRateLimited ?? this.isRateLimited,
    );
  }
}

class RobustWorkoutParams {
  final String workoutName;
  final String workoutType;
  final int durationMinutes;
  final DateTime date;
  final String? challengeId;
  final String? workoutId;
  final String? notes;

  const RobustWorkoutParams({
    required this.workoutName,
    required this.workoutType,
    required this.durationMinutes,
    required this.date,
    this.challengeId,
    this.workoutId,
    this.notes,
  });

  // Gerar fingerprint único para detecção de duplicatas
  String get fingerprint => '${workoutName}_${workoutType}_${durationMinutes}_${_dateKey}_${challengeId ?? "no_challenge"}';
  
  String get _dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'workout_name': workoutName,
    'workout_type': workoutType,
    'duration_minutes': durationMinutes,
    'date': date.toIso8601String(),
    'challenge_id': challengeId,
    'workout_id': workoutId,
    'notes': notes,
  };
}

// ================================================================
// VIEWMODEL ROBUSTO COM PROTEÇÕES MULTICAMADAS
// ================================================================

class RobustWorkoutRecordViewModel extends StateNotifier<RobustWorkoutRecordState> {
  final WorkoutRecordRepository _workoutRecordRepository;
  final AuthRepository _authRepository;
  final ChallengeRepository _challengeRepository;
  final DashboardRepository _dashboardRepository;
  final LoggerService _logger = LoggerService();

  // Controles de concorrência e rate limiting
  final Map<String, Completer<void>> _ongoingSubmissions = {};
  final Map<String, Timer> _cooldownTimers = {};
  
  // Controles de monitoramento
  Timer? _errorResetTimer;
  static const int _maxConsecutiveErrors = 3;
  static const int _rateLimitDurationSeconds = 30;
  static const int _duplicateCheckWindowMinutes = 5;

  // Streams para comunicação com UI
  final StreamController<bool> _workoutCompletedController = StreamController<bool>.broadcast();
  final StreamController<String> _workoutErrorController = StreamController<String>.broadcast();
  final StreamController<Map<String, String>> _validationErrorController = StreamController<Map<String, String>>.broadcast();

  Stream<bool> get workoutCompleted => _workoutCompletedController.stream;
  Stream<String> get workoutError => _workoutErrorController.stream;
  Stream<Map<String, String>> get validationErrors => _validationErrorController.stream;

  RobustWorkoutRecordViewModel({
    required WorkoutRecordRepository workoutRecordRepository,
    required AuthRepository authRepository,
    required ChallengeRepository challengeRepository,
    required DashboardRepository dashboardRepository,
  })  : _workoutRecordRepository = workoutRecordRepository,
        _authRepository = authRepository,
        _challengeRepository = challengeRepository,
        _dashboardRepository = dashboardRepository,
        super(const RobustWorkoutRecordState()) {
    _initializeErrorResetTimer();
  }

  @override
  void dispose() {
    _workoutCompletedController.close();
    _workoutErrorController.close();
    _validationErrorController.close();
    _errorResetTimer?.cancel();
    _cooldownTimers.values.forEach((timer) => timer.cancel());
    super.dispose();
  }

  // ================================================================
  // CAMADA 1: PROTEÇÕES NO FLUTTER (CLIENT-SIDE)
  // ================================================================

  Future<void> recordWorkout(RobustWorkoutParams params) async {
    final now = DateTime.now();
    
    // PROTEÇÃO 1.1: Verificar rate limiting
    if (state.isRateLimited) {
      _logger.w('Tentativa de submissão durante rate limit');
      _workoutErrorController.add('Aguarde ${_rateLimitDurationSeconds}s antes de tentar novamente');
      return;
    }

    // PROTEÇÃO 1.2: Verificar submissões simultâneas
    final submissionKey = params.fingerprint;
    if (_ongoingSubmissions.containsKey(submissionKey)) {
      _logger.w('Tentativa de submissão duplicada simultânea: $submissionKey');
      return _ongoingSubmissions[submissionKey]!.future;
    }

    // PROTEÇÃO 1.3: Verificar se já está processando
    if (state.isSubmitting) {
      _logger.w('Tentativa de submissão enquanto outra está em progresso');
      return;
    }

    // PROTEÇÃO 1.4: Verificar histórico de submissões recentes
    final lastSubmission = state.submissionHistory[submissionKey];
    if (lastSubmission != null && now.difference(lastSubmission).inSeconds < _rateLimitDurationSeconds) {
      _logger.w('Rate limiting: submissão muito recente para $submissionKey');
      _activateRateLimit();
      _workoutErrorController.add('Aguarde ${_rateLimitDurationSeconds}s antes de registrar treino similar');
      return;
    }

    // PROTEÇÃO 1.5: Verificar limite de erros consecutivos
    if (state.consecutiveErrors >= _maxConsecutiveErrors) {
      _logger.w('Muitos erros consecutivos, ativando cooldown');
      _activateRateLimit();
      _workoutErrorController.add('Muitos erros detectados. Aguarde alguns minutos antes de tentar novamente.');
      return;
    }

    // PROTEÇÃO 1.6: Validações rigorosas dos dados
    final validationErrors = await _validateWorkoutParams(params);
    if (validationErrors.isNotEmpty) {
      state = state.copyWith(validationErrors: validationErrors);
      _validationErrorController.add(validationErrors);
      return;
    }

    // Criar controle de submissão
    final completer = Completer<void>();
    _ongoingSubmissions[submissionKey] = completer;

    // Atualizar estado para enviando
    state = state.copyWith(
      isSubmitting: true,
      error: null,
      validationErrors: {},
      lastSubmissionTime: now,
    );

    try {
      await _performRobustWorkoutRegistration(params);
      
      // Sucesso: atualizar histórico e resetar contador de erros
      final updatedHistory = Map<String, DateTime>.from(state.submissionHistory);
      updatedHistory[submissionKey] = now;
      
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        submissionHistory: updatedHistory,
        consecutiveErrors: 0,
      );

      _workoutCompletedController.add(true);
      _logger.i('Treino registrado com sucesso: ${params.workoutName}');

    } catch (e, stack) {
      _handleWorkoutError(e, stack, params);
    } finally {
      _ongoingSubmissions.remove(submissionKey);
      completer.complete();
    }
  }

  // ================================================================
  // CAMADA 2: VALIDAÇÕES PRE-SUBMIT
  // ================================================================

  Future<Map<String, String>> _validateWorkoutParams(RobustWorkoutParams params) async {
    final errors = <String, String>{};

    // Validação 2.1: Dados básicos
    if (params.workoutName.trim().isEmpty) {
      errors['workoutName'] = 'Nome do treino é obrigatório';
    }
    if (params.workoutType.trim().isEmpty) {
      errors['workoutType'] = 'Tipo do treino é obrigatório';
    }
    if (params.durationMinutes <= 0 || params.durationMinutes > 720) { // Máximo 12h
      errors['duration'] = 'Duração deve estar entre 1 e 720 minutos';
    }

    // Validação 2.2: Data válida
    final now = DateTime.now();
    final maxPastDate = now.subtract(const Duration(days: 30)); // Máximo 30 dias no passado
    final maxFutureDate = now.add(const Duration(days: 1)); // Máximo 1 dia no futuro
    
    if (params.date.isBefore(maxPastDate)) {
      errors['date'] = 'Não é possível registrar treinos com mais de 30 dias';
    }
    if (params.date.isAfter(maxFutureDate)) {
      errors['date'] = 'Não é possível registrar treinos no futuro';
    }

    // Validação 2.3: Usuário autenticado
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      errors['auth'] = 'Usuário não autenticado';
      return errors;
    }

    // Validação 2.4: Challenge ativo (se fornecido)
    if (params.challengeId != null && params.challengeId!.isNotEmpty) {
      try {
        final challenge = await _challengeRepository.getChallengeById(params.challengeId!);
        if (challenge == null) {
          errors['challenge'] = 'Desafio não encontrado';
        } else if (!challenge.isActive) {
          errors['challenge'] = 'Desafio não está ativo';
        }
      } catch (e) {
        errors['challenge'] = 'Erro ao validar desafio';
        _logger.e('Erro ao validar challenge', e);
      }
    }

    return errors;
  }

  // ================================================================
  // CAMADA 3: PROCESSAMENTO ROBUSTO COM RETRY
  // ================================================================

  Future<void> _performRobustWorkoutRegistration(RobustWorkoutParams params) async {
    const maxRetries = 3;
    const retryDelays = [
      Duration(milliseconds: 500),
      Duration(seconds: 1),
      Duration(seconds: 2),
    ];

    Exception? lastException;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await _registerWorkoutWithProtections(params);
        return; // Sucesso, sair do loop
      } catch (e) {
        lastException = e as Exception;
        _logger.w('Tentativa ${attempt + 1} falhou: $e');
        
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelays[attempt]);
        }
      }
    }

    // Se chegou aqui, todas as tentativas falharam
    throw lastException!;
  }

  Future<void> _registerWorkoutWithProtections(RobustWorkoutParams params) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    // Usar a função SQL robusta com proteções implementadas
    final result = await _workoutRecordRepository.saveWorkoutRecord(
      userId: currentUser.id,
      challengeId: params.challengeId ?? '',
      workoutName: params.workoutName,
      workoutType: params.workoutType,
      durationMinutes: params.durationMinutes,
      date: params.date,
      notes: params.notes,
      workoutId: params.workoutId,
    );

    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Erro desconhecido ao registrar treino');
    }

    // Atualizar dashboard se necessário
    if (params.challengeId != null && params.challengeId!.isNotEmpty) {
      try {
        await _dashboardRepository.forceRefresh();
      } catch (e) {
        _logger.w('Erro ao atualizar dashboard após registro: $e');
        // Não falhar a operação por causa disso
      }
    }
  }

  // ================================================================
  // TRATAMENTO DE ERROS E RECUPERAÇÃO
  // ================================================================

  void _handleWorkoutError(dynamic error, StackTrace stack, RobustWorkoutParams params) {
    _logger.e('Erro ao registrar treino', error, stack);
    
    final errorMessage = _getHumanReadableError(error.toString());
    final newErrorCount = state.consecutiveErrors + 1;
    
    state = state.copyWith(
      isSubmitting: false,
      isSuccess: false,
      error: errorMessage,
      consecutiveErrors: newErrorCount,
    );

    // Ativar rate limit se muitos erros
    if (newErrorCount >= _maxConsecutiveErrors) {
      _activateRateLimit();
    }

    _workoutErrorController.add(errorMessage);
    
    // Log estruturado para monitoramento
    _logStructuredError(error, params);
  }

  String _getHumanReadableError(String error) {
    if (error.contains('Check-in já realizado')) {
      return 'Você já registrou um treino para este desafio hoje';
    }
    if (error.contains('Treino duplicado')) {
      return 'Este treino já foi registrado recentemente';
    }
    if (error.contains('Rate limiting') || error.contains('muito recente')) {
      return 'Aguarde alguns segundos antes de tentar novamente';
    }
    if (error.contains('network') || error.contains('connection')) {
      return 'Problema de conexão. Verifique sua internet e tente novamente';
    }
    if (error.contains('auth')) {
      return 'Problema de autenticação. Faça login novamente';
    }
    
    return 'Erro ao registrar treino. Tente novamente em alguns segundos';
  }

  void _logStructuredError(dynamic error, RobustWorkoutParams params) {
    final errorData = {
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': _authRepository.currentUser?.id,
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      'workout_params': params.toJson(),
      'consecutive_errors': state.consecutiveErrors,
      'submission_history_size': state.submissionHistory.length,
    };
    
    _logger.e('STRUCTURED_ERROR: ${jsonEncode(errorData)}');
  }

  // ================================================================
  // CONTROLES DE RATE LIMITING E COOLDOWN
  // ================================================================

  void _activateRateLimit() {
    state = state.copyWith(isRateLimited: true);
    
    _cooldownTimers['rate_limit']?.cancel();
    _cooldownTimers['rate_limit'] = Timer(
      Duration(seconds: _rateLimitDurationSeconds),
      () {
        state = state.copyWith(isRateLimited: false);
      },
    );
  }

  void _initializeErrorResetTimer() {
    _errorResetTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) {
        if (state.consecutiveErrors > 0) {
          state = state.copyWith(consecutiveErrors: 0);
          _logger.i('Reset contador de erros consecutivos');
        }
      },
    );
  }

  // ================================================================
  // MÉTODOS PÚBLICOS PARA CONTROLE MANUAL
  // ================================================================

  void clearErrors() {
    state = state.copyWith(
      error: null,
      validationErrors: {},
      consecutiveErrors: 0,
      isRateLimited: false,
    );
  }

  void resetSubmissionHistory() {
    state = state.copyWith(submissionHistory: {});
    _logger.i('Histórico de submissões resetado');
  }

  // Método para diagnóstico
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'state': {
        'isSubmitting': state.isSubmitting,
        'consecutiveErrors': state.consecutiveErrors,
        'isRateLimited': state.isRateLimited,
        'submissionHistorySize': state.submissionHistory.length,
      },
      'controls': {
        'ongoingSubmissions': _ongoingSubmissions.length,
        'cooldownTimers': _cooldownTimers.length,
      },
      'lastError': state.error,
    };
  }
}

// ================================================================
// PROVIDER ROBUSTO
// ================================================================

final robustWorkoutRecordViewModelProvider = StateNotifierProvider<RobustWorkoutRecordViewModel, RobustWorkoutRecordState>((ref) {
  final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  
  return RobustWorkoutRecordViewModel(
    workoutRecordRepository: workoutRecordRepository,
    authRepository: authRepository,
    challengeRepository: challengeRepository,
    dashboardRepository: dashboardRepository,
  );
}); 