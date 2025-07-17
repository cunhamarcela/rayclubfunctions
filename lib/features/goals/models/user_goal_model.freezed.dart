// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_goal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserGoal _$UserGoalFromJson(Map<String, dynamic> json) {
  return _UserGoal.fromJson(json);
}

/// @nodoc
mixin _$UserGoal {
  /// Identificador único da meta
  String get id => throw _privateConstructorUsedError;

  /// Identificador do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Nome/título da meta
  String get title => throw _privateConstructorUsedError;

  /// Descrição opcional da meta
  String? get description => throw _privateConstructorUsedError;

  /// Tipo da meta
  GoalType get type => throw _privateConstructorUsedError;

  /// Valor alvo a ser alcançado
  double get target => throw _privateConstructorUsedError;

  /// Valor atual
  double get progress => throw _privateConstructorUsedError;

  /// Unidade de medida (kg, min, etc)
  String get unit => throw _privateConstructorUsedError;

  /// Data de início
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Data de término prevista
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Data em que a meta foi concluída
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Data de criação
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGoalCopyWith<UserGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGoalCopyWith<$Res> {
  factory $UserGoalCopyWith(UserGoal value, $Res Function(UserGoal) then) =
      _$UserGoalCopyWithImpl<$Res, UserGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String? description,
      GoalType type,
      double target,
      double progress,
      String unit,
      DateTime startDate,
      DateTime? endDate,
      DateTime? completedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$UserGoalCopyWithImpl<$Res, $Val extends UserGoal>
    implements $UserGoalCopyWith<$Res> {
  _$UserGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = null,
    Object? target = null,
    Object? progress = null,
    Object? unit = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? completedAt = freezed,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GoalType,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as double,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$UserGoalImplCopyWith<$Res>
    implements $UserGoalCopyWith<$Res> {
  factory _$$UserGoalImplCopyWith(
          _$UserGoalImpl value, $Res Function(_$UserGoalImpl) then) =
      __$$UserGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String? description,
      GoalType type,
      double target,
      double progress,
      String unit,
      DateTime startDate,
      DateTime? endDate,
      DateTime? completedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$UserGoalImplCopyWithImpl<$Res>
    extends _$UserGoalCopyWithImpl<$Res, _$UserGoalImpl>
    implements _$$UserGoalImplCopyWith<$Res> {
  __$$UserGoalImplCopyWithImpl(
      _$UserGoalImpl _value, $Res Function(_$UserGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = null,
    Object? target = null,
    Object? progress = null,
    Object? unit = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GoalType,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as double,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$UserGoalImpl extends _UserGoal with DiagnosticableTreeMixin {
  const _$UserGoalImpl(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.type,
      required this.target,
      this.progress = 0.0,
      required this.unit,
      required this.startDate,
      this.endDate,
      this.completedAt,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$UserGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserGoalImplFromJson(json);

  /// Identificador único da meta
  @override
  final String id;

  /// Identificador do usuário
  @override
  final String userId;

  /// Nome/título da meta
  @override
  final String title;

  /// Descrição opcional da meta
  @override
  final String? description;

  /// Tipo da meta
  @override
  final GoalType type;

  /// Valor alvo a ser alcançado
  @override
  final double target;

  /// Valor atual
  @override
  @JsonKey()
  final double progress;

  /// Unidade de medida (kg, min, etc)
  @override
  final String unit;

  /// Data de início
  @override
  final DateTime startDate;

  /// Data de término prevista
  @override
  final DateTime? endDate;

  /// Data em que a meta foi concluída
  @override
  final DateTime? completedAt;

  /// Data de criação
  @override
  final DateTime createdAt;

  /// Data da última atualização
  @override
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserGoal(id: $id, userId: $userId, title: $title, description: $description, type: $type, target: $target, progress: $progress, unit: $unit, startDate: $startDate, endDate: $endDate, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserGoal'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('target', target))
      ..add(DiagnosticsProperty('progress', progress))
      ..add(DiagnosticsProperty('unit', unit))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('completedAt', completedAt))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      description,
      type,
      target,
      progress,
      unit,
      startDate,
      endDate,
      completedAt,
      createdAt,
      updatedAt);

  /// Create a copy of UserGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGoalImplCopyWith<_$UserGoalImpl> get copyWith =>
      __$$UserGoalImplCopyWithImpl<_$UserGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserGoalImplToJson(
      this,
    );
  }
}

abstract class _UserGoal extends UserGoal {
  const factory _UserGoal(
      {required final String id,
      required final String userId,
      required final String title,
      final String? description,
      required final GoalType type,
      required final double target,
      final double progress,
      required final String unit,
      required final DateTime startDate,
      final DateTime? endDate,
      final DateTime? completedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$UserGoalImpl;
  const _UserGoal._() : super._();

  factory _UserGoal.fromJson(Map<String, dynamic> json) =
      _$UserGoalImpl.fromJson;

  /// Identificador único da meta
  @override
  String get id;

  /// Identificador do usuário
  @override
  String get userId;

  /// Nome/título da meta
  @override
  String get title;

  /// Descrição opcional da meta
  @override
  String? get description;

  /// Tipo da meta
  @override
  GoalType get type;

  /// Valor alvo a ser alcançado
  @override
  double get target;

  /// Valor atual
  @override
  double get progress;

  /// Unidade de medida (kg, min, etc)
  @override
  String get unit;

  /// Data de início
  @override
  DateTime get startDate;

  /// Data de término prevista
  @override
  DateTime? get endDate;

  /// Data em que a meta foi concluída
  @override
  DateTime? get completedAt;

  /// Data de criação
  @override
  DateTime get createdAt;

  /// Data da última atualização
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGoalImplCopyWith<_$UserGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
