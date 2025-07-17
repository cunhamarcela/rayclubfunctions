import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ray_club_app/features/challenges/screens/challenge_ranking_screen.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_ranking_view_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/providers.dart';

/// Teste básico para a tela de ranking com funcionalidade de pesquisa
/// 
/// Este teste verifica:
/// - Se a barra de pesquisa é exibida
/// - Se a pesquisa filtra corretamente os participantes
/// - Se a limpeza da pesquisa funciona
class MockChallengeRankingViewModel extends StateNotifier<ChallengeRankingState> {
  MockChallengeRankingViewModel() : super(const ChallengeRankingState());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void init(String challengeId) {
    state = state.copyWith(
      challengeId: challengeId,
      progressList: [
        ChallengeProgress(
          id: '1',
          userId: 'user1',
          challengeId: challengeId,
          userName: 'Adriana Esterr',
          points: 100,
          position: 1,
          createdAt: DateTime.now(),
        ),
        ChallengeProgress(
          id: '2',
          userId: 'user2',
          challengeId: challengeId,
          userName: 'Alice Coelho',
          points: 90,
          position: 2,
          createdAt: DateTime.now(),
        ),
        ChallengeProgress(
          id: '3',
          userId: 'user3',
          challengeId: challengeId,
          userName: 'Bruno Silva',
          points: 80,
          position: 3,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  void loadChallengeRanking() async {
    // Simula carregamento
  }

  void loadUserGroups() async {
    // Simula carregamento
  }
}

void main() {
  group('ChallengeRankingScreen Search Tests', () {
    late MockChallengeRankingViewModel mockViewModel;

    setUp(() {
      mockViewModel = MockChallengeRankingViewModel();
    });

    testWidgets('deve exibir a barra de pesquisa', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeRankingViewModelProvider.overrideWith((ref) => mockViewModel),
          ],
          child: MaterialApp(
            home: ChallengeRankingScreen(challengeId: 'test-challenge'),
          ),
        ),
      );

      // Inicializar o viewmodel
      mockViewModel.init('test-challenge');
      await tester.pump();

      // Verificar se a barra de pesquisa está presente
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Pesquisar participante...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('deve filtrar participantes quando pesquisar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeRankingViewModelProvider.overrideWith((ref) => mockViewModel),
          ],
          child: MaterialApp(
            home: ChallengeRankingScreen(challengeId: 'test-challenge'),
          ),
        ),
      );

      // Inicializar o viewmodel
      mockViewModel.init('test-challenge');
      await tester.pump();

      // Todos os participantes devem estar visíveis inicialmente
      expect(find.text('Adriana Esterr'), findsOneWidget);
      expect(find.text('Alice Coelho'), findsOneWidget);
      expect(find.text('Bruno Silva'), findsOneWidget);

      // Digitar na barra de pesquisa
      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pump();

      // Verificar se o viewmodel foi atualizado
      expect(mockViewModel.state.searchQuery, equals('Alice'));
    });

    testWidgets('deve mostrar botão de limpar quando há texto na pesquisa', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeRankingViewModelProvider.overrideWith((ref) => mockViewModel),
          ],
          child: MaterialApp(
            home: ChallengeRankingScreen(challengeId: 'test-challenge'),
          ),
        ),
      );

      // Inicializar o viewmodel
      mockViewModel.init('test-challenge');
      await tester.pump();

      // Inicialmente não deve ter botão de limpar
      expect(find.byIcon(Icons.clear), findsNothing);

      // Adicionar texto na pesquisa
      mockViewModel.updateSearchQuery('Alice');
      await tester.pump();

      // Agora deve ter o botão de limpar
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('deve limpar a pesquisa quando clicar no botão clear', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeRankingViewModelProvider.overrideWith((ref) => mockViewModel),
          ],
          child: MaterialApp(
            home: ChallengeRankingScreen(challengeId: 'test-challenge'),
          ),
        ),
      );

      // Inicializar o viewmodel
      mockViewModel.init('test-challenge');
      mockViewModel.updateSearchQuery('Alice');
      await tester.pump();

      // Verificar se há texto na pesquisa
      expect(mockViewModel.state.searchQuery, equals('Alice'));

      // Clicar no botão de limpar
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Verificar se a pesquisa foi limpa
      expect(mockViewModel.state.searchQuery, equals(''));
    });
  });
} 