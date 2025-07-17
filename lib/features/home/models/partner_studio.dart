// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'partner_content.dart';

part 'partner_studio.freezed.dart';
part 'partner_studio.g.dart';

@freezed
class PartnerStudio with _$PartnerStudio {
  const factory PartnerStudio({
    required String id,
    required String name,
    required String tagline,
    String? logoUrl,
    @JsonKey(ignore: true) Color? logoColor,
    @JsonKey(ignore: true) Color? backgroundColor,
    @JsonKey(ignore: true) IconData? icon,
    @Default([]) List<PartnerContent> contents,
  }) = _PartnerStudio;
  
  factory PartnerStudio.fromJson(Map<String, dynamic> json) => _$PartnerStudioFromJson(json);
  
  // Helper para configurar cores e ícone - não parte da serialização
  const PartnerStudio._();
  
  PartnerStudio withPresentation({
    required Color logoColor,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return copyWith(
      logoColor: logoColor,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }
} 