import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // print('🔍 VERIFICAÇÃO - Apple OAuth no Supabase');
  // print('=' * 60);
  
  await verificarAppleOAuthSupabase();
  
  // print('\n📋 INSTRUÇÕES PARA CORRIGIR NO SUPABASE:');
  // print('1. Acesse: https://supabase.com/dashboard');
  // print('2. Selecione projeto: zsbbgchsjiuicwvtrldn');
  // print('3. Vá em: Authentication → Providers → Apple');
  // print('4. Configure:');
  // print('   ✅ Apple ID: com.rayclub.app');
  // print('   ✅ Bundle ID: com.rayclub.app');
  // print('   ✅ Redirect URL: https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
  // print('   ✅ Deep Link: rayclub://login-callback/');
  
  // print('\n⚠️  IMPORTANTE:');
  // print('- O campo "Bundle ID" deve ser EXATAMENTE: com.rayclub.app');
  // print('- Esse é o campo que está causando o erro "Unacceptable audience"');
  // print('- Salve as configurações e teste novamente');
}

Future<void> verificarAppleOAuthSupabase() async {
  final supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
  
  // print('\n🔍 VERIFICANDO CONFIGURAÇÕES ATUAIS:');
  // print('🌐 Supabase URL: $supabaseUrl');
  // print('📱 Bundle ID esperado: com.rayclub.app');
  
  // Verificar se o endpoint de auth está funcionando
  try {
    // print('\n🧪 Testando endpoint de autenticação...');
    final response = await http.get(
      Uri.parse('$supabaseUrl/auth/v1/settings'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      // print('✅ Endpoint de auth está funcionando');
      
      // Tentar analisar configurações de providers
      try {
        final data = json.decode(response.body);
        if (data['external'] != null) {
          final external = data['external'] as Map<String, dynamic>;
          if (external['apple'] != null) {
            // print('✅ Apple provider está configurado');
            final apple = external['apple'] as Map<String, dynamic>;
            // print('🔍 Configurações Apple encontradas:');
            // print('   - Enabled: ${apple['enabled'] ?? 'não especificado'}');
            // print('   - Client ID: ${apple['client_id'] ?? 'não especificado'}');
          } else {
            // print('❌ Apple provider NÃO encontrado nas configurações');
          }
        }
      } catch (e) {
        // print('⚠️  Não foi possível analisar configurações detalhadas');
      }
    } else {
      // print('❌ Erro ao acessar endpoint: ${response.statusCode}');
      // print('   Response: ${response.body}');
    }
  } catch (e) {
    // print('❌ Erro de conexão: $e');
  }
  
  // print('\n🎯 ERRO ATUAL IDENTIFICADO:');
  // print('❌ Message: Unacceptable audience in id_token: [com.rayclub.app]');
  // print('');
  // print('💡 SOLUÇÃO:');
  // print('Este erro significa que o Supabase não reconhece "com.rayclub.app"');
  // print('como um audience válido para o Apple Sign In.');
  // print('');
  // print('🔧 CAUSA PROVÁVEL:');
  // print('- Bundle ID no Supabase está diferente de "com.rayclub.app"');
  // print('- Ou Apple provider não está configurado corretamente');
  // print('- Ou chave privada (.p8) está incorreta');
  
  // print('\n📝 CHECKLIST PARA VERIFICAR NO SUPABASE:');
  // print('□ Apple provider está habilitado');
  // print('□ Apple ID = com.rayclub.app');  
  // print('□ Bundle ID = com.rayclub.app');
  // print('□ Secret Key (.p8) está correta');
  // print('□ Key ID está correto');
  // print('□ Team ID está correto');
  // print('□ Redirect URLs estão configuradas');
} 