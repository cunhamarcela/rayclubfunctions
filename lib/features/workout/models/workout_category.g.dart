// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutCategory _$WorkoutCategoryFromJson(Map<String, dynamic> json) =>
    WorkoutCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      workoutsCount: (json['workoutsCount'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt(),
      colorHex: json['colorHex'] as String?,
    );

Map<String, dynamic> _$WorkoutCategoryToJson(WorkoutCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      'workoutsCount': instance.workoutsCount,
      if (instance.order case final value?) 'order': value,
      if (instance.colorHex case final value?) 'colorHex': value,
    };
