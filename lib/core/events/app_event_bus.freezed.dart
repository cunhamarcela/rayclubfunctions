// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_event_bus.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppEvent _$AppEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'auth':
      return AuthEvent.fromJson(json);
    case 'workout':
      return WorkoutEvent.fromJson(json);
    case 'challenge':
      return ChallengeEvent.fromJson(json);
    case 'nutrition':
      return NutritionEvent.fromJson(json);
    case 'benefits':
      return BenefitsEvent.fromJson(json);
    case 'connectivity':
      return ConnectivityEvent.fromJson(json);
    case 'custom':
      return CustomEvent.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'AppEvent',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$AppEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this AppEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppEventCopyWith<$Res> {
  factory $AppEventCopyWith(AppEvent value, $Res Function(AppEvent) then) =
      _$AppEventCopyWithImpl<$Res, AppEvent>;
}

/// @nodoc
class _$AppEventCopyWithImpl<$Res, $Val extends AppEvent>
    implements $AppEventCopyWith<$Res> {
  _$AppEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AuthEventImplCopyWith<$Res> {
  factory _$$AuthEventImplCopyWith(
          _$AuthEventImpl value, $Res Function(_$AuthEventImpl) then) =
      __$$AuthEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, String? userId, Map<String, dynamic>? data});
}

