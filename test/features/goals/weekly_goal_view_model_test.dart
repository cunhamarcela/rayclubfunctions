import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal.dart';
import 'package:ray_club_app/features/goals/repositories/weekly_goal_repository.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_view_model.dart';

@GenerateMocks([WeeklyGoalRepository])
import 'weekly_goal_view_model_test.mocks.dart';

void main() {
  late MockWeeklyGoalRepository mockRepository;
  late WeeklyGoalViewModel viewModel;

  setUp(() {
    mockRepository = MockWeeklyGoalRepository();
    viewModel = WeeklyGoalViewModel(mockRepository);
  });

  group('WeeklyGoalViewModel', () {
    final testGoal = WeeklyGoal(
      id: '1',
      userId: 'user1',
      goalMinutes: 180,
      currentMinutes: 60,
      weekStartDate: DateTime.now().subtract(const Duration(days: 2)),
      weekEndDate: DateTime.now().add(const Duration(days: 4)),
      completed: false,
      percentageCompleted: 33.33,
    );

    test('deve carregar meta semanal atual com sucesso', () async {
      // Arrange
      when(mockRepository.getOrCreateCurrentWeeklyGoal())
          .thenAnswer((_) async => testGoal);
      when(mockRepository.watchCurrentWeeklyGoal())
          .thenAnswer((_) => Stream.value(testGoal));

      // Act
      await viewModel.loadCurrentGoal();

      // Assert
      expect(viewModel.state.currentGoal, equals(testGoal));
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, isNull);
    });

    test('deve atualizar meta com sucesso', () async {
      // Arrange
      final updatedGoal = testGoal.copyWith(goalMinutes: 300);
      when(mockRepository.updateWeeklyGoal(300))
          .thenAnswer((_) async => updatedGoal);

      // Act
      await viewModel.updateGoal(300);

      // Assert
      expect(viewModel.state.currentGoal?.goalMinutes, equals(300));
      expect(viewModel.state.isUpdating, false);
      expect(viewModel.state.error, isNull);
    });

    test('deve adicionar minutos de treino', () async {
      // Arrange
      final updatedGoal = testGoal.copyWith(
        currentMinutes: 90,
        percentageCompleted: 50.0,
      );
      when(mockRepository.addWorkoutMinutes(30))
          .thenAnswer((_) async => updatedGoal);

      // Act
      await viewModel.addWorkoutMinutes(30);

      // Assert
      expect(viewModel.state.currentGoal?.currentMinutes, equals(90));
      expect(viewModel.state.currentGoal?.percentageCompleted, equals(50.0));
    });

    test('deve carregar histórico de metas', () async {
      // Arrange
      final history = [testGoal, testGoal.copyWith(id: '2')];
      when(mockRepository.getWeeklyGoalsHistory(limit: 12))
          .thenAnswer((_) async => history);

      // Act
      await viewModel.loadHistory();

      // Assert
      expect(viewModel.state.history.length, equals(2));
      expect(viewModel.state.error, isNull);
    });

    test('deve tratar erro ao carregar meta', () async {
      // Arrange
      when(mockRepository.getOrCreateCurrentWeeklyGoal())
          .thenThrow(Exception('Erro de rede'));

      // Act
      await viewModel.loadCurrentGoal();

      // Assert
      expect(viewModel.state.currentGoal, isNull);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, contains('Erro de rede'));
    });
  });

  group('WeeklyGoalOption', () {
    test('deve formatar tempo corretamente', () {
      expect(WeeklyGoalOption.beginner.formattedTime, equals('1 h'));
      expect(WeeklyGoalOption.light.formattedTime, equals('2 h'));
      expect(WeeklyGoalOption.moderate.formattedTime, equals('3 h'));
      expect(WeeklyGoalOption.active.formattedTime, equals('5 h'));
      expect(WeeklyGoalOption.intense.formattedTime, equals('7 h'));
      expect(WeeklyGoalOption.athlete.formattedTime, equals('10 h'));
    });

    test('deve retornar opção correta baseada em minutos', () {
      expect(WeeklyGoalOption.fromMinutes(60), equals(WeeklyGoalOption.beginner));
      expect(WeeklyGoalOption.fromMinutes(180), equals(WeeklyGoalOption.moderate));
      expect(WeeklyGoalOption.fromMinutes(999), equals(WeeklyGoalOption.custom));
    });
  });
} 