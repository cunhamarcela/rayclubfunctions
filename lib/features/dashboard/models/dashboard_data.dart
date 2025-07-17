// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

/// Modelo que representa os dados completos do dashboard do usuário
/// com dados extraídos diretamente dos workout_records
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    /// Número total de treinos registrados
    @JsonKey(name: 'total_workouts') @Default(0) int totalWorkouts,
    
    /// Duração total de treinos em minutos
    @JsonKey(name: 'total_duration') @Default(0) int totalDuration,
    
    /// Número de dias treinados no mês atual
    @JsonKey(name: 'days_trained_this_month') @Default(0) int daysTrainedThisMonth,
    
    /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
    @JsonKey(name: 'workouts_by_type') @Default({}) Map<String, dynamic> workoutsByType,
    
    /// Lista de treinos recentes
    @JsonKey(name: 'recent_workouts') @Default([]) List<WorkoutPreview> recentWorkouts,
    
    /// Progresso em desafios
    @JsonKey(name: 'challenge_progress') required ChallengeProgress challengeProgress,
    
    /// Data da última atualização dos dados
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _DashboardData;

  /// Conversor de JSON para DashboardData
  factory DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);
}

/// Modelo para pré-visualização de treinos recentes
@freezed
class WorkoutPreview with _$WorkoutPreview {
  const factory WorkoutPreview({
    /// ID único do treino
    @Default('') String id,
    
    /// Nome do treino
    @JsonKey(name: 'workout_name') @Default('') String workoutName,
    
    /// Tipo de treino (cardio, força, etc.)
    @JsonKey(name: 'workout_type') @Default('') String workoutType,
    
    /// Data de realização do treino
    required DateTime date,
    
    /// Duração do treino em minutos
    @JsonKey(name: 'duration_minutes') @Default(0) int durationMinutes,
  }) = _WorkoutPreview;

  /// Conversor de JSON para WorkoutPreview
  factory WorkoutPreview.fromJson(Map<String, dynamic> json) => _$WorkoutPreviewFromJson(json);
}

/// Modelo para progresso em desafios
@freezed
class ChallengeProgress with _$ChallengeProgress {
  const factory ChallengeProgress({
    /// Número total de check-ins realizados
    @JsonKey(name: 'check_ins') @Default(0) int checkIns,
    
    /// Total de pontos acumulados
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
  }) = _ChallengeProgress;

  /// Conversor de JSON para ChallengeProgress
  factory ChallengeProgress.fromJson(Map<String, dynamic> json) => _$ChallengeProgressFromJson(json);
} 