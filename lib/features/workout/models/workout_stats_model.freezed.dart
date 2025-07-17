// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutStats _$WorkoutStatsFromJson(Map<String, dynamic> json) {
  return _WorkoutStats.fromJson(json);
}

/// @nodoc
mixin _$WorkoutStats {
  /// ID do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Total de treinos realizados
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Número de treinos no mês atual
  int get monthWorkouts => throw _privateConstructorUsedError;

  /// Número de treinos na semana atual
  int get weekWorkouts => throw _privateConstructorUsedError;

  /// Maior sequência de dias consecutivos com treino
  int get bestStreak => throw _privateConstructorUsedError;

  /// Sequência atual de dias consecutivos com treino
  int get currentStreak => throw _privateConstructorUsedError;

  /// Frequência mensal em percentual (baseado em meta de 20 treinos/mês)
  double get frequencyPercentage => throw _privateConstructorUsedError;

  /// Total de minutos treinados
  int get totalMinutes => throw _privateConstructorUsedError;

  /// Número de dias treinados este mês
  int get monthWorkoutDays => throw _privateConstructorUsedError;

  /// Número de dias que treinou na semana atual
  int get weekWorkoutDays => throw _privateConstructorUsedError;

  /// Estatísticas por dia da semana (para gráficos)
  Map<String, int>? get weekdayStats => throw _privateConstructorUsedError;

  /// Minutos treinados por dia da semana
  Map<String, int>? get weekdayMinutes => throw _privateConstructorUsedError;

  /// Data da última atualização das estatísticas
  DateTime? get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this WorkoutStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutStatsCopyWith<WorkoutStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutStatsCopyWith<$Res> {
  factory $WorkoutStatsCopyWith(
          WorkoutStats value, $Res Function(WorkoutStats) then) =
      _$WorkoutStatsCopyWithImpl<$Res, WorkoutStats>;
  @useResult
  $Res call(
      {String userId,
      int totalWorkouts,
      int monthWorkouts,
      int weekWorkouts,
      int bestStreak,
      int currentStreak,
      double frequencyPercentage,
      int totalMinutes,
      int monthWorkoutDays,
      int weekWorkoutDays,
      Map<String, int>? weekdayStats,
      Map<String, int>? weekdayMinutes,
      DateTime? lastUpdatedAt});
}

/// @nodoc
class _$WorkoutStatsCopyWithImpl<$Res, $Val extends WorkoutStats>
    implements $WorkoutStatsCopyWith<$Res> {
  _$WorkoutStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalWorkouts = null,
    Object? monthWorkouts = null,
    Object? weekWorkouts = null,
    Object? bestStreak = null,
    Object? currentStreak = null,
    Object? frequencyPercentage = null,
    Object? totalMinutes = null,
    Object? monthWorkoutDays = null,
    Object? weekWorkoutDays = null,
    Object? weekdayStats = freezed,
    Object? weekdayMinutes = freezed,
    Object? lastUpdatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      monthWorkouts: null == monthWorkouts
          ? _value.monthWorkouts
          : monthWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      weekWorkouts: null == weekWorkouts
          ? _value.weekWorkouts
          : weekWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      frequencyPercentage: null == frequencyPercentage
          ? _value.frequencyPercentage
          : frequencyPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      monthWorkoutDays: null == monthWorkoutDays
          ? _value.monthWorkoutDays
          : monthWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
      weekWorkoutDays: null == weekWorkoutDays
          ? _value.weekWorkoutDays
          : weekWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
      weekdayStats: freezed == weekdayStats
          ? _value.weekdayStats
          : weekdayStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      weekdayMinutes: freezed == weekdayMinutes
          ? _value.weekdayMinutes
          : weekdayMinutes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutStatsImplCopyWith<$Res>
    implements $WorkoutStatsCopyWith<$Res> {
  factory _$$WorkoutStatsImplCopyWith(
          _$WorkoutStatsImpl value, $Res Function(_$WorkoutStatsImpl) then) =
      __$$WorkoutStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      int totalWorkouts,
      int monthWorkouts,
      int weekWorkouts,
      int bestStreak,
      int currentStreak,
      double frequencyPercentage,
      int totalMinutes,
      int monthWorkoutDays,
      int weekWorkoutDays,
      Map<String, int>? weekdayStats,
      Map<String, int>? weekdayMinutes,
      DateTime? lastUpdatedAt});
}

