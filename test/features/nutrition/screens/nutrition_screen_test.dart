// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/features/nutrition/screens/nutrition_screen.dart';
// import 'package:ray_club_app/features/nutrition/view_models/nutrition_screen_view_model.dart';

/// Testes básicos para a tela de nutrição
void main() {
  group('NutritionScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('deve exibir o título da tela corretamente', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const NutritionScreen(),
          ),
        ),
      );

      expect(find.text('Nutrição'), findsOneWidget);
    });

    testWidgets('deve exibir a seção de apresentação da nutricionista', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const NutritionScreen(),
          ),
        ),
      );

      expect(find.text('Conheça a'), findsOneWidget);
      expect(find.text('Bruna Braga'), findsOneWidget);
      expect(find.text('Nutricionista especialista\nem nutrição esportiva'), findsOneWidget);
      expect(find.text('Assistir Apresentação'), findsOneWidget);
    });

    testWidgets('deve exibir as três tabs: Receitas, Vídeos e Materiais', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const NutritionScreen(),
          ),
        ),
      );

      expect(find.text('Receitas'), findsOneWidget);
      expect(find.text('Vídeos'), findsOneWidget);
      expect(find.text('Materiais'), findsOneWidget);
    });

    testWidgets('deve exibir botão de voltar no header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const NutritionScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('deve permitir tocar no botão de apresentação', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const NutritionScreen(),
          ),
        ),
      );

      final apresentacaoButton = find.text('Assistir Apresentação');
      expect(apresentacaoButton, findsOneWidget);

      await tester.tap(apresentacaoButton);
      await tester.pumpAndSettle();

      // Verifica se o modal foi aberto (pode ser ajustado conforme necessário)
      // Este teste pode falhar se o YouTubePlayerWidget não estiver disponível no teste
    });
  });
} 