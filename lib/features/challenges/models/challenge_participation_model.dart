// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_participation_model.freezed.dart';
part 'challenge_participation_model.g.dart';

/// Modelo que representa a participação de um usuário em um desafio
@freezed
class ChallengeParticipation with _$ChallengeParticipation {
  const factory ChallengeParticipation({
    /// ID único da participação
    required String id,
    
    /// ID do desafio
    required String challengeId,
    
    /// ID do usuário
    required String userId,
    
    /// Nome do desafio
    required String challengeName,
    
    /// Progresso atual do usuário (0-100)
    @Default(0.0) double currentProgress,
    
    /// Posição do usuário no ranking (opcional)
    int? rank,
    
    /// Total de participantes no desafio
    @Default(0) int totalParticipants,
    
    /// Indica se o desafio foi completado
    @Default(false) bool isCompleted,
    
    /// Data de início do desafio
    required DateTime startDate,
    
    /// Data de fim do desafio
    required DateTime endDate,
    
    /// Data de conclusão (se concluído)
    DateTime? completionDate,
    
    /// Data de criação do registro
    required DateTime createdAt,
    
    /// Data da última atualização
    DateTime? updatedAt,
  }) = _ChallengeParticipation;

  /// Cria um ChallengeParticipation a partir de um mapa JSON
  factory ChallengeParticipation.fromJson(Map<String, dynamic> json) => 
      _$ChallengeParticipationFromJson(json);
  
  const ChallengeParticipation._();
  
  /// Verifica se o desafio está ativo
  bool get isActive => !isCompleted && DateTime.now().isBefore(endDate);
  
  /// Retorna os dias restantes para o fim do desafio
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }
  
  /// Verifica se o desafio está expirado
  bool get isExpired => !isCompleted && DateTime.now().isAfter(endDate);
  
  /// Retorna o progresso como porcentagem formatada
  String get progressText => '${currentProgress.toInt()}%';
  
  /// Retorna o status do desafio em texto
  String get statusText {
    if (isCompleted) return 'Concluído';
    if (isExpired) return 'Expirado';
    return 'Em andamento';
  }
} 