import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import '../repositories/workout_record_repository.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/challenges/repositories/challenge_repository.dart';
import '../../../features/dashboard/repositories/dashboard_repository.dart';
import '../../../shared/utils/logger.dart';
import '../models/workout_record.dart';

// ================================================================
// ESTADOS MELHORADOS PARA TRATAMENTO DE CONCORRÊNCIA
// ================================================================

@immutable
class WorkoutRecordState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final String? workoutId;
  final DateTime? lastSubmissionTime;
  final Map<String, DateTime> submissionHistory; // Histórico para evitar duplicatas

  const WorkoutRecordState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.workoutId,
    this.lastSubmissionTime,
    this.submissionHistory = const {},
  });

  WorkoutRecordState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    String? workoutId,
    DateTime? lastSubmissionTime,
    Map<String, DateTime>? submissionHistory,
  }) {
    return WorkoutRecordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      workoutId: workoutId ?? this.workoutId,
      lastSubmissionTime: lastSubmissionTime ?? this.lastSubmissionTime,
      submissionHistory: submissionHistory ?? this.submissionHistory,
    );
  }
}

class WorkoutParams {
  final String workoutName;
  final String workoutType;
  final int durationMinutes;
  final DateTime date;
  final String? challengeId;
  final String? workoutId;

  const WorkoutParams({
    required this.workoutName,
    required this.workoutType,
    required this.durationMinutes,
    required this.date,
    this.challengeId,
    this.workoutId,
  });

  // Gerar chave única para evitar duplicatas
  String get uniqueKey => '${workoutName}_${workoutType}_${date.millisecondsSinceEpoch ~/ 60000}'; // Granularidade de 1 minuto
}

// ================================================================
// VIEWMODEL MELHORADO COM PROTEÇÕES CONTRA DUPLICATAS
// ================================================================

class ImprovedWorkoutRecordViewModel extends StateNotifier<WorkoutRecordState> {
  final WorkoutRecordRepository _workoutRecordRepository;
  final AuthRepository _authRepository;
  final ChallengeRepository _challengeRepository;
  final DashboardRepository _dashboardRepository;
  final LoggerService _logger = LoggerService();

  // Controles para evitar execuções simultâneas
  final Map<String, Completer<void>> _ongoingSubmissions = {};
  
  // Streams para notificações
  final StreamController<bool> _workoutCompletedController = StreamController<bool>.broadcast();
  final StreamController<String> _workoutErrorController = StreamController<String>.broadcast();

  Stream<bool> get workoutCompleted => _workoutCompletedController.stream;
  Stream<String> get workoutError => _workoutErrorController.stream;

  ImprovedWorkoutRecordViewModel({
    required WorkoutRecordRepository workoutRecordRepository,
    required AuthRepository authRepository,
    required ChallengeRepository challengeRepository,
    required DashboardRepository dashboardRepository,
  })  : _workoutRecordRepository = workoutRecordRepository,
        _authRepository = authRepository,
        _challengeRepository = challengeRepository,
        _dashboardRepository = dashboardRepository,
        super(const WorkoutRecordState());

  @override
  void dispose() {
    _workoutCompletedController.close();
    _workoutErrorController.close();
    super.dispose();
  }

  // ================================================================
  // MÉTODO PRINCIPAL COM PROTEÇÕES CONTRA DUPLICATAS
  // ================================================================

  Future<void> recordWorkout(WorkoutParams params) async {
    final submissionKey = params.uniqueKey;
    
    // PROTEÇÃO 1: Verificar se já está processando esta submissão específica
    if (_ongoingSubmissions.containsKey(submissionKey)) {
      _logger.w('Tentativa de submissão duplicada detectada para: $submissionKey');
      return _ongoingSubmissions[submissionKey]!.future;
    }

    // PROTEÇÃO 2: Verificar se já está enviando qualquer coisa
    if (state.isSubmitting) {
      _logger.w('Tentativa de envio enquanto outro ainda está em progresso');
      return;
    }

    // PROTEÇÃO 3: Rate limiting - verificar se foi enviado recentemente
    final now = DateTime.now();
    final lastSubmission = state.submissionHistory[submissionKey];
    if (lastSubmission != null && now.difference(lastSubmission).inSeconds < 30) {
      _logger.w('Rate limiting: submissão muito recente para $submissionKey');
      _workoutErrorController.add('Aguarde 30 segundos antes de registrar outro treino igual');
      return;
    }

    // Criar completer para controlar esta submissão
    final completer = Completer<void>();
    _ongoingSubmissions[submissionKey] = completer;

    // Atualizar estado para enviando
    state = state.copyWith(
      isSubmitting: true, 
      error: null,
      lastSubmissionTime: now,
    );

    try {
      _logger.i('Iniciando registro de treino: ${params.workoutName}');
      
      await _performWorkoutRegistration(params);
      
      // Atualizar histórico de submissões
      final updatedHistory = Map<String, DateTime>.from(state.submissionHistory);
      updatedHistory[submissionKey] = now;
      
      // Atualizar estado com sucesso
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        submissionHistory: updatedHistory,
      );

      _workoutCompletedController.add(true);

    } catch (e, stack) {
      _logger.e('Erro ao processar registro do treino', e, stack);
      
      // Atualizar estado com erro
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        error: _getHumanReadableError(e.toString()),
      );

