import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ray_club_app/features/nutrition/models/nutrition_item.dart';

part 'nutrition_view_model.freezed.dart';

@freezed
class NutritionState with _$NutritionState {
  const factory NutritionState({
    @Default([]) List<NutritionItem> nutritionItems,
    @Default([]) List<NutritionItem> filteredItems,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default('all') String currentFilter,
  }) = _NutritionState;
}

final nutritionViewModelProvider = StateNotifierProvider<NutritionViewModel, NutritionState>((ref) {
  return NutritionViewModel();
});

class NutritionViewModel extends StateNotifier<NutritionState> {
  NutritionViewModel() : super(const NutritionState()) {
    loadNutritionItems();
  }

  Future<void> loadNutritionItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Simulação de carregamento de dados
      await Future.delayed(const Duration(seconds: 1));
      
      final items = [
        NutritionItem(
          id: '1',
          title: 'Salada Tropical',
          description: 'Uma deliciosa salada tropical',
          category: 'recipe',
          imageUrl: 'https://example.com/salada.png',
          preparationTimeMinutes: 15,
          ingredients: ['Alface', 'Tomate', 'Abacaxi'],
          instructions: ['Lave os vegetais', 'Corte em pedaços', 'Misture tudo'],
          tags: ['Salada', 'Vegano'],
        ),
        NutritionItem(
          id: '2',
          title: 'Dica para Hidratação',
          description: 'Como se manter hidratado durante exercícios',
          category: 'tip',
          imageUrl: 'https://example.com/hidratacao.png',
          preparationTimeMinutes: 5,
          tags: ['Hidratação', 'Saúde'],
          nutritionistTip: 'Beba água regularmente durante o dia.',
        ),
      ];
      
      state = state.copyWith(
        nutritionItems: items,
        filteredItems: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar itens de nutrição: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void filterByCategory(String category) {
    if (category == 'all') {
      state = state.copyWith(
        filteredItems: state.nutritionItems,
        currentFilter: category,
      );
    } else {
      state = state.copyWith(
        filteredItems: state.nutritionItems.where((item) => item.category == category).toList(),
        currentFilter: category,
      );
    }
  }
} 