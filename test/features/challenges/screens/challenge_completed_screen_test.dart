// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/challenges/screens/challenge_completed_screen.dart';

void main() {
  group('ChallengeCompletedScreen Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = ProviderScope(
        child: MaterialApp(
          home: const ChallengeCompletedScreen(),
        ),
      );
    });

    testWidgets('deve exibir mensagem de desafio concluído', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('🎉 Desafio concluído!'), findsOneWidget);
      expect(find.text('Parabéns por ter chegado até o fim!'), findsOneWidget);
      expect(find.textContaining('Agora é só aguardar'), findsOneWidget);
    });

    testWidgets('deve exibir botão para ver histórico de exercícios', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ver meu histórico de exercícios'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('deve ter banner superior com título "Desafio"', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Desafio'), findsOneWidget);
      expect(find.text('Aguardando Resultado'), findsOneWidget);
    });

    testWidgets('deve exibir banner com título apenas', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Desafio'), findsOneWidget);
      // Banner deve ter apenas o título, sem ícones sobrepostos
      expect(find.byIcon(Icons.emoji_events), findsNothing); // Ícone foi removido do banner
    });

    testWidgets('deve exibir informação sobre funcionalidades do histórico', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('No histórico você pode adicionar'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('deve ter Scaffold como widget principal', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
} 