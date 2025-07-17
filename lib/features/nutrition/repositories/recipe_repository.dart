import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import '../../../core/exceptions/app_exceptions.dart';
import 'recipe_favorites_repository.dart';

/// Repositório responsável por buscar receitas do Supabase
class RecipeRepository {
  final SupabaseClient _supabaseClient;
  
  RecipeRepository(this._supabaseClient);
  
  // ✅ Dados mockados removidos - agora usa apenas receitas reais da Bruna Braga do Supabase
  
  /// Busca receitas reais da Bruna Braga do Supabase
  Future<List<Recipe>> getNutritionistRecipes() async {
    try {
      print('🔍 Buscando receitas reais da Bruna Braga...');
      final response = await _supabaseClient
          .from('recipes')
          .select()
          .eq('author_name', 'Bruna Braga')
          .order('created_at', ascending: false);
      
      print('📊 Resposta do Supabase: ${(response as List).length} receitas encontradas');
      
      if (response == null || (response as List).isEmpty) {
        print('⚠️ Nenhuma receita encontrada no Supabase');
        return [];
      }
      
      return (response as List)
          .map((data) {
            print('✅ Processando receita: ${data['title']}');
            return Recipe.fromJson(data);
          })
          .toList();
    } catch (e, stackTrace) {
      print('❌ Erro ao buscar receitas da Bruna Braga: $e');
      print('Stack trace: $stackTrace');
      
      // Sem fallback mockado - retorna lista vazia em caso de erro
      print('🚫 Retornando lista vazia (sem dados mockados)');
      return [];
    }
  }
  
  /// Busca todas as receitas da Ray
  Future<List<Recipe>> getRayRecipes() async {
    try {
      print('Buscando receitas da Ray...');
      final response = await _supabaseClient
          .from('recipes')
          .select()
          .eq('author_type', 'ray')
          .order('created_at', ascending: false);
      
      print('Resposta do Supabase: $response');
      
      if (response == null || (response as List).isEmpty) {
        print('Resposta vazia/null do Supabase, retornando lista vazia (apenas dados reais da Bruna Braga)');
        return [];
      }
      
      return (response as List)
          .map((data) {
            print('Dados da receita: $data');
            return Recipe.fromJson(data);
          })
          .toList();
    } catch (e, stackTrace) {
      print('Erro ao buscar receitas da Ray: $e');
      print('Stack trace: $stackTrace');
      
      // Se houver erro, retorna lista vazia (apenas dados reais da Bruna Braga)
      print('Retornando lista vazia devido ao erro');
      return [];
    }
  }
  
  /// Busca receitas em destaque
  Future<List<Recipe>> getFeaturedRecipes() async {
    try {
      final response = await _supabaseClient
          .from('recipes')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(5);
      
      if (response == null || (response as List).isEmpty) {
        // Retorna lista vazia (apenas dados reais da Bruna Braga)
        return [];
      }
      
      return (response as List)
          .map((data) => Recipe.fromJson(data))
          .toList();
    } catch (e) {
      // Retorna lista vazia (apenas dados reais da Bruna Braga)
      return [];
    }
  }
  
  /// Busca uma receita específica pelo ID
  Future<Recipe> getRecipeById(String id) async {
    try {
      final response = await _supabaseClient
          .from('recipes')
          .select()
          .eq('id', id)
          .single();
      
      return Recipe.fromJson(response);
    } catch (e) {
      // Receita não encontrada (apenas dados reais da Bruna Braga)
      throw AppException('Receita não encontrada');
    }
  }
  
  /// Busca receitas com filtros
  Future<List<Recipe>> searchRecipes({
    String? query,
    String? category,
    RecipeContentType? contentType,
    List<String>? tags,
  }) async {
    try {
      var queryBuilder = _supabaseClient.from('recipes').select();
      
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or('title.ilike.%$query%,description.ilike.%$query%');
      }
      
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }
      
      if (contentType != null) {
        queryBuilder = queryBuilder.eq('content_type', contentType.name);
      }
      
      if (tags != null && tags.isNotEmpty) {
        queryBuilder = queryBuilder.contains('tags', tags);
      }
      
      final response = await queryBuilder.order('created_at', ascending: false);
      
      if (response == null) {
        return [];
      }
      
      return (response as List)
          .map((data) => Recipe.fromJson(data))
          .toList();
    } catch (e) {
      // Retorna lista vazia (apenas dados reais da Bruna Braga)
      return [];
    }
  }

  /// Busca receitas da nutricionista com status de favoritos
  Future<List<Recipe>> getNutritionistRecipesWithFavorites(String? userId) async {
    final recipes = await getNutritionistRecipes();
    
    if (userId == null) {
      return recipes;
    }
    
    try {
      final favoritesRepository = SupabaseRecipeFavoritesRepository(_supabaseClient);
      final favoriteIds = await favoritesRepository.getFavoriteRecipeIds(userId);
      
      return recipes.map((recipe) {
        return recipe.copyWith(
          isFavorite: favoriteIds.contains(recipe.id),
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
      return recipes; // Retorna sem status de favoritos em caso de erro
    }
  }

  /// Busca receitas em destaque com status de favoritos
  Future<List<Recipe>> getFeaturedRecipesWithFavorites(String? userId) async {
    final recipes = await getFeaturedRecipes();
    
    if (userId == null) {
      return recipes;
    }
    
    try {
      final favoritesRepository = SupabaseRecipeFavoritesRepository(_supabaseClient);
      final favoriteIds = await favoritesRepository.getFavoriteRecipeIds(userId);
      
      return recipes.map((recipe) {
        return recipe.copyWith(
          isFavorite: favoriteIds.contains(recipe.id),
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
      return recipes; // Retorna sem status de favoritos em caso de erro
    }
  }

  /// Busca uma receita por ID com status de favorito
  Future<Recipe?> getRecipeByIdWithFavorites(String id, String? userId) async {
    final recipe = await getRecipeById(id);
    
    if (recipe == null || userId == null) {
      return recipe;
    }
    
    try {
      final favoritesRepository = SupabaseRecipeFavoritesRepository(_supabaseClient);
      final isFavorite = await favoritesRepository.isFavorite(userId, id);
      
      return recipe.copyWith(isFavorite: isFavorite);
    } catch (e) {
      print('Erro ao verificar favorito: $e');
      return recipe; // Retorna sem status de favorito em caso de erro
    }
  }
} 