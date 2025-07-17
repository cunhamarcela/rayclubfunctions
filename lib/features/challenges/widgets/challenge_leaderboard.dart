// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/challenge_progress.dart';

/// A widget that displays a leaderboard for a challenge.
/// It receives a pre-sorted ranking list from the parent.
class ChallengeLeaderboard extends StatelessWidget {
  final String challengeId;
  final String? groupId; // Optional group ID for filtering
  final List<ChallengeProgress> rankingList; // Data passed from parent
  final String? userId; // Current user ID for highlighting
  final int maxEntriesToShow; // Max entries before needing "View All"

  const ChallengeLeaderboard({
    required this.challengeId,
    this.groupId,
    required this.rankingList, 
    this.userId,
    this.maxEntriesToShow = 1000,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 ChallengeLeaderboard - build() iniciado');
    debugPrint('🔍 ChallengeLeaderboard - rankingList tem ${rankingList.length} itens');
    debugPrint('🔍 ChallengeLeaderboard - userId: $userId');
    debugPrint('🔍 ChallengeLeaderboard - maxEntriesToShow: $maxEntriesToShow');

    // Show empty state if no rankings exist
    if (rankingList.isEmpty) {
      debugPrint('🔍 ChallengeLeaderboard - lista vazia, mostrando estado vazio');
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.backgroundLight,
              child: Icon(
                Icons.emoji_events_outlined,
                size: 60, 
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ninguém participou ainda. Seja o primeiro!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'StingerTrial',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Participe do desafio e acompanhe seu progresso no ranking.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'StingerFitTrial',
                fontSize: 14,
                color: AppColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Determine the number of entries to show
    final int itemCount = rankingList.length > maxEntriesToShow 
        ? maxEntriesToShow 
        : rankingList.length;
        
    debugPrint('🔍 ChallengeLeaderboard - exibindo $itemCount de ${rankingList.length} entradas');

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Ranking',
            style: TextStyle(
              fontFamily: 'StingerTrial',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.darkGray,
            ),
          ),
        ),
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Row(
            children: [
              const SizedBox(width: 40, child: Text('#', 
                style: TextStyle(
                  fontFamily: 'StingerTrial',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D4D4D),
                )
              )),
              const SizedBox(width: 40),
              const Expanded(child: Text('Participante', 
                style: TextStyle(
                  fontFamily: 'StingerTrial',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D4D4D),
                )
              )),
              const Text('Pontos', 
                style: TextStyle(
                  fontFamily: 'StingerTrial',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D4D4D),
                )
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Rank entries
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final entry = rankingList[index];
            final position = index + 1; // Ranking position
            final isCurrentUser = entry.userId == userId;
            
            if (isCurrentUser) {
              debugPrint('🔍 ChallengeLeaderboard - usuário atual encontrado na posição $position');
            }

            return _buildRankEntry(
              context,
              entry,
              position,
              isCurrentUser,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRankEntry(
    BuildContext context,
    ChallengeProgress entry,
    int position,
    bool isCurrentUser,
  ) {
    // Highlight colors
    final backgroundColor = isCurrentUser ? AppColors.purple.withOpacity(0.1) : Colors.transparent;
    final borderColor = isCurrentUser ? AppColors.purple : AppColors.lightGray;
    final textColor = isCurrentUser ? AppColors.darkGray : AppColors.darkGray;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isCurrentUser ? 1.5 : 1),
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 40,
            child:               Text(
                '#$position',
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ),
          // Avatar
          CircleAvatar(
            backgroundImage: entry.userPhotoUrl != null && entry.userPhotoUrl!.isNotEmpty
                ? NetworkImage(entry.userPhotoUrl!)
                : null,
            radius: 18,
            backgroundColor: isCurrentUser ? AppColors.purple.withOpacity(0.2) : Colors.grey.shade200,
            child: entry.userPhotoUrl == null || entry.userPhotoUrl!.isEmpty
                ? Icon(Icons.person, size: 20, color: isCurrentUser ? AppColors.purple : Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // User Name
          Expanded(
            child: Text(
              entry.userName,
              style: TextStyle(
                fontFamily: 'StingerFitTrial',
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Points
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: isCurrentUser ? AppColors.purple : AppColors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 