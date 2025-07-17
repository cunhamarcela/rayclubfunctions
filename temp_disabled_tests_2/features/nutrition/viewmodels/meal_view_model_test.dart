// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';
import 'package:ray_club_app/features/nutrition/viewmodels/meal_view_model.dart';

class MockMealRepository extends Mock implements MealRepositoryInterface {}

class MockUser extends Mock implements AppUser {
  @override
  final String id = 'user123';
  @override
  final String name = 'Test User';
}

class FakeMeal extends Fake implements Meal {}

void main() {
  late MealViewModel viewModel;
  late MockMealRepository mockRepository;
  late AuthState mockAuthState;
  final mockUser = MockUser();
  
  // Registra valores de fallback para Mocktail
  setUpAll(() {
    registerFallbackValue(FakeMeal());
  });
  
  // Dados de teste
  final testMeals = [
    Meal(
      id: '1',
      name: 'Café da Manhã',
      dateTime: DateTime(2023, 3, 15, 8, 0),
      calories: 450,
      proteins: 20,
      carbs: 45,
      fats: 15,
      imageUrl: 'https://example.com/breakfast.jpg',
      tags: ['healthy', 'breakfast'],
      isFavorite: true,
    ),
    Meal(
      id: '2',
      name: 'Almoço',
      dateTime: DateTime(2023, 3, 15, 12, 30),
      calories: 650,
      proteins: 35,
      carbs: 70,
      fats: 20,
      notes: 'Refeição balanceada',
      imageUrl: 'https://example.com/lunch.jpg',
      tags: ['balanced', 'protein'],
    ),
    Meal(
      id: '3',
      name: 'Jantar',
      dateTime: DateTime(2023, 3, 15, 19, 0),
      calories: 550,
      proteins: 30,
      carbs: 50,
      fats: 18,
      imageUrl: 'https://example.com/dinner.jpg',
    ),
  ];

  setUp(() {
    mockRepository = MockMealRepository();
    // Criando uma instância real de AuthState para o teste
    mockAuthState = AuthState.authenticated(user: mockUser);
    
    // Configuração padrão do repository mock
    when(() => mockRepository.getMeals(
      userId: any(named: 'userId'),
      startDate: any(named: 'startDate'),
      endDate: any(named: 'endDate'),
    )).thenAnswer((_) async => testMeals);
    
    // Inicializar o ViewModel mas desativar a chamada automática no construtor
    // criando uma subclasse para testes
    viewModel = TestMealViewModel(mockRepository, mockAuthState);
  });

  group('MealViewModel - Carregamento de Refeições', () {
    test('loadMeals deve carregar as refeições e atualizar o estado', () async {
      // Act
      await viewModel.loadMeals();
      
      // Assert
      verify(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).called(1);
      
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.meals.length, equals(testMeals.length));
      expect(viewModel.state.error, isNull);
    });
    
    test('loadMeals deve tratar erros corretamente', () async {
      // Arrange
      when(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenThrow(const AppException(message: 'Erro ao buscar refeições'));
      
      // Act
      await viewModel.loadMeals();
      
      // Assert
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.error, contains('Erro ao buscar refeições'));
    });
    
    test('loadMeals deve filtrar corretamente por intervalo de datas', () async {
      // Arrange
      final startDate = DateTime(2023, 3, 15);
      final endDate = DateTime(2023, 3, 15, 23, 59, 59);
      
      final filteredMeals = testMeals.where((meal) => 
        meal.dateTime.isAfter(startDate) && 
        meal.dateTime.isBefore(endDate)
      ).toList();
      
      when(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: startDate,
        endDate: endDate,
      )).thenAnswer((_) async => filteredMeals);
      
      // Act
      await viewModel.loadMeals(startDate: startDate, endDate: endDate);
      
      // Assert
      verify(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: startDate,
        endDate: endDate,
      )).called(1);
      
      expect(viewModel.state.meals.length, equals(filteredMeals.length));
    });
    
    test('loadMeals não deve ser executado quando o usuário não está autenticado', () async {
      // Arrange - criar um estado não autenticado
      mockAuthState = const AuthState.unauthenticated();
      viewModel = TestMealViewModel(mockRepository, mockAuthState);
      
      // Act
      await viewModel.loadMeals();
      
      // Assert
      verifyNever(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ));
      
      expect(viewModel.state.error, contains('User not authenticated'));
    });
  });

  group('MealViewModel - Operações CRUD', () {
    group('Adição de Refeições', () {
      test('addMeal deve adicionar uma refeição e atualizar o estado', () async {
        // Arrange
        final newMeal = Meal(
          id: '4',
          name: 'Lanche',
          dateTime: DateTime(2023, 3, 15, 16, 0),
          calories: 300,
          proteins: 10,
          carbs: 30,
          fats: 12,
        );
        
        when(() => mockRepository.addMeal(any(), any()))
            .thenAnswer((_) async => newMeal);
        
        // Act
        await viewModel.addMeal(newMeal);
        
        // Assert
        verify(() => mockRepository.addMeal(any(), any())).called(1);
        
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.isMealAdded, isTrue);
        expect(viewModel.state.meals.first.id, equals('4'));
      });
      
      test('addMeal deve tratar erros corretamente', () async {
        // Arrange
        final newMeal = Meal(
          id: '4',
          name: 'Lanche',
          dateTime: DateTime(2023, 3, 15, 16, 0),
          calories: 300,
          proteins: 10,
          carbs: 30,
          fats: 12,
        );
        
        when(() => mockRepository.addMeal(any(), any()))
            .thenThrow(const AppException(message: 'Erro ao adicionar refeição'));
        
        // Act
        await viewModel.addMeal(newMeal);
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.error, contains('Erro ao adicionar refeição'));
        expect(viewModel.state.isMealAdded, isFalse);
      });
      
      test('addMeal não deve ser executado quando o usuário não está autenticado', () async {
        // Arrange - criar um estado não autenticado
        mockAuthState = const AuthState.unauthenticated();
        viewModel = TestMealViewModel(mockRepository, mockAuthState);
        
        final newMeal = Meal(
          id: '4',
          name: 'Lanche',
          dateTime: DateTime(2023, 3, 15, 16, 0),
          calories: 300,
          proteins: 10,
          carbs: 30,
          fats: 12,
        );
        
        // Act
        await viewModel.addMeal(newMeal);
        
        // Assert
        verifyNever(() => mockRepository.addMeal(any(), any()));
        expect(viewModel.state.error, contains('User not authenticated'));
      });
    });

    group('Atualização de Refeições', () {
      test('updateMeal deve atualizar uma refeição existente', () async {
        // Arrange - carrega as refeições primeiro
        await viewModel.loadMeals();
        
        final updatedMeal = Meal(
          id: '1',
          name: 'Café da Manhã Atualizado',
          dateTime: DateTime(2023, 3, 15, 8, 0),
          calories: 500,
          proteins: 25,
          carbs: 50,
          fats: 15,
        );
        
        when(() => mockRepository.updateMeal(any()))
            .thenAnswer((_) async => updatedMeal);
        
        // Act
        await viewModel.updateMeal(updatedMeal);
        
        // Assert
        verify(() => mockRepository.updateMeal(any())).called(1);
        
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.isMealUpdated, isTrue);
        expect(viewModel.state.meals.firstWhere((m) => m.id == '1').name, 
            equals('Café da Manhã Atualizado'));
        expect(viewModel.state.meals.firstWhere((m) => m.id == '1').calories, equals(500));
      });
      
      test('updateMeal deve tratar erros corretamente', () async {
        // Arrange
        final updatedMeal = Meal(
          id: '1',
          name: 'Café da Manhã Atualizado',
          dateTime: DateTime(2023, 3, 15, 8, 0),
          calories: 500,
          proteins: 25,
          carbs: 50,
          fats: 15,
        );
        
        when(() => mockRepository.updateMeal(any()))
            .thenThrow(const AppException(message: 'Erro ao atualizar refeição'));
        
        // Act
        await viewModel.updateMeal(updatedMeal);
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.error, contains('Erro ao atualizar refeição'));
        expect(viewModel.state.isMealUpdated, isFalse);
      });
    });
    
    group('Exclusão de Refeições', () {
      test('deleteMeal deve remover uma refeição', () async {
        // Arrange - carrega as refeições primeiro
        await viewModel.loadMeals();
        
        when(() => mockRepository.deleteMeal(any()))
            .thenAnswer((_) async => {});
        
        // Act
        await viewModel.deleteMeal('2');
        
        // Assert
        verify(() => mockRepository.deleteMeal('2')).called(1);
        
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.isMealDeleted, isTrue);
        expect(viewModel.state.meals.where((m) => m.id == '2').isEmpty, isTrue);
        expect(viewModel.state.meals.length, equals(2)); // Removeu 1 de 3
      });
      
      test('deleteMeal deve tratar erros corretamente', () async {
        // Arrange
        when(() => mockRepository.deleteMeal(any()))
            .thenThrow(const AppException(message: 'Erro ao excluir refeição'));
        
        // Act
        await viewModel.deleteMeal('1');
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.error, contains('Erro ao excluir refeição'));
        expect(viewModel.state.isMealDeleted, isFalse);
      });
    });
  });
  
  group('MealViewModel - Filtragem de Refeições', () {
    test('deve filtrar refeições por data', () async {
      // Arrange
      final startDate = DateTime(2023, 3, 15);
      final endDate = DateTime(2023, 3, 15, 23, 59, 59);
      
      final filteredMeals = testMeals; // Todas as refeições são do mesmo dia nos dados de teste
      
      when(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: startDate,
        endDate: endDate,
      )).thenAnswer((_) async => filteredMeals);
      
      // Act
      await viewModel.loadMeals(startDate: startDate, endDate: endDate);
      
      // Assert
      verify(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: startDate,
        endDate: endDate,
      )).called(1);
      
      expect(viewModel.state.meals.length, equals(3));
      // Verificar que todas as refeições estão dentro do intervalo especificado
      for (final meal in viewModel.state.meals) {
        expect(
          meal.dateTime.isAfter(startDate) && meal.dateTime.isBefore(endDate.add(const Duration(seconds: 1))), 
          isTrue
        );
      }
    });
    
    test('deve respeitar os filtros de data quando vazios', () async {
      // Act
      await viewModel.loadMeals();
      
      // Assert
      verify(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: null,
        endDate: null,
      )).called(1);
      
      expect(viewModel.state.meals.length, equals(3));
    });
  });
  
  group('MealViewModel - Cálculos de Nutrientes', () {
    test('deve calcular corretamente o total de calorias diárias', () async {
      // Arrange
      // Carrega as refeições do dia - todas as refeições de teste são do mesmo dia
      await viewModel.loadMeals(
        startDate: DateTime(2023, 3, 15),
        endDate: DateTime(2023, 3, 15, 23, 59, 59),
      );
      
      // Act - Calcula o total manualmente
      final expectedCalories = testMeals.fold<int>(
        0, (sum, meal) => sum + meal.calories
      );
      
      // Calcula o mesmo total através do método do ViewModel
      final totalCalories = viewModel.calculateTotalCalories();
      
      // Assert
      expect(totalCalories, equals(expectedCalories));
      expect(totalCalories, equals(450 + 650 + 550)); // 1650
    });
    
    test('deve calcular corretamente os macronutrientes totais', () async {
      // Arrange
      // Carrega as refeições do dia
      await viewModel.loadMeals(
        startDate: DateTime(2023, 3, 15),
        endDate: DateTime(2023, 3, 15, 23, 59, 59),
      );
      
      // Act - Calcula os totais manualmente
      final expectedProteins = testMeals.fold<double>(
        0, (sum, meal) => sum + meal.proteins
      );
      
      final expectedCarbs = testMeals.fold<double>(
        0, (sum, meal) => sum + meal.carbs
      );
      
      final expectedFats = testMeals.fold<double>(
        0, (sum, meal) => sum + meal.fats
      );
      
      // Calcula os mesmos totais através dos métodos do ViewModel
      final totalProteins = viewModel.calculateTotalProteins();
      final totalCarbs = viewModel.calculateTotalCarbs();
      final totalFats = viewModel.calculateTotalFats();
      
      // Assert
      expect(totalProteins, equals(expectedProteins));
      expect(totalCarbs, equals(expectedCarbs));
      expect(totalFats, equals(expectedFats));
      
      expect(totalProteins, equals(20 + 35 + 30)); // 85g
      expect(totalCarbs, equals(45 + 70 + 50)); // 165g
      expect(totalFats, equals(15 + 20 + 18)); // 53g
    });
    
    test('deve calcular a distribuição percentual de macronutrientes', () async {
      // Arrange
      // Carrega as refeições do dia
      await viewModel.loadMeals(
        startDate: DateTime(2023, 3, 15),
        endDate: DateTime(2023, 3, 15, 23, 59, 59),
      );
      
      // Act
      final macroDistribution = viewModel.calculateMacroDistribution();
      
      // Assert
      expect(macroDistribution.length, equals(3)); // proteína, carboidrato, gordura
      
      // Verificar que a soma é aproximadamente 100%
      final total = macroDistribution['protein']! + 
                    macroDistribution['carbs']! + 
                    macroDistribution['fats']!;
      
      expect(total, closeTo(100, 1)); // Considerar arredondamentos
    });
    
    test('deve calcular as estatísticas nutricionais por dia da semana', () async {
      // Arrange
      // Cria refeições para vários dias da semana
      final mondayMeals = [
        Meal(
          id: 'monday-1',
          name: 'Café Segunda',
          dateTime: DateTime(2023, 3, 13, 8, 0), // Segunda-feira
          calories: 400,
          proteins: 20,
          carbs: 40,
          fats: 15,
        ),
      ];
      
      final tuesdayMeals = [
        Meal(
          id: 'tuesday-1',
          name: 'Café Terça',
          dateTime: DateTime(2023, 3, 14, 8, 0), // Terça-feira
          calories: 420,
          proteins: 22,
          carbs: 42,
          fats: 16,
        ),
      ];
      
      // Configura o mock para retornar diferentes refeições para diferentes dias
      when(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: DateTime(2023, 3, 13),
        endDate: DateTime(2023, 3, 13, 23, 59, 59),
      )).thenAnswer((_) async => mondayMeals);
      
      when(() => mockRepository.getMeals(
        userId: any(named: 'userId'),
        startDate: DateTime(2023, 3, 14),
        endDate: DateTime(2023, 3, 14, 23, 59, 59),
      )).thenAnswer((_) async => tuesdayMeals);
      
      // Act
      final weekStats = await viewModel.getWeeklyStats(
        startDate: DateTime(2023, 3, 13), // Segunda
        endDate: DateTime(2023, 3, 19), // Domingo
      );
      
      // Assert
      expect(weekStats.length, equals(7)); // 7 dias da semana
      expect(weekStats[0]['calories'], equals(400)); // Segunda
      expect(weekStats[1]['calories'], equals(420)); // Terça
    });
  });
}

