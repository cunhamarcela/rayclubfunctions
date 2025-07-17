import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // print('🍎 TESTE DE CONFIGURAÇÃO - SIGN IN WITH APPLE');
  // print('=' * 60);
  
  await _testEnvironmentVariables();
  await _testIOSConfiguration();
  await _testEntitlements();
  _showSummary();
}

Future<void> _testEnvironmentVariables() async {
  // print('\n1️⃣ VARIÁVEIS DE AMBIENTE');
  // print('-' * 30);
  
  try {
    await dotenv.load(fileName: ".env");
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    // print('✅ Arquivo .env carregado');
    // print('✅ SUPABASE_URL: ${supabaseUrl.isNotEmpty ? "Configurada" : "❌ Não encontrada"}');
    // print('✅ SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? "Configurada" : "❌ Não encontrada"}');
    
    if (supabaseUrl.contains('zsbbgchsjiuicwvtrldn.supabase.co')) {
      // print('✅ URL do Supabase correta');
    } else {
      // print('⚠️  URL do Supabase pode não estar correta');
    }
  } catch (e) {
    // print('❌ Erro ao carregar .env: $e');
  }
}

Future<void> _testIOSConfiguration() async {
  // print('\n2️⃣ CONFIGURAÇÃO iOS');
  // print('-' * 30);
  
  // Testar Info.plist
  final infoPlist = File('ios/Runner/Info.plist');
  if (await infoPlist.exists()) {
    final content = await infoPlist.readAsString();
    
    // print('✅ Info.plist encontrado');
    
    // Verificar URL schemes
    if (content.contains('rayclub') && content.contains('com.rayclub.app')) {
      // print('✅ URL Schemes configurados (rayclub, com.rayclub.app)');
    } else {
      // print('❌ URL Schemes não encontrados');
    }
    
    // Verificar App Transport Security
    if (content.contains('appleid.apple.com') && content.contains('zsbbgchsjiuicwvtrldn.supabase.co')) {
      // print('✅ App Transport Security configurado para Apple e Supabase');
    } else {
      // print('⚠️  App Transport Security pode estar incompleto');
    }
    
    // Verificar WKAppBoundDomains
    if (content.contains('WKAppBoundDomains')) {
      // print('✅ WKAppBoundDomains configurado');
    } else {
      // print('⚠️  WKAppBoundDomains não encontrado');
    }
  } else {
    // print('❌ Info.plist não encontrado');
  }
}

Future<void> _testEntitlements() async {
  // print('\n3️⃣ ENTITLEMENTS');
  // print('-' * 30);
  
  final entitlements = File('ios/Runner/Runner.entitlements');
  if (await entitlements.exists()) {
    final content = await entitlements.readAsString();
    
    // print('✅ Runner.entitlements encontrado');
    
    // Verificar Sign in with Apple
    if (content.contains('com.apple.developer.applesignin')) {
      // print('✅ Sign in with Apple entitlement configurado');
    } else {
      // print('❌ Sign in with Apple entitlement não encontrado');
    }
    
    // Verificar Associated Domains
    if (content.contains('com.apple.developer.associated-domains')) {
      // print('✅ Associated Domains configurado');
      
      if (content.contains('zsbbgchsjiuicwvtrldn.supabase.co')) {
        // print('✅ Domain do Supabase incluído nos Associated Domains');
      } else {
        // print('⚠️  Domain do Supabase não encontrado nos Associated Domains');
      }
    } else {
      // print('❌ Associated Domains não configurado');
    }
  } else {
    // print('❌ Runner.entitlements não encontrado');
  }
}

void _showSummary() {
  // print('\n' + '=' * 60);
  // print('📋 RESUMO');
  // print('=' * 60);
  // print('');
  // print('✅ ATUALIZAÇÕES REALIZADAS:');
  // print('   • sign_in_with_apple: 5.0.0 → 6.1.4');
  // print('   • supabase_flutter: 2.3.2 → 2.5.6');
  // print('   • Supabase core packages atualizados');
  // print('   • Info.plist configurado com App Transport Security');
  // print('   • URL schemes para Apple OAuth adicionados');
  // print('   • Privacy manifest adicionado');
  // print('');
  // print('🔍 PRÓXIMOS PASSOS:');
  // print('   1. Testar em dispositivo físico (não funciona no simulador)');
  // print('   2. Verificar configuração no Apple Developer Console');
  // print('   3. Confirmar Service ID: com.rayclub.auth');
  // print('   4. Verificar Redirect URLs no Supabase');
  // print('');
  // print('⚠️  LEMBRE-SE: Sign in with Apple só funciona em:');
  // print('   • Dispositivos físicos (iPhone/iPad)');
  // print('   • Com conta Apple Developer ativa');
  // print('   • Com Service ID configurado corretamente');
} 