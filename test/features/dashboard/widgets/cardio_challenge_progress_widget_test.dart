// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/widgets/cardio_challenge_progress_widget.dart';
import 'package:ray_club_app/features/dashboard/models/cardio_challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/providers/cardio_challenge_providers.dart';

void main() {
  group('CardioChallengeProgressWidget', () {
    testWidgets('deve exibir estado de não participação corretamente', (WidgetTester tester) async {
      final mockProgress = CardioChallengeProgress(
        position: 0,
        totalMinutes: 0,
        isParticipating: false,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardioChallengeProgressWithRefreshProvider.overrideWith(
              (ref) => Future.value(mockProgress),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CardioChallengeProgressWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se o estado de não participação está sendo exibido
      expect(find.text('Entre no desafio para competir!'), findsOneWidget);
      expect(find.text('Participe do desafio e compete com outros usuários em minutos de cardio!'), findsOneWidget);
    });

    testWidgets('deve exibir progresso do usuário participante corretamente', (WidgetTester tester) async {
      final mockProgress = CardioChallengeProgress(
        position: 3,
        totalMinutes: 150,
        previousDayMinutes: 30,
        todayMinutes: 45,
        improvementPercentage: 50.0,
        isParticipating: true,
        totalParticipants: 25,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardioChallengeProgressWithRefreshProvider.overrideWith(
              (ref) => Future.value(mockProgress),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CardioChallengeProgressWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se os dados do progresso estão sendo exibidos
      expect(find.text('Desafio Cardio'), findsOneWidget);
      expect(find.text('3º'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('+50.0%'), findsOneWidget);
      expect(find.text('de 25'), findsOneWidget);
    });

    testWidgets('deve exibir barra de melhoria para progresso significativo', (WidgetTester tester) async {
      final mockProgress = CardioChallengeProgress(
        position: 1,
        totalMinutes: 200,
        previousDayMinutes: 40,
        todayMinutes: 60,
        improvementPercentage: 50.0, // >= 5% para ser significativo
        isParticipating: true,
        totalParticipants: 10,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardioChallengeProgressWithRefreshProvider.overrideWith(
              (ref) => Future.value(mockProgress),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CardioChallengeProgressWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se a barra de melhoria está sendo exibida
      expect(find.byIcon(Icons.trending_up), findsWidgets);
      expect(find.textContaining('Excelente! Você melhorou'), findsOneWidget);
    });

    testWidgets('deve exibir estado de erro corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardioChallengeProgressWithRefreshProvider.overrideWith(
              (ref) => Future.error('Erro de teste'),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CardioChallengeProgressWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se o estado de erro está sendo exibido
      expect(find.text('Erro ao carregar dados'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
