// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/core/services/connectivity_service.dart';
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';
import 'benefit_repository.dart';
import 'mock_benefit_repository.dart';

/// Provider para o repositório de benefícios
final benefitsRepositoryProvider = Provider<BenefitRepository>((ref) {
  // Usar apenas o mock para resolver problemas de compilação
  return MockBenefitRepository();
  
  /* Código original comentado:
  final supabase = ref.watch(supabaseClientProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return SupabaseBenefitRepository(
    supabaseClient: supabase,
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
  */
});

/// Interface para acesso às operações de benefícios
abstract class BenefitsRepository {
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
  
  /// Usa um benefício resgatado
  Future<RedeemedBenefit?> useBenefit(String redeemedBenefitId);
  
  /// Atualiza o status de um benefício
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, BenefitStatus newStatus);
  
  /// Verifica se o usuário é administrador
  Future<bool> isAdmin();
  
  /// Obtém todos os benefícios resgatados (somente admin)
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits();
  
  /// Atualiza a data de expiração de um benefício
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime newExpirationDate);
  
  /// Estende a validade de um benefício resgatado
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime newExpirationDate);
} 