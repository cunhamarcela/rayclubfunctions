import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('🔍 Debugando dados dos participantes...');
  
  const String supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
  
  final client = HttpClient();
  
  try {
    // 1. Verificar participantes e quando entraram
    print('\\n1. Participantes e datas de entrada:');
    
    final request1 = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/cardio_challenge_participants?active=eq.true&select=user_id,joined_at'));
    request1.headers.set('Authorization', 'Bearer $anonKey');
    request1.headers.set('apikey', anonKey);
    
    final response1 = await request1.close();
    final participants = await response1.transform(utf8.decoder).join();
    print('Participantes: $participants');
    
    // 2. Para cada participante, verificar todos os treinos vs treinos após entrada no desafio
    print('\\n2. Comparando treinos totais vs treinos após entrada no desafio:');
    
    // Buscar todos os treinos de cardio
    final request2 = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/workout_records?workout_type=eq.Cardio&select=user_id,workout_name,date,duration_minutes&order=date.desc'));
    request2.headers.set('Authorization', 'Bearer $anonKey');
    request2.headers.set('apikey', anonKey);
    
    final response2 = await request2.close();
    final allWorkouts = await response2.transform(utf8.decoder).join();
    print('Todos os treinos de Cardio: $allWorkouts');
    
    // 3. Verificar get_cardio_ranking atual
    print('\\n3. Resultado da função get_cardio_ranking:');
    
    final request3 = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_ranking'));
    request3.headers.set('Content-Type', 'application/json');
    request3.headers.set('Authorization', 'Bearer $anonKey');
    request3.headers.set('apikey', anonKey);
    request3.write('{}');
    
    final response3 = await request3.close();
    final rankingResult = await response3.transform(utf8.decoder).join();
    print('Ranking atual: $rankingResult');
    
    // 4. Testar query específica para um usuário
    print('\\n4. Análise detalhada para debugging:');
    print('HIPÓTESE: O ranking considera apenas treinos após a data de entrada no desafio');
    print('ESTATÍSTICAS: Mostram todos os treinos de cardio do usuário (incluindo antigos)');
    
  } catch (e) {
    print('ERRO: $e');
  } finally {
    client.close();
  }
}

