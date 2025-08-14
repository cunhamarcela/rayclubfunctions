import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Widget para exibir vídeos do YouTube nas receitas
/// Versão simplificada e estável usando WebView
class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final bool showControls;
  
  const YouTubePlayerWidget({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.showControls = true,
  });

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late WebViewController _webController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      debugPrint('🍽️ [NutritionYouTubePlayer] Inicializando player para videoId: ${widget.videoId}');
      
      final embedUrl = 'https://www.youtube.com/embed/${widget.videoId}?autoplay=0&controls=1&showinfo=0&rel=0&modestbranding=1&playsinline=1';
      
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('🌐 [NutritionYouTubePlayer] Carregando: $url');
            },
            onPageFinished: (String url) {
              debugPrint('🌐 [NutritionYouTubePlayer] ✅ Carregado: $url');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('🌐 [NutritionYouTubePlayer] ❌ Erro: ${error.description}');
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(embedUrl));
        
    } catch (e) {
      debugPrint('🌐 [NutritionYouTubePlayer] ❌ Erro na inicialização: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220, // ✅ Altura fixa para evitar problemas de constraint
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar vídeo',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializePlayer();
              },
              child: Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Carregando vídeo...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return WebViewWidget(controller: _webController);
  }
}