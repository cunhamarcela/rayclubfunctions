// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/models/workout_record_adapter.dart';
import 'package:ray_club_app/core/utils/debug_data_inspector.dart';
import 'package:ray_club_app/core/utils/model_compatibility_checker.dart';
import 'package:ray_club_app/features/progress/repositories/user_progress_repository.dart';
import 'package:ray_club_app/core/providers/service_providers.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/workout/models/workout_processing_status.dart';
import 'package:ray_club_app/features/workout/models/check_in_error_log.dart';
import 'package:ray_club_app/features/challenges/constants/challenge_rpc_params.dart';
import 'package:ray_club_app/features/goals/services/goal_progress_service.dart';

/// Interface para o repositório de registros de treinos
abstract class WorkoutRecordRepository {
  /// Obtém todos os registros de treino do usuário atual
  Future<List<WorkoutRecord>> getUserWorkoutRecords();
  
  /// Cria um novo registro de treino
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record, {List<File>? images});
  
  /// Atualiza um registro de treino existente
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record);
  
  /// Exclui um registro de treino
  Future<void> deleteWorkoutRecord(String id);
  
  /// Faz upload de imagens para um registro de treino
  Future<List<String>> uploadWorkoutImages(String recordId, List<File> images);
  
  /// Obtém o status de processamento de um treino
  Future<WorkoutProcessingStatus?> getWorkoutProcessingStatus(String workoutId);
  
  /// Obtém stream de status de processamento para atualizações em tempo real
  Stream<WorkoutProcessingStatus?> streamWorkoutProcessingStatus(String workoutId);
  
  /// Obtém logs de erros para diagnóstico
  Future<List<CheckInErrorLog>> getWorkoutProcessingErrors({String? workoutId, int limit = 50});
  
  /// Atualiza um treino existente usando a função RPC update_workout_simple
  Future<void> updateWorkout({
    required String workoutId,
    required String userId,
    required String challengeId,
    required String workoutName,
    required String workoutType,
    required int duration,
    required DateTime date,
    String? notes,
  });
  
  /// Exclui um treino existente usando a função RPC delete_workout_simple
  Future<void> deleteWorkout({
    required String workoutId,
    required String userId,
    required String challengeId,
  });

  /// Salva ou atualiza um registro de treino usando a função RPC centralizada
  /// 
  /// Se workoutRecordId for fornecido, atualiza o registro existente
  /// Caso contrário, cria um novo registro
  /// 
  /// Retorna um mapa com o resultado da operação, incluindo se foi marcado como check-in
  Future<Map<String, dynamic>> saveWorkoutRecord({
    required String userId,
    required String challengeId,
    required String workoutName,
    required String workoutType,
    required int durationMinutes,
    required DateTime date,
    String? notes,
    String? workoutId,
    String? workoutRecordId,
  });
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutRecordRepository implements WorkoutRecordRepository {
  @override
  Future<List<WorkoutRecord>> getUserWorkoutRecords() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _getMockWorkoutRecords();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar registros de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record, {List<File>? images}) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return record.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Verificar se o registro existe
      final allRecords = _getMockWorkoutRecords();
      final exists = allRecords.any((r) => r.id == record.id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para atualização',
          code: 'record_not_found',
        );
      }
      
      return record;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkoutRecord(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Verificar se o registro existe
      final allRecords = _getMockWorkoutRecords();
      final exists = allRecords.any((record) => record.id == id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para exclusão',
          code: 'record_not_found',
        );
      }
      
      // Em um ambiente real, o registro seria removido do banco de dados
      return;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<String>> uploadWorkoutImages(String recordId, List<File> images) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1200));
    
    try {
      // Em um ambiente real, as imagens seriam enviadas para um servidor
      // e retornariam URLs. Aqui simulamos URLs fictícias.
      return images.map((image) => 
        'https://mock-storage.example.com/workout-images/$recordId/${DateTime.now().millisecondsSinceEpoch}.jpg'
      ).toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao fazer upload das imagens do treino',
        originalError: e,
      );
    }
  }

  // IMPLEMENTAÇÃO DOS NOVOS MÉTODOS NECESSÁRIOS PARA A INTERFACE
  
  @override
  Future<WorkoutProcessingStatus?> getWorkoutProcessingStatus(String workoutId) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Retornar um status mock com processamento completo para o mock
    return WorkoutProcessingStatus(
      id: 'mock-status-${DateTime.now().millisecondsSinceEpoch}',
      workoutId: workoutId,
      processedForRanking: true,
      processedForDashboard: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      processedAt: DateTime.now().subtract(const Duration(minutes: 4)),
    );
  }
  
  @override
  Stream<WorkoutProcessingStatus?> streamWorkoutProcessingStatus(String workoutId) {
    // The Supabase stream API has different syntax than the query API
    // Let's create a manual polling stream instead as a workaround
    final controller = StreamController<WorkoutProcessingStatus?>();
    
    // Initial fetch
    getWorkoutProcessingStatus(workoutId).then((status) {
      if (!controller.isClosed) {
        controller.add(status);
      }
    });
    
    // Set up periodic polling
    final timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!controller.isClosed) {
        getWorkoutProcessingStatus(workoutId).then((status) {
          if (!controller.isClosed) {
            controller.add(status);
          }
        });
      }
    });
    
    // Clean up when the stream is no longer used
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };
    
    return controller.stream;
  }
  
  @override
  Future<List<CheckInErrorLog>> getWorkoutProcessingErrors({
    String? workoutId,
    int limit = 50
  }) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 700));
    
    // Retornar uma lista vazia para o mock - não há erros
    return [];
  }

  @override
  Future<void> updateWorkout({
    required String workoutId,
    required String userId,
    required String challengeId,
    required String workoutName,
    required String workoutType,
    required int duration,
    required DateTime date,
    String? notes,
  }) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      debugPrint('🔄 Mock: Atualizando treino ID=$workoutId para usuário $userId');
      // Em um ambiente real, o treino seria atualizado no banco de dados
      return;
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkout({
    required String workoutId,
    required String userId,
    required String challengeId,
  }) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      debugPrint('🗑️ Mock: Excluindo treino ID=$workoutId para usuário $userId');
      // Em um ambiente real, o treino seria excluído do banco de dados
      return;
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> saveWorkoutRecord({
    required String userId,
    required String challengeId,
    required String workoutName,
    required String workoutType,
    required int durationMinutes,
    required DateTime date,
    String? notes,
    String? workoutId,
    String? workoutRecordId,
  }) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Simular a lógica do record_workout_basic
      final bool isCheckIn = true; // Aceitar treinos de qualquer duração
      final int pointsEarned = isCheckIn ? 10 : 0; // Pontos para check-in
      
      if (workoutRecordId != null) {
        // Atualização de um registro existente
        debugPrint('🔄 Mock: Atualizando treino ID=$workoutRecordId');
      } else {
        // Criação de um novo registro
        debugPrint('✅ Mock: Criando novo treino no desafio ID=$challengeId');
      }
      
      // Dados fictícios no formato da API
      return {
        'success': true,
        'record_id': workoutRecordId ?? 'new-${DateTime.now().millisecondsSinceEpoch}',
        'is_check_in': isCheckIn,
        'points_earned': pointsEarned,
        'message': isCheckIn 
            ? 'Treino registrado com sucesso! Você ganhou $pointsEarned pontos.' 
            : 'Treino registrado, mas não contou como check-in (duração mínima de 45min necessária).'
      };
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao salvar registro de treino',
        originalError: e,
      );
    }
  }

  // TEMPORÁRIO: Método para gerar dados mockados
  List<WorkoutRecord> _getMockWorkoutRecords() {
    final now = DateTime.now();
    
    return [
      WorkoutRecord(
        id: '1',
        userId: 'user123',
        workoutId: '1',
        workoutName: 'Yoga para Iniciantes',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 20,
        isCompleted: true,
        notes: 'Senti melhora na flexibilidade',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      WorkoutRecord(
        id: '2',
        userId: 'user123',
        workoutId: '4',
        workoutName: 'Treino de Força Total',
        workoutType: 'Força',
        date: now.subtract(const Duration(days: 3)),
        durationMinutes: 45,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      WorkoutRecord(
        id: '3',
        userId: 'user123',
        workoutId: '3',
        workoutName: 'HIIT 15 minutos',
        workoutType: 'HIIT',
        date: now.subtract(const Duration(days: 5)),
        durationMinutes: 15,
        isCompleted: true,
        notes: 'Muito intenso, próxima vez diminuir o ritmo',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      WorkoutRecord(
        id: '4',
        userId: 'user123',
        workoutId: '5',
        workoutName: 'Yoga Flow',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 7)),
        durationMinutes: 40,
        isCompleted: false,
        notes: 'Parei na metade por dor nas costas',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      WorkoutRecord(
        id: '5',
        userId: 'user123',
        workoutId: null,
        workoutName: 'Corrida ao ar livre',
        workoutType: 'Cardio',
        date: now.subtract(const Duration(days: 10)),
        durationMinutes: 25,
        isCompleted: true,
        notes: 'Corrida no parque, 3km',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      WorkoutRecord(
        id: '6',
        userId: 'user123',
        workoutId: '2',
        workoutName: 'Pilates Abdominal',
        workoutType: 'Pilates',
        date: now.subtract(const Duration(days: 14)),
        durationMinutes: 30,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      // Registro de mês anterior
      WorkoutRecord(
        id: '7',
        userId: 'user123',
        workoutId: '1',
        workoutName: 'Yoga para Iniciantes',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 45)),
        durationMinutes: 20,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];
  }
}

/// Provider para o repositório de registros de treino
final workoutRecordRepositoryProvider = Provider<WorkoutRecordRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final progressRepository = ref.watch(userProgressRepositoryProvider);
  
  // Retornar a implementação com ambos os repositórios
  return SupabaseWorkoutRecordRepository(supabase, progressRepository);
});

