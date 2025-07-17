// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInResultImpl _$$CheckInResultImplFromJson(Map<String, dynamic> json) =>
    _$CheckInResultImpl(
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      points: (json['points'] as num).toInt(),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFirstToday: json['isFirstToday'] as bool? ?? false,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CheckInResultImplToJson(_$CheckInResultImpl instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'userId': instance.userId,
      'points': instance.points,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'isFirstToday': instance.isFirstToday,
      'streak': instance.streak,
      'totalPoints': instance.totalPoints,
    };

_$ChallengeCheckInImpl _$$ChallengeCheckInImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeCheckInImpl(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      points: (json['points'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      activityType: json['activityType'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChallengeCheckInImplToJson(
        _$ChallengeCheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challengeId': instance.challengeId,
      'userId': instance.userId,
      'points': instance.points,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.activityType case final value?) 'activityType': value,
      if (instance.notes case final value?) 'notes': value,
      if (instance.metadata case final value?) 'metadata': value,
    };
