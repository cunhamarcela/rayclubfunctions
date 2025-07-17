// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'content': instance.content,
      if (instance.readAt case final value?) 'read_at': value,
      'created_at': instance.createdAt,
    };
