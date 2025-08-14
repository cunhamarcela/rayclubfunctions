// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cardio_challenge_progress.freezed.dart';
part 'cardio_challenge_progress.g.dart';

/// Modelo para progresso do usuário no desafio de cardio
@freezed
class CardioChallengeProgress with _$CardioChallengeProgress {
  const factory CardioChallengeProgress({
    /// Posição do usuário no ranking (1 = primeiro lugar)
    @JsonKey(name: 'position') required int position,
    
    /// Total de minutos de cardio do usuário
    @JsonKey(name: 'total_minutes') required int totalMinutes,
    
    /// Minutos de cardio do dia anterior
    @JsonKey(name: 'previous_day_minutes') @Default(0) int previousDayMinutes,
    
    /// Minutos de cardio de hoje
    @JsonKey(name: 'today_minutes') @Default(0) int todayMinutes,
    
    /// Percentual de melhoria em relação ao dia anterior
    @JsonKey(name: 'improvement_percentage') @Default(0.0) double improvementPercentage,
    
    /// Se o usuário está participando do desafio
    @JsonKey(name: 'is_participating') @Default(false) bool isParticipating,
    
    /// Total de participantes no desafio
    @JsonKey(name: 'total_participants') @Default(0) int totalParticipants,
    
    /// Data da última atualização
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _CardioChallengeProgress;

  factory CardioChallengeProgress.fromJson(Map<String, dynamic> json) => 
      _$CardioChallengeProgressFromJson(json);
}

/// Extensão para cálculos e formatação
extension CardioChallengeProgressExtension on CardioChallengeProgress {
  /// Retorna a posição formatada (ex: "1º", "2º", "3º")
  String get formattedPosition {
    switch (position) {
      case 1:
        return '1º';
      case 2:
        return '2º';
      case 3:
        return '3º';
      default:
        return '${position}º';
    }
  }
  
  /// Retorna o percentual de melhoria formatado
  String get formattedImprovementPercentage {
    if (improvementPercentage == 0) return '0%';
    final sign = improvementPercentage > 0 ? '+' : '';
    return '$sign${improvementPercentage.toStringAsFixed(1)}%';
  }
  
  /// Retorna a cor do percentual baseado na melhoria
  String get improvementColor {
    if (improvementPercentage > 0) return '#4CAF50'; // Verde
    if (improvementPercentage < 0) return '#F44336'; // Vermelho
    return '#9E9E9E'; // Cinza
  }
  
  /// Retorna o ícone do percentual baseado na melhoria
  String get improvementIcon {
    if (improvementPercentage > 0) return '📈';
    if (improvementPercentage < 0) return '📉';
    return '➖';
  }
  
  /// Calcula se houve melhoria significativa (>= 5%)
  bool get hasSignificantImprovement => improvementPercentage >= 5.0;
  
  /// Retorna mensagem motivacional baseada na posição
  String get motivationalMessage {
    if (!isParticipating) return 'Entre no desafio!';
    
    switch (position) {
      case 1:
        return 'Você está em 1º lugar! 🏆';
      case 2:
        return 'Quase lá! Você está em 2º lugar! 🥈';
      case 3:
        return 'Ótimo trabalho! Você está em 3º lugar! 🥉';
      default:
        if (position <= 10) {
          return 'Você está no top 10! Continue assim! 💪';
        } else if (position <= 50) {
          return 'Bom progresso! Você está no top 50! 🚀';
        } else {
          return 'Continue se esforçando! 💪';
        }
    }
  }
}
