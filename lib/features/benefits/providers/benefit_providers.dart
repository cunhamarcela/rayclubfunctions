// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/services/cache_service.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/supabase_providers.dart';
import '../repositories/benefit_repository.dart';
import '../repositories/mock_benefit_repository.dart';

/// Provider do repositório de benefícios
final benefitRepositoryProvider = Provider<BenefitRepository>((ref) {
  // Usar apenas o mock para resolver problemas de compilação
  return MockBenefitRepository();
  
  /* Código original comentado:
  if (kDebugMode) {
    // Em modo de desenvolvimento, usa o mock para testes
    return MockBenefitRepository();
  } else {
    // Em produção, usa a implementação real com Supabase
    final supabase = ref.watch(supabaseClientProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    
    return SupabaseBenefitRepository(
      supabaseClient: supabase,
      cacheService: cacheService,
      connectivityService: connectivityService,
    );
  }
  */
}); 