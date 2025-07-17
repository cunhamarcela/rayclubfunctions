// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:ray_club_app/models/sub_challenge.dart';
import 'package:ray_club_app/repositories/sub_challenge_repository.dart';
import 'package:ray_club_app/services/storage_service.dart';
import 'package:ray_club_app/view_models/states/sub_challenge_state.dart';
import 'package:ray_club_app/view_models/sub_challenge_view_model.dart';

class MockSubChallengeRepository extends Mock
    implements ISubChallengeRepository {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockSubChallengeRepository mockRepository;
  late MockStorageService mockStorageService;
  late SubChallengeViewModel viewModel;
  late SubChallenge testSubChallenge;

  setUp(() {
    mockRepository = MockSubChallengeRepository();
    mockStorageService = MockStorageService();

    testSubChallenge = SubChallenge(
      id: '1',
      parentChallengeId: 'parent-123',
      creatorId: 'user-123',
      title: 'Test SubChallenge',
      description: 'Test Description',
      criteria: {'workout': 'daily'},
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: ['user-123', 'user-456'],
      status: SubChallengeStatus.active,
      validationRules: {'approval': 'automatic'},
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    viewModel = SubChallengeViewModel(
      subChallengeRepository: mockRepository,
      storageService: mockStorageService,
      subChallengeId: '1',
    );

    // Mock the repository methods
    when(() => mockRepository.getSubChallenge('1'))
        .thenAnswer((_) async => testSubChallenge);
  });

  group('initialize', () {
    test('should set state to loaded when getSubChallenge succeeds', () async {
      // Arrange - done in setUp

      // Act
      await viewModel.initialize('1');

      // Assert
      expect(viewModel.state,
          equals(SubChallengeState.loaded(subChallenge: testSubChallenge)));
      verify(() => mockRepository.getSubChallenge('1')).called(1);
    });

    test('should set state to error when getSubChallenge fails', () async {
      // Arrange
      when(() => mockRepository.getSubChallenge('1'))
          .thenThrow(Exception('Failed to load sub-challenge'));

      // Act
      await viewModel.initialize('1');

      // Assert
      expect(
        viewModel.state,
        equals(SubChallengeState.error(
            message: 'Exception: Failed to load sub-challenge')),
      );
      verify(() => mockRepository.getSubChallenge('1')).called(1);
    });
  });

  group('updateSubChallenge', () {
    test('should set state to loaded when updateSubChallenge succeeds',
        () async {
      // Arrange
      final updatedSubChallenge = testSubChallenge.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );

      when(() => mockRepository.updateSubChallenge(
            '1',
            any(),
          )).thenAnswer((_) async => updatedSubChallenge);

      // Act
      await viewModel.updateSubChallenge(
        id: '1',
        subChallenge: updatedSubChallenge,
      );

      // Assert
      expect(viewModel.state,
          equals(SubChallengeState.loaded(subChallenge: updatedSubChallenge)));
      verify(() => mockRepository.updateSubChallenge('1', any())).called(1);
    });

    test('should set state to error when updateSubChallenge fails', () async {
      // Arrange
      when(() => mockRepository.updateSubChallenge('1', any()))
          .thenThrow(Exception('Failed to update sub-challenge'));

      // Act
      await viewModel.updateSubChallenge(
        id: '1',
        subChallenge: testSubChallenge,
      );

      // Assert
      expect(
        viewModel.state,
        equals(SubChallengeState.error(
            message: 'Exception: Failed to update sub-challenge')),
      );
      verify(() => mockRepository.updateSubChallenge('1', any())).called(1);
    });
  });
}
