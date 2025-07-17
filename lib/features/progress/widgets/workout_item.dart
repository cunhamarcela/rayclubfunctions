// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/constants/app_padding.dart';
import 'package:ray_club_app/core/constants/app_strings.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';

class WorkoutItem extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutItem({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppPadding.p16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildWorkoutImage(),
            const SizedBox(width: AppPadding.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.timer_outlined,
                        '${workout.durationMinutes} ${AppStrings.minutes}',
                      ),
                      const SizedBox(width: AppPadding.p12),
                      _buildInfoItem(
                        Icons.category_outlined,
                        workout.type,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutImage() {
    final imageUrl = workout.imageUrl;
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: (imageUrl != null && imageUrl.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: SvgPicture.asset(
                      'assets/icons/dumbbell.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: SvgPicture.asset(
                'assets/icons/dumbbell.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
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
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
} 