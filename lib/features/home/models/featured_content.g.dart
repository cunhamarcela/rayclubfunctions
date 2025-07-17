// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'featured_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeaturedContentImpl _$$FeaturedContentImplFromJson(
        Map<String, dynamic> json) =>
    _$FeaturedContentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category:
          ContentCategory.fromJson(json['category'] as Map<String, dynamic>),
      icon: const IconDataConverter().fromJson(json['icon'] as String),
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      isFeatured: json['isFeatured'] as bool? ?? false,
    );

Map<String, dynamic> _$$FeaturedContentImplToJson(
        _$FeaturedContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category.toJson(),
      'icon': const IconDataConverter().toJson(instance.icon),
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.actionUrl case final value?) 'actionUrl': value,
      if (instance.publishedAt?.toIso8601String() case final value?)
        'publishedAt': value,
      'isFeatured': instance.isFeatured,
    };

_$ContentCategoryImpl _$$ContentCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ContentCategoryImpl(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      colorHex: json['colorHex'] as String?,
    );

Map<String, dynamic> _$$ContentCategoryImplToJson(
        _$ContentCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.colorHex case final value?) 'colorHex': value,
    };
