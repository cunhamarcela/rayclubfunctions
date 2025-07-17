// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/nutrition/models/nutrition_item.dart';
import 'package:ray_club_app/features/nutrition/viewmodels/nutrition_view_model.dart';

void main() {
  late NutritionViewModel viewModel;
  
  // Dados de teste
  final testItems = [
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
    NutritionItem(
      id: '3',
      title: 'Smoothie de Frutas',
      description: 'Um smoothie nutritivo para o café da manhã',
      category: 'recipe',
      imageUrl: 'https://example.com/smoothie.png',
      preparationTimeMinutes: 10,
      ingredients: ['Banana', 'Morango', 'Leite de amêndoas'],
      instructions: ['Adicione as frutas no liquidificador', 'Adicione o leite', 'Bata até ficar homogêneo'],
      tags: ['Smoothie', 'Café da manhã'],
    ),
  ];
  
  setUp(() {
    viewModel = NutritionViewModel();
  });

  group('NutritionViewModel - Estado Inicial', () {
    test('deve inicializar com estado padrão correto', () {
      // Verificar que o estado inicial está correto
      expect(viewModel.state.nutritionItems, isEmpty);
      expect(viewModel.state.filteredItems, isEmpty);
      expect(viewModel.state.isLoading, isTrue); // O construtor inicia carregamento imediatamente
      expect(viewModel.state.errorMessage, isNull);
      expect(viewModel.state.currentFilter, equals('all'));
    });
  });

  group('NutritionViewModel - Carregamento de Dados', () {
    test('loadNutritionItems deve atualizar o estado com itens carregados', () async {
      // Executar o método
      await viewModel.loadNutritionItems();

      // Verificar que os itens foram carregados
      expect(viewModel.state.nutritionItems, isNotEmpty);
      expect(viewModel.state.filteredItems, isNotEmpty);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
      
      // Verificar o conteúdo dos itens
      final firstItem = viewModel.state.nutritionItems.first;
      expect(firstItem.title, equals('Salada Tropical'));
      expect(firstItem.category, equals('recipe'));
    });

    test('loadNutritionItems deve definir os mesmos itens em nutritionItems e filteredItems', () async {
      // Executar o método
      await viewModel.loadNutritionItems();

      // Verificar que as duas listas têm os mesmos itens
      expect(viewModel.state.nutritionItems.length, equals(viewModel.state.filteredItems.length));
      
      for (int i = 0; i < viewModel.state.nutritionItems.length; i++) {
        expect(viewModel.state.nutritionItems[i].id, equals(viewModel.state.filteredItems[i].id));
      }
    });
  });

  group('NutritionViewModel - Filtragem', () {
    test('filterByCategory deve filtrar itens corretamente', () async {
      // Carregar dados primeiro
      await viewModel.loadNutritionItems();
      
      // Filtrar por receitas
      viewModel.filterByCategory('recipe');
      
      // Verificar que apenas receitas foram filtradas
      expect(viewModel.state.filteredItems.every((item) => item.category == 'recipe'), isTrue);
      expect(viewModel.state.currentFilter, equals('recipe'));
      
      // Filtrar por dicas
      viewModel.filterByCategory('tip');
      
      // Verificar que apenas dicas foram filtradas
      expect(viewModel.state.filteredItems.every((item) => item.category == 'tip'), isTrue);
      expect(viewModel.state.currentFilter, equals('tip'));
      
      // Mostrar todos
      viewModel.filterByCategory('all');
      
      // Verificar que todos os itens estão presentes
      expect(viewModel.state.filteredItems.length, equals(viewModel.state.nutritionItems.length));
      expect(viewModel.state.currentFilter, equals('all'));
    });

    test('filterByCategory deve lidar com categoria inexistente', () async {
      // Carregar dados primeiro
      await viewModel.loadNutritionItems();
      
      // Capturar número total de itens
      final totalItemsCount = viewModel.state.nutritionItems.length;
      
      // Filtrar por categoria inexistente
      viewModel.filterByCategory('nonexistent');
      
      // Verificar que a lista filtrada está vazia
      expect(viewModel.state.filteredItems, isEmpty);
      
      // Verificar que a lista original permanece intacta
      expect(viewModel.state.nutritionItems.length, equals(totalItemsCount));
      
      // Verificar que o filtro atual foi atualizado
      expect(viewModel.state.currentFilter, equals('nonexistent'));
    });

    test('filterByCategory deve manter o estado original ao filtrar por all', () async {
      // Carregar dados primeiro
      await viewModel.loadNutritionItems();
      
      // Filtrar por receitas primeiro para alterar o estado
      viewModel.filterByCategory('recipe');
      
      // Verificar que o estado foi alterado
      expect(viewModel.state.filteredItems.length, lessThan(viewModel.state.nutritionItems.length));
      
      // Agora filtrar por 'all'
      viewModel.filterByCategory('all');
      
      // Verificar que todos os itens estão presentes
      expect(viewModel.state.filteredItems.length, equals(viewModel.state.nutritionItems.length));
      expect(viewModel.state.currentFilter, equals('all'));
    });
  });

  group('NutritionViewModel - Casos de Erro', () {
    test('viewModel deve lidar corretamente com erros de carregamento', () async {
      // Criar um novo viewModel que lançará um erro (em um ambiente de teste controlado)
      final errorViewModel = _MockErrorNutritionViewModel();
      
      // Executar o método que lançará erro
      await errorViewModel.loadNutritionItems();
      
      // Verificar o estado após erro
      expect(errorViewModel.state.isLoading, isFalse);
      expect(errorViewModel.state.errorMessage, isNotNull);
      expect(errorViewModel.state.errorMessage, contains('Erro ao carregar'));
      expect(errorViewModel.state.nutritionItems, isEmpty);
      expect(errorViewModel.state.filteredItems, isEmpty);
    });
  });
}

// Mock que sempre lança erro ao carregar itens
class _MockErrorNutritionViewModel extends NutritionViewModel {
  _MockErrorNutritionViewModel() : super();
  
  @override
  Future<void> loadNutritionItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      // Simular uma falha
      throw Exception('Erro ao carregar itens de nutrição!');
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar itens de nutrição: ${e.toString()}',
        isLoading: false,
      );
    }
  }
}
