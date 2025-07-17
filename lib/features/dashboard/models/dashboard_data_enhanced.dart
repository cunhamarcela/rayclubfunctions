// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data_enhanced.freezed.dart';
part 'dashboard_data_enhanced.g.dart';

/// Modelo completo que representa todos os dados do dashboard aprimorado
@freezed
class DashboardDataEnhanced with _$DashboardDataEnhanced {
  const factory DashboardDataEnhanced({
    /// Dados de progresso do usuário
    @JsonKey(name: 'user_progress') required UserProgressData userProgress,
    
    /// Dados de consumo de água
    @JsonKey(name: 'water_intake') required WaterIntakeData waterIntake,
    
    /// Dados de nutrição (pode ser null se não houver dados do dia)
    @JsonKey(name: 'nutrition_data') NutritionData? nutritionData,
    
    /// Lista de metas do usuário
    @JsonKey(name: 'goals') @Default([]) List<GoalData> goals,
    
    /// Treinos recentes
    @JsonKey(name: 'recent_workouts') @Default([]) List<RecentWorkoutData> recentWorkouts,
    
    /// Desafio atual (pode ser null se não houver)
    @JsonKey(name: 'current_challenge') ChallengeData? currentChallenge,
    
    /// Progresso no desafio atual
    @JsonKey(name: 'challenge_progress') ChallengeProgressData? challengeProgress,
    
    /// Benefícios resgatados
    @JsonKey(name: 'redeemed_benefits') @Default([]) List<RedeemedBenefitData> redeemedBenefits,
    
    /// Data da última atualização
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _DashboardDataEnhanced;

  factory DashboardDataEnhanced.fromJson(Map<String, dynamic> json) => 
      _$DashboardDataEnhancedFromJson(json);
}

/// Dados de progresso do usuário
@freezed
class UserProgressData with _$UserProgressData {
  const factory UserProgressData({
    @Default('') String id,
    @JsonKey(name: 'user_id') @Default('') String userId,
    @JsonKey(name: 'total_workouts') @Default(0) int totalWorkouts,
    @JsonKey(name: 'current_streak') @Default(0) int currentStreak,
    @JsonKey(name: 'longest_streak') @Default(0) int longestStreak,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'days_trained_this_month') @Default(0) int daysTrainedThisMonth,
    @JsonKey(name: 'workout_types') @Default({}) Map<String, dynamic> workoutTypes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserProgressData;

  factory UserProgressData.fromJson(Map<String, dynamic> json) => 
      _$UserProgressDataFromJson(json);
}

/// Dados de consumo de água
@freezed
class WaterIntakeData with _$WaterIntakeData {
  const factory WaterIntakeData({
    @Default('') String id,
    @JsonKey(name: 'user_id') @Default('') String userId,
    required DateTime date,
    @Default(0) int cups,
    @Default(8) int goal,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WaterIntakeData;

  factory WaterIntakeData.fromJson(Map<String, dynamic> json) => 
      _$WaterIntakeDataFromJson(json);
}

/// Dados de uma meta
@freezed
class GoalData with _$GoalData {
  const factory GoalData({
    @Default('') String id,
    @Default('') String title,
    @Default('') String description,
    @Default('') String category,
    @JsonKey(name: 'current_value') @Default(0) double currentValue,
    @JsonKey(name: 'target_value') @Default(0) double targetValue,
    @Default('') String unit,
    DateTime? deadline,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _GoalData;

  factory GoalData.fromJson(Map<String, dynamic> json) => 
      _$GoalDataFromJson(json);
}

/// Dados de treino recente
@freezed
class RecentWorkoutData with _$RecentWorkoutData {
  const factory RecentWorkoutData({
    @Default('') String id,
    @JsonKey(name: 'workout_name') @Default('') String workoutName,
    @JsonKey(name: 'workout_type') @Default('') String workoutType,
    required DateTime date,
    @JsonKey(name: 'duration_minutes') @Default(0) int durationMinutes,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
  }) = _RecentWorkoutData;

  factory RecentWorkoutData.fromJson(Map<String, dynamic> json) => 
      _$RecentWorkoutDataFromJson(json);
}

/// Dados do desafio
@freezed
class ChallengeData with _$ChallengeData {
  const factory ChallengeData({
    @Default('') String id,
    @Default('') String title,
    @Default('') String description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @Default(0) int points,
    @Default('') String type,
    @JsonKey(name: 'is_official') @Default(false) bool isOfficial,
    @JsonKey(name: 'days_remaining') @Default(0) int daysRemaining,
  }) = _ChallengeData;

  factory ChallengeData.fromJson(Map<String, dynamic> json) => 
      _$ChallengeDataFromJson(json);
}

/// Dados de progresso no desafio
@freezed
class ChallengeProgressData with _$ChallengeProgressData {
  const factory ChallengeProgressData({
    @Default('') String id,
    @JsonKey(name: 'user_id') @Default('') String userId,
    @JsonKey(name: 'challenge_id') @Default('') String challengeId,
    @Default(0) int points,
    @Default(0) int position,
    @JsonKey(name: 'total_check_ins') @Default(0) int totalCheckIns,
    @JsonKey(name: 'consecutive_days') @Default(0) int consecutiveDays,
    @JsonKey(name: 'completion_percentage') @Default(0.0) double completionPercentage,
  }) = _ChallengeProgressData;

  factory ChallengeProgressData.fromJson(Map<String, dynamic> json) => 
      _$ChallengeProgressDataFromJson(json);
}

/// Dados de benefício resgatado
@freezed
class RedeemedBenefitData with _$RedeemedBenefitData {
  const factory RedeemedBenefitData({
    @Default('') String id,
    @JsonKey(name: 'benefit_id') @Default('') String benefitId,
    @JsonKey(name: 'benefit_title') @Default('') String benefitTitle,
    @JsonKey(name: 'benefit_image_url') String? benefitImageUrl,
    @JsonKey(name: 'redeemed_at') required DateTime redeemedAt,
    @JsonKey(name: 'expiration_date') DateTime? expirationDate,
    @JsonKey(name: 'redemption_code') @Default('') String redemptionCode,
  }) = _RedeemedBenefitData;

  factory RedeemedBenefitData.fromJson(Map<String, dynamic> json) => 
      _$RedeemedBenefitDataFromJson(json);
}

/// Dados de nutrição
@freezed
class NutritionData with _$NutritionData {
  const factory NutritionData({
    @Default('') String id,
    @JsonKey(name: 'user_id') @Default('') String userId,
    required DateTime date,
    @JsonKey(name: 'calories_consumed') @Default(0) int caloriesConsumed,
    @JsonKey(name: 'calories_goal') @Default(2000) int caloriesGoal,
    @Default(0.0) double proteins,
    @Default(0.0) double carbs,
    @Default(0.0) double fats,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _NutritionData;

  factory NutritionData.fromJson(Map<String, dynamic> json) => 
      _$NutritionDataFromJson(json);
} 