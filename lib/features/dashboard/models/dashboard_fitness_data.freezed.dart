// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_fitness_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardFitnessData _$DashboardFitnessDataFromJson(Map<String, dynamic> json) {
  return _DashboardFitnessData.fromJson(json);
}

/// @nodoc
mixin _$DashboardFitnessData {
  /// Dados do calendário mensal com anéis de progresso
  @JsonKey(name: 'calendar')
  CalendarData get calendar => throw _privateConstructorUsedError;

  /// Estatísticas de progresso semanal e mensal
  @JsonKey(name: 'progress')
  ProgressData get progress => throw _privateConstructorUsedError;

  /// Dados de premiação e pontuação
  @JsonKey(name: 'awards')
  AwardsData get awards => throw _privateConstructorUsedError;

  /// Data da última atualização
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this DashboardFitnessData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardFitnessDataCopyWith<DashboardFitnessData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardFitnessDataCopyWith<$Res> {
  factory $DashboardFitnessDataCopyWith(DashboardFitnessData value,
          $Res Function(DashboardFitnessData) then) =
      _$DashboardFitnessDataCopyWithImpl<$Res, DashboardFitnessData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'calendar') CalendarData calendar,
      @JsonKey(name: 'progress') ProgressData progress,
      @JsonKey(name: 'awards') AwardsData awards,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});

  $CalendarDataCopyWith<$Res> get calendar;
  $ProgressDataCopyWith<$Res> get progress;
  $AwardsDataCopyWith<$Res> get awards;
}

/// @nodoc
class _$DashboardFitnessDataCopyWithImpl<$Res,
        $Val extends DashboardFitnessData>
    implements $DashboardFitnessDataCopyWith<$Res> {
  _$DashboardFitnessDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calendar = null,
    Object? progress = null,
    Object? awards = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      calendar: null == calendar
          ? _value.calendar
          : calendar // ignore: cast_nullable_to_non_nullable
              as CalendarData,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as ProgressData,
      awards: null == awards
          ? _value.awards
          : awards // ignore: cast_nullable_to_non_nullable
              as AwardsData,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CalendarDataCopyWith<$Res> get calendar {
    return $CalendarDataCopyWith<$Res>(_value.calendar, (value) {
      return _then(_value.copyWith(calendar: value) as $Val);
    });
  }

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressDataCopyWith<$Res> get progress {
    return $ProgressDataCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AwardsDataCopyWith<$Res> get awards {
    return $AwardsDataCopyWith<$Res>(_value.awards, (value) {
      return _then(_value.copyWith(awards: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardFitnessDataImplCopyWith<$Res>
    implements $DashboardFitnessDataCopyWith<$Res> {
  factory _$$DashboardFitnessDataImplCopyWith(_$DashboardFitnessDataImpl value,
          $Res Function(_$DashboardFitnessDataImpl) then) =
      __$$DashboardFitnessDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'calendar') CalendarData calendar,
      @JsonKey(name: 'progress') ProgressData progress,
      @JsonKey(name: 'awards') AwardsData awards,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});

  @override
  $CalendarDataCopyWith<$Res> get calendar;
  @override
  $ProgressDataCopyWith<$Res> get progress;
  @override
  $AwardsDataCopyWith<$Res> get awards;
}

/// @nodoc
class __$$DashboardFitnessDataImplCopyWithImpl<$Res>
    extends _$DashboardFitnessDataCopyWithImpl<$Res, _$DashboardFitnessDataImpl>
    implements _$$DashboardFitnessDataImplCopyWith<$Res> {
  __$$DashboardFitnessDataImplCopyWithImpl(_$DashboardFitnessDataImpl _value,
      $Res Function(_$DashboardFitnessDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calendar = null,
    Object? progress = null,
    Object? awards = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$DashboardFitnessDataImpl(
      calendar: null == calendar
          ? _value.calendar
          : calendar // ignore: cast_nullable_to_non_nullable
              as CalendarData,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as ProgressData,
      awards: null == awards
          ? _value.awards
          : awards // ignore: cast_nullable_to_non_nullable
              as AwardsData,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardFitnessDataImpl implements _DashboardFitnessData {
  const _$DashboardFitnessDataImpl(
      {@JsonKey(name: 'calendar') required this.calendar,
      @JsonKey(name: 'progress') required this.progress,
      @JsonKey(name: 'awards') required this.awards,
      @JsonKey(name: 'last_updated') required this.lastUpdated});

  factory _$DashboardFitnessDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardFitnessDataImplFromJson(json);

  /// Dados do calendário mensal com anéis de progresso
  @override
  @JsonKey(name: 'calendar')
  final CalendarData calendar;

  /// Estatísticas de progresso semanal e mensal
  @override
  @JsonKey(name: 'progress')
  final ProgressData progress;

  /// Dados de premiação e pontuação
  @override
  @JsonKey(name: 'awards')
  final AwardsData awards;

  /// Data da última atualização
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'DashboardFitnessData(calendar: $calendar, progress: $progress, awards: $awards, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardFitnessDataImpl &&
            (identical(other.calendar, calendar) ||
                other.calendar == calendar) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.awards, awards) || other.awards == awards) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, calendar, progress, awards, lastUpdated);

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardFitnessDataImplCopyWith<_$DashboardFitnessDataImpl>
      get copyWith =>
          __$$DashboardFitnessDataImplCopyWithImpl<_$DashboardFitnessDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardFitnessDataImplToJson(
      this,
    );
  }
}

abstract class _DashboardFitnessData implements DashboardFitnessData {
  const factory _DashboardFitnessData(
          {@JsonKey(name: 'calendar') required final CalendarData calendar,
          @JsonKey(name: 'progress') required final ProgressData progress,
          @JsonKey(name: 'awards') required final AwardsData awards,
          @JsonKey(name: 'last_updated') required final DateTime lastUpdated}) =
      _$DashboardFitnessDataImpl;

  factory _DashboardFitnessData.fromJson(Map<String, dynamic> json) =
      _$DashboardFitnessDataImpl.fromJson;

  /// Dados do calendário mensal com anéis de progresso
  @override
  @JsonKey(name: 'calendar')
  CalendarData get calendar;

  /// Estatísticas de progresso semanal e mensal
  @override
  @JsonKey(name: 'progress')
  ProgressData get progress;

  /// Dados de premiação e pontuação
  @override
  @JsonKey(name: 'awards')
  AwardsData get awards;

  /// Data da última atualização
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;

  /// Create a copy of DashboardFitnessData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardFitnessDataImplCopyWith<_$DashboardFitnessDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CalendarData _$CalendarDataFromJson(Map<String, dynamic> json) {
  return _CalendarData.fromJson(json);
}

/// @nodoc
mixin _$CalendarData {
  /// Mês (1-12)
  @JsonKey(name: 'month')
  int get month => throw _privateConstructorUsedError;

  /// Ano
  @JsonKey(name: 'year')
  int get year => throw _privateConstructorUsedError;

  /// Lista de dias do mês
  @JsonKey(name: 'days')
  List<CalendarDayData> get days => throw _privateConstructorUsedError;

  /// Serializes this CalendarData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarDataCopyWith<CalendarData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarDataCopyWith<$Res> {
  factory $CalendarDataCopyWith(
          CalendarData value, $Res Function(CalendarData) then) =
      _$CalendarDataCopyWithImpl<$Res, CalendarData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'month') int month,
      @JsonKey(name: 'year') int year,
      @JsonKey(name: 'days') List<CalendarDayData> days});
}

/// @nodoc
class _$CalendarDataCopyWithImpl<$Res, $Val extends CalendarData>
    implements $CalendarDataCopyWith<$Res> {
  _$CalendarDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
    Object? days = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as List<CalendarDayData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarDataImplCopyWith<$Res>
    implements $CalendarDataCopyWith<$Res> {
  factory _$$CalendarDataImplCopyWith(
          _$CalendarDataImpl value, $Res Function(_$CalendarDataImpl) then) =
      __$$CalendarDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'month') int month,
      @JsonKey(name: 'year') int year,
      @JsonKey(name: 'days') List<CalendarDayData> days});
}

