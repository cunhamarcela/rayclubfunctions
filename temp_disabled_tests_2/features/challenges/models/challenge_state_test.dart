import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_state.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';

void main() {
  group('ChallengeState', () {
    test('Initial state should have expected default values', () {
      final state = ChallengeState.initial();
      
      expect(state.challenges, isEmpty);
      expect(state.filteredChallenges, isEmpty);
      expect(state.selectedChallenge, isNull);
      expect(state.pendingInvites, isEmpty);
      expect(state.progressList, isEmpty);
      expect(state.userProgress, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
      expect(state.officialChallenge, isNull);
      expect(state.selectedGroupIdForFilter, isNull);
    });
    
    test('Loading state should set isLoading to true', () {
      final state = ChallengeState.loading();
      
      expect(state.isLoading, true);
    });
    
    test('Success state should set success message and data', () {
      const String successMessage = 'Operation successful';
      final challenge = Challenge(
        id: '1', 
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
        creatorId: 'user_123',
        points: 100,
        createdAt: DateTime.now(),
      );
      
      final state = ChallengeState.success(
        challenges: [challenge],
        filteredChallenges: [challenge],
        selectedChallenge: challenge,
        message: successMessage,
      );
      
      expect(state.isLoading, false);
      expect(state.challenges, hasLength(1));
      expect(state.filteredChallenges, hasLength(1));
      expect(state.selectedChallenge, equals(challenge));
      expect(state.successMessage, equals(successMessage));
      expect(state.errorMessage, isNull);
    });
    
    test('Error state should set error message', () {
      const String errorMessage = 'Something went wrong';
      
      final state = ChallengeState.error(message: errorMessage);
      
      expect(state.isLoading, false);
      expect(state.errorMessage, equals(errorMessage));
      expect(state.successMessage, isNull);
    });
    
    test('CopyWith should correctly update fields', () {
      final initialState = ChallengeState.initial();
      
      final challenge = Challenge(
        id: '1', 
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
        creatorId: 'user_123',
        points: 100,
        createdAt: DateTime.now(),
      );
      
      final progress = ChallengeProgress(
        id: '1',
        userId: 'user1',
        challengeId: '1',
        points: 100,
        completionPercentage: 50.0,
        userName: 'Test User',
        position: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final updatedState = initialState.copyWith(
        challenges: [challenge],
        selectedChallenge: challenge,
        progressList: [progress],
        userProgress: progress,
        isLoading: true,
        selectedGroupIdForFilter: 'group1',
      );
      
      expect(updatedState.challenges, hasLength(1));
      expect(updatedState.selectedChallenge, equals(challenge));
      expect(updatedState.progressList, hasLength(1));
      expect(updatedState.userProgress, equals(progress));
      expect(updatedState.isLoading, true);
      expect(updatedState.selectedGroupIdForFilter, equals('group1'));
      
      // Test setting a value to null
      final stateWithNullChallenge = updatedState.copyWith(
        selectedChallenge: null,
      );
      
      expect(stateWithNullChallenge.selectedChallenge, isNull);
    });
  });
} 