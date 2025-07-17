// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutRecordImpl _$$WorkoutRecordImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutRecordImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      workoutId: json['workoutId'] as String?,
      workoutName: json['workoutName'] as String,
      workoutType: json['workoutType'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? true,
      completionStatus: json['completionStatus'] as String? ?? 'completed',
      notes: json['notes'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      challengeId: json['challengeId'] as String?,
    );

Map<String, dynamic> _$$WorkoutRecordImplToJson(_$WorkoutRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      if (instance.workoutId case final value?) 'workoutId': value,
      'workoutName': instance.workoutName,
      'workoutType': instance.workoutType,
      'date': instance.date.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'isCompleted': instance.isCompleted,
      'completionStatus': instance.completionStatus,
      if (instance.notes case final value?) 'notes': value,
      'imageUrls': instance.imageUrls,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.challengeId case final value?) 'challengeId': value,
    };
