// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'preset_category_goals.dart';

part 'real_backend_goal_models.freezed.dart';
part 'real_backend_goal_models.g.dart';

/// **MODELOS REAIS DO BACKEND - RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 18:35
/// **Objetivo:** Usar as estruturas que JÁ EXISTEM no backend
/// **Referência:** Diagnóstico sql/goals_backend_diagnosis.sql
/// 
/// IMPORTANTE: Estes modelos correspondem às tabelas REAIS encontradas no banco

/// **MODELO: workout_category_goals**
/// Tabela que JÁ FAZ a integração treino→meta que você pediu!
@freezed
class WorkoutCategoryGoal with _$WorkoutCategoryGoal {
  const factory WorkoutCategoryGoal({
    required String id,
    required String userId,
    required String category,
    required int goalMinutes,
    required int currentMinutes,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required bool isActive,
    required bool completed,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkoutCategoryGoal;

  factory WorkoutCategoryGoal.fromJson(Map<String, dynamic> json) => 
      _$WorkoutCategoryGoalFromJson(json);
}

/// **MODELO: weekly_goals_expanded**
/// Sistema avançado de metas semanais já implementado
@freezed  
class WeeklyGoalExpanded with _$WeeklyGoalExpanded {
  const factory WeeklyGoalExpanded({
    required String id,
    required String userId,
    required String goalType,
    required String measurementType,
    required String goalTitle,
    String? goalDescription,
    required double targetValue,
    required double currentValue,
    required String unitLabel,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required bool completed,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WeeklyGoalExpanded;

  factory WeeklyGoalExpanded.fromJson(Map<String, dynamic> json) => 
      _$WeeklyGoalExpandedFromJson(json);
}

/// **MODELO: user_goals**
/// Tabela básica de metas do usuário
@freezed
class UserGoal with _$UserGoal {
  const factory UserGoal({
    required String id,
    required String userId,
    required String title,
    required double targetValue,
    required double currentValue,
    String? unit,
    required double progressPercentage,
    required String goalType,
    required DateTime startDate,
    DateTime? targetDate,
    required bool isCompleted,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserGoal;

  factory UserGoal.fromJson(Map<String, dynamic> json) => 
      _$UserGoalFromJson(json);
}

/// **MODELO: personalized_weekly_goals**
/// Sistema de metas personalizadas com check-ins
@freezed
class PersonalizedWeeklyGoal with _$PersonalizedWeeklyGoal {
  const factory PersonalizedWeeklyGoal({
    required String id,
    required String userId,
    required String goalPresetType,
    required String goalTitle,
    String? goalDescription,
    required String measurementType,
    required double targetValue,
    required double currentProgress,
    required String unitLabel,
    required double incrementStep,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required bool isActive,
    required bool isCompleted,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PersonalizedWeeklyGoal;

  factory PersonalizedWeeklyGoal.fromJson(Map<String, dynamic> json) => 
      _$PersonalizedWeeklyGoalFromJson(json);
}

/// **MODELO: goal_check_ins**
/// Check-ins para metas do tipo 'check'
@freezed
class GoalCheckIn with _$GoalCheckIn {
  const factory GoalCheckIn({
    required String id,
    required String goalId,
    required String userId,
    required DateTime checkInDate,
    String? notes,
    required DateTime createdAt,
  }) = _GoalCheckIn;

  factory GoalCheckIn.fromJson(Map<String, dynamic> json) => 
      _$GoalCheckInFromJson(json);
}

/// **MODELO: goal_progress_entries**
/// Entradas de progresso numérico para metas
@freezed
class GoalProgressEntry with _$GoalProgressEntry {
  const factory GoalProgressEntry({
    required String id,
    required String goalId,
    required String userId,
    required double valueAdded,
    required DateTime entryDate,
    String? notes,
    String? source,
    required DateTime createdAt,
  }) = _GoalProgressEntry;

  factory GoalProgressEntry.fromJson(Map<String, dynamic> json) => 
      _$GoalProgressEntryFromJson(json);
}

/// **ENUM: Categorias de Exercício (baseadas no sistema real)**
enum ExerciseCategory {
  @JsonValue('cardio')
  cardio('cardio', 'Cardio', '🏃'),
  
  @JsonValue('musculacao')
  musculacao('musculacao', 'Musculação', '💪'),
  
  @JsonValue('funcional')
  funcional('funcional', 'Funcional', '⚡'),
  
  @JsonValue('yoga')
  yoga('yoga', 'Yoga', '🧘'),
  
  @JsonValue('pilates')
  pilates('pilates', 'Pilates', '🤸'),
  
  @JsonValue('corrida')
  corrida('corrida', 'Corrida', '🏃‍♀️'),
  
  @JsonValue('natacao')
  natacao('natacao', 'Natação', '🏊'),
  
  @JsonValue('ciclismo')
  ciclismo('ciclismo', 'Ciclismo', '🚴'),
  
  @JsonValue('crossfit')
  crossfit('crossfit', 'CrossFit', '🏋️'),
  
  @JsonValue('danca')
  danca('danca', 'Dança', '💃'),
  
  @JsonValue('caminhada')
  caminhada('caminhada', 'Caminhada', '🚶'),
  
  @JsonValue('alongamento')
  alongamento('alongamento', 'Alongamento', '🤏');

  const ExerciseCategory(this.value, this.displayName, this.emoji);
  
  final String value;
  final String displayName;
  final String emoji;
}

/// **HELPER: Resposta das funções SQL**
@freezed
class SqlFunctionResponse with _$SqlFunctionResponse {
  const factory SqlFunctionResponse({
    required bool success,
    String? error,
    String? message,
    Map<String, dynamic>? data,
  }) = _SqlFunctionResponse;

  factory SqlFunctionResponse.fromJson(Map<String, dynamic> json) => 
      _$SqlFunctionResponseFromJson(json);
}

/// **EXTENSÕES PARA COMPATIBILIDADE**

extension WorkoutCategoryGoalExtension on WorkoutCategoryGoal {
  /// Percentual de progresso (0-100)
  double get percentageCompleted {
    if (goalMinutes == 0) return 0.0;
    return ((currentMinutes / goalMinutes) * 100).clamp(0.0, 100.0);
  }
  
  /// Nome de exibição da categoria
  String get categoryDisplayName {
    final preset = PresetCategoryGoal.getByCategory(category);
    return preset?.displayName ?? category.toUpperCase();
  }
  
  /// Minutos restantes para completar a meta
  int get remainingMinutes {
    return (goalMinutes - currentMinutes).clamp(0, goalMinutes);
  }
  
  /// Se a meta está completa
  bool get isCompleted => completed;
  
  /// Exibição formatada dos minutos atuais
  String get currentMinutesDisplay => '${currentMinutes}min';
  
  /// Exibição formatada dos minutos da meta
  String get goalMinutesDisplay => '${goalMinutes}min';
} 