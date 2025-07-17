// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeeklyGoal _$WeeklyGoalFromJson(Map<String, dynamic> json) {
  return _WeeklyGoal.fromJson(json);
}

/// @nodoc
mixin _$WeeklyGoal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get goalMinutes => throw _privateConstructorUsedError;
  int get currentMinutes => throw _privateConstructorUsedError;
  DateTime get weekStartDate => throw _privateConstructorUsedError;
  DateTime get weekEndDate => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  double get percentageCompleted => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WeeklyGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyGoalCopyWith<WeeklyGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyGoalCopyWith<$Res> {
  factory $WeeklyGoalCopyWith(
          WeeklyGoal value, $Res Function(WeeklyGoal) then) =
      _$WeeklyGoalCopyWithImpl<$Res, WeeklyGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      int goalMinutes,
      int currentMinutes,
      DateTime weekStartDate,
      DateTime weekEndDate,
      bool completed,
      double percentageCompleted,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$WeeklyGoalCopyWithImpl<$Res, $Val extends WeeklyGoal>
    implements $WeeklyGoalCopyWith<$Res> {
  _$WeeklyGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? goalMinutes = null,
    Object? currentMinutes = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
    Object? completed = null,
    Object? percentageCompleted = null,
    Object? createdAt = freezed,
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
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      currentMinutes: null == currentMinutes
          ? _value.currentMinutes
          : currentMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEndDate: null == weekEndDate
          ? _value.weekEndDate
          : weekEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      percentageCompleted: null == percentageCompleted
          ? _value.percentageCompleted
          : percentageCompleted // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyGoalImplCopyWith<$Res>
    implements $WeeklyGoalCopyWith<$Res> {
  factory _$$WeeklyGoalImplCopyWith(
          _$WeeklyGoalImpl value, $Res Function(_$WeeklyGoalImpl) then) =
      __$$WeeklyGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      int goalMinutes,
      int currentMinutes,
      DateTime weekStartDate,
      DateTime weekEndDate,
      bool completed,
      double percentageCompleted,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$WeeklyGoalImplCopyWithImpl<$Res>
    extends _$WeeklyGoalCopyWithImpl<$Res, _$WeeklyGoalImpl>
    implements _$$WeeklyGoalImplCopyWith<$Res> {
  __$$WeeklyGoalImplCopyWithImpl(
      _$WeeklyGoalImpl _value, $Res Function(_$WeeklyGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? goalMinutes = null,
    Object? currentMinutes = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
    Object? completed = null,
    Object? percentageCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WeeklyGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      currentMinutes: null == currentMinutes
          ? _value.currentMinutes
          : currentMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEndDate: null == weekEndDate
          ? _value.weekEndDate
          : weekEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      percentageCompleted: null == percentageCompleted
          ? _value.percentageCompleted
          : percentageCompleted // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyGoalImpl implements _WeeklyGoal {
  const _$WeeklyGoalImpl(
      {required this.id,
      required this.userId,
      required this.goalMinutes,
      this.currentMinutes = 0,
      required this.weekStartDate,
      required this.weekEndDate,
      this.completed = false,
      this.percentageCompleted = 0.0,
      this.createdAt,
      this.updatedAt});

  factory _$WeeklyGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final int goalMinutes;
  @override
  @JsonKey()
  final int currentMinutes;
  @override
  final DateTime weekStartDate;
  @override
  final DateTime weekEndDate;
  @override
  @JsonKey()
  final bool completed;
  @override
  @JsonKey()
  final double percentageCompleted;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WeeklyGoal(id: $id, userId: $userId, goalMinutes: $goalMinutes, currentMinutes: $currentMinutes, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate, completed: $completed, percentageCompleted: $percentageCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.goalMinutes, goalMinutes) ||
                other.goalMinutes == goalMinutes) &&
            (identical(other.currentMinutes, currentMinutes) ||
                other.currentMinutes == currentMinutes) &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.weekEndDate, weekEndDate) ||
                other.weekEndDate == weekEndDate) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.percentageCompleted, percentageCompleted) ||
                other.percentageCompleted == percentageCompleted) &&
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
      goalMinutes,
      currentMinutes,
      weekStartDate,
      weekEndDate,
      completed,
      percentageCompleted,
      createdAt,
      updatedAt);

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyGoalImplCopyWith<_$WeeklyGoalImpl> get copyWith =>
      __$$WeeklyGoalImplCopyWithImpl<_$WeeklyGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyGoalImplToJson(
      this,
    );
  }
}

abstract class _WeeklyGoal implements WeeklyGoal {
  const factory _WeeklyGoal(
      {required final String id,
      required final String userId,
      required final int goalMinutes,
      final int currentMinutes,
      required final DateTime weekStartDate,
      required final DateTime weekEndDate,
      final bool completed,
      final double percentageCompleted,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$WeeklyGoalImpl;

  factory _WeeklyGoal.fromJson(Map<String, dynamic> json) =
      _$WeeklyGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get goalMinutes;
  @override
  int get currentMinutes;
  @override
  DateTime get weekStartDate;
  @override
  DateTime get weekEndDate;
  @override
  bool get completed;
  @override
  double get percentageCompleted;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyGoalImplCopyWith<_$WeeklyGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
