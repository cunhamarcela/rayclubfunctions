import 'dart:async'; // Added for StreamController

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/repository_exception.dart';
import 'package:ray_club_app/models/challenge.dart';
import 'package:ray_club_app/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  final _filterBuilderList = MockPostgrestFilterBuilder<PostgrestList>();
  final _filterBuilderMap = MockPostgrestFilterBuilder<PostgrestMap>();
  final _streamFilterBuilder = MockStreamPostgrestFilterBuilder<List<Map<String, dynamic>>>();

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) => _filterBuilderList;

  @override
  PostgrestFilterBuilder<PostgrestList> from(String table) => _filterBuilderList;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(Object json,
          {bool? defaultToNull,
          bool? upsert,
          String? onConflict,
          bool? ignoreDuplicates,
          bool? count}) =>
      _filterBuilderList;

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> json,
          {bool? defaultToNull, bool? count}) =>
      _filterBuilderList;

  @override
  PostgrestFilterBuilder<PostgrestList> delete({bool? count}) => _filterBuilderList;

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) {
    print('MockSupabaseQueryBuilder: eq($column, $value)');
    return _filterBuilderList;
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    print('MockSupabaseQueryBuilder: single() called');
    return MockPostgrestTransformBuilder<PostgrestMap>();
  }

  @override
  StreamPostgrestFilterBuilder<List<Map<String, dynamic>>> stream({required List<String> primaryKey}) {
    print('MockSupabaseQueryBuilder: stream called with pk: $primaryKey');
    return _streamFilterBuilder;
  }
}

class MockStreamPostgrestFilterBuilder<T> extends Mock implements StreamPostgrestFilterBuilder<T> {
  late final StreamController<T> _controller;
  bool _isClosed = false;

  MockStreamPostgrestFilterBuilder() {
    _controller = StreamController<T>.broadcast(onCancel: () {
      _isClosed = true;
    });
  }

  @override
  Stream<T> get stream => _controller.stream;

  @override
  StreamPostgrestFilterBuilder<T> eq(String column, dynamic value) {
    print('MockStreamPostgrestFilterBuilder: eq($column, $value)');
    return this;
  }

  @override
  StreamPostgrestFilterBuilder<T> order(String column, {bool ascending = false, bool? nullsFirst}) {
    print('MockStreamPostgrestFilterBuilder: order($column, ascending: $ascending)');
    return this;
  }

  void addEvent(T event) {
    if (!_isClosed) _controller.add(event);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    if (!_isClosed) _controller.addError(error, stackTrace);
  }

  void closeStream() {
    if (!_isClosed) {
      _controller.close();
      _isClosed = true;
    }
  }
}

class MockPostgrestFilterBuilder<T extends PostgrestResponse> extends Mock
    implements PostgrestFilterBuilder<T> {
  @override
  PostgrestTransformBuilder<T> select([String columns = '*']) {
    print('MockPostgrestFilterBuilder: select($columns) called');
    return MockPostgrestTransformBuilder<T>();
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    print('MockPostgrestFilterBuilder: single() called');
    return MockPostgrestTransformBuilder<PostgrestMap>();
  }

  @override
  PostgrestFilterBuilder<T> eq(String column, dynamic value) {
    print('MockPostgrestFilterBuilder: eq($column, $value) called');
    return this;
  }

  @override
  Future<T> execute({FetchOptions? options, bool? ignoreReturn}) {
    print('MockPostgrestFilterBuilder: execute() called');
    throw UnimplementedError('execute() needs to be mocked in test setup');
  }
}

