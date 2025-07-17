import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../../../core/providers/providers.dart' as core_providers;

/// Provider que fornece o perfil atual do usuário autenticado
/// ✅ Modificado para forçar recarregamento sempre que necessário
final currentProfileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  debugPrint('🔍 currentProfileProvider - Iniciando carregamento...');
  
  final authState = ref.watch(authViewModelProvider);
  
  // Se o usuário não estiver autenticado, retorna null
  final user = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (user == null) {
    debugPrint('⚠️ currentProfileProvider - Usuário não autenticado');
    return null;
  }
  
  debugPrint('👤 currentProfileProvider - User ID: ${user.id}');
  
  // Buscar o perfil do usuário do repositório
  final profileRepository = ref.watch(core_providers.profileRepositoryProvider);
  
  try {
    final profile = await profileRepository.getProfileById(user.id);
    
    if (profile != null) {
      debugPrint('✅ currentProfileProvider - Perfil carregado:');
      debugPrint('   - Nome: "${profile.name}"');
      debugPrint('   - Email: "${profile.email}"');
      debugPrint('   - Telefone: "${profile.phone}"');
      debugPrint('   - Instagram: "${profile.instagram}"');
      debugPrint('   - Gênero: "${profile.gender}"');
    } else {
      debugPrint('⚠️ currentProfileProvider - Perfil não encontrado');
    }
    
    return profile;
  } catch (e, stackTrace) {
    debugPrint('❌ currentProfileProvider - Erro ao carregar perfil: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

/// Provider que disponibiliza a stream de atualizações do perfil atual
final currentProfileStreamProvider = StreamProvider.autoDispose<Profile?>((ref) {
  debugPrint('🔍 currentProfileStreamProvider - Iniciando stream...');
  
  final authState = ref.watch(authViewModelProvider);
  
  // Se o usuário não estiver autenticado, retorna stream vazia
  final user = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (user == null) {
    debugPrint('⚠️ currentProfileStreamProvider - Usuário não autenticado');
    return Stream.value(null);
  }
  
  debugPrint('👤 currentProfileStreamProvider - User ID: ${user.id}');
  
  // Buscar o perfil do repositório como stream
  // Nota: Isso requer implementação de uma stream no repositório
  // Por enquanto, vamos simular com uma stream que emite apenas o valor atual
  final profileRepository = ref.watch(core_providers.profileRepositoryProvider);
  
  return Stream.fromFuture(profileRepository.getProfileById(user.id))
      .where((profile) => profile != null)
      .map((profile) {
        if (profile != null) {
          debugPrint('✅ currentProfileStreamProvider - Profile emitido via stream');
        }
        return profile;
      });
});

/// Provider que disponibiliza o nome de exibição do usuário atual
/// ✅ Modificado para recarregar automaticamente
final userDisplayNameProvider = Provider.autoDispose<String>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  
  final result = profileAsync.when(
    data: (profile) {
      final name = profile?.name ?? 'Usuário';
      debugPrint('📋 userDisplayNameProvider - Nome: "$name"');
      return name;
    },
    loading: () {
      debugPrint('🔄 userDisplayNameProvider - Carregando...');
      return 'Carregando...';
    },
    error: (error, _) {
      debugPrint('❌ userDisplayNameProvider - Erro: $error');
      return 'Usuário';
    },
  );
  
  return result;
});

/// Provider que disponibiliza a URL da foto do usuário atual
/// ✅ Modificado para recarregar automaticamente
final userPhotoUrlProvider = Provider.autoDispose<String?>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  
  final result = profileAsync.when(
    data: (profile) {
      final photoUrl = profile?.photoUrl;
      debugPrint('📋 userPhotoUrlProvider - Photo URL: "$photoUrl"');
      return photoUrl;
    },
    loading: () {
      debugPrint('🔄 userPhotoUrlProvider - Carregando...');
      return null;
    },
    error: (error, _) {
      debugPrint('❌ userPhotoUrlProvider - Erro: $error');
      return null;
    },
  );
  
  return result;
});

/// Provider para forçar refresh do perfil
/// ✅ Novo provider para forçar recarregamento
final profileRefreshProvider = StateProvider<int>((ref) => 0);

/// Provider que força refresh do currentProfileProvider
final currentProfileRefreshableProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  // Escutar mudanças no refresh provider
  ref.watch(profileRefreshProvider);
  
  debugPrint('🔄 currentProfileRefreshableProvider - Forçando refresh...');
  
  // Usar o mesmo logic do currentProfileProvider mas sempre recarregando
  final authState = ref.read(authViewModelProvider);
  
  final user = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (user == null) {
    debugPrint('⚠️ currentProfileRefreshableProvider - Usuário não autenticado');
    return null;
  }
  
  final profileRepository = ref.read(core_providers.profileRepositoryProvider);
  
  try {
    // Sempre buscar dados frescos do banco
    final profile = await profileRepository.getCurrentUserProfile();
    
    if (profile != null) {
      debugPrint('✅ currentProfileRefreshableProvider - Perfil refresh carregado:');
      debugPrint('   - Nome: "${profile.name}"');
      debugPrint('   - Telefone: "${profile.phone}"');
      debugPrint('   - Instagram: "${profile.instagram}"');
      debugPrint('   - Gênero: "${profile.gender}"');
    }
    
    return profile;
  } catch (e) {
    debugPrint('❌ currentProfileRefreshableProvider - Erro: $e');
    rethrow;
  }
});

/// Método utilitário para forçar refresh do perfil
void forceProfileRefresh(WidgetRef ref) {
  debugPrint('🔄 Forçando refresh completo do perfil...');
  
  // Incrementar contador de refresh
  ref.read(profileRefreshProvider.notifier).state++;
  
  // Invalidar todos os providers relacionados
  ref.invalidate(currentProfileProvider);
  ref.invalidate(currentProfileStreamProvider);
  ref.invalidate(userDisplayNameProvider);
  ref.invalidate(userPhotoUrlProvider);
  
  debugPrint('✅ Refresh do perfil executado');
} 