      _workoutErrorController.add(_getHumanReadableError(e.toString()));
    } finally {
      // Limpar controle de submissão
      _ongoingSubmissions.remove(submissionKey);
      completer.complete();
    }
  }

  // ================================================================
  // LÓGICA DE REGISTRO COM VALIDAÇÕES APRIMORADAS
  // ================================================================

  Future<void> _performWorkoutRegistration(WorkoutParams params) async {
    // Validações básicas
    await _validateWorkoutParams(params);

    // Gerar UUID para workout_id se necessário
    final String effectiveWorkoutId = params.workoutId ?? const Uuid().v4();
    _logger.d('WorkoutID: $effectiveWorkoutId (${params.workoutId == null ? "gerado" : "original"})');

    // Registrar treino no histórico local
    final workoutRecord = WorkoutRecord(
      id: const Uuid().v4(),
      userId: _authRepository.currentUser?.id ?? '',
      workoutId: effectiveWorkoutId,
      workoutName: params.workoutName,
      workoutType: params.workoutType,
      date: params.date,
      durationMinutes: params.durationMinutes,
      createdAt: DateTime.now(),
      challengeId: params.challengeId,
    );

    // Persistir localmente primeiro
    final savedRecord = await _workoutRecordRepository.createWorkoutRecord(workoutRecord);
    _logger.i('Treino salvo localmente: ${savedRecord.id}');

    state = state.copyWith(workoutId: savedRecord.id);

    // Se tiver challengeId, registrar check-in no desafio
    if (params.challengeId != null && params.challengeId!.isNotEmpty) {
      await _registerChallengeCheckIn(params, effectiveWorkoutId);
    }
  }

  Future<void> _registerChallengeCheckIn(WorkoutParams params, String effectiveWorkoutId) async {
    _logger.i('Registrando check-in para desafio: ${params.challengeId}');
    
    try {
      final result = await _challengeRepository.recordChallengeCheckIn(
        challengeId: params.challengeId!,
        workoutId: effectiveWorkoutId,
        workoutName: params.workoutName,
        workoutType: params.workoutType,
        durationMinutes: params.durationMinutes,
        date: params.date,
      );

      // Verificar resultado do check-in
      if (result.points == 0 && result.message.toLowerCase().contains('já')) {
        _logger.w('Check-in já existe para hoje: ${result.message}');
        // Não é erro fatal, apenas aviso
      } else if (result.points > 0) {
        _logger.i('Check-in registrado com sucesso: ${result.points} pontos');
      } else {
        throw Exception(result.message);
      }

      // Atualizar dashboard
      await _dashboardRepository.forceRefresh();
      
    } catch (e) {
      _logger.e('Erro ao registrar check-in do desafio: $e');
      // Re-throw para ser tratado pela função principal
      rethrow;
    }
  }

  // ================================================================
  // VALIDAÇÕES E UTILITÁRIOS
  // ================================================================

  Future<void> _validateWorkoutParams(WorkoutParams params) async {
    if (params.workoutName.trim().isEmpty) {
      throw Exception('Nome do treino é obrigatório');
    }

    if (params.durationMinutes <= 0) {
      throw Exception('Duração deve ser maior que zero');
    }

    if (params.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw Exception('Data do treino não pode ser no futuro');
    }

    // Verificar se usuário está autenticado
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não está autenticado');
    }

    // Se tem challengeId, verificar se o desafio existe e está ativo
    if (params.challengeId != null && params.challengeId!.isNotEmpty) {
      try {
        final challenge = await _challengeRepository.getChallengeById(params.challengeId!);
        if (challenge == null) {
          throw Exception('Desafio não encontrado');
        }
        
        if (!challenge.active) {
          throw Exception('Desafio não está mais ativo');
        }
        
        final now = DateTime.now();
        if (now.isBefore(challenge.startDate) || now.isAfter(challenge.endDate)) {
          throw Exception('Desafio fora do período de participação');
        }
      } catch (e) {
        _logger.e('Erro ao validar desafio: $e');
        throw Exception('Erro ao validar desafio: $e');
      }
    }
  }

  String _getHumanReadableError(String error) {
    if (error.toLowerCase().contains('duplicate')) {
      return 'Você já registrou um treino similar hoje';
    } else if (error.toLowerCase().contains('network')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'Operação demorou muito. Tente novamente';
    } else if (error.toLowerCase().contains('authentication')) {
      return 'Erro de autenticação. Faça login novamente';
    } else if (error.toLowerCase().contains('rate')) {
      return 'Muitas tentativas. Aguarde um momento antes de tentar novamente';
    } else {
      return 'Erro inesperado. Tente novamente em alguns instantes';
    }
  }

  // ================================================================
  // MÉTODOS UTILITÁRIOS
  // ================================================================

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const WorkoutRecordState();
  }

  bool canSubmit(WorkoutParams params) {
    if (state.isSubmitting) return false;
    
    final submissionKey = params.uniqueKey;
    final lastSubmission = state.submissionHistory[submissionKey];
    
    if (lastSubmission != null) {
      final timeSinceLastSubmission = DateTime.now().difference(lastSubmission);
      return timeSinceLastSubmission.inSeconds >= 30;
    }
    
    return true;
  }
}

// ================================================================
// PROVIDER MELHORADO
// ================================================================

final improvedWorkoutRecordViewModelProvider = 
    StateNotifierProvider.autoDispose<ImprovedWorkoutRecordViewModel, WorkoutRecordState>((ref) {
  final workoutRepository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);

  return ImprovedWorkoutRecordViewModel(
    workoutRecordRepository: workoutRepository,
    authRepository: authRepository,
    challengeRepository: challengeRepository,
    dashboardRepository: dashboardRepository,
  );
}); 