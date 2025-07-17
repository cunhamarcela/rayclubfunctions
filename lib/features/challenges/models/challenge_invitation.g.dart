// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeGroupInviteImpl _$$ChallengeGroupInviteImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeGroupInviteImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      inviterId: json['inviterId'] as String,
      inviteeId: json['inviteeId'] as String,
      statusCode: (json['status'] as num).toInt(),
      groupName: json['groupName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$$ChallengeGroupInviteImplToJson(
        _$ChallengeGroupInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'inviterId': instance.inviterId,
      'inviteeId': instance.inviteeId,
      'status': instance.statusCode,
      if (instance.groupName case final value?) 'groupName': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      if (instance.respondedAt?.toIso8601String() case final value?)
        'respondedAt': value,
    };
