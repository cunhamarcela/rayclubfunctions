import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe_filter.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';

/// Provider para o estado dos filtros de receitas
final recipeFilterProvider = StateNotifierProvider<RecipeFilterViewModel, RecipeFilterState>((ref) {
  return RecipeFilterViewModel();
});

/// Provider para receitas filtradas
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipesAsync = ref.watch(nutritionistRecipesWithFavoritesProvider);
  final filterState = ref.watch(recipeFilterProvider);
  
  return recipesAsync.whenData((recipes) {
    if (filterState.selectedFilters.isEmpty) {
      return recipes;
    }
    
    // Verifica se há filtro de favoritas selecionado
    final hasFavoritesFilter = filterState.selectedFilters
        .any((filter) => filter.category == RecipeFilterCategory.favoritas);
    
    List<Recipe> filteredRecipes = recipes;
    
    // Aplica filtro de favoritas primeiro se selecionado
    if (hasFavoritesFilter) {
      filteredRecipes = recipes.where((recipe) => recipe.isFavorite ?? false).toList();
    }
    
    // Aplica outros filtros excluindo favoritas
    final otherFilters = filterState.selectedFilters
        .where((filter) => filter.category != RecipeFilterCategory.favoritas)
        .toList();
    
    if (otherFilters.isNotEmpty) {
      filteredRecipes = BrunaRecipeFilters.filterRecipes<Recipe>(
        filteredRecipes,
        otherFilters,
        (recipe) => recipe.tags.join(','),
      );
    }
    
    return filteredRecipes;
  }).valueOrNull ?? [];
});

/// Provider para contagem de receitas por filtro
final filterCountsProvider = Provider<Map<String, int>>((ref) {
  final recipesAsync = ref.watch(nutritionistRecipesWithFavoritesProvider);
  final allFilters = ref.watch(recipeFilterProvider).availableFilters;
  
  return recipesAsync.whenData((recipes) {
    final counts = <String, int>{};
    
    for (final filter in allFilters) {
      int filteredCount;
      
      // Lógica especial para filtro de favoritas
      if (filter.category == RecipeFilterCategory.favoritas) {
        filteredCount = recipes.where((recipe) => recipe.isFavorite ?? false).length;
      } else {
        // Lógica normal para outros filtros baseados em tags
        filteredCount = recipes.where((recipe) {
          return recipe.tags.contains(filter.name);
        }).length;
      }
      
      counts[filter.id] = filteredCount;
    }
    
    return counts;
  }).valueOrNull ?? {};
});

/// ViewModel para gerenciar filtros de receitas
class RecipeFilterViewModel extends StateNotifier<RecipeFilterState> {
  RecipeFilterViewModel() : super(const RecipeFilterState()) {
    _initializeFilters();
  }

  /// Inicializa os filtros disponíveis
  void _initializeFilters() {
    state = state.copyWith(
      isLoading: true,
    );

    try {
      final availableFilters = BrunaRecipeFilters.generateAllFilters();
      
      state = state.copyWith(
        availableFilters: availableFilters,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar filtros: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Alterna seleção de um filtro
  void toggleFilter(String filterId) {
    final updatedAvailableFilters = state.availableFilters.map((filter) {
      if (filter.id == filterId) {
        return filter.copyWith(isSelected: !filter.isSelected);
      }
      return filter;
    }).toList();

    final selectedFilters = updatedAvailableFilters
        .where((filter) => filter.isSelected)
        .toList();

    state = state.copyWith(
      availableFilters: updatedAvailableFilters,
      selectedFilters: selectedFilters,
    );
  }

  /// Seleciona filtros de uma categoria específica
  void selectFiltersInCategory(RecipeFilterCategory category, List<String> filterNames) {
    final updatedAvailableFilters = state.availableFilters.map((filter) {
      if (filter.category == category && filterNames.contains(filter.name)) {
        return filter.copyWith(isSelected: true);
      }
      return filter;
    }).toList();

    final selectedFilters = updatedAvailableFilters
        .where((filter) => filter.isSelected)
        .toList();

    state = state.copyWith(
      availableFilters: updatedAvailableFilters,
      selectedFilters: selectedFilters,
    );
  }

  /// Limpa todos os filtros selecionados
  void clearAllFilters() {
    final updatedAvailableFilters = state.availableFilters
        .map((filter) => filter.copyWith(isSelected: false))
        .toList();

    state = state.copyWith(
      availableFilters: updatedAvailableFilters,
      selectedFilters: [],
    );
  }

  /// Limpa filtros de uma categoria específica
  void clearFiltersInCategory(RecipeFilterCategory category) {
    final updatedAvailableFilters = state.availableFilters.map((filter) {
      if (filter.category == category) {
        return filter.copyWith(isSelected: false);
      }
      return filter;
    }).toList();

    final selectedFilters = updatedAvailableFilters
        .where((filter) => filter.isSelected)
        .toList();

    state = state.copyWith(
      availableFilters: updatedAvailableFilters,
      selectedFilters: selectedFilters,
    );
  }

  /// Obtém filtros por categoria
  List<RecipeFilter> getFiltersByCategory(RecipeFilterCategory category) {
    return state.availableFilters
        .where((filter) => filter.category == category)
        .toList();
  }

  /// Obtém contagem de filtros selecionados por categoria
  int getSelectedCountByCategory(RecipeFilterCategory category) {
    return state.selectedFilters
        .where((filter) => filter.category == category)
        .length;
  }

  /// Verifica se algum filtro está selecionado
  bool get hasSelectedFilters => state.selectedFilters.isNotEmpty;

  /// Obtém texto resumo dos filtros selecionados
  String getSelectedFiltersText() {
    if (state.selectedFilters.isEmpty) {
      return 'Todas as receitas';
    }

    if (state.selectedFilters.length == 1) {
      return state.selectedFilters.first.name;
    }

    return '${state.selectedFilters.length} filtros ativos';
  }
} 