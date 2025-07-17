// Package imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'workout_record.dart';
import 'package:ray_club_app/utils/datetime_extensions.dart';

/// Adaptador para converter entre formatos de nome de coluna
class WorkoutRecordAdapter {
  /// Converte um mapa de dados do banco (snake_case) para o formato do modelo (camelCase)
  static Map<String, dynamic> fromDatabase(Map<String, dynamic> json) {
    debugPrint('📥 Convertendo do banco: $json');
    
    return {
      'id': json['id'] as String,
      'userId': json['user_id'] as String,
      'workoutId': json['workout_id'] as String?, // pode ser null
      'workoutName': json['workout_name'] as String? ?? 'Treino sem nome',
      'workoutType': json['workout_type'] as String? ?? 'Geral',
      'date': json['date'] as String,
      'durationMinutes': json['duration_minutes'] as int,
      'isCompleted': json['is_completed'] as bool? ?? true,
      'completionStatus': json['completion_status'] as String? ?? 'completed',
      'notes': json['notes'] as String?, // pode ser null
      'imageUrls': json['image_urls'] as List<dynamic>? ?? <String>[],
      'createdAt': json['created_at'] as String?, // pode ser null
      'challengeId': json['challenge_id'] as String?, // pode ser null
    };
  }

  /// Converte um modelo WorkoutRecord para o formato do banco (snake_case)
  static Map<String, dynamic> toDatabase(WorkoutRecord record) {
    // Log detalhado do objeto original
    debugPrint('🔬 WorkoutRecordAdapter.toDatabase recebeu record.challengeId = ${record.challengeId}');
    
    // Garantir que workout_id seja tratado como UUID válido ou seja removido
    String? workoutIdStr;
    if (record.workoutId != null) {
      workoutIdStr = record.workoutId.toString().trim();
      // Se for uma string vazia, definir como null para evitar problemas
      if (workoutIdStr.isEmpty) {
        workoutIdStr = null;
        debugPrint('⚠️ ADAPTER: workout_id vazio convertido para null');
      } else {
        debugPrint('✅ ADAPTER: Using workout_id=$workoutIdStr');
      }
    }
    
    final json = {
      // ID é omitido para permitir geração de UUID pelo banco
      'user_id': record.userId,
      // Remover workout_id se for null ou vazio, deixar o banco gerar
      'workout_name': record.workoutName,
      'workout_type': record.workoutType,
      'date': record.date.toSupabaseString(),
      'duration_minutes': record.durationMinutes,
      'is_completed': record.isCompleted,
      'notes': record.notes,
      'image_urls': record.imageUrls,
      'created_at': record.createdAt?.toSupabaseString(),
    };
    
    // Adicionar workout_id somente se for válido
    if (workoutIdStr != null) {
      json['workout_id'] = workoutIdStr;
    }
    
    // Adicionar explicitamente o challenge_id - CRITICAL CODE PATH
    if (record.challengeId != null) {
      json['challenge_id'] = record.challengeId;
      debugPrint('✅ ADAPTER: Incluindo challenge_id no JSON: ${record.challengeId}');
    } else {
      debugPrint('⚠️ ADAPTER: Objeto record NÃO tem challengeId (null)!');
    }
    
    // Remover campos nulos
    json.removeWhere((key, value) => value == null);
    
    debugPrint('📤 ADAPTER: Resultado final do JSON (campos: ${json.keys.join(", ")})');
    return json;
  }
  
  /// Cria um WorkoutRecord a partir de dados do banco 
  /// @deprecated Use fromDatabase instead
  static Map<String, dynamic> fromDatabaseJson(Map<String, dynamic> json) {
    return fromDatabase(json);
  }
  
  /// Converte um WorkoutRecord para o formato do banco
  /// @deprecated Use toDatabase instead
  static Map<String, dynamic> toDatabaseJson(WorkoutRecord record) {
    return toDatabase(record);
  }
  
  /// Converte dados do banco diretamente para WorkoutRecord
  /// @deprecated Use WorkoutRecord.fromJson(fromDatabase(json)) instead
  static WorkoutRecord fromJson(Map<String, dynamic> json) {
    return WorkoutRecord.fromJson(fromDatabase(json));
  }
} 