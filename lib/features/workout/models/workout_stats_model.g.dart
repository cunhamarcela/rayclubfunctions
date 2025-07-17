// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutStatsImpl _$$WorkoutStatsImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutStatsImpl(
      userId: json['userId'] as String,
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      monthWorkouts: (json['monthWorkouts'] as num?)?.toInt() ?? 0,
      weekWorkouts: (json['weekWorkouts'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      frequencyPercentage:
          (json['frequencyPercentage'] as num?)?.toDouble() ?? 0.0,
      totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
      monthWorkoutDays: (json['monthWorkoutDays'] as num?)?.toInt() ?? 0,
      weekWorkoutDays: (json['weekWorkoutDays'] as num?)?.toInt() ?? 0,
      weekdayStats: (json['weekdayStats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      weekdayMinutes: (json['weekdayMinutes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
    );

Map<String, dynamic> _$$WorkoutStatsImplToJson(_$WorkoutStatsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalWorkouts': instance.totalWorkouts,
      'monthWorkouts': instance.monthWorkouts,
      'weekWorkouts': instance.weekWorkouts,
      'bestStreak': instance.bestStreak,
      'currentStreak': instance.currentStreak,
      'frequencyPercentage': instance.frequencyPercentage,
      'totalMinutes': instance.totalMinutes,
      'monthWorkoutDays': instance.monthWorkoutDays,
      'weekWorkoutDays': instance.weekWorkoutDays,
      if (instance.weekdayStats case final value?) 'weekdayStats': value,
      if (instance.weekdayMinutes case final value?) 'weekdayMinutes': value,
      if (instance.lastUpdatedAt?.toIso8601String() case final value?)
        'lastUpdatedAt': value,
    };
