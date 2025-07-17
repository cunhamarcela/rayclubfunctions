// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:ray_club_app/utils/datetime_extensions.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_check_in.freezed.dart';
part 'challenge_check_in.g.dart';

/// Resultado de um check-in em desafio
@freezed
class CheckInResult with _$CheckInResult {
  const factory CheckInResult({
    /// ID do desafio
    required String challengeId,
    
    /// ID do usuário
    required String userId,
    
    /// Pontos ganhos com o check-in
    required int points,
    
    /// Mensagem de resultado
    required String message,
    
    /// Data e hora do check-in
    required DateTime createdAt,
    
    /// Indica se é o primeiro check-in do dia
    @Default(false) bool isFirstToday,
    
    /// Streak atual (dias consecutivos)
    @Default(0) int streak,
    
    /// Total de pontos do usuário no desafio
    @Default(0) int totalPoints,
  }) = _CheckInResult;

  /// Cria um CheckInResult a partir de um mapa JSON
  factory CheckInResult.fromJson(Map<String, dynamic> json) => 
      _$CheckInResultFromJson(json);
}

/// Representa um check-in individual em um desafio
@freezed
class ChallengeCheckIn with _$ChallengeCheckIn {
  const factory ChallengeCheckIn({
    /// ID único do check-in
    required String id,
    
    /// ID do desafio
    required String challengeId,
    
    /// ID do usuário
    required String userId,
    
    /// Pontos ganhos com este check-in
    required int points,
    
    /// Data e hora do check-in
    required DateTime createdAt,
    
    /// Tipo de atividade (opcional)
    String? activityType,
    
    /// Notas ou comentários (opcional)
    String? notes,
    
    /// Dados adicionais do check-in (JSON)
    Map<String, dynamic>? metadata,
  }) = _ChallengeCheckIn;

  /// Cria um ChallengeCheckIn a partir de um mapa JSON
  factory ChallengeCheckIn.fromJson(Map<String, dynamic> json) => 
      _$ChallengeCheckInFromJson(json);
} 