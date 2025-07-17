// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeDataImpl _$$HomeDataImplFromJson(Map<String, dynamic> json) =>
    _$HomeDataImpl(
      activeBanner:
          BannerItem.fromJson(json['activeBanner'] as Map<String, dynamic>),
      banners: (json['banners'] as List<dynamic>)
          .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      progress: UserProgress.fromJson(json['progress'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => WorkoutCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularWorkouts: (json['popularWorkouts'] as List<dynamic>)
          .map((e) => PopularWorkout.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$HomeDataImplToJson(_$HomeDataImpl instance) =>
    <String, dynamic>{
      'activeBanner': instance.activeBanner.toJson(),
      'banners': instance.banners.map((e) => e.toJson()).toList(),
      'progress': instance.progress.toJson(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'popularWorkouts':
          instance.popularWorkouts.map((e) => e.toJson()).toList(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

_$BannerItemImpl _$$BannerItemImplFromJson(Map<String, dynamic> json) =>
    _$BannerItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      actionUrl: json['actionUrl'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$$BannerItemImplToJson(_$BannerItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      if (instance.actionUrl case final value?) 'actionUrl': value,
      'isActive': instance.isActive,
    };

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      workoutsByType: (json['workoutsByType'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      totalDuration: (json['totalDuration'] as num?)?.toInt() ?? 0,
      completedChallenges: (json['completedChallenges'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      lastWorkout: json['lastWorkout'] == null
          ? null
          : DateTime.parse(json['lastWorkout'] as String),
      monthlyWorkouts: (json['monthlyWorkouts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      weeklyWorkouts: (json['weeklyWorkouts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      daysTrainedThisMonth:
          (json['daysTrainedThisMonth'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      challengeProgress: (json['challengeProgress'] as num?)?.toInt() ?? 0,
      recentWorkoutsDuration:
          (json['recentWorkoutsDuration'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.userId case final value?) 'userId': value,
      'totalWorkouts': instance.totalWorkouts,
      'totalPoints': instance.totalPoints,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'workoutsByType': instance.workoutsByType,
      'totalDuration': instance.totalDuration,
      'completedChallenges': instance.completedChallenges,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'lastUpdated': value,
      if (instance.lastWorkout?.toIso8601String() case final value?)
        'lastWorkout': value,
      if (instance.monthlyWorkouts case final value?) 'monthlyWorkouts': value,
      if (instance.weeklyWorkouts case final value?) 'weeklyWorkouts': value,
      'daysTrainedThisMonth': instance.daysTrainedThisMonth,
      'bestStreak': instance.bestStreak,
      'challengeProgress': instance.challengeProgress,
      if (instance.recentWorkoutsDuration case final value?)
        'recentWorkoutsDuration': value,
    };

_$WorkoutCategoryImpl _$$WorkoutCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      workoutCount: (json['workoutCount'] as num).toInt(),
      colorHex: json['colorHex'] as String?,
    );

Map<String, dynamic> _$$WorkoutCategoryImplToJson(
        _$WorkoutCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconUrl': instance.iconUrl,
      'workoutCount': instance.workoutCount,
      if (instance.colorHex case final value?) 'colorHex': value,
    };

_$PopularWorkoutImpl _$$PopularWorkoutImplFromJson(Map<String, dynamic> json) =>
    _$PopularWorkoutImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      duration: json['duration'] as String,
      difficulty: json['difficulty'] as String,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PopularWorkoutImplToJson(
        _$PopularWorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
      'favoriteCount': instance.favoriteCount,
    };