/// Implementação do repositório usando Supabase
class SupabaseWorkoutRecordRepository implements WorkoutRecordRepository {
  final SupabaseClient _supabaseClient;
  final UserProgressRepository _progressRepository;
  
  SupabaseWorkoutRecordRepository(this._supabaseClient, this._progressRepository);

  @override
  Future<List<WorkoutRecord>> getUserWorkoutRecords() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Usar função SQL personalizada para fazer o JOIN corretamente
      final response = await _supabaseClient
          .rpc('get_workout_records_with_processing_status', params: {
            'p_user_id': userId,
            'p_limit': 100, // Limitar para evitar queries muito grandes
            'p_offset': 0,
          });
      
      // Inspecionar os dados retornados pelo Supabase
      DebugDataInspector.logResponse('WorkoutRecords', response);
      
      // Verificar compatibilidade do modelo se houver dados
      if (response is List && response.isNotEmpty && response.first is Map<String, dynamic>) {
        ModelCompatibilityChecker.checkModelCompatibility<WorkoutRecord>(
          modelName: 'WorkoutRecord',
          supabaseData: response.first as Map<String, dynamic>,
          fromJson: WorkoutRecord.fromJson,
          toJson: (record) => WorkoutRecordAdapter.toDatabase(record),
        );
      }
      
