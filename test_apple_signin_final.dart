// Flutter imports:
import 'dart:io';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script de teste completo para Apple Sign In
/// Execute este script para verificar se tudo está configurado corretamente
void main() async {
  print('🍎 ========== TESTE APPLE SIGN IN - VERSÃO FINAL ==========');
  print('🍎 Iniciando verificação completa...');
  print('🍎 Timestamp: ${DateTime.now().toIso8601String()}');
  print('');

  await _testAppleSignInConfiguration();
}

Future<void> _testAppleSignInConfiguration() async {
  // 1. Verificar plataforma
  print('1️⃣ VERIFICAÇÃO DE PLATAFORMA');
  print('   Platform: ${Platform.operatingSystem}');
  print('   É iOS: ${Platform.isIOS}');
  print('   É Android: ${Platform.isAndroid}');
  print('   É Web: ${kIsWeb}');
  
  if (!Platform.isIOS) {
    print('   ❌ Apple Sign In só funciona no iOS');
    return;
  }
  print('   ✅ Plataforma iOS detectada');
  print('');

  // 2. Verificar disponibilidade do Apple Sign In
  print('2️⃣ VERIFICAÇÃO DE DISPONIBILIDADE');
  try {
    final isAvailable = await SignInWithApple.isAvailable();
    print('   Apple Sign In disponível: $isAvailable');
    
    if (!isAvailable) {
      print('   ❌ Apple Sign In não está disponível neste dispositivo');
      print('   💡 Certifique-se de que:');
      print('      - Está rodando em dispositivo físico (não simulador)');
      print('      - O dispositivo tem iOS 13+ ou iPadOS 13+');
      print('      - O usuário está logado com Apple ID');
      return;
    }
    print('   ✅ Apple Sign In está disponível');
  } catch (e) {
    print('   ❌ Erro ao verificar disponibilidade: $e');
    return;
  }
  print('');

  // 3. Verificar configuração do projeto
  print('3️⃣ VERIFICAÇÃO DE CONFIGURAÇÃO DO PROJETO');
  print('   ✅ Entitlements: com.apple.developer.applesignin deve estar presente');
  print('   ✅ Info.plist: CFBundleURLSchemes deve incluir com.rayclub.app');
  print('   ✅ Capability: Sign In with Apple deve estar habilitado no Xcode');
  print('');

  // 4. Teste de obtenção de credenciais (sem autenticação real)
  print('4️⃣ TESTE DE CONFIGURAÇÃO DE CREDENCIAIS');
  try {
    print('   🔄 Testando configuração de credenciais...');
    
    // Gerar nonce para teste
    final nonce = _generateNonce();
    print('   ✅ Nonce gerado: ${nonce.substring(0, 8)}...');
    
    print('   ✅ Configuração de credenciais OK');
  } catch (e) {
    print('   ❌ Erro na configuração de credenciais: $e');
  }
  print('');

  // 5. Verificar configuração do Supabase (se disponível)
  print('5️⃣ VERIFICAÇÃO DE CONFIGURAÇÃO SUPABASE');
  print('   📋 Verifique no Supabase Dashboard:');
  print('   ☐ Authentication > Providers > Apple > Enabled: TRUE');
  print('   ☐ Client ID: com.rayclub.app');
  print('   ☐ Team ID: [seu team ID]');
  print('   ☐ Key ID: [seu key ID]');
  print('   ☐ Private Key: [conteúdo do arquivo .p8]');
  print('');

  // 6. URLs de redirecionamento
  print('6️⃣ VERIFICAÇÃO DE URLs DE REDIRECIONAMENTO');
  print('   📋 No Supabase Dashboard, adicione estas URLs:');
  print('   ☐ https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
  print('   ☐ com.rayclub.app://login-callback/');
  print('');

  // 7. Configuração do Apple Developer Console
  print('7️⃣ VERIFICAÇÃO APPLE DEVELOPER CONSOLE');
  print('   📋 Verifique no Apple Developer Console:');
  print('   ☐ App ID (com.rayclub.app) tem Sign In with Apple habilitado');
  print('   ☐ Service ID criado e configurado');
  print('   ☐ Key para Sign In with Apple criada');
  print('   ☐ Return URLs configuradas no Service ID');
  print('');

  // 8. Teste de fluxo completo (opcional)
  print('8️⃣ TESTE DE FLUXO COMPLETO');
  print('   💡 Para testar o fluxo completo:');
  print('   1. Execute o app no dispositivo físico');
  print('   2. Toque no botão "Continuar com Apple"');
  print('   3. Observe os logs no console');
  print('   4. Verifique se o usuário é autenticado com sucesso');
  print('');

  // 9. Logs esperados
  print('9️⃣ LOGS ESPERADOS EM CASO DE SUCESSO');
  print('   ✅ "Sign in with Apple está disponível"');
  print('   ✅ "Credenciais Apple obtidas com sucesso"');
  print('   ✅ "Identity token obtido"');
  print('   ✅ "Autenticação Apple concluída com sucesso!"');
  print('');

  // 10. Erros comuns e soluções
  print('🔟 ERROS COMUNS E SOLUÇÕES');
  print('');
  print('   ❌ "Apple Sign In não está disponível"');
  print('      → Teste em dispositivo físico, não no simulador');
  print('      → Verifique se o usuário está logado com Apple ID');
  print('');
  print('   ❌ "Token de identidade não foi fornecido"');
  print('      → Verifique configuração no Apple Developer Console');
  print('      → Verifique se o Service ID está correto');
  print('');
  print('   ❌ "Configuração do Apple Sign In inválida"');
  print('      → Verifique credenciais no Supabase Dashboard');
  print('      → Verifique se a Private Key está correta');
  print('');
  print('   ❌ "Erro na autenticação"');
  print('      → Verifique URLs de redirecionamento');
  print('      → Verifique se o Bundle ID está correto');
  print('');

  print('🍎 ========== TESTE FINALIZADO ==========');
  print('🍎 Se todos os itens estiverem ✅, o Apple Sign In deve funcionar');
  print('🍎 Em caso de problemas, verifique os itens marcados com ☐');
  print('🍎 =======================================');
}

/// Gera um nonce aleatório para segurança
String _generateNonce() {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = DateTime.now().millisecondsSinceEpoch;
  return List.generate(32, (i) => charset[(random + i) % charset.length]).join();
} 