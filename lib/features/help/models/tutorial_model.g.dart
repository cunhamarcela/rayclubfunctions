// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorialImpl _$$TutorialImplFromJson(Map<String, dynamic> json) =>
    _$TutorialImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      category: json['category'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      updatedBy: json['updatedBy'] as String?,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      relatedContent:
          json['relatedContent'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$TutorialImplToJson(_$TutorialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'content': instance.content,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.videoUrl case final value?) 'videoUrl': value,
      'category': instance.category,
      'order': instance.order,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      if (instance.updatedBy case final value?) 'updatedBy': value,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'lastUpdated': value,
      'relatedContent': instance.relatedContent,
    };
