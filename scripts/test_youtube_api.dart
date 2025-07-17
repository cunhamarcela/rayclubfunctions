import 'dart:convert';
import 'dart:io';

void main() async {
  print('🎬 Teste da YouTube API - Ray Club');
  print('=' * 50);

  // Lê a API key do .env
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Arquivo .env não encontrado');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'YOUTUBE_API_KEY=(.+)').firstMatch(envContent);
  
  if (apiKeyMatch == null) {
    print('❌ YOUTUBE_API_KEY não encontrada no .env');
    exit(1);
  }

  final apiKey = apiKeyMatch.group(1);
  print('✅ API Key encontrada: ${apiKey?.substring(0, 10)}...');

  // Testa conexão com a API
  final channelId = 'UCJIOE2pKr_sGWxSuUNEBoaw';
  final url = 'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet&order=date&type=video&maxResults=5';

  print('\n📡 Testando conexão com YouTube API...');
  print('🔗 URL: ${url.substring(0, 80)}...');

  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    print('📊 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      
      final items = data['items'] as List<dynamic>? ?? [];
      print('✅ Sucesso! Encontrados ${items.length} vídeos');
      
      print('\n🎥 Primeiros vídeos encontrados:');
      for (int i = 0; i < items.length && i < 3; i++) {
        final video = items[i];
        final snippet = video['snippet'] as Map<String, dynamic>;
        final title = snippet['title'] as String;
        final videoId = video['id']['videoId'] as String;
        
        print('${i + 1}. $title');
        print('   ID: $videoId');
        print('   URL: https://www.youtube.com/watch?v=$videoId');
        print('');
      }
      
      print('🎉 Teste da YouTube API concluído com sucesso!');
      print('✅ Sua API key está funcionando corretamente');
      print('📊 O canal contém vídeos que podem ser importados');
      
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('❌ Erro na API: ${response.statusCode}');
      print('Response: $responseBody');
      
      if (response.statusCode == 403) {
        print('\n🔍 Possíveis causas:');
        print('- Quota da API excedida (você tem 10.000 unidades/dia)');
        print('- API key inválida ou expirada');
        print('- YouTube Data API v3 não habilitada no Google Cloud Console');
      }
    }
    
    client.close();
    
  } catch (e) {
    print('💥 Erro de conexão: $e');
    print('\n🔍 Verifique:');
    print('- Conexão com a internet');
    print('- Configuração da API key');
    print('- Firewall/proxy');
  }
} 