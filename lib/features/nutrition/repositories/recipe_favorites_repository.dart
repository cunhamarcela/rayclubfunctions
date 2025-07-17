// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/recipe.dart';

/// Interface para o repositório de favoritos de receitas
abstract class RecipeFavoritesRepository {
  /// Adiciona uma receita aos favoritos do usuário
  Future<void> addToFavorites(String userId, String recipeId);
  
  /// Remove uma receita dos favoritos do usuário
  Future<void> removeFromFavorites(String userId, String recipeId);
  
  /// Verifica se uma receita está nos favoritos do usuário
  Future<bool> isFavorite(String userId, String recipeId);
  
  /// Obtém todas as receitas favoritas do usuário
  Future<List<Recipe>> getFavoriteRecipes(String userId);
  
  /// Obtém os IDs das receitas favoritas do usuário
  Future<Set<String>> getFavoriteRecipeIds(String userId);
}

/// Implementação do repositório usando Supabase
class SupabaseRecipeFavoritesRepository implements RecipeFavoritesRepository {
  final SupabaseClient _client;
  
  SupabaseRecipeFavoritesRepository(this._client);

  @override
  Future<void> addToFavorites(String userId, String recipeId) async {
    try {
      await _client.from('user_favorite_recipes').upsert({
        'user_id': userId,
        'recipe_id': recipeId,
      });
    } catch (e) {
      throw StorageException(
        message: 'Erro ao adicionar receita aos favoritos',
      );
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String recipeId) async {
    try {
      await _client
          .from('user_favorite_recipes')
          .delete()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao remover receita dos favoritos',
      );
    }
  }

  @override
  Future<bool> isFavorite(String userId, String recipeId) async {
    try {
      final result = await _client.rpc(
        'is_recipe_favorited',
        params: {
          'p_user_id': userId,
          'p_recipe_id': recipeId,
        }
      );
      return result as bool? ?? false;
    } catch (e) {
      // Em caso de erro, assume que não é favorito
      return false;
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_favorite_recipes',
        params: {'p_user_id': userId}
      );
      
      if (response == null || (response as List).isEmpty) {
        return [];
      }
      
      return (response as List)
          .map((data) {
            // Criar map com o ID correto para o Recipe.fromJson
            final recipeData = Map<String, dynamic>.from(data);
            recipeData['id'] = recipeData['recipe_id'];
            recipeData.remove('recipe_id');
            recipeData.remove('favorited_at'); // Remover campo específico da função
            
            return Recipe.fromJson(recipeData);
          })
          .toList();
    } catch (e) {
      throw StorageException(
        message: 'Erro ao buscar receitas favoritas',
      );
    }
  }

  @override
  Future<Set<String>> getFavoriteRecipeIds(String userId) async {
    try {
      final response = await _client
          .from('user_favorite_recipes')
          .select('recipe_id')
          .eq('user_id', userId);
      
      return (response as List)
          .map<String>((item) => item['recipe_id'] as String)
          .toSet();
    } catch (e) {
      // Em caso de erro, retorna set vazio
      return <String>{};
    }
  }
} 