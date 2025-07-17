// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      duration: (json['duration'] as num).toInt(),
      level: json['level'] as String,
      calories: (json['calories'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      trainerName: json['trainerName'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'duration': instance.duration,
      'level': instance.level,
      'calories': instance.calories,
      'imageUrl': instance.imageUrl,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      'isFavorite': instance.isFavorite,
      if (instance.trainerName case final value?) 'trainerName': value,
      'isFeatured': instance.isFeatured,
    };
