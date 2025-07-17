// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyGoalImpl _$$WeeklyGoalImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goalMinutes: (json['goalMinutes'] as num).toInt(),
      currentMinutes: (json['currentMinutes'] as num?)?.toInt() ?? 0,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      completed: json['completed'] as bool? ?? false,
      percentageCompleted:
          (json['percentageCompleted'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WeeklyGoalImplToJson(_$WeeklyGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goalMinutes': instance.goalMinutes,
      'currentMinutes': instance.currentMinutes,
      'weekStartDate': instance.weekStartDate.toIso8601String(),
      'weekEndDate': instance.weekEndDate.toIso8601String(),
      'completed': instance.completed,
      'percentageCompleted': instance.percentageCompleted,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };
