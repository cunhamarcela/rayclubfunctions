import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Extensão para adicionar métodos úteis ao SupabaseClient
extension SupabaseClientExtension on SupabaseClient {
  /// Versão melhorada do método rpc que garante que os UUIDs estejam em formato válido
  /// Este método é equivalente ao rpc padrão, mas foi criado para manter compatibilidade
  /// com código que possa estar esperando este método específico.
  Future<dynamic> rpcWithValidUuids(
    String functionName, {
    Map<String, dynamic>? params,
    bool get = false,
  }) async {
    try {
      debugPrint('🔄 [DIAGNÓSTICO] Iniciando RPC: $functionName');
      if (params != null) {
        debugPrint('🔄 [DIAGNÓSTICO] Parâmetros da RPC: $params');
      }
      
      // Apenas chama o método rpc padrão sem manipulação adicional
      final result = await rpc(
      functionName,
      params: params,
      get: get,
    );
      
      debugPrint('✅ [DIAGNÓSTICO] RPC $functionName concluída com sucesso');
      return result;
    } catch (e) {
      debugPrint('❌ [DIAGNÓSTICO] Erro na RPC $functionName: $e');
      
      // Verificar se é um erro de transação PostgreSQL
      if (e is PostgrestException) {
        debugPrint('❌ [DIAGNÓSTICO] PostgrestException: código=${e.code}, detalhes=${e.details}');
        
        // Caso específico para erro de terminação de transação
        if (e.code == '2D000') {
          debugPrint('⚠️ [DIAGNÓSTICO] Erro de terminação de transação detectado');
        }
      }
      
      // Propagar o erro original
      rethrow;
    }
  }
} 