import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository para gerenciar favoritos do ranking
abstract class RankingFavoritesRepository {
  Future<Set<String>> getFavorites(String userId, String challengeId);
  Future<void> addFavorite(String userId, String favoritedUserId, String challengeId);
  Future<void> removeFavorite(String userId, String favoritedUserId, String challengeId);
}

class SupabaseRankingFavoritesRepository implements RankingFavoritesRepository {
  final SupabaseClient _client;

  SupabaseRankingFavoritesRepository(this._client);

  @override
  Future<Set<String>> getFavorites(String userId, String challengeId) async {
    try {
      final response = await _client
          .from('user_ranking_favorites')
          .select('favorited_user_id')
          .eq('user_id', userId)
          .eq('challenge_id', challengeId);

      return response
          .map<String>((item) => item['favorited_user_id'] as String)
          .toSet();
    } catch (e) {
      return <String>{};
    }
  }

  @override
  Future<void> addFavorite(String userId, String favoritedUserId, String challengeId) async {
    await _client.from('user_ranking_favorites').upsert({
      'user_id': userId,
      'favorited_user_id': favoritedUserId,
      'challenge_id': challengeId,
    });
  }

  @override
  Future<void> removeFavorite(String userId, String favoritedUserId, String challengeId) async {
    await _client
        .from('user_ranking_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('favorited_user_id', favoritedUserId)
        .eq('challenge_id', challengeId);
  }
} 