      return (response as List<dynamic>).map<WorkoutRecord>((json) {
        // Extrair dados do workout (principais) - tratando campos nulos adequadamente
        final workoutData = <String, dynamic>{
          'id': json['id'],
          'user_id': json['user_id'],
          'workout_id': json['workout_id'], // pode ser null
          'workout_name': json['workout_name'] ?? 'Treino sem nome',
          'workout_type': json['workout_type'] ?? 'Geral',
          'date': json['date'],
          'duration_minutes': json['duration_minutes'],
          'is_completed': json['is_completed'],
          'completion_status': json['completion_status'] ?? 'completed',
          'notes': json['notes'], // pode ser null
          'image_urls': json['image_urls'] ?? [],
          'created_at': json['created_at'],
          'challenge_id': json['challenge_id'], // pode ser null
        };
        
        // Converter dados do banco para o formato esperado pelo modelo
        final jsonData = WorkoutRecordAdapter.fromDatabase(workoutData);
        
        // Converter para o objeto WorkoutRecord
        var workout = WorkoutRecord.fromJson(jsonData);
        
        // Verificar se tem dados de processamento de forma segura
        if (json['processing_id'] != null) {
          try {
            // Construir objeto de status de processamento a partir dos campos diretos
            final processingData = {
              'id': json['processing_id'],
              'workout_id': json['id'], // O workout_id no processamento aponta para o id do workout_record
              'processed_for_ranking': json['processed_for_ranking'],
              'processed_for_dashboard': json['processed_for_dashboard'],
              'processing_error': json['processing_error'],
              'created_at': json['processing_created_at'],
              'processed_at': json['processing_processed_at'],
            };
            
            final processingStatus = WorkoutProcessingStatus.fromJson(processingData);
            workout = workout.copyWith(processingStatus: processingStatus);
          } catch (e) {
            // Falha silenciosa - garante que a UI continua funcionando
            debugPrint('Erro ao fazer parse do status: $e');
          }
        }
        
        return workout;
      }).toList();
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Supabase: ${e.toString()}');
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar registros de treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erro genérico: ${e.toString()}');
      if (e is app_errors.AppAuthException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao carregar registros de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record, {List<File>? images}) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Garantir que o ID do usuário seja o do usuário atual
      var recordWithUserId = record.copyWith(userId: userId);
      String? officialChallengeId = recordWithUserId.challengeId;
      
