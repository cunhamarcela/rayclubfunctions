// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      preparationTimeMinutes: (json['preparation_time_minutes'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      servings: (json['servings'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      rating: (json['rating'] as num).toDouble(),
      contentType:
          $enumDecode(_$RecipeContentTypeEnumMap, json['content_type']),
      authorName: json['author_name'] as String,
      isFeatured: json['is_featured'] as bool,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nutritionistTip: json['nutritionist_tip'] as String?,
      videoUrl: json['video_url'] as String?,
      videoId: json['video_id'] as String?,
      videoDuration: (json['video_duration'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      servingsText: json['servings_text'] as String?,
      preparationTimeText: json['preparation_time_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'preparation_time_minutes': instance.preparationTimeMinutes,
      'calories': instance.calories,
      'servings': instance.servings,
      'difficulty': instance.difficulty,
      'rating': instance.rating,
      'content_type': _$RecipeContentTypeEnumMap[instance.contentType]!,
      'author_name': instance.authorName,
      'is_featured': instance.isFeatured,
      if (instance.ingredients case final value?) 'ingredients': value,
      if (instance.instructions case final value?) 'instructions': value,
      if (instance.nutritionistTip case final value?) 'nutritionist_tip': value,
      if (instance.videoUrl case final value?) 'video_url': value,
      if (instance.videoId case final value?) 'video_id': value,
      if (instance.videoDuration case final value?) 'video_duration': value,
      'tags': instance.tags,
      if (instance.servingsText case final value?) 'servings_text': value,
      if (instance.preparationTimeText case final value?)
        'preparation_time_text': value,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$RecipeContentTypeEnumMap = {
  RecipeContentType.text: 'text',
  RecipeContentType.video: 'video',
};
