// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutVideoImpl _$$WorkoutVideoImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutVideoImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: json['duration'] as String,
      youtubeUrl: json['youtube_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: json['category'] as String,
      instructorName: json['instructor_name'] as String?,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      orderIndex: (json['order_index'] as num?)?.toInt(),
      isNew: json['is_new'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      isRecommended: json['is_recommended'] as bool? ?? false,
      requiresExpertAccess: json['requires_expert_access'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      hasPdfMaterials: json['has_pdf_materials'] as bool? ?? false,
      subcategory: json['subcategory'] as String?,
    );

Map<String, dynamic> _$$WorkoutVideoImplToJson(_$WorkoutVideoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
      if (instance.youtubeUrl case final value?) 'youtube_url': value,
      if (instance.thumbnailUrl case final value?) 'thumbnail_url': value,
      'category': instance.category,
      if (instance.instructorName case final value?) 'instructor_name': value,
      if (instance.description case final value?) 'description': value,
      if (instance.difficulty case final value?) 'difficulty': value,
      if (instance.orderIndex case final value?) 'order_index': value,
      'is_new': instance.isNew,
      'is_popular': instance.isPopular,
      'is_recommended': instance.isRecommended,
      'requires_expert_access': instance.requiresExpertAccess,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
      'has_pdf_materials': instance.hasPdfMaterials,
      if (instance.subcategory case final value?) 'subcategory': value,
    };
