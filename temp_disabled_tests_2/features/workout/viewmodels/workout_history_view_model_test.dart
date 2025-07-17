// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_history_view_model.dart';

// Mocks
class MockWorkoutRecordRepository extends Mock implements WorkoutRecordRepository {}

void main() {
  late WorkoutHistoryViewModel viewModel;
  late MockWorkoutRecordRepository mockRepository;
  
  // Dados de teste
  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);
  
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final normalizedYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
  
  final testRecords = [
    WorkoutRecord(
      id: 'record1',
      userId: 'user-1',
      workoutName: 'Treino A',
      workoutType: 'Força',
      date: today,
      durationMinutes: 45,
      workoutId: 'workout1',
      isCompleted: true,
      createdAt: today,
    ),
    WorkoutRecord(
      id: 'record2',
      userId: 'user-1',
      workoutName: 'Treino B',
      workoutType: 'Cardio',
      date: yesterday,
      durationMinutes: 30,
      workoutId: 'workout2',
      isCompleted: true,
      createdAt: yesterday,
    ),
    WorkoutRecord(
      id: 'record3',
      userId: 'user-1',
      workoutName: 'Treino A',
      workoutType: 'Força',
      date: yesterday,
      durationMinutes: 50,
      workoutId: 'workout3',
      isCompleted: true,
      createdAt: yesterday,
    ),
  ];
  
  setUp(() {
    mockRepository = MockWorkoutRecordRepository();
    // Default mock implementation to return empty list
    when(() => mockRepository.getUserWorkoutRecords())
        .thenAnswer((_) async => []);
    viewModel = WorkoutHistoryViewModel(mockRepository);
  });

  group('WorkoutHistoryViewModel - Estado Inicial', () {
    test('deve iniciar com estado de carregamento', () {
      // For this test, we need a repository that doesn't complete immediately
      mockRepository = MockWorkoutRecordRepository();
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async {
            // Add a delay to ensure we can check the loading state
            return Future.delayed(const Duration(seconds: 1), () => []);
          });
      
      // Create a new viewModel that won't complete loading immediately
      final newViewModel = WorkoutHistoryViewModel(mockRepository);
      
      // Verify the initial state is loading
      expect(newViewModel.state, const WorkoutHistoryState.loading());
    });
  });

  group('WorkoutHistoryViewModel - Carregamento de Histórico', () {
    test('deve atualizar o estado para loaded quando há registros', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async => testRecords);
      
      // Act
      await viewModel.loadWorkoutHistory();
      
      // Assert
      viewModel.state.maybeWhen(
        loaded: (allRecords, selectedDate, selectedDateRecords) {
          expect(allRecords.length, equals(3));
          expect(selectedDate, isNull);
          expect(selectedDateRecords, isNull);
        },
        orElse: () => fail('Estado deveria ser loaded'),
      );
      
      verify(() => mockRepository.getUserWorkoutRecords()).called(2); // Uma vez no construtor e outra na chamada explícita
    });
    
    test('deve atualizar o estado para empty quando não há registros', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async => []);
      
      // Act
      await viewModel.loadWorkoutHistory();
      
      // Assert
      expect(viewModel.state, const WorkoutHistoryState.empty());
      verify(() => mockRepository.getUserWorkoutRecords()).called(2); // Uma vez no construtor e outra na chamada explícita
    });
    
    test('deve atualizar o estado para error quando ocorre uma exceção', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenThrow(Exception('Erro ao buscar registros'));
      
      // Act
      await viewModel.loadWorkoutHistory();
      
      // Assert
      viewModel.state.maybeWhen(
        error: (message) {
          expect(message, contains('Erro ao carregar histórico'));
        },
        orElse: () => fail('Estado deveria ser error'),
      );
      
      verify(() => mockRepository.getUserWorkoutRecords()).called(2); // Uma vez no construtor e outra na chamada explícita
    });
  });

  group('WorkoutHistoryViewModel - Agrupamento por Dia', () {
    test('deve agrupar registros por dia corretamente', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async => testRecords);
      
      await viewModel.loadWorkoutHistory();
      
      // Act
      final workoutsByDay = viewModel.getWorkoutsByDay();
      
      // Assert
      expect(workoutsByDay.length, equals(2)); // Dois dias diferentes
      expect(workoutsByDay[normalizedToday]?.length, equals(1)); // Um treino hoje
      expect(workoutsByDay[normalizedYesterday]?.length, equals(2)); // Dois treinos ontem
    });
    
    test('deve retornar mapa vazio quando não estiver em estado loaded', () async {
      // Arrange - Deixar no estado inicial (loading)
      
      // Act
      final workoutsByDay = viewModel.getWorkoutsByDay();
      
      // Assert
      expect(workoutsByDay, isEmpty);
    });
  });

  group('WorkoutHistoryViewModel - Seleção de Data', () {
    test('deve filtrar registros corretamente ao selecionar uma data', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async => testRecords);
      
      await viewModel.loadWorkoutHistory();
      
      // Act
      viewModel.selectDate(yesterday);
      
      // Assert
      viewModel.state.maybeWhen(
        loaded: (allRecords, selectedDate, selectedDateRecords) {
          expect(selectedDate, equals(normalizedYesterday));
          expect(selectedDateRecords?.length, equals(2)); // Dois treinos ontem
          expect(allRecords.length, equals(3)); // Total de registros não muda
        },
        orElse: () => fail('Estado deveria ser loaded'),
      );
    });
    
    test('deve limpar seleção quando passar null como data', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async => testRecords);
      
      await viewModel.loadWorkoutHistory();
      viewModel.selectDate(yesterday); // Primeiro seleciona uma data
      
      // Act
      viewModel.selectDate(null); // Depois limpa a seleção
      
      // Assert
      viewModel.state.maybeWhen(
        loaded: (allRecords, selectedDate, selectedDateRecords) {
          expect(selectedDate, isNull);
          expect(selectedDateRecords, isNull);
          expect(allRecords.length, equals(3));
        },
        orElse: () => fail('Estado deveria ser loaded'),
      );
    });
    
    test('clearSelectedDate deve limpar a data selecionada', () async {
      // Arrange
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async => testRecords);
      
      await viewModel.loadWorkoutHistory();
      viewModel.selectDate(yesterday); // Primeiro seleciona uma data
      
      // Act
      viewModel.clearSelectedDate();
      
      // Assert
      viewModel.state.maybeWhen(
        loaded: (allRecords, selectedDate, selectedDateRecords) {
          expect(selectedDate, isNull);
          expect(selectedDateRecords, isNull);
          expect(allRecords.length, equals(3));
        },
        orElse: () => fail('Estado deveria ser loaded'),
      );
    });
    
    test('selectDate não deve fazer nada quando não estiver em estado loaded', () async {
      // For this test, we need a repository that doesn't complete immediately
      mockRepository = MockWorkoutRecordRepository();
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async {
            // Add a delay to ensure we can check the loading state
            return Future.delayed(const Duration(seconds: 1), () => []);
          });
      
      // Create a new viewModel that will stay in loading state
      final newViewModel = WorkoutHistoryViewModel(mockRepository);
      
      // Act - Tentar selecionar uma data no estado errado
      newViewModel.selectDate(yesterday);
      
      // Assert - O estado continua loading
      expect(newViewModel.state, const WorkoutHistoryState.loading());
    });
    
    test('clearSelectedDate não deve fazer nada quando não estiver em estado loaded', () async {
      // For this test, we need a repository that doesn't complete immediately
      mockRepository = MockWorkoutRecordRepository();
      when(() => mockRepository.getUserWorkoutRecords())
          .thenAnswer((_) async {
            // Add a delay to ensure we can check the loading state
            return Future.delayed(const Duration(seconds: 1), () => []);
          });
      
      // Create a new viewModel that will stay in loading state
      final newViewModel = WorkoutHistoryViewModel(mockRepository);
      
      // Act - Tentar limpar seleção no estado errado
      newViewModel.clearSelectedDate();
      
      // Assert - O estado continua loading
      expect(newViewModel.state, const WorkoutHistoryState.loading());
    });
  });
} 