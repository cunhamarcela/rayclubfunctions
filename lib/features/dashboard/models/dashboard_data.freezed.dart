// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) {
  return _DashboardData.fromJson(json);
}

/// @nodoc
mixin _$DashboardData {
  /// Número total de treinos registrados
  @JsonKey(name: 'total_workouts')
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Duração total de treinos em minutos
  @JsonKey(name: 'total_duration')
  int get totalDuration => throw _privateConstructorUsedError;

  /// Número de dias treinados no mês atual
  @JsonKey(name: 'days_trained_this_month')
  int get daysTrainedThisMonth => throw _privateConstructorUsedError;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  @JsonKey(name: 'workouts_by_type')
  Map<String, dynamic> get workoutsByType => throw _privateConstructorUsedError;

  /// Lista de treinos recentes
  @JsonKey(name: 'recent_workouts')
  List<WorkoutPreview> get recentWorkouts => throw _privateConstructorUsedError;

  /// Progresso em desafios
  @JsonKey(name: 'challenge_progress')
  ChallengeProgress get challengeProgress => throw _privateConstructorUsedError;

  /// Data da última atualização dos dados
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
          DashboardData value, $Res Function(DashboardData) then) =
      _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_workouts') int totalWorkouts,
      @JsonKey(name: 'total_duration') int totalDuration,
      @JsonKey(name: 'days_trained_this_month') int daysTrainedThisMonth,
      @JsonKey(name: 'workouts_by_type') Map<String, dynamic> workoutsByType,
      @JsonKey(name: 'recent_workouts') List<WorkoutPreview> recentWorkouts,
      @JsonKey(name: 'challenge_progress') ChallengeProgress challengeProgress,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});

  $ChallengeProgressCopyWith<$Res> get challengeProgress;
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWorkouts = null,
    Object? totalDuration = null,
    Object? daysTrainedThisMonth = null,
    Object? workoutsByType = null,
    Object? recentWorkouts = null,
    Object? challengeProgress = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByType: null == workoutsByType
          ? _value.workoutsByType
          : workoutsByType // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      recentWorkouts: null == recentWorkouts
          ? _value.recentWorkouts
          : recentWorkouts // ignore: cast_nullable_to_non_nullable
              as List<WorkoutPreview>,
      challengeProgress: null == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgress,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeProgressCopyWith<$Res> get challengeProgress {
    return $ChallengeProgressCopyWith<$Res>(_value.challengeProgress, (value) {
      return _then(_value.copyWith(challengeProgress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
          _$DashboardDataImpl value, $Res Function(_$DashboardDataImpl) then) =
      __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_workouts') int totalWorkouts,
      @JsonKey(name: 'total_duration') int totalDuration,
      @JsonKey(name: 'days_trained_this_month') int daysTrainedThisMonth,
      @JsonKey(name: 'workouts_by_type') Map<String, dynamic> workoutsByType,
      @JsonKey(name: 'recent_workouts') List<WorkoutPreview> recentWorkouts,
      @JsonKey(name: 'challenge_progress') ChallengeProgress challengeProgress,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});

  @override
  $ChallengeProgressCopyWith<$Res> get challengeProgress;
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
      _$DashboardDataImpl _value, $Res Function(_$DashboardDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWorkouts = null,
    Object? totalDuration = null,
    Object? daysTrainedThisMonth = null,
    Object? workoutsByType = null,
    Object? recentWorkouts = null,
    Object? challengeProgress = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$DashboardDataImpl(
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByType: null == workoutsByType
          ? _value._workoutsByType
          : workoutsByType // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      recentWorkouts: null == recentWorkouts
          ? _value._recentWorkouts
          : recentWorkouts // ignore: cast_nullable_to_non_nullable
              as List<WorkoutPreview>,
      challengeProgress: null == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgress,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl(
      {@JsonKey(name: 'total_workouts') this.totalWorkouts = 0,
      @JsonKey(name: 'total_duration') this.totalDuration = 0,
      @JsonKey(name: 'days_trained_this_month') this.daysTrainedThisMonth = 0,
      @JsonKey(name: 'workouts_by_type')
      final Map<String, dynamic> workoutsByType = const {},
      @JsonKey(name: 'recent_workouts')
      final List<WorkoutPreview> recentWorkouts = const [],
      @JsonKey(name: 'challenge_progress') required this.challengeProgress,
      @JsonKey(name: 'last_updated') required this.lastUpdated})
      : _workoutsByType = workoutsByType,
        _recentWorkouts = recentWorkouts;

  factory _$DashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataImplFromJson(json);

  /// Número total de treinos registrados
  @override
  @JsonKey(name: 'total_workouts')
  final int totalWorkouts;

  /// Duração total de treinos em minutos
  @override
  @JsonKey(name: 'total_duration')
  final int totalDuration;

  /// Número de dias treinados no mês atual
  @override
  @JsonKey(name: 'days_trained_this_month')
  final int daysTrainedThisMonth;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  final Map<String, dynamic> _workoutsByType;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  @override
  @JsonKey(name: 'workouts_by_type')
  Map<String, dynamic> get workoutsByType {
    if (_workoutsByType is EqualUnmodifiableMapView) return _workoutsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workoutsByType);
  }

  /// Lista de treinos recentes
  final List<WorkoutPreview> _recentWorkouts;

  /// Lista de treinos recentes
  @override
  @JsonKey(name: 'recent_workouts')
  List<WorkoutPreview> get recentWorkouts {
    if (_recentWorkouts is EqualUnmodifiableListView) return _recentWorkouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentWorkouts);
  }

  /// Progresso em desafios
  @override
  @JsonKey(name: 'challenge_progress')
  final ChallengeProgress challengeProgress;

  /// Data da última atualização dos dados
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'DashboardData(totalWorkouts: $totalWorkouts, totalDuration: $totalDuration, daysTrainedThisMonth: $daysTrainedThisMonth, workoutsByType: $workoutsByType, recentWorkouts: $recentWorkouts, challengeProgress: $challengeProgress, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.daysTrainedThisMonth, daysTrainedThisMonth) ||
                other.daysTrainedThisMonth == daysTrainedThisMonth) &&
            const DeepCollectionEquality()
                .equals(other._workoutsByType, _workoutsByType) &&
            const DeepCollectionEquality()
                .equals(other._recentWorkouts, _recentWorkouts) &&
            (identical(other.challengeProgress, challengeProgress) ||
                other.challengeProgress == challengeProgress) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalWorkouts,
      totalDuration,
      daysTrainedThisMonth,
      const DeepCollectionEquality().hash(_workoutsByType),
      const DeepCollectionEquality().hash(_recentWorkouts),
      challengeProgress,
      lastUpdated);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataImplToJson(
      this,
    );
  }
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData(
      {@JsonKey(name: 'total_workouts') final int totalWorkouts,
      @JsonKey(name: 'total_duration') final int totalDuration,
      @JsonKey(name: 'days_trained_this_month') final int daysTrainedThisMonth,
      @JsonKey(name: 'workouts_by_type')
      final Map<String, dynamic> workoutsByType,
      @JsonKey(name: 'recent_workouts')
      final List<WorkoutPreview> recentWorkouts,
      @JsonKey(name: 'challenge_progress')
      required final ChallengeProgress challengeProgress,
      @JsonKey(name: 'last_updated')
      required final DateTime lastUpdated}) = _$DashboardDataImpl;

  factory _DashboardData.fromJson(Map<String, dynamic> json) =
      _$DashboardDataImpl.fromJson;

  /// Número total de treinos registrados
  @override
  @JsonKey(name: 'total_workouts')
  int get totalWorkouts;

  /// Duração total de treinos em minutos
  @override
  @JsonKey(name: 'total_duration')
  int get totalDuration;

  /// Número de dias treinados no mês atual
  @override
  @JsonKey(name: 'days_trained_this_month')
  int get daysTrainedThisMonth;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  @override
  @JsonKey(name: 'workouts_by_type')
  Map<String, dynamic> get workoutsByType;

  /// Lista de treinos recentes
  @override
  @JsonKey(name: 'recent_workouts')
  List<WorkoutPreview> get recentWorkouts;

  /// Progresso em desafios
  @override
  @JsonKey(name: 'challenge_progress')
  ChallengeProgress get challengeProgress;

  /// Data da última atualização dos dados
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutPreview _$WorkoutPreviewFromJson(Map<String, dynamic> json) {
  return _WorkoutPreview.fromJson(json);
}

