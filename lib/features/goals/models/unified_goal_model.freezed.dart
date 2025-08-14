// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_goal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UnifiedGoal _$UnifiedGoalFromJson(Map<String, dynamic> json) {
  return _UnifiedGoal.fromJson(json);
}

/// @nodoc
mixin _$UnifiedGoal {
  /// Identificadores
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Informações básicas
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Tipo e categoria
  UnifiedGoalType get type => throw _privateConstructorUsedError;
  GoalCategory? get category =>
      throw _privateConstructorUsedError; // Apenas para workout_category
  /// Valores de progresso
  double get targetValue => throw _privateConstructorUsedError;
  double get currentValue => throw _privateConstructorUsedError;
  GoalUnit get unit => throw _privateConstructorUsedError;
  String get measurementType =>
      throw _privateConstructorUsedError; // 'minutes' ou 'days'
  /// Período da meta
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Status
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Auto-incremento
  bool get autoIncrement =>
      throw _privateConstructorUsedError; // Se deve ser atualizada automaticamente por treinos
  /// Timestamps
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UnifiedGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnifiedGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnifiedGoalCopyWith<UnifiedGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedGoalCopyWith<$Res> {
  factory $UnifiedGoalCopyWith(
          UnifiedGoal value, $Res Function(UnifiedGoal) then) =
      _$UnifiedGoalCopyWithImpl<$Res, UnifiedGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String? description,
      UnifiedGoalType type,
      GoalCategory? category,
      double targetValue,
      double currentValue,
      GoalUnit unit,
      String measurementType,
      DateTime startDate,
      DateTime? endDate,
      bool isCompleted,
      DateTime? completedAt,
      bool autoIncrement,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$UnifiedGoalCopyWithImpl<$Res, $Val extends UnifiedGoal>
    implements $UnifiedGoalCopyWith<$Res> {
  _$UnifiedGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnifiedGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = null,
    Object? category = freezed,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? unit = null,
    Object? measurementType = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isCompleted = null,
    Object? completedAt = freezed,
    Object? autoIncrement = null,
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
              as UnifiedGoalType,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as GoalCategory?,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as GoalUnit,
      measurementType: null == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoIncrement: null == autoIncrement
          ? _value.autoIncrement
          : autoIncrement // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$UnifiedGoalImplCopyWith<$Res>
    implements $UnifiedGoalCopyWith<$Res> {
  factory _$$UnifiedGoalImplCopyWith(
          _$UnifiedGoalImpl value, $Res Function(_$UnifiedGoalImpl) then) =
      __$$UnifiedGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String? description,
      UnifiedGoalType type,
      GoalCategory? category,
      double targetValue,
      double currentValue,
      GoalUnit unit,
      String measurementType,
      DateTime startDate,
      DateTime? endDate,
      bool isCompleted,
      DateTime? completedAt,
      bool autoIncrement,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$UnifiedGoalImplCopyWithImpl<$Res>
    extends _$UnifiedGoalCopyWithImpl<$Res, _$UnifiedGoalImpl>
    implements _$$UnifiedGoalImplCopyWith<$Res> {
  __$$UnifiedGoalImplCopyWithImpl(
      _$UnifiedGoalImpl _value, $Res Function(_$UnifiedGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of UnifiedGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = null,
    Object? category = freezed,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? unit = null,
    Object? measurementType = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isCompleted = null,
    Object? completedAt = freezed,
    Object? autoIncrement = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UnifiedGoalImpl(
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
              as UnifiedGoalType,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as GoalCategory?,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as GoalUnit,
      measurementType: null == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoIncrement: null == autoIncrement
          ? _value.autoIncrement
          : autoIncrement // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$UnifiedGoalImpl extends _UnifiedGoal {
  const _$UnifiedGoalImpl(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.type,
      this.category,
      required this.targetValue,
      this.currentValue = 0.0,
      required this.unit,
      this.measurementType = 'minutes',
      required this.startDate,
      this.endDate,
      this.isCompleted = false,
      this.completedAt,
      this.autoIncrement = true,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$UnifiedGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnifiedGoalImplFromJson(json);

  /// Identificadores
  @override
  final String id;
  @override
  final String userId;

  /// Informações básicas
  @override
  final String title;
  @override
  final String? description;

  /// Tipo e categoria
  @override
  final UnifiedGoalType type;
  @override
  final GoalCategory? category;
// Apenas para workout_category
  /// Valores de progresso
  @override
  final double targetValue;
  @override
  @JsonKey()
  final double currentValue;
  @override
  final GoalUnit unit;
  @override
  @JsonKey()
  final String measurementType;
// 'minutes' ou 'days'
  /// Período da meta
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;

  /// Status
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime? completedAt;

  /// Auto-incremento
  @override
  @JsonKey()
  final bool autoIncrement;
// Se deve ser atualizada automaticamente por treinos
  /// Timestamps
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UnifiedGoal(id: $id, userId: $userId, title: $title, description: $description, type: $type, category: $category, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, measurementType: $measurementType, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted, completedAt: $completedAt, autoIncrement: $autoIncrement, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.measurementType, measurementType) ||
                other.measurementType == measurementType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.autoIncrement, autoIncrement) ||
                other.autoIncrement == autoIncrement) &&
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
      category,
      targetValue,
      currentValue,
      unit,
      measurementType,
      startDate,
      endDate,
      isCompleted,
      completedAt,
      autoIncrement,
      createdAt,
      updatedAt);

  /// Create a copy of UnifiedGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedGoalImplCopyWith<_$UnifiedGoalImpl> get copyWith =>
      __$$UnifiedGoalImplCopyWithImpl<_$UnifiedGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnifiedGoalImplToJson(
      this,
    );
  }
}

abstract class _UnifiedGoal extends UnifiedGoal {
  const factory _UnifiedGoal(
      {required final String id,
      required final String userId,
      required final String title,
      final String? description,
      required final UnifiedGoalType type,
      final GoalCategory? category,
      required final double targetValue,
      final double currentValue,
      required final GoalUnit unit,
      final String measurementType,
      required final DateTime startDate,
      final DateTime? endDate,
      final bool isCompleted,
      final DateTime? completedAt,
      final bool autoIncrement,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$UnifiedGoalImpl;
  const _UnifiedGoal._() : super._();

  factory _UnifiedGoal.fromJson(Map<String, dynamic> json) =
      _$UnifiedGoalImpl.fromJson;

  /// Identificadores
  @override
  String get id;
  @override
  String get userId;

  /// Informações básicas
  @override
  String get title;
  @override
  String? get description;

  /// Tipo e categoria
  @override
  UnifiedGoalType get type;
  @override
  GoalCategory? get category; // Apenas para workout_category
  /// Valores de progresso
  @override
  double get targetValue;
  @override
  double get currentValue;
  @override
  GoalUnit get unit;
  @override
  String get measurementType; // 'minutes' ou 'days'
  /// Período da meta
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;

  /// Status
  @override
  bool get isCompleted;
  @override
  DateTime? get completedAt;

  /// Auto-incremento
  @override
  bool get autoIncrement; // Se deve ser atualizada automaticamente por treinos
  /// Timestamps
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UnifiedGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnifiedGoalImplCopyWith<_$UnifiedGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
