/// Tipos de benefícios disponíveis no aplicativo
enum BenefitType {
  /// Cupom de desconto ou oferta especial
  coupon,
  
  /// Código QR para uso em lojas físicas
  qrCode,
  
  /// Link para acesso a conteúdo ou benefício online
  link
}

/// Status dos benefícios resgatados
enum BenefitStatus {
  active,
  used,
  expired,
  cancelled,
}

// Para compatibilidade com código existente
typedef RedemptionStatus = BenefitStatus; 