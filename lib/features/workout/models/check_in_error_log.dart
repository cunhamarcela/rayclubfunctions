// Flutter imports:
import 'package:flutter/material.dart';

/// Modelo que representa um registro de erro no processamento de check-in
class CheckInErrorLog {
  /// Identificador único do registro de erro
  final String id;
  
  /// Identificador do usuário
  final String userId;
  
  /// Identificador do desafio (opcional)
  final String? challengeId;
  
  /// Identificador do treino (opcional)
  final String? workoutId;
  
  /// Dados da requisição original
  final Map<String, dynamic>? requestData;
  
  /// Dados da resposta recebida
  final Map<String, dynamic>? responseData;
  
  /// Mensagem de erro
  final String errorMessage;
  
  /// Detalhes adicionais do erro
  final String? errorDetail;
  
  /// Status do erro ('error', 'duplicate', 'skipped', 'recovery_failed', 'admin_retry')
  final String status;
  
  /// Data de criação do registro
  final DateTime createdAt;

  /// Construtor
  CheckInErrorLog({
    required this.id,
    required this.userId,
    this.challengeId,
    this.workoutId,
    this.requestData,
    this.responseData,
    required this.errorMessage,
    this.errorDetail,
    required this.status,
    required this.createdAt,
  });
  
  /// Cria uma instância a partir de um mapa JSON
  factory CheckInErrorLog.fromJson(Map<String, dynamic> json) {
    return CheckInErrorLog(
      id: json['id'],
      userId: json['user_id'],
      challengeId: json['challenge_id'],
      workoutId: json['workout_id'],
      requestData: json['request_data'],
      responseData: json['response_data'],
      errorMessage: json['error_message'] ?? 'Erro desconhecido',
      errorDetail: json['error_detail'],
      status: json['status'] ?? 'unknown',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  /// Converte a instância para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'workout_id': workoutId,
      'request_data': requestData,
      'response_data': responseData,
      'error_message': errorMessage,
      'error_detail': errorDetail,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Status formatado para exibição na UI
  String get statusFormatted {
    switch (status) {
      case 'error': return 'Erro';
      case 'duplicate': return 'Duplicado';
      case 'skipped': return 'Ignorado';
      case 'recovery_failed': return 'Falha na recuperação';
      case 'admin_retry': return 'Reprocessamento manual';
      default: return status;
    }
  }
  
  /// Cor do status para exibição na UI
  Color get statusColor {
    switch (status) {
      case 'error': return Colors.red;
      case 'duplicate': return Colors.orange;
      case 'skipped': return Colors.blue;
      case 'recovery_failed': return Colors.deepPurple;
      case 'admin_retry': return Colors.teal;
      default: return Colors.grey;
    }
  }
} 