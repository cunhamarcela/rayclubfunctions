import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('🚀 Aplicando funções SQL do desafio de cardio via HTTP...');
  
  const String supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
  
  final client = HttpClient();
  
  try {
    // 1. Testar se as funções já existem
    print('📋 Testando funções existentes...');
    
    // Testar get_cardio_participation
    try {
      final request = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_participation'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $anonKey');
      request.headers.set('apikey', anonKey);
      request.write('{}');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        print('✅ get_cardio_participation: Já existe e funcionando');
        print('   Resposta: $responseBody');
      } else {
        print('❌ get_cardio_participation: Não existe (status: ${response.statusCode})');
        print('   Erro: $responseBody');
      }
    } catch (e) {
      print('❌ get_cardio_participation: Erro ao testar - $e');
    }
    
    // Testar join_cardio_challenge
    try {
      final request2 = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/join_cardio_challenge'));
      request2.headers.set('Content-Type', 'application/json');
      request2.headers.set('Authorization', 'Bearer $anonKey');
      request2.headers.set('apikey', anonKey);
      request2.write('{}');
      
      final response2 = await request2.close();
      final responseBody2 = await response2.transform(utf8.decoder).join();
      
      if (response2.statusCode == 200 || response2.statusCode == 204) {
        print('✅ join_cardio_challenge: Já existe e funcionando');
      } else {
        print('❌ join_cardio_challenge: Não existe (status: ${response2.statusCode})');
        print('   Erro: $responseBody2');
      }
    } catch (e) {
      print('❌ join_cardio_challenge: Erro ao testar - $e');
    }
    
    // Testar get_cardio_ranking
    try {
      final request3 = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_ranking'));
      request3.headers.set('Content-Type', 'application/json');
      request3.headers.set('Authorization', 'Bearer $anonKey');
      request3.headers.set('apikey', anonKey);
      request3.write('{}');
      
      final response3 = await request3.close();
      final responseBody3 = await response3.transform(utf8.decoder).join();
      
      if (response3.statusCode == 200) {
        print('✅ get_cardio_ranking: Já existe e funcionando');
        print('   Participantes encontrados: ${jsonDecode(responseBody3).length}');
      } else {
        print('❌ get_cardio_ranking: Não existe (status: ${response3.statusCode})');
        print('   Erro: $responseBody3');
      }
    } catch (e) {
      print('❌ get_cardio_ranking: Erro ao testar - $e');
    }
    
    print('');
    print('🔍 ANÁLISE CONCLUÍDA!');
    print('');
    print('📋 INSTRUÇÕES PARA APLICAR AS FUNÇÕES MANUALMENTE:');
    print('');
    print('1. Acesse o painel do Supabase: https://zsbbgchsjiuicwvtrldn.supabase.co');
    print('2. Vá para SQL Editor');
    print('3. Execute o conteúdo do arquivo sql/cardio_challenge_participants.sql');
    print('4. Execute o conteúdo do arquivo sql/get_cardio_ranking.sql');
    print('');
    
  } catch (e) {
    print('❌ Erro geral: $e');
  } finally {
    client.close();
  }
}
