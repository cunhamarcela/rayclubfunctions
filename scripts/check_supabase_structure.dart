import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para verificar a estrutura do Supabase
/// Execute com: dart run scripts/check_supabase_structure.dart
void main() async {
  print('🔍 Verificando estrutura do Supabase...');
  
  // Carregar variáveis de ambiente
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Arquivo .env não encontrado');
    exit(1);
  }
  
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
    print('❌ SUPABASE_URL ou SUPABASE_ANON_KEY não encontrados no .env');
    exit(1);
  }
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  final supabase = Supabase.instance.client;
  
  try {
    // Teste 1: Verificar se a tabela existe
    print('\n📋 Teste 1: Verificando tabela workout_category_goals...');
    try {
      final tableResult = await supabase
          .from('workout_category_goals')
          .select('count')
          .limit(1);
      print('✅ Tabela workout_category_goals existe');
      print('   Resultado: $tableResult');
    } catch (e) {
      print('❌ Tabela workout_category_goals não existe ou não acessível: $e');
    }
    
    // Teste 2: Verificar função get_user_category_goals
    print('\n🔧 Teste 2: Verificando função get_user_category_goals...');
    try {
      final functionResult = await supabase.rpc('get_user_category_goals', params: {
        'p_user_id': '01d4a292-1873-4af6-948b-a55eed56d6b9',
      });
      print('✅ Função get_user_category_goals existe');
      print('   Resultado: $functionResult');
      print('   Tipo: ${functionResult.runtimeType}');
      if (functionResult is List) {
        print('   Quantidade de itens: ${functionResult.length}');
      }
    } catch (e) {
      print('❌ Função get_user_category_goals não existe ou erro: $e');
    }
    
    // Teste 3: Verificar função set_category_goal
    print('\n🔧 Teste 3: Verificando função set_category_goal...');
    try {
      // Tentar com parâmetros inválidos para não criar dados
      await supabase.rpc('set_category_goal', params: {
        'p_user_id': '00000000-0000-0000-0000-000000000000',
        'p_category': 'test',
        'p_goal_minutes': 0, // Valor inválido
      });
    } catch (e) {
      if (e.toString().contains('Meta deve estar entre 15 e 1440 minutos')) {
        print('✅ Função set_category_goal existe (erro de validação esperado)');
      } else {
        print('❌ Função set_category_goal não existe ou erro inesperado: $e');
      }
    }
    
    // Teste 4: Verificar dados existentes
    print('\n📊 Teste 4: Verificando dados existentes...');
    try {
      final dataResult = await supabase
          .from('workout_category_goals')
          .select('*')
          .eq('user_id', '01d4a292-1873-4af6-948b-a55eed56d6b9');
      
      print('✅ Dados do usuário encontrados: ${dataResult.length} registros');
      if (dataResult.isNotEmpty) {
        print('   Primeiro registro: ${dataResult.first}');
      }
    } catch (e) {
      print('❌ Erro ao buscar dados: $e');
    }
    
    print('\n✅ Verificação concluída!');
    
  } catch (e) {
    print('❌ Erro geral: $e');
    exit(1);
  }
  
  exit(0);
}
