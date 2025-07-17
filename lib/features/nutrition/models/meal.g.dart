// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      calories: (json['calories'] as num).toInt(),
      proteins: (json['proteins'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dateTime': instance.dateTime.toIso8601String(),
      'calories': instance.calories,
      'proteins': instance.proteins,
      'carbs': instance.carbs,
      'fats': instance.fats,
      if (instance.notes case final value?) 'notes': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      'isFavorite': instance.isFavorite,
      'tags': instance.tags,
    };
