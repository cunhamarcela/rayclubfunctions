// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestList> {}
class MockPostgrestSingleFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestMap> {}

void main() {
  late SupabaseChallengeRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestSingleFilterBuilder mockSingleFilterBuilder;

  const testChallengeId = 'challenge-123';
  const testUserId = 'user-123';

  final testProgressData = {
    'id': 'progress-123',
    'user_id': testUserId,
    'challenge_id': testChallengeId,
    'user_name': 'Test User',
    'user_photo_url': 'https://example.com/avatar.jpg',
    'points': 100,
    'check_ins_count': 5,
    'last_check_in': DateTime.now().toIso8601String(),
    'consecutive_days': 3,
    'completed': false,
    'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'position': 2,
    'completion_percentage': 35.5,
  };

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockSingleFilterBuilder = MockPostgrestSingleFilterBuilder();

    repository = SupabaseChallengeRepository(mockClient);

    // Setup common mocks
    when(() => mockClient.from('challenge_progress')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
  });

  // group('getUserProgress', () {
    // test('should return ChallengeProgress when user progress exists', () async {
      // Arrange
      when(() => mockFilterBuilder.eq('challenge_id', testChallengeId))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', testUserId))
          .thenReturn(mockSingleFilterBuilder);
      when(() => mockSingleFilterBuilder.maybeSingle())
          .thenAnswer((_) async => testProgressData);

      // Act
      final result = await repository.getUserProgress(testChallengeId, testUserId);

      // Assert
      expect(result, isA<ChallengeProgress>());
      expect(result?.id, 'progress-123');
      expect(result?.userId, testUserId);
      expect(result?.challengeId, testChallengeId);
      expect(result?.points, 100);
      expect(result?.checkInsCount, 5);
      expect(result?.consecutiveDays, 3);
      expect(result?.completionPercentage, 35.5);
      
      // Verify method calls
      verify(() => mockClient.from('challenge_progress')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockFilterBuilder.eq('challenge_id', testChallengeId)).called(1);
      verify(() => mockFilterBuilder.eq('user_id', testUserId)).called(1);
      verify(() => mockSingleFilterBuilder.maybeSingle()).called(1);
    });

    // test('should return null when user progress does not exist', () async {
      // Arrange
      when(() => mockFilterBuilder.eq('challenge_id', testChallengeId))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', testUserId))
          .thenReturn(mockSingleFilterBuilder);
      when(() => mockSingleFilterBuilder.maybeSingle())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getUserProgress(testChallengeId, testUserId);

      // Assert
      expect(result, isNull);
      
      // Verify method calls
      verify(() => mockClient.from('challenge_progress')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockFilterBuilder.eq('challenge_id', testChallengeId)).called(1);
      verify(() => mockFilterBuilder.eq('user_id', testUserId)).called(1);
      verify(() => mockSingleFilterBuilder.maybeSingle()).called(1);
    });

    // test('should handle Postgrest errors gracefully', () async {
      // Arrange
      when(() => mockFilterBuilder.eq('challenge_id', testChallengeId))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', testUserId))
          .thenReturn(mockSingleFilterBuilder);
      when(() => mockSingleFilterBuilder.maybeSingle())
          .thenThrow(PostgrestException(message: 'Database error'));

      // Act & Assert
      expect(
        () => repository.getUserProgress(testChallengeId, testUserId),
        throwsA(isA<DatabaseException>()),
      );
    });

    // test('should handle general errors gracefully', () async {
      // Arrange
      when(() => mockFilterBuilder.eq('challenge_id', testChallengeId))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', testUserId))
          .thenReturn(mockSingleFilterBuilder);
      when(() => mockSingleFilterBuilder.maybeSingle())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getUserProgress(testChallengeId, testUserId),
        throwsA(isA<AppException>()),
      );
    });

    // test('should handle malformed data gracefully', () async {
      // Arrange - Provide incomplete/invalid data
      final malformedData = {
        'id': 'progress-123',
        'user_id': testUserId,
        // Missing challenge_id and other fields
      };

      when(() => mockFilterBuilder.eq('challenge_id', testChallengeId))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', testUserId))
          .thenReturn(mockSingleFilterBuilder);
      when(() => mockSingleFilterBuilder.maybeSingle())
          .thenAnswer((_) async => malformedData);

      // Act
      final result = await repository.getUserProgress(testChallengeId, testUserId);

      // Assert - Should not throw but return object with default values
      expect(result, isA<ChallengeProgress>());
      expect(result?.userId, testUserId);
      expect(result?.challengeId, ''); // Default value when missing
    });
  });
} 