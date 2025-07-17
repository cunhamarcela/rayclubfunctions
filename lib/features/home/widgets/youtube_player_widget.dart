// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';

/// Widget para reproduzir vídeos do YouTube com controles nativos
class YouTubePlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const YouTubePlayerWidget({
    super.key,
    required this.videoUrl,
    required this.title,
    this.description,
    this.onClose,
  });

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      // Extrair o ID do vídeo da URL
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      
      if (videoId != null && videoId.isNotEmpty) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            captionLanguage: 'pt',
            forceHD: false,
            useHybridComposition: true,
          ),
        );

        _controller.addListener(_onPlayerStateChange);
      } else {
        // Handle invalid URL
        setState(() {
          _hasError = true;
          _errorMessage = 'URL do YouTube inválida: ${widget.videoUrl}';
        });
        debugPrint('URL do YouTube inválida: ${widget.videoUrl}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao inicializar player: $e';
      });
      debugPrint('Erro ao inicializar player: $e');
    }
  }

  void _onPlayerStateChange() {
    try {
      if (_controller.value.isReady && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
          _hasError = false;
        });
      }

      if (_controller.value.isFullScreen != _isFullScreen) {
        setState(() {
          _isFullScreen = _controller.value.isFullScreen;
        });
      }

      // Detectar erros do player
      if (_controller.value.hasError) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erro no player do YouTube';
        });
      }
    } catch (e) {
      debugPrint('Erro no listener do player: $e');
    }
  }

  @override
  void dispose() {
    try {
      _controller.removeListener(_onPlayerStateChange);
      _controller.dispose();
    } catch (e) {
      debugPrint('Erro ao fazer dispose do controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verificar se há erro ou URL inválida
    if (_hasError) {
      return _buildErrorWidget();
    }

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
    if (videoId == null || videoId.isEmpty) {
      return _buildErrorWidget();
    }

    // Modo simplificado (sem header) quando title estiver vazio
    final isSimpleMode = widget.title.isEmpty;

    if (isSimpleMode) {
      return _buildSimplePlayer();
    }

    // Modo padrão com header
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
          // Handle para arrastar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header com título e botão fechar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.description != null && widget.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
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
          
          // Player do YouTube
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
              child: _buildPlayer(),
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
      child: _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayerBuilder(
        onExitFullScreen: () {
          // Forçar orientação portrait ao sair do fullscreen
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          onReady: () {
            setState(() {
              _isPlayerReady = true;
              _hasError = false;
            });
            debugPrint('Player pronto para: ${widget.title}');
          },
          onEnded: (metaData) {
            debugPrint('Vídeo finalizado: ${metaData.videoId}');
          },
        ),
        builder: (context, player) {
          return Column(
            children: [
              // Player principal
              Expanded(child: player),
              
              // Controles adicionais (opcional)
              if (_isPlayerReady)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 12
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.replay_10,
                        onPressed: () {
                          try {
                            _controller.seekTo(
                              Duration(
                                seconds: (_controller.value.position.inSeconds - 10).clamp(0, double.infinity).toInt(),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Erro ao retroceder: $e');
                          }
                        },
                        label: '-10s',
                      ),
                      _buildControlButton(
                        icon: _controller.value.isPlaying 
                            ? Icons.pause 
                            : Icons.play_arrow,
                        onPressed: () {
                          try {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          } catch (e) {
                            debugPrint('Erro ao play/pause: $e');
                          }
                        },
                        label: _controller.value.isPlaying ? 'Pausar' : 'Play',
                      ),
                      _buildControlButton(
                        icon: Icons.forward_10,
                        onPressed: () {
                          try {
                            _controller.seekTo(
                              Duration(
                                seconds: _controller.value.position.inSeconds + 10,
                              ),
                            );
                          } catch (e) {
                            debugPrint('Erro ao avançar: $e');
                          }
                        },
                        label: '+10s',
                      ),
                      _buildControlButton(
                        icon: Icons.fullscreen,
                        onPressed: () {
                          try {
                            _controller.toggleFullScreenMode();
                          } catch (e) {
                            debugPrint('Erro ao alternar tela cheia: $e');
                          }
                        },
                        label: 'Tela cheia',
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar vídeo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'URL do YouTube inválida ou vídeo não disponível.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'URL: ${widget.videoUrl}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _initializePlayer();
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