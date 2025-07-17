// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeemed_benefit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RedeemedBenefitImpl _$$RedeemedBenefitImplFromJson(
        Map<String, dynamic> json) =>
    _$RedeemedBenefitImpl(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      benefitId: json['benefitId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      code: json['code'] as String,
      status: $enumDecode(_$BenefitStatusEnumMap, json['status']),
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      redeemedAt: json['redeemedAt'] == null
          ? null
          : DateTime.parse(json['redeemedAt'] as String),
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      benefitTitle: json['benefitTitle'] as String?,
      partnerName: json['partnerName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      redemptionCode: json['redemptionCode'] as String?,
    );

Map<String, dynamic> _$$RedeemedBenefitImplToJson(
        _$RedeemedBenefitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.userId case final value?) 'userId': value,
      'benefitId': instance.benefitId,
      'title': instance.title,
      'description': instance.description,
      if (instance.logoUrl case final value?) 'logoUrl': value,
      'code': instance.code,
      'status': _$BenefitStatusEnumMap[instance.status]!,
      if (instance.expirationDate?.toIso8601String() case final value?)
        'expirationDate': value,
      if (instance.redeemedAt?.toIso8601String() case final value?)
        'redeemedAt': value,
      if (instance.usedAt?.toIso8601String() case final value?) 'usedAt': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
      if (instance.benefitTitle case final value?) 'benefitTitle': value,
      if (instance.partnerName case final value?) 'partnerName': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.metadata case final value?) 'metadata': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      if (instance.redemptionCode case final value?) 'redemptionCode': value,
    };

const _$BenefitStatusEnumMap = {
  BenefitStatus.active: 'active',
  BenefitStatus.used: 'used',
  BenefitStatus.expired: 'expired',
  BenefitStatus.cancelled: 'cancelled',
};
