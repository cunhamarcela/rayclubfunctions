import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para aplicar migração das receitas reais da Bruna Braga
void main() async {
  print('🚀 Iniciando migração das receitas da Bruna Braga...');
  
  // Configurar Supabase (usar variáveis de ambiente)
  await Supabase.initialize(
    url: Platform.environment['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL',
    anonKey: Platform.environment['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY',
  );
  
  final supabase = Supabase.instance.client;
  
  try {
    // Ler arquivo SQL
    final sqlFile = File('insert_bruna_recipes.sql');
    if (!await sqlFile.exists()) {
      print('❌ Arquivo insert_bruna_recipes.sql não encontrado');
      print('Execute primeiro: dart parse_bruna_recipes.dart');
      return;
    }
    
    final sqlContent = await sqlFile.readAsString();
    print('📄 SQL carregado: ${sqlContent.length} caracteres');
    
    // Executar migração
    print('🔄 Executando migração...');
    await supabase.rpc('execute_sql', params: {'sql': sqlContent});
    
    print('✅ Migração executada com sucesso!');
    
    // Verificar receitas inseridas
    final response = await supabase
        .from('recipes')
        .select('count(*)')
        .eq('author_name', 'Bruna Braga');
    
    print('📊 Total de receitas da Bruna Braga: ${response}');
    
  } catch (e, stackTrace) {
    print('❌ Erro durante migração: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Alternativa: aplicar migração manualmente usando psql
void showManualInstructions() {
  print('');
  print('📋 Instruções para aplicar migração manualmente:');
  print('');
  print('1. Conecte-se ao Supabase via psql:');
  print('   psql "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres"');
  print('');
  print('2. Execute o arquivo SQL:');
  print('   \\i /path/to/insert_bruna_recipes.sql');
  print('');
  print('3. Verifique as receitas inseridas:');
  print("   SELECT count(*) FROM recipes WHERE author_name = 'Bruna Braga';");
  print('');
} 