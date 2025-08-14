import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🚨 APLICANDO CORREÇÃO URGENTE: Adicionando Raiany como participante ativa');
  
  const supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEzOTg3NjQsImV4cCI6MjAyNjk3NDc2NH0.mEPlIb4ZSiYIXUZVMKyJF5pIwQOeHKE8dTDT6awbCo8';
  
  final client = http.Client();
  
  try {
    // 1. Primeiro verificar se Raiany já é participante
    print('🔍 Verificando se Raiany já é participante...');
    final checkResponse = await client.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_participation'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        'user_id_param': 'bbea26ca-f34c-499f-ad3a-48646a614cd3' // ID da Raiany
      }),
    );
    
    print('📋 Status participação Raiany: ${checkResponse.statusCode}');
    print('📋 Resposta: ${checkResponse.body}');
    
    // 2. Adicionar Raiany como participante ativa
    print('✅ Adicionando Raiany como participante ativa...');
    
    final insertSql = '''
      INSERT INTO public.cardio_challenge_participants (user_id, joined_at, active)
      VALUES ('bbea26ca-f34c-499f-ad3a-48646a614cd3', '2025-08-13 13:39:30+00', true)
      ON CONFLICT (user_id) DO UPDATE SET 
        active = true, 
        joined_at = EXCLUDED.joined_at;
    ''';
    
    final insertResponse = await client.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/execute_sql'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': insertSql
      }),
    );
    
    print('📋 Insert Status: ${insertResponse.statusCode}');
    print('📋 Insert Response: ${insertResponse.body}');
    
    // 3. Verificar novamente após inserção
    print('🔍 Verificando status após inserção...');
    final reCheckResponse = await client.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_participation'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        'user_id_param': 'bbea26ca-f34c-499f-ad3a-48646a614cd3' // ID da Raiany
      }),
    );
    
    print('📋 Novo status participação: ${reCheckResponse.statusCode}');
    print('📋 Nova resposta: ${reCheckResponse.body}');
    
    // 4. Testar ranking após correção
    print('🏆 Testando ranking após correção...');
    final rankingResponse = await client.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_ranking'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        '_limit': 10,
        '_offset': 0
      }),
    );
    
    print('📋 Ranking Status: ${rankingResponse.statusCode}');
    print('📋 Ranking Response: ${rankingResponse.body}');
    
    print('🎉 CORREÇÃO CONCLUÍDA! Agora teste no app clicando na Raiany Ricardo.');
    
  } catch (e) {
    print('❌ Erro: $e');
  } finally {
    client.close();
  }
}

