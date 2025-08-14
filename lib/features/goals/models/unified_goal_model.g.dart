// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnifiedGoalImpl _$$UnifiedGoalImplFromJson(Map<String, dynamic> json) =>
    _$UnifiedGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$UnifiedGoalTypeEnumMap, json['type']),
      category: $enumDecodeNullable(_$GoalCategoryEnumMap, json['category']),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      unit: $enumDecode(_$GoalUnitEnumMap, json['unit']),
      measurementType: json['measurementType'] as String? ?? 'minutes',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      autoIncrement: json['autoIncrement'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UnifiedGoalImplToJson(_$UnifiedGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'type': _$UnifiedGoalTypeEnumMap[instance.type]!,
      if (_$GoalCategoryEnumMap[instance.category] case final value?)
        'category': value,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'unit': _$GoalUnitEnumMap[instance.unit]!,
      'measurementType': instance.measurementType,
      'startDate': instance.startDate.toIso8601String(),
      if (instance.endDate?.toIso8601String() case final value?)
        'endDate': value,
      'isCompleted': instance.isCompleted,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completedAt': value,
      'autoIncrement': instance.autoIncrement,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

const _$UnifiedGoalTypeEnumMap = {
  UnifiedGoalType.workoutCategory: 'workout_category',
  UnifiedGoalType.weeklyMinutes: 'weekly_minutes',
  UnifiedGoalType.dailyHabit: 'daily_habit',
  UnifiedGoalType.custom: 'custom',
};

const _$GoalCategoryEnumMap = {
  GoalCategory.musculacao: 'Musculação',
  GoalCategory.cardio: 'Cardio',
  GoalCategory.funcional: 'Funcional',
  GoalCategory.caminhada: 'Caminhada',
  GoalCategory.yoga: 'Yoga',
  GoalCategory.corrida: 'Corrida',
  GoalCategory.pilates: 'Pilates',
  GoalCategory.danca: 'Dança',
  GoalCategory.hiit: 'HIIT',
  GoalCategory.outro: 'Outro',
};

const _$GoalUnitEnumMap = {
  GoalUnit.sessoes: 'sessoes',
  GoalUnit.minutos: 'minutos',
  GoalUnit.horas: 'horas',
  GoalUnit.dias: 'dias',
  GoalUnit.vezes: 'vezes',
  GoalUnit.quilometros: 'quilometros',
  GoalUnit.calorias: 'calorias',
  GoalUnit.unidade: 'unidade',
};
