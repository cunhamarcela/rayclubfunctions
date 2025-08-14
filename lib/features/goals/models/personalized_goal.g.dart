// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalized_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonalizedGoalImpl _$$PersonalizedGoalImplFromJson(
        Map<String, dynamic> json) =>
    _$PersonalizedGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      presetType:
          $enumDecode(_$PersonalizedGoalPresetTypeEnumMap, json['presetType']),
      title: json['title'] as String,
      description: json['description'] as String?,
      measurementType: $enumDecode(
          _$PersonalizedGoalMeasurementTypeEnumMap, json['measurementType']),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      unitLabel: json['unitLabel'] as String,
      incrementStep: (json['incrementStep'] as num?)?.toDouble() ?? 1.0,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PersonalizedGoalImplToJson(
        _$PersonalizedGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'presetType': _$PersonalizedGoalPresetTypeEnumMap[instance.presetType]!,
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'measurementType':
          _$PersonalizedGoalMeasurementTypeEnumMap[instance.measurementType]!,
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
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

const _$PersonalizedGoalPresetTypeEnumMap = {
  PersonalizedGoalPresetType.projeto7Dias: 'projeto_7_dias',
  PersonalizedGoalPresetType.cardioCheck: 'cardio_check',
  PersonalizedGoalPresetType.musculacaoCheck: 'musculacao_check',
  PersonalizedGoalPresetType.funcionalCheck: 'funcional_check',
  PersonalizedGoalPresetType.yogaCheck: 'yoga_check',
  PersonalizedGoalPresetType.pilatesCheck: 'pilates_check',
  PersonalizedGoalPresetType.hiitCheck: 'hiit_check',
  PersonalizedGoalPresetType.corridaCheck: 'corrida_check',
  PersonalizedGoalPresetType.caminhadaCheck: 'caminhada_check',
  PersonalizedGoalPresetType.natacaoCheck: 'natacao_check',
  PersonalizedGoalPresetType.ciclismoCheck: 'ciclismo_check',
  PersonalizedGoalPresetType.alongamentoCheck: 'alongamento_check',
  PersonalizedGoalPresetType.forcaCheck: 'forca_check',
  PersonalizedGoalPresetType.fisioterapiaCheck: 'fisioterapia_check',
  PersonalizedGoalPresetType.flexibilidadeCheck: 'flexibilidade_check',
  PersonalizedGoalPresetType.custom: 'custom',
};

const _$PersonalizedGoalMeasurementTypeEnumMap = {
  PersonalizedGoalMeasurementType.check: 'check',
  PersonalizedGoalMeasurementType.minutes: 'minutes',
  PersonalizedGoalMeasurementType.weight: 'weight',
  PersonalizedGoalMeasurementType.calories: 'calories',
  PersonalizedGoalMeasurementType.liters: 'liters',
  PersonalizedGoalMeasurementType.days: 'days',
  PersonalizedGoalMeasurementType.custom: 'custom',
};

_$GoalCheckInImpl _$$GoalCheckInImplFromJson(Map<String, dynamic> json) =>
    _$GoalCheckInImpl(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GoalCheckInImplToJson(_$GoalCheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'userId': instance.userId,
      'checkInDate': instance.checkInDate.toIso8601String(),
      'checkInTime': instance.checkInTime.toIso8601String(),
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
      entryTime: DateTime.parse(json['entryTime'] as String),
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
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
      'entryTime': instance.entryTime.toIso8601String(),
      if (instance.notes case final value?) 'notes': value,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$CreateGoalDataImpl _$$CreateGoalDataImplFromJson(Map<String, dynamic> json) =>
    _$CreateGoalDataImpl(
      title: json['title'] as String,
      description: json['description'] as String?,
      measurementType: $enumDecode(
          _$PersonalizedGoalMeasurementTypeEnumMap, json['measurementType']),
      targetValue: (json['targetValue'] as num).toDouble(),
      unitLabel: json['unitLabel'] as String,
      incrementStep: (json['incrementStep'] as num?)?.toDouble() ?? 1.0,
      presetType: $enumDecodeNullable(
              _$PersonalizedGoalPresetTypeEnumMap, json['presetType']) ??
          PersonalizedGoalPresetType.custom,
    );

Map<String, dynamic> _$$CreateGoalDataImplToJson(
        _$CreateGoalDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'measurementType':
          _$PersonalizedGoalMeasurementTypeEnumMap[instance.measurementType]!,
      'targetValue': instance.targetValue,
      'unitLabel': instance.unitLabel,
      'incrementStep': instance.incrementStep,
      'presetType': _$PersonalizedGoalPresetTypeEnumMap[instance.presetType]!,
    };

_$GoalApiResponseImpl _$$GoalApiResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GoalApiResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String?,
      error: json['error'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GoalApiResponseImplToJson(
        _$GoalApiResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      if (instance.message case final value?) 'message': value,
      if (instance.error case final value?) 'error': value,
      if (instance.data case final value?) 'data': value,
    };

_$GoalStatusImpl _$$GoalStatusImplFromJson(Map<String, dynamic> json) =>
    _$GoalStatusImpl(
      goal: PersonalizedGoal.fromJson(json['goal'] as Map<String, dynamic>),
      checkinsToday: (json['checkinsToday'] as num?)?.toInt() ?? 0,
      progressToday: (json['progressToday'] as num?)?.toDouble() ?? 0.0,
      recentCheckIns: (json['recentCheckIns'] as List<dynamic>?)
              ?.map((e) => GoalCheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentEntries: (json['recentEntries'] as List<dynamic>?)
              ?.map(
                  (e) => GoalProgressEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GoalStatusImplToJson(_$GoalStatusImpl instance) =>
    <String, dynamic>{
      'goal': instance.goal.toJson(),
      'checkinsToday': instance.checkinsToday,
      'progressToday': instance.progressToday,
      'recentCheckIns': instance.recentCheckIns.map((e) => e.toJson()).toList(),
      'recentEntries': instance.recentEntries.map((e) => e.toJson()).toList(),
    };
