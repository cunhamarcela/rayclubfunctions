import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/features/challenge/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/models/workout_record_state.dart';
import 'package:ray_club_app/core/connectivity/connectivity_service.dart';
import 'package:ray_club_app/features/storage/local_storage_service.dart';
import 'package:ray_club_app/features/workout/models/pending_workout.dart';

/// Provider para WorkoutRecordViewModel com parâmetros de criação personalizados
final workoutRecordViewModelProvider = StateNotifierProvider<WorkoutRecordViewModel, WorkoutRecordState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  
  return WorkoutRecordViewModel(
    authRepository,
    workoutRecordRepository,
    challengeRepository,
    dashboardRepository,
    connectivityService,
    localStorageService,
  );
});

/// Parâmetros para registro de treino
class WorkoutParams {
  final String workoutName;
  final String workoutType;
  final int durationMinutes;
  final DateTime date;
  final String? challengeId;
  final String? workoutId;
  
  WorkoutParams({
    required this.workoutName,
    required this.workoutType,
    required this.durationMinutes,
    required this.date,
    this.challengeId,
    this.workoutId,
  });
  
  Map<String, dynamic> toJson() => {
    'workout_name': workoutName,
    'workout_type': workoutType,
    'duration_minutes': durationMinutes,
    'date': date.toIso8601String(),
    'challenge_id': challengeId,
    'workout_id': workoutId,
  };
}

/// ViewModel para registro de treinos com prevenção de duplicação
class WorkoutRecordViewModel extends StateNotifier<WorkoutRecordState> {
  final _logger = Logger();
  final AuthRepository _authRepository;
  final WorkoutRecordRepository _workoutRecordRepository;
  final ChallengeRepository _challengeRepository;
  final DashboardRepository _dashboardRepository;
  final ConnectivityService _connectivityService;
  final LocalStorageService _localStorageService;
  
  // Controllers para eventos de treino
  final _workoutCompletedController = StreamController<bool>.broadcast();
  final _workoutErrorController = StreamController<String>.broadcast();

  // Streams públicos para notificar a UI
  Stream<bool> get workoutCompletedStream => _workoutCompletedController.stream;
  Stream<String> get workoutErrorStream => _workoutErrorController.stream;

  WorkoutRecordViewModel(
    this._authRepository,
    this._workoutRecordRepository,
    this._challengeRepository,
    this._dashboardRepository,
    this._connectivityService,
    this._localStorageService,
  ) : super(WorkoutRecordState.initial());
  
