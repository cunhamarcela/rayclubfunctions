// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_category_goal.dart';

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
      currentMinutes: (json['currentMinutes'] as num?)?.toInt() ?? 0,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
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
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

_$WeeklyEvolutionImpl _$$WeeklyEvolutionImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyEvolutionImpl(
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      goalMinutes: (json['goalMinutes'] as num).toInt(),
      currentMinutes: (json['currentMinutes'] as num).toInt(),
      percentageCompleted: (json['percentageCompleted'] as num).toDouble(),
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$$WeeklyEvolutionImplToJson(
        _$WeeklyEvolutionImpl instance) =>
    <String, dynamic>{
      'weekStartDate': instance.weekStartDate.toIso8601String(),
      'goalMinutes': instance.goalMinutes,
      'currentMinutes': instance.currentMinutes,
      'percentageCompleted': instance.percentageCompleted,
      'completed': instance.completed,
    };
