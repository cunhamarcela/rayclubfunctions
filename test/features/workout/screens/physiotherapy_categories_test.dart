import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/workout/screens/workout_videos_screen.dart';

/// 📌 TESTE: Subcategorias de Fisioterapia
/// Data: 2025-01-21 18:30
/// Objetivo: Testar funcionalidade de subcategorias dentro da fisioterapia

void main() {
  group('PhysiotherapyCategories', () {
    testWidgets('deve detectar categoria de fisioterapia corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'da178dba-ae94-425a-aaed-133af7b1bb0f', // ID de fisioterapia
              categoryName: 'Fisioterapia',
            ),
          ),
        ),
      );

      // Aguardar a tela carregar
      await tester.pumpAndSettle();

      // Verificar se o header da fisioterapia aparece
      expect(find.text('The Unit'), findsOneWidget);
      expect(find.text('Escolha sua área de interesse ✨'), findsOneWidget);
    });

    testWidgets('deve mostrar três subcategorias: Testes, Mobilidade, Estabilidade', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'da178dba-ae94-425a-aaed-133af7b1bb0f',
              categoryName: 'Fisioterapia',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se as subcategorias aparecem
      expect(find.text('Testes'), findsOneWidget);
      expect(find.text('Mobilidade'), findsOneWidget);
      expect(find.text('Estabilidade'), findsOneWidget);
      
      // Verificar descrições
      expect(find.text('Avaliações e diagnósticos funcionais'), findsOneWidget);
      expect(find.text('Exercícios para melhorar amplitude de movimento'), findsOneWidget);
      expect(find.text('Exercícios de estabilização e controle motor'), findsOneWidget);
    });

    testWidgets('deve navegar para vídeos filtrados ao clicar numa subcategoria', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'da178dba-ae94-425a-aaed-133af7b1bb0f',
              categoryName: 'Fisioterapia',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se os cards são clicáveis
      final testesCard = find.text('Testes');
      expect(testesCard, findsOneWidget);
      
      // Tap no card de Testes (teste básico de interação)
      await tester.tap(testesCard);
      await tester.pumpAndSettle();
    });

    testWidgets('não deve mostrar subcategorias para outras categorias', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'outro-id-qualquer',
              categoryName: 'Pilates',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Não deve mostrar o header específico da fisioterapia
      expect(find.text('The Unit'), findsNothing);
      expect(find.text('Escolha sua área de interesse ✨'), findsNothing);
    });
  });
} 