// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cardio_challenge_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CardioChallengeProgress _$CardioChallengeProgressFromJson(
    Map<String, dynamic> json) {
  return _CardioChallengeProgress.fromJson(json);
}

/// @nodoc
mixin _$CardioChallengeProgress {
  /// Posição do usuário no ranking (1 = primeiro lugar)
  @JsonKey(name: 'position')
  int get position => throw _privateConstructorUsedError;

  /// Total de minutos de cardio do usuário
  @JsonKey(name: 'total_minutes')
  int get totalMinutes => throw _privateConstructorUsedError;

  /// Minutos de cardio do dia anterior
  @JsonKey(name: 'previous_day_minutes')
  int get previousDayMinutes => throw _privateConstructorUsedError;

  /// Minutos de cardio de hoje
  @JsonKey(name: 'today_minutes')
  int get todayMinutes => throw _privateConstructorUsedError;

  /// Percentual de melhoria em relação ao dia anterior
  @JsonKey(name: 'improvement_percentage')
  double get improvementPercentage => throw _privateConstructorUsedError;

  /// Se o usuário está participando do desafio
  @JsonKey(name: 'is_participating')
  bool get isParticipating => throw _privateConstructorUsedError;

  /// Total de participantes no desafio
  @JsonKey(name: 'total_participants')
  int get totalParticipants => throw _privateConstructorUsedError;

  /// Data da última atualização
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this CardioChallengeProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardioChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardioChallengeProgressCopyWith<CardioChallengeProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardioChallengeProgressCopyWith<$Res> {
  factory $CardioChallengeProgressCopyWith(CardioChallengeProgress value,
          $Res Function(CardioChallengeProgress) then) =
      _$CardioChallengeProgressCopyWithImpl<$Res, CardioChallengeProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'position') int position,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      @JsonKey(name: 'previous_day_minutes') int previousDayMinutes,
      @JsonKey(name: 'today_minutes') int todayMinutes,
      @JsonKey(name: 'improvement_percentage') double improvementPercentage,
      @JsonKey(name: 'is_participating') bool isParticipating,
      @JsonKey(name: 'total_participants') int totalParticipants,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});
}

/// @nodoc
class _$CardioChallengeProgressCopyWithImpl<$Res,
        $Val extends CardioChallengeProgress>
    implements $CardioChallengeProgressCopyWith<$Res> {
  _$CardioChallengeProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardioChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? totalMinutes = null,
    Object? previousDayMinutes = null,
    Object? todayMinutes = null,
    Object? improvementPercentage = null,
    Object? isParticipating = null,
    Object? totalParticipants = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      previousDayMinutes: null == previousDayMinutes
          ? _value.previousDayMinutes
          : previousDayMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      todayMinutes: null == todayMinutes
          ? _value.todayMinutes
          : todayMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      improvementPercentage: null == improvementPercentage
          ? _value.improvementPercentage
          : improvementPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isParticipating: null == isParticipating
          ? _value.isParticipating
          : isParticipating // ignore: cast_nullable_to_non_nullable
              as bool,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardioChallengeProgressImplCopyWith<$Res>
    implements $CardioChallengeProgressCopyWith<$Res> {
  factory _$$CardioChallengeProgressImplCopyWith(
          _$CardioChallengeProgressImpl value,
          $Res Function(_$CardioChallengeProgressImpl) then) =
      __$$CardioChallengeProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'position') int position,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      @JsonKey(name: 'previous_day_minutes') int previousDayMinutes,
      @JsonKey(name: 'today_minutes') int todayMinutes,
      @JsonKey(name: 'improvement_percentage') double improvementPercentage,
      @JsonKey(name: 'is_participating') bool isParticipating,
      @JsonKey(name: 'total_participants') int totalParticipants,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});
}

