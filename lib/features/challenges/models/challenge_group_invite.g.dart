// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_group_invite.dart';

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
      status: $enumDecodeNullable(_$InviteStatusEnumMap, json['status']) ??
          InviteStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$ChallengeGroupInviteImplToJson(
        _$ChallengeGroupInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'inviterId': instance.inviterId,
      'inviteeId': instance.inviteeId,
      'status': _$InviteStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.respondedAt?.toIso8601String() case final value?)
        'respondedAt': value,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
      if (instance.message case final value?) 'message': value,
    };

const _$InviteStatusEnumMap = {
  InviteStatus.pending: 'pending',
  InviteStatus.accepted: 'accepted',
  InviteStatus.rejected: 'rejected',
};
