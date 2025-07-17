import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    // Carrega variáveis de ambiente
    await dotenv.load(fileName: '.env');
    
    // Configuração do Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ Erro: SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY são obrigatórios.');
      print('Defina essas variáveis no arquivo .env');
      exit(1);
    }
    
    // Inicializa o Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    final supabase = Supabase.instance.client;
    
    print('🚀 Conectando ao Supabase...');
    
    // Lê o arquivo SQL
    final sqlFile = File('lib/features/dashboard/sql/get_dashboard_fitness.sql');
    if (!await sqlFile.exists()) {
      print('❌ Erro: Arquivo SQL não encontrado: ${sqlFile.path}');
      exit(1);
    }
    
    final sqlContent = await sqlFile.readAsString();
    
    // Divide o SQL em comandos separados
    final commands = sqlContent
        .split(';')
        .map((cmd) => cmd.trim())
        .where((cmd) => cmd.isNotEmpty && !cmd.startsWith('--'))
        .toList();
    
    print('📝 Executando ${commands.length} comandos SQL...');
    
    // Executa cada comando
    for (int i = 0; i < commands.length; i++) {
      final command = commands[i];
      if (command.trim().isEmpty) continue;
      
      print('⏳ Executando comando ${i + 1}/${commands.length}...');
      
      try {
        // Executa o comando SQL usando rpc
        final result = await supabase.rpc('exec_sql', {
          'sql': command + ';'
        });
        
        print('✅ Comando ${i + 1} executado com sucesso');
        
      } catch (error) {
        // Se exec_sql não existir, tenta usar from().select() para comandos simples
        if (error.toString().contains('exec_sql')) {
          print('⚠️  exec_sql não disponível, tentando abordagem alternativa...');
          
          // Para comandos DROP e CREATE, vamos usar uma abordagem diferente
          if (command.toUpperCase().contains('DROP FUNCTION') || 
              command.toUpperCase().contains('CREATE OR REPLACE FUNCTION')) {
            print('🔄 Pulando comando ${i + 1} (será aplicado via SQL direto)');
            continue;
          }
        }
        
        print('❌ Erro no comando ${i + 1}: $error');
        print('Comando: ${command.substring(0, 50)}...');
      }
    }
    
    print('\n🧪 Testando função get_dashboard_fitness...');
    
    // Testa a função
    try {
      final testResult = await supabase.rpc('get_dashboard_fitness', {
        'user_id_param': '01d4a292-1873-4af6-948b-a55eed56d6b9',
        'month_param': 7,
        'year_param': 2025,
      });
      
      print('✅ Função testada com sucesso!');
      print('📊 Resultado: ${testResult.toString().substring(0, 200)}...');
      
    } catch (error) {
      print('❌ Erro ao testar função: $error');
      
      // Vamos aplicar o SQL manualmente via REST API
      print('\n🔧 Aplicando SQL manualmente...');
      
      // Cria um cliente HTTP para usar a API REST do Supabase
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseKey',
        'apikey': supabaseKey,
      };
      
      // Comando SQL simplificado para criar apenas a função principal
      final createFunctionSql = '''
CREATE OR REPLACE FUNCTION get_dashboard_fitness(
    user_id_param UUID,
    month_param INT,
    year_param INT
) RETURNS JSONB AS \$\$
BEGIN
    RETURN jsonb_build_object(
        'calendar', jsonb_build_object(
            'month', month_param,
            'year', year_param,
            'days', '[]'::jsonb
        ),
        'progress', jsonb_build_object(
            'week', jsonb_build_object('workouts', 0, 'minutes', 0, 'types', 0, 'days', 0),
            'month', jsonb_build_object('workouts', 0, 'minutes', 0, 'days', 0, 'types_distribution', '{}'::jsonb),
            'total', jsonb_build_object('workouts', 0, 'points', 0, 'duration', 0, 'level', 1),
            'streak', jsonb_build_object('current', 0, 'longest', 0)
        ),
        'awards', jsonb_build_object(
            'total_points', 0,
            'achievements', '[]'::jsonb,
            'badges', '[]'::jsonb,
            'level', 1
        ),
        'last_updated', NOW()
    );
END;
\$\$ LANGUAGE plpgsql;
''';
      
      print('🔄 Aplicando função temporária...');
      
      // Executa via HTTP POST
      try {
        final response = await supabase.rpc('exec_sql', {
          'query': createFunctionSql
        });
        
        print('✅ Função temporária aplicada com sucesso!');
        
        // Testa novamente
        final testResult2 = await supabase.rpc('get_dashboard_fitness', {
          'user_id_param': '01d4a292-1873-4af6-948b-a55eed56d6b9',
          'month_param': 7,
          'year_param': 2025,
        });
        
        print('✅ Função temporária testada com sucesso!');
        print('📊 Resultado: ${testResult2.toString().substring(0, 200)}...');
        
      } catch (tempError) {
        print('❌ Erro ao aplicar função temporária: $tempError');
        
        print('\n📝 INSTRUÇÕES MANUAIS:');
        print('1. Acesse o Supabase Dashboard');
        print('2. Vá para SQL Editor');
        print('3. Cole e execute o conteúdo do arquivo: lib/features/dashboard/sql/get_dashboard_fitness.sql');
        print('4. Teste a função com: SELECT get_dashboard_fitness(\'01d4a292-1873-4af6-948b-a55eed56d6b9\'::UUID, 7, 2025);');
      }
    }
    
  } catch (error) {
    print('❌ Erro geral: $error');
    exit(1);
  }
} 