// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/home/repositories/home_repository.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestList> {}
class MockCacheService extends Mock implements CacheService {}

void main() {
  late SupabaseHomeRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockCacheService mockCacheService;

  final mockWorkoutData = [
    {
      'id': 'workout1',
      'title': 'Full Body Workout',
      'image_url': 'https://example.com/workout1.jpg',
      'duration_minutes': 30,
      'difficulty': 'medium',
      'is_public': true,
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'workout2',
      'title': 'HIIT Training',
      'image_url': 'https://example.com/workout2.jpg',
      'duration_minutes': 45,
      'difficulty': 'hard',
      'is_public': true,
      'created_at': DateTime.now().toIso8601String(),
    }
  ];

  final expectedWorkouts = [
    PopularWorkout(
      id: 'workout1',
      title: 'Full Body Workout',
      imageUrl: 'https://example.com/workout1.jpg',
      duration: '30 min',
      difficulty: 'medium',
      favoriteCount: 0,
    ),
    PopularWorkout(
      id: 'workout2',
      title: 'HIIT Training',
      imageUrl: 'https://example.com/workout2.jpg',
      duration: '45 min',
      difficulty: 'hard',
      favoriteCount: 0,
    ),
  ];

  // Cache key used in the repository for popular workouts
  const cacheKey = '_popular_workouts_cache_key';

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockCacheService = MockCacheService();

    repository = SupabaseHomeRepository(
      supabaseClient: mockClient,
      cacheService: mockCacheService,
    );

    // Setup common mocks
    when(() => mockClient.from('workouts')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
  });

  group('getPopularWorkouts', () {
    test('should return popular workouts from Supabase when cache is empty', () async {
      // Arrange
      when(() => mockCacheService.get(any())).thenAnswer((_) async => null);
      when(() => mockCacheService.set(any(), any(), expiry: any(named: 'expiry')))
          .thenAnswer((_) async => true);
      
      when(() => mockFilterBuilder.eq('is_public', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(5)).thenAnswer((_) async => mockWorkoutData);

      // Act
      final result = await repository.getPopularWorkouts();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'workout1');
      expect(result[0].title, 'Full Body Workout');
      expect(result[0].duration, '30 min');
      expect(result[1].id, 'workout2');
      expect(result[1].title, 'HIIT Training');
      expect(result[1].difficulty, 'hard');
      
      // Verify method calls
      verify(() => mockCacheService.get(any())).called(1);
      verify(() => mockClient.from('workouts')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockFilterBuilder.eq('is_public', true)).called(1);
      verify(() => mockFilterBuilder.order('created_at', ascending: false)).called(1);
      verify(() => mockFilterBuilder.limit(5)).called(1);
      verify(() => mockCacheService.set(any(), any(), expiry: any(named: 'expiry'))).called(1);
    });

    test('should return popular workouts from cache when available', () async {
      // Arrange
      final cachedWorkouts = expectedWorkouts.map((w) => w.toJson()).toList();
      when(() => mockCacheService.get(any())).thenAnswer((_) async => cachedWorkouts);
      
      // Act
      final result = await repository.getPopularWorkouts();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'workout1');
      expect(result[1].id, 'workout2');
      
      // Verify cache was used
      verify(() => mockCacheService.get(any())).called(1);
      verifyNever(() => mockClient.from('workouts'));
    });

    test('should handle Supabase errors and use cache as fallback', () async {
      // Arrange
      final cachedWorkouts = expectedWorkouts.map((w) => w.toJson()).toList();
      when(() => mockCacheService.get(any())).thenAnswer((_) async => null);
      when(() => mockCacheService.get(any())).thenAnswer((_) async => cachedWorkouts);
      
      when(() => mockFilterBuilder.eq('is_public', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(5)).thenThrow(PostgrestException(message: 'Database error'));

      // Act
      final result = await repository.getPopularWorkouts();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'workout1');
      expect(result[1].id, 'workout2');
      
      // Verify fallback to cache
      verify(() => mockCacheService.get(any())).called(2); // Called twice - first check, then fallback
    });

    test('should throw AppException when both network and cache fail', () async {
      // Arrange
      when(() => mockCacheService.get(any())).thenAnswer((_) async => null);
      
      when(() => mockFilterBuilder.eq('is_public', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(5)).thenThrow(Exception('Network error'));

      // Second cache attempt also fails
      when(() => mockCacheService.get(any())).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.getPopularWorkouts(),
        throwsA(isA<AppException>()),
      );
    });

    test('should handle empty response from Supabase', () async {
      // Arrange
      when(() => mockCacheService.get(any())).thenAnswer((_) async => null);
      when(() => mockCacheService.set(any(), any(), expiry: any(named: 'expiry')))
          .thenAnswer((_) async => true);
      
      when(() => mockFilterBuilder.eq('is_public', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(5)).thenAnswer((_) async => []);

      // Act
      final result = await repository.getPopularWorkouts();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle malformed data from Supabase', () async {
      // Arrange - Malformed workout data with missing fields
      final malformedData = [
        {
          'id': 'workout1',
          // Missing title and other required fields
          'duration_minutes': 30,
        }
      ];
      
      when(() => mockCacheService.get(any())).thenAnswer((_) async => null);
      when(() => mockCacheService.set(any(), any(), expiry: any(named: 'expiry')))
          .thenAnswer((_) async => true);
      
      when(() => mockFilterBuilder.eq('is_public', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(5)).thenAnswer((_) async => malformedData);

      // Act
      final result = await repository.getPopularWorkouts();

      // Assert - Should still process the result without exception
      expect(result.length, 1);
      expect(result[0].id, 'workout1');
      expect(result[0].title, ''); // Default or empty value
      expect(result[0].duration, '30 min');
    });
  });
} 