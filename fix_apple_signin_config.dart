import 'dart:io';

void main() {
  print('🔧 CORREÇÃO AUTOMÁTICA - APPLE SIGN IN');
  print('=' * 50);
  
  fixEntitlementsReference();
  print('\n✅ CORREÇÕES CONCLUÍDAS!');
  print('\n🎯 INSTRUÇÕES MANUAIS NO XCODE:');
  print('1. Abra o Xcode com: open ios/Runner.xcworkspace');
  print('2. Selecione o target "Runner"');
  print('3. Vá para "Signing & Capabilities"');
  print('4. Certifique-se que:');
  print('   ✓ Team está selecionado');
  print('   ✓ Bundle Identifier = com.rayclub.app');
  print('   ✓ "Sign In with Apple" capability está adicionada');
  print('5. Se "Sign In with Apple" não estiver presente:');
  print('   - Clique no botão "+" (Capability)');
  print('   - Procure por "Sign In with Apple"');
  print('   - Adicione a capability');
  print('\n🍎 APPLE DEVELOPER CONSOLE:');
  print('1. Acesse: https://developer.apple.com/account/');
  print('2. Vá para: Certificates, Identifiers & Profiles');
  print('3. Clique em: Identifiers');
  print('4. Procure: com.rayclub.app');
  print('5. Certifique-se que "Sign In with Apple" está ✓ habilitado');
  print('6. Se não estiver, marque a checkbox e salve');
  
  print('\n⚠️  IMPORTANTE:');
  print('- Teste SEMPRE em dispositivo REAL (não simulador)');
  print('- Certifique-se que está logado com Apple ID no dispositivo');
  print('- O erro Code=1000 geralmente é de configuração no Dev Console');
}

void fixEntitlementsReference() {
  print('\n🔧 Corrigindo referência aos entitlements...');
  
  final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!pbxprojFile.existsSync()) {
    print('❌ Arquivo project.pbxproj não encontrado');
    return;
  }
  
  String content = pbxprojFile.readAsStringSync();
  
  // Verificar se a referência já existe
  if (content.contains('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements')) {
    print('✅ Referência aos entitlements já existe');
    return;
  }
  
  // Adicionar referência aos entitlements para configurações Debug, Release e Profile
  final configs = ['Debug', 'Release', 'Profile'];
  bool modified = false;
  
  for (final config in configs) {
    // Procurar por seções de buildSettings para o target Runner
    final pattern = RegExp(
      r'(buildSettings = \{[^}]*PRODUCT_BUNDLE_IDENTIFIER = com\.rayclub\.app[^}]*)',
      multiLine: true,
      dotAll: true
    );
    
    content = content.replaceAllMapped(pattern, (match) {
      String buildSettings = match.group(1)!;
      
      // Se já não contém CODE_SIGN_ENTITLEMENTS, adicionar
      if (!buildSettings.contains('CODE_SIGN_ENTITLEMENTS')) {
        buildSettings = buildSettings.replaceFirst(
          'PRODUCT_BUNDLE_IDENTIFIER = com.rayclub.app;',
          'CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.rayclub.app;'
        );
        modified = true;
        print('✅ Adicionada referência aos entitlements para configuração $config');
      }
      
      return buildSettings;
    });
  }
  
  if (modified) {
    // Fazer backup do arquivo original
    final backupFile = File('ios/Runner.xcodeproj/project.pbxproj.backup');
    backupFile.writeAsStringSync(pbxprojFile.readAsStringSync());
    print('📄 Backup criado: project.pbxproj.backup');
    
    // Escrever o arquivo modificado
    pbxprojFile.writeAsStringSync(content);
    print('✅ Arquivo project.pbxproj atualizado');
  } else {
    print('ℹ️  Nenhuma modificação necessária no project.pbxproj');
  }
} 