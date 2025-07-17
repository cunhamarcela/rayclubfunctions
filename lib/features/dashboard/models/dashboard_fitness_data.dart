// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_fitness_data.freezed.dart';
part 'dashboard_fitness_data.g.dart';

/// Modelo completo para o dashboard fitness com calendário e estatísticas
@freezed
class DashboardFitnessData with _$DashboardFitnessData {
  const factory DashboardFitnessData({
    /// Dados do calendário mensal com anéis de progresso
    @JsonKey(name: 'calendar') required CalendarData calendar,
    
    /// Estatísticas de progresso semanal e mensal
    @JsonKey(name: 'progress') required ProgressData progress,
    
    /// Dados de premiação e pontuação
    @JsonKey(name: 'awards') required AwardsData awards,
    
    /// Data da última atualização
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _DashboardFitnessData;

  factory DashboardFitnessData.fromJson(Map<String, dynamic> json) => 
      _$DashboardFitnessDataFromJson(json);
}

/// Dados do calendário mensal
@freezed
class CalendarData with _$CalendarData {
  const factory CalendarData({
    /// Mês (1-12)
    @JsonKey(name: 'month') required int month,
    
    /// Ano
    @JsonKey(name: 'year') required int year,
    
    /// Lista de dias do mês
    @JsonKey(name: 'days') @Default([]) List<CalendarDayData> days,
  }) = _CalendarData;

  factory CalendarData.fromJson(Map<String, dynamic> json) => 
      _$CalendarDataFromJson(json);
}

/// Dados de um dia específico no calendário
@freezed
class CalendarDayData with _$CalendarDayData {
  const factory CalendarDayData({
    /// Dia do mês (1-31)
    @JsonKey(name: 'day') required int day,
    
    /// Data completa do dia
    @JsonKey(name: 'date') required DateTime date,
    
    /// Número de treinos no dia
    @JsonKey(name: 'workout_count') @Default(0) int workoutCount,
    
    /// Minutos totais de treino
    @JsonKey(name: 'total_minutes') @Default(0) int totalMinutes,
    
    /// Tipos de treino realizados
    @JsonKey(name: 'workout_types') @Default([]) List<String> workoutTypes,
    
    /// Lista de treinos do dia
    @JsonKey(name: 'workouts') @Default([]) List<WorkoutSummary> workouts,
    
    /// Anéis de progresso do dia
    @JsonKey(name: 'rings') required ActivityRings rings,
  }) = _CalendarDayData;

  factory CalendarDayData.fromJson(Map<String, dynamic> json) => 
      _$CalendarDayDataFromJson(json);
}

/// Anéis de atividade estilo Apple Watch
@freezed
class ActivityRings with _$ActivityRings {
  const factory ActivityRings({
    /// Anel verde - Treino realizado (0-100%)
    @JsonKey(name: 'move') @Default(0) double move,
    
    /// Anel vermelho - Meta de minutos atingida (0-100%)
    @JsonKey(name: 'exercise') @Default(0) double exercise,
    
    /// Anel azul - Check-in válido para desafio (0-100%)
    @JsonKey(name: 'stand') @Default(0) double stand,
  }) = _ActivityRings;

  factory ActivityRings.fromJson(Map<String, dynamic> json) => 
      _$ActivityRingsFromJson(json);
}

/// Resumo de um treino
@freezed
class WorkoutSummary with _$WorkoutSummary {
  const factory WorkoutSummary({
    /// ID do treino
    @JsonKey(name: 'id') required String id,
    
    /// Nome do treino
    @JsonKey(name: 'name') required String name,
    
    /// Tipo do treino
    @JsonKey(name: 'type') required String type,
    
    /// Duração em minutos
    @JsonKey(name: 'duration') @Default(0) int duration,
    
    /// URL da foto (opcional)
    @JsonKey(name: 'photo_url') String? photoUrl,
    
    /// Pontos ganhos
    @JsonKey(name: 'points') @Default(0) int points,
    
    /// Se é válido para desafio
    @JsonKey(name: 'is_challenge_valid') @Default(false) bool isChallengeValid,
    
    /// Data de criação
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _WorkoutSummary;

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) => 
      _$WorkoutSummaryFromJson(json);
}

/// Dados de progresso semanal e mensal
@freezed
class ProgressData with _$ProgressData {
  const factory ProgressData({
    /// Progresso da semana
    @JsonKey(name: 'week') required WeekProgress week,
    
    /// Progresso do mês
    @JsonKey(name: 'month') required MonthProgress month,
    
    /// Dados totais do usuário
    @JsonKey(name: 'total') required TotalProgress total,
    
    /// Dados de streak (sequência de dias)
    @JsonKey(name: 'streak') required StreakData streak,
  }) = _ProgressData;

  factory ProgressData.fromJson(Map<String, dynamic> json) => 
      _$ProgressDataFromJson(json);
}

/// Progresso da semana atual
@freezed
class WeekProgress with _$WeekProgress {
  const factory WeekProgress({
    /// Treinos completados na semana
    @JsonKey(name: 'workouts') @Default(0) int workouts,
    
    /// Minutos completados na semana
    @JsonKey(name: 'minutes') @Default(0) int minutes,
    
    /// Número de tipos diferentes de treino
    @JsonKey(name: 'types') @Default(0) int types,
    
    /// Dias treinados na semana
    @JsonKey(name: 'days') @Default(0) int days,
  }) = _WeekProgress;

  factory WeekProgress.fromJson(Map<String, dynamic> json) => 
      _$WeekProgressFromJson(json);
}

/// Progresso do mês atual
@freezed
class MonthProgress with _$MonthProgress {
  const factory MonthProgress({
    /// Treinos completados no mês
    @JsonKey(name: 'workouts') @Default(0) int workouts,
    
    /// Minutos completados no mês
    @JsonKey(name: 'minutes') @Default(0) int minutes,
    
    /// Dias treinados no mês
    @JsonKey(name: 'days') @Default(0) int days,
    
    /// Distribuição de tipos de treino
    @JsonKey(name: 'types_distribution') @Default({}) Map<String, dynamic> typesDistribution,
  }) = _MonthProgress;

  factory MonthProgress.fromJson(Map<String, dynamic> json) => 
      _$MonthProgressFromJson(json);
}

/// Dados totais do usuário
@freezed
class TotalProgress with _$TotalProgress {
  const factory TotalProgress({
    /// Total de treinos
    @JsonKey(name: 'workouts') @Default(0) int workouts,
    
    /// Total de treinos completados
    @JsonKey(name: 'workouts_completed') @Default(0) int workoutsCompleted,
    
    /// Total de pontos
    @JsonKey(name: 'points') @Default(0) int points,
    
    /// Duração total em minutos
    @JsonKey(name: 'duration') @Default(0) int duration,
    
    /// Dias treinados no mês atual
    @JsonKey(name: 'days_trained_this_month') @Default(0) int daysTrainedThisMonth,
    
    /// Nível atual do usuário
    @JsonKey(name: 'level') @Default(1) int level,
    
    /// Desafios completados
    @JsonKey(name: 'challenges_completed') @Default(0) int challengesCompleted,
  }) = _TotalProgress;

  factory TotalProgress.fromJson(Map<String, dynamic> json) => 
      _$TotalProgressFromJson(json);
}

/// Dados de streak (sequência de dias)
@freezed
class StreakData with _$StreakData {
  const factory StreakData({
    /// Número de dias consecutivos atuais
    @JsonKey(name: 'current') @Default(0) int current,
    
    /// Maior sequência já alcançada
    @JsonKey(name: 'longest') @Default(0) int longest,
  }) = _StreakData;

  factory StreakData.fromJson(Map<String, dynamic> json) => 
      _$StreakDataFromJson(json);
}

/// Dados de premiação e pontuação
@freezed
class AwardsData with _$AwardsData {
  const factory AwardsData({
    /// Total de pontos
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    
    /// Conquistas do usuário
    @JsonKey(name: 'achievements') @Default([]) List<dynamic> achievements,
    
    /// Medalhas conquistadas
    @JsonKey(name: 'badges') @Default([]) List<dynamic> badges,
    
    /// Nível atual
    @JsonKey(name: 'level') @Default(1) int level,
  }) = _AwardsData;

  factory AwardsData.fromJson(Map<String, dynamic> json) => 
      _$AwardsDataFromJson(json);
}

/// Modelo para detalhes de um dia específico
@freezed
class DayDetailsData with _$DayDetailsData {
  const factory DayDetailsData({
    /// Data do dia
    @JsonKey(name: 'date') required DateTime date,
    
    /// Total de treinos
    @JsonKey(name: 'total_workouts') @Default(0) int totalWorkouts,
    
    /// Total de minutos
    @JsonKey(name: 'total_minutes') @Default(0) int totalMinutes,
    
    /// Total de pontos
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    
    /// Lista de treinos
    @JsonKey(name: 'workouts') @Default([]) List<WorkoutSummary> workouts,
  }) = _DayDetailsData;

  factory DayDetailsData.fromJson(Map<String, dynamic> json) => 
      _$DayDetailsDataFromJson(json);
} 