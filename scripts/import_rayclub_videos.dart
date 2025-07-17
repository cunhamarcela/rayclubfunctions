import 'dart:convert';
import 'dart:io';

void main() async {
  print('🎬 Importação de Vídeos do RayClub - VERSÃO FINAL');
  print('=' * 60);
  print('⚠️  EXCLUINDO: Vídeos do "The Unit"');
  print('✅ INCLUINDO: Pilates, FightFit, Musculação, outros');
  print('🔍 VERIFICANDO: Duplicatas antes de inserir');
  print('=' * 60);

  // Lê configurações do .env
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  
  final youtubeApiKeyMatch = RegExp(r'YOUTUBE_API_KEY=(.+)').firstMatch(envContent);
  final supabaseUrlMatch = RegExp(r'SUPABASE_URL=(.+)').firstMatch(envContent);
  final supabaseKeyMatch = RegExp(r'SUPABASE_ANON_KEY=(.+)').firstMatch(envContent);
  
  if (youtubeApiKeyMatch == null || supabaseUrlMatch == null || supabaseKeyMatch == null) {
    print('❌ Configurações não encontradas no .env');
    exit(1);
  }

  final youtubeApiKey = youtubeApiKeyMatch.group(1)!;
  final supabaseUrl = supabaseUrlMatch.group(1)!;
  final supabaseKey = supabaseKeyMatch.group(1)!;

  print('✅ Configurações carregadas');

  try {
    // 1. Busca vídeos do canal RayClub
    final videos = await fetchChannelVideos(youtubeApiKey, 'UCJIOE2pKr_sGWxSuUNEBoaw');
    print('\n📺 Total de vídeos encontrados: ${videos.length}');
    
    // 2. Filtra vídeos (exclui The Unit)
    final filteredVideos = filterVideos(videos);
    print('📊 Vídeos após filtros: ${filteredVideos.length}');
    
    // 3. Verifica vídeos existentes no banco
    final existingVideos = await getExistingVideos(supabaseUrl, supabaseKey);
    print('🗄️ Vídeos já existentes no banco: ${existingVideos.length}');
    
    // 4. Remove duplicatas
    final newVideos = removeDuplicates(filteredVideos, existingVideos);
    print('🆕 Vídeos novos para inserir: ${newVideos.length}');
    
    if (newVideos.isEmpty) {
      print('\n✅ Nenhum vídeo novo para inserir. Banco já está atualizado!');
      return;
    }
    
    // 5. Insere vídeos no banco
    await insertVideos(supabaseUrl, supabaseKey, newVideos);
    
  } catch (e) {
    print('💥 Erro fatal: $e');
    exit(1);
  }
}

Future<List<Map<String, dynamic>>> fetchChannelVideos(String apiKey, String channelId) async {
  final videos = <Map<String, dynamic>>[];
  String? nextPageToken;
  
  do {
    try {
      final client = HttpClient();
      
      // Busca IDs dos vídeos
      var searchUrl = 'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet&order=date&type=video&maxResults=50';
      if (nextPageToken != null) {
        searchUrl += '&pageToken=$nextPageToken';
      }
      
      final searchRequest = await client.getUrl(Uri.parse(searchUrl));
      final searchResponse = await searchRequest.close();
      final searchBody = await searchResponse.transform(utf8.decoder).join();
      
      if (searchResponse.statusCode != 200) {
        print('❌ Erro na busca: ${searchResponse.statusCode}');
        break;
      }
      
      final searchData = jsonDecode(searchBody);
      final items = searchData['items'] as List<dynamic>? ?? [];
      
      if (items.isEmpty) break;
      
      // Extrai IDs dos vídeos
      final videoIds = items.map((item) => item['id']['videoId'] as String).toList();
      
      // Busca detalhes completos dos vídeos
      final detailsUrl = 'https://www.googleapis.com/youtube/v3/videos?key=$apiKey&id=${videoIds.join(',')}&part=snippet,contentDetails,statistics';
      final detailsRequest = await client.getUrl(Uri.parse(detailsUrl));
      final detailsResponse = await detailsRequest.close();
      final detailsBody = await detailsResponse.transform(utf8.decoder).join();
      
      if (detailsResponse.statusCode == 200) {
        final detailsData = jsonDecode(detailsBody);
        final videoDetails = detailsData['items'] as List<dynamic>? ?? [];
        
        for (final video in videoDetails) {
          final snippet = video['snippet'] as Map<String, dynamic>;
          final contentDetails = video['contentDetails'] as Map<String, dynamic>;
          final statistics = video['statistics'] as Map<String, dynamic>? ?? {};
          
          videos.add({
            'videoId': video['id'] as String,
            'title': snippet['title'] as String? ?? '',
            'description': snippet['description'] as String? ?? '',
            'thumbnailUrl': getBestThumbnail(snippet['thumbnails'] as Map<String, dynamic>?),
            'publishedAt': snippet['publishedAt'] as String? ?? '',
            'duration': contentDetails['duration'] as String? ?? 'PT0S',
            'viewCount': int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0,
            'likeCount': int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0,
          });
        }
      }
      
      nextPageToken = searchData['nextPageToken'] as String?;
      client.close();
      
      print('📹 Processados ${videos.length} vídeos...');
      
    } catch (e) {
      print('❌ Erro ao buscar vídeos: $e');
      break;
    }
  } while (nextPageToken != null);
  
  return videos;
}