/// @nodoc
mixin _$WorkoutPreview {
  /// ID único do treino
  String get id => throw _privateConstructorUsedError;

  /// Nome do treino
  @JsonKey(name: 'workout_name')
  String get workoutName => throw _privateConstructorUsedError;

  /// Tipo de treino (cardio, força, etc.)
  @JsonKey(name: 'workout_type')
  String get workoutType => throw _privateConstructorUsedError;

  /// Data de realização do treino
  DateTime get date => throw _privateConstructorUsedError;

  /// Duração do treino em minutos
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Serializes this WorkoutPreview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutPreviewCopyWith<WorkoutPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutPreviewCopyWith<$Res> {
  factory $WorkoutPreviewCopyWith(
          WorkoutPreview value, $Res Function(WorkoutPreview) then) =
      _$WorkoutPreviewCopyWithImpl<$Res, WorkoutPreview>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'workout_name') String workoutName,
      @JsonKey(name: 'workout_type') String workoutType,
      DateTime date,
      @JsonKey(name: 'duration_minutes') int durationMinutes});
}

/// @nodoc
class _$WorkoutPreviewCopyWithImpl<$Res, $Val extends WorkoutPreview>
    implements $WorkoutPreviewCopyWith<$Res> {
  _$WorkoutPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutName = null,
    Object? workoutType = null,
    Object? date = null,
    Object? durationMinutes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      workoutType: null == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutPreviewImplCopyWith<$Res>
    implements $WorkoutPreviewCopyWith<$Res> {
  factory _$$WorkoutPreviewImplCopyWith(_$WorkoutPreviewImpl value,
          $Res Function(_$WorkoutPreviewImpl) then) =
      __$$WorkoutPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'workout_name') String workoutName,
      @JsonKey(name: 'workout_type') String workoutType,
      DateTime date,
      @JsonKey(name: 'duration_minutes') int durationMinutes});
}

