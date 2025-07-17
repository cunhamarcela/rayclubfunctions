import 'package:ray_club_app/core/utils/model_mapper.dart';
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';

/// Mapper para conversão entre dados do Supabase e modelo Benefit
/// 
/// Necessário para:
/// 1. Converter campos snake_case para camelCase
/// 2. Mapear enums de texto para BenefitType
/// 3. Garantir valores padrão seguros para campos nulos
class BenefitMapper {
  /// Converte dados do Supabase para o modelo Benefit
  static Benefit fromSupabase(Map<String, dynamic> json) {
    // Primeiro tenta usar o fromJson padrão do Freezed
    try {
      // Pré-processamento para campos problemáticos
      final processedJson = {
        ...json,
        // Converter tipo de texto para enum
        'type': _parseBenefitType(json['type']).toString().split('.').last,
        // Converter snake_case para camelCase
        'imageUrl': json['image_url'] ?? '',
        'qrCodeUrl': json['qr_code_url'],
        'expiresAt': json['expires_at'],
        'actionUrl': json['action_url'],
        'pointsRequired': json['points_required'] ?? 0,
        'expirationDate': json['expiration_date'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'availableQuantity': json['available_quantity'] ?? 0,
        'termsAndConditions': json['terms_and_conditions'],
        'isFeatured': json['is_featured'] ?? false,
        'promoCode': json['promo_code'],
      };
      
      return Benefit.fromJson(processedJson);
    } 
    // Se falhar, usa abordagem manual mais robusta
    catch (e) {
      return Benefit(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['image_url'] ?? '',
        qrCodeUrl: json['qr_code_url'],
        expiresAt: _parseDateTime(json['expires_at']),
        partner: json['partner'] ?? '',
        terms: json['terms'],
        type: _parseBenefitType(json['type']),
        actionUrl: json['action_url'],
        pointsRequired: _parseInt(json['points_required']) ?? 0,
        expirationDate: _parseDateTime(json['expiration_date']) ?? 
            DateTime.now().add(const Duration(days: 30)),
        availableQuantity: _parseInt(json['available_quantity']) ?? 0,
        termsAndConditions: json['terms_and_conditions'],
        isFeatured: json['is_featured'] == true,
        promoCode: json['promo_code'],
        category: json['category'] ?? '',
      );
    }
  }
  
  /// Determina se um JSON precisa de mapper personalizado
  static bool needsMapper(Map<String, dynamic> json) {
    // Verificar se contém campos em snake_case ou tipo que precise de conversão
    return json.containsKey('image_url') || 
           json.containsKey('qr_code_url') ||
           json.containsKey('type') ||
           json.containsKey('points_required');
  }
  
  /// Converte string para o enum BenefitType
  static BenefitType _parseBenefitType(dynamic value) {
    if (value == null) return BenefitType.coupon;
    if (value is BenefitType) return value;
    
    final typeStr = value.toString().toLowerCase();
    
    switch (typeStr) {
      case 'coupon': return BenefitType.coupon;
      case 'qrcode':
      case 'qr_code':
      case 'qr': return BenefitType.qrCode;
      case 'link':
      case 'url':
      case 'web': return BenefitType.link;
      default: return BenefitType.coupon;
    }
  }
  
  /// Converte string para DateTime de forma segura
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    
    try {
      if (value is String) return DateTime.parse(value);
      if (value is int) {
        // Timestamp em segundos ou milissegundos
        return value > 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    } catch (_) {
      return null;
    }
    
    return null;
  }
  
  /// Converte para int de forma segura
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
  
  /// Mapeia o modelo Benefit para o formato do Supabase
  static Map<String, dynamic> toSupabase(Benefit benefit) {
    final map = <String, dynamic>{
      'id': benefit.id,
      'title': benefit.title,
      'description': benefit.description,
      'image_url': benefit.imageUrl,
      'qr_code_url': benefit.qrCodeUrl,
      'partner': benefit.partner,
      'terms': benefit.terms,
      'type': benefit.type.toString().split('.').last,
      'action_url': benefit.actionUrl,
      'points_required': benefit.pointsRequired,
      'expiration_date': benefit.expirationDate.toIso8601String(),
      'available_quantity': benefit.availableQuantity,
      'terms_and_conditions': benefit.termsAndConditions,
      'is_featured': benefit.isFeatured,
      'promo_code': benefit.promoCode,
      'category': benefit.category,
    };
    
    if (benefit.expiresAt != null) {
      map['expires_at'] = benefit.expiresAt!.toIso8601String();
    }
    
    return map;
  }
} 