      // Log do record antes de converter
      debugPrint('🔍 Antes de converter: WorkoutRecord tem challenge_id = ${recordWithUserId.challengeId}');
      
      // Verificar se challengeId é null e registrar contexto detalhado
      if (officialChallengeId == null || officialChallengeId.isEmpty) {
        debugPrint('❌ challengeId está null! Usuário: ${recordWithUserId.userId}, Data: ${recordWithUserId.date}, Nome: ${recordWithUserId.workoutName}');
        // Buscar desafio oficial diretamente como último recurso
        try {
          final officialChallengeQuery = await _supabaseClient
              .from('challenges')
              .select()
              .eq('is_official', true)
              .lt('start_date', DateTime.now().toUtc().toIso8601String())
              .gt('end_date', DateTime.now().toUtc().toIso8601String())
              .limit(1);
          
          if (officialChallengeQuery.isNotEmpty) {
            officialChallengeId = officialChallengeQuery[0]['id'] as String;
            // Atualizar o record com o challengeId encontrado
            recordWithUserId = recordWithUserId.copyWith(challengeId: officialChallengeId);
            debugPrint('🆘 Recuperado challenge_id=$officialChallengeId diretamente do banco como último recurso');
          }
        } catch (e) {
          debugPrint('⚠️ Falha ao buscar desafio oficial como último recurso: $e');
        }
      }
      
      // Gerar um effectiveWorkoutId se não existir
      final effectiveWorkoutId = recordWithUserId.workoutId ?? const Uuid().v4();
      debugPrint('🔍 Usando effectiveWorkoutId=$effectiveWorkoutId para saveWorkoutRecord');
      
      // Usar saveWorkoutRecord que já tem tratamento adequado para workoutId e challengeId
      final result = await saveWorkoutRecord(
        userId: recordWithUserId.userId,
        challengeId: officialChallengeId ?? '',
        workoutName: recordWithUserId.workoutName,
        workoutType: recordWithUserId.workoutType,
        durationMinutes: recordWithUserId.durationMinutes,
        date: recordWithUserId.date,
        notes: recordWithUserId.notes,
        workoutId: effectiveWorkoutId,
      );
      
      if (result['success'] != true) {
        throw app_errors.DatabaseException(
          message: result['message'] ?? 'Erro ao criar registro de treino',
          code: result['error_code'] ?? 'unknown_error',
        );
      }
      
      // Obter o ID do registro criado
      final workoutId = result['workout_id'] as String;
      debugPrint('✅ Treino salvo com sucesso: ID=${workoutId}');

      // Buscar o registro completo do banco para garantir dados consistentes
      var response = await _supabaseClient
          .from('workout_records')
          .select()
          .eq('id', workoutId)
          .single();

