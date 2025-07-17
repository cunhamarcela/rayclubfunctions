// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSectionImpl _$$WorkoutSectionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSectionImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedTimeMinutes:
          (json['estimatedTimeMinutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WorkoutSectionImplToJson(
        _$WorkoutSectionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'order': instance.order,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'estimatedTimeMinutes': instance.estimatedTimeMinutes,
    };
