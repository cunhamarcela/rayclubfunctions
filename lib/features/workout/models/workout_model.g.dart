// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutImpl _$$WorkoutImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      level: json['level'] as String?,
      equipment:
          (json['equipment'] as List<dynamic>).map((e) => e as String).toList(),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => WorkoutSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      exercises: (json['exercises'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$$WorkoutImplToJson(_$WorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      'type': instance.type,
      'durationMinutes': instance.durationMinutes,
      'difficulty': instance.difficulty,
      if (instance.level case final value?) 'level': value,
      'equipment': instance.equipment,
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'creatorId': instance.creatorId,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      if (instance.exercises case final value?) 'exercises': value,
    };

_$WorkoutSectionImpl _$$WorkoutSectionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSectionImpl(
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorkoutSectionImplToJson(
        _$WorkoutSectionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

_$WorkoutFilterImpl _$$WorkoutFilterImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutFilterImpl(
      category: json['category'] as String? ?? '',
      maxDuration: (json['maxDuration'] as num?)?.toInt() ?? 0,
      minDuration: (json['minDuration'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? '',
    );

Map<String, dynamic> _$$WorkoutFilterImplToJson(_$WorkoutFilterImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'maxDuration': instance.maxDuration,
      'minDuration': instance.minDuration,
      'difficulty': instance.difficulty,
    };
