// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/challenge.dart';

class ChallengeProgressCard extends StatelessWidget {
  final Challenge challenge;
  final double progress;
  final bool isActive;
  final VoidCallback? onDetailsPressed;

  const ChallengeProgressCard({
    required this.challenge,
    required this.progress,
    required this.isActive,
    this.onDetailsPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage based on challenge days
    final clampedPercentage = progress.clamp(0.0, 1.0);
    
    // Format progress text - mostrando apenas a porcentagem
    final progressText = '${(clampedPercentage * 100).toInt()}%';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seu Progresso',
                style: TextStyle(
                  fontFamily: 'Century Gothic',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  progressText,
                  style: TextStyle(
                    fontFamily: 'Century Gothic',
                    fontSize: 14,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: clampedPercentage,
                    minHeight: 6,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                progressText,
                style: TextStyle(
                  fontFamily: 'Century Gothic',
                  fontSize: 14,
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: AppColors.purple,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Faça check-ins para aumentar seu progresso',
                  style: TextStyle(
                    fontFamily: 'Century Gothic',
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(),
              if (isActive)
                ElevatedButton(
                  onPressed: onDetailsPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.orange.withOpacity(0.4),
                  ),
                  child: Text(
                    'Ver Detalhes',
                    style: TextStyle(
                      fontFamily: 'Century Gothic',
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = isActive
        ? 'Em Andamento'
        : 'Encerrado';
    
    final icon = isActive
        ? Icons.directions_run
        : Icons.flag;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.darkGray,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Century Gothic',
              fontSize: 12,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 