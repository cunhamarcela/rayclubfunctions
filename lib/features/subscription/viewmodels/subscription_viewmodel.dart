import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/subscription_repository.dart';
import '../models/subscription_status.dart';

/// Estado do ViewModel de acesso do usuário
class UserAccessState {
  final UserAccessStatus? currentStatus;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  
  const UserAccessState({
    this.currentStatus,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });
  
  UserAccessState copyWith({
    UserAccessStatus? currentStatus,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return UserAccessState(
      currentStatus: currentStatus ?? this.currentStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// ViewModel para gerenciar acesso do usuário
class UserAccessViewModel extends StateNotifier<UserAccessState> {
  final UserAccessRepository _repository;
  
  UserAccessViewModel(this._repository) : super(const UserAccessState());
  
  /// Busca o nível de acesso do usuário
  Future<UserAccessStatus> getUserAccessLevel(String userId) async {
    try {
      // NÃO modifica o state se estiver sendo chamado durante a inicialização
      // Apenas retorna o status sem atualizar o state
      
      // Verifica se precisa revalidar
      if (state.currentStatus?.needsVerification == true) {
        debugPrint('🔄 Revalidando nível de acesso...');
        final status = await _repository.revalidateAccess(userId);
        
        // Agenda a atualização do state para depois
        Future.microtask(() {
          if (mounted) {
        state = state.copyWith(
          currentStatus: status,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
          }
        });
        
        return status;
      }
      
      // Se já tem status válido em cache, retorna
      if (state.currentStatus != null && 
          state.currentStatus!.userId == userId &&
          !state.currentStatus!.needsVerification) {
        return state.currentStatus!;
      }
      
      // Busca novo status
      final status = await _repository.getUserAccessLevel(userId);
      
      // Agenda a atualização do state para depois
      Future.microtask(() {
        if (mounted) {
      state = state.copyWith(
        currentStatus: status,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
        }
      });
      
      return status;
    } catch (e) {
      debugPrint('❌ Erro no ViewModel de acesso: $e');
      
      // Agenda a atualização do state para depois
      Future.microtask(() {
        if (mounted) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
        }
      });
      
      // Retorna acesso básico em caso de erro
      return UserAccessStatus.basic(userId);
    }
  }
  
  /// Verifica acesso a uma feature específica
  Future<bool> checkFeatureAccess(String userId, String featureKey) async {
    try {
      // Verificação rápida no cache local
      if (state.currentStatus != null && 
          state.currentStatus!.userId == userId &&
          !state.currentStatus!.needsVerification) {
        return state.currentStatus!.hasAccess(featureKey);
      }
      
      // Verificação no servidor para features críticas
      return await _repository.hasFeatureAccess(userId, featureKey);
    } catch (e) {
      debugPrint('❌ Erro ao verificar acesso à feature $featureKey: $e');
      return false;
    }
  }
  
  /// Força revalidação do nível de acesso
  Future<void> revalidateAccess(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final status = await _repository.revalidateAccess(userId);
      
      state = state.copyWith(
        currentStatus: status,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Erro ao revalidar acesso: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Registra tentativa de acesso a feature avançada
  Future<void> logProgressAttempt(String userId, String featureKey) async {
    await _repository.logProgressAttempt(userId, featureKey);
  }
  
  /// Limpa o cache de acesso
  void clearCache() {
    state = const UserAccessState();
  }
} 