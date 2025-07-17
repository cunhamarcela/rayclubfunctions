import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../repositories/ranking_favorites_repository.dart';

/// Provider do repository de favoritos
final rankingFavoritesRepositoryProvider = Provider<RankingFavoritesRepository>((ref) {
  return SupabaseRankingFavoritesRepository(Supabase.instance.client);
});

/// Notifier para gerenciar favoritos do ranking
class RankingFavoritesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  
  RankingFavoritesNotifier(this._ref) : super(<String>{});

  /// Carrega favoritos para um desafio específico
  Future<void> loadFavorites(String challengeId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final repository = _ref.read(rankingFavoritesRepositoryProvider);
    final favorites = await repository.getFavorites(user.id, challengeId);
    state = favorites;
  }

  /// Toggle favorito (adiciona se não existe, remove se existe)
  Future<void> toggleFavorite(String favoritedUserId, String challengeId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final repository = _ref.read(rankingFavoritesRepositoryProvider);
    final isFavorite = state.contains(favoritedUserId);

    if (isFavorite) {
      await repository.removeFavorite(user.id, favoritedUserId, challengeId);
      state = {...state}..remove(favoritedUserId);
    } else {
      await repository.addFavorite(user.id, favoritedUserId, challengeId);
      state = {...state, favoritedUserId};
    }
  }
}

/// Provider principal para favoritos do ranking
final rankingFavoritesProvider = StateNotifierProvider<RankingFavoritesNotifier, Set<String>>((ref) {
  return RankingFavoritesNotifier(ref);
});

/// Provider para controlar se está mostrando apenas favoritos
final showOnlyFavoritesProvider = StateProvider<bool>((ref) => false); 