// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/utils/youtube_utils.dart';

/// Widget para exibir thumbnails de vídeos do YouTube com fallback automático
class YouTubeThumbnailWidget extends StatefulWidget {
  /// URL do vídeo do YouTube
  final String? youtubeUrl;
  
  /// URL de imagem de fallback caso não seja um vídeo do YouTube ou a thumbnail não carregue
  final String? fallbackImageUrl;
  
  /// Largura do widget
  final double? width;
  
  /// Altura do widget
  final double? height;
  
  /// Ajuste da imagem
  final BoxFit fit;
  
  /// Border radius
  final BorderRadius? borderRadius;
  
  /// Se deve mostrar o ícone do YouTube sobreposto
  final bool showPlayIcon;
  
  /// Qualidade da thumbnail (padrão: alta qualidade)
  final YouTubeThumbnailQuality quality;
  
  /// Widget de loading personalizado
  final Widget? loadingWidget;
  
  /// Widget de erro personalizado
  final Widget? errorWidget;

  const YouTubeThumbnailWidget({
    super.key,
    required this.youtubeUrl,
    this.fallbackImageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showPlayIcon = true,
    this.quality = YouTubeThumbnailQuality.high,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<YouTubeThumbnailWidget> createState() => _YouTubeThumbnailWidgetState();
}

class _YouTubeThumbnailWidgetState extends State<YouTubeThumbnailWidget> {
  String? _currentImageUrl;
  List<String> _fallbackUrls = [];
  int _currentFallbackIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeImageUrl();
  }

  @override
  void didUpdateWidget(YouTubeThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeUrl != widget.youtubeUrl || 
        oldWidget.quality != widget.quality) {
      _initializeImageUrl();
    }
  }

  void _initializeImageUrl() {
    _isLoading = true;
    _hasError = false;
    _currentFallbackIndex = 0;

    // Verifica se a URL é válida antes de processar
    if (widget.youtubeUrl == null || widget.youtubeUrl!.isEmpty) {
      if (widget.fallbackImageUrl != null) {
        // Se não há URL do YouTube, usa a imagem de fallback
        _currentImageUrl = widget.fallbackImageUrl;
        _fallbackUrls = [];
      } else {
        // Sem imagem disponível
        _currentImageUrl = null;
        _fallbackUrls = [];
        _scheduleStateUpdate(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }
    } else {
      // Primeiro tenta usar a thumbnail do YouTube
      String qualityString;
      switch (widget.quality) {
        case YouTubeThumbnailQuality.maxres:
          qualityString = 'maxresdefault';
          break;
        case YouTubeThumbnailQuality.high:
          qualityString = 'hqdefault';
          break;
        case YouTubeThumbnailQuality.medium:
          qualityString = 'mqdefault';
          break;
        case YouTubeThumbnailQuality.default_:
          qualityString = 'default';
          break;
      }
      
      final thumbnailUrl = YouTubeUtils.getThumbnailUrl(
        widget.youtubeUrl!,
        quality: qualityString,
      );

      if (thumbnailUrl != null) {
        // Se for vídeo do YouTube, prepara as URLs de fallback
        _fallbackUrls = YouTubeUtils.getThumbnailUrlsWithFallback(widget.youtubeUrl!);
        _currentImageUrl = thumbnailUrl;
      } else if (widget.fallbackImageUrl != null) {
        // Se não for YouTube, usa a imagem de fallback
        _currentImageUrl = widget.fallbackImageUrl;
        _fallbackUrls = [];
      } else {
        // Sem imagem disponível
        _currentImageUrl = null;
        _fallbackUrls = [];
        _scheduleStateUpdate(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleStateUpdate(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(callback);
      }
    });
  }

  void _onImageError() {
    if (_currentFallbackIndex < _fallbackUrls.length - 1) {
      // Tenta a próxima qualidade de thumbnail
      _scheduleStateUpdate(() {
        _currentFallbackIndex++;
        _currentImageUrl = _fallbackUrls[_currentFallbackIndex];
        _hasError = false;
      });
    } else if (widget.fallbackImageUrl != null && 
               _currentImageUrl != widget.fallbackImageUrl) {
      // Tenta a imagem de fallback fornecida
      _scheduleStateUpdate(() {
        _currentImageUrl = widget.fallbackImageUrl;
        _hasError = false;
      });
    } else {
      // Esgotou todas as opções
      _scheduleStateUpdate(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem principal
            _buildMainImage(),
            
            // Ícone do YouTube (se aplicável)
            if (widget.showPlayIcon && 
                widget.youtubeUrl != null && 
                YouTubeUtils.isValidYouTubeUrl(widget.youtubeUrl!))
              _buildPlayIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_currentImageUrl == null) {
      return _buildLoadingWidget();
    }

    return Image.network(
      _currentImageUrl!,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Imagem carregada com sucesso
          _scheduleStateUpdate(() {
            _isLoading = false;
          });
          return child;
        }
        return _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        _onImageError();
        return _buildLoadingWidget();
      },
    );
  }

  Widget _buildPlayIcon() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000), // YouTube red
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
} 