import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/recipe_repository.dart';
import '../models/recipe.dart';
import '../../../core/providers/providers.dart';

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