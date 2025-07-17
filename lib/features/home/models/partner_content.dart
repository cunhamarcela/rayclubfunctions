// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_content.freezed.dart';
part 'partner_content.g.dart';

@freezed
class PartnerContent with _$PartnerContent {
  const factory PartnerContent({
    required String id,
    required String title,
    required String duration,
    required String difficulty,
    required String imageUrl,
    String? studioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartnerContent;
  
  factory PartnerContent.fromJson(Map<String, dynamic> json) => _$PartnerContentFromJson(json);
} 