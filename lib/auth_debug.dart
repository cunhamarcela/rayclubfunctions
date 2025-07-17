import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Classe utilitária para diagnóstico de problemas de autenticação
class AuthDebugUtils {
  /// Imprime informações de diagnóstico no console para ajudar a depurar problemas de autenticação
  static void printAuthDebugInfo() {
    debugPrint('🔍 ---- INFORMAÇÕES DE DIAGNÓSTICO PARA AUTENTICAÇÃO ----');
    
    // Plataforma
    if (kIsWeb) {
      debugPrint('📱 Plataforma: Web');
    } else {
      debugPrint('📱 Plataforma: ${Platform.operatingSystem}');
      debugPrint('📱 Versão: ${Platform.operatingSystemVersion}');
    }
    
    // Verificar cliente Supabase
    try {
      final client = Supabase.instance.client;
      debugPrint('✅ Supabase inicializado');
      
      // Verificar sessão atual
      final session = client.auth.currentSession;
      if (session != null) {
        debugPrint('✅ Sessão ativa: Sim');
        debugPrint('✅ Usuário: ${session.user.email ?? 'Email não definido'}');
        debugPrint('✅ Expiração do token: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000) : 'Não definido'}');
      } else {
        debugPrint('❌ Sessão ativa: Não');
      }
      
      // Verificar configuração de PKCE
      // A linha abaixo foi removida porque authStore.flowType pode não existir na versão atual
      // debugPrint('✅ Supabase inicializado com AuthFlowType: ${client.auth.authStore.flowType.name}');
    } catch (e) {
      debugPrint('❌ Erro ao acessar Supabase: $e');
    }
    
    // Verificar deep link (Android)
    if (!kIsWeb && Platform.isAndroid) {
      debugPrint('ℹ️ Android Deep Link deve ter: <data android:scheme="rayclub" android:host="login-callback" />');
    }
    
    // Verificar deep link (iOS)
    if (!kIsWeb && Platform.isIOS) {
      debugPrint('ℹ️ iOS Deep Link deve ter: <string>rayclub</string> e <key>FlutterDeepLinkingEnabled</key><true/>');
    }
    
    debugPrint('ℹ️ Supabase deve ter URL redirecionamento: rayclub://login-callback/');
    debugPrint('ℹ️ GCP deve ter URL redirecionamento: https://XXXXXXXX.supabase.co/auth/v1/callback');
    
    debugPrint('🔍 ---- FIM DAS INFORMAÇÕES DE DIAGNÓSTICO ----');
  }
} 