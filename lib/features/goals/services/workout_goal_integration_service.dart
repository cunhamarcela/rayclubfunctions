// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../repositories/unified_goal_repository.dart';
import '../providers/unified_goal_providers.dart';
import '../../workout/models/workout_record.dart';

/// **SERVIÇO DE INTEGRAÇÃO TREINOS ↔ METAS**
/// 
/// **Data:** 29 de Janeiro de 2025 às 16:30
/// **Objetivo:** Conectar automaticamente treinos registrados com progresso de metas
/// **Referência:** Sistema de metas unificado Ray Club

class WorkoutGoalIntegrationService {
  final UnifiedGoalRepository _goalRepository;

  WorkoutGoalIntegrationService({
    required UnifiedGoalRepository goalRepository,
  }) : _goalRepository = goalRepository;

  /// Processa um treino registrado e atualiza as metas correspondentes
  /// 
  /// **Parâmetros:**
  /// - `workoutRecord`: Registro do treino que foi completado
  /// 
  /// **Retorna:**
  /// Mapa com estatísticas do processamento
  Future<Map<String, dynamic>> processWorkoutForGoals(WorkoutRecord workoutRecord) async {
    try {
      debugPrint('🎯 [WorkoutGoalIntegration] Processando treino para metas...');
      debugPrint('📊 Treino: ${workoutRecord.workoutName} (${workoutRecord.workoutType})');
      debugPrint('⏱️ Duração: ${workoutRecord.durationMinutes} minutos');
      debugPrint('👤 Usuário: ${workoutRecord.userId}');
      
      // Usar o método do repositório unificado
      await _goalRepository.updateGoalsFromWorkout(
        workoutRecord.userId,
        workoutRecord.workoutType ?? 'Treino',
        workoutRecord.durationMinutes ?? 0,
      );
      
      debugPrint('✅ [WorkoutGoalIntegration] Metas processadas com sucesso!');
      
      return {
        'success': true,
        'workout_type': workoutRecord.workoutType,
        'duration_minutes': workoutRecord.durationMinutes,
        'user_id': workoutRecord.userId,
        'processed_at': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      debugPrint('❌ [WorkoutGoalIntegration] Erro ao processar metas: $e');
      
      return {
        'success': false,
        'error': e.toString(),
        'workout_type': workoutRecord.workoutType,
        'duration_minutes': workoutRecord.durationMinutes,
        'user_id': workoutRecord.userId,
        'processed_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Processa treino com parâmetros simples (para compatibilidade)
  Future<Map<String, dynamic>> processWorkoutSimple({
    required String userId,
    required String workoutType,
    required int durationMinutes,
  }) async {
    final mockRecord = WorkoutRecord(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      workoutId: null,
      workoutName: workoutType,
      workoutType: workoutType,
      date: DateTime.now(),
      durationMinutes: durationMinutes,
      createdAt: DateTime.now(),
    );
    
    return await processWorkoutForGoals(mockRecord);
  }
}

/// **PROVIDER PARA O SERVIÇO DE INTEGRAÇÃO**
final workoutGoalIntegrationServiceProvider = Provider<WorkoutGoalIntegrationService>((ref) {
  final goalRepository = ref.watch(unifiedGoalRepositoryProvider);
  return WorkoutGoalIntegrationService(goalRepository: goalRepository);
});

/// **PROVIDER PARA PROCESSAR TREINO COM METAS**
final processWorkoutForGoalsServiceProvider = Provider((ref) {
  final service = ref.watch(workoutGoalIntegrationServiceProvider);
  
  return (WorkoutRecord workoutRecord) async {
    final result = await service.processWorkoutForGoals(workoutRecord);
    
    // Invalidar providers relacionados para atualizar UI
    if (result['success'] == true) {
      ref.invalidate(userGoalsProvider);
      ref.invalidate(activeGoalsProvider);
      ref.invalidate(goalStatsProvider);
    }
    
    return result;
  };
}); 