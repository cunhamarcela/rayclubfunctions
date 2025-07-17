// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_participation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeParticipationImpl _$$ChallengeParticipationImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeParticipationImpl(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      challengeName: json['challengeName'] as String,
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      rank: (json['rank'] as num?)?.toInt(),
      totalParticipants: (json['totalParticipants'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ChallengeParticipationImplToJson(
        _$ChallengeParticipationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challengeId': instance.challengeId,
      'userId': instance.userId,
      'challengeName': instance.challengeName,
      'currentProgress': instance.currentProgress,
      if (instance.rank case final value?) 'rank': value,
      'totalParticipants': instance.totalParticipants,
      'isCompleted': instance.isCompleted,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      if (instance.completionDate?.toIso8601String() case final value?)
        'completionDate': value,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };
