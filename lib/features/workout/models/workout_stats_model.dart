// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_stats_model.freezed.dart';
part 'workout_stats_model.g.dart';

/// Modelo que representa as estatísticas de treino do usuário
@freezed
class WorkoutStats with _$WorkoutStats {
  const factory WorkoutStats({
    /// ID do usuário
    required String userId,
    
    /// Total de treinos realizados
    @Default(0) int totalWorkouts,
    
    /// Número de treinos no mês atual
    @Default(0) int monthWorkouts,
    
    /// Número de treinos na semana atual
    @Default(0) int weekWorkouts,
    
    /// Maior sequência de dias consecutivos com treino
    @Default(0) int bestStreak,
    
    /// Sequência atual de dias consecutivos com treino
    @Default(0) int currentStreak,
    
    /// Frequência mensal em percentual (baseado em meta de 20 treinos/mês)
    @Default(0.0) double frequencyPercentage,
    
    /// Total de minutos treinados
    @Default(0) int totalMinutes,
    
    /// Número de dias treinados este mês
    @Default(0) int monthWorkoutDays,
    
    /// Número de dias que treinou na semana atual
    @Default(0) int weekWorkoutDays,
    
    /// Estatísticas por dia da semana (para gráficos)
    Map<String, int>? weekdayStats,
    
    /// Minutos treinados por dia da semana
    Map<String, int>? weekdayMinutes,
    
    /// Data da última atualização das estatísticas
    DateTime? lastUpdatedAt,
  }) = _WorkoutStats;

  /// Converte um mapa para WorkoutStats
  factory WorkoutStats.fromJson(Map<String, dynamic> json) => _$WorkoutStatsFromJson(json);
  
  /// Cria uma instância vazia de WorkoutStats com o ID do usuário
  factory WorkoutStats.empty(String userId) => WorkoutStats(userId: userId);
  
  const WorkoutStats._();
  
  /// Se o usuário tem uma sequência ativa (treinou ontem ou hoje)
  bool get hasActiveStreak => currentStreak > 0;
  
  /// Frequência formatada como texto
  String get frequencyText => '${frequencyPercentage.toInt()}%';
  
  /// Média de treinos por semana
  double get weeklyAverage => totalWorkouts > 0 ? (totalWorkouts / (totalWorkouts / 7)).clamp(0, 7) : 0;
  
  /// Média de minutos por treino
  int get averageMinutesPerWorkout => 
      totalWorkouts > 0 ? (totalMinutes / totalWorkouts).round() : 0;
} 