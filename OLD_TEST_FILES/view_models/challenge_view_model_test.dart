// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:ray_club_app/models/challenge.dart';
import 'package:ray_club_app/repositories/challenge_repository.dart';
import 'package:ray_club_app/services/storage_service.dart';
import 'package:ray_club_app/view_models/challenge_view_model.dart';
import 'package:ray_club_app/view_models/states/challenge_state.dart';

class MockChallengeRepository extends Mock implements IChallengeRepository {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  late ChallengeViewModel viewModel;
  late MockChallengeRepository mockRepository;
  late MockStorageService mockStorageService;

  final testChallenge = Challenge(
    id: '1',
    title: 'Test Challenge',
    description: 'Test Description',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    reward: 100,
    participants: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockChallengeRepository();
    mockStorageService = MockStorageService();
    viewModel = ChallengeViewModel(
      challengeRepository: mockRepository,
      storageService: mockStorageService,
      challengeId: '1',
    );
  });

  group('initial state', () {
    test('should be initial', () {
      expect(viewModel.state, equals(ChallengeState.initial()));
    });
  });

  group('initialize', () {
    test('should emit loading state while initializing', () async {
      when(() => mockRepository.getChallenge(any()))
          .thenAnswer((_) async => testChallenge);

      viewModel.initialize('1');

      expect(viewModel.state, equals(ChallengeState.loading()));
      verify(() => mockRepository.getChallenge('1')).called(1);
    });

    test('should emit loaded state with challenge on successful initialization',
        () async {
      when(() => mockRepository.getChallenge(any()))
          .thenAnswer((_) async => testChallenge);

      await viewModel.initialize('1');

      expect(viewModel.state,
          equals(ChallengeState.loaded(challenge: testChallenge)));
      verify(() => mockRepository.getChallenge('1')).called(1);
    });

    test('should emit error state when initialization fails', () async {
      when(() => mockRepository.getChallenge(any()))
          .thenThrow(Exception('Failed to load challenge'));

      await viewModel.initialize('1');

      expect(viewModel.state,
          equals(ChallengeState.error(message: 'Failed to load challenge')));
      verify(() => mockRepository.getChallenge('1')).called(1);
    });
  });

  group('updateChallenge', () {
    test('should emit loading state while updating', () async {
      when(() => mockRepository.updateChallenge(any(), any()))
          .thenAnswer((_) async => testChallenge);

      viewModel.updateChallenge(id: '1', challenge: testChallenge);

      expect(viewModel.state, equals(ChallengeState.loading()));
      verify(() => mockRepository.updateChallenge('1', testChallenge.toJson()))
          .called(1);
    });

    test('should emit loaded state with updated challenge on successful update',
        () async {
      when(() => mockRepository.updateChallenge(any(), any()))
          .thenAnswer((_) async => testChallenge);

      await viewModel.updateChallenge(id: '1', challenge: testChallenge);

      expect(viewModel.state,
          equals(ChallengeState.loaded(challenge: testChallenge)));
      verify(() => mockRepository.updateChallenge('1', testChallenge.toJson()))
          .called(1);
    });

    test('should emit error state when update fails', () async {
      when(() => mockRepository.updateChallenge(any(), any()))
          .thenThrow(Exception('Failed to update challenge'));

      await viewModel.updateChallenge(id: '1', challenge: testChallenge);

      expect(viewModel.state,
          equals(ChallengeState.error(message: 'Failed to update challenge')));
      verify(() => mockRepository.updateChallenge('1', testChallenge.toJson()))
          .called(1);
    });
  });

  group('deleteChallenge', () {
    test('should emit loading state while deleting', () async {
      when(() => mockRepository.deleteChallenge(any()))
          .thenAnswer((_) async {});

      viewModel.deleteChallenge(id: '1');

      expect(viewModel.state, equals(ChallengeState.loading()));
      verify(() => mockRepository.deleteChallenge('1')).called(1);
    });

    test('should emit initial state on successful deletion', () async {
      when(() => mockRepository.deleteChallenge(any()))
          .thenAnswer((_) async {});

      await viewModel.deleteChallenge(id: '1');

      expect(viewModel.state, equals(ChallengeState.initial()));
      verify(() => mockRepository.deleteChallenge('1')).called(1);
    });

    test('should emit error state when deletion fails', () async {
      when(() => mockRepository.deleteChallenge(any()))
          .thenThrow(Exception('Failed to delete challenge'));

      await viewModel.deleteChallenge(id: '1');

      expect(viewModel.state,
          equals(ChallengeState.error(message: 'Failed to delete challenge')));
      verify(() => mockRepository.deleteChallenge('1')).called(1);
    });
  });
}
