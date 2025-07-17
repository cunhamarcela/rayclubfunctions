// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/repository_exception.dart';
import 'package:ray_club_app/models/sub_challenge.dart';
import 'package:ray_club_app/repositories/sub_challenge_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  final _filterBuilder = MockPostgrestFilterBuilder();

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _filterBuilder;

  @override
  PostgrestFilterBuilder<PostgrestList> from(String table) => _filterBuilder;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(Object json,
          {bool? defaultToNull,
          bool? upsert,
          String? onConflict,
          bool? ignoreDuplicates,
          bool? count}) =>
      _filterBuilder;

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> json,
          {bool? defaultToNull, bool? count}) =>
      _filterBuilder;

  @override
  PostgrestFilterBuilder<PostgrestList> delete({bool? count}) => _filterBuilder;

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) =>
      _filterBuilder;
}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {
  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      MockPostgrestTransformBuilder();

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      MockPostgrestTransformBuilder();

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) =>
      this;

  @override
  PostgrestResponse<PostgrestList> execute() {
    return PostgrestResponse(
      data: [
        {
          'id': '1',
          'parent_challenge_id': 'parent-1',
          'creator_id': 'user-1',
          'title': 'Test SubChallenge',
          'description': 'Test Description',
          'criteria': {'workout': 'daily'},
          'start_date': '2024-03-21T00:00:00Z',
          'end_date': '2024-04-21T00:00:00Z',
          'participants': [],
          'status': 0,
          'validation_rules': {},
          'created_at': '2024-03-21T00:00:00Z',
          'updated_at': '2024-03-21T00:00:00Z',
        }
      ],
      count: 1,
    );
  }
}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {
  @override
  PostgrestResponse<PostgrestList> execute() {
    return PostgrestResponse(
      data: [
        {
          'id': '1',
          'parent_challenge_id': 'parent-1',
          'creator_id': 'user-1',
          'title': 'Test SubChallenge',
          'description': 'Test Description',
          'criteria': {'workout': 'daily'},
          'start_date': '2024-03-21T00:00:00Z',
          'end_date': '2024-04-21T00:00:00Z',
          'participants': [],
          'status': 0,
          'validation_rules': {},
          'created_at': '2024-03-21T00:00:00Z',
          'updated_at': '2024-03-21T00:00:00Z',
        }
      ],
      count: 1,
    );
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late SubChallengeRepository repository;
  late SubChallenge testSubChallenge;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    repository = SubChallengeRepository(mockClient);
    testSubChallenge = SubChallenge(
      id: '1',
      parentChallengeId: 'parent-1',
      creatorId: 'user-1',
      title: 'Test SubChallenge',
      description: 'Test Description',
      criteria: {'workout': 'daily'},
      startDate: DateTime.parse('2024-03-21T00:00:00Z'),
      endDate: DateTime.parse('2024-04-21T00:00:00Z'),
      participants: [],
      status: SubChallengeStatus.active,
      validationRules: {},
      createdAt: DateTime.parse('2024-03-21T00:00:00Z'),
      updatedAt: DateTime.parse('2024-03-21T00:00:00Z'),
    );

    when(() => mockClient.from(any())).thenReturn(mockQueryBuilder);
  });

  group('getSubChallenges', () {
    test('returns list of sub-challenges', () async {
      final subChallenges = await repository.getSubChallenges('parent-1');

      expect(subChallenges, isA<List<SubChallenge>>());
      expect(subChallenges.length, 1);
      expect(subChallenges.first.id, testSubChallenge.id);
      verify(() => mockClient.from('sub_challenges')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockQueryBuilder.eq('parent_challenge_id', 'parent-1'))
          .called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.eq('parent_challenge_id', 'parent-1'))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.getSubChallenges('parent-1'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('getSubChallenge', () {
    test('returns sub-challenge by id', () async {
      final subChallenge = await repository.getSubChallenge('1');

      expect(subChallenge, isA<SubChallenge>());
      expect(subChallenge.id, testSubChallenge.id);
      verify(() => mockClient.from('sub_challenges')).called(1);
      verify(() => mockQueryBuilder.eq('id', '1')).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.eq('id', '1'))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.getSubChallenge('1'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('createSubChallenge', () {
    test('creates and returns sub-challenge', () async {
      final subChallenge =
          await repository.createSubChallenge(testSubChallenge);

      expect(subChallenge, isA<SubChallenge>());
      expect(subChallenge.id, testSubChallenge.id);
      verify(() => mockClient.from('sub_challenges')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.insert(any()))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.createSubChallenge(testSubChallenge),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('moderateSubChallenge', () {
    test('moderates sub-challenge', () async {
      when(() => mockQueryBuilder.eq('id', '1'))
          .thenReturn(MockPostgrestFilterBuilder());

      await repository.moderateSubChallenge('1', ModerationType.approve);

      verify(() => mockClient.from('sub_challenges')).called(1);
      verify(() => mockQueryBuilder
          .update({'status': SubChallengeStatus.active.index})).called(1);
      verify(() => mockQueryBuilder.eq('id', '1')).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.update(any()))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.moderateSubChallenge('1', ModerationType.approve),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
