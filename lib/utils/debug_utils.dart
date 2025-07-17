// Project imports:
import 'package:ray_club_app/utils/json_utils.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Utilitários para debugging de erros comuns
class DebugUtils {
  static const String _logTag = 'DebugUtils';
  
  /// Analisa um objeto JSON para identificar possíveis problemas de tipo
  /// com campos String ou NULL
  static void analyzeJsonForTypeErrors(Map<String, dynamic> json, {
    required String context,
    bool verbose = false,
  }) {
    LogUtils.debug('🔍 Analisando JSON para $context', tag: _logTag);
    
    // Primeiro analisar estrutura básica
    final int totalFields = json.length;
    final int nullFields = json.values.where((v) => v == null).length;
    final double nullPercentage = totalFields > 0 ? (nullFields / totalFields) * 100 : 0;
    
    LogUtils.debug(
      '📊 Estrutura: $totalFields campos, $nullFields nulos (${nullPercentage.toStringAsFixed(1)}%)',
      tag: _logTag
    );
    
    // Verificar campos críticos
    final criticalFields = [
      'id', 'user_id', 'userId', 'creator_id', 'creatorId', 
      'name', 'title', 'description', 'email', 'url'
    ];
    
    // Construir regex para identificar campos importantes
    final idRegex = RegExp(r'.*_?id$');
    final nameRegex = RegExp(r'.*_?name$');
    final urlRegex = RegExp(r'.*_?url$');
    
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      final runtimeType = value?.runtimeType.toString() ?? 'null';
      
      bool isCritical = criticalFields.contains(key) || 
                        idRegex.hasMatch(key) ||
                        nameRegex.hasMatch(key) ||
                        urlRegex.hasMatch(key);
      
      // Identificar campos que poderiam causar erro de tipo NULL para String
      if (value == null && isCritical) {
        LogUtils.warning('⚠️ Campo crítico "$key" é NULL', tag: _logTag);
      } 
      // Verificar se é um campo que seria naturalmente String
      else if (isCritical && value != null && runtimeType != 'String') {
        LogUtils.warning('⚠️ Campo crítico "$key" é $runtimeType, não String', tag: _logTag);
      }
      // Se for verbose, mostrar todos os campos
      else if (verbose) {
        LogUtils.debug('Campo "$key": $value ($runtimeType)', tag: _logTag);
      }
    }
    
    // Verificar campos aninhados
    for (final entry in json.entries) {
      if (entry.value is Map<String, dynamic>) {
        LogUtils.debug('🔍 Analisando sub-objeto ${entry.key}:', tag: _logTag);
        analyzeJsonForTypeErrors(
          entry.value as Map<String, dynamic>,
          context: '$context.${entry.key}',
          verbose: verbose
        );
      } else if (entry.value is List) {
        final list = entry.value as List;
        if (list.isNotEmpty && list.first is Map<String, dynamic>) {
          LogUtils.debug('🔍 Analisando primeiro item da lista ${entry.key}:', tag: _logTag);
          analyzeJsonForTypeErrors(
            list.first as Map<String, dynamic>,
            context: '$context.${entry.key}[0]',
            verbose: verbose
          );
        }
      }
    }
  }
  
  /// Sanitiza todos os campos de ID em um JSON para garantir que sejam string
  static Map<String, dynamic> sanitizeIds(Map<String, dynamic> json) {
    final result = <String, dynamic>{};
    
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Verificar se é um campo de ID
      if (key == 'id' || key.endsWith('_id') || key.endsWith('Id')) {
        // Garantir que seja uma string não-nula
        result[key] = JsonUtils.safeString(value);
      } else {
        // Manter outros campos como estão
        result[key] = value;
      }
    }
    
    return result;
  }
  
  /// Analisa um erro para ver se é relacionado a cast de null para String
  static bool isNullStringCastError(Object error) {
    final errorStr = error.toString();
    return errorStr.contains("type 'Null' is not a subtype of type 'String'");
  }
} 