/// @nodoc
class __$$CalendarDataImplCopyWithImpl<$Res>
    extends _$CalendarDataCopyWithImpl<$Res, _$CalendarDataImpl>
    implements _$$CalendarDataImplCopyWith<$Res> {
  __$$CalendarDataImplCopyWithImpl(
      _$CalendarDataImpl _value, $Res Function(_$CalendarDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalendarData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
    Object? days = null,
  }) {
    return _then(_$CalendarDataImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<CalendarDayData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarDataImpl implements _CalendarData {
  const _$CalendarDataImpl(
      {@JsonKey(name: 'month') required this.month,
      @JsonKey(name: 'year') required this.year,
      @JsonKey(name: 'days') final List<CalendarDayData> days = const []})
      : _days = days;

  factory _$CalendarDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarDataImplFromJson(json);

  /// Mês (1-12)
  @override
  @JsonKey(name: 'month')
  final int month;

  /// Ano
  @override
  @JsonKey(name: 'year')
  final int year;

  /// Lista de dias do mês
  final List<CalendarDayData> _days;

  /// Lista de dias do mês
  @override
  @JsonKey(name: 'days')
  List<CalendarDayData> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'CalendarData(month: $month, year: $year, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarDataImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, month, year, const DeepCollectionEquality().hash(_days));

  /// Create a copy of CalendarData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarDataImplCopyWith<_$CalendarDataImpl> get copyWith =>
      __$$CalendarDataImplCopyWithImpl<_$CalendarDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarDataImplToJson(
      this,
    );
  }
}

abstract class _CalendarData implements CalendarData {
  const factory _CalendarData(
          {@JsonKey(name: 'month') required final int month,
          @JsonKey(name: 'year') required final int year,
          @JsonKey(name: 'days') final List<CalendarDayData> days}) =
      _$CalendarDataImpl;

  factory _CalendarData.fromJson(Map<String, dynamic> json) =
      _$CalendarDataImpl.fromJson;

  /// Mês (1-12)
  @override
  @JsonKey(name: 'month')
  int get month;

  /// Ano
  @override
  @JsonKey(name: 'year')
  int get year;

  /// Lista de dias do mês
  @override
  @JsonKey(name: 'days')
  List<CalendarDayData> get days;

  /// Create a copy of CalendarData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarDataImplCopyWith<_$CalendarDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarDayData _$CalendarDayDataFromJson(Map<String, dynamic> json) {
  return _CalendarDayData.fromJson(json);
}

/// @nodoc
mixin _$CalendarDayData {
  /// Dia do mês (1-31)
  @JsonKey(name: 'day')
  int get day => throw _privateConstructorUsedError;

  /// Data completa do dia
  @JsonKey(name: 'date')
  DateTime get date => throw _privateConstructorUsedError;

  /// Número de treinos no dia
  @JsonKey(name: 'workout_count')
  int get workoutCount => throw _privateConstructorUsedError;

  /// Minutos totais de treino
  @JsonKey(name: 'total_minutes')
  int get totalMinutes => throw _privateConstructorUsedError;

  /// Tipos de treino realizados
  @JsonKey(name: 'workout_types')
  List<String> get workoutTypes => throw _privateConstructorUsedError;

  /// Lista de treinos do dia
  @JsonKey(name: 'workouts')
  List<WorkoutSummary> get workouts => throw _privateConstructorUsedError;

  /// Anéis de progresso do dia
  @JsonKey(name: 'rings')
  ActivityRings get rings => throw _privateConstructorUsedError;

  /// Serializes this CalendarDayData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarDayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarDayDataCopyWith<CalendarDayData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarDayDataCopyWith<$Res> {
  factory $CalendarDayDataCopyWith(
          CalendarDayData value, $Res Function(CalendarDayData) then) =
      _$CalendarDayDataCopyWithImpl<$Res, CalendarDayData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'day') int day,
      @JsonKey(name: 'date') DateTime date,
      @JsonKey(name: 'workout_count') int workoutCount,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      @JsonKey(name: 'workout_types') List<String> workoutTypes,
      @JsonKey(name: 'workouts') List<WorkoutSummary> workouts,
      @JsonKey(name: 'rings') ActivityRings rings});

  $ActivityRingsCopyWith<$Res> get rings;
}