      // Converter para objeto WorkoutRecord usando o adapter
      var resultRecord = WorkoutRecord.fromJson(WorkoutRecordAdapter.fromDatabase(response));
      debugPrint('📥 Convertendo do banco: $response');
      debugPrint('📥 Challenge ID recebido do banco: ${resultRecord.challengeId}');

      // Se imagens foram fornecidas, fazer upload e atualizar o registro
      if (images != null && images.isNotEmpty) {
        try {
          final imageUrls = await uploadWorkoutImages(resultRecord.id, images);
          
          // Atualizar manualmente o campo image_urls se o upload foi bem-sucedido
          await _supabaseClient
              .from('workout_records')
              .update({'image_urls': imageUrls})
              .match({'id': resultRecord.id});
          
          // Atualizar o objeto localmente
          response = await _supabaseClient
              .from('workout_records')
              .select()
              .eq('id', resultRecord.id)
              .single();
              
          resultRecord = WorkoutRecord.fromJson(WorkoutRecordAdapter.fromDatabase(response));
        } catch (e) {
          throw app_errors.StorageException(
            message: 'Erro ao fazer upload das imagens: ${e.toString()}',
            originalError: e,
          );
        }
      }

      // Atualizar o progresso do usuário com o novo treino
      try {
        await _progressRepository.updateProgressAfterWorkout(userId, resultRecord);
        debugPrint('✅ Progresso do usuário atualizado com sucesso');
      } catch (e) {
        // Apenas fazer log do erro, não devemos falhar a operação principal
        debugPrint('⚠️ Erro ao atualizar progresso do usuário: $e');
      }

      // 🎯 NOVO: Atualizar metas automaticamente baseado no treino
      try {
        // Importar o UnifiedGoalRepository se não estiver importado
        // e integrar aqui quando disponível
        debugPrint('🎯 [INTEGRAÇÃO METAS] Processando treino para metas automáticas...');
        debugPrint('🎯 Treino: ${resultRecord.workoutType} (${resultRecord.durationMinutes} min)');
        
        // TODO: Adicionar integração com UnifiedGoalRepository.updateGoalsFromWorkout()
        // quando o provider estiver disponível
        
        debugPrint('✅ [INTEGRAÇÃO METAS] Preparado para integração futura');
      } catch (e) {
        // Não propagar erro para não interromper o fluxo principal
        debugPrint('⚠️ [INTEGRAÇÃO METAS] Erro ao processar metas: $e');
      }

