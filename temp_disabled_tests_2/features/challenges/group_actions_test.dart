// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';

// Mock classes
class MockChallengeRepository extends Mock implements ChallengeRepository {}
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestList> {}
class MockPostgrestSingleFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestMap> {}

void main() {
  late ChallengeRepository mockRepository;
  late ChallengeGroupViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockSupabaseClient mockClient;

  const testGroupId = 'group-456';
  const testChallengeId = 'challenge-123';
  const testUserId = 'user-123';

  final testGroup = ChallengeGroup(
    id: testGroupId,
    name: 'Test Group',
    description: 'Test Description',
    challengeId: testChallengeId,
    creatorId: testUserId,
    memberIds: [testUserId, 'user-456'],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  final updatedGroup = ChallengeGroup(
    id: testGroupId,
    name: 'Updated Group Name',
    description: 'Updated Description',
    challengeId: testChallengeId,
    creatorId: testUserId,
    memberIds: [testUserId, 'user-456'],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  setUp(() {
    mockRepository = MockChallengeRepository();
    mockAuthRepository = MockAuthRepository();
    mockClient = MockSupabaseClient();

    // Create the view model with mocked dependencies
    viewModel = ChallengeGroupViewModel(mockRepository, mockAuthRepository, mockClient);

    // Standard setup for auth
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => User(id: testUserId, email: 'test@example.com'));
  });

  group('updateGroup', () {
    test('should successfully update group details', () async {
      // Arrange
      when(() => mockRepository.updateGroup(any())).thenAnswer((_) async {});
      when(() => mockRepository.getGroupById(testGroupId)).thenAnswer((_) async => updatedGroup);
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.updateGroup(updatedGroup);

      // Assert
      expect(viewModel.state.selectedGroup?.name, 'Updated Group Name');
      expect(viewModel.state.selectedGroup?.description, 'Updated Description');
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, null);
      
      // Verify repository calls
      verify(() => mockRepository.updateGroup(any())).called(1);
      verify(() => mockRepository.getGroupById(testGroupId)).called(1);
    });

    test('should handle database errors during update', () async {
      // Arrange
      when(() => mockRepository.updateGroup(any()))
          .thenThrow(DatabaseException(message: 'Database error during update'));
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.updateGroup(updatedGroup);

      // Assert
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.selectedGroup, testGroup); // Should preserve old group data
      
      // Verify repository calls
      verify(() => mockRepository.updateGroup(any())).called(1);
      verifyNever(() => mockRepository.getGroupById(any()));
    });

    test('should handle permission errors during update', () async {
      // Arrange
      when(() => mockRepository.updateGroup(any()))
          .thenThrow(const ForbiddenException(message: 'Not enough permissions'));
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.updateGroup(updatedGroup);

      // Assert
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.error?.contains('permission'), isTrue);
      expect(viewModel.state.isLoading, false);
      
      // Verify repository calls
      verify(() => mockRepository.updateGroup(any())).called(1);
    });

    test('should validate group data before update', () async {
      // Arrange - Create invalid group with empty name
      final invalidGroup = ChallengeGroup(
        id: testGroupId,
        name: '', // Empty name - should be invalid
        description: 'Test Description',
        challengeId: testChallengeId,
        creatorId: testUserId,
        memberIds: [testUserId],
        createdAt: DateTime.now(),
      );
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.updateGroup(invalidGroup);

      // Assert
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.error?.contains('name'), isTrue);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.selectedGroup, testGroup); // Should preserve old group data
      
      // Verify repository calls - shouldn't call update with invalid data
      verifyNever(() => mockRepository.updateGroup(any()));
    });
  });

  group('deleteGroup', () {
    test('should successfully delete a group', () async {
      // Arrange
      when(() => mockRepository.deleteGroup(testGroupId)).thenAnswer((_) async {});
      
      final initialGroups = [testGroup, ChallengeGroup(
        id: 'other-group-id',
        name: 'Other Group',
        challengeId: testChallengeId,
        creatorId: testUserId,
        memberIds: [testUserId],
        createdAt: DateTime.now(),
      )];
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: initialGroups,
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.deleteGroup(testGroupId);

      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, null);
      expect(viewModel.state.selectedGroup, isNull); // Selected group should be cleared
      expect(viewModel.state.groups.length, 1); // One group should be removed
      expect(viewModel.state.groups[0].id, 'other-group-id');
      
      // Verify repository calls
      verify(() => mockRepository.deleteGroup(testGroupId)).called(1);
    });

    test('should handle database errors during delete', () async {
      // Arrange
      when(() => mockRepository.deleteGroup(testGroupId))
          .thenThrow(DatabaseException(message: 'Database error during delete'));
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.deleteGroup(testGroupId);

      // Assert
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.groups.length, 1); // Group should still be in the list
      
      // Verify repository calls
      verify(() => mockRepository.deleteGroup(testGroupId)).called(1);
    });

    test('should handle permission errors during delete', () async {
      // Arrange
      when(() => mockRepository.deleteGroup(testGroupId))
          .thenThrow(const ForbiddenException(message: 'Only group creator can delete'));
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.deleteGroup(testGroupId);

      // Assert
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.error?.contains('permission'), isTrue);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.groups.length, 1); // Group should still be in the list
      
      // Verify repository calls
      verify(() => mockRepository.deleteGroup(testGroupId)).called(1);
    });

    test('should handle attempt to delete non-existent group', () async {
      // Arrange
      const nonExistentGroupId = 'non-existent-group';
      when(() => mockRepository.deleteGroup(nonExistentGroupId))
          .thenThrow(ResourceNotFoundException(message: 'Group not found'));
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup,
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.deleteGroup(nonExistentGroupId);

      // Assert
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.error?.contains('not found'), isTrue);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.groups.length, 1); // Group list should remain unchanged
      
      // Verify repository calls
      verify(() => mockRepository.deleteGroup(nonExistentGroupId)).called(1);
    });
    
    test('should clear selectedGroup when deleting the currently selected group', () async {
      // Arrange
      when(() => mockRepository.deleteGroup(testGroupId)).thenAnswer((_) async {});
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup],
        selectedGroup: testGroup, // This is the group we're deleting
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.deleteGroup(testGroupId);

      // Assert
      expect(viewModel.state.selectedGroup, isNull); // Selected group should be cleared
      expect(viewModel.state.groups, isEmpty); // Groups should be empty
      
      // Verify repository calls
      verify(() => mockRepository.deleteGroup(testGroupId)).called(1);
    });
    
    test('should keep selectedGroup when deleting a different group', () async {
      // Arrange
      const otherGroupId = 'other-group-id';
      when(() => mockRepository.deleteGroup(otherGroupId)).thenAnswer((_) async {});
      
      final otherGroup = ChallengeGroup(
        id: otherGroupId,
        name: 'Other Group',
        challengeId: testChallengeId,
        creatorId: testUserId,
        memberIds: [testUserId],
        createdAt: DateTime.now(),
      );
      
      // Setup initial state
      viewModel.state = ChallengeGroupState.success(
        groups: [testGroup, otherGroup],
        selectedGroup: testGroup, // We're keeping this one
        pendingInvites: [],
        groupRanking: [],
      );

      // Act
      await viewModel.deleteGroup(otherGroupId); // Deleting the other group

      // Assert
      expect(viewModel.state.selectedGroup, testGroup); // Selected group should remain
      expect(viewModel.state.groups.length, 1); // Only one group should remain
      expect(viewModel.state.groups[0].id, testGroupId);
      
      // Verify repository calls
      verify(() => mockRepository.deleteGroup(otherGroupId)).called(1);
    });
  });
} 