/// @nodoc
class _$CalendarDayDataCopyWithImpl<$Res, $Val extends CalendarDayData>
    implements $CalendarDayDataCopyWith<$Res> {
  _$CalendarDayDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarDayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? date = null,
    Object? workoutCount = null,
    Object? totalMinutes = null,
    Object? workoutTypes = null,
    Object? workouts = null,
    Object? rings = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      workoutTypes: null == workoutTypes
          ? _value.workoutTypes
          : workoutTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSummary>,
      rings: null == rings
          ? _value.rings
          : rings // ignore: cast_nullable_to_non_nullable
              as ActivityRings,
    ) as $Val);
  }

  /// Create a copy of CalendarDayData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActivityRingsCopyWith<$Res> get rings {
    return $ActivityRingsCopyWith<$Res>(_value.rings, (value) {
      return _then(_value.copyWith(rings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalendarDayDataImplCopyWith<$Res>
    implements $CalendarDayDataCopyWith<$Res> {
  factory _$$CalendarDayDataImplCopyWith(_$CalendarDayDataImpl value,
          $Res Function(_$CalendarDayDataImpl) then) =
      __$$CalendarDayDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'day') int day,
      @JsonKey(name: 'date') DateTime date,
      @JsonKey(name: 'workout_count') int workoutCount,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      @JsonKey(name: 'workout_types') List<String> workoutTypes,
      @JsonKey(name: 'workouts') List<WorkoutSummary> workouts,
      @JsonKey(name: 'rings') ActivityRings rings});

  @override
  $ActivityRingsCopyWith<$Res> get rings;
}

/// @nodoc
class __$$CalendarDayDataImplCopyWithImpl<$Res>
    extends _$CalendarDayDataCopyWithImpl<$Res, _$CalendarDayDataImpl>
    implements _$$CalendarDayDataImplCopyWith<$Res> {
  __$$CalendarDayDataImplCopyWithImpl(
      _$CalendarDayDataImpl _value, $Res Function(_$CalendarDayDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalendarDayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? date = null,
    Object? workoutCount = null,
    Object? totalMinutes = null,
    Object? workoutTypes = null,
    Object? workouts = null,
    Object? rings = null,
  }) {
    return _then(_$CalendarDayDataImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      workoutTypes: null == workoutTypes
          ? _value._workoutTypes
          : workoutTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      workouts: null == workouts
          ? _value._workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSummary>,
      rings: null == rings
          ? _value.rings
          : rings // ignore: cast_nullable_to_non_nullable
              as ActivityRings,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarDayDataImpl implements _CalendarDayData {
  const _$CalendarDayDataImpl(
      {@JsonKey(name: 'day') required this.day,
      @JsonKey(name: 'date') required this.date,
      @JsonKey(name: 'workout_count') this.workoutCount = 0,
      @JsonKey(name: 'total_minutes') this.totalMinutes = 0,
      @JsonKey(name: 'workout_types')
      final List<String> workoutTypes = const [],
      @JsonKey(name: 'workouts') final List<WorkoutSummary> workouts = const [],
      @JsonKey(name: 'rings') required this.rings})
      : _workoutTypes = workoutTypes,
        _workouts = workouts;

  factory _$CalendarDayDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarDayDataImplFromJson(json);

  /// Dia do mês (1-31)
  @override
  @JsonKey(name: 'day')
  final int day;

  /// Data completa do dia
  @override
  @JsonKey(name: 'date')
  final DateTime date;

  /// Número de treinos no dia
  @override
  @JsonKey(name: 'workout_count')
  final int workoutCount;

  /// Minutos totais de treino
  @override
  @JsonKey(name: 'total_minutes')
  final int totalMinutes;

  /// Tipos de treino realizados
  final List<String> _workoutTypes;

  /// Tipos de treino realizados
  @override
  @JsonKey(name: 'workout_types')
  List<String> get workoutTypes {
    if (_workoutTypes is EqualUnmodifiableListView) return _workoutTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workoutTypes);
  }

  /// Lista de treinos do dia
  final List<WorkoutSummary> _workouts;

  /// Lista de treinos do dia
  @override
  @JsonKey(name: 'workouts')
  List<WorkoutSummary> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  /// Anéis de progresso do dia
  @override
  @JsonKey(name: 'rings')
  final ActivityRings rings;

  @override
  String toString() {
    return 'CalendarDayData(day: $day, date: $date, workoutCount: $workoutCount, totalMinutes: $totalMinutes, workoutTypes: $workoutTypes, workouts: $workouts, rings: $rings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarDayDataImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            const DeepCollectionEquality()
                .equals(other._workoutTypes, _workoutTypes) &&
            const DeepCollectionEquality().equals(other._workouts, _workouts) &&
            (identical(other.rings, rings) || other.rings == rings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      day,
      date,
      workoutCount,
      totalMinutes,
      const DeepCollectionEquality().hash(_workoutTypes),
      const DeepCollectionEquality().hash(_workouts),
      rings);

  /// Create a copy of CalendarDayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarDayDataImplCopyWith<_$CalendarDayDataImpl> get copyWith =>
      __$$CalendarDayDataImplCopyWithImpl<_$CalendarDayDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarDayDataImplToJson(
      this,
    );
  }
}

abstract class _CalendarDayData implements CalendarDayData {
  const factory _CalendarDayData(
          {@JsonKey(name: 'day') required final int day,
          @JsonKey(name: 'date') required final DateTime date,
          @JsonKey(name: 'workout_count') final int workoutCount,
          @JsonKey(name: 'total_minutes') final int totalMinutes,
          @JsonKey(name: 'workout_types') final List<String> workoutTypes,
          @JsonKey(name: 'workouts') final List<WorkoutSummary> workouts,
          @JsonKey(name: 'rings') required final ActivityRings rings}) =
      _$CalendarDayDataImpl;

  factory _CalendarDayData.fromJson(Map<String, dynamic> json) =
      _$CalendarDayDataImpl.fromJson;

  /// Dia do mês (1-31)
  @override
  @JsonKey(name: 'day')
  int get day;

  /// Data completa do dia
  @override
  @JsonKey(name: 'date')
  DateTime get date;

  /// Número de treinos no dia
  @override
  @JsonKey(name: 'workout_count')
  int get workoutCount;

  /// Minutos totais de treino
  @override
  @JsonKey(name: 'total_minutes')
  int get totalMinutes;

  /// Tipos de treino realizados
  @override
  @JsonKey(name: 'workout_types')
  List<String> get workoutTypes;

  /// Lista de treinos do dia
  @override
  @JsonKey(name: 'workouts')
  List<WorkoutSummary> get workouts;

  /// Anéis de progresso do dia
  @override
  @JsonKey(name: 'rings')
  ActivityRings get rings;

  /// Create a copy of CalendarDayData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarDayDataImplCopyWith<_$CalendarDayDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityRings _$ActivityRingsFromJson(Map<String, dynamic> json) {
  return _ActivityRings.fromJson(json);
}

/// @nodoc
mixin _$ActivityRings {
  /// Anel verde - Treino realizado (0-100%)
  @JsonKey(name: 'move')
  double get move => throw _privateConstructorUsedError;

  /// Anel vermelho - Meta de minutos atingida (0-100%)
  @JsonKey(name: 'exercise')
  double get exercise => throw _privateConstructorUsedError;

  /// Anel azul - Check-in válido para desafio (0-100%)
  @JsonKey(name: 'stand')
  double get stand => throw _privateConstructorUsedError;

  /// Serializes this ActivityRings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityRings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityRingsCopyWith<ActivityRings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityRingsCopyWith<$Res> {
  factory $ActivityRingsCopyWith(
          ActivityRings value, $Res Function(ActivityRings) then) =
      _$ActivityRingsCopyWithImpl<$Res, ActivityRings>;
  @useResult
  $Res call(
      {@JsonKey(name: 'move') double move,
      @JsonKey(name: 'exercise') double exercise,
      @JsonKey(name: 'stand') double stand});
}

/// @nodoc
class _$ActivityRingsCopyWithImpl<$Res, $Val extends ActivityRings>
    implements $ActivityRingsCopyWith<$Res> {
  _$ActivityRingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityRings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? move = null,
    Object? exercise = null,
    Object? stand = null,
  }) {
    return _then(_value.copyWith(
      move: null == move
          ? _value.move
          : move // ignore: cast_nullable_to_non_nullable
              as double,
      exercise: null == exercise
          ? _value.exercise
          : exercise // ignore: cast_nullable_to_non_nullable
              as double,
      stand: null == stand
          ? _value.stand
          : stand // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityRingsImplCopyWith<$Res>
    implements $ActivityRingsCopyWith<$Res> {
  factory _$$ActivityRingsImplCopyWith(
          _$ActivityRingsImpl value, $Res Function(_$ActivityRingsImpl) then) =
      __$$ActivityRingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'move') double move,
      @JsonKey(name: 'exercise') double exercise,
      @JsonKey(name: 'stand') double stand});
}

/// @nodoc
class __$$ActivityRingsImplCopyWithImpl<$Res>
    extends _$ActivityRingsCopyWithImpl<$Res, _$ActivityRingsImpl>
    implements _$$ActivityRingsImplCopyWith<$Res> {
  __$$ActivityRingsImplCopyWithImpl(
      _$ActivityRingsImpl _value, $Res Function(_$ActivityRingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityRings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? move = null,
    Object? exercise = null,
    Object? stand = null,
  }) {
    return _then(_$ActivityRingsImpl(
      move: null == move
          ? _value.move
          : move // ignore: cast_nullable_to_non_nullable
              as double,
      exercise: null == exercise
          ? _value.exercise
          : exercise // ignore: cast_nullable_to_non_nullable
              as double,
      stand: null == stand
          ? _value.stand
          : stand // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityRingsImpl implements _ActivityRings {
  const _$ActivityRingsImpl(
      {@JsonKey(name: 'move') this.move = 0,
      @JsonKey(name: 'exercise') this.exercise = 0,
      @JsonKey(name: 'stand') this.stand = 0});

  factory _$ActivityRingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityRingsImplFromJson(json);

  /// Anel verde - Treino realizado (0-100%)
  @override
  @JsonKey(name: 'move')
  final double move;

  /// Anel vermelho - Meta de minutos atingida (0-100%)
  @override
  @JsonKey(name: 'exercise')
  final double exercise;

  /// Anel azul - Check-in válido para desafio (0-100%)
  @override
  @JsonKey(name: 'stand')
  final double stand;

  @override
  String toString() {
    return 'ActivityRings(move: $move, exercise: $exercise, stand: $stand)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityRingsImpl &&
            (identical(other.move, move) || other.move == move) &&
            (identical(other.exercise, exercise) ||
                other.exercise == exercise) &&
            (identical(other.stand, stand) || other.stand == stand));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, move, exercise, stand);

  /// Create a copy of ActivityRings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityRingsImplCopyWith<_$ActivityRingsImpl> get copyWith =>
      __$$ActivityRingsImplCopyWithImpl<_$ActivityRingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityRingsImplToJson(
      this,
    );
  }
}

abstract class _ActivityRings implements ActivityRings {
  const factory _ActivityRings(
      {@JsonKey(name: 'move') final double move,
      @JsonKey(name: 'exercise') final double exercise,
      @JsonKey(name: 'stand') final double stand}) = _$ActivityRingsImpl;

  factory _ActivityRings.fromJson(Map<String, dynamic> json) =
      _$ActivityRingsImpl.fromJson;

  /// Anel verde - Treino realizado (0-100%)
  @override
  @JsonKey(name: 'move')
  double get move;

  /// Anel vermelho - Meta de minutos atingida (0-100%)
  @override
  @JsonKey(name: 'exercise')
  double get exercise;

  /// Anel azul - Check-in válido para desafio (0-100%)
  @override
  @JsonKey(name: 'stand')
  double get stand;

  /// Create a copy of ActivityRings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityRingsImplCopyWith<_$ActivityRingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutSummary _$WorkoutSummaryFromJson(Map<String, dynamic> json) {
  return _WorkoutSummary.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSummary {
  /// ID do treino
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;

  /// Nome do treino
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;

  /// Tipo do treino
  @JsonKey(name: 'type')
  String get type => throw _privateConstructorUsedError;

  /// Duração em minutos
  @JsonKey(name: 'duration')
  int get duration => throw _privateConstructorUsedError;

  /// URL da foto (opcional)
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Pontos ganhos
  @JsonKey(name: 'points')
  int get points => throw _privateConstructorUsedError;

  /// Se é válido para desafio
  @JsonKey(name: 'is_challenge_valid')
  bool get isChallengeValid => throw _privateConstructorUsedError;

  /// Data de criação
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WorkoutSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutSummaryCopyWith<WorkoutSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSummaryCopyWith<$Res> {
  factory $WorkoutSummaryCopyWith(
          WorkoutSummary value, $Res Function(WorkoutSummary) then) =
      _$WorkoutSummaryCopyWithImpl<$Res, WorkoutSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'duration') int duration,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'points') int points,
      @JsonKey(name: 'is_challenge_valid') bool isChallengeValid,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$WorkoutSummaryCopyWithImpl<$Res, $Val extends WorkoutSummary>
    implements $WorkoutSummaryCopyWith<$Res> {
  _$WorkoutSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? duration = null,
    Object? photoUrl = freezed,
    Object? points = null,
    Object? isChallengeValid = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      isChallengeValid: null == isChallengeValid
          ? _value.isChallengeValid
          : isChallengeValid // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSummaryImplCopyWith<$Res>
    implements $WorkoutSummaryCopyWith<$Res> {
  factory _$$WorkoutSummaryImplCopyWith(_$WorkoutSummaryImpl value,
          $Res Function(_$WorkoutSummaryImpl) then) =
      __$$WorkoutSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'duration') int duration,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'points') int points,
      @JsonKey(name: 'is_challenge_valid') bool isChallengeValid,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$WorkoutSummaryImplCopyWithImpl<$Res>
    extends _$WorkoutSummaryCopyWithImpl<$Res, _$WorkoutSummaryImpl>
    implements _$$WorkoutSummaryImplCopyWith<$Res> {
  __$$WorkoutSummaryImplCopyWithImpl(
      _$WorkoutSummaryImpl _value, $Res Function(_$WorkoutSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? duration = null,
    Object? photoUrl = freezed,
    Object? points = null,
    Object? isChallengeValid = null,
    Object? createdAt = null,
  }) {
    return _then(_$WorkoutSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      isChallengeValid: null == isChallengeValid
          ? _value.isChallengeValid
          : isChallengeValid // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSummaryImpl implements _WorkoutSummary {
  const _$WorkoutSummaryImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'name') required this.name,
      @JsonKey(name: 'type') required this.type,
      @JsonKey(name: 'duration') this.duration = 0,
      @JsonKey(name: 'photo_url') this.photoUrl,
      @JsonKey(name: 'points') this.points = 0,
      @JsonKey(name: 'is_challenge_valid') this.isChallengeValid = false,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$WorkoutSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSummaryImplFromJson(json);

  /// ID do treino
  @override
  @JsonKey(name: 'id')
  final String id;

  /// Nome do treino
  @override
  @JsonKey(name: 'name')
  final String name;

  /// Tipo do treino
  @override
  @JsonKey(name: 'type')
  final String type;

  /// Duração em minutos
  @override
  @JsonKey(name: 'duration')
  final int duration;

  /// URL da foto (opcional)
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  /// Pontos ganhos
  @override
  @JsonKey(name: 'points')
  final int points;

  /// Se é válido para desafio
  @override
  @JsonKey(name: 'is_challenge_valid')
  final bool isChallengeValid;

  /// Data de criação
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'WorkoutSummary(id: $id, name: $name, type: $type, duration: $duration, photoUrl: $photoUrl, points: $points, isChallengeValid: $isChallengeValid, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.isChallengeValid, isChallengeValid) ||
                other.isChallengeValid == isChallengeValid) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, duration,
      photoUrl, points, isChallengeValid, createdAt);

  /// Create a copy of WorkoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSummaryImplCopyWith<_$WorkoutSummaryImpl> get copyWith =>
      __$$WorkoutSummaryImplCopyWithImpl<_$WorkoutSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSummaryImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSummary implements WorkoutSummary {
  const factory _WorkoutSummary(
          {@JsonKey(name: 'id') required final String id,
          @JsonKey(name: 'name') required final String name,
          @JsonKey(name: 'type') required final String type,
          @JsonKey(name: 'duration') final int duration,
          @JsonKey(name: 'photo_url') final String? photoUrl,
          @JsonKey(name: 'points') final int points,
          @JsonKey(name: 'is_challenge_valid') final bool isChallengeValid,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$WorkoutSummaryImpl;

  factory _WorkoutSummary.fromJson(Map<String, dynamic> json) =
      _$WorkoutSummaryImpl.fromJson;

  /// ID do treino
  @override
  @JsonKey(name: 'id')
  String get id;

  /// Nome do treino
  @override
  @JsonKey(name: 'name')
  String get name;

  /// Tipo do treino
  @override
  @JsonKey(name: 'type')
  String get type;

  /// Duração em minutos
  @override
  @JsonKey(name: 'duration')
  int get duration;

  /// URL da foto (opcional)
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;

  /// Pontos ganhos
  @override
  @JsonKey(name: 'points')
  int get points;

  /// Se é válido para desafio
  @override
  @JsonKey(name: 'is_challenge_valid')
  bool get isChallengeValid;

  /// Data de criação
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of WorkoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutSummaryImplCopyWith<_$WorkoutSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressData _$ProgressDataFromJson(Map<String, dynamic> json) {
  return _ProgressData.fromJson(json);
}

/// @nodoc
mixin _$ProgressData {
  /// Progresso da semana
  @JsonKey(name: 'week')
  WeekProgress get week => throw _privateConstructorUsedError;

  /// Progresso do mês
  @JsonKey(name: 'month')
  MonthProgress get month => throw _privateConstructorUsedError;

  /// Dados totais do usuário
  @JsonKey(name: 'total')
  TotalProgress get total => throw _privateConstructorUsedError;

  /// Dados de streak (sequência de dias)
  @JsonKey(name: 'streak')
  StreakData get streak => throw _privateConstructorUsedError;

  /// Serializes this ProgressData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressDataCopyWith<ProgressData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressDataCopyWith<$Res> {
  factory $ProgressDataCopyWith(
          ProgressData value, $Res Function(ProgressData) then) =
      _$ProgressDataCopyWithImpl<$Res, ProgressData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'week') WeekProgress week,
      @JsonKey(name: 'month') MonthProgress month,
      @JsonKey(name: 'total') TotalProgress total,
      @JsonKey(name: 'streak') StreakData streak});

  $WeekProgressCopyWith<$Res> get week;
  $MonthProgressCopyWith<$Res> get month;
  $TotalProgressCopyWith<$Res> get total;
  $StreakDataCopyWith<$Res> get streak;
}

/// @nodoc
class _$ProgressDataCopyWithImpl<$Res, $Val extends ProgressData>
    implements $ProgressDataCopyWith<$Res> {
  _$ProgressDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? week = null,
    Object? month = null,
    Object? total = null,
    Object? streak = null,
  }) {
    return _then(_value.copyWith(
      week: null == week
          ? _value.week
          : week // ignore: cast_nullable_to_non_nullable
              as WeekProgress,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as MonthProgress,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as TotalProgress,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as StreakData,
    ) as $Val);
  }

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeekProgressCopyWith<$Res> get week {
    return $WeekProgressCopyWith<$Res>(_value.week, (value) {
      return _then(_value.copyWith(week: value) as $Val);
    });
  }

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MonthProgressCopyWith<$Res> get month {
    return $MonthProgressCopyWith<$Res>(_value.month, (value) {
      return _then(_value.copyWith(month: value) as $Val);
    });
  }

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TotalProgressCopyWith<$Res> get total {
    return $TotalProgressCopyWith<$Res>(_value.total, (value) {
      return _then(_value.copyWith(total: value) as $Val);
    });
  }

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakDataCopyWith<$Res> get streak {
    return $StreakDataCopyWith<$Res>(_value.streak, (value) {
      return _then(_value.copyWith(streak: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgressDataImplCopyWith<$Res>
    implements $ProgressDataCopyWith<$Res> {
  factory _$$ProgressDataImplCopyWith(
          _$ProgressDataImpl value, $Res Function(_$ProgressDataImpl) then) =
      __$$ProgressDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'week') WeekProgress week,
      @JsonKey(name: 'month') MonthProgress month,
      @JsonKey(name: 'total') TotalProgress total,
      @JsonKey(name: 'streak') StreakData streak});

  @override
  $WeekProgressCopyWith<$Res> get week;
  @override
  $MonthProgressCopyWith<$Res> get month;
  @override
  $TotalProgressCopyWith<$Res> get total;
  @override
  $StreakDataCopyWith<$Res> get streak;
}

/// @nodoc
class __$$ProgressDataImplCopyWithImpl<$Res>
    extends _$ProgressDataCopyWithImpl<$Res, _$ProgressDataImpl>
    implements _$$ProgressDataImplCopyWith<$Res> {
  __$$ProgressDataImplCopyWithImpl(
      _$ProgressDataImpl _value, $Res Function(_$ProgressDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? week = null,
    Object? month = null,
    Object? total = null,
    Object? streak = null,
  }) {
    return _then(_$ProgressDataImpl(
      week: null == week
          ? _value.week
          : week // ignore: cast_nullable_to_non_nullable
              as WeekProgress,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as MonthProgress,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as TotalProgress,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as StreakData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressDataImpl implements _ProgressData {
  const _$ProgressDataImpl(
      {@JsonKey(name: 'week') required this.week,
      @JsonKey(name: 'month') required this.month,
      @JsonKey(name: 'total') required this.total,
      @JsonKey(name: 'streak') required this.streak});

  factory _$ProgressDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressDataImplFromJson(json);

  /// Progresso da semana
  @override
  @JsonKey(name: 'week')
  final WeekProgress week;

  /// Progresso do mês
  @override
  @JsonKey(name: 'month')
  final MonthProgress month;

  /// Dados totais do usuário
  @override
  @JsonKey(name: 'total')
  final TotalProgress total;

  /// Dados de streak (sequência de dias)
  @override
  @JsonKey(name: 'streak')
  final StreakData streak;

  @override
  String toString() {
    return 'ProgressData(week: $week, month: $month, total: $total, streak: $streak)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressDataImpl &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.streak, streak) || other.streak == streak));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, week, month, total, streak);

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressDataImplCopyWith<_$ProgressDataImpl> get copyWith =>
      __$$ProgressDataImplCopyWithImpl<_$ProgressDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressDataImplToJson(
      this,
    );
  }
}

abstract class _ProgressData implements ProgressData {
  const factory _ProgressData(
          {@JsonKey(name: 'week') required final WeekProgress week,
          @JsonKey(name: 'month') required final MonthProgress month,
          @JsonKey(name: 'total') required final TotalProgress total,
          @JsonKey(name: 'streak') required final StreakData streak}) =
      _$ProgressDataImpl;

  factory _ProgressData.fromJson(Map<String, dynamic> json) =
      _$ProgressDataImpl.fromJson;

  /// Progresso da semana
  @override
  @JsonKey(name: 'week')
  WeekProgress get week;

  /// Progresso do mês
  @override
  @JsonKey(name: 'month')
  MonthProgress get month;

  /// Dados totais do usuário
  @override
  @JsonKey(name: 'total')
  TotalProgress get total;

  /// Dados de streak (sequência de dias)
  @override
  @JsonKey(name: 'streak')
  StreakData get streak;

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressDataImplCopyWith<_$ProgressDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeekProgress _$WeekProgressFromJson(Map<String, dynamic> json) {
  return _WeekProgress.fromJson(json);
}

/// @nodoc
mixin _$WeekProgress {
  /// Treinos completados na semana
  @JsonKey(name: 'workouts')
  int get workouts => throw _privateConstructorUsedError;

  /// Minutos completados na semana
  @JsonKey(name: 'minutes')
  int get minutes => throw _privateConstructorUsedError;

  /// Número de tipos diferentes de treino
  @JsonKey(name: 'types')
  int get types => throw _privateConstructorUsedError;

  /// Dias treinados na semana
  @JsonKey(name: 'days')
  int get days => throw _privateConstructorUsedError;

  /// Serializes this WeekProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeekProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeekProgressCopyWith<WeekProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekProgressCopyWith<$Res> {
  factory $WeekProgressCopyWith(
          WeekProgress value, $Res Function(WeekProgress) then) =
      _$WeekProgressCopyWithImpl<$Res, WeekProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'workouts') int workouts,
      @JsonKey(name: 'minutes') int minutes,
      @JsonKey(name: 'types') int types,
      @JsonKey(name: 'days') int days});
}

/// @nodoc
class _$WeekProgressCopyWithImpl<$Res, $Val extends WeekProgress>
    implements $WeekProgressCopyWith<$Res> {
  _$WeekProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeekProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? minutes = null,
    Object? types = null,
    Object? days = null,
  }) {
    return _then(_value.copyWith(
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as int,
      minutes: null == minutes
          ? _value.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      types: null == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeekProgressImplCopyWith<$Res>
    implements $WeekProgressCopyWith<$Res> {
  factory _$$WeekProgressImplCopyWith(
          _$WeekProgressImpl value, $Res Function(_$WeekProgressImpl) then) =
      __$$WeekProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'workouts') int workouts,
      @JsonKey(name: 'minutes') int minutes,
      @JsonKey(name: 'types') int types,
      @JsonKey(name: 'days') int days});
}

/// @nodoc
class __$$WeekProgressImplCopyWithImpl<$Res>
    extends _$WeekProgressCopyWithImpl<$Res, _$WeekProgressImpl>
    implements _$$WeekProgressImplCopyWith<$Res> {
  __$$WeekProgressImplCopyWithImpl(
      _$WeekProgressImpl _value, $Res Function(_$WeekProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeekProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? minutes = null,
    Object? types = null,
    Object? days = null,
  }) {
    return _then(_$WeekProgressImpl(
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as int,
      minutes: null == minutes
          ? _value.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      types: null == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeekProgressImpl implements _WeekProgress {
  const _$WeekProgressImpl(
      {@JsonKey(name: 'workouts') this.workouts = 0,
      @JsonKey(name: 'minutes') this.minutes = 0,
      @JsonKey(name: 'types') this.types = 0,
      @JsonKey(name: 'days') this.days = 0});

  factory _$WeekProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeekProgressImplFromJson(json);

  /// Treinos completados na semana
  @override
  @JsonKey(name: 'workouts')
  final int workouts;

  /// Minutos completados na semana
  @override
  @JsonKey(name: 'minutes')
  final int minutes;

  /// Número de tipos diferentes de treino
  @override
  @JsonKey(name: 'types')
  final int types;

  /// Dias treinados na semana
  @override
  @JsonKey(name: 'days')
  final int days;

  @override
  String toString() {
    return 'WeekProgress(workouts: $workouts, minutes: $minutes, types: $types, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekProgressImpl &&
            (identical(other.workouts, workouts) ||
                other.workouts == workouts) &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.types, types) || other.types == types) &&
            (identical(other.days, days) || other.days == days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, workouts, minutes, types, days);

  /// Create a copy of WeekProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekProgressImplCopyWith<_$WeekProgressImpl> get copyWith =>
      __$$WeekProgressImplCopyWithImpl<_$WeekProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeekProgressImplToJson(
      this,
    );
  }
}

abstract class _WeekProgress implements WeekProgress {
  const factory _WeekProgress(
      {@JsonKey(name: 'workouts') final int workouts,
      @JsonKey(name: 'minutes') final int minutes,
      @JsonKey(name: 'types') final int types,
      @JsonKey(name: 'days') final int days}) = _$WeekProgressImpl;

  factory _WeekProgress.fromJson(Map<String, dynamic> json) =
      _$WeekProgressImpl.fromJson;

  /// Treinos completados na semana
  @override
  @JsonKey(name: 'workouts')
  int get workouts;

  /// Minutos completados na semana
  @override
  @JsonKey(name: 'minutes')
  int get minutes;

  /// Número de tipos diferentes de treino
  @override
  @JsonKey(name: 'types')
  int get types;

  /// Dias treinados na semana
  @override
  @JsonKey(name: 'days')
  int get days;

  /// Create a copy of WeekProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekProgressImplCopyWith<_$WeekProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthProgress _$MonthProgressFromJson(Map<String, dynamic> json) {
  return _MonthProgress.fromJson(json);
}

/// @nodoc
mixin _$MonthProgress {
  /// Treinos completados no mês
  @JsonKey(name: 'workouts')
  int get workouts => throw _privateConstructorUsedError;

  /// Minutos completados no mês
  @JsonKey(name: 'minutes')
  int get minutes => throw _privateConstructorUsedError;

  /// Dias treinados no mês
  @JsonKey(name: 'days')
  int get days => throw _privateConstructorUsedError;

  /// Distribuição de tipos de treino
  @JsonKey(name: 'types_distribution')
  Map<String, dynamic> get typesDistribution =>
      throw _privateConstructorUsedError;

  /// Serializes this MonthProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthProgressCopyWith<MonthProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthProgressCopyWith<$Res> {
  factory $MonthProgressCopyWith(
          MonthProgress value, $Res Function(MonthProgress) then) =
      _$MonthProgressCopyWithImpl<$Res, MonthProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'workouts') int workouts,
      @JsonKey(name: 'minutes') int minutes,
      @JsonKey(name: 'days') int days,
      @JsonKey(name: 'types_distribution')
      Map<String, dynamic> typesDistribution});
}

/// @nodoc
class _$MonthProgressCopyWithImpl<$Res, $Val extends MonthProgress>
    implements $MonthProgressCopyWith<$Res> {
  _$MonthProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? minutes = null,
    Object? days = null,
    Object? typesDistribution = null,
  }) {
    return _then(_value.copyWith(
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as int,
      minutes: null == minutes
          ? _value.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
      typesDistribution: null == typesDistribution
          ? _value.typesDistribution
          : typesDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthProgressImplCopyWith<$Res>
    implements $MonthProgressCopyWith<$Res> {
  factory _$$MonthProgressImplCopyWith(
          _$MonthProgressImpl value, $Res Function(_$MonthProgressImpl) then) =
      __$$MonthProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'workouts') int workouts,
      @JsonKey(name: 'minutes') int minutes,
      @JsonKey(name: 'days') int days,
      @JsonKey(name: 'types_distribution')
      Map<String, dynamic> typesDistribution});
}

/// @nodoc
class __$$MonthProgressImplCopyWithImpl<$Res>
    extends _$MonthProgressCopyWithImpl<$Res, _$MonthProgressImpl>
    implements _$$MonthProgressImplCopyWith<$Res> {
  __$$MonthProgressImplCopyWithImpl(
      _$MonthProgressImpl _value, $Res Function(_$MonthProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? minutes = null,
    Object? days = null,
    Object? typesDistribution = null,
  }) {
    return _then(_$MonthProgressImpl(
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as int,
      minutes: null == minutes
          ? _value.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
      typesDistribution: null == typesDistribution
          ? _value._typesDistribution
          : typesDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthProgressImpl implements _MonthProgress {
  const _$MonthProgressImpl(
      {@JsonKey(name: 'workouts') this.workouts = 0,
      @JsonKey(name: 'minutes') this.minutes = 0,
      @JsonKey(name: 'days') this.days = 0,
      @JsonKey(name: 'types_distribution')
      final Map<String, dynamic> typesDistribution = const {}})
      : _typesDistribution = typesDistribution;

  factory _$MonthProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthProgressImplFromJson(json);

  /// Treinos completados no mês
  @override
  @JsonKey(name: 'workouts')
  final int workouts;

  /// Minutos completados no mês
  @override
  @JsonKey(name: 'minutes')
  final int minutes;

  /// Dias treinados no mês
  @override
  @JsonKey(name: 'days')
  final int days;

  /// Distribuição de tipos de treino
  final Map<String, dynamic> _typesDistribution;

  /// Distribuição de tipos de treino
  @override
  @JsonKey(name: 'types_distribution')
  Map<String, dynamic> get typesDistribution {
    if (_typesDistribution is EqualUnmodifiableMapView)
      return _typesDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_typesDistribution);
  }

  @override
  String toString() {
    return 'MonthProgress(workouts: $workouts, minutes: $minutes, days: $days, typesDistribution: $typesDistribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthProgressImpl &&
            (identical(other.workouts, workouts) ||
                other.workouts == workouts) &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.days, days) || other.days == days) &&
            const DeepCollectionEquality()
                .equals(other._typesDistribution, _typesDistribution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, workouts, minutes, days,
      const DeepCollectionEquality().hash(_typesDistribution));

  /// Create a copy of MonthProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthProgressImplCopyWith<_$MonthProgressImpl> get copyWith =>
      __$$MonthProgressImplCopyWithImpl<_$MonthProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthProgressImplToJson(
      this,
    );
  }
}

abstract class _MonthProgress implements MonthProgress {
  const factory _MonthProgress(
      {@JsonKey(name: 'workouts') final int workouts,
      @JsonKey(name: 'minutes') final int minutes,
      @JsonKey(name: 'days') final int days,
      @JsonKey(name: 'types_distribution')
      final Map<String, dynamic> typesDistribution}) = _$MonthProgressImpl;

  factory _MonthProgress.fromJson(Map<String, dynamic> json) =
      _$MonthProgressImpl.fromJson;

  /// Treinos completados no mês
  @override
  @JsonKey(name: 'workouts')
  int get workouts;

  /// Minutos completados no mês
  @override
  @JsonKey(name: 'minutes')
  int get minutes;

  /// Dias treinados no mês
  @override
  @JsonKey(name: 'days')
  int get days;

  /// Distribuição de tipos de treino
  @override
  @JsonKey(name: 'types_distribution')
  Map<String, dynamic> get typesDistribution;

  /// Create a copy of MonthProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthProgressImplCopyWith<_$MonthProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TotalProgress _$TotalProgressFromJson(Map<String, dynamic> json) {
  return _TotalProgress.fromJson(json);
}

/// @nodoc
mixin _$TotalProgress {
  /// Total de treinos
  @JsonKey(name: 'workouts')
  int get workouts => throw _privateConstructorUsedError;

  /// Total de treinos completados
  @JsonKey(name: 'workouts_completed')
  int get workoutsCompleted => throw _privateConstructorUsedError;

  /// Total de pontos
  @JsonKey(name: 'points')
  int get points => throw _privateConstructorUsedError;

  /// Duração total em minutos
  @JsonKey(name: 'duration')
  int get duration => throw _privateConstructorUsedError;

  /// Dias treinados no mês atual
  @JsonKey(name: 'days_trained_this_month')
  int get daysTrainedThisMonth => throw _privateConstructorUsedError;

  /// Nível atual do usuário
  @JsonKey(name: 'level')
  int get level => throw _privateConstructorUsedError;

  /// Desafios completados
  @JsonKey(name: 'challenges_completed')
  int get challengesCompleted => throw _privateConstructorUsedError;

  /// Serializes this TotalProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TotalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TotalProgressCopyWith<TotalProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotalProgressCopyWith<$Res> {
  factory $TotalProgressCopyWith(
          TotalProgress value, $Res Function(TotalProgress) then) =
      _$TotalProgressCopyWithImpl<$Res, TotalProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'workouts') int workouts,
      @JsonKey(name: 'workouts_completed') int workoutsCompleted,
      @JsonKey(name: 'points') int points,
      @JsonKey(name: 'duration') int duration,
      @JsonKey(name: 'days_trained_this_month') int daysTrainedThisMonth,
      @JsonKey(name: 'level') int level,
      @JsonKey(name: 'challenges_completed') int challengesCompleted});
}

/// @nodoc
class _$TotalProgressCopyWithImpl<$Res, $Val extends TotalProgress>
    implements $TotalProgressCopyWith<$Res> {
  _$TotalProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TotalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? workoutsCompleted = null,
    Object? points = null,
    Object? duration = null,
    Object? daysTrainedThisMonth = null,
    Object? level = null,
    Object? challengesCompleted = null,
  }) {
    return _then(_value.copyWith(
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsCompleted: null == workoutsCompleted
          ? _value.workoutsCompleted
          : workoutsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      challengesCompleted: null == challengesCompleted
          ? _value.challengesCompleted
          : challengesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TotalProgressImplCopyWith<$Res>
    implements $TotalProgressCopyWith<$Res> {
  factory _$$TotalProgressImplCopyWith(
          _$TotalProgressImpl value, $Res Function(_$TotalProgressImpl) then) =
      __$$TotalProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'workouts') int workouts,
      @JsonKey(name: 'workouts_completed') int workoutsCompleted,
      @JsonKey(name: 'points') int points,
      @JsonKey(name: 'duration') int duration,
      @JsonKey(name: 'days_trained_this_month') int daysTrainedThisMonth,
      @JsonKey(name: 'level') int level,
      @JsonKey(name: 'challenges_completed') int challengesCompleted});
}

/// @nodoc
class __$$TotalProgressImplCopyWithImpl<$Res>
    extends _$TotalProgressCopyWithImpl<$Res, _$TotalProgressImpl>
    implements _$$TotalProgressImplCopyWith<$Res> {
  __$$TotalProgressImplCopyWithImpl(
      _$TotalProgressImpl _value, $Res Function(_$TotalProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of TotalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? workoutsCompleted = null,
    Object? points = null,
    Object? duration = null,
    Object? daysTrainedThisMonth = null,
    Object? level = null,
    Object? challengesCompleted = null,
  }) {
    return _then(_$TotalProgressImpl(
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsCompleted: null == workoutsCompleted
          ? _value.workoutsCompleted
          : workoutsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      challengesCompleted: null == challengesCompleted
          ? _value.challengesCompleted
          : challengesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TotalProgressImpl implements _TotalProgress {
  const _$TotalProgressImpl(
      {@JsonKey(name: 'workouts') this.workouts = 0,
      @JsonKey(name: 'workouts_completed') this.workoutsCompleted = 0,
      @JsonKey(name: 'points') this.points = 0,
      @JsonKey(name: 'duration') this.duration = 0,
      @JsonKey(name: 'days_trained_this_month') this.daysTrainedThisMonth = 0,
      @JsonKey(name: 'level') this.level = 1,
      @JsonKey(name: 'challenges_completed') this.challengesCompleted = 0});

  factory _$TotalProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$TotalProgressImplFromJson(json);

  /// Total de treinos
  @override
  @JsonKey(name: 'workouts')
  final int workouts;

  /// Total de treinos completados
  @override
  @JsonKey(name: 'workouts_completed')
  final int workoutsCompleted;

  /// Total de pontos
  @override
  @JsonKey(name: 'points')
  final int points;

  /// Duração total em minutos
  @override
  @JsonKey(name: 'duration')
  final int duration;

  /// Dias treinados no mês atual
  @override
  @JsonKey(name: 'days_trained_this_month')
  final int daysTrainedThisMonth;

  /// Nível atual do usuário
  @override
  @JsonKey(name: 'level')
  final int level;

  /// Desafios completados
  @override
  @JsonKey(name: 'challenges_completed')
  final int challengesCompleted;

  @override
  String toString() {
    return 'TotalProgress(workouts: $workouts, workoutsCompleted: $workoutsCompleted, points: $points, duration: $duration, daysTrainedThisMonth: $daysTrainedThisMonth, level: $level, challengesCompleted: $challengesCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TotalProgressImpl &&
            (identical(other.workouts, workouts) ||
                other.workouts == workouts) &&
            (identical(other.workoutsCompleted, workoutsCompleted) ||
                other.workoutsCompleted == workoutsCompleted) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.daysTrainedThisMonth, daysTrainedThisMonth) ||
                other.daysTrainedThisMonth == daysTrainedThisMonth) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.challengesCompleted, challengesCompleted) ||
                other.challengesCompleted == challengesCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, workouts, workoutsCompleted,
      points, duration, daysTrainedThisMonth, level, challengesCompleted);

  /// Create a copy of TotalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TotalProgressImplCopyWith<_$TotalProgressImpl> get copyWith =>
      __$$TotalProgressImplCopyWithImpl<_$TotalProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TotalProgressImplToJson(
      this,
    );
  }
}

abstract class _TotalProgress implements TotalProgress {
  const factory _TotalProgress(
      {@JsonKey(name: 'workouts') final int workouts,
      @JsonKey(name: 'workouts_completed') final int workoutsCompleted,
      @JsonKey(name: 'points') final int points,
      @JsonKey(name: 'duration') final int duration,
      @JsonKey(name: 'days_trained_this_month') final int daysTrainedThisMonth,
      @JsonKey(name: 'level') final int level,
      @JsonKey(name: 'challenges_completed')
      final int challengesCompleted}) = _$TotalProgressImpl;

  factory _TotalProgress.fromJson(Map<String, dynamic> json) =
      _$TotalProgressImpl.fromJson;

  /// Total de treinos
  @override
  @JsonKey(name: 'workouts')
  int get workouts;

  /// Total de treinos completados
  @override
  @JsonKey(name: 'workouts_completed')
  int get workoutsCompleted;

  /// Total de pontos
  @override
  @JsonKey(name: 'points')
  int get points;

  /// Duração total em minutos
  @override
  @JsonKey(name: 'duration')
  int get duration;

  /// Dias treinados no mês atual
  @override
  @JsonKey(name: 'days_trained_this_month')
  int get daysTrainedThisMonth;

  /// Nível atual do usuário
  @override
  @JsonKey(name: 'level')
  int get level;

  /// Desafios completados
  @override
  @JsonKey(name: 'challenges_completed')
  int get challengesCompleted;

  /// Create a copy of TotalProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TotalProgressImplCopyWith<_$TotalProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StreakData _$StreakDataFromJson(Map<String, dynamic> json) {
  return _StreakData.fromJson(json);
}

/// @nodoc
mixin _$StreakData {
  /// Número de dias consecutivos atuais
  @JsonKey(name: 'current')
  int get current => throw _privateConstructorUsedError;

  /// Maior sequência já alcançada
  @JsonKey(name: 'longest')
  int get longest => throw _privateConstructorUsedError;

  /// Serializes this StreakData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakDataCopyWith<StreakData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakDataCopyWith<$Res> {
  factory $StreakDataCopyWith(
          StreakData value, $Res Function(StreakData) then) =
      _$StreakDataCopyWithImpl<$Res, StreakData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'current') int current,
      @JsonKey(name: 'longest') int longest});
}

