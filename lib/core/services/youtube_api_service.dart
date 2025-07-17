import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/env_config.dart';

/// Serviço para integração com a YouTube Data API v3
/// Extrai metadados de vídeos do canal do Ray Club
class YouTubeApiService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final Dio _dio;
  final String _apiKey;
  
  // Add OAuth support for private videos
  String? _accessToken;

  YouTubeApiService({required String apiKey}) 
      : _apiKey = apiKey,
        _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Set OAuth access token for private video access
  void setAccessToken(String accessToken) {
    _accessToken = accessToken;
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  /// Extrai todos os vídeos de um canal do YouTube
  /// 
  /// [channelId] - ID do canal (ex: UCJIOE2pKr_sGWxSuUNEBoaw)
  /// [maxResults] - Número máximo de vídeos a serem retornados (padrão: 50, máximo: 50)
  /// 
  /// Retorna lista de mapas com metadados dos vídeos
  Future<List<Map<String, dynamic>>> getChannelVideos(
    String channelId, {
    int maxResults = 50,
    bool includePrivate = false,
  }) async {
    try {
      // For private videos, we need to use OAuth
      if (includePrivate && _accessToken == null) {
        throw Exception('OAuth access token required for private videos');
      }

      final queryParams = {
        'part': 'snippet,contentDetails,status',
        'channelId': channelId,
        'maxResults': maxResults.toString(),
        'order': 'date',
        'type': 'video',
      };

      // Use OAuth token if available, otherwise use API key
      if (_accessToken != null) {
        // Don't add key parameter when using OAuth
      } else {
        queryParams['key'] = _apiKey;
      }

      final response = await _dio.get('search', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List<dynamic>? ?? [];
        
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching channel videos: $e');
      return [];
    }
  }

  /// Categorizar vídeo com base no título
  /// 
  /// Retorna o UUID da categoria correspondente
  Map<String, dynamic> categorizeVideo(String title) {
    final titleLower = title.toLowerCase();
    
    // Mapeamento de categorias com UUIDs do banco
    final categories = {
      'fisioterapia': {
        'id': 'da178dba-ae94-425a-aaed-133af7b1bb0f',
        'keywords': ['the unit', 'fisio', 'reabilitação', 'lesao', 'lesão'],
      },
      'pilates': {
        'id': 'fe034f6d-aa79-436c-b0b7-7aea572f08c1', 
        'keywords': ['pilates', 'goyá', 'goya'],
      },
      'funcional': {
        'id': '43eb2044-38cf-4193-848c-da46fd7e9cb4',
        'keywords': ['fightfit', 'fight fit', 'funcional', 'crossfit'],
      },
      'musculacao': {
        'id': 'd2d2a9b8-d861-47c7-9d26-283539beda24',
        'keywords': ['treino a', 'treino b', 'treino c', 'treino d', 'treino e', 'musculação', 'musculacao', 'academia'],
      },
      'corrida': {
        'id': '8f234567-1234-5678-9abc-def012345678', // UUID placeholder - ajustar conforme banco
        'keywords': ['corrida', 'running', 'cardio'],
      },
    };

    // Verifica cada categoria
    for (final entry in categories.entries) {
      final categoryData = entry.value as Map<String, dynamic>;
      final keywords = categoryData['keywords'] as List<String>;
      
      for (final keyword in keywords) {
        if (titleLower.contains(keyword)) {
          return {
            'category_id': categoryData['id'],
            'category_name': entry.key,
            'matched_keyword': keyword,
          };
        }
      }
    }

    // Categoria padrão se não encontrar correspondência
    return {
      'category_id': 'd2d2a9b8-d861-47c7-9d26-283539beda24', // Musculação como padrão
      'category_name': 'musculacao',
      'matched_keyword': 'default',
    };
  }

  /// Determinar instrutor com base no título
  String determineInstructor(String title) {
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('the unit')) return 'The Unit';
    if (titleLower.contains('pilates') || titleLower.contains('goyá') || titleLower.contains('goya')) {
      return 'Goya Health Club';
    }
    if (titleLower.contains('fightfit') || titleLower.contains('fight fit')) {
      return 'Fight Fit';
    }
    if (titleLower.contains('bora')) return 'Bora Assessoria';
    
    return 'Treinos de Musculação'; // Padrão
  }

  /// Converter duração ISO 8601 para segundos
  /// 
  /// Exemplo: PT4M13S -> 253 segundos
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
      print('Erro ao parsear duração $isoDuration: $e');
      return 0;
    }
  }

  /// Seleciona a melhor thumbnail disponível
  String? _getBestThumbnail(Map<String, dynamic>? thumbnails) {
    if (thumbnails == null) return null;
    
    // Ordem de preferência: maxres -> high -> medium -> default
    const priorities = ['maxres', 'high', 'medium', 'default'];
    
    for (final priority in priorities) {
      final thumbnail = thumbnails[priority] as Map<String, dynamic>?;
      if (thumbnail != null) {
        return thumbnail['url'] as String?;
      }
    }
    
    return null;
  }

  /// Gerar URL do vídeo no YouTube
  String generateVideoUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// Gerar URL da thumbnail customizada
  String generateThumbnailUrl(String videoId, {String quality = 'maxresdefault'}) {
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
} 