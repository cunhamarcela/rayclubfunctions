import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Debug do Canal YouTube - Ray Club');
  print('=' * 50);

  // Lê a API key do .env
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'YOUTUBE_API_KEY=(.+)').firstMatch(envContent);
  final apiKey = apiKeyMatch?.group(1);

  // Testa diferentes variações do channel ID
  final channelIds = [
    'UCJIOE2pKr_sGWxSuUNEBoaw',
    'UCJIOe2PKr_sGWxSuUNEBoaw', // Variação com 'e' minúsculo
    'UC_JIOE2pKr_sGWxSuUNEBoaw', // Com underscore
  ];

  for (final channelId in channelIds) {
    print('\n🔍 Testando Channel ID: $channelId');
    await testChannel(apiKey!, channelId);
  }

  // Testa busca por palavras-chave relacionadas ao canal
  print('\n🔍 Buscando por palavras-chave...');
  await searchByKeywords(apiKey!, [
    'ray club',
    'rayclub',
    'goya health',
    'fight fit',
    'the unit',
  ]);
}

Future<void> testChannel(String apiKey, String channelId) async {
  try {
    // 1. Primeiro verifica se o canal existe
    final channelUrl = 'https://www.googleapis.com/youtube/v3/channels?key=$apiKey&id=$channelId&part=snippet,statistics';
    
    final client = HttpClient();
    final channelRequest = await client.getUrl(Uri.parse(channelUrl));
    final channelResponse = await channelRequest.close();
    final channelBody = await channelResponse.transform(utf8.decoder).join();
    
    if (channelResponse.statusCode == 200) {
      final channelData = jsonDecode(channelBody);
      final channels = channelData['items'] as List<dynamic>? ?? [];
      
      if (channels.isEmpty) {
        print('❌ Canal não encontrado: $channelId');
        return;
      }
      
      final channel = channels[0];
      final snippet = channel['snippet'] as Map<String, dynamic>;
      final statistics = channel['statistics'] as Map<String, dynamic>;
      
      print('✅ Canal encontrado: ${snippet['title']}');
      print('   Descrição: ${snippet['description']?.substring(0, 100) ?? 'Sem descrição'}...');
      print('   Vídeos: ${statistics['videoCount'] ?? 'N/A'}');
      print('   Inscritos: ${statistics['subscriberCount'] ?? 'N/A'}');
      print('   Visualizações: ${statistics['viewCount'] ?? 'N/A'}');
      
      // 2. Busca vídeos deste canal
      await searchVideos(apiKey, channelId);
      
    } else {
      print('❌ Erro ao verificar canal: ${channelResponse.statusCode}');
    }
    
    client.close();
    
  } catch (e) {
    print('💥 Erro: $e');
  }
}

Future<void> searchVideos(String apiKey, String channelId) async {
  try {
    final client = HttpClient();
    
    // Busca vídeos do canal
    final searchUrl = 'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet&order=date&type=video&maxResults=10';
    final searchRequest = await client.getUrl(Uri.parse(searchUrl));
    final searchResponse = await searchRequest.close();
    final searchBody = await searchResponse.transform(utf8.decoder).join();
    
    if (searchResponse.statusCode == 200) {
      final data = jsonDecode(searchBody);
      final items = data['items'] as List<dynamic>? ?? [];
      
      print('   📹 Vídeos encontrados: ${items.length}');
      
      for (int i = 0; i < items.length && i < 3; i++) {
        final video = items[i];
        final snippet = video['snippet'] as Map<String, dynamic>;
        final title = snippet['title'] as String;
        final publishedAt = snippet['publishedAt'] as String;
        print('   ${i + 1}. $title (${publishedAt.substring(0, 10)})');
      }
    }
    
    client.close();
    
  } catch (e) {
    print('   💥 Erro na busca de vídeos: $e');
  }
}

Future<void> searchByKeywords(String apiKey, List<String> keywords) async {
  final client = HttpClient();
  
  for (final keyword in keywords) {
    try {
      final searchUrl = 'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=${Uri.encodeComponent(keyword)}&part=snippet&order=relevance&type=video&maxResults=5';
      final request = await client.getUrl(Uri.parse(searchUrl));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final items = data['items'] as List<dynamic>? ?? [];
        
        print('\n🔍 Palavra-chave "$keyword": ${items.length} resultados');
        
        for (int i = 0; i < items.length && i < 2; i++) {
          final video = items[i];
          final snippet = video['snippet'] as Map<String, dynamic>;
          final title = snippet['title'] as String;
          final channelTitle = snippet['channelTitle'] as String;
          final channelId = snippet['channelId'] as String;
          
          print('   ${i + 1}. $title');
          print('      Canal: $channelTitle (ID: $channelId)');
        }
      }
      
    } catch (e) {
      print('💥 Erro na busca por "$keyword": $e');
    }
  }
  
  client.close();
} 