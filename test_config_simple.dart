import 'dart:io';

void main() async {
  // print('🍎 TESTE DE CONFIGURAÇÃO - SIGN IN WITH APPLE');
  // print('=' * 60);
  
  await _testIOSConfiguration();
  await _testEntitlements();
  _showResults();
}

Future<void> _testIOSConfiguration() async {
  // print('\n📱 CONFIGURAÇÃO iOS');
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
    
    // Verificar Google Client ID
    if (content.contains('GIDClientID')) {
      // print('✅ Google Client ID configurado');
    } else {
      // print('⚠️  Google Client ID não encontrado');
    }
  } else {
    // print('❌ Info.plist não encontrado');
  }
}

Future<void> _testEntitlements() async {
  // print('\n🔑 ENTITLEMENTS');
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

void _showResults() {
  // print('\n' + '=' * 60);
  // print('📋 RESUMO DAS ATUALIZAÇÕES');
  // print('=' * 60);
  // print('');
  // print('✅ DEPENDÊNCIAS ATUALIZADAS:');
  // print('   • sign_in_with_apple: 5.0.0 → 6.1.4');
  // print('   • supabase_flutter: 2.3.2 → 2.5.6');
  // print('   • supabase: 2.0.8 → 2.2.2');
  // print('   • postgrest: 2.0.0 → 2.1.1');
  // print('   • google_sign_in: 6.1.6 → 6.2.1');
  // print('');
  // print('✅ INFO.PLIST ATUALIZADO:');
  // print('   • App Transport Security melhorado');
  // print('   • URL scheme para Apple OAuth adicionado');
  // print('   • Domínios específicos do Supabase e Apple');
  // print('   • Privacy manifest adicionado');
  // print('');
  // print('✅ RUNNER.ENTITLEMENTS ATUALIZADO:');
  // print('   • Associated Domain do Supabase adicionado');
  // print('');
  // print('🔍 PRÓXIMOS PASSOS:');
  // print('   1. Testar em dispositivo físico (iPhone/iPad)');
  // print('   2. Verificar Service ID no Apple Developer Console');
  // print('   3. Confirmar Redirect URLs no Supabase Auth');
  // print('   4. Verificar se o erro persiste');
  // print('');
  // print('⚠️  IMPORTANTE:');
  // print('   • Sign in with Apple NÃO funciona no simulador');
  // print('   • Necessário dispositivo físico para teste');
  // print('   • Service ID: com.rayclub.auth deve estar ativo');
} 