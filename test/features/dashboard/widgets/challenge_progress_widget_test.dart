// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/widgets/challenge_progress_widget.dart';

void main() {
  group('ChallengeProgressWidget Tests', () {
    /// Teste básico: Widget não deve quebrar quando criado
    testWidgets('should create widget without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: ChallengeProgressWidget(),
            ),
          ),
        ),
      );

      // Assert - Widget deve ser criado sem quebrar
      expect(tester.takeException(), isNull);
    });

    /// Teste básico: Widget deve ser do tipo ChallengeProgressWidget
    testWidgets('should be of correct type', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: ChallengeProgressWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ChallengeProgressWidget), findsOneWidget);
    });

    /// Teste básico: Widget deve renderizar sem erros
    testWidgets('should render without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: ChallengeProgressWidget(),
            ),
          ),
        ),
      );

      // Aguardar para garantir que o widget foi construído
      await tester.pump();

      // Assert - Não deve haver exceções
      expect(tester.takeException(), isNull);
    });
  });
} 