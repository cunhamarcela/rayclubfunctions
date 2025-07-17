import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnvironmentConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String loggingApiUrl;
  final String loggingApiKey;
  final String analyticsApiKey;

  EnvironmentConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.loggingApiUrl,
    required this.loggingApiKey,
    required this.analyticsApiKey,
  });

  factory EnvironmentConfig.fromEnv() {
    return EnvironmentConfig(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      loggingApiUrl: dotenv.env['LOGGING_API_URL'] ?? '',
      loggingApiKey: dotenv.env['LOGGING_API_KEY'] ?? '',
      analyticsApiKey: dotenv.env['ANALYTICS_API_KEY'] ?? '',
    );
  }
}

final environmentProvider = Provider<EnvironmentConfig>((ref) {
  return EnvironmentConfig.fromEnv();
}); 