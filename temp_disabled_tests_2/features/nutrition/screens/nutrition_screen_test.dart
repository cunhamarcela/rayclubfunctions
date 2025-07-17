import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ray_club_app/features/nutrition/screens/nutrition_screen.dart';
import 'package:ray_club_app/features/nutrition/models/recipe.dart';
import 'package:ray_club_app/features/nutrition/providers/recipe_providers.dart';

class MockRecipeRepository extends Mock {}

void main() {
  group('NutritionScreen', () {
    testWidgets('should display loading indicator when fetching recipes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionistRecipesProvider.overrideWith((ref) async {
              await Future.delayed(const Duration(seconds: 1));
              return <Recipe>[];
            }),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display tabs for receitas, videos and materiais', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionistRecipesProvider.overrideWith((ref) async => <Recipe>[]),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Receitas'), findsOneWidget);
      expect(find.text('Vídeos'), findsOneWidget);
      expect(find.text('Materiais'), findsOneWidget);
    });

    testWidgets('should display empty state when no recipes available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionistRecipesProvider.overrideWith((ref) async => <Recipe>[]),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nenhuma receita disponível'), findsOneWidget);
    });

    testWidgets('should display error state when loading fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionistRecipesProvider.overrideWith((ref) async {
              throw Exception('Erro ao carregar receitas');
            }),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar receitas'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('should display materials coming soon message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionistRecipesProvider.overrideWith((ref) async => <Recipe>[]),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Materiais tab
      await tester.tap(find.text('Materiais'));
      await tester.pumpAndSettle();

      expect(find.text('Materiais em breve'), findsOneWidget);
      expect(find.text('PDFs, ebooks e guias nutricionais\nserão disponibilizados aqui.'), findsOneWidget);
    });
  });
} 