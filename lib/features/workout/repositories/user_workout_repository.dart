// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/events/app_event_bus.dart';
import 'package:ray_club_app/core/offline/offline_operation_queue.dart';
import 'package:ray_club_app/core/offline/offline_repository_helper.dart';
import 'package:ray_club_app/features/workout/models/user_workout.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/utils/datetime_extensions.dart';

/// Provider for UserWorkoutRepository
final userWorkoutRepositoryProvider = Provider<UserWorkoutRepository>((ref) {
  final supabase = Supabase.instance.client;
  final eventBus = ref.watch(appEventBusProvider);
  final offlineHelper = ref.watch(offlineRepositoryHelperProvider);
  return UserWorkoutRepository(supabase, eventBus, offlineHelper);
});

/// Repository for managing user workout records
class UserWorkoutRepository {
  final SupabaseClient _client;
  final AppEventBus _eventBus;
  final OfflineRepositoryHelper _offlineHelper;
  
  UserWorkoutRepository(this._client, this._eventBus, this._offlineHelper);
  
  /// Save a workout record
  Future<UserWorkout> saveWorkout(UserWorkout workout) async {
    // Ensure we have user information
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw AppAuthException(message: 'User not authenticated');
    }
    
    // Create data map with required fields
    final workoutData = {
      ...workout.toJson(),
      'user_id': currentUser.id,
      'user_name': workout.userName ?? currentUser.userMetadata?['name'] ?? 'User',
      'completed_at': workout.completedAt?.toSupabaseString() ?? DateTime.now().toSupabaseString(),
    };
    
    try {
      // Usa o helper para executar com suporte offline
      return await _offlineHelper.executeWithOfflineSupport<UserWorkout>(
        entity: 'workouts',
        type: OperationType.create,
        data: workoutData,
        onlineOperation: () async {
          // Operação online normal
          final response = await _client
              .from('user_workouts')
              .insert(workoutData)
              .select()
              .single();
          
          // Create workout object
          final savedWorkout = UserWorkout.fromJson(response);
          
          // Publish event
          _publishWorkoutEvent(savedWorkout, currentUser.id);
          
          return savedWorkout;
        },
        offlineResultBuilder: (operation) {
          // Se estiver offline, cria um ID temporário e retorna o workout
          // com uma flag indicando que foi salvo offline
          final savedWorkout = UserWorkout.fromJson({
            ...workoutData,
            'id': 'offline_${operation.id}',
            'is_synced': false,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          LogUtils.info(
            'Treino salvo na fila offline',
            tag: 'UserWorkoutRepository',
            data: {'operationId': operation.id},
          );
          
          return savedWorkout;
        },
      );
    } catch (e) {
      // Se for uma exceção de operação offline, podemos tratá-la de maneira especial
      if (e is OfflineOperationException) {
        LogUtils.info(
          'Treino adicionado à fila offline',
          tag: 'UserWorkoutRepository',
          data: {'operationId': e.operationId},
        );
        
        // Criar um objeto de treino com ID temporário
        return UserWorkout.fromJson({
          ...workoutData,
          'id': 'offline_${e.operationId}',
          'is_synced': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      // Para outros erros, registramos e propagamos
      LogUtils.error(
        'Erro ao salvar treino',
        tag: 'UserWorkoutRepository',
        error: e,
      );
      
      throw AppStorageException(
        message: 'Failed to save workout record',
        originalError: e,
      );
    }
  }
  
  /// Get user workout history
  Future<List<UserWorkout>> getUserWorkouts({required String userId, int limit = 20}) async {
    try {
      // Para leitura, tentamos obter dados do Supabase
      final response = await _client
          .from('user_workouts')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((item) => UserWorkout.fromJson(item))
          .toList();
    } catch (e) {
      // Se houver erro de conectividade, podemos tentar obter dados do cache local
      // (implementação do cache omitida para simplificar)
      LogUtils.warning(
        'Erro ao buscar histórico de treinos online, tentando cache',
        tag: 'UserWorkoutRepository',
        data: {'error': e.toString()},
      );
      
      // Retornamos uma lista vazia por enquanto
      return [];
    }
  }
  
  /// Get recent workouts (last X days)
  Future<List<UserWorkout>> getRecentWorkouts({required String userId, int days = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final response = await _client
          .from('user_workouts')
          .select()
          .eq('user_id', userId)
          .gte('completed_at', cutoffDate.toIso8601String())
          .order('completed_at', ascending: false);
      
      return (response as List)
          .map((item) => UserWorkout.fromJson(item))
          .toList();
    } catch (e) {
      // Se houver erro de conectividade, podemos tentar obter dados do cache local
      LogUtils.warning(
        'Erro ao buscar treinos recentes online, tentando cache',
        tag: 'UserWorkoutRepository',
        data: {'error': e.toString()},
      );
      
      // Retornamos uma lista vazia por enquanto
      return [];
    }
  }
  
  /// Publish workout event
  void _publishWorkoutEvent(UserWorkout workout, String userId) {
    _eventBus.publish(
      AppEvent.workout(
        type: EventTypes.workoutCompleted,
        workoutId: workout.id,
        data: {
          'workout': workout.toJson(),
          'userId': userId,
        },
      ),
    );
  }

  /// Get user workout history converted to WorkoutRecord format
  Future<List<WorkoutRecord>> getUserWorkoutsAsRecords({required String userId, int limit = 20}) async {
    final userWorkouts = await getUserWorkouts(userId: userId, limit: limit);
    return userWorkouts.map(_convertToWorkoutRecord).toList();
  }

  /// Convert UserWorkout to WorkoutRecord
  WorkoutRecord _convertToWorkoutRecord(UserWorkout workout) {
    // Obter data do treino, garantindo fuso horário correto do Brasil
    DateTime workoutDate;
    if (workout.completedAt != null) {
      workoutDate = workout.completedAt!;
    } else {
      // Criar data com fuso horário do Brasil (UTC-3)
      final nowInBrazil = DateTime.now().subtract(const Duration(hours: 3));
      workoutDate = DateTime(nowInBrazil.year, nowInBrazil.month, nowInBrazil.day);
    }
    
    return WorkoutRecord(
      id: workout.id,
      userId: workout.userId,
      workoutId: workout.workoutId,
      workoutName: workout.userName ?? 'Unknown Workout',
      workoutType: workout.workoutType ?? 'General',
      date: workoutDate,
      durationMinutes: workout.duration ?? 0,
      isCompleted: true,
      notes: workout.notes,
      createdAt: workout.completedAt,
    );
  }
} 