// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../enums/benefit_type.dart';

part 'benefit.freezed.dart';
part 'benefit.g.dart';

/// Model representing a benefit or coupon
@freezed
class Benefit with _$Benefit {
  const factory Benefit({
    /// Identificador único do benefício
    required String id,
    
    /// Título do benefício
    required String title,
    
    /// Descrição detalhada do benefício
    required String description,
    
    /// URL da imagem que representa o benefício
    @Default('') String imageUrl,
    
    /// URL do QR Code do benefício (opcional)
    String? qrCodeUrl,
    
    /// Data de expiração do benefício (opcional)
    DateTime? expiresAt,
    
    /// Empresa ou marca parceira que fornece o benefício
    required String partner,
    
    /// Termos e condições para uso do benefício
    String? terms,
    
    /// Tipo do benefício
    @Default(BenefitType.coupon) BenefitType type,
    
    /// URL de ação associada ao benefício
    String? actionUrl,
    
    /// Quantidade de pontos necessários para resgatar o benefício
    required int pointsRequired,
    
    /// Data de expiração do benefício
    required DateTime expirationDate,
    
    /// Quantidade disponível do benefício
    required int availableQuantity,
    
    /// Termos e condições detalhados para uso do benefício
    String? termsAndConditions,
    
    /// Indica se o benefício está em destaque
    @Default(false) bool isFeatured,
    
    /// Código promocional associado ao benefício
    String? promoCode,
    
    /// Categoria do benefício
    @Default('') String category,
  }) = _Benefit;

  /// Cria um benefício a partir de JSON
  factory Benefit.fromJson(Map<String, dynamic> json) => _$BenefitFromJson(json);
  
  /// Cria um benefício vazio com valores padrão
  factory Benefit.empty() => Benefit(
    id: '',
    title: '',
    description: '',
    partner: '',
    pointsRequired: 0,
    expirationDate: DateTime.now().add(const Duration(days: 30)),
    availableQuantity: 0,
  );
} 
