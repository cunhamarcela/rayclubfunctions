// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaqImpl _$$FaqImplFromJson(Map<String, dynamic> json) => _$FaqImpl(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      updatedBy: json['updatedBy'] as String?,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$FaqImplToJson(_$FaqImpl instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
      'isActive': instance.isActive,
      if (instance.updatedBy case final value?) 'updatedBy': value,
      if (instance.lastUpdated?.toIso8601String() case final value?)
        'lastUpdated': value,
    };
