import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Investigação Detalhada do Canal RayClub');
  print('=' * 50);

  // Lê a API key do .env
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'YOUTUBE_API_KEY=(.+)').firstMatch(envContent);
  final apiKey = apiKeyMatch?.group(1);

  if (apiKey == null) {
    print('❌ API key não encontrada');
    exit(1);
  }

  print('✅ API Key configurada');

  // Vamos investigar de várias formas
  await checkChannelDetails(apiKey, 'UCJIOE2pKr_sGWxSuUNEBoaw');
  await searchByChannelName(apiKey);
  await searchByBrandKeywords(apiKey);
  await checkPlaylistVideos(apiKey, 'UCJIOE2pKr_sGWxSuUNEBoaw');
}

Future<void> checkChannelDetails(String apiKey, String channelId) async {
  print('\n1️⃣ VERIFICANDO DETALHES DO CANAL');
  print('-' * 40);
  
  try {
    final client = HttpClient();
    final url = 'https://www.googleapis.com/youtube/v3/channels?key=$apiKey&id=$channelId&part=snippet,statistics,contentDetails';
    
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      final channels = data['items'] as List<dynamic>? ?? [];
      
      if (channels.isNotEmpty) {
        final channel = channels[0];
        final snippet = channel['snippet'] as Map<String, dynamic>;
        final statistics = channel['statistics'] as Map<String, dynamic>;
        final contentDetails = channel['contentDetails'] as Map<String, dynamic>?;
        
        print('✅ Canal encontrado: ${snippet['title']}');
        print('📅 Criado em: ${snippet['publishedAt']}');
        print('📊 Estatísticas:');
        print('   📹 Vídeos: ${statistics['videoCount'] ?? 'N/A'}');
        print('   👥 Inscritos: ${statistics['subscriberCount'] ?? 'N/A'}');
        print('   👀 Visualizações: ${statistics['viewCount'] ?? 'N/A'}');
        
        if (contentDetails != null) {
          final relatedPlaylists = contentDetails['relatedPlaylists'] as Map<String, dynamic>?;
          if (relatedPlaylists != null) {
            final uploadsPlaylist = relatedPlaylists['uploads'] as String?;
            print('📁 Playlist de uploads: $uploadsPlaylist');
            
            if (uploadsPlaylist != null) {
              await checkPlaylistVideos(apiKey, uploadsPlaylist);
            }
          }
        }
      } else {
        print('❌ Canal não encontrado com ID: $channelId');
      }
    } else {
      print('❌ Erro na consulta: ${response.statusCode}');
      print('Response: $body');
    }
    
    client.close();
    
  } catch (e) {
    print('💥 Erro: $e');
  }
}

Future<void> checkPlaylistVideos(String apiKey, String playlistId) async {
  print('\n2️⃣ VERIFICANDO PLAYLIST DE UPLOADS: $playlistId');
  print('-' * 40);
  
  try {
    final client = HttpClient();
    final url = 'https://www.googleapis.com/youtube/v3/playlistItems?key=$apiKey&playlistId=$playlistId&part=snippet&maxResults=10';
    
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      final items = data['items'] as List<dynamic>? ?? [];
      
      print('📹 Vídeos encontrados na playlist: ${items.length}');
      
      for (int i = 0; i < items.length && i < 5; i++) {
        final item = items[i];
        final snippet = item['snippet'] as Map<String, dynamic>;
        final title = snippet['title'] as String;
        final publishedAt = snippet['publishedAt'] as String;
        final videoId = snippet['resourceId']['videoId'] as String;
        
        print('${i + 1}. $title');
        print('   📅 ${publishedAt.substring(0, 10)}');
        print('   🆔 $videoId');
        print('   🔗 https://www.youtube.com/watch?v=$videoId');
        print('');
      }
      
    } else {
      print('❌ Erro na consulta da playlist: ${response.statusCode}');
      print('Response: $body');
    }
    
    client.close();
    
  } catch (e) {
    print('💥 Erro: $e');
  }
}

Future<void> searchByChannelName(String apiKey) async {
  print('\n3️⃣ BUSCANDO POR NOME DO CANAL');
  print('-' * 40);
  
  final searchTerms = ['RayClub', 'Ray Club', 'rayclub'];
  
  for (final term in searchTerms) {
    try {
      final client = HttpClient();
      final url = 'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=${Uri.encodeComponent(term)}&part=snippet&type=channel&maxResults=10';
      
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final items = data['items'] as List<dynamic>? ?? [];
        
        print('\n🔍 Busca por "$term": ${items.length} canais encontrados');
        
        for (int i = 0; i < items.length && i < 3; i++) {
          final item = items[i];
          final snippet = item['snippet'] as Map<String, dynamic>;
          final channelId = item['id']['channelId'] as String;
          final title = snippet['title'] as String;
          final description = snippet['description'] as String;
          
          print('${i + 1}. $title');
          print('   🆔 $channelId');
          print('   📝 ${description.length > 100 ? description.substring(0, 100) + '...' : description}');
          print('');
        }
      }
      
      client.close();
      
    } catch (e) {
      print('💥 Erro na busca por "$term": $e');
    }
  }
}

Future<void> searchByBrandKeywords(String apiKey) async {
  print('\n4️⃣ BUSCANDO POR PALAVRAS-CHAVE DAS MARCAS');
  print('-' * 40);
  
  final keywords = [
    'Goya Health Club pilates',
    'Fight Fit treino',
    'Treino A musculação',
    'Ray Club treino',
  ];
  
  for (final keyword in keywords) {
    try {
      final client = HttpClient();
      final url = 'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=${Uri.encodeComponent(keyword)}&part=snippet&type=video&maxResults=5';
      
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final items = data['items'] as List<dynamic>? ?? [];
        
        print('\n🔍 "$keyword": ${items.length} vídeos');
        
        for (int i = 0; i < items.length && i < 2; i++) {
          final item = items[i];
          final snippet = item['snippet'] as Map<String, dynamic>;
          final title = snippet['title'] as String;
          final channelTitle = snippet['channelTitle'] as String;
          final channelId = snippet['channelId'] as String;
          final videoId = item['id']['videoId'] as String;
          
          print('${i + 1}. $title');
          print('   📺 Canal: $channelTitle');
          print('   🆔 Canal ID: $channelId');
          print('   🎥 Vídeo: https://www.youtube.com/watch?v=$videoId');
          
          // Se encontrarmos o canal RayClub, vamos investigar mais
          if (channelTitle.toLowerCase().contains('rayclub') || 
              channelTitle.toLowerCase().contains('ray club') ||
              channelId == 'UCJIOE2pKr_sGWxSuUNEBoaw') {
            print('   🎯 CANAL RELEVANTE ENCONTRADO!');
          }
          print('');
        }
      }
      
      client.close();
      
    } catch (e) {
      print('💥 Erro na busca por "$keyword": $e');
    }
  }
} 