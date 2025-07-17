// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/providers/providers.dart';
import '../repositories/recipe_favorites_repository.dart';
import '../models/recipe.dart';

/// Provider para o repositório de favoritos de receitas
final recipeFavoritesRepositoryProvider = Provider<RecipeFavoritesRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseRecipeFavoritesRepository(supabaseClient);
});

/// Notifier para gerenciar favoritos de receitas
class RecipeFavoritesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  
  RecipeFavoritesNotifier(this._ref) : super(<String>{});

  /// Carrega favoritos do usuário
  Future<void> loadFavorites(String userId) async {
    try {
      final repository = _ref.read(recipeFavoritesRepositoryProvider);
      final favoriteIds = await repository.getFavoriteRecipeIds(userId);
      state = favoriteIds;
    } catch (e) {
      // Em caso de erro, mantém o estado atual
      print('Erro ao carregar favoritos: $e');
    }
  }

  /// Toggle favorito (adiciona se não existe, remove se existe)
  Future<void> toggleFavorite(String userId, String recipeId) async {
    try {
      final repository = _ref.read(recipeFavoritesRepositoryProvider);
      final isFavorite = state.contains(recipeId);

      if (isFavorite) {
        // Remove dos favoritos
        await repository.removeFromFavorites(userId, recipeId);
        state = {...state}..remove(recipeId);
      } else {
        // Adiciona aos favoritos
        await repository.addToFavorites(userId, recipeId);
        state = {...state, recipeId};
      }
    } catch (e) {
      // Em caso de erro, reverte o estado otimista
      print('Erro ao alterar favorito: $e');
      // Recarrega os favoritos para garantir consistência
      await loadFavorites(userId);
    }
  }

  /// Verifica se uma receita é favorita
  bool isFavorite(String recipeId) {
    return state.contains(recipeId);
  }

  /// Limpa os favoritos (útil no logout)
  void clearFavorites() {
    state = <String>{};
  }
}

/// Provider principal para favoritos de receitas
final recipeFavoritesProvider = StateNotifierProvider<RecipeFavoritesNotifier, Set<String>>((ref) {
  return RecipeFavoritesNotifier(ref);
});

/// Provider para buscar receitas favoritas do usuário
final favoriteRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final repository = ref.watch(recipeFavoritesRepositoryProvider);
  return repository.getFavoriteRecipes(userId);
});

/// Provider para verificar se uma receita específica é favorita
final isRecipeFavoriteProvider = Provider.family<bool, String>((ref, recipeId) {
  final favorites = ref.watch(recipeFavoritesProvider);
  return favorites.contains(recipeId);
});

/// Provider para contar total de receitas favoritas
final favoriteRecipesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(recipeFavoritesProvider);
  return favorites.length;
}); 