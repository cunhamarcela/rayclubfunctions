import 'dart:io';

/// Script de diagnóstico para verificar configurações OAuth
/// Execute com: dart debug_oauth_configuration.dart
void main() {
  print('🔍 ========== DIAGNÓSTICO DE CONFIGURAÇÃO OAUTH ==========');
  print('');
  
  // Verificar se o arquivo .env existe
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Arquivo .env não encontrado!');
    print('   Por favor, crie o arquivo .env com as configurações necessárias.');
    exit(1);
  }
  
  print('✅ Arquivo .env encontrado');
  
  // Ler o conteúdo do .env
  final envContent = envFile.readAsStringSync();
  final envLines = envContent.split('\n');
  
  // Variáveis de interesse
  final Map<String, String> envVars = {};
  for (final line in envLines) {
    if (line.contains('=') && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        envVars[key] = value;
      }
    }
  }
  
  // Verificar URLs configuradas
  print('');
  print('📋 URLs de Ambiente:');
  print('   SUPABASE_URL: ${envVars['SUPABASE_URL'] ?? 'NÃO ENCONTRADO'}');
  print('   DEV_SUPABASE_URL: ${envVars['DEV_SUPABASE_URL'] ?? 'NÃO ENCONTRADO'}');
  print('   PROD_SUPABASE_URL: ${envVars['PROD_SUPABASE_URL'] ?? 'NÃO ENCONTRADO'}');
  print('');
  
  // Verificar Google Client IDs
  print('🔑 Google Client IDs:');
  print('   GOOGLE_WEB_CLIENT_ID: ${envVars['GOOGLE_WEB_CLIENT_ID'] ?? 'NÃO ENCONTRADO'}');
  print('   GOOGLE_IOS_CLIENT_ID: ${envVars['GOOGLE_IOS_CLIENT_ID'] ?? 'NÃO ENCONTRADO'}');
  print('');
  
  // URLs esperadas
  print('🌐 URLs de Callback Esperadas:');
  print('   Supabase Callback: https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback');
  print('   Custom Callback: https://rayclub.com.br/auth/callback');
  print('');
  
  // Verificar Info.plist
  final infoPlistFile = File('ios/Runner/Info.plist');
  if (infoPlistFile.existsSync()) {
    print('📱 Verificando Info.plist do iOS:');
    final infoPlistContent = infoPlistFile.readAsStringSync();
    
    // Verificar GIDClientID
    if (infoPlistContent.contains('<key>GIDClientID</key>')) {
      final gidRegex = RegExp(r'<key>GIDClientID</key>\s*<string>([^<]+)</string>');
      final gidMatch = gidRegex.firstMatch(infoPlistContent);
      if (gidMatch != null) {
        print('   GIDClientID: ${gidMatch.group(1)}');
      }
    } else {
      print('   ❌ GIDClientID não encontrado no Info.plist');
    }
    
    // Verificar URL Schemes
    if (infoPlistContent.contains('CFBundleURLSchemes')) {
      print('   ✅ CFBundleURLSchemes encontrado');
      
      // Verificar rayclub scheme
      if (infoPlistContent.contains('<string>rayclub</string>')) {
        print('   ✅ URL Scheme "rayclub" configurado');
      } else {
        print('   ⚠️  URL Scheme "rayclub" não encontrado');
      }
      
      // Verificar Google reversed client ID
      if (infoPlistContent.contains('com.googleusercontent.apps.')) {
        print('   ✅ Google reversed client ID configurado');
      } else {
        print('   ⚠️  Google reversed client ID não encontrado');
      }
    } else {
      print('   ❌ CFBundleURLSchemes não encontrado no Info.plist');
    }
  } else {
    print('⚠️  Arquivo ios/Runner/Info.plist não encontrado');
  }
  
  print('');
  print('⚠️  IMPORTANTE - Verificar no Dashboard do Supabase:');
  print('   1. Authentication > URL Configuration');
  print('   2. Site URL deve estar VAZIO ou apontar para o app');
  print('   3. Redirect URLs deve incluir:');
  print('      - https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback');
  print('      - rayclub://login-callback/');
  print('');
  
  print('⚠️  IMPORTANTE - Verificar no Google Cloud Console:');
  print('   1. APIs & Services > Credentials > OAuth 2.0 Client IDs');
  print('   2. Authorized redirect URIs deve incluir:');
  print('      - https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback');
  print('');
  
  print('🔧 SOLUÇÃO ATUAL:');
  print('   Usando LaunchMode.platformDefault (browser externo)');
  print('   até resolver o problema de redirecionamento');
  print('');
  
  print('📱 Para iOS:');
  print('   Info.plist deve ter CFBundleURLSchemes configurado');
  print('   com "rayclub" e o reversed client ID do Google');
  print('');
  
  print('🔧 ========== FIM DO DIAGNÓSTICO ==========');
} 