/// @nodoc
class __$$WorkoutStatsImplCopyWithImpl<$Res>
    extends _$WorkoutStatsCopyWithImpl<$Res, _$WorkoutStatsImpl>
    implements _$$WorkoutStatsImplCopyWith<$Res> {
  __$$WorkoutStatsImplCopyWithImpl(
      _$WorkoutStatsImpl _value, $Res Function(_$WorkoutStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalWorkouts = null,
    Object? monthWorkouts = null,
    Object? weekWorkouts = null,
    Object? bestStreak = null,
    Object? currentStreak = null,
    Object? frequencyPercentage = null,
    Object? totalMinutes = null,
    Object? monthWorkoutDays = null,
    Object? weekWorkoutDays = null,
    Object? weekdayStats = freezed,
    Object? weekdayMinutes = freezed,
    Object? lastUpdatedAt = freezed,
  }) {
    return _then(_$WorkoutStatsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      monthWorkouts: null == monthWorkouts
          ? _value.monthWorkouts
          : monthWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      weekWorkouts: null == weekWorkouts
          ? _value.weekWorkouts
          : weekWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      frequencyPercentage: null == frequencyPercentage
          ? _value.frequencyPercentage
          : frequencyPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      monthWorkoutDays: null == monthWorkoutDays
          ? _value.monthWorkoutDays
          : monthWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
      weekWorkoutDays: null == weekWorkoutDays
          ? _value.weekWorkoutDays
          : weekWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
      weekdayStats: freezed == weekdayStats
          ? _value._weekdayStats
          : weekdayStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      weekdayMinutes: freezed == weekdayMinutes
          ? _value._weekdayMinutes
          : weekdayMinutes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutStatsImpl extends _WorkoutStats {
  const _$WorkoutStatsImpl(
      {required this.userId,
      this.totalWorkouts = 0,
      this.monthWorkouts = 0,
      this.weekWorkouts = 0,
      this.bestStreak = 0,
      this.currentStreak = 0,
      this.frequencyPercentage = 0.0,
      this.totalMinutes = 0,
      this.monthWorkoutDays = 0,
      this.weekWorkoutDays = 0,
      final Map<String, int>? weekdayStats,
      final Map<String, int>? weekdayMinutes,
      this.lastUpdatedAt})
      : _weekdayStats = weekdayStats,
        _weekdayMinutes = weekdayMinutes,
        super._();

  factory _$WorkoutStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutStatsImplFromJson(json);

  /// ID do usuário
  @override
  final String userId;

  /// Total de treinos realizados
  @override
  @JsonKey()
  final int totalWorkouts;

  /// Número de treinos no mês atual
  @override
  @JsonKey()
  final int monthWorkouts;

  /// Número de treinos na semana atual
  @override
  @JsonKey()
  final int weekWorkouts;

  /// Maior sequência de dias consecutivos com treino
  @override
  @JsonKey()
  final int bestStreak;

  /// Sequência atual de dias consecutivos com treino
  @override
  @JsonKey()
  final int currentStreak;

  /// Frequência mensal em percentual (baseado em meta de 20 treinos/mês)
  @override
  @JsonKey()
  final double frequencyPercentage;

  /// Total de minutos treinados
  @override
  @JsonKey()
  final int totalMinutes;

  /// Número de dias treinados este mês
  @override
  @JsonKey()
  final int monthWorkoutDays;

  /// Número de dias que treinou na semana atual
  @override
  @JsonKey()
  final int weekWorkoutDays;

  /// Estatísticas por dia da semana (para gráficos)
  final Map<String, int>? _weekdayStats;

  /// Estatísticas por dia da semana (para gráficos)
  @override
  Map<String, int>? get weekdayStats {
    final value = _weekdayStats;
    if (value == null) return null;
    if (_weekdayStats is EqualUnmodifiableMapView) return _weekdayStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Minutos treinados por dia da semana
  final Map<String, int>? _weekdayMinutes;

  /// Minutos treinados por dia da semana
  @override
  Map<String, int>? get weekdayMinutes {
    final value = _weekdayMinutes;
    if (value == null) return null;
    if (_weekdayMinutes is EqualUnmodifiableMapView) return _weekdayMinutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Data da última atualização das estatísticas
  @override
  final DateTime? lastUpdatedAt;

  @override
  String toString() {
    return 'WorkoutStats(userId: $userId, totalWorkouts: $totalWorkouts, monthWorkouts: $monthWorkouts, weekWorkouts: $weekWorkouts, bestStreak: $bestStreak, currentStreak: $currentStreak, frequencyPercentage: $frequencyPercentage, totalMinutes: $totalMinutes, monthWorkoutDays: $monthWorkoutDays, weekWorkoutDays: $weekWorkoutDays, weekdayStats: $weekdayStats, weekdayMinutes: $weekdayMinutes, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.monthWorkouts, monthWorkouts) ||
                other.monthWorkouts == monthWorkouts) &&
            (identical(other.weekWorkouts, weekWorkouts) ||
                other.weekWorkouts == weekWorkouts) &&
            (identical(other.bestStreak, bestStreak) ||
                other.bestStreak == bestStreak) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.frequencyPercentage, frequencyPercentage) ||
                other.frequencyPercentage == frequencyPercentage) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.monthWorkoutDays, monthWorkoutDays) ||
                other.monthWorkoutDays == monthWorkoutDays) &&
            (identical(other.weekWorkoutDays, weekWorkoutDays) ||
                other.weekWorkoutDays == weekWorkoutDays) &&
            const DeepCollectionEquality()
                .equals(other._weekdayStats, _weekdayStats) &&
            const DeepCollectionEquality()
                .equals(other._weekdayMinutes, _weekdayMinutes) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      totalWorkouts,
      monthWorkouts,
      weekWorkouts,
      bestStreak,
      currentStreak,
      frequencyPercentage,
      totalMinutes,
      monthWorkoutDays,
      weekWorkoutDays,
      const DeepCollectionEquality().hash(_weekdayStats),
      const DeepCollectionEquality().hash(_weekdayMinutes),
      lastUpdatedAt);

  /// Create a copy of WorkoutStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStatsImplCopyWith<_$WorkoutStatsImpl> get copyWith =>
      __$$WorkoutStatsImplCopyWithImpl<_$WorkoutStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutStatsImplToJson(
      this,
    );
  }
}

