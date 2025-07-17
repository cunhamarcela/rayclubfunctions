import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Widget para exibir vídeos do YouTube nas receitas
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
  late YoutubePlayerController _controller;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        hideControls: !widget.showControls,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // Força orientação portrait ao sair do fullscreen
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFCDA8F0),
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
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
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller.pause();
        },
      ),
      builder: (context, player) {
        return Column(
          children: [
            player,
            if (widget.showControls && _isPlayerReady)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: _controller.value.isPlaying
                          ? _controller.pause
                          : _controller.play,
                    ),
                    Text(
                      _formatDuration(_controller.value.position),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Text('/'),
                    Text(
                      _formatDuration(_controller.metadata.duration),
                      style: const TextStyle(fontSize: 14),
                    ),
                    IconButton(
                      icon: Icon(
                        _controller.value.isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                      ),
                      onPressed: () {
                        _controller.toggleFullScreenMode();
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return duration.inHours > 0 
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }
} 