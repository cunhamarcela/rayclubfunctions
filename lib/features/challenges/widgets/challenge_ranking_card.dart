// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';

/// Um widget que exibe um item no ranking de um desafio.
class ChallengeRankingCard extends StatelessWidget {
  final int position;
  final ChallengeProgress progress;
  final bool isCurrentUser;

  const ChallengeRankingCard({
    Key? key,
    required this.position,
    required this.progress,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cores para destacar posições e usuário atual
    final backgroundColor = isCurrentUser 
        ? AppColors.primary.withOpacity(0.1) 
        : (position <= 3 ? AppColors.secondary.withOpacity(0.05) : Colors.transparent);
    
    final borderColor = isCurrentUser 
        ? AppColors.primary 
        : (position <= 3 ? AppColors.secondary.withOpacity(0.3) : Colors.grey.shade200);
    
    final textColor = isCurrentUser 
        ? AppColors.primary 
        : AppColors.textDark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor, 
          width: isCurrentUser ? 1.5 : 1
        ),
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getPositionColor(position, isCurrentUser),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: position <= 3 || isCurrentUser ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar do usuário
          CircleAvatar(
            radius: 16,
            backgroundColor: isCurrentUser ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200,
            backgroundImage: progress.userPhotoUrl != null && progress.userPhotoUrl!.isNotEmpty
                ? NetworkImage(progress.userPhotoUrl!)
                : null,
            child: progress.userPhotoUrl == null || progress.userPhotoUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: isCurrentUser ? AppColors.primary : Colors.grey,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Nome do usuário
          Expanded(
            child: Text(
              progress.userName,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Pontos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.primary.withOpacity(0.1)
                  : (position <= 3 ? AppColors.secondary.withOpacity(0.1) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: _getStarColor(position, isCurrentUser),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${progress.currentPoints}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser
                        ? AppColors.primary
                        : (position <= 3 ? AppColors.secondary : AppColors.textDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int position, bool isCurrentUser) {
    if (isCurrentUser) {
      return AppColors.primary;
    }
    
    switch (position) {
      case 1:
        return Colors.amber.shade600; // Ouro
      case 2:
        return Colors.blueGrey.shade400; // Prata
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStarColor(int position, bool isCurrentUser) {
    if (isCurrentUser) {
      return AppColors.primary;
    }
    
    switch (position) {
      case 1:
        return Colors.amber.shade600; // Ouro
      case 2:
        return Colors.blueGrey.shade400; // Prata
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.grey.shade400;
    }
  }
} 