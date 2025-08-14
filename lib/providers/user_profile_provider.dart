import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/models/profile_model.dart';
import '../features/profile/repositories/profile_repository.dart';
import '../features/profile/repositories/supabase_profile_repository.dart';
import 'package:flutter/foundation.dart';

/// Provider que expõe a instância do SupabaseClient
/// Permite mockar o cliente Supabase inteiro nos testes
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider que expõe a implementação do repositório de perfil
/// Permite trocar a implementação para testes ou outras fontes de dados
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // ✅ Depende do supabaseClientProvider para ser testável
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(client);
});

/// Provider global que carrega o perfil do usuário com accountType
/// ✅ Segue o padrão do guia: carrega uma única vez após login
/// ✅ CORRIGIDO: Usa repository em vez de Profile.fromJson() que estava falhando
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  // ✅ Depende do supabaseClientProvider para ser testável
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  debugPrint('🔍 [userProfileProvider] ========== CARREGANDO PERFIL ==========');
  debugPrint('🔍 [userProfileProvider] User ID: $userId');
  debugPrint('🔍 [userProfileProvider] Timestamp: ${DateTime.now()}');
  
  if (userId == null) {
    debugPrint('🔍 [userProfileProvider] ❌ User ID é null - retornando null');
    return null;
  }

  try {
    // ✅ Usar o provider do repositório para permitir mocking
    final repository = ref.watch(profileRepositoryProvider);
    debugPrint('🔍 [userProfileProvider] Repository lido do provider, buscando perfil...');
    
    final profile = await repository.getProfileById(userId);
    debugPrint('🔍 [userProfileProvider] ========== PERFIL CARREGADO ==========');
    debugPrint('🔍 [userProfileProvider] Profile: $profile');
    debugPrint('🔍 [userProfileProvider] Account Type: ${profile?.accountType}');
    debugPrint('🔍 [userProfileProvider] Account Type runtimeType: ${profile?.accountType.runtimeType}');
    debugPrint('🔍 [userProfileProvider] ID: ${profile?.id}');
    debugPrint('🔍 [userProfileProvider] Name: ${profile?.name}');
    debugPrint('🔍 [userProfileProvider] Email: ${profile?.email}');
    debugPrint('🔍 [userProfileProvider] ===========================================');
    
    return profile;
  } catch (e, stackTrace) {
    debugPrint('🔍 [userProfileProvider] ❌ ERRO ao carregar perfil: $e');
    debugPrint('🔍 [userProfileProvider] StackTrace: $stackTrace');
    rethrow;
  }
});

/// Provider derivado que transforma o perfil em valor booleano expert
/// ✅ Segue o padrão do guia: provider derivado para isExpert
/// ⚠️ IMPORTANTE: Retorna AsyncValue para tratar loading corretamente
final isExpertUserProfileProvider = Provider<AsyncValue<bool>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  
  debugPrint('🔍 [isExpertUserProfileProvider] ========== VERIFICANDO EXPERT ==========');
  debugPrint('🔍 [isExpertUserProfileProvider] profileAsync.runtimeType: ${profileAsync.runtimeType}');
  debugPrint('🔍 [isExpertUserProfileProvider] profileAsync: $profileAsync');

  return profileAsync.when(
    data: (profile) {
      debugPrint('🔍 [isExpertUserProfileProvider] ========== PROCESSANDO DADOS ==========');
      debugPrint('🔍 [isExpertUserProfileProvider] Profile carregado: $profile');
      debugPrint('🔍 [isExpertUserProfileProvider] Account Type: ${profile?.accountType}');
      debugPrint('🔍 [isExpertUserProfileProvider] Account Type runtimeType: ${profile?.accountType.runtimeType}');
      
      // ✅ VALIDAÇÃO EXTRA: Se accountType for null, tratar como 'basic'
      final accountType = profile?.accountType ?? 'basic';
      final isExpert = accountType == 'expert';
      
      debugPrint('🔍 [isExpertUserProfileProvider] accountType original: ${profile?.accountType}');
      debugPrint('🔍 [isExpertUserProfileProvider] accountType final: $accountType');
      debugPrint('🔍 [isExpertUserProfileProvider] isExpert calculado: $isExpert');
      debugPrint('🔍 [isExpertUserProfileProvider] isExpert runtimeType: ${isExpert.runtimeType}');
      debugPrint('🔍 [isExpertUserProfileProvider] Comparação: "$accountType" == "expert" = $isExpert');
      debugPrint('🔍 [isExpertUserProfileProvider] Comparação strict: ${accountType.toLowerCase() == 'expert'}');
      
      // ✅ FAIL-SAFE ADICIONAL: Se profile for null, sempre basic
      if (profile == null) {
        debugPrint('🔍 [isExpertUserProfileProvider] ⚠️ Profile é null - retornando false');
        final result = AsyncValue.data(false);
        debugPrint('🔍 [isExpertUserProfileProvider] AsyncValue.data criado: $result');
        debugPrint('🔍 [isExpertUserProfileProvider] =============================================');
        return result;
      }
      
      final result = AsyncValue.data(isExpert);
      debugPrint('🔍 [isExpertUserProfileProvider] AsyncValue.data criado: $result');
      debugPrint('🔍 [isExpertUserProfileProvider] =============================================');
      return result;
    },
    loading: () {
      debugPrint('🔍 [isExpertUserProfileProvider] ⏳ Loading...');
      return const AsyncValue.loading();
    },
    error: (error, stack) {
      debugPrint('🔍 [isExpertUserProfileProvider] ❌ Erro: $error');
      debugPrint('🔍 [isExpertUserProfileProvider] Stack: $stack');
      return AsyncValue.error(error, stack);
    },
  );
}); 