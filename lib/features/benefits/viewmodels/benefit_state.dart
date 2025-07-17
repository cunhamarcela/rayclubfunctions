// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';

part 'benefit_state.freezed.dart';

/// Estado para gerenciamento de benefícios
@freezed
class BenefitState with _$BenefitState {
  const factory BenefitState({
    /// Lista de todos os benefícios disponíveis
    @Default([]) List<Benefit> benefits,
    
    /// Lista de benefícios resgatados pelo usuário
    @Default([]) List<RedeemedBenefit> redeemedBenefits,
    
    /// Lista de categorias de benefícios
    @Default([]) List<String> categories,
    
    /// Categoria atualmente selecionada para filtro
    String? selectedCategory,
    
    /// Benefício selecionado para visualização detalhada
    Benefit? selectedBenefit,
    
    /// Benefício resgatado selecionado para visualização
    RedeemedBenefit? selectedRedeemedBenefit,
    
    /// Pontos disponíveis do usuário
    int? userPoints,
    
    /// Indica se está carregando dados
    @Default(false) bool isLoading,
    
    /// Mensagem de erro, se houver
    String? errorMessage,
    
    /// Mensagem de sucesso, se houver
    String? successMessage,
    
    /// Indica se está em processo de resgate
    @Default(false) bool isRedeeming,
    
    /// Benefício que está sendo resgatado atualmente
    Benefit? benefitBeingRedeemed,
    
    /// Dados do QR code gerado
    String? qrCodeData,
    
    /// Data/hora de expiração do QR code
    DateTime? qrCodeExpiresAt,
  }) = _BenefitState;
} 
