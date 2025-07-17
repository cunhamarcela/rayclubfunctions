// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      if (instance.name case final value?) 'name': value,
      if (instance.photoUrl case final value?) 'photoUrl': value,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      'isEmailVerified': instance.isEmailVerified,
      if (instance.metadata case final value?) 'metadata': value,
      if (instance.isAdmin case final value?) 'isAdmin': value,
    };