/// @nodoc
class _$StreakDataCopyWithImpl<$Res, $Val extends StreakData>
    implements $StreakDataCopyWith<$Res> {
  _$StreakDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? longest = null,
  }) {
    return _then(_value.copyWith(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      longest: null == longest
          ? _value.longest
          : longest // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakDataImplCopyWith<$Res>
    implements $StreakDataCopyWith<$Res> {
  factory _$$StreakDataImplCopyWith(
          _$StreakDataImpl value, $Res Function(_$StreakDataImpl) then) =
      __$$StreakDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'current') int current,
      @JsonKey(name: 'longest') int longest});
}

/// @nodoc
class __$$StreakDataImplCopyWithImpl<$Res>
    extends _$StreakDataCopyWithImpl<$Res, _$StreakDataImpl>
    implements _$$StreakDataImplCopyWith<$Res> {
  __$$StreakDataImplCopyWithImpl(
      _$StreakDataImpl _value, $Res Function(_$StreakDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? longest = null,
  }) {
    return _then(_$StreakDataImpl(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      longest: null == longest
          ? _value.longest
          : longest // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakDataImpl implements _StreakData {
  const _$StreakDataImpl(
      {@JsonKey(name: 'current') this.current = 0,
      @JsonKey(name: 'longest') this.longest = 0});

  factory _$StreakDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakDataImplFromJson(json);

  /// Número de dias consecutivos atuais
  @override
  @JsonKey(name: 'current')
  final int current;

  /// Maior sequência já alcançada
  @override
  @JsonKey(name: 'longest')
  final int longest;

  @override
  String toString() {
    return 'StreakData(current: $current, longest: $longest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakDataImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.longest, longest) || other.longest == longest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, current, longest);

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakDataImplCopyWith<_$StreakDataImpl> get copyWith =>
      __$$StreakDataImplCopyWithImpl<_$StreakDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakDataImplToJson(
      this,
    );
  }
}

abstract class _StreakData implements StreakData {
  const factory _StreakData(
      {@JsonKey(name: 'current') final int current,
      @JsonKey(name: 'longest') final int longest}) = _$StreakDataImpl;

  factory _StreakData.fromJson(Map<String, dynamic> json) =
      _$StreakDataImpl.fromJson;

  /// Número de dias consecutivos atuais
  @override
  @JsonKey(name: 'current')
  int get current;

  /// Maior sequência já alcançada
  @override
  @JsonKey(name: 'longest')
  int get longest;

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakDataImplCopyWith<_$StreakDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AwardsData _$AwardsDataFromJson(Map<String, dynamic> json) {
  return _AwardsData.fromJson(json);
}

/// @nodoc
mixin _$AwardsData {
  /// Total de pontos
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;

  /// Conquistas do usuário
  @JsonKey(name: 'achievements')
  List<dynamic> get achievements => throw _privateConstructorUsedError;

  /// Medalhas conquistadas
  @JsonKey(name: 'badges')
  List<dynamic> get badges => throw _privateConstructorUsedError;

  /// Nível atual
  @JsonKey(name: 'level')
  int get level => throw _privateConstructorUsedError;

  /// Serializes this AwardsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AwardsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AwardsDataCopyWith<AwardsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AwardsDataCopyWith<$Res> {
  factory $AwardsDataCopyWith(
          AwardsData value, $Res Function(AwardsData) then) =
      _$AwardsDataCopyWithImpl<$Res, AwardsData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'achievements') List<dynamic> achievements,
      @JsonKey(name: 'badges') List<dynamic> badges,
      @JsonKey(name: 'level') int level});
}

/// @nodoc
class _$AwardsDataCopyWithImpl<$Res, $Val extends AwardsData>
    implements $AwardsDataCopyWith<$Res> {
  _$AwardsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AwardsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPoints = null,
    Object? achievements = null,
    Object? badges = null,
    Object? level = null,
  }) {
    return _then(_value.copyWith(
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AwardsDataImplCopyWith<$Res>
    implements $AwardsDataCopyWith<$Res> {
  factory _$$AwardsDataImplCopyWith(
          _$AwardsDataImpl value, $Res Function(_$AwardsDataImpl) then) =
      __$$AwardsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'achievements') List<dynamic> achievements,
      @JsonKey(name: 'badges') List<dynamic> badges,
      @JsonKey(name: 'level') int level});
}

