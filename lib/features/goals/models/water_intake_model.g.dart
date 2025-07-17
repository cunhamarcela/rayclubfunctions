// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_intake_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WaterIntakeImpl _$$WaterIntakeImplFromJson(Map<String, dynamic> json) =>
    _$WaterIntakeImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      currentGlasses: (json['currentGlasses'] as num?)?.toInt() ?? 0,
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 8,
      glassSize: (json['glassSize'] as num?)?.toInt() ?? 250,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WaterIntakeImplToJson(_$WaterIntakeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'currentGlasses': instance.currentGlasses,
      'dailyGoal': instance.dailyGoal,
      'glassSize': instance.glassSize,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };
