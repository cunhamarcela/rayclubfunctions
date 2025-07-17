// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckInResult _$CheckInResultFromJson(Map<String, dynamic> json) {
  return _CheckInResult.fromJson(json);
}

/// @nodoc
mixin _$CheckInResult {
  /// ID do desafio
  String get challengeId => throw _privateConstructorUsedError;

  /// ID do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Pontos ganhos com o check-in
  int get points => throw _privateConstructorUsedError;

  /// Mensagem de resultado
  String get message => throw _privateConstructorUsedError;

  /// Data e hora do check-in
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Indica se é o primeiro check-in do dia
  bool get isFirstToday => throw _privateConstructorUsedError;

  /// Streak atual (dias consecutivos)
  int get streak => throw _privateConstructorUsedError;

  /// Total de pontos do usuário no desafio
  int get totalPoints => throw _privateConstructorUsedError;

  /// Serializes this CheckInResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInResultCopyWith<CheckInResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInResultCopyWith<$Res> {
  factory $CheckInResultCopyWith(
          CheckInResult value, $Res Function(CheckInResult) then) =
      _$CheckInResultCopyWithImpl<$Res, CheckInResult>;
  @useResult
  $Res call(
      {String challengeId,
      String userId,
      int points,
      String message,
      DateTime createdAt,
      bool isFirstToday,
      int streak,
      int totalPoints});
}