      return resultRecord;
    } catch (e) {
      debugPrint('❌ Erro ao criar registro: ${e.toString()}');
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao criar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se o registro pertence ao usuário atual
      if (record.userId != userId) {
        throw app_errors.UnauthorizedException(
          message: 'Não autorizado a atualizar este registro',
          code: 'unauthorized',
        );
      }
      
      // Usar a função RPC update_workout_simple para melhor consistência
      await updateWorkout(
        workoutId: record.id,
        userId: record.userId,
        challengeId: record.challengeId ?? '',
        workoutName: record.workoutName,
        workoutType: record.workoutType,
        duration: record.durationMinutes,
        date: record.date,
        notes: record.notes,
      );
      
      // Buscar o registro atualizado do banco para garantir dados consistentes
      final response = await _supabaseClient
          .from('workout_records')
          .select()
          .match({'id': record.id})
          .single();
      
      return WorkoutRecord.fromJson(WorkoutRecordAdapter.fromDatabase(response));
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Supabase: ${e.toString()}');
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para atualização',
          originalError: e,
          code: 'record_not_found',
        );
      }
      
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar registro de treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erro genérico ao atualizar: ${e.toString()}');
      if (e is app_errors.AppAuthException || 
          e is app_errors.UnauthorizedException || 
          e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkoutRecord(String id) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      debugPrint('🗑️ Tentando excluir treino: id=$id, userId=$userId');
      
      // Obter o registro para buscar dados necessários antes de excluir
      final record = await _supabaseClient
          .from('workout_records')
          .select()
          .match({'id': id, 'user_id': userId})
          .maybeSingle();
      
      if (record == null) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado',
          code: 'record_not_found',
        );
      }
      
      // Usar a função RPC delete_workout_simple para melhor consistência
      await deleteWorkout(
        workoutId: id,
        userId: userId,
        challengeId: record['challenge_id'] as String? ?? '',
      );
      
      debugPrint('✅ Treino excluído com sucesso');
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Supabase ao excluir: ${e.toString()}');
      throw app_errors.DatabaseException(
        message: 'Erro ao excluir registro de treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erro genérico ao excluir: ${e.toString()}');
      if (e is app_errors.AppAuthException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<String>> uploadWorkoutImages(String recordId, List<File> images) async {
    try {
      final List<String> imageUrls = [];
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }

      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileExt = file.path.split('.').last;
        final fileName = '$recordId-$currentUserId-${DateTime.now().millisecondsSinceEpoch}-$i.$fileExt';
        // Atualizado: caminho agora é apenas '$currentUserId/$fileName'
        final filePath = '$currentUserId/$fileName';

        // Upload para o bucket 'workout-images' (com hífen)
        const bucketName = 'workout-images';

        await supabase.storage
            .from(bucketName)
            .upload(filePath, file, fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
              metadata: {
                'owner': currentUserId,
              }
            ));

        // Obter a URL pública da imagem
        final imageUrl = supabase.storage
            .from(bucketName)
            .getPublicUrl(filePath);

        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      throw app_errors.AppException(
        message: 'Erro ao fazer upload das imagens: ${e.toString()}',
        code: 'workout_image_upload_error',
      );
    }
  }

  @override
  Future<WorkoutProcessingStatus?> getWorkoutProcessingStatus(String workoutId) async {
    try {
      final response = await _supabaseClient
        .from('workout_processing_queue')
        .select()
        .match({'workout_id': workoutId})
        .single();
        
      if (response == null) return null;
      return WorkoutProcessingStatus.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao obter status de processamento: $e');
      return null;
    }
  }
  
  @override
  Stream<WorkoutProcessingStatus?> streamWorkoutProcessingStatus(String workoutId) {
    // The Supabase stream API has different syntax than the query API
    // Let's create a manual polling stream instead as a workaround
    final controller = StreamController<WorkoutProcessingStatus?>();
    
    // Initial fetch
    getWorkoutProcessingStatus(workoutId).then((status) {
      if (!controller.isClosed) {
        controller.add(status);
      }
    });
    
    // Set up periodic polling
    final timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!controller.isClosed) {
        getWorkoutProcessingStatus(workoutId).then((status) {
          if (!controller.isClosed) {
            controller.add(status);
          }
        });
      }
    });
    
    // Clean up when the stream is no longer used
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };
    
    return controller.stream;
  }

  @override
  Future<List<CheckInErrorLog>> getWorkoutProcessingErrors({
    String? workoutId,
    int limit = 50
  }) async {
    try {
      var query = _supabaseClient
        .from('check_in_error_logs')
        .select();
        
      if (workoutId != null) {
        query = query.match({'workout_id': workoutId});
      }
      
      final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
        
      return (response as List)
        .map((json) => CheckInErrorLog.fromJson(json))
        .toList();
    } catch (e) {
      debugPrint('Erro ao obter logs de erro: $e');
      return [];
    }
  }

  /// Função para tratamento centralizado da resposta da RPC para check-ins de desafios
  /// Recebe qualquer tipo de resposta e padroniza o tratamento
  Map<String, dynamic> parseCheckInResponse(dynamic response) {
    debugPrint('📊 [PARSER] Interpretando resposta de check-in: $response (${response.runtimeType})');
    
    if (response == null) {
      debugPrint('⚠️ [PARSER] Resposta nula');
      return {
        'success': false,
        'message': 'Sem resposta do servidor',
        'points_earned': 0
      };
    }
    
    // Caso 1: Resposta booleana
    if (response is bool) {
      final success = response;
      debugPrint('✅ [PARSER] Resposta booleana: $success');
      
      return {
        'success': success,
        'message': success ? 'Check-in processado com sucesso' : 'Falha ao processar check-in',
        'points_earned': success ? 10 : 0 // Valor padrão para booleanos
      };
    }
    
    // Caso 2: Resposta é um Map
    if (response is Map) {
      try {
        final keysStr = response.keys.join(', ');
        debugPrint('✅ [PARSER] Resposta Map com chaves: $keysStr');
        
        final success = response['success'] as bool? ?? true;
        final pointsEarned = response['points_earned'] as int? ?? 0;
        final message = response['message'] as String? ?? 'Check-in processado';
        
        return {
          'success': success,
          'message': message,
          'points_earned': pointsEarned,
          // Preservar outras propriedades do mapa original com conversão explícita de tipos
          ...Map.fromEntries(response.entries
              .where((e) => !['success', 'message', 'points_earned'].contains(e.key))
              .map((e) => MapEntry<String, dynamic>(e.key.toString(), e.value))
          )
        };
      } catch (e) {
        debugPrint('⚠️ [PARSER] Erro ao extrair valores do Map: $e');
        return {
          'success': true, // Assumir sucesso por padrão
          'message': 'Check-in processado (com erro de parsing)',
          'points_earned': 0
        };
      }
    }
    
    // Caso 3: Outro tipo de resposta
    debugPrint('⚠️ [PARSER] Tipo de resposta não esperado: ${response.runtimeType}');
    
    return {
      'success': true, // Assumir sucesso por segurança
      'message': 'Formato de resposta não reconhecido',
      'points_earned': 0
    };
  }

  @override
  Future<Map<String, dynamic>> saveWorkoutRecord({
    required String userId,
    required String challengeId,
    required String workoutName,
    required String workoutType,
    required int durationMinutes,
    required DateTime date,
    String? notes,
    String? workoutId,
    String? workoutRecordId,
  }) async {
    try {
      // Verificar se o usuário está autenticado
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Log do challengeId (pode ser vazio se não há desafio ativo)
      if (challengeId.isEmpty) {
        debugPrint('ℹ️ Registrando treino sem desafio associado para usuário: $userId');
      } else {
        debugPrint('✅ PAYLOAD contém challenge_id=$challengeId');
      }
      
      // Montar parâmetros para a função RPC
      final params = {
        'p_user_id': userId,
        'p_challenge_id': challengeId.isEmpty ? null : challengeId,
        'p_workout_name': workoutName,
        'p_workout_type': workoutType,
        'p_duration_minutes': durationMinutes,
        'p_date': date.toUtc().toIso8601String(),
        'p_notes': notes ?? '',
      };
      
      // Garantir que sempre enviamos p_workout_id, mesmo se for vazio
      // Isso é importante para o Supabase usar o parâmetro corretamente
      params['p_workout_id'] = workoutId?.trim() ?? '';
      debugPrint('🔍 Usando workout_id=${workoutId ?? ''} para RPC');
      
      if (workoutRecordId != null) {
        params['p_workout_record_id'] = workoutRecordId;
        debugPrint('🔄 Atualizando treino existente ID=$workoutRecordId');
      } else {
        debugPrint('✅ Criando novo registro de treino');
      }
      
      // Chamar a função RPC
      debugPrint('📤 Chamando record_workout_basic com parâmetros: $params');
      final response = await _supabaseClient.rpc('record_workout_basic', params: params);
      
      // Verificar resposta
      // IMPORTANTE: A resposta agora é diretamente um Map e não um objeto PostgrestResponse
      debugPrint('✅ Resposta direta recebida: $response (tipo: ${response.runtimeType})');
      
      // ⭐ NOVO: Processar treino para atualizar metas automaticamente
      await _processWorkoutForGoals(
        userId: userId,
        workoutType: workoutType,
        durationMinutes: durationMinutes,
        workoutDate: date,
      );
      
      return _processRpcResponse(response);
    } catch (e) {
      debugPrint('❌ Erro no RPC record_workout_basic: $e');
      
      // ⭐ NOVO: Mesmo em caso de erro no registro, tentar processar metas
      // para garantir que o usuário não perca o progresso
      if (e is! app_errors.AppAuthException) {
        await _processWorkoutForGoals(
          userId: userId,
          workoutType: workoutType,
          durationMinutes: durationMinutes,
          workoutDate: date,
        );
      }
      
      throw app_errors.StorageException(
        message: 'Erro ao registrar treino via RPC: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Atualiza um treino existente usando a função RPC update_workout_simple
  Future<void> updateWorkout({
    required String workoutId,
    required String userId,
    required String challengeId,
    required String workoutName,
    required String workoutType,
    required int duration,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final params = {
        'p_workout_record_id': workoutId,
        'p_user_id': userId,
        'p_workout_name': workoutName,
        'p_workout_type': workoutType,
        'p_duration_minutes': duration,
        'p_date': date.toUtc().toIso8601String(),
        'p_notes': notes ?? '',
      };
      
      debugPrint('📤 Enviando dados para update_workout_simple: $params');

      final response = await _supabaseClient.rpc(
        'update_workout_simple',
        params: params,
      );

      debugPrint('✅ Resposta recebida: $response');

      if (response is Map<String, dynamic>) {
        final bool success = response['success'] as bool? ?? false;
        if (!success) {
          throw app_errors.DatabaseException(
            message: response['message'] as String? ?? 'Erro ao atualizar treino',
            code: response['error_code'] as String? ?? 'unknown_error',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar treino: $e');
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }

  /// Exclui um treino existente usando a função RPC delete_workout_simple
  Future<void> deleteWorkout({
    required String workoutId,
    required String userId,
    required String challengeId,
  }) async {
    try {
      final params = {
        'p_workout_record_id': workoutId,
        'p_user_id': userId,
      };
      
      debugPrint('📤 Enviando dados para delete_workout_simple: $params');

      final response = await _supabaseClient.rpc(
        'delete_workout_simple',
        params: params,
      );

      debugPrint('✅ Resposta recebida: $response');

      if (response is Map<String, dynamic>) {
        final bool success = response['success'] as bool? ?? false;
        if (!success) {
          throw app_errors.DatabaseException(
            message: response['message'] as String? ?? 'Erro ao excluir treino',
            code: response['error_code'] as String? ?? 'unknown_error',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao excluir treino: $e');
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  /// ⭐ NOVO: Processa treino para atualizar metas automaticamente
  /// 
  /// **Data:** 2025-01-21 às 15:30
  /// **Objetivo:** Conectar exercícios registrados às metas correspondentes
  /// **Referência:** Sistema de metas automático Ray Club
  Future<void> _processWorkoutForGoals({
    required String userId,
    required String workoutType,
    required int durationMinutes,
    required DateTime workoutDate,
  }) async {
    try {
      // Importar e usar o GoalProgressService
      final goalProgressService = GoalProgressService(
        supabaseClient: _supabaseClient,
      );
      
      final result = await goalProgressService.processWorkoutForGoals(
        userId: userId,
        workoutType: workoutType,
        durationMinutes: durationMinutes,
        workoutDate: workoutDate,
      );
      
      debugPrint('🎯 Resultado atualização de metas: ${result['message']}');
      
      if (result['updated_goals'] > 0) {
        debugPrint('🎉 ${result['updated_goals']} meta(s) atualizada(s) para categoria "${result['category']}"');
      }
      
    } catch (e) {
      debugPrint('⚠️ Erro ao processar metas (não crítico): $e');
      // Não propagar erro para não afetar o registro do treino
    }
  }

  /// Processa a resposta do RPC para verificar sucesso/erro
  static Map<String, dynamic> _processRpcResponse(dynamic response) {
  Map<String, dynamic> result;
  
  // Verificar se a resposta é um mapa válido
  if (response is Map<String, dynamic>) {
    result = response;
    debugPrint('✅ Resposta processada como Map: $result');
    
    // Verificar se a resposta indica sucesso
    final bool success = result['success'] as bool? ?? false;
    if (!success) {
      throw app_errors.DatabaseException(
        message: result['message'] as String? ?? 'Erro ao registrar treino',
        code: result['error_code'] as String? ?? 'unknown_error',
      );
    }
  } else {
    // Lidar com formatos inesperados
    debugPrint('⚠️ Formato de resposta inesperado: ${response.runtimeType}');
    result = {
      'success': true,
      'workout_id': '',
      'message': 'Treino registrado com formato de resposta não esperado'
    };
  }
  
  debugPrint('✅ Treino registrado com sucesso');
  return result;
  }
}