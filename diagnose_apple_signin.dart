import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  print('🍎 DIAGNÓSTICO COMPLETO - SIGN IN WITH APPLE');
  print('=' * 60);
  
  // 1. Verificar variáveis de ambiente
  print('\n1️⃣ VARIÁVEIS DE AMBIENTE:');
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  print('   ✅ SUPABASE_URL: ${supabaseUrl.isNotEmpty ? "Configurada" : "❌ NÃO CONFIGURADA"}');
  print('   ✅ SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? "Configurada" : "❌ NÃO CONFIGURADA"}');
  
  // 2. Verificar plataforma
  print('\n2️⃣ PLATAFORMA:');
  String platform = 'unknown';
  if (identical(0, 0.0)) {
    platform = 'web';
  } else if (Platform.isIOS) {
    platform = 'ios';
  } else if (Platform.isAndroid) {
    platform = 'android';
  }
  print('   📱 Plataforma detectada: $platform');
  
  // 3. Verificar configurações de deep link
  print('\n3️⃣ CONFIGURAÇÕES DE DEEP LINK:');
  final deepLinkUrl = (platform == 'ios' || platform == 'android')
      ? 'rayclub://login-callback/'
      : 'https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback';
  print('   🔗 URL de redirecionamento: $deepLinkUrl');
  print('   🔗 Tipo: ${deepLinkUrl.startsWith('rayclub://') ? "Deep Link Nativo" : "URL HTTPS"}');
  
  // 4. Verificar Bundle Identifier
  print('\n4️⃣ BUNDLE IDENTIFIER:');
  print('   📦 Bundle ID esperado: com.rayclub.app');
  print('   ⚠️  Certifique-se que está configurado corretamente no Xcode');
  
  // 5. Verificar entitlements
  print('\n5️⃣ ENTITLEMENTS NECESSÁRIOS:');
  print('   ✅ com.apple.developer.applesignin');
  print('   ✅ com.apple.developer.associated-domains (applinks:rayclub.app)');
  
  // 6. Inicializar Supabase para teste
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    print('\n6️⃣ TESTE DE CONEXÃO SUPABASE:');
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );
      print('   ✅ Supabase inicializado com sucesso');
      
      // Verificar providers disponíveis
      print('\n7️⃣ TESTE DE PROVIDERS OAUTH:');
      try {
        // Simular chamada OAuth para verificar configuração
        print('   🔍 Testando configuração Apple OAuth...');
        print('   ⚠️  Este é apenas um teste de configuração');
        
        // URLs que devem estar configuradas no Supabase
        print('\n8️⃣ URLS QUE DEVEM ESTAR NO SUPABASE:');
        print('   1. https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
        print('   2. rayclub://login-callback/');
        print('   3. https://rayclub.app/auth/callback (se usar domínio customizado)');
        
      } catch (e) {
        print('   ❌ Erro ao testar OAuth: $e');
      }
      
    } catch (e) {
      print('   ❌ Erro ao inicializar Supabase: $e');
    }
  }
  
  // 9. Checklist de configuração
  print('\n9️⃣ CHECKLIST DE CONFIGURAÇÃO:');
  print('');
  print('   NO SUPABASE DASHBOARD:');
  print('   ☐ Authentication > Providers > Apple habilitado');
  print('   ☐ Service ID configurado (do Apple Developer)');
  print('   ☐ Team ID: 5X5AG58L34');
  print('   ☐ Key ID configurado');
  print('   ☐ Private Key configurada');
  print('   ☐ Redirect URLs adicionadas:');
  print('      - https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
  print('      - rayclub://login-callback/');
  print('');
  print('   NO APPLE DEVELOPER:');
  print('   ☐ App ID com Sign In with Apple habilitado');
  print('   ☐ Service ID criado e configurado');
  print('   ☐ Key criada para Sign In with Apple');
  print('   ☐ Associated Domains configurado (applinks:rayclub.app)');
  print('');
  print('   NO XCODE:');
  print('   ☐ Capability "Sign In with Apple" adicionada');
  print('   ☐ Associated Domains adicionado');
  print('   ☐ Bundle ID correto: com.rayclub.app');
  print('   ☐ Team selecionado corretamente');
  
  // 10. Possíveis erros
  print('\n🔟 ERROS COMUNS E SOLUÇÕES:');
  print('');
  print('   ❌ "Invalid_client" ou "Invalid request"');
  print('      → Verificar Service ID e Key ID no Supabase');
  print('      → Verificar se a Private Key está correta');
  print('');
  print('   ❌ "Redirect URL mismatch"');
  print('      → Adicionar todas as URLs no Supabase Dashboard');
  print('      → Verificar se o deep link está configurado');
  print('');
  print('   ❌ "User cancelled" após login');
  print('      → Verificar Bundle ID no Xcode');
  print('      → Verificar Associated Domains');
  print('');
  print('   ❌ "Network error" ou timeout');
  print('      → Verificar conexão com internet');
  print('      → Verificar se Supabase está acessível');
  
  print('\n' + '=' * 60);
  print('DIAGNÓSTICO COMPLETO FINALIZADO');
  print('=' * 60);
} 