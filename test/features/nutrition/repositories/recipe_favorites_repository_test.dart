// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/nutrition/repositories/recipe_favorites_repository.dart';
import 'package:ray_club_app/core/exceptions/app_exceptions.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  group('SupabaseRecipeFavoritesRepository', () {
    late MockSupabaseClient mockClient;
    late SupabaseRecipeFavoritesRepository repository;
    
    const String userId = 'test-user-id';
    const String recipeId = 'test-recipe-id';

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = SupabaseRecipeFavoritesRepository(mockClient);
    });

    group('addToFavorites', () {
      test('deve adicionar receita aos favoritos com sucesso', () async {
        // Arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(mockClient.from('user_favorite_recipes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any)).thenAnswer((_) async => []);

        // Act
        await repository.addToFavorites(userId, recipeId);

        // Assert
        verify(mockClient.from('user_favorite_recipes')).called(1);
        verify(mockQueryBuilder.upsert({
          'user_id': userId,
          'recipe_id': recipeId,
        })).called(1);
      });

      test('deve lançar StorageException em caso de erro', () async {
        // Arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(mockClient.from('user_favorite_recipes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.addToFavorites(userId, recipeId),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('removeFromFavorites', () {
      test('deve remover receita dos favoritos com sucesso', () async {
        // Arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(mockClient.from('user_favorite_recipes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('user_id', userId)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('recipe_id', recipeId)).thenAnswer((_) async => []);

        // Act
        await repository.removeFromFavorites(userId, recipeId);

        // Assert
        verify(mockClient.from('user_favorite_recipes')).called(1);
        verify(mockQueryBuilder.delete()).called(1);
        verify(mockQueryBuilder.eq('user_id', userId)).called(1);
        verify(mockQueryBuilder.eq('recipe_id', recipeId)).called(1);
      });

      test('deve lançar StorageException em caso de erro', () async {
        // Arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(mockClient.from('user_favorite_recipes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('user_id', userId)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('recipe_id', recipeId)).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.removeFromFavorites(userId, recipeId),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('isFavorite', () {
      test('deve retornar true se receita for favorita', () async {
        // Arrange
        when(mockClient.rpc('is_recipe_favorited', params: anyNamed('params')))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isFavorite(userId, recipeId);

        // Assert
        expect(result, isTrue);
        verify(mockClient.rpc('is_recipe_favorited', params: {
          'p_user_id': userId,
          'p_recipe_id': recipeId,
        })).called(1);
      });

      test('deve retornar false se receita não for favorita', () async {
        // Arrange
        when(mockClient.rpc('is_recipe_favorited', params: anyNamed('params')))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.isFavorite(userId, recipeId);

        // Assert
        expect(result, isFalse);
      });

      test('deve retornar false em caso de erro', () async {
        // Arrange
        when(mockClient.rpc('is_recipe_favorited', params: anyNamed('params')))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.isFavorite(userId, recipeId);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getFavoriteRecipeIds', () {
      test('deve retornar set de IDs das receitas favoritas', () async {
        // Arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(mockClient.from('user_favorite_recipes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('recipe_id')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('user_id', userId)).thenAnswer((_) async => [
          {'recipe_id': 'recipe1'},
          {'recipe_id': 'recipe2'},
        ]);

        // Act
        final result = await repository.getFavoriteRecipeIds(userId);

        // Assert
        expect(result, equals({'recipe1', 'recipe2'}));
        verify(mockClient.from('user_favorite_recipes')).called(1);
        verify(mockQueryBuilder.select('recipe_id')).called(1);
        verify(mockQueryBuilder.eq('user_id', userId)).called(1);
      });

      test('deve retornar set vazio em caso de erro', () async {
        // Arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(mockClient.from('user_favorite_recipes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('recipe_id')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('user_id', userId)).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getFavoriteRecipeIds(userId);

        // Assert
        expect(result, isEmpty);
      });
    });
  });
} 