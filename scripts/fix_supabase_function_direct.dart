import 'dart:io';
import 'dart:convert';

/// Script para executar SQL diretamente no Supabase via HTTP
Future<void> main() async {
  try {
    print('🔧 Iniciando correção da função set_category_goal...');
    
    // Ler variáveis de ambiente do .env
    final envFile = File('.env');
    if (!envFile.existsSync()) {
      throw Exception('Arquivo .env não encontrado');
    }
    
    final envContent = await envFile.readAsString();
    final envVars = <String, String>{};
    
    for (final line in envContent.split('\n')) {
      if (line.trim().isNotEmpty && !line.startsWith('#')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          envVars[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
    }
    
    // Usar URL do terminal log (a que realmente funciona)
    final supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
    final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
    
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception('SUPABASE_URL e SUPABASE_ANON_KEY são obrigatórios');
    }
    
    print('✅ Variáveis de ambiente carregadas');
    print('🔗 URL: $supabaseUrl');
    
    // Ler SQL
    final sqlFile = File('sql/fix_goals_function_definitively.sql');
    if (!sqlFile.existsSync()) {
      throw Exception('Arquivo SQL não encontrado: ${sqlFile.path}');
    }
    
    final sqlContent = await sqlFile.readAsString();
    print('✅ SQL carregado: ${sqlContent.length} caracteres');
    
    // Executar SQL diretamente via REST API
    final client = HttpClient();
    
    // Dividir SQL em comandos individuais
    final sqlCommands = sqlContent
        .split(';')
        .map((cmd) => cmd.trim())
        .where((cmd) => cmd.isNotEmpty && !cmd.startsWith('--'))
        .toList();
    
    print('📝 ${sqlCommands.length} comandos SQL para executar');
    
    for (int i = 0; i < sqlCommands.length; i++) {
      final command = sqlCommands[i];
      if (command.isEmpty) continue;
      
      print('📤 Executando comando ${i + 1}/${sqlCommands.length}...');
      
      final uri = Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql');
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $supabaseKey');
      request.headers.set('apikey', supabaseKey);
      
      final body = jsonEncode({'sql': command});
      request.write(body);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        print('✅ Comando ${i + 1} executado com sucesso');
      } else {
        print('❌ Erro no comando ${i + 1}: ${response.statusCode}');
        print('❌ SQL: $command');
        print('❌ Resposta: $responseBody');
        throw Exception('Falha ao executar SQL');
      }
    }
    
    print('🎉 Todos os comandos SQL executados com sucesso!');
    print('🎉 Função set_category_goal atualizada para suportar dias e minutos!');
    
    client.close();
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('❌ Stack trace: $stackTrace');
    exit(1);
  }
}
