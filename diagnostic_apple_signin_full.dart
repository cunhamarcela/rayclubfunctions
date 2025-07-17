import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print('🍎 DIAGNÓSTICO COMPLETO - SIGN IN WITH APPLE');
  print('=' * 60);
  print('⚠️  Nota: Sign in with Apple só funciona em dispositivos físicos');
  print('=' * 60);
  
  // Carregar variáveis de ambiente
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Arquivo .env carregado com sucesso');
  } catch (e) {
    print('❌ Erro ao carregar .env: $e');
    return;
  }
  
  await _checkEnvironmentVariables();
  await _checkIOSConfiguration();
  await _checkPubspecDependencies();
  await _checkSupabaseProvider();
  await _checkImplementationFiles();
  await _generateReport();
}

Future<void> _checkEnvironmentVariables() async {
  print('\n📋 1. VERIFICANDO VARIÁVEIS DE AMBIENTE');
  print('-' * 40);
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  final appleClientId = dotenv.env['APPLE_CLIENT_ID'] ?? '';
  
  print('✅ SUPABASE_URL: ${supabaseUrl.isNotEmpty ? "Configurada (${supabaseUrl.substring(0, 20)}...)" : "❌ NÃO CONFIGURADA"}');
  print('✅ SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? "Configurada" : "❌ NÃO CONFIGURADA"}');
  print('🍎 APPLE_CLIENT_ID: ${appleClientId.isNotEmpty ? "Configurada ($appleClientId)" : "⚠️  NÃO CONFIGURADA (opcional)"}');
}

Future<void> _checkIOSConfiguration() async {
  print('\n📱 2. VERIFICANDO CONFIGURAÇÃO iOS');
  print('-' * 40);
  
  // Verificar Info.plist
  final infoPlist = File('ios/Runner/Info.plist');
  if (await infoPlist.exists()) {
    final content = await infoPlist.readAsString();
    
    print('✅ Info.plist encontrado');
    
    // Verificar URL Schemes
    if (content.contains('rayclub') && content.contains('CFBundleURLSchemes')) {
      print('✅ URL Scheme "rayclub" configurado');
    } else {
      print('❌ URL Scheme "rayclub" NÃO encontrado');
    }
    
    // Verificar Associated Domains
    if (content.contains('com.apple.developer.associated-domains')) {
      print('✅ Associated Domains configurado');
    } else {
      print('⚠️  Associated Domains não encontrado (opcional)');
    }
  } else {
    print('❌ Info.plist não encontrado');
  }
  
  // Verificar Runner.entitlements
  final entitlements = File('ios/Runner/Runner.entitlements');
  if (await entitlements.exists()) {
    final content = await entitlements.readAsString();
    
    print('✅ Runner.entitlements encontrado');
    
    if (content.contains('com.apple.developer.applesignin')) {
      print('✅ Sign in with Apple entitlement configurado');
    } else {
      print('❌ Sign in with Apple entitlement NÃO encontrado');
    }
  } else {
    print('❌ Runner.entitlements não encontrado');
  }
  
  // Verificar project.pbxproj
  final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
  if (await pbxproj.exists()) {
    final content = await pbxproj.readAsString();
    
    if (content.contains('com.apple.developer.applesignin')) {
      print('✅ Capability configurado no Xcode project');
    } else {
      print('⚠️  Capability pode não estar configurado no Xcode');
    }
  }
}

Future<void> _checkPubspecDependencies() async {
  print('\n📦 3. VERIFICANDO DEPENDÊNCIAS');
  print('-' * 40);
  
  final pubspec = File('pubspec.yaml');
  if (await pubspec.exists()) {
    final content = await pubspec.readAsString();
    
    final dependencies = [
      'sign_in_with_apple',
      'supabase_flutter',
      'flutter_riverpod',
    ];
    
    for (final dep in dependencies) {
      if (content.contains(dep)) {
        print('✅ $dep: Configurado');
      } else {
        print('❌ $dep: NÃO encontrado');
      }
    }
  }
}

Future<void> _checkSupabaseProvider() async {
  print('\n🔧 4. VERIFICANDO CONFIGURAÇÃO SUPABASE');
  print('-' * 40);
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  
  if (supabaseUrl.isNotEmpty) {
    print('✅ Supabase URL configurada');
    print('📍 URL: $supabaseUrl');
    print('');
    print('🔍 VERIFIQUE NO SUPABASE DASHBOARD:');
    print('   1. Authentication > Providers > Apple');
    print('   2. Enabled: ✅ TRUE');
    print('   3. Client ID: com.rayclub.auth (ou similar)');
    print('   4. Team ID: A9CM2RXUWB');
    print('   5. Key ID: [sua key]');
    print('   6. Private Key: [conteúdo do arquivo .p8]');
    print('');
    print('🔍 VERIFIQUE AS REDIRECT URLs:');
    print('   - ${supabaseUrl}/auth/v1/callback');
    print('   - https://rayclub.com.br/auth/callback');
  } else {
    print('❌ Supabase URL não configurada');
  }
}

Future<void> _checkImplementationFiles() async {
  print('\n💻 5. VERIFICANDO IMPLEMENTAÇÃO');
  print('-' * 40);
  
  final filesToCheck = [
    'lib/features/auth/repositories/auth_repository.dart',
    'lib/features/auth/viewmodels/auth_viewmodel.dart',
    'lib/features/auth/screens/login_screen.dart',
  ];
  
  for (final filePath in filesToCheck) {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      
      print('✅ $filePath: Arquivo encontrado');
      
      // Verificar imports essenciais
      if (content.contains('sign_in_with_apple')) {
        print('   ✅ Import do sign_in_with_apple');
      }
      
      // Verificar implementação do método
      if (content.contains('signInWithApple') || content.contains('SignInWithApple')) {
        print('   ✅ Método signInWithApple implementado');
      }
      
      // Verificar Provider no Supabase
      if (content.contains('OAuthProvider.apple') || content.contains('Provider.apple')) {
        print('   ✅ Provider Apple configurado para Supabase');
      }
    } else {
      print('❌ $filePath: Arquivo não encontrado');
    }
  }
}

Future<void> _generateReport() async {
  print('\n📊 6. RELATÓRIO FINAL');
  print('=' * 60);
  
  print('🔍 PRÓXIMOS PASSOS PARA TESTAR:');
  print('');
  print('1️⃣ COMPILE PARA DISPOSITIVO FÍSICO:');
  print('   flutter build ios --debug');
  print('   ou');
  print('   flutter run --device-id [seu-dispositivo]');
  print('');
  print('2️⃣ VERIFIQUE NO APPLE DEVELOPER:');
  print('   - App ID: com.rayclub.app');
  print('   - Service ID: com.rayclub.auth');
  print('   - Key ID: A9CM2RXUWB');
  print('   - Team ID: deve estar correto');
  print('');
  print('3️⃣ VERIFIQUE NO SUPABASE:');
  print('   - Provider Apple habilitado');
  print('   - Todas as informações do Apple Developer');
  print('   - Redirect URLs corretas');
  print('');
  print('4️⃣ TESTE NO DISPOSITIVO:');
  print('   - Botão Apple aparece?');
  print('   - Abre tela nativa do iOS?');
  print('   - Login completa ou dá erro?');
  print('');
  print('🐛 SE DER ERRO, VERIFIQUE OS LOGS:');
  print('   flutter logs --verbose');
  print('');
  print('💡 DICA: Use Xcode para ver logs mais detalhados:');
  print('   Xcode > Window > Devices and Simulators > [seu device] > Open Console');
  
  print('\n✅ Diagnóstico completo finalizado!');
} 