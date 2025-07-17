// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_fitness_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardFitnessDataImpl _$$DashboardFitnessDataImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardFitnessDataImpl(
      calendar: CalendarData.fromJson(json['calendar'] as Map<String, dynamic>),
      progress: ProgressData.fromJson(json['progress'] as Map<String, dynamic>),
      awards: AwardsData.fromJson(json['awards'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$DashboardFitnessDataImplToJson(
        _$DashboardFitnessDataImpl instance) =>
    <String, dynamic>{
      'calendar': instance.calendar.toJson(),
      'progress': instance.progress.toJson(),
      'awards': instance.awards.toJson(),
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

_$CalendarDataImpl _$$CalendarDataImplFromJson(Map<String, dynamic> json) =>
    _$CalendarDataImpl(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => CalendarDayData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CalendarDataImplToJson(_$CalendarDataImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
      'days': instance.days.map((e) => e.toJson()).toList(),
    };

_$CalendarDayDataImpl _$$CalendarDayDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarDayDataImpl(
      day: (json['day'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      workoutCount: (json['workout_count'] as num?)?.toInt() ?? 0,
      totalMinutes: (json['total_minutes'] as num?)?.toInt() ?? 0,
      workoutTypes: (json['workout_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      workouts: (json['workouts'] as List<dynamic>?)
              ?.map((e) => WorkoutSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rings: ActivityRings.fromJson(json['rings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CalendarDayDataImplToJson(
        _$CalendarDayDataImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'date': instance.date.toIso8601String(),
      'workout_count': instance.workoutCount,
      'total_minutes': instance.totalMinutes,
      'workout_types': instance.workoutTypes,
      'workouts': instance.workouts.map((e) => e.toJson()).toList(),
      'rings': instance.rings.toJson(),
    };

_$ActivityRingsImpl _$$ActivityRingsImplFromJson(Map<String, dynamic> json) =>
    _$ActivityRingsImpl(
      move: (json['move'] as num?)?.toDouble() ?? 0,
      exercise: (json['exercise'] as num?)?.toDouble() ?? 0,
      stand: (json['stand'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$ActivityRingsImplToJson(_$ActivityRingsImpl instance) =>
    <String, dynamic>{
      'move': instance.move,
      'exercise': instance.exercise,
      'stand': instance.stand,
    };

_$WorkoutSummaryImpl _$$WorkoutSummaryImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      photoUrl: json['photo_url'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      isChallengeValid: json['is_challenge_valid'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$WorkoutSummaryImplToJson(
        _$WorkoutSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'duration': instance.duration,
      if (instance.photoUrl case final value?) 'photo_url': value,
      'points': instance.points,
      'is_challenge_valid': instance.isChallengeValid,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$ProgressDataImpl _$$ProgressDataImplFromJson(Map<String, dynamic> json) =>
    _$ProgressDataImpl(
      week: WeekProgress.fromJson(json['week'] as Map<String, dynamic>),
      month: MonthProgress.fromJson(json['month'] as Map<String, dynamic>),
      total: TotalProgress.fromJson(json['total'] as Map<String, dynamic>),
      streak: StreakData.fromJson(json['streak'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProgressDataImplToJson(_$ProgressDataImpl instance) =>
    <String, dynamic>{
      'week': instance.week.toJson(),
      'month': instance.month.toJson(),
      'total': instance.total.toJson(),
      'streak': instance.streak.toJson(),
    };

_$WeekProgressImpl _$$WeekProgressImplFromJson(Map<String, dynamic> json) =>
    _$WeekProgressImpl(
      workouts: (json['workouts'] as num?)?.toInt() ?? 0,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      types: (json['types'] as num?)?.toInt() ?? 0,
      days: (json['days'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WeekProgressImplToJson(_$WeekProgressImpl instance) =>
    <String, dynamic>{
      'workouts': instance.workouts,
      'minutes': instance.minutes,
      'types': instance.types,
      'days': instance.days,
    };

_$MonthProgressImpl _$$MonthProgressImplFromJson(Map<String, dynamic> json) =>
    _$MonthProgressImpl(
      workouts: (json['workouts'] as num?)?.toInt() ?? 0,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      days: (json['days'] as num?)?.toInt() ?? 0,
      typesDistribution:
          json['types_distribution'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$MonthProgressImplToJson(_$MonthProgressImpl instance) =>
    <String, dynamic>{
      'workouts': instance.workouts,
      'minutes': instance.minutes,
      'days': instance.days,
      'types_distribution': instance.typesDistribution,
    };

_$TotalProgressImpl _$$TotalProgressImplFromJson(Map<String, dynamic> json) =>
    _$TotalProgressImpl(
      workouts: (json['workouts'] as num?)?.toInt() ?? 0,
      workoutsCompleted: (json['workouts_completed'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      daysTrainedThisMonth:
          (json['days_trained_this_month'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      challengesCompleted: (json['challenges_completed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TotalProgressImplToJson(_$TotalProgressImpl instance) =>
    <String, dynamic>{
      'workouts': instance.workouts,
      'workouts_completed': instance.workoutsCompleted,
      'points': instance.points,
      'duration': instance.duration,
      'days_trained_this_month': instance.daysTrainedThisMonth,
      'level': instance.level,
      'challenges_completed': instance.challengesCompleted,
    };

_$StreakDataImpl _$$StreakDataImplFromJson(Map<String, dynamic> json) =>
    _$StreakDataImpl(
      current: (json['current'] as num?)?.toInt() ?? 0,
      longest: (json['longest'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StreakDataImplToJson(_$StreakDataImpl instance) =>
    <String, dynamic>{
      'current': instance.current,
      'longest': instance.longest,
    };

_$AwardsDataImpl _$$AwardsDataImplFromJson(Map<String, dynamic> json) =>
    _$AwardsDataImpl(
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      achievements: json['achievements'] as List<dynamic>? ?? const [],
      badges: json['badges'] as List<dynamic>? ?? const [],
      level: (json['level'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$AwardsDataImplToJson(_$AwardsDataImpl instance) =>
    <String, dynamic>{
      'total_points': instance.totalPoints,
      'achievements': instance.achievements,
      'badges': instance.badges,
      'level': instance.level,
    };

_$DayDetailsDataImpl _$$DayDetailsDataImplFromJson(Map<String, dynamic> json) =>
    _$DayDetailsDataImpl(
      date: DateTime.parse(json['date'] as String),
      totalWorkouts: (json['total_workouts'] as num?)?.toInt() ?? 0,
      totalMinutes: (json['total_minutes'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      workouts: (json['workouts'] as List<dynamic>?)
              ?.map((e) => WorkoutSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DayDetailsDataImplToJson(
        _$DayDetailsDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'total_workouts': instance.totalWorkouts,
      'total_minutes': instance.totalMinutes,
      'total_points': instance.totalPoints,
      'workouts': instance.workouts.map((e) => e.toJson()).toList(),
    };
