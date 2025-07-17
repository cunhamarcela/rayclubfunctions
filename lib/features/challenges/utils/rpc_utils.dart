import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/uuid_extensions.dart';

/// Extensão para simplificar a validação de UUIDs em chamadas RPC
extension RpcExtension on SupabaseClient {
  /// Executa uma chamada RPC com validação de UUIDs para parâmetros conhecidos
  Future<dynamic> rpcWithValidUuids(
    String function, {
    required Map<String, dynamic> params,
    List<String>? uuidFields,
  }) async {
    // Lista padrão de campos que são UUIDs
    final defaultUuidFields = [
      'challenge_id', 'p_challenge_id', 'challenge_id_param',
      'user_id', 'p_user_id', 'user_id_param',
      'workout_id', 'p_workout_id', 'workout_id_param',
      'group_id', 'p_group_id', 'group_id_param',
    ];
    
    // Combinar com campos adicionais se fornecidos
    final fieldsToValidate = [...defaultUuidFields];
    if (uuidFields != null) {
      fieldsToValidate.addAll(uuidFields);
    }
    
    // Validar UUIDs nos parâmetros
    final validatedParams = Map<String, dynamic>.from(params);
    for (final field in fieldsToValidate) {
      if (validatedParams.containsKey(field) && 
          validatedParams[field] is String) {
        validatedParams[field] = (validatedParams[field] as String).toValidUuid();
      }
    }
    
    // Executar a função RPC com parâmetros validados
    return rpc(function, params: validatedParams);
  }
} 