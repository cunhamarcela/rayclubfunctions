import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/providers/workout_material_providers.dart';
import 'package:ray_club_app/widgets/pdf_viewer_widget.dart';
import 'package:ray_club_app/features/home/widgets/youtube_player_widget.dart';
import 'package:ray_club_app/models/material.dart' as app_material;


class WorkoutVideoDetailScreen extends ConsumerWidget {
  final WorkoutVideo video;

  const WorkoutVideoDetailScreen({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(workoutVideoMaterialsProvider(video.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          video.title,
          style: AppTextStyles.subtitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vídeo
            _buildVideoSection(context),
            
            const SizedBox(height: 24),
            
            // Informações do treino
            _buildInfoSection(),
            
            const SizedBox(height: 24),
            
            // Materiais PDFs
            materialsAsync.when(
              data: (materials) => materials.isNotEmpty 
                  ? _buildMaterialsSection(context, materials)
                  : const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Thumbnail
          if (video.thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                video.thumbnailUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          
          // Play button
          Center(
            child: GestureDetector(
              onTap: () => _openVideoPlayer(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: AppColors.surface,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre o Treino',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 8),
        
        if (video.description != null)
          Text(
            video.description!,
            style: AppTextStyles.body,
          ),
        
        const SizedBox(height: 16),
        
        // Metadados
        Row(
          children: [
            _buildMetadataChip('Duração', video.duration),
            const SizedBox(width: 8),
            if (video.difficulty != null)
              _buildMetadataChip('Dificuldade', video.difficulty!),
            const SizedBox(width: 8),
            if (video.instructorName != null)
              _buildMetadataChip('Instrutor', video.instructorName!),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.chipText.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(BuildContext context, List<app_material.Material> materials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materiais do Treino',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 16),
        
        ...materials.map((material) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: ListTile(
            leading: Icon(
              Icons.picture_as_pdf,
              color: AppColors.primary,
            ),
            title: Text(
              material.title,
              style: AppTextStyles.body,
            ),
            subtitle: Text(
              material.description,
              style: AppTextStyles.smallText,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onTap: () => _openPdfViewer(context, material),
          ),
        )),
      ],
    );
  }

  void _openVideoPlayer(BuildContext context) {
    if (video.youtubeUrl != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => YouTubePlayerWidget(
            videoUrl: video.youtubeUrl!,
            title: video.title,
            description: video.description,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  void _openPdfViewer(BuildContext context, app_material.Material material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerWidget(
          material: material,
          title: material.title,
        ),
      ),
    );
  }
} 