/// @nodoc
class __$$AuthEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$AuthEventImpl>
    implements _$$AuthEventImplCopyWith<$Res> {
  __$$AuthEventImplCopyWithImpl(
      _$AuthEventImpl _value, $Res Function(_$AuthEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? userId = freezed,
    Object? data = freezed,
  }) {
    return _then(_$AuthEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthEventImpl with DiagnosticableTreeMixin implements AuthEvent {
  const _$AuthEventImpl(
      {required this.type,
      this.userId,
      final Map<String, dynamic>? data,
      final String? $type})
      : _data = data,
        $type = $type ?? 'auth';

  factory _$AuthEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthEventImplFromJson(json);

  @override
  final String type;
  @override
  final String? userId;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.auth(type: $type, userId: $userId, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.auth'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, userId, const DeepCollectionEquality().hash(_data));

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthEventImplCopyWith<_$AuthEventImpl> get copyWith =>
      __$$AuthEventImplCopyWithImpl<_$AuthEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return auth(type, userId, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return auth?.call(type, userId, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(type, userId, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthEventImplToJson(
      this,
    );
  }
}

abstract class AuthEvent implements AppEvent {
  const factory AuthEvent(
      {required final String type,
      final String? userId,
      final Map<String, dynamic>? data}) = _$AuthEventImpl;

  factory AuthEvent.fromJson(Map<String, dynamic> json) =
      _$AuthEventImpl.fromJson;

  String get type;
  String? get userId;
  Map<String, dynamic>? get data;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthEventImplCopyWith<_$AuthEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WorkoutEventImplCopyWith<$Res> {
  factory _$$WorkoutEventImplCopyWith(
          _$WorkoutEventImpl value, $Res Function(_$WorkoutEventImpl) then) =
      __$$WorkoutEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, String workoutId, Map<String, dynamic>? data});
}

/// @nodoc
class __$$WorkoutEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$WorkoutEventImpl>
    implements _$$WorkoutEventImplCopyWith<$Res> {
  __$$WorkoutEventImplCopyWithImpl(
      _$WorkoutEventImpl _value, $Res Function(_$WorkoutEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? workoutId = null,
    Object? data = freezed,
  }) {
    return _then(_$WorkoutEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutEventImpl with DiagnosticableTreeMixin implements WorkoutEvent {
  const _$WorkoutEventImpl(
      {required this.type,
      required this.workoutId,
      final Map<String, dynamic>? data,
      final String? $type})
      : _data = data,
        $type = $type ?? 'workout';

  factory _$WorkoutEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutEventImplFromJson(json);

  @override
  final String type;
  @override
  final String workoutId;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.workout(type: $type, workoutId: $workoutId, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.workout'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('workoutId', workoutId))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, workoutId, const DeepCollectionEquality().hash(_data));

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutEventImplCopyWith<_$WorkoutEventImpl> get copyWith =>
      __$$WorkoutEventImplCopyWithImpl<_$WorkoutEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return workout(type, workoutId, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return workout?.call(type, workoutId, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (workout != null) {
      return workout(type, workoutId, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return workout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return workout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (workout != null) {
      return workout(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutEventImplToJson(
      this,
    );
  }
}

abstract class WorkoutEvent implements AppEvent {
  const factory WorkoutEvent(
      {required final String type,
      required final String workoutId,
      final Map<String, dynamic>? data}) = _$WorkoutEventImpl;

  factory WorkoutEvent.fromJson(Map<String, dynamic> json) =
      _$WorkoutEventImpl.fromJson;

  String get type;
  String get workoutId;
  Map<String, dynamic>? get data;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutEventImplCopyWith<_$WorkoutEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChallengeEventImplCopyWith<$Res> {
  factory _$$ChallengeEventImplCopyWith(_$ChallengeEventImpl value,
          $Res Function(_$ChallengeEventImpl) then) =
      __$$ChallengeEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, String challengeId, Map<String, dynamic>? data});
}

/// @nodoc
class __$$ChallengeEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$ChallengeEventImpl>
    implements _$$ChallengeEventImplCopyWith<$Res> {
  __$$ChallengeEventImplCopyWithImpl(
      _$ChallengeEventImpl _value, $Res Function(_$ChallengeEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? challengeId = null,
    Object? data = freezed,
  }) {
    return _then(_$ChallengeEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeEventImpl
    with DiagnosticableTreeMixin
    implements ChallengeEvent {
  const _$ChallengeEventImpl(
      {required this.type,
      required this.challengeId,
      final Map<String, dynamic>? data,
      final String? $type})
      : _data = data,
        $type = $type ?? 'challenge';

  factory _$ChallengeEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeEventImplFromJson(json);

  @override
  final String type;
  @override
  final String challengeId;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.challenge(type: $type, challengeId: $challengeId, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.challenge'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('challengeId', challengeId))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, challengeId,
      const DeepCollectionEquality().hash(_data));

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeEventImplCopyWith<_$ChallengeEventImpl> get copyWith =>
      __$$ChallengeEventImplCopyWithImpl<_$ChallengeEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return challenge(type, challengeId, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return challenge?.call(type, challengeId, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (challenge != null) {
      return challenge(type, challengeId, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return challenge(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return challenge?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (challenge != null) {
      return challenge(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeEventImplToJson(
      this,
    );
  }
}

abstract class ChallengeEvent implements AppEvent {
  const factory ChallengeEvent(
      {required final String type,
      required final String challengeId,
      final Map<String, dynamic>? data}) = _$ChallengeEventImpl;

  factory ChallengeEvent.fromJson(Map<String, dynamic> json) =
      _$ChallengeEventImpl.fromJson;

  String get type;
  String get challengeId;
  Map<String, dynamic>? get data;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeEventImplCopyWith<_$ChallengeEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NutritionEventImplCopyWith<$Res> {
  factory _$$NutritionEventImplCopyWith(_$NutritionEventImpl value,
          $Res Function(_$NutritionEventImpl) then) =
      __$$NutritionEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, String? mealId, Map<String, dynamic>? data});
}

/// @nodoc
class __$$NutritionEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$NutritionEventImpl>
    implements _$$NutritionEventImplCopyWith<$Res> {
  __$$NutritionEventImplCopyWithImpl(
      _$NutritionEventImpl _value, $Res Function(_$NutritionEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? mealId = freezed,
    Object? data = freezed,
  }) {
    return _then(_$NutritionEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      mealId: freezed == mealId
          ? _value.mealId
          : mealId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionEventImpl
    with DiagnosticableTreeMixin
    implements NutritionEvent {
  const _$NutritionEventImpl(
      {required this.type,
      this.mealId,
      final Map<String, dynamic>? data,
      final String? $type})
      : _data = data,
        $type = $type ?? 'nutrition';

  factory _$NutritionEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionEventImplFromJson(json);

  @override
  final String type;
  @override
  final String? mealId;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.nutrition(type: $type, mealId: $mealId, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.nutrition'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('mealId', mealId))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mealId, mealId) || other.mealId == mealId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, mealId, const DeepCollectionEquality().hash(_data));

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionEventImplCopyWith<_$NutritionEventImpl> get copyWith =>
      __$$NutritionEventImplCopyWithImpl<_$NutritionEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return nutrition(type, mealId, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return nutrition?.call(type, mealId, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (nutrition != null) {
      return nutrition(type, mealId, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return nutrition(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return nutrition?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (nutrition != null) {
      return nutrition(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionEventImplToJson(
      this,
    );
  }
}

abstract class NutritionEvent implements AppEvent {
  const factory NutritionEvent(
      {required final String type,
      final String? mealId,
      final Map<String, dynamic>? data}) = _$NutritionEventImpl;

  factory NutritionEvent.fromJson(Map<String, dynamic> json) =
      _$NutritionEventImpl.fromJson;

  String get type;
  String? get mealId;
  Map<String, dynamic>? get data;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionEventImplCopyWith<_$NutritionEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BenefitsEventImplCopyWith<$Res> {
  factory _$$BenefitsEventImplCopyWith(
          _$BenefitsEventImpl value, $Res Function(_$BenefitsEventImpl) then) =
      __$$BenefitsEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, String? benefitId, Map<String, dynamic>? data});
}

/// @nodoc
class __$$BenefitsEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$BenefitsEventImpl>
    implements _$$BenefitsEventImplCopyWith<$Res> {
  __$$BenefitsEventImplCopyWithImpl(
      _$BenefitsEventImpl _value, $Res Function(_$BenefitsEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? benefitId = freezed,
    Object? data = freezed,
  }) {
    return _then(_$BenefitsEventImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: freezed == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BenefitsEventImpl
    with DiagnosticableTreeMixin
    implements BenefitsEvent {
  const _$BenefitsEventImpl(
      {required this.type,
      this.benefitId,
      final Map<String, dynamic>? data,
      final String? $type})
      : _data = data,
        $type = $type ?? 'benefits';

  factory _$BenefitsEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$BenefitsEventImplFromJson(json);

  @override
  final String type;
  @override
  final String? benefitId;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.benefits(type: $type, benefitId: $benefitId, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.benefits'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('benefitId', benefitId))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BenefitsEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.benefitId, benefitId) ||
                other.benefitId == benefitId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, benefitId, const DeepCollectionEquality().hash(_data));

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BenefitsEventImplCopyWith<_$BenefitsEventImpl> get copyWith =>
      __$$BenefitsEventImplCopyWithImpl<_$BenefitsEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return benefits(type, benefitId, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return benefits?.call(type, benefitId, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (benefits != null) {
      return benefits(type, benefitId, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return benefits(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return benefits?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (benefits != null) {
      return benefits(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BenefitsEventImplToJson(
      this,
    );
  }
}

abstract class BenefitsEvent implements AppEvent {
  const factory BenefitsEvent(
      {required final String type,
      final String? benefitId,
      final Map<String, dynamic>? data}) = _$BenefitsEventImpl;

  factory BenefitsEvent.fromJson(Map<String, dynamic> json) =
      _$BenefitsEventImpl.fromJson;

  String get type;
  String? get benefitId;
  Map<String, dynamic>? get data;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BenefitsEventImplCopyWith<_$BenefitsEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectivityEventImplCopyWith<$Res> {
  factory _$$ConnectivityEventImplCopyWith(_$ConnectivityEventImpl value,
          $Res Function(_$ConnectivityEventImpl) then) =
      __$$ConnectivityEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isOnline, String? timestamp});
}

/// @nodoc
class __$$ConnectivityEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$ConnectivityEventImpl>
    implements _$$ConnectivityEventImplCopyWith<$Res> {
  __$$ConnectivityEventImplCopyWithImpl(_$ConnectivityEventImpl _value,
      $Res Function(_$ConnectivityEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOnline = null,
    Object? timestamp = freezed,
  }) {
    return _then(_$ConnectivityEventImpl(
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectivityEventImpl
    with DiagnosticableTreeMixin
    implements ConnectivityEvent {
  const _$ConnectivityEventImpl(
      {required this.isOnline, this.timestamp, final String? $type})
      : $type = $type ?? 'connectivity';

  factory _$ConnectivityEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectivityEventImplFromJson(json);

  @override
  final bool isOnline;
  @override
  final String? timestamp;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.connectivity(isOnline: $isOnline, timestamp: $timestamp)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.connectivity'))
      ..add(DiagnosticsProperty('isOnline', isOnline))
      ..add(DiagnosticsProperty('timestamp', timestamp));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectivityEventImpl &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isOnline, timestamp);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectivityEventImplCopyWith<_$ConnectivityEventImpl> get copyWith =>
      __$$ConnectivityEventImplCopyWithImpl<_$ConnectivityEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return connectivity(isOnline, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return connectivity?.call(isOnline, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (connectivity != null) {
      return connectivity(isOnline, timestamp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return connectivity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return connectivity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (connectivity != null) {
      return connectivity(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectivityEventImplToJson(
      this,
    );
  }
}

abstract class ConnectivityEvent implements AppEvent {
  const factory ConnectivityEvent(
      {required final bool isOnline,
      final String? timestamp}) = _$ConnectivityEventImpl;

  factory ConnectivityEvent.fromJson(Map<String, dynamic> json) =
      _$ConnectivityEventImpl.fromJson;

  bool get isOnline;
  String? get timestamp;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectivityEventImplCopyWith<_$ConnectivityEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomEventImplCopyWith<$Res> {
  factory _$$CustomEventImplCopyWith(
          _$CustomEventImpl value, $Res Function(_$CustomEventImpl) then) =
      __$$CustomEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, Map<String, dynamic> data});
}

/// @nodoc
class __$$CustomEventImplCopyWithImpl<$Res>
    extends _$AppEventCopyWithImpl<$Res, _$CustomEventImpl>
    implements _$$CustomEventImplCopyWith<$Res> {
  __$$CustomEventImplCopyWithImpl(
      _$CustomEventImpl _value, $Res Function(_$CustomEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? data = null,
  }) {
    return _then(_$CustomEventImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomEventImpl with DiagnosticableTreeMixin implements CustomEvent {
  const _$CustomEventImpl(
      {required this.name,
      required final Map<String, dynamic> data,
      final String? $type})
      : _data = data,
        $type = $type ?? 'custom';

  factory _$CustomEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomEventImplFromJson(json);

  @override
  final String name;
  final Map<String, dynamic> _data;
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppEvent.custom(name: $name, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppEvent.custom'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_data));

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomEventImplCopyWith<_$CustomEventImpl> get copyWith =>
      __$$CustomEventImplCopyWithImpl<_$CustomEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String type, String? userId, Map<String, dynamic>? data)
        auth,
    required TResult Function(
            String type, String workoutId, Map<String, dynamic>? data)
        workout,
    required TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)
        challenge,
    required TResult Function(
            String type, String? mealId, Map<String, dynamic>? data)
        nutrition,
    required TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)
        benefits,
    required TResult Function(bool isOnline, String? timestamp) connectivity,
    required TResult Function(String name, Map<String, dynamic> data) custom,
  }) {
    return custom(name, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult? Function(
            String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult? Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult? Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult? Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult? Function(bool isOnline, String? timestamp)? connectivity,
    TResult? Function(String name, Map<String, dynamic> data)? custom,
  }) {
    return custom?.call(name, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String type, String? userId, Map<String, dynamic>? data)?
        auth,
    TResult Function(String type, String workoutId, Map<String, dynamic>? data)?
        workout,
    TResult Function(
            String type, String challengeId, Map<String, dynamic>? data)?
        challenge,
    TResult Function(String type, String? mealId, Map<String, dynamic>? data)?
        nutrition,
    TResult Function(
            String type, String? benefitId, Map<String, dynamic>? data)?
        benefits,
    TResult Function(bool isOnline, String? timestamp)? connectivity,
    TResult Function(String name, Map<String, dynamic> data)? custom,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(name, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthEvent value) auth,
    required TResult Function(WorkoutEvent value) workout,
    required TResult Function(ChallengeEvent value) challenge,
    required TResult Function(NutritionEvent value) nutrition,
    required TResult Function(BenefitsEvent value) benefits,
    required TResult Function(ConnectivityEvent value) connectivity,
    required TResult Function(CustomEvent value) custom,
  }) {
    return custom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthEvent value)? auth,
    TResult? Function(WorkoutEvent value)? workout,
    TResult? Function(ChallengeEvent value)? challenge,
    TResult? Function(NutritionEvent value)? nutrition,
    TResult? Function(BenefitsEvent value)? benefits,
    TResult? Function(ConnectivityEvent value)? connectivity,
    TResult? Function(CustomEvent value)? custom,
  }) {
    return custom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthEvent value)? auth,
    TResult Function(WorkoutEvent value)? workout,
    TResult Function(ChallengeEvent value)? challenge,
    TResult Function(NutritionEvent value)? nutrition,
    TResult Function(BenefitsEvent value)? benefits,
    TResult Function(ConnectivityEvent value)? connectivity,
    TResult Function(CustomEvent value)? custom,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomEventImplToJson(
      this,
    );
  }
}

abstract class CustomEvent implements AppEvent {
  const factory CustomEvent(
      {required final String name,
      required final Map<String, dynamic> data}) = _$CustomEventImpl;

  factory CustomEvent.fromJson(Map<String, dynamic> json) =
      _$CustomEventImpl.fromJson;

  String get name;
  Map<String, dynamic> get data;

  /// Create a copy of AppEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomEventImplCopyWith<_$CustomEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
