// Project imports:
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';

/// Interface para acesso às operações de benefícios
abstract class BenefitRepository {
  /// Recupera todos os benefícios disponíveis
  Future<List<Benefit>> getBenefits();
  
  /// Recupera um benefício pelo ID
  Future<Benefit?> getBenefitById(String id);
  
  /// Recupera as categorias de benefícios (parceiros)
  Future<List<String>> getBenefitCategories();
  
  /// Recupera benefícios por categoria
  Future<List<Benefit>> getBenefitsByCategory(String category);
  
  /// Verifica se o usuário tem pontos suficientes para resgatar um benefício
  Future<bool> hasEnoughPoints(String benefitId);
  
  /// Resgata um benefício
  Future<RedeemedBenefit> redeemBenefit(String benefitId);
  
  /// Obtém benefícios resgatados pelo usuário logado
  Future<List<RedeemedBenefit>> getRedeemedBenefits();
  
  /// Obtém detalhe de um benefício resgatado pelo ID
  Future<RedeemedBenefit?> getRedeemedBenefitById(String id);
  
  /// Marca um benefício como utilizado
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId);
  
  /// Cancela um benefício resgatado
  Future<void> cancelRedeemedBenefit(String redeemedBenefitId);
  
  /// Usa um benefício resgatado
  Future<RedeemedBenefit?> useBenefit(String redeemedBenefitId);
  
  /// Atualiza o status de um benefício
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, BenefitStatus newStatus);
  
  /// Verifica se o usuário é administrador
  Future<bool> isAdmin();
  
  /// Obtém todos os benefícios resgatados (somente admin)
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits();
  
  /// Atualiza a data de expiração de um benefício
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate);
  
  /// Estende a validade de um benefício resgatado
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate);
  
  /// Obtém benefícios em destaque
  Future<List<Benefit>> getFeaturedBenefits();
  
  /// Gera código de resgate
  Future<String> generateRedemptionCode({
    required String userId,
    required String benefitId,
  });
  
  /// Verifica código de resgate
  Future<bool> verifyRedemptionCode({
    required String redemptionCode,
    required String benefitId,
  });
} 
