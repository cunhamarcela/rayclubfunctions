// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      detail: json['detail'] as String,
      imageUrl: json['imageUrl'] as String?,
      restTime: (json['restTime'] as num?)?.toInt(),
      instructions: json['instructions'] as String?,
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      equipment: (json['equipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      videoUrl: json['videoUrl'] as String?,
      description: json['description'] as String?,
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: (json['reps'] as num?)?.toInt() ?? 12,
      duration: (json['duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'detail': instance.detail,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.restTime case final value?) 'restTime': value,
      if (instance.instructions case final value?) 'instructions': value,
      if (instance.targetMuscles case final value?) 'targetMuscles': value,
      if (instance.equipment case final value?) 'equipment': value,
      if (instance.videoUrl case final value?) 'videoUrl': value,
      if (instance.description case final value?) 'description': value,
      if (instance.sets case final value?) 'sets': value,
      if (instance.reps case final value?) 'reps': value,
      if (instance.duration case final value?) 'duration': value,
    };
