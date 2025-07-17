// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserGoalImpl _$$UserGoalImplFromJson(Map<String, dynamic> json) =>
    _$UserGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$GoalTypeEnumMap, json['type']),
      target: (json['target'] as num).toDouble(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserGoalImplToJson(_$UserGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'type': _$GoalTypeEnumMap[instance.type]!,
      'target': instance.target,
      'progress': instance.progress,
      'unit': instance.unit,
      'startDate': instance.startDate.toIso8601String(),
      if (instance.endDate?.toIso8601String() case final value?)
        'endDate': value,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completedAt': value,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

const _$GoalTypeEnumMap = {
  GoalType.weight: 'weight',
  GoalType.workout: 'workout',
  GoalType.steps: 'steps',
  GoalType.nutrition: 'nutrition',
  GoalType.custom: 'custom',
};
