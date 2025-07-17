import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuração para testes
class TestConfig {
  /// URL do Supabase para testes
  static String get supabaseUrl =>
      _getEnvVar('SUPABASE_URL', 'https://seu-projeto-id.supabase.co');

  /// Chave anônima do Supabase para testes
  static String get supabaseAnonKey =>
      _getEnvVar('SUPABASE_ANON_KEY', 'sua-anon-key-aqui');

  /// Verifica se as credenciais do Supabase são válidas
  static bool get hasValidSupabaseCredentials =>
      supabaseUrl.isNotEmpty &&
      supabaseUrl != 'https://seu-projeto-id.supabase.co' &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'sua-anon-key-aqui';

  /// Inicializa a configuração de teste
  static Future<void> init() async {
    try {
      // Tenta carregar o arquivo .env.test se existir
      await dotenv.load(fileName: '.env.test');
      debugPrint('✅ Arquivo .env.test carregado para testes');
    } catch (e) {
      try {
        // Tenta carregar .env normal se .env.test não existir
        await dotenv.load();
        debugPrint('✅ Arquivo .env carregado para testes');
      } catch (e) {
        debugPrint('⚠️ Arquivos de ambiente não encontrados. Usando valores padrão ou variáveis de ambiente do sistema.');
      }
    }
  }

  /// Recupera uma variável de ambiente da seguinte ordem:
  /// 1. Variável de ambiente do sistema
  /// 2. Valor do arquivo .env
  /// 3. Valor padrão fornecido
  static String _getEnvVar(String name, String defaultValue) {
    // Primeiro tenta das variáveis de ambiente do sistema
    final sysEnv = Platform.environment[name];
    if (sysEnv != null && sysEnv.isNotEmpty) {
      return sysEnv;
    }
    
    // Em seguida tenta do .env 
    final envValue = dotenv.env[name];
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }
    
    // Por último usa o valor padrão
    return defaultValue;
  }
} 