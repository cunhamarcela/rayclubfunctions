import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_status.dart';

/// Repository para gerenciar níveis de acesso do usuário
class UserAccessRepository {
  final SupabaseClient _supabase;
  
  UserAccessRepository(this._supabase);
  
  /// Busca o nível de acesso do usuário
  /// Faz verificação server-side para segurança
  Future<UserAccessStatus> getUserAccessLevel(String userId) async {
    try {
      // Buscar dados de nível via RPC para segurança
      final response = await _supabase.rpc('check_user_access_level', 
        params: {'user_id_param': userId}
      );
      
      if (response == null) {
        return UserAccessStatus.basic(userId);
      }
      
      return UserAccessStatus.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Erro ao buscar nível de acesso: $e');
      // Em caso de erro, retorna acesso básico para segurança
      return UserAccessStatus.basic(userId);
    }
  }
  
  /// Verifica se o usuário tem acesso a uma feature específica
  /// Método rápido para verificações críticas
  Future<bool> hasFeatureAccess(String userId, String featureKey) async {
    try {
      final response = await _supabase.rpc('check_feature_access', 
        params: {
          'user_id_param': userId,
          'feature_key_param': featureKey,
        }
      );
      
      return response as bool? ?? false;
    } catch (e) {
      debugPrint('❌ Erro ao verificar acesso à feature $featureKey: $e');
      return false;
    }
  }
  
  /// Atualiza o cache local do nível de acesso
  Future<void> updateAccessCache(UserAccessStatus status) async {
    try {
      await _supabase
          .from('user_progress_level')
          .upsert(status.toJson());
    } catch (e) {
      debugPrint('❌ Erro ao atualizar cache de acesso: $e');
    }
  }
  
  /// Força revalidação do nível de acesso no servidor
  Future<UserAccessStatus> revalidateAccess(String userId) async {
    try {
      // Chama webhook interno que verifica com sistema externo
      final response = await _supabase.rpc('refresh_user_level', 
        params: {'user_id_param': userId}
      );
      
      if (response == null) {
        return UserAccessStatus.basic(userId);
      }
      
      final status = UserAccessStatus.fromJson(response as Map<String, dynamic>);
      
      // Atualiza o cache
      await updateAccessCache(status);
      
      return status;
    } catch (e) {
      debugPrint('❌ Erro ao revalidar acesso: $e');
      return UserAccessStatus.basic(userId);
    }
  }
  
  /// Registra tentativa de acesso a feature avançada
  /// Para analytics e gamificação
  Future<void> logProgressAttempt(String userId, String featureKey) async {
    try {
      await _supabase.rpc('track_user_progress', 
        params: {
          'user_id_param': userId,
          'feature_key_param': featureKey,
          'timestamp_param': DateTime.now().toIso8601String(),
        }
      );
    } catch (e) {
      debugPrint('⚠️ Erro ao registrar progresso: $e');
    }
  }
} 