// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NutritionItemImpl _$$NutritionItemImplFromJson(Map<String, dynamic> json) =>
    _$NutritionItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      preparationTimeMinutes: (json['preparationTimeMinutes'] as num).toInt(),
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      nutritionistTip: json['nutritionistTip'] as String?,
    );

Map<String, dynamic> _$$NutritionItemImplToJson(_$NutritionItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'preparationTimeMinutes': instance.preparationTimeMinutes,
      if (instance.ingredients case final value?) 'ingredients': value,
      if (instance.instructions case final value?) 'instructions': value,
      'tags': instance.tags,
      if (instance.nutritionistTip case final value?) 'nutritionistTip': value,
    };
