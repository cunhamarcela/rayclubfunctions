// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_goal_expanded.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyGoalExpandedImpl _$$WeeklyGoalExpandedImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyGoalExpandedImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goalType:
          $enumDecodeNullable(_$GoalPresetTypeEnumMap, json['goalType']) ??
              GoalPresetType.custom,
      measurementType: $enumDecodeNullable(
              _$GoalMeasurementTypeEnumMap, json['measurementType']) ??
          GoalMeasurementType.minutes,
      goalTitle: json['goalTitle'] as String? ?? 'Meta Semanal',
      goalDescription: json['goalDescription'] as String?,
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 180.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      unitLabel: json['unitLabel'] as String? ?? 'min',
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      completed: json['completed'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WeeklyGoalExpandedImplToJson(
        _$WeeklyGoalExpandedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goalType': _$GoalPresetTypeEnumMap[instance.goalType]!,
      'measurementType':
          _$GoalMeasurementTypeEnumMap[instance.measurementType]!,
      'goalTitle': instance.goalTitle,
      if (instance.goalDescription case final value?) 'goalDescription': value,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'unitLabel': instance.unitLabel,
      'weekStartDate': instance.weekStartDate.toIso8601String(),
      'weekEndDate': instance.weekEndDate.toIso8601String(),
      'completed': instance.completed,
      'active': instance.active,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

const _$GoalPresetTypeEnumMap = {
  GoalPresetType.projetoBrunaBraga: 'projeto_bruna_braga',
  GoalPresetType.cardio: 'cardio',
  GoalPresetType.musculacao: 'musculacao',
  GoalPresetType.custom: 'custom',
};

const _$GoalMeasurementTypeEnumMap = {
  GoalMeasurementType.minutes: 'minutes',
  GoalMeasurementType.days: 'days',
  GoalMeasurementType.checkins: 'checkins',
  GoalMeasurementType.weight: 'weight',
  GoalMeasurementType.repetitions: 'repetitions',
  GoalMeasurementType.distance: 'distance',
  GoalMeasurementType.custom: 'custom',
};
