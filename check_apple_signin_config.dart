import 'dart:io';

void main() {
  print('🔍 DIAGNÓSTICO APPLE SIGN IN - Ray Club App');
  print('=' * 50);
  
  // Verificar arquivos de configuração
  checkInfoPlist();
  checkEntitlements();
  checkPodfile();
  checkCapabilities();
  
  print('\n✅ PRÓXIMOS PASSOS:');
  print('1. Verifique se no Xcode está configurado:');
  print('   - Target Runner → Signing & Capabilities');
  print('   - Sign In with Apple capability adicionada');
  print('   - Team selecionado corretamente');
  print('   - Bundle ID = com.rayclub.app');
  print('\n2. No Apple Developer Console:');
  print('   - https://developer.apple.com/account/');
  print('   - Identifiers → com.rayclub.app');
  print('   - Sign In with Apple ✓ habilitado');
  print('\n3. Teste em dispositivo REAL (não simulador)');
  print('4. Certifique-se que está logado com Apple ID no dispositivo');
}

void checkInfoPlist() {
  print('\n📱 VERIFICANDO INFO.PLIST:');
  
  final file = File('ios/Runner/Info.plist');
  if (!file.existsSync()) {
    print('❌ Info.plist não encontrado');
    return;
  }
  
  final content = file.readAsStringSync();
  
  // Verificar CFBundleURLSchemes
  if (content.contains('com.rayclub.app')) {
    print('✅ Bundle URL Scheme encontrado: com.rayclub.app');
  } else {
    print('❌ Bundle URL Scheme com.rayclub.app NÃO encontrado');
  }
  
  // Verificar FlutterDeepLinkingEnabled
  if (content.contains('FlutterDeepLinkingEnabled') && content.contains('<true/>')) {
    print('✅ FlutterDeepLinkingEnabled configurado');
  } else {
    print('❌ FlutterDeepLinkingEnabled NÃO configurado');
  }
  
  // Verificar rayclub scheme
  if (content.contains('<string>rayclub</string>')) {
    print('✅ Scheme rayclub encontrado');
  } else {
    print('❌ Scheme rayclub NÃO encontrado');
  }
}

void checkEntitlements() {
  print('\n🔐 VERIFICANDO ENTITLEMENTS:');
  
  final file = File('ios/Runner/Runner.entitlements');
  if (!file.existsSync()) {
    print('❌ Runner.entitlements não encontrado');
    return;
  }
  
  final content = file.readAsStringSync();
  
  // Verificar Apple Sign In entitlement
  if (content.contains('com.apple.developer.applesignin')) {
    print('✅ Apple Sign In entitlement encontrado');
  } else {
    print('❌ Apple Sign In entitlement NÃO encontrado');
  }
  
  // Verificar associated domains
  if (content.contains('com.apple.developer.associated-domains')) {
    print('✅ Associated domains configurado');
  } else {
    print('❌ Associated domains NÃO configurado');
  }
}

void checkPodfile() {
  print('\n📦 VERIFICANDO PODFILE:');
  
  final file = File('ios/Podfile');
  if (!file.existsSync()) {
    print('❌ Podfile não encontrado');
    return;
  }
  
  final content = file.readAsStringSync();
  
  // Verificar plataforma iOS
  if (content.contains("platform :ios, '")) {
    final regex = RegExp(r"platform :ios, '(\d+\.\d+)'");
    final match = regex.firstMatch(content);
    if (match != null) {
      final version = match.group(1);
      print('✅ Plataforma iOS: $version');
      
      if (double.parse(version!) >= 13.0) {
        print('✅ Versão iOS compatível com Apple Sign In (13.0+)');
      } else {
        print('❌ Versão iOS muito baixa para Apple Sign In (requer 13.0+)');
      }
    }
  } else {
    print('❌ Plataforma iOS não definida no Podfile');
  }
}

void checkCapabilities() {
  print('\n🛠️ VERIFICANDO CAPABILITIES:');
  
  final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!pbxprojFile.existsSync()) {
    print('❌ project.pbxproj não encontrado');
    return;
  }
  
  final content = pbxprojFile.readAsStringSync();
  
  // Verificar Bundle ID
  if (content.contains('PRODUCT_BUNDLE_IDENTIFIER = com.rayclub.app')) {
    print('✅ Bundle ID correto encontrado no projeto');
  } else {
    print('❌ Bundle ID com.rayclub.app NÃO encontrado no projeto');
  }
  
  // Verificar se existe entitlements reference
  if (content.contains('Runner.entitlements')) {
    print('✅ Entitlements file referenciado no projeto');
  } else {
    print('❌ Entitlements file NÃO referenciado');
  }
} 