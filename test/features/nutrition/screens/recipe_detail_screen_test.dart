// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:ray_club_app/features/nutrition/screens/recipe_detail_screen.dart';
import 'package:ray_club_app/features/nutrition/models/recipe.dart';
import 'package:ray_club_app/features/nutrition/providers/recipe_providers.dart';
import 'package:ray_club_app/features/nutrition/providers/recipe_favorites_providers.dart';
import 'package:ray_club_app/core/providers/auth_provider.dart';

// Mock classes
class MockRecipeFavoritesNotifier extends Mock implements RecipeFavoritesNotifier {}

void main() {
  group('RecipeDetailScreen - Favoritos', () {
    late Recipe mockRecipe;
    
    setUp(() {
      mockRecipe = Recipe(
        id: 'test-recipe-id',
        title: 'Receita Teste',
        description: 'Descrição da receita teste',
        category: 'Lanches',
        imageUrl: 'https://example.com/image.jpg',
        preparationTimeMinutes: 30,
        calories: 200,
        servings: 2,
        difficulty: 'Fácil',
        rating: 4.5,
        contentType: RecipeContentType.text,
        authorName: 'Bruna Braga',
        isFeatured: false,
        ingredients: ['Ingrediente 1', 'Ingrediente 2'],
        instructions: ['Passo 1', 'Passo 2'],
        tags: ['tag1', 'tag2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );
    });

    testWidgets('deve mostrar ícone de bookmark vazio quando receita não é favorita', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          recipeByIdProvider('test-recipe-id').overrideWith((ref) => AsyncValue.data(mockRecipe)),
          recipeFavoritesProvider.overrideWith((ref) => <String>{}),
          currentUserProvider.overrideWith((ref) => null), // Usuário não logado
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RecipeDetailScreen(recipeId: 'test-recipe-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsNothing);
    });

    testWidgets('deve mostrar ícone de bookmark preenchido quando receita é favorita', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          recipeByIdProvider('test-recipe-id').overrideWith((ref) => AsyncValue.data(mockRecipe.copyWith(isFavorite: true))),
          recipeFavoritesProvider.overrideWith((ref) => {'test-recipe-id'}),
          currentUserProvider.overrideWith((ref) => null),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RecipeDetailScreen(recipeId: 'test-recipe-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
    });

    testWidgets('deve desabilitar botão de favorito quando usuário não está logado', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          recipeByIdProvider('test-recipe-id').overrideWith((ref) => AsyncValue.data(mockRecipe)),
          recipeFavoritesProvider.overrideWith((ref) => <String>{}),
          currentUserProvider.overrideWith((ref) => null), // Usuário não logado
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RecipeDetailScreen(recipeId: 'test-recipe-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final favoriteButton = find.byType(IconButton).first;
      final iconButton = tester.widget<IconButton>(favoriteButton);
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('deve mostrar estado de loading enquanto carrega receita', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          recipeByIdProvider('test-recipe-id').overrideWith((ref) => const AsyncValue.loading()),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RecipeDetailScreen(recipeId: 'test-recipe-id'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve mostrar estado de erro quando falha ao carregar receita', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          recipeByIdProvider('test-recipe-id').overrideWith((ref) => AsyncValue.error('Erro de teste', StackTrace.empty)),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RecipeDetailScreen(recipeId: 'test-recipe-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Erro ao carregar receita: Erro de teste'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
} 