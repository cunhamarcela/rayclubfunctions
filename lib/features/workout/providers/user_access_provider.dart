import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/workout/repositories/workout_videos_repository.dart';
import 'package:flutter/foundation.dart';

/// Provider para obter o nível do usuário atual
final userLevelProvider = FutureProvider<String>((ref) async {
  print('🔍 [userLevelProvider] ========== INICIANDO VERIFICAÇÃO ==========');
  
  try {
    final repository = ref.read(workoutVideosRepositoryProvider);
    print('🔍 [userLevelProvider] Repository obtido com sucesso');
    
    final level = await repository.getCurrentUserLevel();
    print('🔍 [userLevelProvider] ✅ Nível obtido do banco: "$level"');
    
    return level;
  } catch (e, stackTrace) {
    print('❌ [userLevelProvider] ERRO ao obter nível: $e');
    print('❌ [userLevelProvider] Stack trace: $stackTrace');
    return 'basic'; // Fallback seguro
  }
});

/// Provider para verificar se usuário é expert
final isExpertUserProvider = FutureProvider<bool>((ref) async {
  print('🔍 [isExpertUserProvider] ========== VERIFICAÇÃO EXPERT ==========');
  
  try {
    final userLevel = await ref.watch(userLevelProvider.future);
    print('🔍 [isExpertUserProvider] Nível recebido: "$userLevel"');
    
    // ⚠️ VERIFICAÇÃO RIGOROSA: apenas 'expert' exato retorna true
    final isExpert = userLevel == 'expert';
    print('🔍 [isExpertUserProvider] Comparação: "$userLevel" == "expert" = $isExpert');
    
    if (isExpert) {
      print('✅ [isExpertUserProvider] 🌟 USUÁRIO É EXPERT! 🌟');
    } else {
      print('❌ [isExpertUserProvider] ⚠️ USUÁRIO É BASIC ⚠️');
    }
    
    return isExpert;
  } catch (e) {
    print('❌ [isExpertUserProvider] ERRO na verificação: $e');
    // ⚠️ ERRO = NÃO É EXPERT
    print('❌ [isExpertUserProvider] ⚠️ ERRO = BASIC (fail-safe) ⚠️');
    return false;
  }
});

/// Provider para verificar se usuário pode acessar um vídeo específico
final canAccessVideoProvider = FutureProvider.family<bool, String>((ref, videoId) async {
  try {
    final repository = ref.watch(workoutVideosRepositoryProvider);
    final canAccess = await repository.canUserAccessVideoLink(videoId);
    // ⚠️ DEVE RETORNAR TRUE EXPLICITAMENTE
    return canAccess == true;
  } catch (e) {
    // ⚠️ ERRO = SEM ACESSO
    return false;
  }
});

/// State notifier para controlar o estado de acesso
class UserAccessState {
  final String userLevel;
  final bool isExpert;
  final Map<String, bool> videoAccess;

  const UserAccessState({
    required this.userLevel,
    required this.isExpert,
    required this.videoAccess,
  });

  UserAccessState copyWith({
    String? userLevel,
    bool? isExpert,
    Map<String, bool>? videoAccess,
  }) {
    return UserAccessState(
      userLevel: userLevel ?? this.userLevel,
      isExpert: isExpert ?? this.isExpert,
      videoAccess: videoAccess ?? this.videoAccess,
    );
  }
}

class UserAccessNotifier extends StateNotifier<AsyncValue<UserAccessState>> {
  final WorkoutVideosRepository _repository;

  UserAccessNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadUserAccess();
  }

  Future<void> _loadUserAccess() async {
    try {
      final userLevel = await _repository.getCurrentUserLevel();
      // ⚠️ VERIFICAÇÃO RIGOROSA: apenas 'expert' exato é válido
      final isValidExpert = userLevel == 'expert';
      
      state = AsyncValue.data(UserAccessState(
        userLevel: isValidExpert ? 'expert' : 'basic',
        isExpert: isValidExpert,
        videoAccess: {},
      ));
    } catch (e) {
      // ⚠️ EM CASO DE ERRO, CRIAR ESTADO BASIC
      state = AsyncValue.data(const UserAccessState(
        userLevel: 'basic',
        isExpert: false,
        videoAccess: {},
      ));
    }
  }

  Future<bool> checkVideoAccess(String videoId) async {
    try {
      final currentState = state.value;
      // ⚠️ SEGURANÇA: Se não há estado válido, negar acesso
      if (currentState == null || !currentState.isExpert) return false;

      // Se já verificamos este vídeo, retornar cache (mas só se positivo)
      if (currentState.videoAccess.containsKey(videoId)) {
        return currentState.videoAccess[videoId] == true;
      }

      // ⚠️ VERIFICAÇÃO TRIPLA DE SEGURANÇA
      // 1. Deve ser expert no estado local
      if (!currentState.isExpert) return false;
      
      // 2. Verificar novamente se ainda é expert
      final currentLevel = await _repository.getCurrentUserLevel();
      if (currentLevel != 'expert') return false;
      
      // 3. Verificar acesso específico no backend
      final canAccess = await _repository.canUserAccessVideoLink(videoId);
      
      // ⚠️ TODAS as condições devem ser verdadeiras
      final hasAccess = (currentLevel == 'expert') && 
                       (canAccess == true) && 
                       currentState.isExpert;
      
      // Atualizar cache
      final updatedAccess = Map<String, bool>.from(currentState.videoAccess);
      updatedAccess[videoId] = hasAccess;
      
      state = AsyncValue.data(currentState.copyWith(videoAccess: updatedAccess));
      
      return hasAccess;
      
    } catch (e) {
      debugPrint('[checkVideoAccess] ERROR for video $videoId: $e');
      return false; // Fail-safe: qualquer erro nega acesso
    }
  }

  void refresh() {
    state = const AsyncValue.loading();
    _loadUserAccess();
  }
}

final userAccessProvider = StateNotifierProvider<UserAccessNotifier, AsyncValue<UserAccessState>>((ref) {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return UserAccessNotifier(repository);
});

/// Provider para verificar acesso a vídeo específico com fail-safe
final checkVideoAccessProvider = FutureProvider.family<bool, String>((ref, videoId) async {
  print('🔍 [checkVideoAccessProvider] ========== VERIFICAÇÃO VÍDEO ==========');
  print('🔍 [checkVideoAccessProvider] Video ID: $videoId');
  
  try {
    final isExpert = await ref.watch(isExpertUserProvider.future);
    print('🔍 [checkVideoAccessProvider] Usuário é expert? $isExpert');
    
    if (!isExpert) {
      print('❌ [checkVideoAccessProvider] ⚠️ USUÁRIO BASIC = SEM ACESSO AO VÍDEO ⚠️');
      return false;
    }
    
    print('✅ [checkVideoAccessProvider] 🌟 EXPERT = ACESSO LIBERADO AO VÍDEO 🌟');
    return true;
  } catch (e) {
    print('❌ [checkVideoAccessProvider] ERRO para vídeo $videoId: $e');
    print('❌ [checkVideoAccessProvider] ⚠️ ERRO = SEM ACESSO (fail-safe) ⚠️');
    return false; // Fail-safe: qualquer erro nega acesso
  }
});