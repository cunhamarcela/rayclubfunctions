import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/subscription_repository.dart';
import '../models/subscription_status.dart';
import '../viewmodels/subscription_viewmodel.dart';
import '../../../core/providers/providers.dart';

/// Provider para o repository de acesso do usuário
final userAccessRepositoryProvider = Provider<UserAccessRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserAccessRepository(supabase);
});

/// Provider para o ViewModel de acesso do usuário
final userAccessViewModelProvider = StateNotifierProvider<UserAccessViewModel, UserAccessState>((ref) {
  final repository = ref.watch(userAccessRepositoryProvider);
  return UserAccessViewModel(repository);
});

/// Provider que retorna o nível de acesso atual do usuário logado
final currentUserAccessProvider = FutureProvider<UserAccessStatus>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }
  
  final viewModel = ref.watch(userAccessViewModelProvider.notifier);
  return await viewModel.getUserAccessLevel(user.id);
});

/// Provider que verifica se uma feature específica está disponível
final featureAccessProvider = Provider.family<AsyncValue<bool>, String>((ref, featureKey) {
  final userAccess = ref.watch(currentUserAccessProvider);
  
  return userAccess.when(
    data: (status) => AsyncValue.data(status.hasAccess(featureKey)),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.data(false), // Falha segura
  );
});

/// Provider simples para verificação rápida de acesso avançado
final hasAdvancedAccessProvider = Provider<bool>((ref) {
  final userAccess = ref.watch(currentUserAccessProvider);
  
  return userAccess.when(
    data: (status) => status.isAccessValid && status.hasExtendedAccess,
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// Provider para configuração de segurança
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig();
});

/// Classe de configuração da aplicação
class AppConfig {
  /// Verifica se o sistema de gates está habilitado
  /// Pode ser desabilitado remotamente em caso de problemas
  bool get progressGatesEnabled {
    // TODO: Implementar Firebase Remote Config ou similar
    // Por enquanto, sempre habilitado
    return true;
  }
  
  /// Modo seguro - mostra todo conteúdo liberado
  bool get safeMode {
    // TODO: Implementar controle via remote config
    return false;
  }
}

/// NOVO: Provider que verifica se o usuário pode VER conteúdos de parceiros (todos podem)
final canViewPartnerContentProvider = Provider<bool>((ref) {
  // Todos os usuários autenticados podem VER os conteúdos
  final user = Supabase.instance.client.auth.currentUser;
  return user != null;
});

/// NOVO: Provider que verifica se o usuário evoluiu o suficiente para INTERAGIR com conteúdos
final hasEvolvedEnoughProvider = Provider<bool>((ref) {
  final userAccess = ref.watch(currentUserAccessProvider);
  
  return userAccess.when(
    data: (status) => status.isAccessValid && status.hasExtendedAccess,
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// NOVO: Provider que determina se deve mostrar indicador de evolução
final shouldShowEvolutionIndicatorProvider = Provider<bool>((ref) {
  final canView = ref.watch(canViewPartnerContentProvider);
  final hasEvolved = ref.watch(hasEvolvedEnoughProvider);
  
  // Mostra indicador se pode ver mas ainda não evoluiu o suficiente
  return canView && !hasEvolved;
});

/// NOVO: Provider para verificação rápida se usuário é EXPERT
/// Usado pelos players de YouTube para bloquear acesso
final isExpertUserProvider = FutureProvider<bool>((ref) async {
  try {
    final userAccess = await ref.read(currentUserAccessProvider.future);
    
    // Verificação rigorosa: deve ser expert com acesso válido
    final isExpert = userAccess.isExpert && userAccess.isAccessValid;
    final hasVideoLibraryAccess = userAccess.hasAccess('workout_library');
    
    return isExpert && hasVideoLibraryAccess;
  } catch (e) {
    // Em caso de erro, nega acesso por segurança
    return false;
  }
}); 