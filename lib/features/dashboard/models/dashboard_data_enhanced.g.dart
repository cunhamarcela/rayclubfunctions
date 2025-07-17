// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data_enhanced.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDataEnhancedImpl _$$DashboardDataEnhancedImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardDataEnhancedImpl(
      userProgress: UserProgressData.fromJson(
          json['user_progress'] as Map<String, dynamic>),
      waterIntake: WaterIntakeData.fromJson(
          json['water_intake'] as Map<String, dynamic>),
      nutritionData: json['nutrition_data'] == null
          ? null
          : NutritionData.fromJson(
              json['nutrition_data'] as Map<String, dynamic>),
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => GoalData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentWorkouts: (json['recent_workouts'] as List<dynamic>?)
              ?.map(
                  (e) => RecentWorkoutData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentChallenge: json['current_challenge'] == null
          ? null
          : ChallengeData.fromJson(
              json['current_challenge'] as Map<String, dynamic>),
      challengeProgress: json['challenge_progress'] == null
          ? null
          : ChallengeProgressData.fromJson(
              json['challenge_progress'] as Map<String, dynamic>),
      redeemedBenefits: (json['redeemed_benefits'] as List<dynamic>?)
              ?.map((e) =>
                  RedeemedBenefitData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$DashboardDataEnhancedImplToJson(
        _$DashboardDataEnhancedImpl instance) =>
    <String, dynamic>{
      'user_progress': instance.userProgress.toJson(),
      'water_intake': instance.waterIntake.toJson(),
      if (instance.nutritionData?.toJson() case final value?)
        'nutrition_data': value,
      'goals': instance.goals.map((e) => e.toJson()).toList(),
      'recent_workouts':
          instance.recentWorkouts.map((e) => e.toJson()).toList(),
      if (instance.currentChallenge?.toJson() case final value?)
        'current_challenge': value,
      if (instance.challengeProgress?.toJson() case final value?)
        'challenge_progress': value,
      'redeemed_benefits':
          instance.redeemedBenefits.map((e) => e.toJson()).toList(),
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

_$UserProgressDataImpl _$$UserProgressDataImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProgressDataImpl(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      totalWorkouts: (json['total_workouts'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      daysTrainedThisMonth:
          (json['days_trained_this_month'] as num?)?.toInt() ?? 0,
      workoutTypes: json['workout_types'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserProgressDataImplToJson(
        _$UserProgressDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'total_workouts': instance.totalWorkouts,
      'current_streak': instance.currentStreak,
      'longest_streak': instance.longestStreak,
      'total_points': instance.totalPoints,
      'days_trained_this_month': instance.daysTrainedThisMonth,
      'workout_types': instance.workoutTypes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$WaterIntakeDataImpl _$$WaterIntakeDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WaterIntakeDataImpl(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      cups: (json['cups'] as num?)?.toInt() ?? 0,
      goal: (json['goal'] as num?)?.toInt() ?? 8,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$WaterIntakeDataImplToJson(
        _$WaterIntakeDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'date': instance.date.toIso8601String(),
      'cups': instance.cups,
      'goal': instance.goal,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$GoalDataImpl _$$GoalDataImplFromJson(Map<String, dynamic> json) =>
    _$GoalDataImpl(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0,
      targetValue: (json['target_value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$GoalDataImplToJson(_$GoalDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'current_value': instance.currentValue,
      'target_value': instance.targetValue,
      'unit': instance.unit,
      if (instance.deadline?.toIso8601String() case final value?)
        'deadline': value,
      'is_completed': instance.isCompleted,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$RecentWorkoutDataImpl _$$RecentWorkoutDataImplFromJson(
        Map<String, dynamic> json) =>
    _$RecentWorkoutDataImpl(
      id: json['id'] as String? ?? '',
      workoutName: json['workout_name'] as String? ?? '',
      workoutType: json['workout_type'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );

Map<String, dynamic> _$$RecentWorkoutDataImplToJson(
        _$RecentWorkoutDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_name': instance.workoutName,
      'workout_type': instance.workoutType,
      'date': instance.date.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
      'is_completed': instance.isCompleted,
    };

_$ChallengeDataImpl _$$ChallengeDataImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeDataImpl(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      points: (json['points'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      isOfficial: json['is_official'] as bool? ?? false,
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ChallengeDataImplToJson(_$ChallengeDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      if (instance.imageUrl case final value?) 'image_url': value,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'points': instance.points,
      'type': instance.type,
      'is_official': instance.isOfficial,
      'days_remaining': instance.daysRemaining,
    };

_$ChallengeProgressDataImpl _$$ChallengeProgressDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeProgressDataImpl(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      challengeId: json['challenge_id'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt() ?? 0,
      totalCheckIns: (json['total_check_ins'] as num?)?.toInt() ?? 0,
      consecutiveDays: (json['consecutive_days'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$ChallengeProgressDataImplToJson(
        _$ChallengeProgressDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'challenge_id': instance.challengeId,
      'points': instance.points,
      'position': instance.position,
      'total_check_ins': instance.totalCheckIns,
      'consecutive_days': instance.consecutiveDays,
      'completion_percentage': instance.completionPercentage,
    };

_$RedeemedBenefitDataImpl _$$RedeemedBenefitDataImplFromJson(
        Map<String, dynamic> json) =>
    _$RedeemedBenefitDataImpl(
      id: json['id'] as String? ?? '',
      benefitId: json['benefit_id'] as String? ?? '',
      benefitTitle: json['benefit_title'] as String? ?? '',
      benefitImageUrl: json['benefit_image_url'] as String?,
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
      expirationDate: json['expiration_date'] == null
          ? null
          : DateTime.parse(json['expiration_date'] as String),
      redemptionCode: json['redemption_code'] as String? ?? '',
    );

Map<String, dynamic> _$$RedeemedBenefitDataImplToJson(
        _$RedeemedBenefitDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'benefit_id': instance.benefitId,
      'benefit_title': instance.benefitTitle,
      if (instance.benefitImageUrl case final value?)
        'benefit_image_url': value,
      'redeemed_at': instance.redeemedAt.toIso8601String(),
      if (instance.expirationDate?.toIso8601String() case final value?)
        'expiration_date': value,
      'redemption_code': instance.redemptionCode,
    };

_$NutritionDataImpl _$$NutritionDataImplFromJson(Map<String, dynamic> json) =>
    _$NutritionDataImpl(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      caloriesConsumed: (json['calories_consumed'] as num?)?.toInt() ?? 0,
      caloriesGoal: (json['calories_goal'] as num?)?.toInt() ?? 2000,
      proteins: (json['proteins'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$NutritionDataImplToJson(_$NutritionDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'date': instance.date.toIso8601String(),
      'calories_consumed': instance.caloriesConsumed,
      'calories_goal': instance.caloriesGoal,
      'proteins': instance.proteins,
      'carbs': instance.carbs,
      'fats': instance.fats,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