abstract class _WorkoutStats extends WorkoutStats {
  const factory _WorkoutStats(
      {required final String userId,
      final int totalWorkouts,
      final int monthWorkouts,
      final int weekWorkouts,
      final int bestStreak,
      final int currentStreak,
      final double frequencyPercentage,
      final int totalMinutes,
      final int monthWorkoutDays,
      final int weekWorkoutDays,
      final Map<String, int>? weekdayStats,
      final Map<String, int>? weekdayMinutes,
      final DateTime? lastUpdatedAt}) = _$WorkoutStatsImpl;
  const _WorkoutStats._() : super._();

  factory _WorkoutStats.fromJson(Map<String, dynamic> json) =
      _$WorkoutStatsImpl.fromJson;

  /// ID do usuário
  @override
  String get userId;

  /// Total de treinos realizados
  @override
  int get totalWorkouts;

  /// Número de treinos no mês atual
  @override
  int get monthWorkouts;

  /// Número de treinos na semana atual
  @override
  int get weekWorkouts;

  /// Maior sequência de dias consecutivos com treino
  @override
  int get bestStreak;

  /// Sequência atual de dias consecutivos com treino
  @override
  int get currentStreak;

  /// Frequência mensal em percentual (baseado em meta de 20 treinos/mês)
  @override
  double get frequencyPercentage;

  /// Total de minutos treinados
  @override
  int get totalMinutes;

  /// Número de dias treinados este mês
  @override
  int get monthWorkoutDays;

  /// Número de dias que treinou na semana atual
  @override
  int get weekWorkoutDays;

  /// Estatísticas por dia da semana (para gráficos)
  @override
  Map<String, int>? get weekdayStats;

  /// Minutos treinados por dia da semana
  @override
  Map<String, int>? get weekdayMinutes;

  /// Data da última atualização das estatísticas
  @override
  DateTime? get lastUpdatedAt;

  /// Create a copy of WorkoutStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutStatsImplCopyWith<_$WorkoutStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
