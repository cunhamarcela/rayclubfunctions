import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/core/services/youtube_api_service.dart';

/// Script para importar automaticamente vídeos do canal do YouTube
/// Channel ID: UCJIOE2pKr_sGWxSuUNEBoaw
void main() async {
  print('🎬 Ray Club - Automação de Importação de Vídeos do YouTube');
  print('=' * 60);

  try {
    // Carrega variáveis de ambiente
    await dotenv.load(fileName: '.env');
    print('✅ Variáveis de ambiente carregadas');

    // Inicializa Supabase
    await _initializeSupabase();
    print('✅ Supabase inicializado');

    // Inicializa YouTube API
    final youtubeService = YouTubeApiService();
    print('✅ YouTube API inicializada');

    // ID do canal do Ray Club
    const channelId = 'UCJIOE2pKr_sGWxSuUNEBoaw';
    
    print('\n📺 Extraindo vídeos do canal...');
    final videos = await youtubeService.getChannelVideos(channelId, maxResults: 50);
    
    print('📊 Encontrados ${videos.length} vídeos no canal');
    
    if (videos.isEmpty) {
      print('❌ Nenhum vídeo encontrado no canal');
      return;
    }

    print('\n🔄 Processando e inserindo vídeos...');
    
    int successCount = 0;
    int skipCount = 0;
    int errorCount = 0;

    for (int i = 0; i < videos.length; i++) {
      final video = videos[i];
      final progress = '${i + 1}/${videos.length}';
      
      try {
        print('\n[$progress] 🎥 ${video['title']}');
        
        // Categoriza o vídeo
        final category = youtubeService.categorizeVideo(video['title']);
        final instructor = youtubeService.determineInstructor(video['title']);
        final durationSeconds = youtubeService.parseDuration(video['duration']);
        
        print('  📂 Categoria: ${category['category_name']} (${category['matched_keyword']})');
        print('  👨‍🏫 Instrutor: $instructor');
        print('  ⏱️ Duração: ${_formatDuration(durationSeconds)}');

        // Verifica se o vídeo já existe
        final existingVideo = await _checkExistingVideo(video['videoId']);
        if (existingVideo != null) {
          print('  ⚠️ Vídeo já existe no banco de dados');
          skipCount++;
          continue;
        }

        // Prepara dados para inserção
        final videoData = {
          'title': video['title'],
          'description': video['description'],
          'video_url': youtubeService.generateVideoUrl(video['videoId']),
          'thumbnail_url': video['thumbnailUrl'] ?? youtubeService.generateThumbnailUrl(video['videoId']),
          'duration_seconds': durationSeconds,
          'instructor': instructor,
          'category_id': category['category_id'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_active': true,
          'video_type': 'youtube',
          'youtube_video_id': video['videoId'],
          'view_count': video['viewCount'],
          'like_count': video['likeCount'],
          'published_at': video['publishedAt'],
        };

        // Insere no banco de dados
        await _insertVideo(videoData);
        print('  ✅ Vídeo inserido com sucesso');
        successCount++;

        // Pausa para evitar rate limit
        await Future.delayed(const Duration(milliseconds: 100));

      } catch (e) {
        print('  ❌ Erro ao processar vídeo: $e');
        errorCount++;
        continue;
      }
    }

    // Relatório final
    print('\n' + '=' * 60);
    print('📈 RELATÓRIO FINAL');
    print('=' * 60);
    print('✅ Vídeos inseridos: $successCount');
    print('⚠️ Vídeos pulados (já existem): $skipCount');
    print('❌ Erros: $errorCount');
    print('📊 Total processado: ${videos.length}');
    
    if (successCount > 0) {
      print('\n🎉 Importação concluída com sucesso!');
      print('   Verifique os vídeos na seção de treinos do app.');
    }

  } catch (e) {
    print('💥 Erro fatal na automação: $e');
    exit(1);
  }
}

/// Inicializa conexão com Supabase
Future<void> _initializeSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Configure SUPABASE_URL e SUPABASE_ANON_KEY no .env');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
}

/// Verifica se um vídeo já existe no banco
Future<Map<String, dynamic>?> _checkExistingVideo(String youtubeVideoId) async {
  try {
    final response = await Supabase.instance.client
        .from('workout_videos')
        .select('id, title')
        .eq('youtube_video_id', youtubeVideoId)
        .maybeSingle();
    
    return response;
  } catch (e) {
    // Se der erro, assume que não existe
    return null;
  }
}

/// Insere vídeo no banco de dados
Future<void> _insertVideo(Map<String, dynamic> videoData) async {
  try {
    await Supabase.instance.client
        .from('workout_videos')
        .insert(videoData);
  } catch (e) {
    // Verifica se é erro de categoria não encontrada
    if (e.toString().contains('workout_categories')) {
      print('    ⚠️ Categoria não encontrada, usando categoria padrão');
      videoData['category_id'] = 'd2d2a9b8-d861-47c7-9d26-283539beda24'; // Musculação
      
      await Supabase.instance.client
          .from('workout_videos')
          .insert(videoData);
    } else {
      rethrow;
    }
  }
}

/// Formata duração em segundos para formato legível
String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  
  if (hours > 0) {
    return '${hours}h ${minutes}m ${remainingSeconds}s';
  } else if (minutes > 0) {
    return '${minutes}m ${remainingSeconds}s';
  } else {
    return '${remainingSeconds}s';
  }
} 