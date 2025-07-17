// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProgressState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingStreak => throw _privateConstructorUsedError;
  bool get isLoadingCount => throw _privateConstructorUsedError;
  bool get isLoadingWorkouts => throw _privateConstructorUsedError;
  List<Workout> get workouts => throw _privateConstructorUsedError;
  DateTime get selectedDate => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get workoutCount => throw _privateConstructorUsedError;
  UserProgress? get userProgress => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;
  AppException? get streakError => throw _privateConstructorUsedError;
  AppException? get countError => throw _privateConstructorUsedError;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressStateCopyWith<ProgressState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressStateCopyWith<$Res> {
  factory $ProgressStateCopyWith(
          ProgressState value, $Res Function(ProgressState) then) =
      _$ProgressStateCopyWithImpl<$Res, ProgressState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoadingStreak,
      bool isLoadingCount,
      bool isLoadingWorkouts,
      List<Workout> workouts,
      DateTime selectedDate,
      int currentStreak,
      int workoutCount,
      UserProgress? userProgress,
      AppException? error,
      AppException? streakError,
      AppException? countError});

  $UserProgressCopyWith<$Res>? get userProgress;
}

/// @nodoc
class _$ProgressStateCopyWithImpl<$Res, $Val extends ProgressState>
    implements $ProgressStateCopyWith<$Res> {
  _$ProgressStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingStreak = null,
    Object? isLoadingCount = null,
    Object? isLoadingWorkouts = null,
    Object? workouts = null,
    Object? selectedDate = null,
    Object? currentStreak = null,
    Object? workoutCount = null,
    Object? userProgress = freezed,
    Object? error = freezed,
    Object? streakError = freezed,
    Object? countError = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingStreak: null == isLoadingStreak
          ? _value.isLoadingStreak
          : isLoadingStreak // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingCount: null == isLoadingCount
          ? _value.isLoadingCount
          : isLoadingCount // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingWorkouts: null == isLoadingWorkouts
          ? _value.isLoadingWorkouts
          : isLoadingWorkouts // ignore: cast_nullable_to_non_nullable
              as bool,
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<Workout>,
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      userProgress: freezed == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as UserProgress?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppException?,
      streakError: freezed == streakError
          ? _value.streakError
          : streakError // ignore: cast_nullable_to_non_nullable
              as AppException?,
      countError: freezed == countError
          ? _value.countError
          : countError // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ) as $Val);
  }

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProgressCopyWith<$Res>? get userProgress {
    if (_value.userProgress == null) {
      return null;
    }

    return $UserProgressCopyWith<$Res>(_value.userProgress!, (value) {
      return _then(_value.copyWith(userProgress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgressStateImplCopyWith<$Res>
    implements $ProgressStateCopyWith<$Res> {
  factory _$$ProgressStateImplCopyWith(
          _$ProgressStateImpl value, $Res Function(_$ProgressStateImpl) then) =
      __$$ProgressStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoadingStreak,
      bool isLoadingCount,
      bool isLoadingWorkouts,
      List<Workout> workouts,
      DateTime selectedDate,
      int currentStreak,
      int workoutCount,
      UserProgress? userProgress,
      AppException? error,
      AppException? streakError,
      AppException? countError});

  @override
  $UserProgressCopyWith<$Res>? get userProgress;
}

/// @nodoc
class __$$ProgressStateImplCopyWithImpl<$Res>
    extends _$ProgressStateCopyWithImpl<$Res, _$ProgressStateImpl>
    implements _$$ProgressStateImplCopyWith<$Res> {
  __$$ProgressStateImplCopyWithImpl(
      _$ProgressStateImpl _value, $Res Function(_$ProgressStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingStreak = null,
    Object? isLoadingCount = null,
    Object? isLoadingWorkouts = null,
    Object? workouts = null,
    Object? selectedDate = null,
    Object? currentStreak = null,
    Object? workoutCount = null,
    Object? userProgress = freezed,
    Object? error = freezed,
    Object? streakError = freezed,
    Object? countError = freezed,
  }) {
    return _then(_$ProgressStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingStreak: null == isLoadingStreak
          ? _value.isLoadingStreak
          : isLoadingStreak // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingCount: null == isLoadingCount
          ? _value.isLoadingCount
          : isLoadingCount // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingWorkouts: null == isLoadingWorkouts
          ? _value.isLoadingWorkouts
          : isLoadingWorkouts // ignore: cast_nullable_to_non_nullable
              as bool,
      workouts: null == workouts
          ? _value._workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<Workout>,
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      userProgress: freezed == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as UserProgress?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppException?,
      streakError: freezed == streakError
          ? _value.streakError
          : streakError // ignore: cast_nullable_to_non_nullable
              as AppException?,
      countError: freezed == countError
          ? _value.countError
          : countError // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ));
  }
}

/// @nodoc

class _$ProgressStateImpl implements _ProgressState {
  const _$ProgressStateImpl(
      {required this.isLoading,
      required this.isLoadingStreak,
      required this.isLoadingCount,
      required this.isLoadingWorkouts,
      required final List<Workout> workouts,
      required this.selectedDate,
      required this.currentStreak,
      required this.workoutCount,
      this.userProgress,
      this.error,
      this.streakError,
      this.countError})
      : _workouts = workouts;

  @override
  final bool isLoading;
  @override
  final bool isLoadingStreak;
  @override
  final bool isLoadingCount;
  @override
  final bool isLoadingWorkouts;
  final List<Workout> _workouts;
  @override
  List<Workout> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  @override
  final DateTime selectedDate;
  @override
  final int currentStreak;
  @override
  final int workoutCount;
  @override
  final UserProgress? userProgress;
  @override
  final AppException? error;
  @override
  final AppException? streakError;
  @override
  final AppException? countError;

  @override
  String toString() {
    return 'ProgressState(isLoading: $isLoading, isLoadingStreak: $isLoadingStreak, isLoadingCount: $isLoadingCount, isLoadingWorkouts: $isLoadingWorkouts, workouts: $workouts, selectedDate: $selectedDate, currentStreak: $currentStreak, workoutCount: $workoutCount, userProgress: $userProgress, error: $error, streakError: $streakError, countError: $countError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingStreak, isLoadingStreak) ||
                other.isLoadingStreak == isLoadingStreak) &&
            (identical(other.isLoadingCount, isLoadingCount) ||
                other.isLoadingCount == isLoadingCount) &&
            (identical(other.isLoadingWorkouts, isLoadingWorkouts) ||
                other.isLoadingWorkouts == isLoadingWorkouts) &&
            const DeepCollectionEquality().equals(other._workouts, _workouts) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.userProgress, userProgress) ||
                other.userProgress == userProgress) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.streakError, streakError) ||
                other.streakError == streakError) &&
            (identical(other.countError, countError) ||
                other.countError == countError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isLoadingStreak,
      isLoadingCount,
      isLoadingWorkouts,
      const DeepCollectionEquality().hash(_workouts),
      selectedDate,
      currentStreak,
      workoutCount,
      userProgress,
      error,
      streakError,
      countError);

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressStateImplCopyWith<_$ProgressStateImpl> get copyWith =>
      __$$ProgressStateImplCopyWithImpl<_$ProgressStateImpl>(this, _$identity);
}

abstract class _ProgressState implements ProgressState {
  const factory _ProgressState(
      {required final bool isLoading,
      required final bool isLoadingStreak,
      required final bool isLoadingCount,
      required final bool isLoadingWorkouts,
      required final List<Workout> workouts,
      required final DateTime selectedDate,
      required final int currentStreak,
      required final int workoutCount,
      final UserProgress? userProgress,
      final AppException? error,
      final AppException? streakError,
      final AppException? countError}) = _$ProgressStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isLoadingStreak;
  @override
  bool get isLoadingCount;
  @override
  bool get isLoadingWorkouts;
  @override
  List<Workout> get workouts;
  @override
  DateTime get selectedDate;
  @override
  int get currentStreak;
  @override
  int get workoutCount;
  @override
  UserProgress? get userProgress;
  @override
  AppException? get error;
  @override
  AppException? get streakError;
  @override
  AppException? get countError;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressStateImplCopyWith<_$ProgressStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
