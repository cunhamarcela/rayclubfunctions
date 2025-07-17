// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_processing_status.dart';
import 'package:ray_club_app/utils/datetime_extensions.dart';

part 'workout_record.freezed.dart';
part 'workout_record.g.dart';

/// Modelo que representa um registro de treino realizado pelo usuário
@freezed
class WorkoutRecord with _$WorkoutRecord {
  const factory WorkoutRecord({
    /// ID do registro
    required String id,
    
    /// ID do usuário
    required String userId,
    
    /// ID do treino (pode ser nulo para treinos personalizados)
    String? workoutId,
    
    /// Nome do treino realizado
    required String workoutName,
    
    /// Tipo/categoria do treino
    required String workoutType,
    
    /// Data e hora do treino
    required DateTime date,
    
    /// Duração em minutos
    required int durationMinutes,
    
    /// Indica se o treino foi completado integralmente
    @Default(true) bool isCompleted,
    
    /// Status de conclusão do treino
    @Default('completed') String completionStatus,
    
    /// Notas ou observações opcionais
    String? notes,
    
    /// URLs das imagens associadas ao treino
    @Default([]) List<String> imageUrls,
    
    /// Data de criação do registro
    DateTime? createdAt,
    
    /// ID do desafio ao qual este treino pertence (se houver)
    String? challengeId,
    
    /// Status de processamento do treino (não persistido no Supabase)
    @JsonKey(ignore: true) WorkoutProcessingStatus? processingStatus,
  }) = _WorkoutRecord;

  /// Conversor de JSON para WorkoutRecord
  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => _$WorkoutRecordFromJson(json);

  factory WorkoutRecord.empty() {
    // Criar data com fuso horário do Brasil (UTC-3)
    final nowInBrazil = DateTime.now().subtract(const Duration(hours: 3));
    final brazilDate = DateTime(nowInBrazil.year, nowInBrazil.month, nowInBrazil.day);
    
    return WorkoutRecord(
      id: const Uuid().v4(),
      userId: '',
      workoutName: '',
      workoutType: '',
      date: brazilDate,
      durationMinutes: 30,
    );
  }
}

/// Extensão para adicionar getters relacionados ao status de processamento
extension WorkoutRecordProcessingExtension on WorkoutRecord {
  /// Verifica se o treino foi completamente processado
  bool get isFullyProcessed => 
      processingStatus == null || 
      (processingStatus!.processedForRanking && processingStatus!.processedForDashboard);
      
  /// Texto de status formatado para exibição na UI
  String get statusText => isFullyProcessed 
      ? "✅ Processado" 
      : "⌛ Em Análise";
      
  /// Cor do status para exibição na UI
  Color get statusColor => isFullyProcessed 
      ? Colors.green 
      : Colors.amber;
      
  /// Obtém a mensagem de erro de processamento, se houver
  String? get processingErrorMessage => 
      processingStatus?.processingError;
      
  /// Verifica se houve falha no processamento
  bool get hasFailed => 
      processingStatus != null && 
      processingStatus!.processingError != null &&
      !isFullyProcessed;
} 