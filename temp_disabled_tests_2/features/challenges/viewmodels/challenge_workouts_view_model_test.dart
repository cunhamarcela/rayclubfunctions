import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ray_club_app/features/challenges/models/workout_record_with_user.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';

import 'challenge_workouts_view_model_test.mocks.dart';

@GenerateMocks([ChallengeRepository])
void main() {
  late MockChallengeRepository mockRepository;
  late ProviderContainer container;
  
  setUp(() {
    mockRepository = MockChallengeRepository();
    container = ProviderContainer(
      overrides: [
        challengeRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
  });
  
  group('ChallengeWorkoutsViewModel', () {
    const testChallengeId = 'challenge-123';
    
    // Create test data
    final workoutRecords = List.generate(
      25,
      (i) => WorkoutRecordWithUser(
        id: 'workout-$i',
        userId: i < 15 ? 'user-1' : 'user-2', // First 15 from user-1, rest from user-2
        userName: i < 15 ? 'User One' : 'User Two',
        workoutName: 'Workout $i',
        workoutType: 'Running',
        date: DateTime(2023, 8, 15).subtract(Duration(days: i)),
        durationMinutes: 30 + i,
      ),
    );
    
    test('should load first page of workouts', () async {
      // Setup
      when(mockRepository.getChallengeWorkoutsCount(testChallengeId))
          .thenAnswer((_) async => 25);
          
      when(mockRepository.getChallengeWorkoutRecords(
        testChallengeId,
        limit: 20,
        offset: 0,
        useCache: true,
      )).thenAnswer((_) async => workoutRecords.sublist(0, 20));
      
      // Initial state
      expect(container.read(challengeWorkoutsViewModelProvider).workoutRecords.isEmpty, true);
      
      // Action
      await container.read(challengeWorkoutsViewModelProvider.notifier)
          .loadChallengeWorkouts(testChallengeId);
      
      // Verify
      final state = container.read(challengeWorkoutsViewModelProvider);
      expect(state.workoutRecords.length, 20);
      expect(state.hasMoreRecords, true);
      expect(state.isLoading, false);
      expect(state.currentPage, 1);
      
      // Verify workouts are grouped by user
      expect(state.workoutsByUser.length, 2);
      expect(state.workoutsByUser['user-1']?.length, 15);
      expect(state.workoutsByUser['user-2']?.length, 5);
    });
    
    test('should load more workouts when requested', () async {
      // Setup
      when(mockRepository.getChallengeWorkoutsCount(testChallengeId))
          .thenAnswer((_) async => 25);
          
      when(mockRepository.getChallengeWorkoutRecords(
        testChallengeId,
        limit: 20,
        offset: 0,
        useCache: true,
      )).thenAnswer((_) async => workoutRecords.sublist(0, 20));
      
      when(mockRepository.getChallengeWorkoutRecords(
        testChallengeId,
        limit: 20,
        offset: 20,
        useCache: true,
      )).thenAnswer((_) async => workoutRecords.sublist(20, 25));
      
      // Load first page
      await container.read(challengeWorkoutsViewModelProvider.notifier)
          .loadChallengeWorkouts(testChallengeId);
          
      // Load more
      await container.read(challengeWorkoutsViewModelProvider.notifier)
          .loadMoreWorkouts(testChallengeId);
      
      // Verify
      final state = container.read(challengeWorkoutsViewModelProvider);
      expect(state.workoutRecords.length, 25);
      expect(state.hasMoreRecords, false);
      expect(state.currentPage, 2);
    });
    
    test('should refresh workouts and reset pagination', () async {
      // Setup
      when(mockRepository.getChallengeWorkoutsCount(testChallengeId))
          .thenAnswer((_) async => 25);
          
      when(mockRepository.getChallengeWorkoutRecords(
        testChallengeId,
        limit: 20,
        offset: 0,
        useCache: true,
      )).thenAnswer((_) async => workoutRecords.sublist(0, 20));
      
      when(mockRepository.getChallengeWorkoutRecords(
        testChallengeId,
        limit: 20,
        offset: 0,
        useCache: false,
      )).thenAnswer((_) async => workoutRecords.sublist(0, 20));
      
      // Load first page
      await container.read(challengeWorkoutsViewModelProvider.notifier)
          .loadChallengeWorkouts(testChallengeId);
          
      // Update state to simulate pagination
      container.read(challengeWorkoutsViewModelProvider.notifier).loadChallengeWorkouts(testChallengeId);
      
      // Refresh
      await container.read(challengeWorkoutsViewModelProvider.notifier)
          .refreshWorkouts(testChallengeId);
      
      // Verify
      final state = container.read(challengeWorkoutsViewModelProvider);
      expect(state.currentPage, 0);
      
      // Verify cache was not used during refresh
      verify(mockRepository.getChallengeWorkoutRecords(
        testChallengeId,
        limit: 20,
        offset: 0,
        useCache: false,
      ));
    });
  });
} 