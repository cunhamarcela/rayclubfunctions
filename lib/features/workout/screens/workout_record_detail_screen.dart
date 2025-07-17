// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/core/widgets/loading_indicator.dart';

@RoutePage()
class WorkoutRecordDetailScreen extends ConsumerStatefulWidget {
  final String recordId;
  final WorkoutRecord? workoutRecord; // Opcional, caso já tenhamos o objeto

  const WorkoutRecordDetailScreen({
    super.key,
    required this.recordId,
    this.workoutRecord,
  });

  @override
  ConsumerState<WorkoutRecordDetailScreen> createState() => _WorkoutRecordDetailScreenState();
}

class _WorkoutRecordDetailScreenState extends ConsumerState<WorkoutRecordDetailScreen> {
  late Future<WorkoutRecord?> _workoutRecordFuture;

  @override
  void initState() {
    super.initState();
    
    if (widget.workoutRecord != null) {
      _workoutRecordFuture = Future.value(widget.workoutRecord);
    } else {
      // Se não temos, mostrar erro pois não há método para buscar um único registro
      _workoutRecordFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: FutureBuilder<WorkoutRecord?>(
        future: _workoutRecordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          
          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }
          
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar treino',
            style: AppTypography.headingSmall.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WorkoutRecord record) {    
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(record),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkoutInfo(record),
                // Só exibe seção de fotos se houver imagens
                if (record.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildPhotosSection(record),
                ],
                // Só exibe seção de observações se houver notas
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildNotesSection(record),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(WorkoutRecord record) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          record.workoutName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(128, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo se houver, senão gradiente
            if (record.imageUrls.isNotEmpty)
              Image.network(
                record.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
              ),
            // Overlay escuro para melhor legibilidade
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildWorkoutInfo(WorkoutRecord record) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.fitness_center,
              label: 'Tipo',
              value: record.workoutType,
              color: AppColors.primary,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.timer,
              label: 'Duração',
              value: '${record.durationMinutes} minutos',
              color: AppColors.secondary,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Data',
              value: dateFormat.format(record.date.toLocal()),
              color: AppColors.accent,
            ),
            if (record.challengeId != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.flag,
                label: 'Desafio',
                value: 'Participando de desafio',
                color: AppColors.success,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(WorkoutRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Fotos do Treino',
              style: AppTypography.headingSmall,
            ),
            const Spacer(),
            Text(
              '${record.imageUrls.length} foto${record.imageUrls.length > 1 ? 's' : ''}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: record.imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, record.imageUrls[index]),
                child: Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < record.imageUrls.length - 1 ? 12 : 0,
                  ),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          record.imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                        // Indicador de tap para expandir
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(WorkoutRecord record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Observações',
                  style: AppTypography.headingSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.notes!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 