/// @nodoc
class __$$WorkoutPreviewImplCopyWithImpl<$Res>
    extends _$WorkoutPreviewCopyWithImpl<$Res, _$WorkoutPreviewImpl>
    implements _$$WorkoutPreviewImplCopyWith<$Res> {
  __$$WorkoutPreviewImplCopyWithImpl(
      _$WorkoutPreviewImpl _value, $Res Function(_$WorkoutPreviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutName = null,
    Object? workoutType = null,
    Object? date = null,
    Object? durationMinutes = null,
  }) {
    return _then(_$WorkoutPreviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      workoutType: null == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutPreviewImpl implements _WorkoutPreview {
  const _$WorkoutPreviewImpl(
      {this.id = '',
      @JsonKey(name: 'workout_name') this.workoutName = '',
      @JsonKey(name: 'workout_type') this.workoutType = '',
      required this.date,
      @JsonKey(name: 'duration_minutes') this.durationMinutes = 0});

  factory _$WorkoutPreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutPreviewImplFromJson(json);

  /// ID único do treino
  @override
  @JsonKey()
  final String id;

  /// Nome do treino
  @override
  @JsonKey(name: 'workout_name')
  final String workoutName;

  /// Tipo de treino (cardio, força, etc.)
  @override
  @JsonKey(name: 'workout_type')
  final String workoutType;

  /// Data de realização do treino
  @override
  final DateTime date;

  /// Duração do treino em minutos
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  @override
  String toString() {
    return 'WorkoutPreview(id: $id, workoutName: $workoutName, workoutType: $workoutType, date: $date, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutPreviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.workoutType, workoutType) ||
                other.workoutType == workoutType) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, workoutName, workoutType, date, durationMinutes);

  /// Create a copy of WorkoutPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutPreviewImplCopyWith<_$WorkoutPreviewImpl> get copyWith =>
      __$$WorkoutPreviewImplCopyWithImpl<_$WorkoutPreviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutPreviewImplToJson(
      this,
    );
  }
}

abstract class _WorkoutPreview implements WorkoutPreview {
  const factory _WorkoutPreview(
          {final String id,
          @JsonKey(name: 'workout_name') final String workoutName,
          @JsonKey(name: 'workout_type') final String workoutType,
          required final DateTime date,
          @JsonKey(name: 'duration_minutes') final int durationMinutes}) =
      _$WorkoutPreviewImpl;

  factory _WorkoutPreview.fromJson(Map<String, dynamic> json) =
      _$WorkoutPreviewImpl.fromJson;

  /// ID único do treino
  @override
  String get id;

  /// Nome do treino
  @override
  @JsonKey(name: 'workout_name')
  String get workoutName;

  /// Tipo de treino (cardio, força, etc.)
  @override
  @JsonKey(name: 'workout_type')
  String get workoutType;

  /// Data de realização do treino
  @override
  DateTime get date;

  /// Duração do treino em minutos
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;

  /// Create a copy of WorkoutPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutPreviewImplCopyWith<_$WorkoutPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeProgress _$ChallengeProgressFromJson(Map<String, dynamic> json) {
  return _ChallengeProgress.fromJson(json);
}

/// @nodoc
mixin _$ChallengeProgress {
  /// Número total de check-ins realizados
  @JsonKey(name: 'check_ins')
  int get checkIns => throw _privateConstructorUsedError;

  /// Total de pontos acumulados
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;

  /// Serializes this ChallengeProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeProgressCopyWith<ChallengeProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeProgressCopyWith<$Res> {
  factory $ChallengeProgressCopyWith(
          ChallengeProgress value, $Res Function(ChallengeProgress) then) =
      _$ChallengeProgressCopyWithImpl<$Res, ChallengeProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'check_ins') int checkIns,
      @JsonKey(name: 'total_points') int totalPoints});
}

