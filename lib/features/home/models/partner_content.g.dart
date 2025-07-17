// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartnerContentImpl _$$PartnerContentImplFromJson(Map<String, dynamic> json) =>
    _$PartnerContentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: json['duration'] as String,
      difficulty: json['difficulty'] as String,
      imageUrl: json['imageUrl'] as String,
      studioId: json['studioId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PartnerContentImplToJson(
        _$PartnerContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
      'imageUrl': instance.imageUrl,
      if (instance.studioId case final value?) 'studioId': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };
