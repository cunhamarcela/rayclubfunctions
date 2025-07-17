// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:ray_club_app/utils/log_utils.dart';

/// Utilitário para processamento seguro de campos JSON
class JsonUtils {
  static const String _logTag = 'JsonUtils';
  
  /// Converte um valor para String de forma segura, retornando um valor padrão
  /// caso o campo seja nulo ou não possa ser convertido.
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }
  
  /// Converte um valor para String? de forma segura.
  /// Se o valor for nulo, uma string vazia ou não puder ser convertido
  /// para String, retorna null.
  static String? safeNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.trim().isEmpty ? null : value;
    }
    // Tenta converter outros tipos para string
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }
  
  /// Obtém um campo String de um map JSON de forma segura
  static String getStringValue(Map<String, dynamic> json, String key, {String defaultValue = ''}) {
    return safeString(json[key], defaultValue: defaultValue);
  }
  
  /// Obtém um campo String? de um map JSON de forma segura
  static String? getNullableStringValue(Map<String, dynamic> json, String key) {
    return safeNullableString(json[key]);
  }
  
  /// Tenta converter um valor para int de forma segura
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    // Se é um DateTime (caso específico para days_remaining), tratar adequadamente
    if (value is DateTime) {
      // Converter para dias a partir da data atual
      final difference = value.difference(DateTime.now()).inDays;
      return difference > 0 ? difference : 0;
    }
    return defaultValue;
  }
  
  /// Tenta converter um valor para double de forma segura
  static double safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  
  /// Tenta converter um valor para bool de forma segura
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes') return true;
      if (lowerValue == 'false' || lowerValue == '0' || lowerValue == 'no') return false;
    }
    return defaultValue;
  }
  
  /// Tenta converter um valor para DateTime de forma segura
  static DateTime? safeDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      } else if (value is int) {
        // Assume que é timestamp em milissegundos
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      LogUtils.error('Erro ao converter DateTime', tag: _logTag, error: e);
    }
    
    return null;
  }
  
  /// Tenta decodificar um JSON em formato String para Map<String, dynamic>
  static Map<String, dynamic> safeJsonDecode(String jsonString, {Map<String, dynamic>? defaultValue}) {
    try {
      final Map<String, dynamic> result = jsonDecode(jsonString);
      return result;
    } catch (e) {
      LogUtils.error('Erro ao decodificar JSON: $jsonString', tag: _logTag, error: e);
      return defaultValue ?? {};
    }
  }
  
  /// Diagnóstico de erro de tipo 'Null' para 'String'
  static void diagnoseNullStringError(Map<String, dynamic> json, {String? context}) {
    final tag = context != null ? '$_logTag:$context' : _logTag;
    
    LogUtils.debug('Diagnosticando potenciais campos nulos com erro de tipo String', tag: tag);
    
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Verificar campos mais propensos a erros
      if (value == null) {
        if (key.contains('id') || key.contains('name') || key.contains('title') || 
            key.contains('url') || key.contains('email')) {
          LogUtils.warning('⚠️ Campo "$key" é NULL e pode causar erro de tipagem', tag: tag);
        }
      }
    }
  }
  
  /// Função específica para sanitizar dados de desafio
  /// Utiliza os novos métodos seguros para processamento de valores
  static Map<String, dynamic> sanitizeChallenge(Map<String, dynamic> json) {
    // Tratar especificamente o campo days_remaining que pode ser DateTime
    int daysRemaining = 0;
    if (json.containsKey('days_remaining')) {
      daysRemaining = safeInt(json['days_remaining']);
    } else if (json.containsKey('end_date')) {
      // Se não tiver days_remaining mas tiver end_date, calcular
      final endDate = safeDateTime(json['end_date']);
      if (endDate != null) {
        daysRemaining = DateTime.now().difference(endDate).inDays.abs();
      }
    }
    
    // Processar datas
    final startDate = safeDateTime(json['start_date']) ?? DateTime.now();
    final endDate = safeDateTime(json['end_date']) ?? DateTime.now().add(const Duration(days: 7));
    
    // Log de diagnóstico
    if (json['start_date'] is DateTime) {
      LogUtils.debug('Campo start_date já é DateTime na entrada', tag: _logTag);
    }
    
    return {
      'id': getStringValue(json, 'id'),
      'title': getStringValue(json, 'title'),
      'description': getStringValue(json, 'description'),
      'imageUrl': getNullableStringValue(json, 'image_url'),
      'startDate': startDate, // Usar o objeto DateTime diretamente
      'endDate': endDate, // Usar o objeto DateTime diretamente
      'type': getStringValue(json, 'type', defaultValue: 'normal'),
      'points': safeInt(json['points'], defaultValue: 10),
      'requirements': json['requirements'] is List ? json['requirements'] : [],
      'participants': json['participants'] is List ? json['participants'] : [],
      'active': safeBool(json['active'], defaultValue: true),
      'creatorId': getNullableStringValue(json, 'creator_id'),
      'isOfficial': safeBool(json['is_official'], defaultValue: false),
      'createdAt': safeDateTime(json['created_at']),
      'updatedAt': safeDateTime(json['updated_at']),
      'invitedUsers': json['invited_users'] is List ? json['invited_users'] : [],
      'daysRemaining': daysRemaining, // Adicionar campo calculado
    };
  }
  
  /// Função específica para sanitizar dados de progresso de desafio
  /// Utiliza os novos métodos seguros para processamento de valores
  static Map<String, dynamic> sanitizeChallengeProgress(Map<String, dynamic> json) {
    // Corrigir qualquer campo DateTime que possa causar erro
    if (json['user_name'] is DateTime) {
      LogUtils.warning('Convertendo user_name de DateTime para String', tag: _logTag);
      json['user_name'] = (json['user_name'] as DateTime).toIso8601String();
    }
    
    return {
      'id': getStringValue(json, 'id'),
      'user_id': getStringValue(json, 'user_id'),
      'challenge_id': getStringValue(json, 'challenge_id'),
      'user_name': getStringValue(json, 'user_name', defaultValue: 'Usuário'),
      'user_photo_url': getNullableStringValue(json, 'user_photo_url'),
      'points': safeInt(json['points']),
      'check_ins_count': safeInt(json['check_ins_count']),
      'consecutive_days': safeInt(json['consecutive_days']),
      'position': safeInt(json['position']),
      'completion_percentage': safeDouble(json['completion_percentage']),
      'completed': safeBool(json['completed']),
      'last_check_in': safeDateTime(json['last_check_in']),
      'created_at': safeDateTime(json['created_at']) ?? DateTime.now(),
      'updated_at': safeDateTime(json['updated_at']),
    };
  }
  
  /// Diagnostica erros específicos e mostra mais informações
  static void diagnoseTypeError(
    dynamic error,
    {String? context, 
    Map<String, dynamic>? data,
    List<String>? fieldsToCheck}
  ) {
    final tag = context != null ? '$_logTag:$context' : _logTag;
    
    if (error.toString().contains('DateTime') && error.toString().contains('String')) {
      LogUtils.error('Erro de tipo: valor DateTime usado onde String era esperado', tag: tag);
      
      if (data != null) {
        final keys = fieldsToCheck ?? data.keys.toList();
        for (final key in keys) {
          final value = data[key];
          if (value != null) {
            LogUtils.debug('Campo "$key": ${value.runtimeType}', tag: tag);
          } else {
            LogUtils.warning('Campo "$key" é NULL', tag: tag);
          }
        }
      }
    }
  }
}