/// @nodoc
class _$ChallengeProgressCopyWithImpl<$Res, $Val extends ChallengeProgress>
    implements $ChallengeProgressCopyWith<$Res> {
  _$ChallengeProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkIns = null,
    Object? totalPoints = null,
  }) {
    return _then(_value.copyWith(
      checkIns: null == checkIns
          ? _value.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeProgressImplCopyWith<$Res>
    implements $ChallengeProgressCopyWith<$Res> {
  factory _$$ChallengeProgressImplCopyWith(_$ChallengeProgressImpl value,
          $Res Function(_$ChallengeProgressImpl) then) =
      __$$ChallengeProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'check_ins') int checkIns,
      @JsonKey(name: 'total_points') int totalPoints});
}

/// @nodoc
class __$$ChallengeProgressImplCopyWithImpl<$Res>
    extends _$ChallengeProgressCopyWithImpl<$Res, _$ChallengeProgressImpl>
    implements _$$ChallengeProgressImplCopyWith<$Res> {
  __$$ChallengeProgressImplCopyWithImpl(_$ChallengeProgressImpl _value,
      $Res Function(_$ChallengeProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkIns = null,
    Object? totalPoints = null,
  }) {
    return _then(_$ChallengeProgressImpl(
      checkIns: null == checkIns
          ? _value.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeProgressImpl implements _ChallengeProgress {
  const _$ChallengeProgressImpl(
      {@JsonKey(name: 'check_ins') this.checkIns = 0,
      @JsonKey(name: 'total_points') this.totalPoints = 0});

  factory _$ChallengeProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeProgressImplFromJson(json);

  /// Número total de check-ins realizados
  @override
  @JsonKey(name: 'check_ins')
  final int checkIns;

  /// Total de pontos acumulados
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;

  @override
  String toString() {
    return 'ChallengeProgress(checkIns: $checkIns, totalPoints: $totalPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeProgressImpl &&
            (identical(other.checkIns, checkIns) ||
                other.checkIns == checkIns) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, checkIns, totalPoints);

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeProgressImplCopyWith<_$ChallengeProgressImpl> get copyWith =>
      __$$ChallengeProgressImplCopyWithImpl<_$ChallengeProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeProgressImplToJson(
      this,
    );
  }
}

abstract class _ChallengeProgress implements ChallengeProgress {
  const factory _ChallengeProgress(
          {@JsonKey(name: 'check_ins') final int checkIns,
          @JsonKey(name: 'total_points') final int totalPoints}) =
      _$ChallengeProgressImpl;

  factory _ChallengeProgress.fromJson(Map<String, dynamic> json) =
      _$ChallengeProgressImpl.fromJson;

  /// Número total de check-ins realizados
  @override
  @JsonKey(name: 'check_ins')
  int get checkIns;

  /// Total de pontos acumulados
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeProgressImplCopyWith<_$ChallengeProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
