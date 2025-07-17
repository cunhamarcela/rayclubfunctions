// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_studio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartnerStudioImpl _$$PartnerStudioImplFromJson(Map<String, dynamic> json) =>
    _$PartnerStudioImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      logoUrl: json['logoUrl'] as String?,
      contents: (json['contents'] as List<dynamic>?)
              ?.map((e) => PartnerContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PartnerStudioImplToJson(_$PartnerStudioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tagline': instance.tagline,
      if (instance.logoUrl case final value?) 'logoUrl': value,
      'contents': instance.contents.map((e) => e.toJson()).toList(),
    };
