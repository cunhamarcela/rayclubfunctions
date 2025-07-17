import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/features/home/widgets/youtube_player_widget.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_videos_viewmodel.dart';

@RoutePage()
class WorkoutVideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final WorkoutVideo? video;

  const WorkoutVideoPlayerScreen({
    super.key,
    @PathParam('videoId') required this.videoId,
    this.video,
  });

  @override
  ConsumerState<WorkoutVideoPlayerScreen> createState() => _WorkoutVideoPlayerScreenState();
}

class _WorkoutVideoPlayerScreenState extends ConsumerState<WorkoutVideoPlayerScreen> {
  bool _showPlayer = false;

  @override
  void initState() {
    super.initState();
    // Pequeno delay para evitar problemas de renderização
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showPlayer = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    if (video == null) {
      return Scaffold(
        appBar: AppBarWidget(
          title: 'Vídeo de Treino',
          showBackButton: true,
        ),
        body: const Center(
          child: Text('Vídeo não encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(
        title: video.title,
        showBackButton: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Player de vídeo (ocupa a maior parte da tela)
          Expanded(
            flex: 3,
            child: _showPlayer && video.youtubeUrl != null
                ? Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: _buildSimplePlayer(video),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),

          // Informações e controles (compactos na parte inferior)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle visual
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Informações compactas do vídeo
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags e metadados em uma linha
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Tag de instrutor
                          if (video.instructorName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    video.instructorName!,
                                    style: AppTextStyles.smallText.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Tag de duração
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  video.duration,
                                  style: AppTextStyles.smallText.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Tag de dificuldade
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Vídeo de treino', // Texto genérico substituindo difficulty
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Descrição (se existir)
                      if (video.description != null && video.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          child: Text(
                            video.description!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Funcionalidade em desenvolvimento'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.favorite_border, size: 18),
                              label: const Text(
                                'Favoritar',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Treino marcado como concluído!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text(
                                'Concluir',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Safe area para botões
                const SafeArea(
                  top: false,
                  child: SizedBox(height: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePlayer(WorkoutVideo video) {
    return YouTubePlayerWidget(
      videoUrl: video.youtubeUrl!,
      title: '', // Não mostra título no player pois já está no AppBar
      description: null, // Não mostra descrição no player pois está na parte inferior
      onClose: () => context.router.maybePop(),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    return AppColors.primary; // Cor padrão para todos os vídeos
  }
} 