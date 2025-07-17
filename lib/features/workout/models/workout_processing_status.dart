// Flutter imports:
import 'package:flutter/material.dart';

/// Modelo que representa o status de processamento de um registro de treino
class WorkoutProcessingStatus {
  /// Identificador único do registro de status
  final String id;
  
  /// Identificador do registro de treino associado
  final String workoutId;
  
  /// Indica se o treino foi processado para atualização de ranking
  final bool processedForRanking;
  
  /// Indica se o treino foi processado para atualização de dashboard
  final bool processedForDashboard;
  
  /// Mensagem de erro caso ocorra algum problema no processamento
  final String? processingError;
  
  /// Data de criação do registro na fila de processamento
  final DateTime createdAt;
  
  /// Data de processamento, quando concluído
  final DateTime? processedAt;

  /// Construtor
  WorkoutProcessingStatus({
    required this.id,
    required this.workoutId,
    required this.processedForRanking,
    required this.processedForDashboard,
    this.processingError,
    required this.createdAt,
    this.processedAt,
  });
  
  /// Verifica se o treino foi completamente processado
  bool get isFullyProcessed => 
    processedForRanking && processedForDashboard;
    
  /// Texto de status formatado para exibição na UI
  String get statusText {
    if (isFullyProcessed) return '✅ Processado';
    if (!processedForRanking && !processedForDashboard) return '⌛ Em Análise';
    return '🔄 Processamento parcial';
  }
  
  /// Cor do status para exibição na UI
  Color get statusColor {
    if (isFullyProcessed) return Colors.green;
    return Colors.amber;
  }
  
  /// Cria uma instância a partir de um mapa JSON
  factory WorkoutProcessingStatus.fromJson(Map<String, dynamic> json) {
    return WorkoutProcessingStatus(
      id: json['id'],
      workoutId: json['workout_id'],
      processedForRanking: json['processed_for_ranking'] ?? false,
      processedForDashboard: json['processed_for_dashboard'] ?? false,
      processingError: json['processing_error'],
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null 
        ? DateTime.parse(json['processed_at']) 
        : null,
    );
  }
  
  /// Converte a instância para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'processed_for_ranking': processedForRanking,
      'processed_for_dashboard': processedForDashboard,
      'processing_error': processingError,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }
} 