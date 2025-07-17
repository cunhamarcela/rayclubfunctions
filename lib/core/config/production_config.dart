import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuração de produção do aplicativo
/// 
/// Esta classe contém as configurações de produção para quando o .env
/// não está disponível (como em builds iOS de produção).
class ProductionConfig {
  /// Inicializa as configurações de produção
  /// Se o .env não tiver as variáveis, usa os valores hardcoded
  static Future<void> initialize() async {
    // Em produção, configurar as variáveis se não estiverem no .env
    if (kReleaseMode) {
      // Configurações do Supabase
      dotenv.env['PROD_SUPABASE_URL'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co';
      dotenv.env['PROD_SUPABASE_ANON_KEY'] ??= 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
      
      // Mesmas credenciais para todos os ambientes
      dotenv.env['DEV_SUPABASE_URL'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co';
      dotenv.env['DEV_SUPABASE_ANON_KEY'] ??= 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
      
      dotenv.env['STAGING_SUPABASE_URL'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co';
      dotenv.env['STAGING_SUPABASE_ANON_KEY'] ??= 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
      
      // URLs adicionais
      dotenv.env['SUPABASE_URL'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co';
      dotenv.env['SUPABASE_ANON_KEY'] ??= 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
      dotenv.env['API_URL'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co';
      dotenv.env['STORAGE_URL'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co/storage/v1';
      
      // Google OAuth
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??= '187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com';
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ??= '187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i.apps.googleusercontent.com';
      
      // Apple Sign In
      dotenv.env['APPLE_CLIENT_ID'] ??= 'com.rayclub.app';
      dotenv.env['APPLE_SERVICE_ID'] ??= 'com.rayclub.app.signin';
      dotenv.env['APPLE_REDIRECT_URI'] ??= 'https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback';
      
      // URLs Base
      dotenv.env['BASE_URL'] ??= 'https://rayclub.com.br';
      dotenv.env['API_BASE_URL'] ??= 'https://api.rayclub.com.br';
      
      // Storage Buckets
      dotenv.env['STORAGE_WORKOUT_BUCKET'] ??= 'workout-images';
      dotenv.env['STORAGE_PROFILE_BUCKET'] ??= 'profile-images';
      dotenv.env['STORAGE_NUTRITION_BUCKET'] ??= 'nutrition-images';
      dotenv.env['STORAGE_FEATURED_BUCKET'] ??= 'featured-images';
      dotenv.env['STORAGE_CHALLENGE_BUCKET'] ??= 'challenge-media';
      
      // Configurações de ambiente
      dotenv.env['APP_ENV'] ??= 'production';
      dotenv.env['APP_NAME'] ??= 'Ray Club';
      dotenv.env['APP_VERSION'] ??= '1.0.11';
      dotenv.env['APP_BUILD_NUMBER'] ??= '22';
      
      // Feature flags
      dotenv.env['ENABLE_DEEP_LINKS'] ??= 'true';
      dotenv.env['ENABLE_ANALYTICS'] ??= 'false';
      dotenv.env['ENABLE_REMOTE_LOGGING'] ??= 'false';
      dotenv.env['DEBUG_MODE'] ??= 'false';
      dotenv.env['ENABLE_DEBUG_LOGS'] ??= 'false';
      
      print('✅ Configurações de produção carregadas com sucesso');
    }
    
    // Validar variáveis obrigatórias
    final requiredVars = [
      'PROD_SUPABASE_URL',
      'PROD_SUPABASE_ANON_KEY',
      'GOOGLE_WEB_CLIENT_ID',
      'GOOGLE_IOS_CLIENT_ID',
    ];
    
    final missingVars = <String>[];
    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        missingVars.add(varName);
      }
    }
    
    if (missingVars.isNotEmpty && !kReleaseMode) {
      throw Exception(
        'Variáveis de ambiente obrigatórias não encontradas: ${missingVars.join(', ')}\n'
        'Configure estas variáveis no arquivo .env antes de executar o app.'
      );
    }
  }
  
  /// Retorna a URL do Supabase para produção
  static String get supabaseUrl {
    final url = dotenv.env['PROD_SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      if (kReleaseMode) {
        return 'https://zsbbgchsjiuicwvtrldn.supabase.co';
      }
      throw Exception('PROD_SUPABASE_URL não configurada');
    }
    return url;
  }
  
  /// Retorna a chave anônima do Supabase para produção
  static String get supabaseAnonKey {
    final key = dotenv.env['PROD_SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      if (kReleaseMode) {
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
      }
      throw Exception('PROD_SUPABASE_ANON_KEY não configurada');
    }
    return key;
  }
  
  /// Retorna o Google Web Client ID
  static String get googleWebClientId {
    final id = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    if (id == null || id.isEmpty) {
      if (kReleaseMode) {
        return '187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com';
      }
      throw Exception('GOOGLE_WEB_CLIENT_ID não configurado');
    }
    return id;
  }
  
  /// Retorna o Google iOS Client ID
  static String get googleIosClientId {
    final id = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
    if (id == null || id.isEmpty) {
      if (kReleaseMode) {
        return '187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i.apps.googleusercontent.com';
      }
      throw Exception('GOOGLE_IOS_CLIENT_ID não configurado');
    }
    return id;
  }
} 