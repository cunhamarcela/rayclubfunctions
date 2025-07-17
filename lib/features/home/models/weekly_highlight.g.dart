// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_highlight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyHighlightImpl _$$WeeklyHighlightImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyHighlightImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: const IconDataConverter().fromJson(json['icon'] as String),
      color: const ColorConverter().fromJson(json['color'] as String),
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      artImage: json['artImage'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      tagline: json['tagline'] as String?,
      actionRoute: json['actionRoute'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$WeeklyHighlightImplToJson(
        _$WeeklyHighlightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': const IconDataConverter().toJson(instance.icon),
      'color': const ColorConverter().toJson(instance.color),
      if (instance.subtitle case final value?) 'subtitle': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.artImage case final value?) 'artImage': value,
      if (instance.price case final value?) 'price': value,
      if (instance.tagline case final value?) 'tagline': value,
      if (instance.actionRoute case final value?) 'actionRoute': value,
      'isFeatured': instance.isFeatured,
      if (instance.startDate?.toIso8601String() case final value?)
        'startDate': value,
      if (instance.endDate?.toIso8601String() case final value?)
        'endDate': value,
    };
