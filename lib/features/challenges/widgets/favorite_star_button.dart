import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ranking_favorites_provider.dart';

class FavoriteStarButton extends ConsumerWidget {
  final String userId;
  final String challengeId;
  
  const FavoriteStarButton({
    super.key,
    required this.userId,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(rankingFavoritesProvider);
    final isFavorite = favorites.contains(userId);
    
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? Colors.amber : Colors.grey,
        size: 20,
      ),
      onPressed: () {
        ref.read(rankingFavoritesProvider.notifier).toggleFavorite(userId, challengeId);
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
    );
  }
} 