// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDataImpl _$$DashboardDataImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDataImpl(
      totalWorkouts: (json['total_workouts'] as num?)?.toInt() ?? 0,
      totalDuration: (json['total_duration'] as num?)?.toInt() ?? 0,
      daysTrainedThisMonth:
          (json['days_trained_this_month'] as num?)?.toInt() ?? 0,
      workoutsByType:
          json['workouts_by_type'] as Map<String, dynamic>? ?? const {},
      recentWorkouts: (json['recent_workouts'] as List<dynamic>?)
              ?.map((e) => WorkoutPreview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      challengeProgress: ChallengeProgress.fromJson(
          json['challenge_progress'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$DashboardDataImplToJson(_$DashboardDataImpl instance) =>
    <String, dynamic>{
      'total_workouts': instance.totalWorkouts,
      'total_duration': instance.totalDuration,
      'days_trained_this_month': instance.daysTrainedThisMonth,
      'workouts_by_type': instance.workoutsByType,
      'recent_workouts':
          instance.recentWorkouts.map((e) => e.toJson()).toList(),
      'challenge_progress': instance.challengeProgress.toJson(),
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

_$WorkoutPreviewImpl _$$WorkoutPreviewImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutPreviewImpl(
      id: json['id'] as String? ?? '',
      workoutName: json['workout_name'] as String? ?? '',
      workoutType: json['workout_type'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WorkoutPreviewImplToJson(
        _$WorkoutPreviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_name': instance.workoutName,
      'workout_type': instance.workoutType,
      'date': instance.date.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
    };

_$ChallengeProgressImpl _$$ChallengeProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeProgressImpl(
      checkIns: (json['check_ins'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ChallengeProgressImplToJson(
        _$ChallengeProgressImpl instance) =>
    <String, dynamic>{
      'check_ins': instance.checkIns,
      'total_points': instance.totalPoints,
    };
