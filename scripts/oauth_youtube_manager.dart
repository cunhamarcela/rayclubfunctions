import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para importar vídeos privados usando autenticação OAuth como manager do canal
/// Este script autentica usando suas credenciais de manager para acessar vídeos privados
class YouTubeOAuthManager {
  static const String _authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _tokenUrl = 'https://oauth2.googleapis.com/token';
  static const String _redirectUri = 'urn:ietf:wg:oauth:2.0:oob'; // For desktop apps
  
  final String _clientId;
  final String _clientSecret;
  final Dio _dio = Dio();
  
  YouTubeOAuthManager({
    required String clientId,
    required String clientSecret,
  }) : _clientId = clientId, _clientSecret = clientSecret;

  /// Gera URL de autorização para login como manager
  String getAuthorizationUrl() {
    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'scope': 'https://www.googleapis.com/auth/youtube.readonly',
      'access_type': 'offline',
      'prompt': 'consent',
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$_authUrl?$queryString';
  }

  /// Troca código de autorização por token de acesso
  Future<Map<String, dynamic>> exchangeCodeForToken(String authCode) async {
    try {
      final response = await _dio.post(_tokenUrl, data: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': authCode,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Falha na autenticação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao trocar código por token: $e');
    }
  }

  /// Busca vídeos privados do canal usando token OAuth
  Future<List<Map<String, dynamic>>> getPrivateChannelVideos(
    String accessToken,
    String channelId,
  ) async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
      
      // Busca a playlist de uploads do canal
      final channelResponse = await dio.get(
        'https://www.googleapis.com/youtube/v3/channels',
        queryParameters: {
          'part': 'contentDetails',
          'id': channelId,
        },
      );

      if (channelResponse.data['items'].isEmpty) {
        throw Exception('Canal não encontrado ou sem acesso');
      }

      final uploadsPlaylistId = channelResponse.data['items'][0]
          ['contentDetails']['relatedPlaylists']['uploads'];

      // Busca todos os vídeos da playlist (incluindo privados)
      final videosResponse = await dio.get(
        'https://www.googleapis.com/youtube/v3/playlistItems',
        queryParameters: {
          'part': 'snippet,contentDetails',
          'playlistId': uploadsPlaylistId,
          'maxResults': 50,
        },
      );

      final items = videosResponse.data['items'] as List<dynamic>? ?? [];
      
      // Busca detalhes completos dos vídeos
      final videoIds = items
          .map((item) => item['snippet']['resourceId']['videoId'])
          .join(',');

      if (videoIds.isEmpty) {
        return [];
      }

      final detailsResponse = await dio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,status',
          'id': videoIds,
        },
      );

      final videoDetails = detailsResponse.data['items'] as List<dynamic>? ?? [];
      
      return videoDetails.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final contentDetails = video['contentDetails'] as Map<String, dynamic>;
        final status = video['status'] as Map<String, dynamic>;
        
        return {
          'videoId': video['id'] as String,
          'title': snippet['title'] as String? ?? '',
          'description': snippet['description'] as String? ?? '',
          'thumbnailUrl': _getBestThumbnail(snippet['thumbnails'] as Map<String, dynamic>?),
          'publishedAt': snippet['publishedAt'] as String? ?? '',
          'duration': contentDetails['duration'] as String? ?? 'PT0S',
          'privacyStatus': status['privacyStatus'] as String? ?? 'private',
          'channelTitle': snippet['channelTitle'] as String? ?? '',
        };
      }).toList();

    } catch (e) {
      throw Exception('Erro ao buscar vídeos privados: $e');
    }
  }

  String _getBestThumbnail(Map<String, dynamic>? thumbnails) {
    if (thumbnails == null) return '';
    
    // Ordem de preferência: maxres > high > medium > default
    for (final quality in ['maxres', 'high', 'medium', 'default']) {
      if (thumbnails.containsKey(quality)) {
        return thumbnails[quality]['url'] as String? ?? '';
      }
    }
    return '';
  }
}