List<Map<String, dynamic>> filterVideos(List<Map<String, dynamic>> videos) {
  return videos.where((video) {
    final title = (video['title'] as String).toLowerCase();
    
    // Exclui vídeos do "The Unit"
    if (title.contains('the unit')) {
      print('⚠️  Excluído (The Unit): ${video['title']}');
      return false;
    }
    
    return true;
  }).toList();
}

Future<Set<String>> getExistingVideos(String supabaseUrl, String supabaseKey) async {
  final existingVideoIds = <String>{};
  
  try {
    final client = HttpClient();
    final url = '$supabaseUrl/rest/v1/workout_videos?select=video_url';
    
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('apikey', supabaseKey);
    request.headers.set('Authorization', 'Bearer $supabaseKey');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List<dynamic>;
      
      for (final video in data) {
        final videoUrl = video['video_url'] as String?;
        if (videoUrl != null) {
          // Extrai ID do YouTube da URL
          final videoIdMatch = RegExp(r'watch\?v=([^&]+)').firstMatch(videoUrl);
          if (videoIdMatch != null) {
            existingVideoIds.add(videoIdMatch.group(1)!);
          }
        }
      }
    }
    
    client.close();
    
  } catch (e) {
    print('⚠️  Erro ao verificar vídeos existentes: $e');
  }
  
  return existingVideoIds;
}

List<Map<String, dynamic>> removeDuplicates(List<Map<String, dynamic>> videos, Set<String> existingIds) {
  return videos.where((video) {
    final videoId = video['videoId'] as String;
    if (existingIds.contains(videoId)) {
      print('⚠️  Duplicata encontrada: ${video['title']}');
      return false;
    }
    return true;
  }).toList();
}

