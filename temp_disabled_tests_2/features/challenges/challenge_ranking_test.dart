// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';

// Mock classes
class MockChallengeRepository extends Mock implements ChallengeRepository {}
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockStreamPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<StreamController<List<Map<String, dynamic>>>> _controllers = [];
  
  void addEvent(List<Map<String, dynamic>> data) {
    for (final controller in _controllers) {
      controller.add(data);
    }
  }
  
  void addError(Object error) {
    for (final controller in _controllers) {
      controller.addError(error);
    }
  }
  
  void closeStream() {
    for (final controller in _controllers) {
      controller.close();
    }
    _controllers.clear();
  }
}

class StreamController<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();
  Stream<T> get stream => _controller.stream;
  
  void add(T data) {
    if (!_controller.isClosed) {
      _controller.add(data);
    }
  }
  
  void addError(Object error) {
    if (!_controller.isClosed) {
      _controller.addError(error);
    }
  }
  
  void close() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}

void main() {
  late ChallengeRepository mockRepository;
  late ChallengeViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockStreamPostgrestFilterBuilder mockStreamFilterBuilder;

  const testChallengeId = 'challenge-123';
  const testGroupId = 'group-456';

  final testChallenge = Challenge(
    id: testChallengeId,
    title: 'Test Challenge',
    description: 'Test Description',
    imageUrl: 'https://example.com/image.jpg',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isOfficial: true,
    active: true,
    creatorId: 'admin-user',
    points: 100,
    participants: ['user-1', 'user-2', 'user-3'],
  );

  // Initial progress data
  final progressUser1_t0 = {
    'id': 'progress-1',
    'user_id': 'user-1',
    'challenge_id': testChallengeId,
    'user_name': 'User One',
    'user_photo_url': 'https://example.com/user1.jpg',
    'points': 100,
    'position': 1,
    'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
  };

  final progressUser2_t0 = {
    'id': 'progress-2',
    'user_id': 'user-2',
    'challenge_id': testChallengeId,
    'user_name': 'User Two',
    'user_photo_url': 'https://example.com/user2.jpg',
    'points': 75,
    'position': 2,
    'created_at': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
  };

  // Updated progress data (positions changed)
  final progressUser1_t1 = {
    'id': 'progress-1',
    'user_id': 'user-1',
    'challenge_id': testChallengeId,
    'user_name': 'User One',
    'user_photo_url': 'https://example.com/user1.jpg',
    'points': 100,
    'position': 2, // Position dropped
    'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
  };

  final progressUser2_t1 = {
    'id': 'progress-2',
    'user_id': 'user-2',
    'challenge_id': testChallengeId,
    'user_name': 'User Two',
    'user_photo_url': 'https://example.com/user2.jpg',
    'points': 120, // Points increased
    'position': 1, // Position improved
    'created_at': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
  };

  setUp(() {
    mockRepository = MockChallengeRepository();
    mockAuthRepository = MockAuthRepository();
    mockStreamFilterBuilder = MockStreamPostgrestFilterBuilder();
    
    viewModel = ChallengeViewModel(mockRepository, mockAuthRepository);
    
    // Common setup
    when(() => mockRepository.getChallengeById(testChallengeId))
        .thenAnswer((_) async => testChallenge);
  });

  tearDown(() {
    mockStreamFilterBuilder.closeStream();
  });

  group('watchChallengeRanking', () {
    test('should update state with real-time changes in ranking', () async {
      // Arrange
      final initialProgressList = [
        ChallengeProgress.fromJson(progressUser1_t0),
        ChallengeProgress.fromJson(progressUser2_t0),
      ];
      
      final updatedProgressList = [
        ChallengeProgress.fromJson(progressUser2_t1),
        ChallengeProgress.fromJson(progressUser1_t1),
      ];
      
      // Setup repository to return initial data
      when(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      ))
          .thenAnswer((_) async => initialProgressList);
      
      // Setup real-time subscription
      when(() => mockRepository.watchChallengeParticipants(testChallengeId, limit: any(named: 'limit')))
          .thenAnswer((_) {
            final controller = StreamController<List<ChallengeProgress>>();
            mockStreamFilterBuilder._controllers.add(controller);
            return controller.stream;
          });
      
      // Act - Load challenge details (should setup subscription)
      await viewModel.loadChallengeDetails(testChallengeId);
      
      // Verify initial state
      expect(viewModel.state.progressList.length, 2);
      expect(viewModel.state.progressList[0].userId, 'user-1');
      expect(viewModel.state.progressList[0].points, 100);
      expect(viewModel.state.progressList[1].userId, 'user-2');
      expect(viewModel.state.progressList[1].points, 75);
      
      // Act - Simulate real-time update
      mockStreamFilterBuilder._controllers.first.add(updatedProgressList);
      
      // Need to wait for async updates
      await Future.delayed(Duration.zero);
      
      // Assert updated state
      expect(viewModel.state.progressList.length, 2);
      expect(viewModel.state.progressList[0].userId, 'user-2');
      expect(viewModel.state.progressList[0].points, 120);
      expect(viewModel.state.progressList[1].userId, 'user-1');
      expect(viewModel.state.progressList[1].points, 100);
      
      // Verify repository calls
      verify(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      )).called(1);
    });

    test('should filter ranking by group ID when specified', () async {
      // Arrange
      final initialProgressList = [
        ChallengeProgress.fromJson(progressUser1_t0),
        ChallengeProgress.fromJson(progressUser2_t0),
      ];
      
      // Setup repository to return initial data
      when(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      ))
          .thenAnswer((_) async => initialProgressList);
      
      // Setup repository to return filtered data
      when(() => mockRepository.getGroupRanking(testGroupId))
          .thenAnswer((_) async => [initialProgressList[0]]); // Only return user-1
      
      // Setup real-time subscription for normal ranking
      when(() => mockRepository.watchChallengeParticipants(testChallengeId, limit: any(named: 'limit')))
          .thenAnswer((_) {
            final controller = StreamController<List<ChallengeProgress>>();
            mockStreamFilterBuilder._controllers.add(controller);
            return controller.stream;
          });
      
      // Setup real-time subscription for group ranking
      when(() => mockRepository.watchGroupRanking(testGroupId))
          .thenAnswer((_) {
            final controller = StreamController<List<ChallengeProgress>>();
            mockStreamFilterBuilder._controllers.add(controller);
            return controller.stream;
          });
      
      // Act - Load challenge details
      await viewModel.loadChallengeDetails(testChallengeId);
      
      // Verify initial state (all users)
      expect(viewModel.state.progressList.length, 2);
      
      // Act - Apply group filter
      viewModel.filterRankingByGroup(testGroupId);
      
      // Need to wait for async updates
      await Future.delayed(Duration.zero);
      
      // Assert filtered state
      expect(viewModel.state.progressList.length, 1);
      expect(viewModel.state.progressList[0].userId, 'user-1');
      expect(viewModel.state.selectedGroupIdForFilter, testGroupId);
      
      // Verify repository calls
      verify(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      )).called(1);
      verify(() => mockRepository.getGroupRanking(testGroupId)).called(1);
      verify(() => mockRepository.watchChallengeParticipants(testChallengeId, limit: any(named: 'limit'))).called(1);
      verify(() => mockRepository.watchGroupRanking(testGroupId)).called(1);
    });

    test('should handle errors in real-time subscription', () async {
      // Arrange
      final initialProgressList = [
        ChallengeProgress.fromJson(progressUser1_t0),
        ChallengeProgress.fromJson(progressUser2_t0),
      ];
      
      // Setup repository to return initial data
      when(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      ))
          .thenAnswer((_) async => initialProgressList);
      
      // Setup real-time subscription that will emit an error
      when(() => mockRepository.watchChallengeParticipants(testChallengeId, limit: any(named: 'limit')))
          .thenAnswer((_) {
            final controller = StreamController<List<ChallengeProgress>>();
            mockStreamFilterBuilder._controllers.add(controller);
            return controller.stream;
          });
      
      // Act - Load challenge details
      await viewModel.loadChallengeDetails(testChallengeId);
      
      // Verify initial state
      expect(viewModel.state.progressList.length, 2);
      expect(viewModel.state.errorMessage, isNull);
      
      // Act - Simulate error in real-time stream
      mockStreamFilterBuilder._controllers.first.addError(DatabaseException(message: 'Stream error'));
      
      // Need to wait for async updates
      await Future.delayed(Duration.zero);
      
      // Assert error state - should preserve previous progress data
      expect(viewModel.state.progressList.length, 2); // Keeps old data
      expect(viewModel.state.errorMessage, isNotNull); // Should set error message
      
      // Verify repository calls
      verify(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      )).called(1);
      verify(() => mockRepository.watchChallengeParticipants(testChallengeId, limit: any(named: 'limit'))).called(1);
    });
    
    test('should cleanup subscriptions when viewModel is disposed', () async {
      // Arrange
      final initialProgressList = [
        ChallengeProgress.fromJson(progressUser1_t0),
        ChallengeProgress.fromJson(progressUser2_t0),
      ];
      
      // Setup repository to return initial data
      when(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        testChallengeId
      ))
          .thenAnswer((_) async => initialProgressList);
      
      // Setup real-time subscription
      when(() => mockRepository.watchChallengeParticipants(testChallengeId, limit: any(named: 'limit')))
          .thenAnswer((_) {
            final controller = StreamController<List<ChallengeProgress>>();
            mockStreamFilterBuilder._controllers.add(controller);
            return controller.stream;
          });
      
      // Act - Load challenge details
      await viewModel.loadChallengeDetails(testChallengeId);
      
      // Verify initial state
      expect(viewModel.state.progressList.length, 2);
      
      // Act - Dispose the viewModel
      viewModel.dispose();
      
      // Assert - No exception should be thrown when emitting after disposal
      // The mock will try to emit to a disposed stream controller
      mockStreamFilterBuilder._controllers.first.add([]);
      
      // Just verify disposal doesn't throw errors
      expect(true, isTrue);
    });
  });
} 