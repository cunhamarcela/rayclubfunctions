import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/auth_provider.dart';

/// Provider para o repositório de receitas
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return RecipeRepository(supabaseClient);
});

/// Provider para buscar receitas da nutricionista
final nutritionistRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getNutritionistRecipes();
});

/// Provider para buscar receitas em destaque
final featuredRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getFeaturedRecipes();
});

/// Provider para buscar uma receita específica
final recipeByIdProvider = FutureProvider.family<Recipe, String>((ref, id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeById(id);
});

/// Provider para buscar receitas da nutricionista COM status de favoritos
final nutritionistRecipesWithFavoritesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  
  // Buscar receitas da nutricionista
  final recipes = await repository.getNutritionistRecipes();
  
  // Buscar favoritos do usuário atual (se autenticado)
  try {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser != null) {
      // Usar o método que já existe no repositório para combinar com favoritos
      return repository.getNutritionistRecipesWithFavorites(currentUser.id);
    }
  } catch (e) {
    // Se houver erro ou usuário não autenticado, retorna receitas sem favoritos
    print('Erro ao carregar favoritos ou usuário não autenticado: $e');
  }
  
  return recipes;
});

/// Provider para buscar as 4 receitas favoritas da Ray em vídeo
/// Estas são as receitas selecionadas especialmente para a seção da home
final rayFavoriteRecipeVideosProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  
  // Padrões de busca para os 4 vídeos favoritos da Ray
  const favoritePatterns = [
    'gororoba de banana',
    'bolo alagado',
    'banana toast', 
    'pão de queijo',
  ];
  
  try {
    print('🍽️ [Provider] Iniciando busca das receitas favoritas da Ray...');
    final allRecipes = await repository.getNutritionistRecipes();
    print('🍽️ [Provider] Total de receitas carregadas: ${allRecipes.length}');
    
    // Debug: mostrar todas as receitas de vídeo
    final videoRecipes = allRecipes
        .where((recipe) => recipe.contentType == RecipeContentType.video)
        .toList();
    print('🍽️ [Provider] Receitas de vídeo encontradas: ${videoRecipes.length}');
    for (final recipe in videoRecipes) {
      print('🍽️ [Provider] Vídeo: "${recipe.title}" - videoId: ${recipe.videoId}');
    }
    
    // Buscar pelas receitas específicas usando padrões flexíveis
    final favoriteRecipes = <Recipe>[];
    for (final pattern in favoritePatterns) {
      print('🍽️ [Provider] Buscando receita com padrão: "$pattern"');
      
      final matchingRecipes = allRecipes.where((r) => 
        r.contentType == RecipeContentType.video && 
        r.title.toLowerCase().contains(pattern)
      ).toList();
      
      if (matchingRecipes.isNotEmpty) {
        final recipe = matchingRecipes.first;
        print('🍽️ [Provider] ✅ Receita encontrada: "${recipe.title}" para padrão "$pattern"');
        favoriteRecipes.add(recipe);
      } else {
        print('🍽️ [Provider] ❌ Nenhuma receita encontrada para padrão: "$pattern"');
      }
    }
    
    print('🍽️ [Provider] Total de receitas favoritas encontradas: ${favoriteRecipes.length}');
    
    // Garantir que sempre retornamos exatamente 4 receitas
    if (favoriteRecipes.length < 4) {
      print('🍽️ [Provider] ⚠️ Apenas ${favoriteRecipes.length} receitas encontradas, completando com placeholders...');
      
      // Buscar outras receitas de vídeo para completar
      final otherVideoRecipes = allRecipes
          .where((r) => r.contentType == RecipeContentType.video && !favoriteRecipes.contains(r))
          .take(4 - favoriteRecipes.length)
          .toList();
      
      favoriteRecipes.addAll(otherVideoRecipes);
      print('🍽️ [Provider] Total após completar: ${favoriteRecipes.length}');
    }
    
    return favoriteRecipes.take(4).toList();
  } catch (e) {
    print('🍽️ [Provider] ❌ Erro ao buscar receitas favoritas da Ray: $e');
    return [];
  }
}); 