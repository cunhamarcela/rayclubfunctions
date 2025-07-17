// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/core/utils/formatters.dart';

/// Widget que mostra informações sobre um treino realizado pelo usuário.
class UserWorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const UserWorkoutCard({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com tipo e ícone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getWorkoutIcon(workout.type),
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        workout.type,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _getFormattedTime(workout.completedAt),
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        icon: Icons.timer,
                        label: '${workout.durationMinutes} min',
                        color: AppColors.primary.withOpacity(0.1),
                        textColor: AppColors.primary,
                      ),
                      _buildInfoChip(
                        icon: Icons.local_fire_department,
                        label: '${workout.caloriesBurned} kcal',
                        color: Colors.orange.withOpacity(0.1),
                        textColor: Colors.orange.shade700,
                      ),
                      _buildInfoChip(
                        icon: Icons.fitness_center,
                        label: '${workout.exerciseCount} exercícios',
                        color: Colors.purple.withOpacity(0.1),
                        textColor: Colors.purple.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime(DateTime? time) {
    if (time == null) {
      return '';
    }
    return DateFormat('HH:mm').format(time);
  }

  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'força':
        return Icons.fitness_center;
      case 'flexibilidade':
        return Icons.accessibility_new;
      case 'yoga':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.timer;
      default:
        return Icons.sports_gymnastics;
    }
  }
} 