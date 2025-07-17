// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeGroupInviteImpl _$$ChallengeGroupInviteImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeGroupInviteImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      inviterId: json['inviterId'] as String,
      inviterName: json['inviterName'] as String,
      inviteeId: json['inviteeId'] as String,
      status: $enumDecodeNullable(_$InviteStatusEnumMap, json['status']) ??
          InviteStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$$ChallengeGroupInviteImplToJson(
        _$ChallengeGroupInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'inviterId': instance.inviterId,
      'inviterName': instance.inviterName,
      'inviteeId': instance.inviteeId,
      'status': _$InviteStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.respondedAt?.toIso8601String() case final value?)
        'respondedAt': value,
    };

const _$InviteStatusEnumMap = {
  InviteStatus.pending: 'pending',
  InviteStatus.accepted: 'accepted',
  InviteStatus.rejected: 'rejected',
};
