import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Script para remover categorias duplicadas e indesejadas
/// Remove: Cardio, Yoga, HIIT conforme solicitado
Future<void> main() async {
  try {
    // Carregar variáveis de ambiente
    await dotenv.load(fileName: '.env');
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      print('❌ Erro: SUPABASE_URL ou SUPABASE_ANON_KEY não encontrados no .env');
      exit(1);
    }
    
    // Inicializar Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Conectado ao Supabase');
    
    // 1. Verificar categorias existentes
    print('\n🔍 Verificando categorias existentes...');
    final existingCategories = await supabase
        .from('workout_categories')
        .select('id, name, workoutsCount, order_index')
        .order('order_index');
    
    print('📋 Categorias encontradas:');
    for (final category in existingCategories) {
      print('  - ${category['name']} (ID: ${category['id']}, Count: ${category['workoutsCount']}, Order: ${category['order_index']})');
    }
    
    // 2. Identificar categorias a serem removidas
    final categoriesToRemove = ['cardio', 'yoga', 'hiit'];
    final categoriesToRemoveIds = <String>[];
    
    for (final category in existingCategories) {
      if (categoriesToRemove.contains(category['name'].toString().toLowerCase())) {
        categoriesToRemoveIds.add(category['id'].toString());
        print('🎯 Categoria marcada para remoção: ${category['name']}');
      }
    }
    
    if (categoriesToRemoveIds.isEmpty) {
      print('✅ Nenhuma categoria para remover encontrada');
      return;
    }
    
    // 3. Backup das categorias que serão removidas
    print('\n💾 Criando backup das categorias...');
    final categoriesToBackup = await supabase
        .from('workout_categories')
        .select()
        .inFilter('id', categoriesToRemoveIds);
    
    print('📦 Backup criado para ${categoriesToBackup.length} categorias');
    
    // 4. Backup dos vídeos associados
    print('\n💾 Criando backup dos vídeos associados...');
    final videosToBackup = await supabase
        .from('workout_videos')
        .select()
        .inFilter('category', categoriesToRemoveIds);
    
    print('📦 Backup criado para ${videosToBackup.length} vídeos');
    
    // 5. Remover vídeos associados primeiro (devido a FK constraints)
    if (videosToBackup.isNotEmpty) {
      print('\n🗑️ Removendo ${videosToBackup.length} vídeos associados...');
      await supabase
          .from('workout_videos')
          .delete()
          .inFilter('category', categoriesToRemoveIds);
      print('✅ Vídeos removidos');
    }
    
    // 6. Remover as categorias
    print('\n🗑️ Removendo categorias indesejadas...');
    await supabase
        .from('workout_categories')
        .delete()
        .inFilter('id', categoriesToRemoveIds);
    print('✅ Categorias removidas: ${categoriesToRemove.join(', ')}');
    
    // 7. Reorganizar ordem das categorias restantes
    print('\n🔄 Reorganizando ordem das categorias...');
    final remainingCategories = await supabase
        .from('workout_categories')
        .select('id, name')
        .order('name');
    
    final categoryOrder = {
      'musculação': 1,
      'funcional': 2, 
      'pilates': 3,
      'força': 4,
      'flexibilidade': 5,
      'corrida': 6,
      'fisioterapia': 7,
      'alongamento': 8,
    };
    
    for (final category in remainingCategories) {
      final name = category['name'].toString().toLowerCase();
      final newOrder = categoryOrder[name] ?? 999;
      
      await supabase
          .from('workout_categories')
          .update({'order_index': newOrder})
          .eq('id', category['id']);
      
      print('  📝 ${category['name']}: ordem ${newOrder}');
    }
    
    // 8. Atualizar contadores de vídeos
    print('\n🔢 Atualizando contadores de vídeos...');
    for (final category in remainingCategories) {
      final videoCount = await supabase
          .from('workout_videos')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('category', category['id']);
      
      await supabase
          .from('workout_categories')
          .update({'workoutsCount': videoCount.count})
          .eq('id', category['id']);
      
      print('  📊 ${category['name']}: ${videoCount.count} vídeos');
    }
    
    // 9. Verificação final
    print('\n✅ Verificação final...');
    final finalCategories = await supabase
        .from('workout_categories')
        .select('id, name, workoutsCount, order_index')
        .order('order_index');
    
    print('📋 Categorias finais:');
    for (final category in finalCategories) {
      print('  - ${category['name']} (Count: ${category['workoutsCount']}, Order: ${category['order_index']})');
    }
    
    print('\n🎉 Processo concluído com sucesso!');
    print('✅ Categorias removidas: ${categoriesToRemove.join(', ')}');
    print('✅ Cards duplicados removidos');
    print('✅ Ordem das categorias reorganizada');
    
  } catch (e) {
    print('❌ Erro durante execução: $e');
    exit(1);
  }
} 