/// Categoriza vídeo baseado no título
Map<String, dynamic> categorizeVideo(String title, String description) {
  final titleLower = title.toLowerCase();
  final descLower = description.toLowerCase();
  final combined = '$titleLower $descLower';

  // Exclui vídeos "The Unit"
  if (combined.contains('the unit')) {
    return {'skip': true, 'reason': 'Vídeo "The Unit" excluído conforme solicitado'};
  }

  // Categorização baseada no título/descrição
  if (combined.contains('pilates') || combined.contains('goyá') || combined.contains('goya')) {
    return {
      'categoryId': 'fe034f6d-aa79-436c-b0b7-7aea572f08c1', // Pilates
      'instructor': 'Goya Health Club',
    };
  }
  
  if (combined.contains('fightfit') || combined.contains('fight fit')) {
    return {
      'categoryId': '43eb2044-38cf-4193-848c-da46fd7e9cb4', // Funcional
      'instructor': 'Fight Fit',
    };
  }
  
  if (combined.contains('treino a') || combined.contains('treino b') || 
      combined.contains('treino c') || combined.contains('treino d') || 
      combined.contains('treino e')) {
    return {
      'categoryId': 'd2d2a9b8-d861-47c7-9d26-283539beda24', // Musculação
      'instructor': 'Treinos de Musculação',
    };
  }
  
  if (combined.contains('corrida') || combined.contains('running')) {
    return {
      'categoryId': '07754890-b092-4386-be56-bb088a2a96f1', // Corrida
      'instructor': 'Ray Club',
    };
  }
  
  if (combined.contains('hiit')) {
    return {
      'categoryId': '6d431a7e-8a71-4521-be52-6fa3a717d2dd', // HIIT
      'instructor': 'Ray Club',
    };
  }
  
  if (combined.contains('fisioterapia') || combined.contains('reabilitação')) {
    return {
      'categoryId': 'da178dba-ae94-425a-aaed-133af7b1bb0f', // Fisioterapia
      'instructor': 'Ray Club',
    };
  }

  // Default: Musculação
  return {
    'categoryId': 'd2d2a9b8-d861-47c7-9d26-283539beda24', // Musculação
    'instructor': 'Ray Club',
  };
}

/// Converte duração ISO 8601 para segundos
int parseDuration(String duration) {
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(duration);
  
  if (match == null) return 0;
  
  final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
  final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
  final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
  
  return hours * 3600 + minutes * 60 + seconds;
}