Future<void> insertVideos(String supabaseUrl, String supabaseKey, List<Map<String, dynamic>> videos) async {
  print('\n🔄 Iniciando inserção de ${videos.length} vídeos...');
  
  int successCount = 0;
  int errorCount = 0;

  for (int i = 0; i < videos.length; i++) {
    final video = videos[i];
    final progress = '${i + 1}/${videos.length}';
    
    try {
      print('\n[$progress] 🎥 ${video['title']}');
      
      // Categoriza o vídeo
      final category = categorizeVideo(video['title'] as String);
      final instructor = determineInstructor(video['title'] as String);
      final durationSeconds = parseDuration(video['duration'] as String);
      
      print('  📂 Categoria: ${category['name']} (${category['matched_keyword']})');
      print('  👨‍🏫 Instrutor: $instructor');
      print('  ⏱️ Duração: ${formatDuration(durationSeconds)}');

      // Prepara dados para inserção
      final videoData = {
        'title': video['title'],
        'description': video['description'],
        'video_url': 'https://www.youtube.com/watch?v=${video['videoId']}',
        'thumbnail_url': video['thumbnailUrl'] ?? 'https://img.youtube.com/vi/${video['videoId']}/maxresdefault.jpg',
        'duration_seconds': durationSeconds,
        'instructor': instructor,
        'category_id': category['id'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': true,
        'video_type': 'youtube',
        'view_count': video['viewCount'],
        'like_count': video['likeCount'],
        'published_at': video['publishedAt'],
      };

      // Insere no banco
      await insertSingleVideo(supabaseUrl, supabaseKey, videoData);
      print('  ✅ Inserido com sucesso');
      successCount++;

      // Pequena pausa para evitar rate limit
      await Future.delayed(const Duration(milliseconds: 200));

    } catch (e) {
      print('  ❌ Erro: $e');
      errorCount++;
    }
  }

  // Relatório final
  print('\n' + '=' * 60);
  print('📈 RELATÓRIO FINAL');
  print('=' * 60);
  print('✅ Vídeos inseridos: $successCount');
  print('❌ Erros: $errorCount');
  print('📊 Total processado: ${videos.length}');
  
  if (successCount > 0) {
    print('\n🎉 Importação concluída com sucesso!');
    print('   Verifique os vídeos na seção de treinos do app.');
  }
}

Future<void> insertSingleVideo(String supabaseUrl, String supabaseKey, Map<String, dynamic> videoData) async {
  final client = HttpClient();
  final url = '$supabaseUrl/rest/v1/workout_videos';
  
  final request = await client.postUrl(Uri.parse(url));
  request.headers.set('apikey', supabaseKey);
  request.headers.set('Authorization', 'Bearer $supabaseKey');
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Prefer', 'return=minimal');
  
  request.write(jsonEncode(videoData));
  
  final response = await request.close();
  
  if (response.statusCode != 201) {
    final responseBody = await response.transform(utf8.decoder).join();
    throw Exception('Erro ao inserir vídeo: ${response.statusCode} - $responseBody');
  }
  
  client.close();
}

Map<String, dynamic> categorizeVideo(String title) {
  final titleLower = title.toLowerCase();
  
  // Mapeamento com IDs corretos do banco
  final categories = {
    'pilates': {
      'id': 'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
      'name': 'Pilates',
      'keywords': ['pilates', 'goyá', 'goya'],
    },
    'funcional': {
      'id': '43eb2044-38cf-4193-848c-da46fd7e9cb4',
      'name': 'Funcional',
      'keywords': ['fightfit', 'fight fit', 'funcional', 'crossfit'],
    },
    'musculacao': {
      'id': 'd2d2a9b8-d861-47c7-9d26-283539beda24',
      'name': 'Musculação',
      'keywords': ['treino a', 'treino b', 'treino c', 'treino d', 'treino e', 'musculação', 'musculacao', 'academia'],
    },
    'corrida': {
      'id': '07754890-b092-4386-be56-bb088a2a96f1',
      'name': 'Corrida',
      'keywords': ['corrida', 'running', 'cardio'],
    },
    'hiit': {
      'id': '6d431a7e-8a71-4521-be52-6fa3a717d2dd',
      'name': 'HIIT',
      'keywords': ['hiit', 'alta intensidade', 'interval'],
    },
  };

  // Verifica cada categoria
  for (final entry in categories.entries) {
    final categoryData = entry.value as Map<String, dynamic>;
    final keywords = categoryData['keywords'] as List<String>;
    
    for (final keyword in keywords) {
      if (titleLower.contains(keyword)) {
        return {
          'id': categoryData['id'],
          'name': categoryData['name'],
          'matched_keyword': keyword,
        };
      }
    }
  }

  // Categoria padrão: Musculação
  return {
    'id': 'd2d2a9b8-d861-47c7-9d26-283539beda24',
    'name': 'Musculação',
    'matched_keyword': 'default',
  };
}

String determineInstructor(String title) {
  final titleLower = title.toLowerCase();
  
  if (titleLower.contains('pilates') || titleLower.contains('goyá') || titleLower.contains('goya')) {
    return 'Goya Health Club';
  }
  if (titleLower.contains('fightfit') || titleLower.contains('fight fit')) {
    return 'Fight Fit';
  }
  if (titleLower.contains('bora')) return 'Bora Assessoria';
  
  return 'Treinos de Musculação'; // Padrão
}

int parseDuration(String isoDuration) {
  try {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);
    
    if (match == null) return 0;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return (hours * 3600) + (minutes * 60) + seconds;
  } catch (e) {
    return 0;
  }
}

String formatDuration(int seconds) {
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

String? getBestThumbnail(Map<String, dynamic>? thumbnails) {
  if (thumbnails == null) return null;
  
  const priorities = ['maxres', 'high', 'medium', 'default'];
  
  for (final priority in priorities) {
    final thumbnail = thumbnails[priority] as Map<String, dynamic>?;
    if (thumbnail != null) {
      return thumbnail['url'] as String?;
    }
  }
  
  return null;
} 