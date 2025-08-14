// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'real_backend_goal_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutCategoryGoalImpl _$$WorkoutCategoryGoalImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutCategoryGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      goalMinutes: (json['goalMinutes'] as num).toInt(),
      currentMinutes: (json['currentMinutes'] as num).toInt(),
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      isActive: json['isActive'] as bool,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WorkoutCategoryGoalImplToJson(
        _$WorkoutCategoryGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': instance.category,
      'goalMinutes': instance.goalMinutes,
      'currentMinutes': instance.currentMinutes,
      'weekStartDate': instance.weekStartDate.toIso8601String(),
      'weekEndDate': instance.weekEndDate.toIso8601String(),
      'isActive': instance.isActive,
      'completed': instance.completed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$WeeklyGoalExpandedImpl _$$WeeklyGoalExpandedImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyGoalExpandedImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goalType: json['goalType'] as String,
      measurementType: json['measurementType'] as String,
      goalTitle: json['goalTitle'] as String,
      goalDescription: json['goalDescription'] as String?,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      unitLabel: json['unitLabel'] as String,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      completed: json['completed'] as bool,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WeeklyGoalExpandedImplToJson(
        _$WeeklyGoalExpandedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goalType': instance.goalType,
      'measurementType': instance.measurementType,
      'goalTitle': instance.goalTitle,
      if (instance.goalDescription case final value?) 'goalDescription': value,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'unitLabel': instance.unitLabel,
      'weekStartDate': instance.weekStartDate.toIso8601String(),
      'weekEndDate': instance.weekEndDate.toIso8601String(),
      'completed': instance.completed,
      'active': instance.active,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$UserGoalImpl _$$UserGoalImplFromJson(Map<String, dynamic> json) =>
    _$UserGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      unit: json['unit'] as String?,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      goalType: json['goalType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserGoalImplToJson(_$UserGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      if (instance.unit case final value?) 'unit': value,
      'progressPercentage': instance.progressPercentage,
      'goalType': instance.goalType,
      'startDate': instance.startDate.toIso8601String(),
      if (instance.targetDate?.toIso8601String() case final value?)
        'targetDate': value,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$PersonalizedWeeklyGoalImpl _$$PersonalizedWeeklyGoalImplFromJson(
        Map<String, dynamic> json) =>
    _$PersonalizedWeeklyGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goalPresetType: json['goalPresetType'] as String,
      goalTitle: json['goalTitle'] as String,
      goalDescription: json['goalDescription'] as String?,
      measurementType: json['measurementType'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentProgress: (json['currentProgress'] as num).toDouble(),
      unitLabel: json['unitLabel'] as String,
      incrementStep: (json['incrementStep'] as num).toDouble(),
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      isActive: json['isActive'] as bool,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PersonalizedWeeklyGoalImplToJson(
        _$PersonalizedWeeklyGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goalPresetType': instance.goalPresetType,
      'goalTitle': instance.goalTitle,
      if (instance.goalDescription case final value?) 'goalDescription': value,
      'measurementType': instance.measurementType,
      'targetValue': instance.targetValue,
      'currentProgress': instance.currentProgress,
      'unitLabel': instance.unitLabel,
      'incrementStep': instance.incrementStep,
      'weekStartDate': instance.weekStartDate.toIso8601String(),
      'weekEndDate': instance.weekEndDate.toIso8601String(),
      'isActive': instance.isActive,
      'isCompleted': instance.isCompleted,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completedAt': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$GoalCheckInImpl _$$GoalCheckInImplFromJson(Map<String, dynamic> json) =>
    _$GoalCheckInImpl(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GoalCheckInImplToJson(_$GoalCheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'userId': instance.userId,
      'checkInDate': instance.checkInDate.toIso8601String(),
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$GoalProgressEntryImpl _$$GoalProgressEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$GoalProgressEntryImpl(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      valueAdded: (json['valueAdded'] as num).toDouble(),
      entryDate: DateTime.parse(json['entryDate'] as String),
      notes: json['notes'] as String?,
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GoalProgressEntryImplToJson(
        _$GoalProgressEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'userId': instance.userId,
      'valueAdded': instance.valueAdded,
      'entryDate': instance.entryDate.toIso8601String(),
      if (instance.notes case final value?) 'notes': value,
      if (instance.source case final value?) 'source': value,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$SqlFunctionResponseImpl _$$SqlFunctionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SqlFunctionResponseImpl(
      success: json['success'] as bool,
      error: json['error'] as String?,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SqlFunctionResponseImplToJson(
        _$SqlFunctionResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      if (instance.error case final value?) 'error': value,
      if (instance.message case final value?) 'message': value,
      if (instance.data case final value?) 'data': value,
    };
