// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environment.dart';

class AppConfig {
  static String get supabaseUrl => EnvironmentManager.supabaseUrl;
  static String get supabaseAnonKey => EnvironmentManager.supabaseAnonKey;

  static String get apiUrl => EnvironmentManager.apiUrl;
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  static String get appName => dotenv.env['APP_NAME'] ?? 'Ray Club';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get debugMode => EnvironmentManager.debugMode;

  // @deprecated Variáveis legadas que serão removidas em versões futuras.
  // Utilize os buckets específicos abaixo em vez dessas variáveis genéricas.
  static String get storageBucket => dotenv.env['STORAGE_BUCKET'] ?? '';
  static String get storageUrl => dotenv.env['STORAGE_URL'] ?? '';
  
  // Storage buckets
  static String get workoutBucket => EnvironmentManager.workoutBucket;
  static String get profileBucket => EnvironmentManager.profileBucket;
  static String get nutritionBucket => EnvironmentManager.nutritionBucket;
  static String get featuredBucket => EnvironmentManager.featuredBucket;
  static String get challengeBucket => EnvironmentManager.challengeBucket;

  static bool get analyticsEnabled =>
      dotenv.env['ANALYTICS_ENABLED']?.toLowerCase() == 'true';
  static String get analyticsKey => dotenv.env['ANALYTICS_KEY'] ?? '';

  static Future<void> initialize() async {
    await dotenv.load();
    
    // Configurar o ambiente com base na variável APP_ENV
    final envName = dotenv.env['APP_ENV'] ?? 'development';
    
    switch (envName) {
      case 'production':
        EnvironmentManager.setEnvironment(Environment.production);
        break;
      case 'staging':
        EnvironmentManager.setEnvironment(Environment.staging);
        break;
      default:
        EnvironmentManager.setEnvironment(Environment.development);
    }
    
    // Validar se o ambiente está corretamente configurado
    if (!EnvironmentManager.validateEnvironment()) {
      print('AVISO: Configuração de ambiente incompleta!');
    }
  }

  static bool get isProduction => EnvironmentManager.isProduction;
  static bool get isDevelopment => EnvironmentManager.isDevelopment;
  static bool get isStaging => EnvironmentManager.isStaging;
}
