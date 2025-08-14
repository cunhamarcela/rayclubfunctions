// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/home/widgets/simple_youtube_player.dart';

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
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _useSimpleFallback = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    // ✅ TEMPORÁRIO: Forçar uso do player WebView que é mais estável
    debugPrint('🎬 [YouTubePlayerWidget] Usando SimpleYouTubePlayer por padrão');
    setState(() {
      _useSimpleFallback = true;
    });
    // _initializePlayer(); // Desabilitado temporariamente
  }

  void _initializePlayer() {
    try {
      debugPrint('🎬 [YouTubePlayerWidget] Inicializando player para URL: ${widget.videoUrl}');
      
      // Extrair o ID do vídeo da URL
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      debugPrint('🎬 [YouTubePlayerWidget] Video ID extraído: $videoId');
      
      if (videoId != null && videoId.isNotEmpty) {
        // ✅ MELHORIA: Delay para garantir que o widget esteja montado
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          
          try {
            _controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,  // ✅ Manter false para evitar problemas
                mute: false,
                enableCaption: true,
                captionLanguage: 'pt',
                forceHD: false,
                useHybridComposition: true,  // ✅ Importante para estabilidade
                disableDragSeek: false,
                loop: false,
                isLive: false,
                hideControls: false,
                controlsVisibleAtStart: true,  // ✅ Garantir que controles apareçam
              ),
            );

            _controller!.addListener(_onPlayerStateChange);
            debugPrint('🎬 [YouTubePlayerWidget] ✅ Controller criado com sucesso');
            
            if (mounted) {
              setState(() {
                _hasError = false;
              });
            }
          } catch (e) {
            debugPrint('🎬 [YouTubePlayerWidget] ❌ Erro ao criar controller: $e');
            _retryCount++;
            if (_retryCount >= 2) {
              debugPrint('🎬 [YouTubePlayerWidget] 🔄 Usando fallback simples após ${_retryCount} tentativas');
              if (mounted) {
                setState(() {
                  _useSimpleFallback = true;
                });
              }
            } else if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Erro ao criar player: $e';
              });
            }
          }
        });
      } else {
        // Handle invalid URL
        debugPrint('🎬 [YouTubePlayerWidget] ❌ URL inválida: ${widget.videoUrl}');
        setState(() {
          _hasError = true;
          _errorMessage = 'URL do YouTube inválida: ${widget.videoUrl}';
        });
      }
    } catch (e) {
      debugPrint('🎬 [YouTubePlayerWidget] ❌ Erro geral na inicialização: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao inicializar player: $e';
      });
    }
  }

  void _onPlayerStateChange() {
    try {
      if (!mounted) return;
      
      final currentValue = _controller!.value;
      debugPrint('🎬 [YouTubePlayerWidget] Estado alterado - isReady: ${currentValue.isReady}, hasError: ${currentValue.hasError}');
      
      if (currentValue.isReady && !_isPlayerReady) {
        debugPrint('🎬 [YouTubePlayerWidget] ✅ Player ficou pronto!');
        setState(() {
          _isPlayerReady = true;
          _hasError = false;
        });
      }

      if (currentValue.isFullScreen != _isFullScreen) {
        debugPrint('🎬 [YouTubePlayerWidget] 🔄 Mudança de tela cheia: ${currentValue.isFullScreen}');
        setState(() {
          _isFullScreen = currentValue.isFullScreen;
        });
      }

      // Detectar erros do player
      if (currentValue.hasError) {
        debugPrint('🎬 [YouTubePlayerWidget] ❌ Player reportou erro');
        setState(() {
          _hasError = true;
          _errorMessage = 'Erro no player do YouTube';
        });
      }
    } catch (e) {
      debugPrint('🎬 [YouTubePlayerWidget] ❌ Erro no listener: $e');
    }
  }

  @override
  void dispose() {
    try {
      debugPrint('🎬 [YouTubePlayerWidget] Fazendo dispose do controller');
      if (_controller != null) {
        _controller!.removeListener(_onPlayerStateChange);
        _controller!.dispose();
      }
    } catch (e) {
      debugPrint('🎬 [YouTubePlayerWidget] ❌ Erro ao fazer dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎬 [YouTubePlayerWidget] Build chamado - hasError: $_hasError, isPlayerReady: $_isPlayerReady, useSimpleFallback: $_useSimpleFallback');
    
    // ✅ USAR FALLBACK SIMPLES SE NECESSÁRIO
    if (_useSimpleFallback) {
      debugPrint('🎬 [YouTubePlayerWidget] 🔄 Usando SimpleYouTubePlayer como fallback');
      return SimpleYouTubePlayer(
        videoUrl: widget.videoUrl,
        title: widget.title,
        description: widget.description,
        onClose: widget.onClose,
      );
    }
    
    // Verificar se há erro ou URL inválida
    if (_hasError) {
      debugPrint('🎬 [YouTubePlayerWidget] Exibindo widget de erro');
      return _buildErrorWidget();
    }

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
    if (videoId == null || videoId.isEmpty) {
      debugPrint('🎬 [YouTubePlayerWidget] Video ID inválido, exibindo erro');
      return _buildErrorWidget();
    }

    // ✅ AGUARDAR INICIALIZAÇÃO DO CONTROLLER
    if (!_isPlayerReady && _controller == null) {
      debugPrint('🎬 [YouTubePlayerWidget] Controller ainda não criado, exibindo loading');
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
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
          debugPrint('🎬 [YouTubePlayerWidget] Saindo do modo tela cheia');
          // ✅ REMOVIDO: Não forçar orientação para evitar loops
        },
        player: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                widget.title.isEmpty ? 'Vídeo' : widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
          onReady: () {
            debugPrint('🎬 [YouTubePlayerWidget] ✅ onReady callback - Player pronto para: ${widget.title}');
            if (mounted) {
              setState(() {
                _isPlayerReady = true;
                _hasError = false;
              });
            }
          },
          onEnded: (metaData) {
            debugPrint('🎬 [YouTubePlayerWidget] 🏁 Vídeo finalizado: ${metaData.videoId}');
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
                            _controller!.seekTo(
                              Duration(
                                seconds: (_controller!.value.position.inSeconds - 10).clamp(0, double.infinity).toInt(),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Erro ao retroceder: $e');
                          }
                        },
                        label: '-10s',
                      ),
                      _buildControlButton(
                        icon: _controller!.value.isPlaying 
                            ? Icons.pause 
                            : Icons.play_arrow,
                        onPressed: () {
                          try {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          } catch (e) {
                            debugPrint('Erro ao play/pause: $e');
                          }
                        },
                        label: _controller!.value.isPlaying ? 'Pausar' : 'Play',
                      ),
                      _buildControlButton(
                        icon: Icons.forward_10,
                        onPressed: () {
                          try {
                            _controller!.seekTo(
                              Duration(
                                seconds: _controller!.value.position.inSeconds + 10,
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
                            _controller!.toggleFullScreenMode();
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
                    _retryCount = 0;
                  });
                  _initializePlayer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _useSimpleFallback = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Player simples'),
              ),
              const SizedBox(width: 8),
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