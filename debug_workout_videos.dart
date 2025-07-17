import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/config/env_config.dart';
import 'package:ray_club_app/features/workout/repositories/workout_videos_repository.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  print('🔍 INICIANDO DEBUG DOS VÍDEOS DE TREINO');
  print('=' * 50);
  
  try {
    final supabase = Supabase.instance.client;
    final repository = WorkoutVideosRepository(
      supabase: supabase, 
      dio: Dio(),
    );

    // Teste 1: Verificar dados brutos do banco
    print('\n📊 TESTE 1: Dados brutos do banco');
    print('-' * 30);
    
    final rawData = await supabase
        .from('workout_videos')
        .select()
        .limit(5);
    
    print('Registros encontrados: ${rawData.length}');
    for (var item in rawData) {
      print('• ID: ${item['id']}');
      print('  Título: ${item['title']}');
      print('  YouTube URL: ${item['youtube_url']}');
      print('  Categoria: ${item['category']}');
      print('  Dificuldade: ${item['difficulty']}');
      print('');
    }

    // Teste 2: Verificar se consegue mapear para o modelo
    print('\n🔄 TESTE 2: Mapeamento para modelo');
    print('-' * 30);
    
    try {
      final videos = rawData.map((json) => WorkoutVideo.fromJson(json)).toList();
      print('✅ Mapeamento bem-sucedido! ${videos.length} vídeos mapeados');
      
      for (var video in videos.take(3)) {
        print('• ${video.title}');
        print('  YouTube: ${video.youtubeUrl}');
        print('  Categoria: ${video.category}');
        print('  Instrutor: ${video.instructorName}');
        print('');
      }
    } catch (e) {
      print('❌ Erro no mapeamento: $e');
    }

    // Teste 3: Verificar categorias específicas
    print('\n📂 TESTE 3: Vídeos por categoria');
    print('-' * 30);
    
    // Verificar categorias existentes
    final categories = await supabase
        .from('workout_categories')
        .select('id, name');
    
    print('Categorias disponíveis:');
    for (var cat in categories) {
      print('• ${cat['name']} (${cat['id']})');
      
      // Buscar vídeos desta categoria
      try {
        final categoryVideos = await repository.getVideosByCategory(cat['id']);
        print('  Vídeos: ${categoryVideos.length}');
      } catch (e) {
        print('  Erro ao buscar vídeos: $e');
      }
    }

    // Teste 4: Testar os novos vídeos específicos
    print('\n🎥 TESTE 4: Verificar novos vídeos inseridos');
    print('-' * 30);
    
    final newVideosUrls = [
      'https://youtu.be/4rOQ2wbHnVU',
      'https://youtu.be/9DuQ5lBul3k', 
      'https://youtu.be/t172SCu4QU0'
    ];
    
    for (var url in newVideosUrls) {
      final video = await supabase
          .from('workout_videos')
          .select()
          .eq('youtube_url', url)
          .maybeSingle();
      
      if (video != null) {
        print('✅ Encontrado: ${video['title']}');
        print('   Categoria: ${video['category']}');
        print('   Dificuldade: ${video['difficulty']}');
      } else {
        print('❌ Não encontrado: $url');
      }
    }

    // Teste 5: Verificar vídeos recomendados
    print('\n⭐ TESTE 5: Vídeos recomendados');
    print('-' * 30);
    
    try {
      final recommended = await repository.getRecommendedVideos();
      print('✅ Vídeos recomendados: ${recommended.length}');
      
      for (var video in recommended.take(3)) {
        print('• ${video.title} (${video.difficulty})');
      }
    } catch (e) {
      print('❌ Erro ao buscar recomendados: $e');
    }

    // Teste 6: Verificar vídeos populares
    print('\n🔥 TESTE 6: Vídeos populares');
    print('-' * 30);
    
    try {
      final popular = await repository.getPopularVideos();
      print('✅ Vídeos populares: ${popular.length}');
      
      for (var video in popular.take(3)) {
        print('• ${video.title} (${video.difficulty})');
      }
    } catch (e) {
      print('❌ Erro ao buscar populares: $e');
    }

    print('\n🎯 TESTE 7: Verificar problema específico do Musculação');
    print('-' * 30);
    
    // Buscar categoria Musculação
    final musculacaoCategory = await supabase
        .from('workout_categories')
        .select()
        .eq('name', 'Musculação')
        .maybeSingle();
    
    if (musculacaoCategory != null) {
      print('✅ Categoria Musculação encontrada: ${musculacaoCategory['id']}');
      
      try {
        final musculacaoVideos = await repository.getVideosByCategory(musculacaoCategory['id']);
        print('   Vídeos de musculação: ${musculacaoVideos.length}');
        
        for (var video in musculacaoVideos) {
          print('   • ${video.title} - ${video.difficulty}');
        }
      } catch (e) {
        print('   ❌ Erro ao buscar vídeos de musculação: $e');
      }
    } else {
      print('❌ Categoria Musculação não encontrada');
    }

  } catch (e) {
    print('❌ ERRO GERAL: $e');
    print('Stack trace: ${StackTrace.current}');
  }
  
  print('\n' + '=' * 50);
  print('🏁 DEBUG CONCLUÍDO');
} 