// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personalized_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PersonalizedGoal _$PersonalizedGoalFromJson(Map<String, dynamic> json) {
  return _PersonalizedGoal.fromJson(json);
}

/// @nodoc
mixin _$PersonalizedGoal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  PersonalizedGoalPresetType get presetType =>
      throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  PersonalizedGoalMeasurementType get measurementType =>
      throw _privateConstructorUsedError;
  double get targetValue => throw _privateConstructorUsedError;
  double get currentProgress => throw _privateConstructorUsedError;
  String get unitLabel => throw _privateConstructorUsedError;
  double get incrementStep => throw _privateConstructorUsedError;
  DateTime get weekStartDate => throw _privateConstructorUsedError;
  DateTime get weekEndDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PersonalizedGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonalizedGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalizedGoalCopyWith<PersonalizedGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalizedGoalCopyWith<$Res> {
  factory $PersonalizedGoalCopyWith(
          PersonalizedGoal value, $Res Function(PersonalizedGoal) then) =
      _$PersonalizedGoalCopyWithImpl<$Res, PersonalizedGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      PersonalizedGoalPresetType presetType,
      String title,
      String? description,
      PersonalizedGoalMeasurementType measurementType,
      double targetValue,
      double currentProgress,
      String unitLabel,
      double incrementStep,
      DateTime weekStartDate,
      DateTime weekEndDate,
      bool isActive,
      bool isCompleted,
      DateTime? completedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PersonalizedGoalCopyWithImpl<$Res, $Val extends PersonalizedGoal>
    implements $PersonalizedGoalCopyWith<$Res> {
  _$PersonalizedGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalizedGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? presetType = null,
    Object? title = null,
    Object? description = freezed,
    Object? measurementType = null,
    Object? targetValue = null,
    Object? currentProgress = null,
    Object? unitLabel = null,
    Object? incrementStep = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
    Object? isActive = null,
    Object? isCompleted = null,
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
      presetType: null == presetType
          ? _value.presetType
          : presetType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalPresetType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      measurementType: null == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalMeasurementType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as double,
      unitLabel: null == unitLabel
          ? _value.unitLabel
          : unitLabel // ignore: cast_nullable_to_non_nullable
              as String,
      incrementStep: null == incrementStep
          ? _value.incrementStep
          : incrementStep // ignore: cast_nullable_to_non_nullable
              as double,
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEndDate: null == weekEndDate
          ? _value.weekEndDate
          : weekEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$PersonalizedGoalImplCopyWith<$Res>
    implements $PersonalizedGoalCopyWith<$Res> {
  factory _$$PersonalizedGoalImplCopyWith(_$PersonalizedGoalImpl value,
          $Res Function(_$PersonalizedGoalImpl) then) =
      __$$PersonalizedGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      PersonalizedGoalPresetType presetType,
      String title,
      String? description,
      PersonalizedGoalMeasurementType measurementType,
      double targetValue,
      double currentProgress,
      String unitLabel,
      double incrementStep,
      DateTime weekStartDate,
      DateTime weekEndDate,
      bool isActive,
      bool isCompleted,
      DateTime? completedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PersonalizedGoalImplCopyWithImpl<$Res>
    extends _$PersonalizedGoalCopyWithImpl<$Res, _$PersonalizedGoalImpl>
    implements _$$PersonalizedGoalImplCopyWith<$Res> {
  __$$PersonalizedGoalImplCopyWithImpl(_$PersonalizedGoalImpl _value,
      $Res Function(_$PersonalizedGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of PersonalizedGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? presetType = null,
    Object? title = null,
    Object? description = freezed,
    Object? measurementType = null,
    Object? targetValue = null,
    Object? currentProgress = null,
    Object? unitLabel = null,
    Object? incrementStep = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
    Object? isActive = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PersonalizedGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      presetType: null == presetType
          ? _value.presetType
          : presetType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalPresetType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      measurementType: null == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalMeasurementType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as double,
      unitLabel: null == unitLabel
          ? _value.unitLabel
          : unitLabel // ignore: cast_nullable_to_non_nullable
              as String,
      incrementStep: null == incrementStep
          ? _value.incrementStep
          : incrementStep // ignore: cast_nullable_to_non_nullable
              as double,
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEndDate: null == weekEndDate
          ? _value.weekEndDate
          : weekEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$PersonalizedGoalImpl extends _PersonalizedGoal {
  const _$PersonalizedGoalImpl(
      {required this.id,
      required this.userId,
      required this.presetType,
      required this.title,
      this.description,
      required this.measurementType,
      required this.targetValue,
      this.currentProgress = 0.0,
      required this.unitLabel,
      this.incrementStep = 1.0,
      required this.weekStartDate,
      required this.weekEndDate,
      this.isActive = true,
      this.isCompleted = false,
      this.completedAt,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$PersonalizedGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalizedGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final PersonalizedGoalPresetType presetType;
  @override
  final String title;
  @override
  final String? description;
  @override
  final PersonalizedGoalMeasurementType measurementType;
  @override
  final double targetValue;
  @override
  @JsonKey()
  final double currentProgress;
  @override
  final String unitLabel;
  @override
  @JsonKey()
  final double incrementStep;
  @override
  final DateTime weekStartDate;
  @override
  final DateTime weekEndDate;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime? completedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PersonalizedGoal(id: $id, userId: $userId, presetType: $presetType, title: $title, description: $description, measurementType: $measurementType, targetValue: $targetValue, currentProgress: $currentProgress, unitLabel: $unitLabel, incrementStep: $incrementStep, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate, isActive: $isActive, isCompleted: $isCompleted, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalizedGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.presetType, presetType) ||
                other.presetType == presetType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.measurementType, measurementType) ||
                other.measurementType == measurementType) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.unitLabel, unitLabel) ||
                other.unitLabel == unitLabel) &&
            (identical(other.incrementStep, incrementStep) ||
                other.incrementStep == incrementStep) &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.weekEndDate, weekEndDate) ||
                other.weekEndDate == weekEndDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
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
      presetType,
      title,
      description,
      measurementType,
      targetValue,
      currentProgress,
      unitLabel,
      incrementStep,
      weekStartDate,
      weekEndDate,
      isActive,
      isCompleted,
      completedAt,
      createdAt,
      updatedAt);

  /// Create a copy of PersonalizedGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalizedGoalImplCopyWith<_$PersonalizedGoalImpl> get copyWith =>
      __$$PersonalizedGoalImplCopyWithImpl<_$PersonalizedGoalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalizedGoalImplToJson(
      this,
    );
  }
}

abstract class _PersonalizedGoal extends PersonalizedGoal {
  const factory _PersonalizedGoal(
      {required final String id,
      required final String userId,
      required final PersonalizedGoalPresetType presetType,
      required final String title,
      final String? description,
      required final PersonalizedGoalMeasurementType measurementType,
      required final double targetValue,
      final double currentProgress,
      required final String unitLabel,
      final double incrementStep,
      required final DateTime weekStartDate,
      required final DateTime weekEndDate,
      final bool isActive,
      final bool isCompleted,
      final DateTime? completedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$PersonalizedGoalImpl;
  const _PersonalizedGoal._() : super._();

  factory _PersonalizedGoal.fromJson(Map<String, dynamic> json) =
      _$PersonalizedGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  PersonalizedGoalPresetType get presetType;
  @override
  String get title;
  @override
  String? get description;
  @override
  PersonalizedGoalMeasurementType get measurementType;
  @override
  double get targetValue;
  @override
  double get currentProgress;
  @override
  String get unitLabel;
  @override
  double get incrementStep;
  @override
  DateTime get weekStartDate;
  @override
  DateTime get weekEndDate;
  @override
  bool get isActive;
  @override
  bool get isCompleted;
  @override
  DateTime? get completedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PersonalizedGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalizedGoalImplCopyWith<_$PersonalizedGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalCheckIn _$GoalCheckInFromJson(Map<String, dynamic> json) {
  return _GoalCheckIn.fromJson(json);
}

/// @nodoc
mixin _$GoalCheckIn {
  String get id => throw _privateConstructorUsedError;
  String get goalId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get checkInDate => throw _privateConstructorUsedError;
  DateTime get checkInTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GoalCheckIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalCheckInCopyWith<GoalCheckIn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalCheckInCopyWith<$Res> {
  factory $GoalCheckInCopyWith(
          GoalCheckIn value, $Res Function(GoalCheckIn) then) =
      _$GoalCheckInCopyWithImpl<$Res, GoalCheckIn>;
  @useResult
  $Res call(
      {String id,
      String goalId,
      String userId,
      DateTime checkInDate,
      DateTime checkInTime,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$GoalCheckInCopyWithImpl<$Res, $Val extends GoalCheckIn>
    implements $GoalCheckInCopyWith<$Res> {
  _$GoalCheckInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goalId = null,
    Object? userId = null,
    Object? checkInDate = null,
    Object? checkInTime = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      checkInDate: null == checkInDate
          ? _value.checkInDate
          : checkInDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkInTime: null == checkInTime
          ? _value.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalCheckInImplCopyWith<$Res>
    implements $GoalCheckInCopyWith<$Res> {
  factory _$$GoalCheckInImplCopyWith(
          _$GoalCheckInImpl value, $Res Function(_$GoalCheckInImpl) then) =
      __$$GoalCheckInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String goalId,
      String userId,
      DateTime checkInDate,
      DateTime checkInTime,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$GoalCheckInImplCopyWithImpl<$Res>
    extends _$GoalCheckInCopyWithImpl<$Res, _$GoalCheckInImpl>
    implements _$$GoalCheckInImplCopyWith<$Res> {
  __$$GoalCheckInImplCopyWithImpl(
      _$GoalCheckInImpl _value, $Res Function(_$GoalCheckInImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goalId = null,
    Object? userId = null,
    Object? checkInDate = null,
    Object? checkInTime = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$GoalCheckInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      checkInDate: null == checkInDate
          ? _value.checkInDate
          : checkInDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkInTime: null == checkInTime
          ? _value.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalCheckInImpl implements _GoalCheckIn {
  const _$GoalCheckInImpl(
      {required this.id,
      required this.goalId,
      required this.userId,
      required this.checkInDate,
      required this.checkInTime,
      this.notes,
      required this.createdAt});

  factory _$GoalCheckInImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalCheckInImplFromJson(json);

  @override
  final String id;
  @override
  final String goalId;
  @override
  final String userId;
  @override
  final DateTime checkInDate;
  @override
  final DateTime checkInTime;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'GoalCheckIn(id: $id, goalId: $goalId, userId: $userId, checkInDate: $checkInDate, checkInTime: $checkInTime, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalCheckInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.checkInDate, checkInDate) ||
                other.checkInDate == checkInDate) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, goalId, userId, checkInDate,
      checkInTime, notes, createdAt);

  /// Create a copy of GoalCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalCheckInImplCopyWith<_$GoalCheckInImpl> get copyWith =>
      __$$GoalCheckInImplCopyWithImpl<_$GoalCheckInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalCheckInImplToJson(
      this,
    );
  }
}

abstract class _GoalCheckIn implements GoalCheckIn {
  const factory _GoalCheckIn(
      {required final String id,
      required final String goalId,
      required final String userId,
      required final DateTime checkInDate,
      required final DateTime checkInTime,
      final String? notes,
      required final DateTime createdAt}) = _$GoalCheckInImpl;

  factory _GoalCheckIn.fromJson(Map<String, dynamic> json) =
      _$GoalCheckInImpl.fromJson;

  @override
  String get id;
  @override
  String get goalId;
  @override
  String get userId;
  @override
  DateTime get checkInDate;
  @override
  DateTime get checkInTime;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of GoalCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalCheckInImplCopyWith<_$GoalCheckInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalProgressEntry _$GoalProgressEntryFromJson(Map<String, dynamic> json) {
  return _GoalProgressEntry.fromJson(json);
}

/// @nodoc
mixin _$GoalProgressEntry {
  String get id => throw _privateConstructorUsedError;
  String get goalId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get valueAdded => throw _privateConstructorUsedError;
  DateTime get entryDate => throw _privateConstructorUsedError;
  DateTime get entryTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GoalProgressEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalProgressEntryCopyWith<GoalProgressEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalProgressEntryCopyWith<$Res> {
  factory $GoalProgressEntryCopyWith(
          GoalProgressEntry value, $Res Function(GoalProgressEntry) then) =
      _$GoalProgressEntryCopyWithImpl<$Res, GoalProgressEntry>;
  @useResult
  $Res call(
      {String id,
      String goalId,
      String userId,
      double valueAdded,
      DateTime entryDate,
      DateTime entryTime,
      String? notes,
      String source,
      DateTime createdAt});
}

/// @nodoc
class _$GoalProgressEntryCopyWithImpl<$Res, $Val extends GoalProgressEntry>
    implements $GoalProgressEntryCopyWith<$Res> {
  _$GoalProgressEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goalId = null,
    Object? userId = null,
    Object? valueAdded = null,
    Object? entryDate = null,
    Object? entryTime = null,
    Object? notes = freezed,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      valueAdded: null == valueAdded
          ? _value.valueAdded
          : valueAdded // ignore: cast_nullable_to_non_nullable
              as double,
      entryDate: null == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalProgressEntryImplCopyWith<$Res>
    implements $GoalProgressEntryCopyWith<$Res> {
  factory _$$GoalProgressEntryImplCopyWith(_$GoalProgressEntryImpl value,
          $Res Function(_$GoalProgressEntryImpl) then) =
      __$$GoalProgressEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String goalId,
      String userId,
      double valueAdded,
      DateTime entryDate,
      DateTime entryTime,
      String? notes,
      String source,
      DateTime createdAt});
}

/// @nodoc
class __$$GoalProgressEntryImplCopyWithImpl<$Res>
    extends _$GoalProgressEntryCopyWithImpl<$Res, _$GoalProgressEntryImpl>
    implements _$$GoalProgressEntryImplCopyWith<$Res> {
  __$$GoalProgressEntryImplCopyWithImpl(_$GoalProgressEntryImpl _value,
      $Res Function(_$GoalProgressEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goalId = null,
    Object? userId = null,
    Object? valueAdded = null,
    Object? entryDate = null,
    Object? entryTime = null,
    Object? notes = freezed,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(_$GoalProgressEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      valueAdded: null == valueAdded
          ? _value.valueAdded
          : valueAdded // ignore: cast_nullable_to_non_nullable
              as double,
      entryDate: null == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalProgressEntryImpl implements _GoalProgressEntry {
  const _$GoalProgressEntryImpl(
      {required this.id,
      required this.goalId,
      required this.userId,
      required this.valueAdded,
      required this.entryDate,
      required this.entryTime,
      this.notes,
      this.source = 'manual',
      required this.createdAt});

  factory _$GoalProgressEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalProgressEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String goalId;
  @override
  final String userId;
  @override
  final double valueAdded;
  @override
  final DateTime entryDate;
  @override
  final DateTime entryTime;
  @override
  final String? notes;
  @override
  @JsonKey()
  final String source;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'GoalProgressEntry(id: $id, goalId: $goalId, userId: $userId, valueAdded: $valueAdded, entryDate: $entryDate, entryTime: $entryTime, notes: $notes, source: $source, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalProgressEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.valueAdded, valueAdded) ||
                other.valueAdded == valueAdded) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.entryTime, entryTime) ||
                other.entryTime == entryTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, goalId, userId, valueAdded,
      entryDate, entryTime, notes, source, createdAt);

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalProgressEntryImplCopyWith<_$GoalProgressEntryImpl> get copyWith =>
      __$$GoalProgressEntryImplCopyWithImpl<_$GoalProgressEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalProgressEntryImplToJson(
      this,
    );
  }
}

abstract class _GoalProgressEntry implements GoalProgressEntry {
  const factory _GoalProgressEntry(
      {required final String id,
      required final String goalId,
      required final String userId,
      required final double valueAdded,
      required final DateTime entryDate,
      required final DateTime entryTime,
      final String? notes,
      final String source,
      required final DateTime createdAt}) = _$GoalProgressEntryImpl;

  factory _GoalProgressEntry.fromJson(Map<String, dynamic> json) =
      _$GoalProgressEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get goalId;
  @override
  String get userId;
  @override
  double get valueAdded;
  @override
  DateTime get entryDate;
  @override
  DateTime get entryTime;
  @override
  String? get notes;
  @override
  String get source;
  @override
  DateTime get createdAt;

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalProgressEntryImplCopyWith<_$GoalProgressEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateGoalData _$CreateGoalDataFromJson(Map<String, dynamic> json) {
  return _CreateGoalData.fromJson(json);
}

/// @nodoc
mixin _$CreateGoalData {
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  PersonalizedGoalMeasurementType get measurementType =>
      throw _privateConstructorUsedError;
  double get targetValue => throw _privateConstructorUsedError;
  String get unitLabel => throw _privateConstructorUsedError;
  double get incrementStep => throw _privateConstructorUsedError;
  PersonalizedGoalPresetType get presetType =>
      throw _privateConstructorUsedError;

  /// Serializes this CreateGoalData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateGoalData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateGoalDataCopyWith<CreateGoalData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGoalDataCopyWith<$Res> {
  factory $CreateGoalDataCopyWith(
          CreateGoalData value, $Res Function(CreateGoalData) then) =
      _$CreateGoalDataCopyWithImpl<$Res, CreateGoalData>;
  @useResult
  $Res call(
      {String title,
      String? description,
      PersonalizedGoalMeasurementType measurementType,
      double targetValue,
      String unitLabel,
      double incrementStep,
      PersonalizedGoalPresetType presetType});
}

/// @nodoc
class _$CreateGoalDataCopyWithImpl<$Res, $Val extends CreateGoalData>
    implements $CreateGoalDataCopyWith<$Res> {
  _$CreateGoalDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateGoalData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = freezed,
    Object? measurementType = null,
    Object? targetValue = null,
    Object? unitLabel = null,
    Object? incrementStep = null,
    Object? presetType = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      measurementType: null == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalMeasurementType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      unitLabel: null == unitLabel
          ? _value.unitLabel
          : unitLabel // ignore: cast_nullable_to_non_nullable
              as String,
      incrementStep: null == incrementStep
          ? _value.incrementStep
          : incrementStep // ignore: cast_nullable_to_non_nullable
              as double,
      presetType: null == presetType
          ? _value.presetType
          : presetType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalPresetType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateGoalDataImplCopyWith<$Res>
    implements $CreateGoalDataCopyWith<$Res> {
  factory _$$CreateGoalDataImplCopyWith(_$CreateGoalDataImpl value,
          $Res Function(_$CreateGoalDataImpl) then) =
      __$$CreateGoalDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String? description,
      PersonalizedGoalMeasurementType measurementType,
      double targetValue,
      String unitLabel,
      double incrementStep,
      PersonalizedGoalPresetType presetType});
}

/// @nodoc
class __$$CreateGoalDataImplCopyWithImpl<$Res>
    extends _$CreateGoalDataCopyWithImpl<$Res, _$CreateGoalDataImpl>
    implements _$$CreateGoalDataImplCopyWith<$Res> {
  __$$CreateGoalDataImplCopyWithImpl(
      _$CreateGoalDataImpl _value, $Res Function(_$CreateGoalDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateGoalData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = freezed,
    Object? measurementType = null,
    Object? targetValue = null,
    Object? unitLabel = null,
    Object? incrementStep = null,
    Object? presetType = null,
  }) {
    return _then(_$CreateGoalDataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      measurementType: null == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalMeasurementType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      unitLabel: null == unitLabel
          ? _value.unitLabel
          : unitLabel // ignore: cast_nullable_to_non_nullable
              as String,
      incrementStep: null == incrementStep
          ? _value.incrementStep
          : incrementStep // ignore: cast_nullable_to_non_nullable
              as double,
      presetType: null == presetType
          ? _value.presetType
          : presetType // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoalPresetType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateGoalDataImpl extends _CreateGoalData {
  const _$CreateGoalDataImpl(
      {required this.title,
      this.description,
      required this.measurementType,
      required this.targetValue,
      required this.unitLabel,
      this.incrementStep = 1.0,
      this.presetType = PersonalizedGoalPresetType.custom})
      : super._();

  factory _$CreateGoalDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateGoalDataImplFromJson(json);

  @override
  final String title;
  @override
  final String? description;
  @override
  final PersonalizedGoalMeasurementType measurementType;
  @override
  final double targetValue;
  @override
  final String unitLabel;
  @override
  @JsonKey()
  final double incrementStep;
  @override
  @JsonKey()
  final PersonalizedGoalPresetType presetType;

  @override
  String toString() {
    return 'CreateGoalData(title: $title, description: $description, measurementType: $measurementType, targetValue: $targetValue, unitLabel: $unitLabel, incrementStep: $incrementStep, presetType: $presetType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGoalDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.measurementType, measurementType) ||
                other.measurementType == measurementType) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.unitLabel, unitLabel) ||
                other.unitLabel == unitLabel) &&
            (identical(other.incrementStep, incrementStep) ||
                other.incrementStep == incrementStep) &&
            (identical(other.presetType, presetType) ||
                other.presetType == presetType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, description,
      measurementType, targetValue, unitLabel, incrementStep, presetType);

  /// Create a copy of CreateGoalData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGoalDataImplCopyWith<_$CreateGoalDataImpl> get copyWith =>
      __$$CreateGoalDataImplCopyWithImpl<_$CreateGoalDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateGoalDataImplToJson(
      this,
    );
  }
}

abstract class _CreateGoalData extends CreateGoalData {
  const factory _CreateGoalData(
      {required final String title,
      final String? description,
      required final PersonalizedGoalMeasurementType measurementType,
      required final double targetValue,
      required final String unitLabel,
      final double incrementStep,
      final PersonalizedGoalPresetType presetType}) = _$CreateGoalDataImpl;
  const _CreateGoalData._() : super._();

  factory _CreateGoalData.fromJson(Map<String, dynamic> json) =
      _$CreateGoalDataImpl.fromJson;

  @override
  String get title;
  @override
  String? get description;
  @override
  PersonalizedGoalMeasurementType get measurementType;
  @override
  double get targetValue;
  @override
  String get unitLabel;
  @override
  double get incrementStep;
  @override
  PersonalizedGoalPresetType get presetType;

  /// Create a copy of CreateGoalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateGoalDataImplCopyWith<_$CreateGoalDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalApiResponse _$GoalApiResponseFromJson(Map<String, dynamic> json) {
  return _GoalApiResponse.fromJson(json);
}

/// @nodoc
mixin _$GoalApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  /// Serializes this GoalApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalApiResponseCopyWith<GoalApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalApiResponseCopyWith<$Res> {
  factory $GoalApiResponseCopyWith(
          GoalApiResponse value, $Res Function(GoalApiResponse) then) =
      _$GoalApiResponseCopyWithImpl<$Res, GoalApiResponse>;
  @useResult
  $Res call(
      {bool success,
      String? message,
      String? error,
      Map<String, dynamic>? data});
}

/// @nodoc
class _$GoalApiResponseCopyWithImpl<$Res, $Val extends GoalApiResponse>
    implements $GoalApiResponseCopyWith<$Res> {
  _$GoalApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalApiResponseImplCopyWith<$Res>
    implements $GoalApiResponseCopyWith<$Res> {
  factory _$$GoalApiResponseImplCopyWith(_$GoalApiResponseImpl value,
          $Res Function(_$GoalApiResponseImpl) then) =
      __$$GoalApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String? message,
      String? error,
      Map<String, dynamic>? data});
}

/// @nodoc
class __$$GoalApiResponseImplCopyWithImpl<$Res>
    extends _$GoalApiResponseCopyWithImpl<$Res, _$GoalApiResponseImpl>
    implements _$$GoalApiResponseImplCopyWith<$Res> {
  __$$GoalApiResponseImplCopyWithImpl(
      _$GoalApiResponseImpl _value, $Res Function(_$GoalApiResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_$GoalApiResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
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
class _$GoalApiResponseImpl implements _GoalApiResponse {
  const _$GoalApiResponseImpl(
      {required this.success,
      this.message,
      this.error,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$GoalApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String? message;
  @override
  final String? error;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GoalApiResponse(success: $success, message: $message, error: $error, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, error,
      const DeepCollectionEquality().hash(_data));

  /// Create a copy of GoalApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalApiResponseImplCopyWith<_$GoalApiResponseImpl> get copyWith =>
      __$$GoalApiResponseImplCopyWithImpl<_$GoalApiResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalApiResponseImplToJson(
      this,
    );
  }
}

abstract class _GoalApiResponse implements GoalApiResponse {
  const factory _GoalApiResponse(
      {required final bool success,
      final String? message,
      final String? error,
      final Map<String, dynamic>? data}) = _$GoalApiResponseImpl;

  factory _GoalApiResponse.fromJson(Map<String, dynamic> json) =
      _$GoalApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String? get message;
  @override
  String? get error;
  @override
  Map<String, dynamic>? get data;

  /// Create a copy of GoalApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalApiResponseImplCopyWith<_$GoalApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalStatus _$GoalStatusFromJson(Map<String, dynamic> json) {
  return _GoalStatus.fromJson(json);
}

/// @nodoc
mixin _$GoalStatus {
  PersonalizedGoal get goal => throw _privateConstructorUsedError;
  int get checkinsToday => throw _privateConstructorUsedError;
  double get progressToday => throw _privateConstructorUsedError;
  List<GoalCheckIn> get recentCheckIns => throw _privateConstructorUsedError;
  List<GoalProgressEntry> get recentEntries =>
      throw _privateConstructorUsedError;

  /// Serializes this GoalStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalStatusCopyWith<GoalStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalStatusCopyWith<$Res> {
  factory $GoalStatusCopyWith(
          GoalStatus value, $Res Function(GoalStatus) then) =
      _$GoalStatusCopyWithImpl<$Res, GoalStatus>;
  @useResult
  $Res call(
      {PersonalizedGoal goal,
      int checkinsToday,
      double progressToday,
      List<GoalCheckIn> recentCheckIns,
      List<GoalProgressEntry> recentEntries});

  $PersonalizedGoalCopyWith<$Res> get goal;
}

/// @nodoc
class _$GoalStatusCopyWithImpl<$Res, $Val extends GoalStatus>
    implements $GoalStatusCopyWith<$Res> {
  _$GoalStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? checkinsToday = null,
    Object? progressToday = null,
    Object? recentCheckIns = null,
    Object? recentEntries = null,
  }) {
    return _then(_value.copyWith(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoal,
      checkinsToday: null == checkinsToday
          ? _value.checkinsToday
          : checkinsToday // ignore: cast_nullable_to_non_nullable
              as int,
      progressToday: null == progressToday
          ? _value.progressToday
          : progressToday // ignore: cast_nullable_to_non_nullable
              as double,
      recentCheckIns: null == recentCheckIns
          ? _value.recentCheckIns
          : recentCheckIns // ignore: cast_nullable_to_non_nullable
              as List<GoalCheckIn>,
      recentEntries: null == recentEntries
          ? _value.recentEntries
          : recentEntries // ignore: cast_nullable_to_non_nullable
              as List<GoalProgressEntry>,
    ) as $Val);
  }

  /// Create a copy of GoalStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonalizedGoalCopyWith<$Res> get goal {
    return $PersonalizedGoalCopyWith<$Res>(_value.goal, (value) {
      return _then(_value.copyWith(goal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GoalStatusImplCopyWith<$Res>
    implements $GoalStatusCopyWith<$Res> {
  factory _$$GoalStatusImplCopyWith(
          _$GoalStatusImpl value, $Res Function(_$GoalStatusImpl) then) =
      __$$GoalStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PersonalizedGoal goal,
      int checkinsToday,
      double progressToday,
      List<GoalCheckIn> recentCheckIns,
      List<GoalProgressEntry> recentEntries});

  @override
  $PersonalizedGoalCopyWith<$Res> get goal;
}

/// @nodoc
class __$$GoalStatusImplCopyWithImpl<$Res>
    extends _$GoalStatusCopyWithImpl<$Res, _$GoalStatusImpl>
    implements _$$GoalStatusImplCopyWith<$Res> {
  __$$GoalStatusImplCopyWithImpl(
      _$GoalStatusImpl _value, $Res Function(_$GoalStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? checkinsToday = null,
    Object? progressToday = null,
    Object? recentCheckIns = null,
    Object? recentEntries = null,
  }) {
    return _then(_$GoalStatusImpl(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as PersonalizedGoal,
      checkinsToday: null == checkinsToday
          ? _value.checkinsToday
          : checkinsToday // ignore: cast_nullable_to_non_nullable
              as int,
      progressToday: null == progressToday
          ? _value.progressToday
          : progressToday // ignore: cast_nullable_to_non_nullable
              as double,
      recentCheckIns: null == recentCheckIns
          ? _value._recentCheckIns
          : recentCheckIns // ignore: cast_nullable_to_non_nullable
              as List<GoalCheckIn>,
      recentEntries: null == recentEntries
          ? _value._recentEntries
          : recentEntries // ignore: cast_nullable_to_non_nullable
              as List<GoalProgressEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalStatusImpl extends _GoalStatus {
  const _$GoalStatusImpl(
      {required this.goal,
      this.checkinsToday = 0,
      this.progressToday = 0.0,
      final List<GoalCheckIn> recentCheckIns = const [],
      final List<GoalProgressEntry> recentEntries = const []})
      : _recentCheckIns = recentCheckIns,
        _recentEntries = recentEntries,
        super._();

  factory _$GoalStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalStatusImplFromJson(json);

  @override
  final PersonalizedGoal goal;
  @override
  @JsonKey()
  final int checkinsToday;
  @override
  @JsonKey()
  final double progressToday;
  final List<GoalCheckIn> _recentCheckIns;
  @override
  @JsonKey()
  List<GoalCheckIn> get recentCheckIns {
    if (_recentCheckIns is EqualUnmodifiableListView) return _recentCheckIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentCheckIns);
  }

  final List<GoalProgressEntry> _recentEntries;
  @override
  @JsonKey()
  List<GoalProgressEntry> get recentEntries {
    if (_recentEntries is EqualUnmodifiableListView) return _recentEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentEntries);
  }

  @override
  String toString() {
    return 'GoalStatus(goal: $goal, checkinsToday: $checkinsToday, progressToday: $progressToday, recentCheckIns: $recentCheckIns, recentEntries: $recentEntries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalStatusImpl &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.checkinsToday, checkinsToday) ||
                other.checkinsToday == checkinsToday) &&
            (identical(other.progressToday, progressToday) ||
                other.progressToday == progressToday) &&
            const DeepCollectionEquality()
                .equals(other._recentCheckIns, _recentCheckIns) &&
            const DeepCollectionEquality()
                .equals(other._recentEntries, _recentEntries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      goal,
      checkinsToday,
      progressToday,
      const DeepCollectionEquality().hash(_recentCheckIns),
      const DeepCollectionEquality().hash(_recentEntries));

  /// Create a copy of GoalStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalStatusImplCopyWith<_$GoalStatusImpl> get copyWith =>
      __$$GoalStatusImplCopyWithImpl<_$GoalStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalStatusImplToJson(
      this,
    );
  }
}

abstract class _GoalStatus extends GoalStatus {
  const factory _GoalStatus(
      {required final PersonalizedGoal goal,
      final int checkinsToday,
      final double progressToday,
      final List<GoalCheckIn> recentCheckIns,
      final List<GoalProgressEntry> recentEntries}) = _$GoalStatusImpl;
  const _GoalStatus._() : super._();

  factory _GoalStatus.fromJson(Map<String, dynamic> json) =
      _$GoalStatusImpl.fromJson;

  @override
  PersonalizedGoal get goal;
  @override
  int get checkinsToday;
  @override
  double get progressToday;
  @override
  List<GoalCheckIn> get recentCheckIns;
  @override
  List<GoalProgressEntry> get recentEntries;

  /// Create a copy of GoalStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalStatusImplCopyWith<_$GoalStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
