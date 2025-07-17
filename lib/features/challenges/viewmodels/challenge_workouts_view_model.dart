import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/workout_record_with_user.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';

/// State class for challenge workouts
class ChallengeWorkoutsState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<WorkoutRecordWithUser> workoutRecords;
  final Map<String, List<WorkoutRecordWithUser>> workoutsByUser;
  final int totalRecords;
  final int currentPage;
  final int recordsPerPage;
  final bool hasMoreRecords;
  final bool isCached;

  ChallengeWorkoutsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.workoutRecords = const [],
    this.workoutsByUser = const {},
    this.totalRecords = 0,
    this.currentPage = 0,
    this.recordsPerPage = 20,
    this.hasMoreRecords = false,
    this.isCached = false,
  });

  /// Creates a copy of this state with the given fields replaced
  ChallengeWorkoutsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    List<WorkoutRecordWithUser>? workoutRecords,
    Map<String, List<WorkoutRecordWithUser>>? workoutsByUser,
    int? totalRecords,
    int? currentPage,
    int? recordsPerPage,
    bool? hasMoreRecords,
    bool? isCached,
  }) {
    return ChallengeWorkoutsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      workoutRecords: workoutRecords ?? this.workoutRecords,
      workoutsByUser: workoutsByUser ?? this.workoutsByUser,
      totalRecords: totalRecords ?? this.totalRecords,
      currentPage: currentPage ?? this.currentPage,
      recordsPerPage: recordsPerPage ?? this.recordsPerPage,
      hasMoreRecords: hasMoreRecords ?? this.hasMoreRecords,
      isCached: isCached ?? this.isCached,
    );
  }
}

/// ViewModel for managing challenge workout records
class ChallengeWorkoutsViewModel extends StateNotifier<ChallengeWorkoutsState> {
  final ChallengeRepository _repository;
  String? _lastLoadedChallengeId;

  ChallengeWorkoutsViewModel(this._repository) : super(ChallengeWorkoutsState());

  /// Loads workout records for a challenge and groups them by user
  Future<void> loadChallengeWorkouts(String challengeId, {bool refresh = false}) async {
    // Reset state if refreshing or loading a different challenge
    if (refresh || challengeId != _lastLoadedChallengeId) {
      state = ChallengeWorkoutsState(isLoading: true);
      _lastLoadedChallengeId = challengeId;
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      // Get total count first if needed
      if (state.totalRecords == 0) {
        final totalCount = await _repository.getChallengeWorkoutsCount(challengeId);
        state = state.copyWith(totalRecords: totalCount);
      }
      
      final offset = refresh ? 0 : state.currentPage * state.recordsPerPage;
      
      // Load workouts with pagination
      final workoutRecords = await _repository.getChallengeWorkoutRecords(
        challengeId,
        limit: state.recordsPerPage,
        offset: offset,
        useCache: !refresh, // Don't use cache when refreshing
      );
      
      // Group workouts by user
      final Map<String, List<WorkoutRecordWithUser>> workoutsByUser;
      
      if (refresh) {
        // If refreshing, replace all workouts
        workoutsByUser = groupBy(
          workoutRecords, 
          (WorkoutRecordWithUser workout) => workout.userId
        );
      } else {
        // If loading more, merge with existing workouts
        final allWorkouts = [...state.workoutRecords, ...workoutRecords];
        workoutsByUser = groupBy(
          allWorkouts, 
          (WorkoutRecordWithUser workout) => workout.userId
        );
      }

      // Calculate if there are more records to load
      final hasMore = state.totalRecords > (offset + workoutRecords.length);

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        workoutRecords: refresh 
            ? workoutRecords 
            : [...state.workoutRecords, ...workoutRecords],
        workoutsByUser: workoutsByUser,
        currentPage: refresh ? 0 : state.currentPage + 1,
        hasMoreRecords: hasMore,
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar treinos do desafio: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Falha ao carregar os treinos: $e',
      );
    }
  }

  /// Loads the next page of workout records
  Future<void> loadMoreWorkouts(String challengeId) async {
    if (state.isLoadingMore || !state.hasMoreRecords) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    
    try {
      final offset = state.currentPage * state.recordsPerPage;
      
      final workoutRecords = await _repository.getChallengeWorkoutRecords(
        challengeId,
        limit: state.recordsPerPage,
        offset: offset,
      );
      
      // Merge with existing workouts
      final allWorkouts = [...state.workoutRecords, ...workoutRecords];
      final workoutsByUser = groupBy(
        allWorkouts, 
        (WorkoutRecordWithUser workout) => workout.userId
      );
      
      // Calculate if there are more records to load
      final hasMore = state.totalRecords > (offset + workoutRecords.length);

      state = state.copyWith(
        isLoadingMore: false,
        workoutRecords: allWorkouts,
        workoutsByUser: workoutsByUser,
        currentPage: state.currentPage + 1,
        hasMoreRecords: hasMore,
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar mais treinos: $e');
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Falha ao carregar mais treinos: $e',
      );
    }
  }
  
  /// Refreshes workout records from the server
  Future<void> refreshWorkouts(String challengeId) async {
    await loadChallengeWorkouts(challengeId, refresh: true);
  }
}

/// Provider for the ChallengeWorkoutsViewModel
final challengeWorkoutsViewModelProvider = StateNotifierProvider<ChallengeWorkoutsViewModel, ChallengeWorkoutsState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  return ChallengeWorkoutsViewModel(repository);
}); 