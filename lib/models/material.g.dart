// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaterialImpl _$$MaterialImplFromJson(Map<String, dynamic> json) =>
    _$MaterialImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      materialType: $enumDecode(_$MaterialTypeEnumMap, json['material_type']),
      materialContext:
          $enumDecode(_$MaterialContextEnumMap, json['material_context']),
      filePath: json['file_path'] as String,
      fileSize: (json['file_size'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      authorName: json['author_name'] as String?,
      workoutVideoId: json['workout_video_id'] as String?,
      orderIndex: (json['order_index'] as num?)?.toInt(),
      isFeatured: json['is_featured'] as bool? ?? false,
      requiresExpertAccess: json['requires_expert_access'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$MaterialImplToJson(_$MaterialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'material_type': _$MaterialTypeEnumMap[instance.materialType]!,
      'material_context': _$MaterialContextEnumMap[instance.materialContext]!,
      'file_path': instance.filePath,
      if (instance.fileSize case final value?) 'file_size': value,
      if (instance.thumbnailUrl case final value?) 'thumbnail_url': value,
      if (instance.authorName case final value?) 'author_name': value,
      if (instance.workoutVideoId case final value?) 'workout_video_id': value,
      if (instance.orderIndex case final value?) 'order_index': value,
      'is_featured': instance.isFeatured,
      'requires_expert_access': instance.requiresExpertAccess,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };

const _$MaterialTypeEnumMap = {
  MaterialType.pdf: 'pdf',
  MaterialType.ebook: 'ebook',
  MaterialType.guide: 'guide',
  MaterialType.document: 'document',
};

const _$MaterialContextEnumMap = {
  MaterialContext.workout: 'workout',
  MaterialContext.nutrition: 'nutrition',
  MaterialContext.general: 'general',
};
