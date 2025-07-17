// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart' show Workout, WorkoutSection;
import 'package:ray_club_app/features/workout/models/exercise.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';

// Criando mocks para os testes
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late WorkoutViewModel viewModel;
  late MockWorkoutRepository mockRepository;

  // Dados de teste
  final testWorkouts = [
    Workout(
      id: '1',
      title: 'Treino HIIT',
      description: 'Treino de alta intensidade',
      imageUrl: 'https://example.com/hiit.jpg',
      type: 'Cardio',
      difficulty: 'Avançado',
      durationMinutes: 30,
      equipment: ['Corda', 'Tapete'],
      sections: [
        WorkoutSection(
          name: 'Aquecimento',
          exercises: [
            Exercise(
              name: 'Polichinelo',
              duration: 60,
              repetitions: 0,
              imageUrl: 'https://example.com/jumping_jacks.gif',
            ),
          ],
        ),
      ],
      creatorId: 'admin',
      createdAt: DateTime.now(),
    ),
    Workout(
      id: '2',
      title: 'Treino de Força',
      description: 'Treino para ganho de massa muscular',
      imageUrl: 'https://example.com/strength.jpg',
      type: 'Força',
      difficulty: 'Intermediário',
      durationMinutes: 45,
      equipment: ['Halteres', 'Banco'],
      sections: [
        WorkoutSection(
          name: 'Parte Principal',
          exercises: [
            Exercise(
              name: 'Supino',
              duration: 0,
              repetitions: 12,
              imageUrl: 'https://example.com/bench_press.gif',
            ),
          ],
        ),
      ],
      creatorId: 'admin',
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockRepository = MockWorkoutRepository();
    
    // Configuração padrão dos mocks
    when(() => mockRepository.getWorkouts())
        .thenAnswer((_) async => testWorkouts);
    
    viewModel = WorkoutViewModel(mockRepository);
  });

  group('WorkoutViewModel - inicialização', () {
    test('inicia no estado de carregamento e carrega treinos automaticamente', () async {
      // Setup - Aguarda a chamada assíncrona no construtor
      await Future.delayed(Duration.zero);
      
      // Verify
      verify(() => mockRepository.getWorkouts()).called(1);
      
      // Assert que o estado foi atualizado corretamente
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.currentWorkouts.length, 2);
      expect(viewModel.state.currentWorkouts[0].id, '1');
      expect(viewModel.state.currentWorkouts[1].id, '2');
    });
    
    test('extrai categorias únicas dos treinos carregados', () async {
      // Setup - Aguarda a chamada assíncrona no construtor
      await Future.delayed(Duration.zero);
      
      // Assert que as categorias foram extraídas corretamente
      final state = viewModel.state;
      expect(
        state.maybeWhen(
          loaded: (_, __, categories, ___) => categories,
          orElse: () => <String>[],
        ),
        containsAll(['Cardio', 'Força']),
      );
    });
  });

  group('WorkoutViewModel - loadWorkouts', () {
    test('carrega treinos com sucesso', () async {
      // Act
      await viewModel.loadWorkouts();
      
      // Assert
      verify(() => mockRepository.getWorkouts()).called(2); // Uma vez no construtor e outra na chamada explícita
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.currentWorkouts.length, 2);
    });
    
    test('lida com erros ao carregar treinos', () async {
      // Arrange
      when(() => mockRepository.getWorkouts())
          .thenThrow(AppException(message: 'Erro ao carregar treinos'));
      
      // Act
      await viewModel.loadWorkouts();
      
      // Assert
      expect(
        viewModel.state,
        isA<WorkoutState>().having(
          (state) => state.maybeWhen(
            error: (message) => message,
            orElse: () => null,
          ),
          'mensagem de erro',
          'Erro ao carregar treinos',
        ),
      );
    });
  });

  group('WorkoutViewModel - filtros', () {
    test('filtra treinos por categoria', () async {
      // Arrange - Aguarda carregamento inicial
      await Future.delayed(Duration.zero);
      
      // Act
      viewModel.filterByCategory('Cardio');
      
      // Assert
      expect(viewModel.state.currentWorkouts.length, 1);
      expect(viewModel.state.currentWorkouts[0].title, 'Treino HIIT');
      
      // Resetar filtro
      viewModel.resetFilters();
      expect(viewModel.state.currentWorkouts.length, 2);
    });
    
    test('filtra treinos por dificuldade', () async {
      // Arrange - Aguarda carregamento inicial
      await Future.delayed(Duration.zero);
      
      // Act
      viewModel.filterByDifficulty('Avançado');
      
      // Assert
      expect(viewModel.state.currentWorkouts.length, 1);
      expect(viewModel.state.currentWorkouts[0].difficulty, 'Avançado');
      
      // Resetar filtro
      viewModel.resetFilters();
      expect(viewModel.state.currentWorkouts.length, 2);
    });
    
    test('filtra treinos por duração máxima', () async {
      // Arrange - Aguarda carregamento inicial
      await Future.delayed(Duration.zero);
      
      // Act
      viewModel.filterByDuration(35);
      
      // Assert
      expect(viewModel.state.currentWorkouts.length, 1);
      expect(viewModel.state.currentWorkouts[0].durationMinutes, 30);
      
      // Resetar filtro
      viewModel.resetFilters();
      expect(viewModel.state.currentWorkouts.length, 2);
    });
  });

  group('WorkoutViewModel - seleção de treino', () {
    test('seleciona um treino específico', () async {
      // Arrange - Aguarda carregamento inicial
      await Future.delayed(Duration.zero);
      
      // Act
      viewModel.selectWorkout('2');
      
      // Assert
      expect(viewModel.state.selectedWorkout, isNotNull);
      expect(viewModel.state.selectedWorkout!.id, '2');
      expect(viewModel.state.selectedWorkout!.title, 'Treino de Força');
    });
    
    test('lida com tentativa de selecionar treino inexistente', () async {
      // Arrange - Aguarda carregamento inicial
      await Future.delayed(Duration.zero);
      
      // Act
      viewModel.selectWorkout('999');
      
      // Assert
      expect(
        viewModel.state,
        isA<WorkoutState>().having(
          (state) => state.maybeWhen(
            error: (message) => message,
            orElse: () => null,
          ),
          'mensagem de erro',
          'Treino não encontrado',
        ),
      );
    });
  });
} 
