/// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment.dart';

/// Configurações centralizadas de autenticação
/// 
/// Este arquivo contém todas as URLs e configurações relacionadas
/// à autenticação do aplicativo Ray Club.
class AuthConfig {
  /// URL base do aplicativo
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://rayclub.com.br';
  
  /// URL de callback OAuth customizada
  static String get oauthCallbackUrl => '$baseUrl/auth/callback';
  
  /// URL de callback do Supabase
  static String get supabaseCallbackUrl {
    final supabaseUrl = EnvironmentManager.supabaseUrl;
    if (supabaseUrl.isEmpty) {
      throw Exception('Supabase URL não configurada');
    }
    return '$supabaseUrl/auth/v1/callback';
  }
  
  /// URL de redefinição de senha
  static String get resetPasswordUrl => '$baseUrl/reset-password';
  
  /// URL de confirmação de email
  static String get confirmEmailUrl => '$baseUrl/confirm';
  
  /// Google Client IDs
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
  
  /// Deep Link Schemes
  static const String appScheme = 'rayclub';
  static const String loginCallbackPath = 'login-callback';
  static const String resetPasswordPath = 'reset-password';
  static const String confirmPath = 'confirm';
  
  /// Deep Link URLs
  static String get loginCallbackDeepLink => '$appScheme://$loginCallbackPath';
  static String get resetPasswordDeepLink => '$appScheme://$resetPasswordPath';
  static String get confirmDeepLink => '$appScheme://$confirmPath';
  
  /// Configuração para escolher qual URL usar
  static const bool useSupabaseCallback = true; // Mude para false quando tiver as páginas web
  
  /// Retorna a URL de OAuth callback apropriada para a plataforma
  static String getOAuthCallbackUrl() {
    final url = useSupabaseCallback ? supabaseCallbackUrl : oauthCallbackUrl;
    print('🔧 AuthConfig.getOAuthCallbackUrl(): $url');
    print('🔧 Usando ${useSupabaseCallback ? "Supabase" : "Custom"} callback URL');
    return url;
  }
  
  /// Retorna a URL de reset de password
  static String getResetPasswordUrl() {
    print('🔧 AuthConfig.getResetPasswordUrl(): $resetPasswordUrl');
    return resetPasswordUrl;
  }
  
  /// Retorna a URL de confirmação de email
  static String getConfirmEmailUrl() {
    print('🔧 AuthConfig.getConfirmEmailUrl(): $confirmEmailUrl');
    return confirmEmailUrl;
  }
  
  /// Configurações do Google OAuth
  static const googleOAuthConfig = {
    'scopes': ['email', 'profile'],
    'responseType': 'code',
  };
  
  /// Configurações do Apple OAuth
  static const appleOAuthConfig = {
    'scopes': ['name', 'email'],
    'responseType': 'code',
  };
  
  /// URLs que devem estar configuradas no Supabase Auth
  static List<String> get requiredSupabaseUrls => [
    oauthCallbackUrl,
    supabaseCallbackUrl,
    resetPasswordUrl,
    confirmEmailUrl,
  ];
  
  /// URLs que devem estar configuradas no Google Cloud Console
  static List<String> get requiredGoogleUrls => [
    useSupabaseCallback ? supabaseCallbackUrl : oauthCallbackUrl,
  ];
  
