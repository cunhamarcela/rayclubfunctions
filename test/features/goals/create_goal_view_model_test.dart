// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:ray_club_app/features/goals/models/unified_goal_model.dart';
import 'package:ray_club_app/features/goals/repositories/unified_goal_repository.dart';
import 'package:ray_club_app/features/goals/viewmodels/create_goal_view_model.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/auth/models/user_model.dart';

@GenerateMocks([UnifiedGoalRepository, IAuthRepository])
import 'create_goal_view_model_test.mocks.dart';

/// **TESTES DO CREATE GOAL VIEW MODEL**
/// 
/// **Data:** 30 de Janeiro de 2025 às 17:15
/// **Objetivo:** Testar criação de metas personalizadas e pré-definidas
void main() {
  group('CreateGoalViewModel', () {
    late MockUnifiedGoalRepository mockRepository;
    late MockIAuthRepository mockAuthRepository;
    late ProviderContainer container;
    late CreateGoalViewModel viewModel;

    setUp(() {
      mockRepository = MockUnifiedGoalRepository();
      mockAuthRepository = MockIAuthRepository();
      
      container = ProviderContainer(
        overrides: [
          unifiedGoalRepositoryProvider.overrideWithValue(mockRepository),
          // authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      
      viewModel = CreateGoalViewModel(
        repository: mockRepository,
        authRepository: mockAuthRepository,
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('createGoal', () {
      const mockUser = UserModel(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: '2025-01-30T17:15:00Z',
      );

      test('deve criar meta personalizada com sucesso', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
        when(mockRepository.createGoal(any))
            .thenAnswer((_) async => UnifiedGoal(
              id: 'goal123',
              userId: 'user123',
              title: 'Meditar diariamente',
              type: UnifiedGoalType.custom,
              targetValue: 7.0,
              currentValue: 0.0,
              unit: GoalUnit.dias,
              measurementType: 'days',
              startDate: DateTime.now(),
              createdAt: DateTime.now(),
            ));

        // Act
        final result = await viewModel.createGoal(
          title: 'Meditar diariamente',
          category: null,
          measurementType: 'days',
          targetValue: 7.0,
          isCustom: true,
        );

        // Assert
        expect(result, isTrue);
        expect(viewModel.state.isSuccess, isTrue);
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.errorMessage, isNull);
        
        verify(mockRepository.createGoal(any)).called(1);
      });

      test('deve criar meta pré-definida com categoria', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
        when(mockRepository.createGoal(any))
            .thenAnswer((_) async => UnifiedGoal(
              id: 'goal456',
              userId: 'user123',
              title: 'Funcional',
              type: UnifiedGoalType.weeklyMinutes,
              category: GoalCategory.funcional,
              targetValue: 150.0,
              currentValue: 0.0,
              unit: GoalUnit.minutos,
              measurementType: 'minutes',
              startDate: DateTime.now(),
              createdAt: DateTime.now(),
            ));

        // Act
        final result = await viewModel.createGoal(
          title: 'Funcional',
          category: 'Funcional',
          measurementType: 'minutes',
          targetValue: 150.0,
          isCustom: false,
        );

        // Assert
        expect(result, isTrue);
        expect(viewModel.state.isSuccess, isTrue);
        
        final captured = verify(mockRepository.createGoal(captureAny)).captured.first as UnifiedGoal;
        expect(captured.title, equals('Funcional'));
        expect(captured.category, equals(GoalCategory.funcional));
        expect(captured.autoIncrement, isTrue); // Metas pré-definidas têm auto-incremento
      });

      test('deve falhar quando usuário não está autenticado', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await viewModel.createGoal(
          title: 'Teste',
          category: null,
          measurementType: 'days',
          targetValue: 5.0,
          isCustom: true,
        );

        // Assert
        expect(result, isFalse);
        expect(viewModel.state.errorMessage, isNotNull);
        expect(viewModel.state.errorMessage, contains('Usuário não autenticado'));
        
        verifyNever(mockRepository.createGoal(any));
      });

      test('deve tratar erro do repositório', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
        when(mockRepository.createGoal(any))
            .thenThrow(Exception('Erro de conexão'));

        // Act
        final result = await viewModel.createGoal(
          title: 'Teste',
          category: null,
          measurementType: 'days',
          targetValue: 5.0,
          isCustom: true,
        );

        // Assert
        expect(result, isFalse);
        expect(viewModel.state.errorMessage, isNotNull);
        expect(viewModel.state.errorMessage, contains('Erro ao criar meta'));
        expect(viewModel.state.isLoading, isFalse);
      });
    });

    group('clearState', () {
      test('deve limpar estado corretamente', () {
        // Arrange
        viewModel.state = viewModel.state.copyWith(
          isLoading: true,
          errorMessage: 'Erro teste',
        );

        // Act
        viewModel.clearState();

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.isSuccess, isFalse);
        expect(viewModel.state.errorMessage, isNull);
      });
    });
  });

  group('GoalCategory', () {
    test('deve ter tipos de exercício corretos', () {
      final workoutTypes = GoalCategory.workoutTypes;
      
      expect(workoutTypes, contains('Funcional'));
      expect(workoutTypes, contains('Musculação'));
      expect(workoutTypes, contains('Pilates'));
      expect(workoutTypes, contains('Força'));
      expect(workoutTypes, contains('Alongamento'));
      expect(workoutTypes, contains('Corrida'));
      expect(workoutTypes, contains('Fisioterapia'));
      expect(workoutTypes, contains('Outro'));
      expect(workoutTypes.length, equals(8));
    });

    test('fromString deve funcionar corretamente', () {
      expect(GoalCategory.fromString('Funcional'), equals(GoalCategory.funcional));
      expect(GoalCategory.fromString('Musculação'), equals(GoalCategory.musculacao));
      expect(GoalCategory.fromString('Inexistente'), equals(GoalCategory.outro));
      expect(GoalCategory.fromString(null), isNull);
    });

    test('isValidWorkoutType deve validar tipos corretamente', () {
      expect(GoalCategory.isValidWorkoutType('Funcional'), isTrue);
      expect(GoalCategory.isValidWorkoutType('Musculação'), isTrue);
      expect(GoalCategory.isValidWorkoutType('Inexistente'), isFalse);
      expect(GoalCategory.isValidWorkoutType(''), isFalse);
    });
  });
}

