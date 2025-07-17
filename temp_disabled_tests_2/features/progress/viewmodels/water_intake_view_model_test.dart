// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/features/goals/repositories/water_intake_repository.dart';
import 'package:ray_club_app/features/progress/screens/progress_plan_screen.dart';

// Criando mocks para os testes
class MockWaterIntakeRepository extends Mock implements WaterIntakeRepository {}

void main() {
  late WaterIntakeViewModel viewModel;
  late MockWaterIntakeRepository mockRepository;
  
  // Dados de teste
  final defaultWaterIntake = WaterIntake(
    id: 'test-1',
    userId: 'user-1',
    date: DateTime(2023, 10, 15),
    currentGlasses: 3,
    dailyGoal: 8,
    glassSize: 250,
    createdAt: DateTime(2023, 10, 15, 8, 0),
  );
  
  setUp(() {
    mockRepository = MockWaterIntakeRepository();
    viewModel = WaterIntakeViewModel(mockRepository);
  });
  
  group('WaterIntakeViewModel - loadTodayWaterIntake', () {
    test('deve iniciar com estado de carregamento', () {
      // Verificar o estado inicial
      expect(viewModel.state, const AsyncValue<WaterIntake>.loading());
    });
    
    test('deve atualizar o estado com sucesso ao carregar dados', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      // Act - O método é chamado no construtor, mas podemos chamá-lo novamente
      await viewModel.loadTodayWaterIntake();
      
      // Assert
      verify(() => mockRepository.getTodayWaterIntake()).called(2); // Uma vez no construtor, outra na chamada explícita
      
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.id, defaultWaterIntake.id);
      expect(viewModel.state.value?.currentGlasses, 3);
      expect(viewModel.state.value?.dailyGoal, 8);
    });
    
    test('deve atualizar o estado com erro quando falhar', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenThrow(StorageException(message: 'Falha ao carregar dados de consumo de água'));
      
      // Act
      await viewModel.loadTodayWaterIntake();
      
      // Assert
      verify(() => mockRepository.getTodayWaterIntake()).called(2); // Uma vez no construtor, outra na chamada explícita
      
      expect(viewModel.state.hasError, true);
      expect(viewModel.state.error.toString(), contains('Falha ao carregar dados'));
    });
  });
  
  group('WaterIntakeViewModel - addGlass', () {
    test('deve adicionar um copo de água com sucesso', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      final updatedWaterIntake = defaultWaterIntake.copyWith(
        currentGlasses: 4,
        updatedAt: DateTime.now(),
      );
      
      when(() => mockRepository.addGlass())
          .thenAnswer((_) async => updatedWaterIntake);
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.addGlass();
      
      // Assert
      verify(() => mockRepository.addGlass()).called(1);
      
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.currentGlasses, 4);
    });
    
    test('deve mostrar erro ao falhar na adição de copo', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      when(() => mockRepository.addGlass())
          .thenThrow(StorageException(message: 'Falha ao adicionar copo'));
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.addGlass();
      
      // Assert
      verify(() => mockRepository.addGlass()).called(1);
      
      expect(viewModel.state.hasError, true);
      expect(viewModel.state.error.toString(), contains('Falha ao adicionar copo'));
    });
    
    test('deve recarregar os dados após falha na adição', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      when(() => mockRepository.addGlass())
          .thenThrow(StorageException(message: 'Falha ao adicionar copo'));
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.addGlass();
      
      // Assert - Verifica que loadTodayWaterIntake foi chamado após o erro
      verify(() => mockRepository.getTodayWaterIntake()).called(2); // Uma no construtor, outra na recarga após erro
    });
  });
  
  group('WaterIntakeViewModel - removeGlass', () {
    test('deve remover um copo de água com sucesso', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      final updatedWaterIntake = defaultWaterIntake.copyWith(
        currentGlasses: 2,
        updatedAt: DateTime.now(),
      );
      
      when(() => mockRepository.removeGlass())
          .thenAnswer((_) async => updatedWaterIntake);
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.removeGlass();
      
      // Assert
      verify(() => mockRepository.removeGlass()).called(1);
      
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.currentGlasses, 2);
    });
    
    test('deve mostrar erro ao falhar na remoção de copo', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      when(() => mockRepository.removeGlass())
          .thenThrow(StorageException(message: 'Falha ao remover copo'));
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.removeGlass();
      
      // Assert
      verify(() => mockRepository.removeGlass()).called(1);
      
      expect(viewModel.state.hasError, true);
      expect(viewModel.state.error.toString(), contains('Falha ao remover copo'));
    });
  });
  
  group('WaterIntakeViewModel - updateDailyGoal', () {
    test('deve atualizar meta diária com sucesso', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      final updatedWaterIntake = defaultWaterIntake.copyWith(
        dailyGoal: 10,
        updatedAt: DateTime.now(),
      );
      
      when(() => mockRepository.updateDailyGoal(10))
          .thenAnswer((_) async => updatedWaterIntake);
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.updateDailyGoal(10);
      
      // Assert
      verify(() => mockRepository.updateDailyGoal(10)).called(1);
      
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.dailyGoal, 10);
    });
    
    test('não deve atualizar meta quando valor for inválido', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.updateDailyGoal(0);
      
      // Assert
      verifyNever(() => mockRepository.updateDailyGoal(any()));
      
      // O estado não deve mudar
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.dailyGoal, 8);
    });
    
    test('deve atualizar estado otimisticamente antes da API responder', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      // Configurar um delay para simular resposta lenta da API
      when(() => mockRepository.updateDailyGoal(12))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 500));
            return defaultWaterIntake.copyWith(
              dailyGoal: 12,
              updatedAt: DateTime.now(),
            );
          });
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act - Iniciar a atualização
      final future = viewModel.updateDailyGoal(12);
      
      // Assert - Verificar atualização otimista imediata (antes da resposta da API)
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.dailyGoal, 12); // Já atualizado otimisticamente
      
      // Aguardar conclusão da chamada à API
      await future;
      
      // Verificar estado final
      verify(() => mockRepository.updateDailyGoal(12)).called(1);
      expect(viewModel.state.hasValue, true);
      expect(viewModel.state.value?.dailyGoal, 12);
    });
    
    test('deve reverter para dados corretos após erro na atualização', () async {
      // Arrange
      when(() => mockRepository.getTodayWaterIntake())
          .thenAnswer((_) async => defaultWaterIntake);
      
      when(() => mockRepository.updateDailyGoal(15))
          .thenThrow(StorageException(message: 'Falha ao atualizar meta'));
      
      // Aguardar a carga inicial (do construtor)
      await Future.delayed(Duration.zero);
      
      // Act
      await viewModel.updateDailyGoal(15);
      
      // Assert
      verify(() => mockRepository.updateDailyGoal(15)).called(1);
      
      // Deve ter erro no estado
      expect(viewModel.state.hasError, true);
      expect(viewModel.state.error.toString(), contains('Falha ao atualizar meta'));
      
      // Deve ter recarregado os dados originais
      verify(() => mockRepository.getTodayWaterIntake()).called(2); // Uma no início, outra na recarga
    });
  });
} 