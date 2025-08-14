import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_filter.freezed.dart';
part 'recipe_filter.g.dart';

/// Modelo para filtros de receitas baseado nas categorias reais da Bruna Braga
@freezed
class RecipeFilter with _$RecipeFilter {
  const factory RecipeFilter({
    required String id,
    required String name,
    required RecipeFilterCategory category,
    @Default(false) bool isSelected,
  }) = _RecipeFilter;

  factory RecipeFilter.fromJson(Map<String, dynamic> json) => _$RecipeFilterFromJson(json);
}

/// Categorias de filtros baseadas no documento da Bruna Braga
enum RecipeFilterCategory {
  favoritas,    // Receitas favoritas do usuário
  objetivo,     // Emagrecimento, Hipertrofia
  paladar,      // Doce, Salgado
  refeicao,     // Café da Manhã, Almoço, Jantar, etc.
  timing,       // Pré Treino, Pós Treino
  macronutrientes, // Carboidratos, Proteínas, Gorduras
  outros,       // Vegano, Low Carb, Detox, etc.
}

/// State para gerenciar filtros selecionados
@freezed
class RecipeFilterState with _$RecipeFilterState {
  const factory RecipeFilterState({
    @Default([]) List<RecipeFilter> availableFilters,
    @Default([]) List<RecipeFilter> selectedFilters,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RecipeFilterState;

  factory RecipeFilterState.fromJson(Map<String, dynamic> json) => _$RecipeFilterStateFromJson(json);
}

/// Classe com os filtros reais extraídos do documento da Bruna Braga
class BrunaRecipeFilters {
  static const Map<RecipeFilterCategory, List<String>> filtersByCategory = {
    RecipeFilterCategory.favoritas: [
      'Minhas Favoritas',
    ],
    RecipeFilterCategory.objetivo: [
      'Emagrecimento',
      'Hipertrofia',
    ],
    RecipeFilterCategory.paladar: [
      'Doce',
      'Salgado',
    ],
    RecipeFilterCategory.refeicao: [
      'Café da Manhã',
      'Almoço', 
      'Jantar',
      'Lanche da Tarde',
      'Lanche',
      'Sobremesa',
    ],
    RecipeFilterCategory.timing: [
      'Pós Treino',
      'Pré Treino',
    ],
    RecipeFilterCategory.macronutrientes: [
      'Carboidratos',
      'Proteínas',
      'Gorduras',
    ],
    RecipeFilterCategory.outros: [
      'Vegano',
      'Low Carb', 
      'Sem Glúten',
      'Funcional',
      'Detox',
      'Hidratante',
      'Energizante',
      'Vegetariano',
      'Rápido',
      'Light',
      'Bebidas',
      'Sopa',
    ],
  };

  /// Gera lista de filtros disponíveis
  static List<RecipeFilter> generateAllFilters() {
    final filters = <RecipeFilter>[];
    
    filtersByCategory.forEach((category, filterNames) {
      for (final name in filterNames) {
        filters.add(RecipeFilter(
          id: '${category.name}_${name.toLowerCase().replaceAll(' ', '_')}',
          name: name,
          category: category,
        ));
      }
    });
    
    return filters;
  }

  /// Obtém nome legível da categoria
  static String getCategoryDisplayName(RecipeFilterCategory category) {
    switch (category) {
      case RecipeFilterCategory.favoritas:
        return 'Favoritas';
      case RecipeFilterCategory.objetivo:
        return 'Objetivo';
      case RecipeFilterCategory.paladar:
        return 'Paladar';
      case RecipeFilterCategory.refeicao:
        return 'Refeição';
      case RecipeFilterCategory.timing:
        return 'Timing';
      case RecipeFilterCategory.macronutrientes:
        return 'Macronutrientes';
      case RecipeFilterCategory.outros:
        return 'Outros';
    }
  }

  /// Obtém ícone da categoria
  static String getCategoryIcon(RecipeFilterCategory category) {
    switch (category) {
      case RecipeFilterCategory.favoritas:
        return '💖';
      case RecipeFilterCategory.objetivo:
        return '🎯';
      case RecipeFilterCategory.paladar:
        return '🫶';
      case RecipeFilterCategory.refeicao:
        return '🍽️';
      case RecipeFilterCategory.timing:
        return '⏰';
      case RecipeFilterCategory.macronutrientes:
        return '🧬';
      case RecipeFilterCategory.outros:
        return '✨';
    }
  }

  /// Filtra receitas pelos filtros selecionados
  static List<T> filterRecipes<T>(
    List<T> recipes,
    List<RecipeFilter> selectedFilters,
    String Function(T) getRecipeTags,
  ) {
    if (selectedFilters.isEmpty) return recipes;
    
    final selectedFilterNames = selectedFilters.map((f) => f.name).toSet();
    
    return recipes.where((recipe) {
      final recipeTags = getRecipeTags(recipe).split(',').map((tag) => tag.trim()).toSet();
      
      // Receita deve ter pelo menos um dos filtros selecionados
      return selectedFilterNames.any((filterName) => recipeTags.contains(filterName));
    }).toList();
  }
} 