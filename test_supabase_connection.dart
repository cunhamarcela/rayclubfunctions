import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🔍 Testando conexão com Supabase...\n');
  
  // Lendo as variáveis do .env
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  final envLines = envContent.split('\n');
  
  String? supabaseUrl;
  String? supabaseAnonKey;
  
  for (final line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) {
      supabaseUrl = line.split('=')[1].trim();
    } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
      supabaseAnonKey = line.split('=')[1].trim();
    }
  }
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ Não foi possível encontrar SUPABASE_URL ou SUPABASE_ANON_KEY no .env');
    return;
  }
  
  print('📋 Configurações encontradas:');
  print('   URL: $supabaseUrl');
  print('   Key: ${supabaseAnonKey.substring(0, 20)}...\n');
  
  // Testando a conexão
  try {
    print('🔄 Testando conexão com a API...');
    
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    print('📡 Status Code: ${response.statusCode}');
    print('📡 Status Message: ${response.reasonPhrase}');
    
    if (response.statusCode == 401) {
      print('\n❌ ERRO 401: Invalid API Key!');
      print('   A chave ANON_KEY está incorreta ou expirada.');
      print('\n🔧 Solução:');
      print('   1. Acesse o Supabase Dashboard');
      print('   2. Vá em Settings > API');
      print('   3. Copie a chave "anon public"');
      print('   4. Atualize SUPABASE_ANON_KEY no .env');
    } else if (response.statusCode == 200 || response.statusCode == 404) {
      print('\n✅ Conexão com Supabase OK!');
      print('   A chave está funcionando corretamente.');
      
      // Testando auth endpoint
      print('\n🔄 Testando endpoint de autenticação...');
      final authResponse = await http.get(
        Uri.parse('$supabaseUrl/auth/v1/settings'),
        headers: {
          'apikey': supabaseAnonKey,
        },
      );
      
      print('📡 Auth Status: ${authResponse.statusCode}');
      if (authResponse.statusCode == 200) {
        final settings = json.decode(authResponse.body);
        print('✅ Auth endpoint OK!');
        print('   Providers habilitados: ${settings['external'] ?? 'nenhum'}');
      }
    } else {
      print('\n⚠️  Status inesperado: ${response.statusCode}');
      print('   Resposta: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Erro ao conectar: $e');
    print('   Verifique sua conexão com a internet.');
  }
} 