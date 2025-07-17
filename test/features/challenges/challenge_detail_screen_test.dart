import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:auto_route/auto_route.dart';

import 'package:ray_club_app/features/challenges/screens/challenge_detail_screen.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_state.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';


class MockStackRouter extends Mock implements StackRouter {}

void main() {
  group('ChallengeDetailScreen Botão Histórico Tests', () {
    late MockStackRouter mockRouter;
    
    setUp(() {
      mockRouter = MockStackRouter();
    });

    /// Test: Verificar se o FloatingActionButton "Ver Histórico de Treinos" está presente
    testWidgets('deve mostrar FloatingActionButton histórico de treinos', (WidgetTester tester) async {
      // Arrange: Criar um desafio mock ATIVO
      final mockChallenge = Challenge(
        id: 'test-challenge-id',
        title: 'Desafio Teste',
        description: 'Descrição do desafio teste',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        imageUrl: null,
        type: 'fitness',
        points: 100,
        active: true,
      );

      final mockState = ChallengeState(
        challenges: [mockChallenge],
        selectedChallenge: mockChallenge,
        progressList: [],
        isLoading: false,
        errorMessage: null,
        selectedGroupIdForFilter: null,
        userProgress: null,
      );

      // Act: Renderizar a tela com providers mocados
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeViewModelProvider.overrideWith(
              (ref) => MockChallengeViewModel()..setState(mockState),
            ),
          ],
          child: StackRouterScope(
            controller: mockRouter,
            stateHash: 0,
            child: MaterialApp(
              home: ChallengeDetailScreen(challengeId: 'test-challenge-id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verificar se o FloatingActionButton existe
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Verificar se o texto está correto
      final historyButtonFinder = find.text('Ver Histórico de Treinos');
      expect(historyButtonFinder, findsOneWidget);
    });

    /// Test: Verificar se o FloatingActionButton tem o ícone correto
    testWidgets('deve mostrar ícone de histórico no FloatingActionButton', (WidgetTester tester) async {
      // Arrange
      final mockChallenge = Challenge(
        id: 'test-challenge-id',
        title: 'Desafio Teste',
        description: 'Descrição do desafio teste',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        imageUrl: null,
        type: 'fitness',
        points: 100,
        active: true,
      );

      final mockState = ChallengeState(
        challenges: [mockChallenge],
        selectedChallenge: mockChallenge,
        progressList: [],
        isLoading: false,
        errorMessage: null,
        selectedGroupIdForFilter: null,
        userProgress: null,
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeViewModelProvider.overrideWith(
              (ref) => MockChallengeViewModel()..setState(mockState),
            ),
          ],
          child: StackRouterScope(
            controller: mockRouter,
            stateHash: 0,
            child: MaterialApp(
              home: ChallengeDetailScreen(challengeId: 'test-challenge-id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verificar se o ícone de histórico está presente
      final historyIconFinder = find.byIcon(Icons.history);
      expect(historyIconFinder, findsOneWidget);
    });

    /// Test: Verificar se não há FloatingActionButton quando desafio está inativo
    testWidgets('não deve mostrar FloatingActionButton quando desafio está inativo', (WidgetTester tester) async {
      // Arrange: Criar um desafio mock INATIVO
      final mockChallenge = Challenge(
        id: 'test-challenge-id',
        title: 'Desafio Teste',
        description: 'Descrição do desafio teste',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: null,
        type: 'fitness',
        points: 100,
        active: false,
      );

      final mockState = ChallengeState(
        challenges: [mockChallenge],
        selectedChallenge: mockChallenge,
        progressList: [],
        isLoading: false,
        errorMessage: null,
        selectedGroupIdForFilter: null,
        userProgress: null,
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeViewModelProvider.overrideWith(
              (ref) => MockChallengeViewModel()..setState(mockState),
            ),
          ],
          child: StackRouterScope(
            controller: mockRouter,
            stateHash: 0,
            child: MaterialApp(
              home: ChallengeDetailScreen(challengeId: 'test-challenge-id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verificar se NÃO há FloatingActionButton
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsNothing);
    });
  });
}

/// Mock ViewModel para testes
class MockChallengeViewModel extends StateNotifier<ChallengeState> {
  MockChallengeViewModel() : super(const ChallengeState(
    challenges: [],
    selectedChallenge: null,
    progressList: [],
    isLoading: false,
    errorMessage: null,
    selectedGroupIdForFilter: null,
    userProgress: null,
  ));

  void setState(ChallengeState newState) {
    state = newState;
  }
} 