import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Script para testar a configuração OAuth do Supabase
/// 
/// Execute com: dart test_supabase_oauth.dart
void main() async {
  // print('🔍 ========== TESTE DE CONFIGURAÇÃO OAUTH SUPABASE ==========');
  // print('');
  
  // Configurações
  const supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
  const googleClientId = '187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com';
  
  // print('📋 Configurações:');
  // print('   Supabase URL: $supabaseUrl');
  // print('   Google Client ID: $googleClientId');
  // print('');
  
  // Teste 1: Verificar se o Supabase está acessível
  // print('🔄 Teste 1: Verificando acesso ao Supabase...');
  try {
    final response = await http.get(Uri.parse('$supabaseUrl/auth/v1/health'));
    // print('   Status: ${response.statusCode}');
    // print('   Response: ${response.body}');
    
    if (response.statusCode == 200) {
      // print('   ✅ Supabase Auth está acessível');
    } else {
      // print('   ❌ Problema ao acessar Supabase Auth');
    }
  } catch (e) {
    // print('   ❌ Erro ao conectar: $e');
  }
  
  // print('');
  
  // Teste 2: Verificar configuração OAuth do Google
  // print('🔄 Teste 2: Verificando configuração OAuth...');
  try {
    // Construir URL OAuth manualmente
    final params = {
      'provider': 'google',
      'redirect_to': 'rayclub://login-callback/',
      'scopes': 'email profile',
    };
    
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final oauthUrl = '$supabaseUrl/auth/v1/authorize?$queryString';
    
    // print('   OAuth URL gerada:');
    // print('   $oauthUrl');
    // print('');
    
    // Fazer request HEAD para verificar se a URL é válida
    final response = await http.head(Uri.parse(oauthUrl));
    // print('   Status da URL OAuth: ${response.statusCode}');
    
    if (response.statusCode == 302 || response.statusCode == 303) {
      // print('   ✅ URL OAuth válida (redirecionamento esperado)');
      // print('   Location header: ${response.headers['location']}');
    } else {
      // print('   ⚠️ Status inesperado: ${response.statusCode}');
    }
  } catch (e) {
    // print('   ❌ Erro ao testar OAuth: $e');
  }
  
  // print('');
  
  // Teste 3: Verificar URLs de callback registradas
  // print('🔄 Teste 3: URLs de callback sugeridas:');
  // print('   1. rayclub://login-callback/');
  // print('   2. rayclub://login-callback');
  // print('   3. https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
  // print('   4. https://rayclub.com.br/auth/callback');
  // print('');
  
  // print('⚠️  IMPORTANTE: Verifique no Dashboard do Supabase:');
  // print('   - Authentication > URL Configuration');
  // print('   - Adicione TODAS as URLs acima em "Redirect URLs"');
  // print('');
  
  // print('⚠️  IMPORTANTE: Verifique no Google Cloud Console:');
  // print('   - APIs & Services > Credentials > OAuth 2.0 Client IDs');
  // print('   - Adicione "https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback"');
  // print('   - Em "Authorized redirect URIs"');
  
  // print('');
  // print('🔍 ========== FIM DO TESTE ==========');
} 