  /// Validação de configuração com logs detalhados
  static void validateConfiguration() {
    print('');
    print('🔧 ========== VALIDAÇÃO DE CONFIGURAÇÃO AUTH ==========');
    print('🔧 AuthConfig: URLs configuradas:');
    print('🔧   Base URL: $baseUrl');
    print('🔧   OAuth Callback (Custom): $oauthCallbackUrl');
    print('🔧   OAuth Callback (Supabase): $supabaseCallbackUrl');
    print('🔧   USANDO: ${useSupabaseCallback ? supabaseCallbackUrl : oauthCallbackUrl}');
    print('🔧   Reset Password: $resetPasswordUrl');
    print('🔧   Confirm Email: $confirmEmailUrl');
    print('🔧 ');
    print('🔧 Google Client IDs:');
    print('🔧   Web Application: $googleWebClientId');
    print('🔧   iOS Application: $googleIosClientId');
    print('🔧   OAuth Nativo usa: $googleWebClientId (para compatibilidade com Supabase)');
    print('🔧   OAuth Web usa: $googleWebClientId');
    print('🔧 ');
    print('🔧 Deep Link Schemes:');
    print('🔧   App Scheme: $appScheme');
    print('🔧   Login Callback: $loginCallbackDeepLink');
    print('🔧   Reset Password: $resetPasswordDeepLink');
    print('🔧   Confirm Email: $confirmDeepLink');
    print('🔧 ');
    print('🔧 URLs requeridas no Supabase:');
    for (int i = 0; i < requiredSupabaseUrls.length; i++) {
      print('🔧   ${i + 1}. ${requiredSupabaseUrls[i]}');
    }
    print('🔧 ');
    print('🔧 URLs requeridas no Google Cloud Console (Web Application):');
    for (int i = 0; i < requiredGoogleUrls.length; i++) {
      print('🔧   ${i + 1}. ${requiredGoogleUrls[i]}');
    }
    print('🔧 ');
    print('🔧 ⚠️  OAUTH MODE: HÍBRIDO (Nativo + Web)');
    print('🔧 ⚠️  1ª tentativa: OAuth Nativo (mais confiável)');
    print('🔧 ⚠️  2ª tentativa: OAuth Web (fallback)');
    print('🔧 ⚠️  AMBOS usam Web Client ID para compatibilidade com Supabase');
    print('🔧 =====================================================');
    print('');
  }
  
  /// Logs detalhados para debug de OAuth
  static void logOAuthAttempt(String provider, String platform, String redirectUrl) {
    print('');
    print('🔐 ========== TENTATIVA DE LOGIN OAUTH ==========');
    print('🔐 Provider: $provider');
    print('🔐 Platform: $platform');
    print('🔐 Redirect URL: $redirectUrl');
    print('🔐 Timestamp: ${DateTime.now().toIso8601String()}');
    
    // Logs específicos por provider
    if (provider.toLowerCase() == 'google') {
      print('🔐 Google OAuth Config:');
      print('🔐   Scopes: ${googleOAuthConfig['scopes']}');
      print('🔐   Response Type: ${googleOAuthConfig['responseType']}');
      print('🔐   Client ID (Web): $googleWebClientId');
      print('🔐   Client ID (iOS): $googleIosClientId');
    } else if (provider.toLowerCase() == 'apple') {
      print('🔐 Apple OAuth Config:');
      print('🔐   Scopes: ${appleOAuthConfig['scopes']}');
      print('🔐   Response Type: ${appleOAuthConfig['responseType']}');
      print('🔐   Apple Sign In: Usa configuração automática do iOS');
    }
    
    print('🔐 ===============================================');
    print('');
  }
  
  /// Logs detalhados para debug de reset de senha
  static void logPasswordReset(String email, String redirectUrl) {
    print('');
    print('🔑 ========== RESET DE SENHA ==========');
    print('🔑 Email: $email');
    print('🔑 Redirect URL: $redirectUrl');
    print('🔑 Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔑 =====================================');
    print('');
  }
  
  /// Logs detalhados para debug de cadastro
  static void logSignUp(String email, String redirectUrl) {
    print('');
    print('📝 ========== CADASTRO DE USUÁRIO ==========');
    print('📝 Email: $email');
    print('📝 Redirect URL: $redirectUrl');
    print('📝 Timestamp: ${DateTime.now().toIso8601String()}');
    print('📝 ==========================================');
    print('');
  }
  
  /// Valida se todas as configurações necessárias estão presentes
  static bool validate() {
    final errors = <String>[];
    
    if (EnvironmentManager.supabaseUrl.isEmpty) {
      errors.add('Supabase URL não configurada');
    }
    
    if (googleWebClientId.isEmpty) {
      errors.add('Google Web Client ID não configurado');
    }
    
    if (googleIosClientId.isEmpty) {
      errors.add('Google iOS Client ID não configurado');
    }
    
    if (errors.isNotEmpty) {
      print('❌ Erros de configuração de autenticação:');
      for (final error in errors) {
        print('  - $error');
      }
      return false;
    }
    
    return true;
  }
} 