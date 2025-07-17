// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Serviço para gerenciar variáveis de ambiente
class EnvConfig {
  /// Singleton
  static final EnvConfig _instance = EnvConfig._internal();
  
  /// Factory construtor
  factory EnvConfig() {
    return _instance;
  }
  
  /// Construtor privado
  EnvConfig._internal();
  
  /// Inicializa o serviço
  Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('⚠️ Falha ao carregar arquivo .env: $e');
    }
  }
  
  /// Obtém uma variável de ambiente
  String get(String key) {
    try {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        debugPrint('⚠️ Variável de ambiente não encontrada: $key');
        return '';
      }
      return value;
    } catch (e) {
      debugPrint('⚠️ Erro ao obter variável de ambiente $key: $e');
      return '';
    }
  }
  
  /// Obtém uma variável de ambiente como um boolean
  bool getBool(String key) {
    final value = get(key).toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }
  
  /// Obtém uma variável de ambiente como um int
  int getInt(String key) {
    try {
      return int.parse(get(key));
    } catch (e) {
      debugPrint('⚠️ Erro ao converter variável $key para int: $e');
      return 0;
    }
  }
  
  /// Obtém uma variável de ambiente como um double
  double getDouble(String key) {
    try {
      return double.parse(get(key));
    } catch (e) {
      debugPrint('⚠️ Erro ao converter variável $key para double: $e');
      return 0.0;
    }
  }
  
  /// Verifica se uma variável existe
  bool has(String key) {
    return dotenv.env.containsKey(key) && dotenv.env[key]!.isNotEmpty;
  }
  
  /// Retorna uma lista de variáveis disponíveis (apenas em modo debug)
  List<String> getAvailableKeys() {
    if (kReleaseMode) {
      return [];
    }
    return dotenv.env.keys.toList();
  }
  
  /// URLs do Supabase
  String get supabaseUrl => get('SUPABASE_URL');
  String get supabaseAnonKey => get('SUPABASE_ANON_KEY');
  
  /// URLs de integrações
  String get apiBaseUrl => get('API_BASE_URL');
  
  /// Configurações de feature flags
  bool get enableDeepLinks => getBool('ENABLE_DEEP_LINKS');
  bool get enableAnalytics => getBool('ENABLE_ANALYTICS');
} 