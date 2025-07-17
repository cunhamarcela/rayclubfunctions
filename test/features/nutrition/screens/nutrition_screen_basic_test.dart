import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/nutrition/screens/nutrition_screen.dart';
import 'package:ray_club_app/features/nutrition/models/recipe.dart';
import 'package:ray_club_app/features/nutrition/providers/recipe_providers.dart';

void main() {
  testWidgets('NutritionScreen has 3 tabs', (WidgetTester tester) async {
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

    // Verifica se as 3 abas estão presentes
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('Vídeos'), findsOneWidget);
    expect(find.text('Materiais'), findsOneWidget);
  });

  testWidgets('Materials tab shows coming soon message', (WidgetTester tester) async {
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

    // Toca na aba Materiais
    await tester.tap(find.text('Materiais'));
    await tester.pumpAndSettle();

    // Verifica se a mensagem "em breve" aparece
    expect(find.text('Materiais em breve'), findsOneWidget);
  });
} 