/// @nodoc
class _$CheckInResultCopyWithImpl<$Res, $Val extends CheckInResult>
    implements $CheckInResultCopyWith<$Res> {
  _$CheckInResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? userId = null,
    Object? points = null,
    Object? message = null,
    Object? createdAt = null,
    Object? isFirstToday = null,
    Object? streak = null,
    Object? totalPoints = null,
  }) {
    return _then(_value.copyWith(
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFirstToday: null == isFirstToday
          ? _value.isFirstToday
          : isFirstToday // ignore: cast_nullable_to_non_nullable
              as bool,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInResultImplCopyWith<$Res>
    implements $CheckInResultCopyWith<$Res> {
  factory _$$CheckInResultImplCopyWith(
          _$CheckInResultImpl value, $Res Function(_$CheckInResultImpl) then) =
      __$$CheckInResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String challengeId,
      String userId,
      int points,
      String message,
      DateTime createdAt,
      bool isFirstToday,
      int streak,
      int totalPoints});
}

/// @nodoc
class __$$CheckInResultImplCopyWithImpl<$Res>
    extends _$CheckInResultCopyWithImpl<$Res, _$CheckInResultImpl>
    implements _$$CheckInResultImplCopyWith<$Res> {
  __$$CheckInResultImplCopyWithImpl(
      _$CheckInResultImpl _value, $Res Function(_$CheckInResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? userId = null,
    Object? points = null,
    Object? message = null,
    Object? createdAt = null,
    Object? isFirstToday = null,
    Object? streak = null,
    Object? totalPoints = null,
  }) {
    return _then(_$CheckInResultImpl(
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFirstToday: null == isFirstToday
          ? _value.isFirstToday
          : isFirstToday // ignore: cast_nullable_to_non_nullable
              as bool,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
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
class _$CheckInResultImpl
    with DiagnosticableTreeMixin
    implements _CheckInResult {
  const _$CheckInResultImpl(
      {required this.challengeId,
      required this.userId,
      required this.points,
      required this.message,
      required this.createdAt,
      this.isFirstToday = false,
      this.streak = 0,
      this.totalPoints = 0});

  factory _$CheckInResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInResultImplFromJson(json);

  /// ID do desafio
  @override
  final String challengeId;

  /// ID do usuário
  @override
  final String userId;

  /// Pontos ganhos com o check-in
  @override
  final int points;

  /// Mensagem de resultado
  @override
  final String message;

  /// Data e hora do check-in
  @override
  final DateTime createdAt;

  /// Indica se é o primeiro check-in do dia
  @override
  @JsonKey()
  final bool isFirstToday;

  /// Streak atual (dias consecutivos)
  @override
  @JsonKey()
  final int streak;

  /// Total de pontos do usuário no desafio
  @override
  @JsonKey()
  final int totalPoints;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CheckInResult(challengeId: $challengeId, userId: $userId, points: $points, message: $message, createdAt: $createdAt, isFirstToday: $isFirstToday, streak: $streak, totalPoints: $totalPoints)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CheckInResult'))
      ..add(DiagnosticsProperty('challengeId', challengeId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('points', points))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('isFirstToday', isFirstToday))
      ..add(DiagnosticsProperty('streak', streak))
      ..add(DiagnosticsProperty('totalPoints', totalPoints));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInResultImpl &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isFirstToday, isFirstToday) ||
                other.isFirstToday == isFirstToday) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, challengeId, userId, points,
      message, createdAt, isFirstToday, streak, totalPoints);

  /// Create a copy of CheckInResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInResultImplCopyWith<_$CheckInResultImpl> get copyWith =>
      __$$CheckInResultImplCopyWithImpl<_$CheckInResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInResultImplToJson(
      this,
    );
  }
}

abstract class _CheckInResult implements CheckInResult {
  const factory _CheckInResult(
      {required final String challengeId,
      required final String userId,
      required final int points,
      required final String message,
      required final DateTime createdAt,
      final bool isFirstToday,
      final int streak,
      final int totalPoints}) = _$CheckInResultImpl;

  factory _CheckInResult.fromJson(Map<String, dynamic> json) =
      _$CheckInResultImpl.fromJson;

  /// ID do desafio
  @override
  String get challengeId;

  /// ID do usuário
  @override
  String get userId;

  /// Pontos ganhos com o check-in
  @override
  int get points;

  /// Mensagem de resultado
  @override
  String get message;

  /// Data e hora do check-in
  @override
  DateTime get createdAt;

  /// Indica se é o primeiro check-in do dia
  @override
  bool get isFirstToday;

  /// Streak atual (dias consecutivos)
  @override
  int get streak;

  /// Total de pontos do usuário no desafio
  @override
  int get totalPoints;

  /// Create a copy of CheckInResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInResultImplCopyWith<_$CheckInResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeCheckIn _$ChallengeCheckInFromJson(Map<String, dynamic> json) {
  return _ChallengeCheckIn.fromJson(json);
}

/// @nodoc
mixin _$ChallengeCheckIn {
  /// ID único do check-in
  String get id => throw _privateConstructorUsedError;

  /// ID do desafio
  String get challengeId => throw _privateConstructorUsedError;

  /// ID do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Pontos ganhos com este check-in
  int get points => throw _privateConstructorUsedError;

  /// Data e hora do check-in
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Tipo de atividade (opcional)
  String? get activityType => throw _privateConstructorUsedError;

  /// Notas ou comentários (opcional)
  String? get notes => throw _privateConstructorUsedError;

  /// Dados adicionais do check-in (JSON)
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ChallengeCheckIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeCheckInCopyWith<ChallengeCheckIn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCheckInCopyWith<$Res> {
  factory $ChallengeCheckInCopyWith(
          ChallengeCheckIn value, $Res Function(ChallengeCheckIn) then) =
      _$ChallengeCheckInCopyWithImpl<$Res, ChallengeCheckIn>;
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String userId,
      int points,
      DateTime createdAt,
      String? activityType,
      String? notes,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ChallengeCheckInCopyWithImpl<$Res, $Val extends ChallengeCheckIn>
    implements $ChallengeCheckInCopyWith<$Res> {
  _$ChallengeCheckInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? points = null,
    Object? createdAt = null,
    Object? activityType = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      activityType: freezed == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeCheckInImplCopyWith<$Res>
    implements $ChallengeCheckInCopyWith<$Res> {
  factory _$$ChallengeCheckInImplCopyWith(_$ChallengeCheckInImpl value,
          $Res Function(_$ChallengeCheckInImpl) then) =
      __$$ChallengeCheckInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String userId,
      int points,
      DateTime createdAt,
      String? activityType,
      String? notes,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ChallengeCheckInImplCopyWithImpl<$Res>
    extends _$ChallengeCheckInCopyWithImpl<$Res, _$ChallengeCheckInImpl>
    implements _$$ChallengeCheckInImplCopyWith<$Res> {
  __$$ChallengeCheckInImplCopyWithImpl(_$ChallengeCheckInImpl _value,
      $Res Function(_$ChallengeCheckInImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? points = null,
    Object? createdAt = null,
    Object? activityType = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$ChallengeCheckInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      activityType: freezed == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeCheckInImpl
    with DiagnosticableTreeMixin
    implements _ChallengeCheckIn {
  const _$ChallengeCheckInImpl(
      {required this.id,
      required this.challengeId,
      required this.userId,
      required this.points,
      required this.createdAt,
      this.activityType,
      this.notes,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$ChallengeCheckInImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeCheckInImplFromJson(json);

  /// ID único do check-in
  @override
  final String id;

  /// ID do desafio
  @override
  final String challengeId;

  /// ID do usuário
  @override
  final String userId;

  /// Pontos ganhos com este check-in
  @override
  final int points;

  /// Data e hora do check-in
  @override
  final DateTime createdAt;

  /// Tipo de atividade (opcional)
  @override
  final String? activityType;

  /// Notas ou comentários (opcional)
  @override
  final String? notes;

  /// Dados adicionais do check-in (JSON)
  final Map<String, dynamic>? _metadata;

  /// Dados adicionais do check-in (JSON)
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChallengeCheckIn(id: $id, challengeId: $challengeId, userId: $userId, points: $points, createdAt: $createdAt, activityType: $activityType, notes: $notes, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChallengeCheckIn'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('challengeId', challengeId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('points', points))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('activityType', activityType))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeCheckInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      challengeId,
      userId,
      points,
      createdAt,
      activityType,
      notes,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ChallengeCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeCheckInImplCopyWith<_$ChallengeCheckInImpl> get copyWith =>
      __$$ChallengeCheckInImplCopyWithImpl<_$ChallengeCheckInImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeCheckInImplToJson(
      this,
    );
  }
}

abstract class _ChallengeCheckIn implements ChallengeCheckIn {
  const factory _ChallengeCheckIn(
      {required final String id,
      required final String challengeId,
      required final String userId,
      required final int points,
      required final DateTime createdAt,
      final String? activityType,
      final String? notes,
      final Map<String, dynamic>? metadata}) = _$ChallengeCheckInImpl;

  factory _ChallengeCheckIn.fromJson(Map<String, dynamic> json) =
      _$ChallengeCheckInImpl.fromJson;

  /// ID único do check-in
  @override
  String get id;

  /// ID do desafio
  @override
  String get challengeId;

  /// ID do usuário
  @override
  String get userId;

  /// Pontos ganhos com este check-in
  @override
  int get points;

  /// Data e hora do check-in
  @override
  DateTime get createdAt;

  /// Tipo de atividade (opcional)
  @override
  String? get activityType;

  /// Notas ou comentários (opcional)
  @override
  String? get notes;

  /// Dados adicionais do check-in (JSON)
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ChallengeCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeCheckInImplCopyWith<_$ChallengeCheckInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
