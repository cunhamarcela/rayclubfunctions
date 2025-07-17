import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Utilitário para validar variáveis de ambiente
class EnvValidator {
  /// Variáveis de ambiente obrigatórias
  static const List<String> requiredVars = [
    'API_URL',
    'STORAGE_URL',
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
    'ENVIRONMENT',
    'APP_VERSION',
  ];
  
  /// Verifica se todas as variáveis de ambiente obrigatórias estão definidas
  /// Retorna true se todas estiverem definidas, false caso contrário
  static bool validateEnvironment() {
    final missingVars = <String>[];
    
    for (final variable in requiredVars) {
      final value = dotenv.env[variable];
      if (value == null || value.isEmpty) {
        missingVars.add(variable);
      }
    }
    
    if (missingVars.isNotEmpty) {
      debugPrint('⚠️ Variáveis de ambiente ausentes: ${missingVars.join(', ')}');
      return false;
    }
    
    return true;
  }
  
  /// Obtém uma variável de ambiente com valor padrão caso não esteja definida
  static String getEnv(String key, {String defaultValue = ''}) {
    final value = dotenv.env[key];
    
    if (value == null || value.isEmpty) {
      debugPrint('⚠️ Variável de ambiente não encontrada: $key, usando valor padrão: $defaultValue');
      return defaultValue;
    }
    
    return value;
  }
  
  /// Verifica se uma variável de ambiente está definida
  static bool hasEnv(String key) {
    final value = dotenv.env[key];
    return value != null && value.isNotEmpty;
  }
  
  /// Lista todas as variáveis de ambiente definidas (exceto informações sensíveis)
  static void logEnvironment() {
    final envVars = dotenv.env.entries
        .where((entry) => !_isSensitiveKey(entry.key))
        .map((entry) => '${entry.key}=${entry.value}')
        .join('\n');
    
    debugPrint('📝 Variáveis de ambiente:\n$envVars');
  }
  
  /// Verifica se uma chave é sensível (não deve ser logada)
  static bool _isSensitiveKey(String key) {
    final sensitivePatterns = [
      'key',
      'secret',
      'password',
      'token',
      'auth',
    ];
    
    return sensitivePatterns.any((pattern) => 
        key.toLowerCase().contains(pattern.toLowerCase()));
  }
} 