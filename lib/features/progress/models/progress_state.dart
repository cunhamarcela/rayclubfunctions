import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';

part 'progress_state.freezed.dart';

@freezed
class ProgressState with _$ProgressState {
  const factory ProgressState({
    required bool isLoading,
    required bool isLoadingStreak,
    required bool isLoadingCount,
    required bool isLoadingWorkouts,
    required List<Workout> workouts,
    required DateTime selectedDate,
    required int currentStreak,
    required int workoutCount,
    UserProgress? userProgress,
    AppException? error,
    AppException? streakError,
    AppException? countError,
  }) = _ProgressState;

  factory ProgressState.initial() => ProgressState(
        isLoading: false,
        isLoadingStreak: false,
        isLoadingCount: false,
        isLoadingWorkouts: false,
        workouts: const [],
        selectedDate: DateTime.now(),
        currentStreak: 0,
        workoutCount: 0,
        userProgress: null,
        error: null,
        streakError: null,
        countError: null,
      );
} 