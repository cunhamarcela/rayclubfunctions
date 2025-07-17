import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/core/widgets/loading_widget.dart';
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/features/home/widgets/youtube_player_widget.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_videos_viewmodel.dart';
import 'package:ray_club_app/features/workout/widgets/workout_video_card.dart';

@RoutePage()
class WorkoutVideosScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String? categoryName;

  const WorkoutVideosScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<WorkoutVideosScreen> createState() => _WorkoutVideosScreenState();
}

class _WorkoutVideosScreenState extends ConsumerState<WorkoutVideosScreen> {
  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(workoutVideosByCategoryProvider(widget.categoryId));
    
    // Determinar o nome da categoria baseado no ID se não foi fornecido
    final categoryName = widget.categoryName ?? _getCategoryNameFromId(widget.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(
        title: categoryName,
        showBackButton: true,
      ),
      body: videosAsync.when(
        data: (videos) {
          if (videos.isEmpty) {
            return _buildEmptyState();
          }
          return _buildContent(videos);
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar vídeos',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(workoutVideosByCategoryProvider(widget.categoryId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryNameFromId(String categoryId) {
    // Este é um fallback caso o categoryName não seja passado
    return widget.categoryName ?? 'Treinos';
  }

  Widget _buildContent(List<WorkoutVideo> videos) {
    // Vídeos já estão ordenados por ordem de inserção no repositório
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: WorkoutVideoCard(
            video: video,
            onTap: () => _onVideoTap(video),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum vídeo disponível',
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Em breve adicionaremos novos conteúdos!',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onVideoTap(WorkoutVideo video) {
    if (video.youtubeUrl != null && video.youtubeUrl!.isNotEmpty) {
      try {
        // Abrir player do YouTube em modal bottom sheet COM PROTEÇÃO EXPERT
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          builder: (context) => Consumer(
            builder: (context, ref, _) {
              return ExpertVideoGuard.buildProtectedPlayer(
                context,
                ref,
                video.youtubeUrl ?? video.id,
                DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => YouTubePlayerWidget(
                    videoUrl: video.youtubeUrl!,
                    title: video.title,
                    description: video.description ?? video.instructorName,
                    onClose: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        );
      } catch (e) {
        debugPrint('Erro ao abrir player do YouTube: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o vídeo. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Fallback caso não tenha URL do YouTube
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vídeo não disponível no momento'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
} 