/// @nodoc
class __$$CardioChallengeProgressImplCopyWithImpl<$Res>
    extends _$CardioChallengeProgressCopyWithImpl<$Res,
        _$CardioChallengeProgressImpl>
    implements _$$CardioChallengeProgressImplCopyWith<$Res> {
  __$$CardioChallengeProgressImplCopyWithImpl(
      _$CardioChallengeProgressImpl _value,
      $Res Function(_$CardioChallengeProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of CardioChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? totalMinutes = null,
    Object? previousDayMinutes = null,
    Object? todayMinutes = null,
    Object? improvementPercentage = null,
    Object? isParticipating = null,
    Object? totalParticipants = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$CardioChallengeProgressImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      previousDayMinutes: null == previousDayMinutes
          ? _value.previousDayMinutes
          : previousDayMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      todayMinutes: null == todayMinutes
          ? _value.todayMinutes
          : todayMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      improvementPercentage: null == improvementPercentage
          ? _value.improvementPercentage
          : improvementPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isParticipating: null == isParticipating
          ? _value.isParticipating
          : isParticipating // ignore: cast_nullable_to_non_nullable
              as bool,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardioChallengeProgressImpl implements _CardioChallengeProgress {
  const _$CardioChallengeProgressImpl(
      {@JsonKey(name: 'position') required this.position,
      @JsonKey(name: 'total_minutes') required this.totalMinutes,
      @JsonKey(name: 'previous_day_minutes') this.previousDayMinutes = 0,
      @JsonKey(name: 'today_minutes') this.todayMinutes = 0,
      @JsonKey(name: 'improvement_percentage') this.improvementPercentage = 0.0,
      @JsonKey(name: 'is_participating') this.isParticipating = false,
      @JsonKey(name: 'total_participants') this.totalParticipants = 0,
      @JsonKey(name: 'last_updated') required this.lastUpdated});

  factory _$CardioChallengeProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardioChallengeProgressImplFromJson(json);

  /// Posição do usuário no ranking (1 = primeiro lugar)
  @override
  @JsonKey(name: 'position')
  final int position;

  /// Total de minutos de cardio do usuário
  @override
  @JsonKey(name: 'total_minutes')
  final int totalMinutes;

  /// Minutos de cardio do dia anterior
  @override
  @JsonKey(name: 'previous_day_minutes')
  final int previousDayMinutes;

  /// Minutos de cardio de hoje
  @override
  @JsonKey(name: 'today_minutes')
  final int todayMinutes;

  /// Percentual de melhoria em relação ao dia anterior
  @override
  @JsonKey(name: 'improvement_percentage')
  final double improvementPercentage;

  /// Se o usuário está participando do desafio
  @override
  @JsonKey(name: 'is_participating')
  final bool isParticipating;

  /// Total de participantes no desafio
  @override
  @JsonKey(name: 'total_participants')
  final int totalParticipants;

  /// Data da última atualização
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'CardioChallengeProgress(position: $position, totalMinutes: $totalMinutes, previousDayMinutes: $previousDayMinutes, todayMinutes: $todayMinutes, improvementPercentage: $improvementPercentage, isParticipating: $isParticipating, totalParticipants: $totalParticipants, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardioChallengeProgressImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.previousDayMinutes, previousDayMinutes) ||
                other.previousDayMinutes == previousDayMinutes) &&
            (identical(other.todayMinutes, todayMinutes) ||
                other.todayMinutes == todayMinutes) &&
            (identical(other.improvementPercentage, improvementPercentage) ||
                other.improvementPercentage == improvementPercentage) &&
            (identical(other.isParticipating, isParticipating) ||
                other.isParticipating == isParticipating) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      position,
      totalMinutes,
      previousDayMinutes,
      todayMinutes,
      improvementPercentage,
      isParticipating,
      totalParticipants,
      lastUpdated);

  /// Create a copy of CardioChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardioChallengeProgressImplCopyWith<_$CardioChallengeProgressImpl>
      get copyWith => __$$CardioChallengeProgressImplCopyWithImpl<
          _$CardioChallengeProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardioChallengeProgressImplToJson(
      this,
    );
  }
}

abstract class _CardioChallengeProgress implements CardioChallengeProgress {
  const factory _CardioChallengeProgress(
          {@JsonKey(name: 'position') required final int position,
          @JsonKey(name: 'total_minutes') required final int totalMinutes,
          @JsonKey(name: 'previous_day_minutes') final int previousDayMinutes,
          @JsonKey(name: 'today_minutes') final int todayMinutes,
          @JsonKey(name: 'improvement_percentage')
          final double improvementPercentage,
          @JsonKey(name: 'is_participating') final bool isParticipating,
          @JsonKey(name: 'total_participants') final int totalParticipants,
          @JsonKey(name: 'last_updated') required final DateTime lastUpdated}) =
      _$CardioChallengeProgressImpl;

  factory _CardioChallengeProgress.fromJson(Map<String, dynamic> json) =
      _$CardioChallengeProgressImpl.fromJson;

  /// Posição do usuário no ranking (1 = primeiro lugar)
  @override
  @JsonKey(name: 'position')
  int get position;

  /// Total de minutos de cardio do usuário
  @override
  @JsonKey(name: 'total_minutes')
  int get totalMinutes;

  /// Minutos de cardio do dia anterior
  @override
  @JsonKey(name: 'previous_day_minutes')
  int get previousDayMinutes;

  /// Minutos de cardio de hoje
  @override
  @JsonKey(name: 'today_minutes')
  int get todayMinutes;

  /// Percentual de melhoria em relação ao dia anterior
  @override
  @JsonKey(name: 'improvement_percentage')
  double get improvementPercentage;

  /// Se o usuário está participando do desafio
  @override
  @JsonKey(name: 'is_participating')
  bool get isParticipating;

  /// Total de participantes no desafio
  @override
  @JsonKey(name: 'total_participants')
  int get totalParticipants;

  /// Data da última atualização
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;

  /// Create a copy of CardioChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardioChallengeProgressImplCopyWith<_$CardioChallengeProgressImpl>
      get copyWith => throw _privateConstructorUsedError;
}