/// @nodoc
class __$$AwardsDataImplCopyWithImpl<$Res>
    extends _$AwardsDataCopyWithImpl<$Res, _$AwardsDataImpl>
    implements _$$AwardsDataImplCopyWith<$Res> {
  __$$AwardsDataImplCopyWithImpl(
      _$AwardsDataImpl _value, $Res Function(_$AwardsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of AwardsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPoints = null,
    Object? achievements = null,
    Object? badges = null,
    Object? level = null,
  }) {
    return _then(_$AwardsDataImpl(
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AwardsDataImpl implements _AwardsData {
  const _$AwardsDataImpl(
      {@JsonKey(name: 'total_points') this.totalPoints = 0,
      @JsonKey(name: 'achievements')
      final List<dynamic> achievements = const [],
      @JsonKey(name: 'badges') final List<dynamic> badges = const [],
      @JsonKey(name: 'level') this.level = 1})
      : _achievements = achievements,
        _badges = badges;

  factory _$AwardsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AwardsDataImplFromJson(json);

  /// Total de pontos
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Conquistas do usuário
  final List<dynamic> _achievements;

  /// Conquistas do usuário
  @override
  @JsonKey(name: 'achievements')
  List<dynamic> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  /// Medalhas conquistadas
  final List<dynamic> _badges;

  /// Medalhas conquistadas
  @override
  @JsonKey(name: 'badges')
  List<dynamic> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  /// Nível atual
  @override
  @JsonKey(name: 'level')
  final int level;

  @override
  String toString() {
    return 'AwardsData(totalPoints: $totalPoints, achievements: $achievements, badges: $badges, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AwardsDataImpl &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalPoints,
      const DeepCollectionEquality().hash(_achievements),
      const DeepCollectionEquality().hash(_badges),
      level);

  /// Create a copy of AwardsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AwardsDataImplCopyWith<_$AwardsDataImpl> get copyWith =>
      __$$AwardsDataImplCopyWithImpl<_$AwardsDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AwardsDataImplToJson(
      this,
    );
  }
}

abstract class _AwardsData implements AwardsData {
  const factory _AwardsData(
      {@JsonKey(name: 'total_points') final int totalPoints,
      @JsonKey(name: 'achievements') final List<dynamic> achievements,
      @JsonKey(name: 'badges') final List<dynamic> badges,
      @JsonKey(name: 'level') final int level}) = _$AwardsDataImpl;

  factory _AwardsData.fromJson(Map<String, dynamic> json) =
      _$AwardsDataImpl.fromJson;

  /// Total de pontos
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;

  /// Conquistas do usuário
  @override
  @JsonKey(name: 'achievements')
  List<dynamic> get achievements;

  /// Medalhas conquistadas
  @override
  @JsonKey(name: 'badges')
  List<dynamic> get badges;

  /// Nível atual
  @override
  @JsonKey(name: 'level')
  int get level;

  /// Create a copy of AwardsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AwardsDataImplCopyWith<_$AwardsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DayDetailsData _$DayDetailsDataFromJson(Map<String, dynamic> json) {
  return _DayDetailsData.fromJson(json);
}

/// @nodoc
mixin _$DayDetailsData {
  /// Data do dia
  @JsonKey(name: 'date')
  DateTime get date => throw _privateConstructorUsedError;

  /// Total de treinos
  @JsonKey(name: 'total_workouts')
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Total de minutos
  @JsonKey(name: 'total_minutes')
  int get totalMinutes => throw _privateConstructorUsedError;

  /// Total de pontos
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;

  /// Lista de treinos
  @JsonKey(name: 'workouts')
  List<WorkoutSummary> get workouts => throw _privateConstructorUsedError;

  /// Serializes this DayDetailsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayDetailsDataCopyWith<DayDetailsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayDetailsDataCopyWith<$Res> {
  factory $DayDetailsDataCopyWith(
          DayDetailsData value, $Res Function(DayDetailsData) then) =
      _$DayDetailsDataCopyWithImpl<$Res, DayDetailsData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'date') DateTime date,
      @JsonKey(name: 'total_workouts') int totalWorkouts,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'workouts') List<WorkoutSummary> workouts});
}

