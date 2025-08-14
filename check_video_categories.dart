import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    // Carrega variáveis de ambiente
    await dotenv.load(fileName: '.env');
    
    // Configuração do Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      print('❌ Erro: SUPABASE_URL e SUPABASE_ANON_KEY são obrigatórios.');
      print('Defina essas variáveis no arquivo .env');
      exit(1);
    }
    
    // Inicializa o Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    final supabase = Supabase.instance.client;
    
    print('🔍 Verificando vídeos de fisioterapia...\n');
    
    // Busca todos os vídeos de fisioterapia
    final response = await supabase
        .from('workout_videos')
        .select('title, subcategory, order_index')
        .eq('category', 'da178dba-ae94-425a-aaed-133af7b1bb0f') // ID da fisioterapia
        .order('subcategory')
        .order('order_index');
    
    final videos = List<Map<String, dynamic>>.from(response);
    
    print('📊 SITUAÇÃO ATUAL DOS VÍDEOS:\n');
    
    // Agrupa por subcategoria
    final videosBySubcategory = <String, List<Map<String, dynamic>>>{};
    for (final video in videos) {
      final subcategory = video['subcategory'] ?? 'sem_subcategoria';
      videosBySubcategory[subcategory] ??= [];
      videosBySubcategory[subcategory]!.add(video);
    }
    
    // Mostra a situação atual
    for (final entry in videosBySubcategory.entries) {
      final subcategory = entry.key;
      final subcategoryVideos = entry.value;
      
      print('🏷️  SUBCATEGORIA: $subcategory (${subcategoryVideos.length} vídeos)');
      
      for (final video in subcategoryVideos) {
        final title = video['title'];
        String status = '✅';
        String suggestion = '';
        
        // Verifica se está na subcategoria correta
        if (title.toLowerCase().contains('mobilidade') && subcategory != 'mobilidade') {
          status = '❌';
          suggestion = ' → deveria estar em "mobilidade"';
        } else if (title.toLowerCase().contains('teste') && subcategory != 'testes') {
          status = '❌';
          suggestion = ' → deveria estar em "testes"';
        } else if (title.toLowerCase().contains('estabilidade') && subcategory != 'estabilidade') {
          status = '❌';
          suggestion = ' → deveria estar em "estabilidade"';
        }
        
        print('   $status $title$suggestion');
      }
      print('');
    }
    
    // Identifica vídeos que precisam ser movidos
    final videosToMove = <Map<String, dynamic>>[];
    
    for (final video in videos) {
      final title = video['title'].toLowerCase();
      final currentSubcategory = video['subcategory'];
      String? correctSubcategory;
      
      if (title.contains('mobilidade') && currentSubcategory != 'mobilidade') {
        correctSubcategory = 'mobilidade';
      } else if (title.contains('teste') && currentSubcategory != 'testes') {
        correctSubcategory = 'testes';
      }
      
      if (correctSubcategory != null) {
        videosToMove.add({
          ...video,
          'correct_subcategory': correctSubcategory,
        });
      }
    }
    
    if (videosToMove.isNotEmpty) {
      print('🔧 VÍDEOS QUE PRECISAM SER MOVIDOS:');
      for (final video in videosToMove) {
        print('   "${video['title']}" de "${video['subcategory']}" → "${video['correct_subcategory']}"');
      }
      print('\n');
    } else {
      print('✅ Todos os vídeos estão nas subcategorias corretas!\n');
    }
    
  } catch (e, stackTrace) {
    print('❌ Erro ao verificar vídeos: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
} 