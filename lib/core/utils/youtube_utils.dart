/// Utilitários para trabalhar com URLs e thumbnails do YouTube
class YouTubeUtils {
  /// Extrai o ID do vídeo de uma URL do YouTube
  /// 
  /// Suporta os seguintes formatos:
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - https://m.youtube.com/watch?v=VIDEO_ID
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    
    // Padrões de URL do YouTube
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
      RegExp(r'youtube\.com/v/([^?]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    
    return null;
  }
  
  /// Gera a URL da thumbnail de um vídeo do YouTube
  /// 
  /// [url] - URL do vídeo do YouTube
  /// [quality] - Qualidade da thumbnail (maxres, hq, mq, default)
  /// 
  /// Retorna a URL da thumbnail ou null se não conseguir extrair o ID
  static String? getThumbnailUrl(String videoUrl, {String quality = 'hqdefault'}) {
    final videoId = extractVideoId(videoUrl);
    if (videoId == null) return null;
    
    // Qualidades disponíveis:
    // - default (120x90)
    // - mqdefault (320x180)
    // - hqdefault (480x360)
    // - sddefault (640x480)
    // - maxresdefault (1280x720)
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
  
  /// Gera a URL embed de um vídeo do YouTube
  static String? getEmbedUrl(String videoUrl) {
    final videoId = extractVideoId(videoUrl);
    if (videoId == null) return null;
    
    return 'https://www.youtube.com/embed/$videoId';
  }
  
  /// Formata duração de segundos para string legível
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seg';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '$minutes min';
      }
      return '$minutes min $remainingSeconds seg';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      if (minutes == 0) {
        return '$hours h';
      }
      return '$hours h $minutes min';
    }
  }
  
  /// Converte string de duração para minutos
  static int? parseDurationToMinutes(String duration) {
    // Padrões: "45 min", "1h 30min", "2h", "30 seg"
    final hourMinutePattern = RegExp(r'(\d+)\s*h(?:\s*(\d+)\s*min)?');
    final minutePattern = RegExp(r'(\d+)\s*min');
    final secondPattern = RegExp(r'(\d+)\s*seg');
    
    // Tenta hora e minuto
    final hourMinuteMatch = hourMinutePattern.firstMatch(duration);
    if (hourMinuteMatch != null) {
      final hours = int.parse(hourMinuteMatch.group(1)!);
      final minutes = hourMinuteMatch.group(2) != null 
          ? int.parse(hourMinuteMatch.group(2)!) 
          : 0;
      return hours * 60 + minutes;
    }
    
    // Tenta apenas minutos
    final minuteMatch = minutePattern.firstMatch(duration);
    if (minuteMatch != null) {
      return int.parse(minuteMatch.group(1)!);
    }
    
    // Tenta segundos
    final secondMatch = secondPattern.firstMatch(duration);
    if (secondMatch != null) {
      final seconds = int.parse(secondMatch.group(1)!);
      return seconds ~/ 60; // Converte para minutos
    }
    
    return null;
  }
  
  /// Verifica se uma URL é válida do YouTube
  static bool isValidYouTubeUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return extractVideoId(url) != null;
  }
  
  /// Gera múltiplas URLs de thumbnail com fallback para diferentes qualidades
  /// 
  /// Útil para implementar fallback caso a thumbnail de alta qualidade não exista
  static List<String> getThumbnailUrlsWithFallback(String? url) {
    if (url == null || url.isEmpty) return [];
    final videoId = extractVideoId(url);
    if (videoId == null) return [];
    
    return [
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
      'https://img.youtube.com/vi/$videoId/default.jpg',
    ];
  }
}

/// Qualidades disponíveis para thumbnails do YouTube
enum YouTubeThumbnailQuality {
  /// Resolução máxima (1280x720) - pode não estar disponível para todos os vídeos
  maxres,
  /// Alta qualidade (480x360)
  high,
  /// Qualidade média (320x180)
  medium,
  /// Qualidade padrão (120x90)
  default_,
} 