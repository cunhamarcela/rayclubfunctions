// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BenefitImpl _$$BenefitImplFromJson(Map<String, dynamic> json) =>
    _$BenefitImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      qrCodeUrl: json['qrCodeUrl'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      partner: json['partner'] as String,
      terms: json['terms'] as String?,
      type: $enumDecodeNullable(_$BenefitTypeEnumMap, json['type']) ??
          BenefitType.coupon,
      actionUrl: json['actionUrl'] as String?,
      pointsRequired: (json['pointsRequired'] as num).toInt(),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      availableQuantity: (json['availableQuantity'] as num).toInt(),
      termsAndConditions: json['termsAndConditions'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      promoCode: json['promoCode'] as String?,
      category: json['category'] as String? ?? '',
    );

Map<String, dynamic> _$$BenefitImplToJson(_$BenefitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      if (instance.qrCodeUrl case final value?) 'qrCodeUrl': value,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
      'partner': instance.partner,
      if (instance.terms case final value?) 'terms': value,
      'type': _$BenefitTypeEnumMap[instance.type]!,
      if (instance.actionUrl case final value?) 'actionUrl': value,
      'pointsRequired': instance.pointsRequired,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'availableQuantity': instance.availableQuantity,
      if (instance.termsAndConditions case final value?)
        'termsAndConditions': value,
      'isFeatured': instance.isFeatured,
      if (instance.promoCode case final value?) 'promoCode': value,
      'category': instance.category,
    };

const _$BenefitTypeEnumMap = {
  BenefitType.coupon: 'coupon',
  BenefitType.qrCode: 'qrCode',
  BenefitType.link: 'link',
};
