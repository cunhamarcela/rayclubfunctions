// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'water_intake_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WaterIntake _$WaterIntakeFromJson(Map<String, dynamic> json) {
  return _WaterIntake.fromJson(json);
}

/// @nodoc
mixin _$WaterIntake {
  /// Identificador único do registro
  String get id => throw _privateConstructorUsedError;

  /// Identificador do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Data do registro
  DateTime get date => throw _privateConstructorUsedError;

  /// Número de copos de água ingeridos
  int get currentGlasses => throw _privateConstructorUsedError;

  /// Meta diária de copos de água
  int get dailyGoal => throw _privateConstructorUsedError;

  /// Volume em ml por copo (padrão 250ml)
  int get glassSize => throw _privateConstructorUsedError;

  /// Data de criação do registro
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização do registro
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WaterIntake to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaterIntake
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaterIntakeCopyWith<WaterIntake> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaterIntakeCopyWith<$Res> {
  factory $WaterIntakeCopyWith(
          WaterIntake value, $Res Function(WaterIntake) then) =
      _$WaterIntakeCopyWithImpl<$Res, WaterIntake>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime date,
      int currentGlasses,
      int dailyGoal,
      int glassSize,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$WaterIntakeCopyWithImpl<$Res, $Val extends WaterIntake>
    implements $WaterIntakeCopyWith<$Res> {
  _$WaterIntakeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaterIntake
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? currentGlasses = null,
    Object? dailyGoal = null,
    Object? glassSize = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentGlasses: null == currentGlasses
          ? _value.currentGlasses
          : currentGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      dailyGoal: null == dailyGoal
          ? _value.dailyGoal
          : dailyGoal // ignore: cast_nullable_to_non_nullable
              as int,
      glassSize: null == glassSize
          ? _value.glassSize
          : glassSize // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WaterIntakeImplCopyWith<$Res>
    implements $WaterIntakeCopyWith<$Res> {
  factory _$$WaterIntakeImplCopyWith(
          _$WaterIntakeImpl value, $Res Function(_$WaterIntakeImpl) then) =
      __$$WaterIntakeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime date,
      int currentGlasses,
      int dailyGoal,
      int glassSize,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$WaterIntakeImplCopyWithImpl<$Res>
    extends _$WaterIntakeCopyWithImpl<$Res, _$WaterIntakeImpl>
    implements _$$WaterIntakeImplCopyWith<$Res> {
  __$$WaterIntakeImplCopyWithImpl(
      _$WaterIntakeImpl _value, $Res Function(_$WaterIntakeImpl) _then)
      : super(_value, _then);

  /// Create a copy of WaterIntake
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? currentGlasses = null,
    Object? dailyGoal = null,
    Object? glassSize = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WaterIntakeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentGlasses: null == currentGlasses
          ? _value.currentGlasses
          : currentGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      dailyGoal: null == dailyGoal
          ? _value.dailyGoal
          : dailyGoal // ignore: cast_nullable_to_non_nullable
              as int,
      glassSize: null == glassSize
          ? _value.glassSize
          : glassSize // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WaterIntakeImpl extends _WaterIntake {
  const _$WaterIntakeImpl(
      {required this.id,
      required this.userId,
      required this.date,
      this.currentGlasses = 0,
      this.dailyGoal = 8,
      this.glassSize = 250,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$WaterIntakeImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaterIntakeImplFromJson(json);

  /// Identificador único do registro
  @override
  final String id;

  /// Identificador do usuário
  @override
  final String userId;

  /// Data do registro
  @override
  final DateTime date;

  /// Número de copos de água ingeridos
  @override
  @JsonKey()
  final int currentGlasses;

  /// Meta diária de copos de água
  @override
  @JsonKey()
  final int dailyGoal;

  /// Volume em ml por copo (padrão 250ml)
  @override
  @JsonKey()
  final int glassSize;

  /// Data de criação do registro
  @override
  final DateTime createdAt;

  /// Data da última atualização do registro
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WaterIntake(id: $id, userId: $userId, date: $date, currentGlasses: $currentGlasses, dailyGoal: $dailyGoal, glassSize: $glassSize, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaterIntakeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.currentGlasses, currentGlasses) ||
                other.currentGlasses == currentGlasses) &&
            (identical(other.dailyGoal, dailyGoal) ||
                other.dailyGoal == dailyGoal) &&
            (identical(other.glassSize, glassSize) ||
                other.glassSize == glassSize) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, date, currentGlasses,
      dailyGoal, glassSize, createdAt, updatedAt);

  /// Create a copy of WaterIntake
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaterIntakeImplCopyWith<_$WaterIntakeImpl> get copyWith =>
      __$$WaterIntakeImplCopyWithImpl<_$WaterIntakeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WaterIntakeImplToJson(
      this,
    );
  }
}

abstract class _WaterIntake extends WaterIntake {
  const factory _WaterIntake(
      {required final String id,
      required final String userId,
      required final DateTime date,
      final int currentGlasses,
      final int dailyGoal,
      final int glassSize,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$WaterIntakeImpl;
  const _WaterIntake._() : super._();

  factory _WaterIntake.fromJson(Map<String, dynamic> json) =
      _$WaterIntakeImpl.fromJson;

  /// Identificador único do registro
  @override
  String get id;

  /// Identificador do usuário
  @override
  String get userId;

  /// Data do registro
  @override
  DateTime get date;

  /// Número de copos de água ingeridos
  @override
  int get currentGlasses;

  /// Meta diária de copos de água
  @override
  int get dailyGoal;

  /// Volume em ml por copo (padrão 250ml)
  @override
  int get glassSize;

  /// Data de criação do registro
  @override
  DateTime get createdAt;

  /// Data da última atualização do registro
  @override
  DateTime? get updatedAt;

  /// Create a copy of WaterIntake
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaterIntakeImplCopyWith<_$WaterIntakeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