  /// Registra um treino com prevenção de duplicação
  Future<void> recordWorkout(WorkoutParams params) async {
    // Verificar se já está enviando (previne envios duplicados)
    if (state.isSubmitting) {
      _logger.w('Tentativa de envio duplicado ignorada');
      return;
    }
    
    // Atualizar estado para enviando (desabilita botão)
    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      _logger.i('Processando conclusão do treino: ${params.workoutName}');
      
      // Gerar UUID para workout_id se for null (caso de treino manual)
      final String effectiveWorkoutId = params.workoutId ?? const Uuid().v4();
      _logger.d('WorkoutID: $effectiveWorkoutId (${params.workoutId == null ? "gerado" : "original"})');
      
      // Registrar treino no histórico local
      final workoutRecord = WorkoutRecord(
        id: const Uuid().v4(),
        userId: _authRepository.currentUser?.id ?? '',
        workoutId: effectiveWorkoutId, // Usar o ID efetivo (original ou gerado)
        workoutName: params.workoutName,
        workoutType: params.workoutType,
        date: params.date,
        durationMinutes: params.durationMinutes,
        createdAt: DateTime.now(),
        challengeId: params.challengeId, // Incluir o challengeId no registro do treino
      );
      
      // Persistir localmente
      final savedRecord = await _workoutRecordRepository.createWorkoutRecord(workoutRecord);
      
      // Se tiver challengeId, registrar check-in no desafio
      if (params.challengeId != null && params.challengeId!.isNotEmpty) {
        _logger.i('Registrando check-in para desafio: ${params.challengeId}');
        
        // Usar o ID efetivo no check-in do desafio
        await _challengeRepository.recordChallengeCheckIn(
          challengeId: params.challengeId!,
          workoutId: effectiveWorkoutId,
          workoutName: params.workoutName,
          workoutType: params.workoutType,
          durationMinutes: params.durationMinutes,
          date: params.date,
        );
        
        // Atualizar dashboard para mostrar pontos atualizados
        await _dashboardRepository.forceRefresh();
      }
      
      // Notificar observadores da conclusão
      _workoutCompletedController.add(true);
      
      // Atualizar estado com sucesso
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        workoutId: savedRecord.id,
      );
    } catch (e, stack) {
      _logger.e('Erro ao processar conclusão do treino', e, stack);
      _workoutErrorController.add('Erro ao registrar treino: ${e.toString()}');
      
      // Atualizar estado com erro
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }
  
  /// Registra um treino com suporte a modo offline
  Future<void> recordWorkoutWithOfflineSupport(WorkoutParams params) async {
    // Verificar se já está enviando
    if (state.isSubmitting) {
      _logger.w('Tentativa de envio duplicado ignorada');
      return;
    }
    
    // Atualizar estado para enviando
    state = state.copyWith(isSubmitting: true, error: null);
    
    // Verificar conectividade
    final hasConnection = await _connectivityService.hasInternetConnection();
    
    if (!hasConnection) {
      _logger.i('Sem conexão, salvando localmente: ${params.workoutName}');
      
      // Salvar localmente
      final pendingId = const Uuid().v4();
      await _localStorageService.savePendingWorkout(
        PendingWorkout(
          id: pendingId,
          data: params.toJson(),
          createdAt: DateTime.now(),
        ).toJson(),
      );
      
      // Notificar usuário
      state = state.copyWith(
        isSubmitting: false,
        isOfflineSaved: true,
        pendingWorkoutId: pendingId,
      );
      
      return;
    }
    
    // Continuar com envio online
    await recordWorkout(params);
  }
  
  /// Processa treinos pendentes salvos em modo offline
  Future<void> processPendingWorkouts() async {
    _logger.i('Verificando treinos pendentes para processamento');
    
    // Obter treinos pendentes
    final pendingWorkouts = await _localStorageService.getPendingWorkouts();
    
    if (pendingWorkouts.isEmpty) {
      _logger.i('Nenhum treino pendente encontrado');
      return;
    }
    
    _logger.i('Encontrados ${pendingWorkouts.length} treinos pendentes');
    
    // Verificar conectividade
    final hasConnection = await _connectivityService.hasInternetConnection();
    
    if (!hasConnection) {
      _logger.w('Sem conexão, não é possível processar treinos pendentes');
      return;
    }
    
    for (final pendingWorkout in pendingWorkouts) {
      try {
        // Converter de volta para objetos
        final pendingData = PendingWorkout.fromJson(pendingWorkout);
        
        _logger.i('Processando treino pendente: ${pendingData.id}');
        
        // Criar parâmetros a partir dos dados salvos
        final params = WorkoutParams(
          workoutName: pendingData.data['workout_name'],
          workoutType: pendingData.data['workout_type'],
          durationMinutes: pendingData.data['duration_minutes'],
          date: DateTime.parse(pendingData.data['date']),
          challengeId: pendingData.data['challenge_id'],
          workoutId: pendingData.data['workout_id'],
        );
        
        // Registrar treino (fora do estado do notifier para não afetar a UI atual)
        await recordWorkout(params);
        
        // Remover treino processado da lista de pendentes
        await _localStorageService.removePendingWorkout(pendingData.id);
        
        _logger.i('Treino pendente processado com sucesso: ${pendingData.id}');
      } catch (e) {
        _logger.e('Erro ao processar treino pendente', e);
        // Continuar para o próximo treino
      }
    }
  }
  
  @override
  void dispose() {
    _workoutCompletedController.close();
    _workoutErrorController.close();
    super.dispose();
  }
} 