import 'dart:io';

void main() async {
  print('🍎 DIAGNÓSTICO COMPLETO - SIGN IN WITH APPLE');
  print('=' * 60);
  print('⚠️  Nota: Sign in with Apple só funciona em dispositivos físicos');
  print('=' * 60);
  
  await _checkFiles();
  await _checkIOSConfig();
  await _checkEnvFile();
  _showNextSteps();
}

Future<void> _checkFiles() async {
  print('\n📂 1. VERIFICANDO ARQUIVOS ESSENCIAIS');
  print('-' * 40);
  
  final files = {
    'pubspec.yaml': 'Configuração do projeto',
    'ios/Runner/Info.plist': 'Configuração iOS',
    'ios/Runner/Runner.entitlements': 'Entitlements do iOS',
    '.env': 'Variáveis de ambiente',
    'lib/features/auth/repositories/auth_repository.dart': 'Repository de autenticação',
    'lib/features/auth/viewmodels/auth_viewmodel.dart': 'ViewModel de autenticação',
  };
  
  for (final entry in files.entries) {
    final file = File(entry.key);
    if (await file.exists()) {
      print('✅ ${entry.key}: ${entry.value}');
    } else {
      print('❌ ${entry.key}: ARQUIVO NÃO ENCONTRADO');
    }
  }
}

Future<void> _checkIOSConfig() async {
  print('\n📱 2. VERIFICANDO CONFIGURAÇÃO iOS');
  print('-' * 40);
  
  // Verificar Info.plist
  final infoPlist = File('ios/Runner/Info.plist');
  if (await infoPlist.exists()) {
    final content = await infoPlist.readAsString();
    print('✅ Info.plist encontrado');
    
    if (content.contains('rayclub') && content.contains('CFBundleURLSchemes')) {
      print('  ✅ URL Scheme "rayclub" configurado');
    } else {
      print('  ❌ URL Scheme "rayclub" NÃO encontrado');
    }
    
    if (content.contains('com.apple.developer.associated-domains')) {
      print('  ✅ Associated Domains configurado');
    } else {
      print('  ⚠️  Associated Domains não encontrado (opcional)');
    }
  }
  
  // Verificar Runner.entitlements
  final entitlements = File('ios/Runner/Runner.entitlements');
  if (await entitlements.exists()) {
    final content = await entitlements.readAsString();
    print('✅ Runner.entitlements encontrado');
    
    if (content.contains('com.apple.developer.applesignin')) {
      print('  ✅ Sign in with Apple entitlement configurado');
    } else {
      print('  ❌ Sign in with Apple entitlement NÃO encontrado');
    }
  }
  
  // Verificar pubspec.yaml
  final pubspec = File('pubspec.yaml');
  if (await pubspec.exists()) {
    final content = await pubspec.readAsString();
    print('✅ pubspec.yaml encontrado');
    
    if (content.contains('sign_in_with_apple')) {
      print('  ✅ Dependência sign_in_with_apple configurada');
    } else {
      print('  ❌ Dependência sign_in_with_apple NÃO encontrada');
    }
  }
}

Future<void> _checkEnvFile() async {
  print('\n🔐 3. VERIFICANDO VARIÁVEIS DE AMBIENTE');
  print('-' * 40);
  
  final envFile = File('.env');
  if (await envFile.exists()) {
    final content = await envFile.readAsString();
    print('✅ Arquivo .env encontrado');
    
    final hasSupabaseUrl = content.contains('SUPABASE_URL=');
    final hasSupabaseKey = content.contains('SUPABASE_ANON_KEY=');
    final hasAppleClientId = content.contains('APPLE_CLIENT_ID=');
    
    print('  ${hasSupabaseUrl ? "✅" : "❌"} SUPABASE_URL');
    print('  ${hasSupabaseKey ? "✅" : "❌"} SUPABASE_ANON_KEY');
    print('  ${hasAppleClientId ? "✅" : "⚠️ "} APPLE_CLIENT_ID (opcional)');
    
    if (hasSupabaseUrl) {
      final urlMatch = RegExp(r'SUPABASE_URL=(.+)').firstMatch(content);
      if (urlMatch != null) {
        final url = urlMatch.group(1)?.trim() ?? '';
        print('  📍 URL: ${url.substring(0, url.length > 30 ? 30 : url.length)}...');
      }
    }
  } else {
    print('❌ Arquivo .env NÃO encontrado');
  }
}

void _showNextSteps() {
  print('\n🔍 4. PRÓXIMOS PASSOS PARA TESTE');
  print('=' * 60);
  
  print('\n1️⃣ CONECTE UM DISPOSITIVO FÍSICO iOS');
  print('   - iPhone ou iPad com iOS 13+');
  print('   - Cable USB conectado ao Mac');
  print('   - Dispositivo desbloqueado e confiável');
  
  print('\n2️⃣ COMPILE PARA O DISPOSITIVO:');
  print('   flutter devices  # lista dispositivos');
  print('   flutter run --device-id [device-id]');
  
  print('\n3️⃣ VERIFICAÇÕES NO APPLE DEVELOPER:');
  print('   ✅ App ID: com.rayclub.app');
  print('   ✅ Service ID: com.rayclub.auth');
  print('   ✅ Key ID: A9CM2RXUWB');
  print('   ✅ Team ID: [verificar se está correto]');
  print('   ✅ Private Key (.p8): [arquivo baixado]');
  
  print('\n4️⃣ VERIFICAÇÕES NO SUPABASE:');
  print('   ✅ Authentication > Providers > Apple > Enabled');
  print('   ✅ Client ID: com.rayclub.auth');
  print('   ✅ Team ID: A9CM2RXUWB');
  print('   ✅ Key ID: [sua key]');
  print('   ✅ Private Key: [conteúdo do .p8]');
  
  print('\n5️⃣ TESTE NO DISPOSITIVO:');
  print('   - Toque no botão "Sign in with Apple"');
  print('   - Deve abrir interface nativa do iOS');
  print('   - Complete o login/senha');
  print('   - Verifique se retorna para o app');
  
  print('\n🐛 SE DER ERRO:');
  print('   - Use Xcode para ver logs detalhados');
  print('   - Window > Devices and Simulators');
  print('   - Selecione seu device > Open Console');
  print('   - Filtre por "rayclub" ou "supabase"');
  
  print('\n📋 CONFIGURAÇÃO SUPABASE REQUERIDA:');
  print('   Redirect URLs:');
  print('   - https://[seu-supabase-url]/auth/v1/callback');
  print('   - https://rayclub.com.br/auth/callback');
  
  print('\n✅ Diagnóstico finalizado!');
  print('📞 Se o erro persistir, execute no dispositivo e');
  print('   capture os logs para análise detalhada.');
} 