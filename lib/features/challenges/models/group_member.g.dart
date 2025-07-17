// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupMemberImpl _$$GroupMemberImplFromJson(Map<String, dynamic> json) =>
    _$GroupMemberImpl(
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      groupId: json['groupId'] as String,
      isCreator: json['isCreator'] as bool? ?? false,
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$GroupMemberImplToJson(_$GroupMemberImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userDisplayName': instance.userDisplayName,
      if (instance.userAvatarUrl case final value?) 'userAvatarUrl': value,
      'groupId': instance.groupId,
      'isCreator': instance.isCreator,
      if (instance.joinedAt?.toIso8601String() case final value?)
        'joinedAt': value,
    };
