import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';

/// Widget alternativo mais simples para reproduzir vídeos do YouTube
/// Usado como fallback quando o YouTubePlayerWidget padrão falha
class SimpleYouTubePlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const SimpleYouTubePlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.description,
    this.onClose,
  });

  @override
  State<SimpleYouTubePlayer> createState() => _SimpleYouTubePlayerState();
}

class _SimpleYouTubePlayerState extends State<SimpleYouTubePlayer> {
  late WebViewController _webController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      debugPrint('🌐 [SimpleYouTubePlayer] Inicializando WebView para: ${widget.videoUrl}');
      
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null || videoId.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'URL inválida';
        });
        return;
      }

      // URL do YouTube com parâmetros para melhor integração
      final embedUrl = 'https://www.youtube.com/embed/$videoId?'
          'autoplay=0&'
          'controls=1&'
          'showinfo=0&'
          'rel=0&'
          'modestbranding=1&'
          'playsinline=1';

      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('🌐 [SimpleYouTubePlayer] Carregando: $url');
            },
            onPageFinished: (String url) {
              debugPrint('🌐 [SimpleYouTubePlayer] ✅ Carregado: $url');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('🌐 [SimpleYouTubePlayer] ❌ Erro: ${error.description}');
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(embedUrl));
        
    } catch (e) {
      debugPrint('🌐 [SimpleYouTubePlayer] ❌ Erro na inicialização: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao inicializar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    final isSimpleMode = widget.title.isEmpty;

    if (isSimpleMode) {
      return _buildSimplePlayer();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (widget.onClose != null) {
                      widget.onClose!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Player
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildWebViewPlayer(),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSimplePlayer() {
    return Container(
      color: Colors.black,
      child: _buildWebViewPlayer(),
    );
  }

  Widget _buildWebViewPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          WebViewWidget(controller: _webController),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ops! Algo deu errado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Não foi possível carregar o vídeo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  _initializeWebView();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
