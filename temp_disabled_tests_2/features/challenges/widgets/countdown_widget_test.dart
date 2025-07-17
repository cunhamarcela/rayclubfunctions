// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/challenges/widgets/countdown_widget.dart';

/// Testes para o widget de contagem regressiva do Desafio Ray 21
void main() {
  group('CountdownWidget Tests', () {
    
    /// Helper para criar o widget com ProviderScope
    Widget createCountdownWidget({
      required DateTime targetDate,
      String? title,
      String? subtitle,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CountdownWidget(
              targetDate: targetDate,
              title: title ?? 'Desafio Ray 21',
              subtitle: subtitle ?? 'Começará em:',
            ),
          ),
        ),
      );
    }

    testWidgets('deve exibir título e subtitle corretamente', (WidgetTester tester) async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 5));
      const title = 'Teste Desafio';
      const subtitle = 'Iniciará em:';

      // Act
      await tester.pumpWidget(createCountdownWidget(
        targetDate: futureDate,
        title: title,
        subtitle: subtitle,
      ));

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('deve exibir ícone de troféu quando countdown está ativo', (WidgetTester tester) async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 1));

      // Act
      await tester.pumpWidget(createCountdownWidget(targetDate: futureDate));

      // Assert
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('deve exibir unidades de tempo (Dias, Horas, Min, Seg)', (WidgetTester tester) async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 2, hours: 3, minutes: 4, seconds: 5));

      // Act
      await tester.pumpWidget(createCountdownWidget(targetDate: futureDate));

      // Assert
      expect(find.text('Dias'), findsOneWidget);
      expect(find.text('Horas'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Seg'), findsOneWidget);
    });

    testWidgets('deve mostrar data de início formatada', (WidgetTester tester) async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 1));

      // Act
      await tester.pumpWidget(createCountdownWidget(targetDate: futureDate));

      // Assert
      expect(find.text('Início: 26 de Maio de 2025'), findsOneWidget);
    });

    testWidgets('deve exibir estado expirado quando data já passou', (WidgetTester tester) async {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      // Act
      await tester.pumpWidget(createCountdownWidget(targetDate: pastDate));
      await tester.pump(); // Permitir que o widget atualize

      // Assert
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(find.text('O Desafio Ray 21 começou!'), findsOneWidget);
      expect(find.text('Atualize a página para participar'), findsOneWidget);
    });

    testWidgets('deve usar valores padrão quando não fornecidos', (WidgetTester tester) async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 1));

      // Act
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CountdownWidget(targetDate: futureDate),
          ),
        ),
      ));

      // Assert
      expect(find.text('Desafio Ray 21'), findsOneWidget);
      expect(find.text('Começará em:'), findsOneWidget);
    });

    testWidgets('deve exibir formatação correta de números com zero à esquerda', (WidgetTester tester) async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(minutes: 5, seconds: 3));

      // Act
      await tester.pumpWidget(createCountdownWidget(targetDate: futureDate));

      // Assert
      // Verifica se números menores que 10 têm zero à esquerda
      expect(find.text('00'), findsWidgets); // Dias e horas devem ser 00
      expect(find.text('05'), findsOneWidget); // Minutos devem ser 05
      expect(find.textContaining('0'), findsWidgets); // Segundos podem ter 0x
    });
  });
} 