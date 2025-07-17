// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/exercise.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onTap;

  const ExerciseListItem({
    Key? key,
    required this.exercise,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundLight,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número do exercício
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Detalhes do exercício
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getExerciseDetails(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    if (exercise.instructions != null && exercise.instructions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        exercise.instructions!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Seta para direita
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExerciseDetails() {
    final details = <String>[];
    
    if (exercise.sets != null && exercise.sets! > 0) {
      details.add('${exercise.sets} ${exercise.sets == 1 ? 'série' : 'séries'}');
    }
    
    if (exercise.reps != null && exercise.reps! > 0) {
      details.add('${exercise.reps} ${exercise.reps == 1 ? 'repetição' : 'repetições'}');
    }
    
    if (exercise.duration != null && exercise.duration! > 0) {
      details.add('${exercise.duration} ${exercise.duration == 1 ? 'segundo' : 'segundos'}');
    }
    
    if (exercise.restTime != null && exercise.restTime! > 0) {
      details.add('${exercise.restTime}s de descanso');
    }
    
    return details.join(' • ');
  }
} 