Future<void> main() async {
  try {
    // Carrega variáveis de ambiente
    final env = DotEnv(includePlatformEnvironment: true)..load();
    
    final clientId = env['GOOGLE_OAUTH_CLIENT_ID'];
    final clientSecret = env['GOOGLE_OAUTH_CLIENT_SECRET'];
    final supabaseUrl = env['SUPABASE_URL'];
    final supabaseAnonKey = env['SUPABASE_ANON_KEY'];
    
    if (clientId == null || clientSecret == null) {
      print('❌ ERRO: Configure GOOGLE_OAUTH_CLIENT_ID e GOOGLE_OAUTH_CLIENT_SECRET no .env');
      print('');
      print('📋 Para obter as credenciais OAuth:');
      print('1. Acesse: https://console.developers.google.com/');
      print('2. Crie um projeto ou selecione um existente');
      print('3. Habilite a YouTube Data API v3');
      print('4. Crie credenciais OAuth 2.0 para aplicação desktop');
      print('5. Adicione as credenciais ao arquivo .env');
      return;
    }

    if (supabaseUrl == null || supabaseAnonKey == null) {
      print('❌ ERRO: Configure SUPABASE_URL e SUPABASE_ANON_KEY no .env');
      return;
    }

    // Inicializa Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    final supabase = Supabase.instance.client;

    // Inicializa OAuth manager
    final oauthManager = YouTubeOAuthManager(
      clientId: clientId,
      clientSecret: clientSecret,
    );

    print('🔐 Autenticação OAuth necessária para acessar vídeos privados');
    print('');
    print('📋 PASSOS PARA AUTENTICAÇÃO:');
    print('1. Acesse o link abaixo no seu navegador');
    print('2. Faça login com sua conta de manager do canal');
    print('3. Autorize o acesso aos dados do YouTube');
    print('4. Copie o código de autorização que aparecerá');
    print('');
    
    final authUrl = oauthManager.getAuthorizationUrl();
    print('🔗 Link de autorização:');
    print(authUrl);
    print('');
    
    stdout.write('Cole aqui o código de autorização: ');
    final authCode = stdin.readLineSync()?.trim();
    
    if (authCode == null || authCode.isEmpty) {
      print('❌ Código de autorização inválido');
      return;
    }

    print('🔄 Trocando código por token de acesso...');
    final tokenData = await oauthManager.exchangeCodeForToken(authCode);
    final accessToken = tokenData['access_token'] as String;
    
    print('✅ Autenticação bem-sucedida!');
    print('');

    // Busca vídeos privados do canal
    const channelId = 'UCJIOE2pKr_sGWxSuUNEBoaw';
    print('🔍 Buscando vídeos privados do canal...');
    
    final videos = await oauthManager.getPrivateChannelVideos(accessToken, channelId);
    
    if (videos.isEmpty) {
      print('⚠️  Nenhum vídeo encontrado no canal');
      return;
    }

    print('📹 Encontrados ${videos.length} vídeos no canal');
    print('');

    // Verifica duplicatas existentes
    final existingVideos = await supabase
        .from('workout_videos')
        .select('video_url')
        .execute();
    
    final existingVideoIds = <String>{};
    if (existingVideos.data != null) {
      for (final video in existingVideos.data) {
        final url = video['video_url'] as String?;
        if (url != null && url.contains('youtube.com/watch?v=')) {
          final videoId = url.split('v=')[1].split('&')[0];
          existingVideoIds.add(videoId);
        }
      }
    }

    // Processa cada vídeo
    int inserted = 0;
    int skipped = 0;
    int errors = 0;

    for (final video in videos) {
      final videoId = video['videoId'] as String;
      final title = video['title'] as String;
      final description = video['description'] as String;
      final privacyStatus = video['privacyStatus'] as String;

      print('📹 Processando: $title (Status: $privacyStatus)');

      // Verifica se já existe
      if (existingVideoIds.contains(videoId)) {
        print('  ⏭️  Já existe no banco de dados');
        skipped++;
        continue;
      }

      // Categoriza o vídeo
      final category = categorizeVideo(title, description);
      
      if (category['skip'] == true) {
        print('  ⏭️  ${category['reason']}');
        skipped++;
        continue;
      }

      try {
        // Insere no banco de dados
        await supabase.from('workout_videos').insert({
          'title': title,
          'description': description,
          'video_url': 'https://www.youtube.com/watch?v=$videoId',
          'duration_seconds': parseDuration(video['duration'] as String),
          'thumbnail_url': video['thumbnailUrl'] as String,
          'category_id': category['categoryId'],
          'instructor': category['instructor'],
          'is_premium': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        print('  ✅ Inserido com sucesso');
        inserted++;

      } catch (e) {
        print('  ❌ Erro ao inserir: $e');
        errors++;
      }
    }

    print('');
    print('📊 RESUMO DA IMPORTAÇÃO:');
    print('  ✅ Inseridos: $inserted vídeos');
    print('  ⏭️  Ignorados: $skipped vídeos');
    print('  ❌ Erros: $errors vídeos');
    print('');
    print('🎉 Importação concluída!');

  } catch (e) {
    print('❌ Erro geral: $e');
    exit(1);
  }
} 