class MockPostgrestTransformBuilder<T> extends Mock implements PostgrestTransformBuilder<T> {
  @override
  Future<Response> execute({FetchOptions? options, bool? ignoreReturn}) {
    print('MockPostgrestTransformBuilder: execute() called');
    throw UnimplementedError('execute() needs to be mocked in test setup');
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockStreamPostgrestFilterBuilder<List<Map<String, dynamic>>> mockStreamFilterBuilder;
  late ChallengeRepository repository;
  late Challenge testChallenge;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockStreamFilterBuilder = MockStreamPostgrestFilterBuilder<List<Map<String, dynamic>>>();

    repository = ChallengeRepository(mockClient);

    testChallenge = Challenge(
      id: '1',
      title: 'Test Challenge',
      description: 'Test Description',
      startDate: DateTime.parse('2024-03-21'),
      endDate: DateTime.parse('2024-04-21'),
      reward: 100,
      participants: [],
      createdAt: DateTime.parse('2024-03-21T00:00:00Z'),
      updatedAt: DateTime.parse('2024-03-21T00:00:00Z'),
    );

    when(() => mockClient.from(any())).thenReturn(mockQueryBuilder);
  });

  group('getChallenges', () {
    test('returns list of challenges', () async {
      final challenges = await repository.getChallenges();

      expect(challenges, isA<List<Challenge>>());
      expect(challenges.length, 1);
      expect(challenges.first.id, testChallenge.id);
      verify(() => mockClient.from('challenges')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.select())
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.getChallenges(),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('getChallenge', () {
    test('returns challenge by id', () async {
      final challenge = await repository.getChallenge('1');

      expect(challenge, isA<Challenge>());
      expect(challenge.id, testChallenge.id);
      verify(() => mockClient.from('challenges')).called(1);
      verify(() => mockQueryBuilder.eq('id', '1')).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.eq('id', '1'))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.getChallenge('1'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('throws ResourceNotFoundException when challenge not found', () async {
      when(() => mockQueryBuilder.eq('id', '1')).thenReturn(
          MockPostgrestFilterBuilder()
            ..when(() => execute())
                .thenAnswer((_) => PostgrestResponse(data: [], count: 0)));

      expect(
        () => repository.getChallenge('1'),
        throwsA(isA<ResourceNotFoundException>()),
      );
    });
  });

  group('createChallenge', () {
    test('creates and returns challenge', () async {
      final challenge = await repository.createChallenge(testChallenge);

      expect(challenge, isA<Challenge>());
      expect(challenge.id, testChallenge.id);
      verify(() => mockClient.from('challenges')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.insert(any()))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.createChallenge(testChallenge),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('updateChallenge', () {
    test('updates and returns challenge', () async {
      final challenge =
          await repository.updateChallenge('1', testChallenge.toJson());

      expect(challenge, isA<Challenge>());
      expect(challenge.id, testChallenge.id);
      verify(() => mockClient.from('challenges')).called(1);
      verify(() => mockQueryBuilder.eq('id', '1')).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.eq('id', '1'))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.updateChallenge('1', testChallenge.toJson()),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('deleteChallenge', () {
    test('deletes challenge', () async {
      await repository.deleteChallenge('1');

      verify(() => mockClient.from('challenges')).called(1);
      verify(() => mockQueryBuilder.eq('id', '1')).called(1);
    });

    test('throws DatabaseException when database operation fails', () async {
      when(() => mockQueryBuilder.eq('id', '1'))
          .thenThrow(Exception('Database error'));

      expect(
        () => repository.deleteChallenge('1'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('watchGroupRanking', () {
    final mockTransformBuilderMap = MockPostgrestTransformBuilder<PostgrestMap>();

    setUp(() {
      mockStreamFilterBuilder = MockStreamPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      when(() => mockQueryBuilder.stream(primaryKey: ['id'])).thenReturn(mockStreamFilterBuilder);
      when(() => mockStreamFilterBuilder.eq(any(), any())).thenReturn(mockStreamFilterBuilder);
      when(() => mockStreamFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockStreamFilterBuilder);

      when(() => mockClient.from('challenge_groups')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select('id, challenge_id, member_ids')).thenReturn(mockTransformBuilderMap);
      when(() => mockTransformBuilderMap.eq('id', testGroupId)).thenReturn(mockTransformBuilderMap);
    });

    tearDown(() {
      mockStreamFilterBuilder.closeStream();
    });

    test('should emit filtered, sorted, and ranked progress for group members', () async {
      when(() => mockTransformBuilderMap.single()).thenAnswer((_) async => mockGroupData);

      final expectedProgress_t0 = [
        ChallengeProgress.fromJson(mockProgressUser1_t0).copyWith(position: 1),
        ChallengeProgress.fromJson(mockProgressUser2_t0).copyWith(position: 2),
      ];
       final expectedProgress_t1 = [
         ChallengeProgress.fromJson(mockProgressUser2_t1).copyWith(position: 1),
         ChallengeProgress.fromJson(mockProgressUser1_t1).copyWith(position: 2),
      ];

      final stream = repository.watchGroupRanking(testGroupId);

      expectLater(
        stream,
        emitsInOrder([
          expectedProgress_t0,
          expectedProgress_t1,
        ]),
      );

      await Future.delayed(Duration.zero);
      mockStreamFilterBuilder.addEvent([mockProgressUser1_t0, mockProgressUser2_t0, mockProgressUser3_t0]);
      await Future.delayed(Duration.zero);
       mockStreamFilterBuilder.addEvent([mockProgressUser1_t1, mockProgressUser2_t1, mockProgressUser3_t0]);
       await Future.delayed(Duration.zero);
    });

    test('should yield empty list and complete if group has no members', () async {
      final mockEmptyGroupData = Map<String, dynamic>.from(mockGroupData)..['member_ids'] = <String>[];
      when(() => mockTransformBuilderMap.single()).thenAnswer((_) async => mockEmptyGroupData);

      final stream = repository.watchGroupRanking(testGroupId);

      await expectLater(stream, emitsInOrder([ equals(<ChallengeProgress>[]), emitsDone]));
    });

    test('should emit ResourceNotFoundException if group does not exist', () async {
      when(() => mockTransformBuilderMap.single()).thenAnswer((_) async => null);

      final stream = repository.watchGroupRanking(testGroupId);

       await expectLater(stream, emitsError(isA<ResourceNotFoundException>()));
    });

    test('should emit DatabaseException if stream emits an error', () async {
       when(() => mockTransformBuilderMap.single()).thenAnswer((_) async => mockGroupData);

      final streamError = Exception('Supabase stream error');
      final expectedError = isA<DatabaseException>()
          .having((e) => e.originalError, 'originalError', streamError)
          .having((e) => e.message, 'message', contains('Erro ao observar ranking do grupo'));

      final stream = repository.watchGroupRanking(testGroupId);

      expectLater(stream, emitsError(expectedError));

      await Future.delayed(Duration.zero);
      mockStreamFilterBuilder.addError(streamError);
       await Future.delayed(Duration.zero);
    });

    test('should filter out non-member progress', () async {
      when(() => mockTransformBuilderMap.single()).thenAnswer((_) async => mockGroupData);

      final expectedProgress = [
        ChallengeProgress.fromJson(mockProgressUser1_t0).copyWith(position: 1),
        ChallengeProgress.fromJson(mockProgressUser2_t0).copyWith(position: 2),
      ];

      final stream = repository.watchGroupRanking(testGroupId);

      expectLater(stream, emits(expectedProgress));

      await Future.delayed(Duration.zero);
      mockStreamFilterBuilder.addEvent([
        mockProgressUser1_t0,
        mockProgressUser2_t0,
        mockProgressUser3_t0
      ]);
       await Future.delayed(Duration.zero);
    });

    test('should correctly rank users based on points within the group', () async {
      when(() => mockTransformBuilderMap.single()).thenAnswer((_) async => mockGroupData);

       final user1Progress = Map.of(mockProgressUser1_t0)..['points'] = 75;
       final user2Progress = Map.of(mockProgressUser2_t0)..['points'] = 150;

       final expectedProgress = [
        ChallengeProgress.fromJson(user2Progress).copyWith(position: 1),
        ChallengeProgress.fromJson(user1Progress).copyWith(position: 2),
      ];

      final stream = repository.watchGroupRanking(testGroupId);

      expectLater(stream, emits(expectedProgress));

      await Future.delayed(Duration.zero);
      mockStreamFilterBuilder.addEvent([ user1Progress, user2Progress ]);
       await Future.delayed(Duration.zero);
    });
  });
}
