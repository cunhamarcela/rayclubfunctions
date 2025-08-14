import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dotenv/dotenv.dart';

/// Script para aplicar suporte a metas de dias no Supabase
Future<void> main() async {
  try {
    print('🔧 Iniciando aplicação de suporte a metas de dias...');
    
    // Carregar variáveis de ambiente
    final env = DotEnv()..load();
    final supabaseUrl = env['SUPABASE_URL'];
    final supabaseKey = env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Variáveis de ambiente SUPABASE_URL e SUPABASE_ANON_KEY são obrigatórias');
    }
    
    // Inicializar Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Supabase inicializado');
    
    // Ler arquivo SQL
    final sqlFile = File('sql/update_goals_support_days.sql');
    if (!await sqlFile.exists()) {
      throw Exception('Arquivo SQL não encontrado: ${sqlFile.path}');
    }
    
    final sqlContent = await sqlFile.readAsString();
    print('📄 Arquivo SQL carregado: ${sqlContent.length} caracteres');
    
    // Dividir em comandos individuais
    final commands = sqlContent
        .split(';')
        .map((cmd) => cmd.trim())
        .where((cmd) => cmd.isNotEmpty && !cmd.startsWith('--'))
        .toList();
    
    print('🔧 Executando ${commands.length} comandos SQL...');
    
    // Executar cada comando
    for (int i = 0; i < commands.length; i++) {
      final command = commands[i];
      if (command.isEmpty) continue;
      
      try {
        print('⏳ Executando comando ${i + 1}/${commands.length}...');
        await supabase.rpc('exec_sql', params: {'sql': command});
        print('✅ Comando ${i + 1} executado com sucesso');
      } catch (e) {
        // Para comandos DROP, ignorar erro se função não existir
        if (command.contains('DROP FUNCTION') && e.toString().contains('does not exist')) {
          print('⚠️ Função não existia (ignorando): ${e.toString().substring(0, 100)}...');
          continue;
        }
        
        print('❌ Erro no comando ${i + 1}: $e');
        print('📝 Comando que falhou: ${command.substring(0, 200)}...');
        throw e;
      }
    }
    
    print('🎉 Todas as funções foram atualizadas com sucesso!');
    
    // Testar nova função
    print('🧪 Testando nova função...');
    
    // Teste 1: Meta de minutos
    try {
      await supabase.rpc('set_category_goal', params: {
        'p_user_id': '01d4a292-1873-4af6-948b-a55eed56d6b9',
        'p_category': 'teste_minutos',
        'p_goal_value': 90,
        'p_goal_type': 'minutes'
      });
      print('✅ Teste 1 (minutos): OK');
    } catch (e) {
      print('❌ Teste 1 (minutos): $e');
    }
    
    // Teste 2: Meta de dias
    try {
      await supabase.rpc('set_category_goal', params: {
        'p_user_id': '01d4a292-1873-4af6-948b-a55eed56d6b9',
        'p_category': 'teste_dias',
        'p_goal_value': 5,
        'p_goal_type': 'days'
      });
      print('✅ Teste 2 (dias): OK');
    } catch (e) {
      print('❌ Teste 2 (dias): $e');
    }
    
    // Teste 3: Compatibilidade com versão antiga
    try {
      await supabase.rpc('set_category_goal', params: {
        'p_user_id': '01d4a292-1873-4af6-948b-a55eed56d6b9',
        'p_category': 'teste_compatibilidade',
        'p_goal_minutes': 120
      });
      print('✅ Teste 3 (compatibilidade): OK');
    } catch (e) {
      print('❌ Teste 3 (compatibilidade): $e');
    }
    
    print('🎉 Script concluído com sucesso!');
    
  } catch (e, stackTrace) {
    print('❌ Erro durante execução: $e');
    print('📍 Stack trace: $stackTrace');
    exit(1);
  }
}