/// @nodoc
class _$DayDetailsDataCopyWithImpl<$Res, $Val extends DayDetailsData>
    implements $DayDetailsDataCopyWith<$Res> {
  _$DayDetailsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalWorkouts = null,
    Object? totalMinutes = null,
    Object? totalPoints = null,
    Object? workouts = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSummary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayDetailsDataImplCopyWith<$Res>
    implements $DayDetailsDataCopyWith<$Res> {
  factory _$$DayDetailsDataImplCopyWith(_$DayDetailsDataImpl value,
          $Res Function(_$DayDetailsDataImpl) then) =
      __$$DayDetailsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'date') DateTime date,
      @JsonKey(name: 'total_workouts') int totalWorkouts,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'workouts') List<WorkoutSummary> workouts});
}

/// @nodoc
class __$$DayDetailsDataImplCopyWithImpl<$Res>
    extends _$DayDetailsDataCopyWithImpl<$Res, _$DayDetailsDataImpl>
    implements _$$DayDetailsDataImplCopyWith<$Res> {
  __$$DayDetailsDataImplCopyWithImpl(
      _$DayDetailsDataImpl _value, $Res Function(_$DayDetailsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DayDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalWorkouts = null,
    Object? totalMinutes = null,
    Object? totalPoints = null,
    Object? workouts = null,
  }) {
    return _then(_$DayDetailsDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      workouts: null == workouts
          ? _value._workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSummary>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DayDetailsDataImpl implements _DayDetailsData {
  const _$DayDetailsDataImpl(
      {@JsonKey(name: 'date') required this.date,
      @JsonKey(name: 'total_workouts') this.totalWorkouts = 0,
      @JsonKey(name: 'total_minutes') this.totalMinutes = 0,
      @JsonKey(name: 'total_points') this.totalPoints = 0,
      @JsonKey(name: 'workouts')
      final List<WorkoutSummary> workouts = const []})
      : _workouts = workouts;

  factory _$DayDetailsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayDetailsDataImplFromJson(json);

  /// Data do dia
  @override
  @JsonKey(name: 'date')
  final DateTime date;

  /// Total de treinos
  @override
  @JsonKey(name: 'total_workouts')
  final int totalWorkouts;

  /// Total de minutos
  @override
  @JsonKey(name: 'total_minutes')
  final int totalMinutes;

  /// Total de pontos
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Lista de treinos
  final List<WorkoutSummary> _workouts;

  /// Lista de treinos
  @override
  @JsonKey(name: 'workouts')
  List<WorkoutSummary> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  @override
  String toString() {
    return 'DayDetailsData(date: $date, totalWorkouts: $totalWorkouts, totalMinutes: $totalMinutes, totalPoints: $totalPoints, workouts: $workouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayDetailsDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            const DeepCollectionEquality().equals(other._workouts, _workouts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      totalWorkouts,
      totalMinutes,
      totalPoints,
      const DeepCollectionEquality().hash(_workouts));

  /// Create a copy of DayDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayDetailsDataImplCopyWith<_$DayDetailsDataImpl> get copyWith =>
      __$$DayDetailsDataImplCopyWithImpl<_$DayDetailsDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayDetailsDataImplToJson(
      this,
    );
  }
}

abstract class _DayDetailsData implements DayDetailsData {
  const factory _DayDetailsData(
          {@JsonKey(name: 'date') required final DateTime date,
          @JsonKey(name: 'total_workouts') final int totalWorkouts,
          @JsonKey(name: 'total_minutes') final int totalMinutes,
          @JsonKey(name: 'total_points') final int totalPoints,
          @JsonKey(name: 'workouts') final List<WorkoutSummary> workouts}) =
      _$DayDetailsDataImpl;

  factory _DayDetailsData.fromJson(Map<String, dynamic> json) =
      _$DayDetailsDataImpl.fromJson;

  /// Data do dia
  @override
  @JsonKey(name: 'date')
  DateTime get date;

  /// Total de treinos
  @override
  @JsonKey(name: 'total_workouts')
  int get totalWorkouts;

  /// Total de minutos
  @override
  @JsonKey(name: 'total_minutes')
  int get totalMinutes;

  /// Total de pontos
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;

  /// Lista de treinos
  @override
  @JsonKey(name: 'workouts')
  List<WorkoutSummary> get workouts;

  /// Create a copy of DayDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayDetailsDataImplCopyWith<_$DayDetailsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
