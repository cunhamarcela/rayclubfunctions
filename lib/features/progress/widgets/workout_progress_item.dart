import 'package:flutter/material.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/constants/app_padding.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';

class WorkoutProgressItem extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutProgressItem({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppPadding.p12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Row(
            children: [
              _buildWorkoutImage(),
              const SizedBox(width: AppPadding.p16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoItem(
                          Icons.timer_outlined,
                          '${workout.duration} min',
                        ),
                        const SizedBox(width: AppPadding.p12),
                        _buildInfoItem(
                          Icons.fitness_center_outlined,
                          workout.type,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildCompletionBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(workout.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Completed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
} 