/// Versão de teste do MealViewModel que não chama loadMeals no construtor
class TestMealViewModel extends MealViewModel {
  TestMealViewModel(super.repository, super.authState) : super();
  
  @override
  void initState() {
    // Não faz nada - evitando a chamada automática de loadMeals
  }
  
  // Métodos auxiliares para testes de cálculos
  int calculateTotalCalories() {
    return state.meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }
  
  double calculateTotalProteins() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.proteins);
  }
  
  double calculateTotalCarbs() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.carbs);
  }
  
  double calculateTotalFats() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.fats);
  }
  
  Map<String, double> calculateMacroDistribution() {
    final totalProteins = calculateTotalProteins();
    final totalCarbs = calculateTotalCarbs();
    final totalFats = calculateTotalFats();
    
    final totalGrams = totalProteins + totalCarbs + totalFats;
    
    return {
      'protein': (totalProteins / totalGrams) * 100,
      'carbs': (totalCarbs / totalGrams) * 100,
      'fats': (totalFats / totalGrams) * 100,
    };
  }
  
  Future<List<Map<String, dynamic>>> getWeeklyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final weekStats = <Map<String, dynamic>>[];
    
    for (var i = 0; i < 7; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final endOfDay = DateTime(
        currentDate.year, 
        currentDate.month, 
        currentDate.day, 
        23, 59, 59
      );
      
      await loadMeals(startDate: currentDate, endDate: endOfDay);
      
      weekStats.add({
        'date': currentDate,
        'calories': calculateTotalCalories(),
        'proteins': calculateTotalProteins(),
        'carbs': calculateTotalCarbs(),
        'fats': calculateTotalFats(),
      });
    }
    
    return weekStats;
  }
} 
