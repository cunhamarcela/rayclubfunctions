// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_category_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutCategoryGoal _$WorkoutCategoryGoalFromJson(Map<String, dynamic> json) {
  return _WorkoutCategoryGoal.fromJson(json);
}

/// @nodoc
mixin _$WorkoutCategoryGoal {
  /// Identificador único da meta
  String get id => throw _privateConstructorUsedError;

  /// Identificador do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Categoria do treino (corrida, yoga, funcional, etc.)
  String get category => throw _privateConstructorUsedError;

  /// Meta em minutos para a semana
  int get goalMinutes => throw _privateConstructorUsedError;

  /// Minutos acumulados na semana atual
  int get currentMinutes => throw _privateConstructorUsedError;

  /// Data de início da semana
  DateTime get weekStartDate => throw _privateConstructorUsedError;

  /// Data de fim da semana
  DateTime get weekEndDate => throw _privateConstructorUsedError;

  /// Se a meta está ativa
  bool get isActive => throw _privateConstructorUsedError;

  /// Se a meta foi completada
  bool get completed => throw _privateConstructorUsedError;

  /// Data de criação
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WorkoutCategoryGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutCategoryGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutCategoryGoalCopyWith<WorkoutCategoryGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCategoryGoalCopyWith<$Res> {
  factory $WorkoutCategoryGoalCopyWith(
          WorkoutCategoryGoal value, $Res Function(WorkoutCategoryGoal) then) =
      _$WorkoutCategoryGoalCopyWithImpl<$Res, WorkoutCategoryGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String category,
      int goalMinutes,
      int currentMinutes,
      DateTime weekStartDate,
      DateTime weekEndDate,
      bool isActive,
      bool completed,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$WorkoutCategoryGoalCopyWithImpl<$Res, $Val extends WorkoutCategoryGoal>
    implements $WorkoutCategoryGoalCopyWith<$Res> {
  _$WorkoutCategoryGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutCategoryGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? category = null,
    Object? goalMinutes = null,
    Object? currentMinutes = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
    Object? isActive = null,
    Object? completed = null,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
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
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WorkoutCategoryGoalImplCopyWith<$Res>
    implements $WorkoutCategoryGoalCopyWith<$Res> {
  factory _$$WorkoutCategoryGoalImplCopyWith(_$WorkoutCategoryGoalImpl value,
          $Res Function(_$WorkoutCategoryGoalImpl) then) =
      __$$WorkoutCategoryGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String category,
      int goalMinutes,
      int currentMinutes,
      DateTime weekStartDate,
      DateTime weekEndDate,
      bool isActive,
      bool completed,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$WorkoutCategoryGoalImplCopyWithImpl<$Res>
    extends _$WorkoutCategoryGoalCopyWithImpl<$Res, _$WorkoutCategoryGoalImpl>
    implements _$$WorkoutCategoryGoalImplCopyWith<$Res> {
  __$$WorkoutCategoryGoalImplCopyWithImpl(_$WorkoutCategoryGoalImpl _value,
      $Res Function(_$WorkoutCategoryGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutCategoryGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? category = null,
    Object? goalMinutes = null,
    Object? currentMinutes = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
    Object? isActive = null,
    Object? completed = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WorkoutCategoryGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
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
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
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
class _$WorkoutCategoryGoalImpl extends _WorkoutCategoryGoal {
  const _$WorkoutCategoryGoalImpl(
      {required this.id,
      required this.userId,
      required this.category,
      required this.goalMinutes,
      this.currentMinutes = 0,
      required this.weekStartDate,
      required this.weekEndDate,
      this.isActive = true,
      this.completed = false,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$WorkoutCategoryGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutCategoryGoalImplFromJson(json);

  /// Identificador único da meta
  @override
  final String id;

  /// Identificador do usuário
  @override
  final String userId;

  /// Categoria do treino (corrida, yoga, funcional, etc.)
  @override
  final String category;

  /// Meta em minutos para a semana
  @override
  final int goalMinutes;

  /// Minutos acumulados na semana atual
  @override
  @JsonKey()
  final int currentMinutes;

  /// Data de início da semana
  @override
  final DateTime weekStartDate;

  /// Data de fim da semana
  @override
  final DateTime weekEndDate;

  /// Se a meta está ativa
  @override
  @JsonKey()
  final bool isActive;

  /// Se a meta foi completada
  @override
  @JsonKey()
  final bool completed;

  /// Data de criação
  @override
  final DateTime createdAt;

  /// Data da última atualização
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WorkoutCategoryGoal(id: $id, userId: $userId, category: $category, goalMinutes: $goalMinutes, currentMinutes: $currentMinutes, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate, isActive: $isActive, completed: $completed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutCategoryGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.goalMinutes, goalMinutes) ||
                other.goalMinutes == goalMinutes) &&
            (identical(other.currentMinutes, currentMinutes) ||
                other.currentMinutes == currentMinutes) &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.weekEndDate, weekEndDate) ||
                other.weekEndDate == weekEndDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
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
      category,
      goalMinutes,
      currentMinutes,
      weekStartDate,
      weekEndDate,
      isActive,
      completed,
      createdAt,
      updatedAt);

  /// Create a copy of WorkoutCategoryGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutCategoryGoalImplCopyWith<_$WorkoutCategoryGoalImpl> get copyWith =>
      __$$WorkoutCategoryGoalImplCopyWithImpl<_$WorkoutCategoryGoalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutCategoryGoalImplToJson(
      this,
    );
  }
}

abstract class _WorkoutCategoryGoal extends WorkoutCategoryGoal {
  const factory _WorkoutCategoryGoal(
      {required final String id,
      required final String userId,
      required final String category,
      required final int goalMinutes,
      final int currentMinutes,
      required final DateTime weekStartDate,
      required final DateTime weekEndDate,
      final bool isActive,
      final bool completed,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$WorkoutCategoryGoalImpl;
  const _WorkoutCategoryGoal._() : super._();

  factory _WorkoutCategoryGoal.fromJson(Map<String, dynamic> json) =
      _$WorkoutCategoryGoalImpl.fromJson;

  /// Identificador único da meta
  @override
  String get id;

  /// Identificador do usuário
  @override
  String get userId;

  /// Categoria do treino (corrida, yoga, funcional, etc.)
  @override
  String get category;

  /// Meta em minutos para a semana
  @override
  int get goalMinutes;

  /// Minutos acumulados na semana atual
  @override
  int get currentMinutes;

  /// Data de início da semana
  @override
  DateTime get weekStartDate;

  /// Data de fim da semana
  @override
  DateTime get weekEndDate;

  /// Se a meta está ativa
  @override
  bool get isActive;

  /// Se a meta foi completada
  @override
  bool get completed;

  /// Data de criação
  @override
  DateTime get createdAt;

  /// Data da última atualização
  @override
  DateTime? get updatedAt;

  /// Create a copy of WorkoutCategoryGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutCategoryGoalImplCopyWith<_$WorkoutCategoryGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyEvolution _$WeeklyEvolutionFromJson(Map<String, dynamic> json) {
  return _WeeklyEvolution.fromJson(json);
}

/// @nodoc
mixin _$WeeklyEvolution {
  /// Data de início da semana
  DateTime get weekStartDate => throw _privateConstructorUsedError;

  /// Meta em minutos para a semana
  int get goalMinutes => throw _privateConstructorUsedError;

  /// Minutos realizados na semana
  int get currentMinutes => throw _privateConstructorUsedError;

  /// Percentual completado
  double get percentageCompleted => throw _privateConstructorUsedError;

  /// Se a meta foi completada
  bool get completed => throw _privateConstructorUsedError;

  /// Serializes this WeeklyEvolution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyEvolution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyEvolutionCopyWith<WeeklyEvolution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyEvolutionCopyWith<$Res> {
  factory $WeeklyEvolutionCopyWith(
          WeeklyEvolution value, $Res Function(WeeklyEvolution) then) =
      _$WeeklyEvolutionCopyWithImpl<$Res, WeeklyEvolution>;
  @useResult
  $Res call(
      {DateTime weekStartDate,
      int goalMinutes,
      int currentMinutes,
      double percentageCompleted,
      bool completed});
}

/// @nodoc
class _$WeeklyEvolutionCopyWithImpl<$Res, $Val extends WeeklyEvolution>
    implements $WeeklyEvolutionCopyWith<$Res> {
  _$WeeklyEvolutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyEvolution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStartDate = null,
    Object? goalMinutes = null,
    Object? currentMinutes = null,
    Object? percentageCompleted = null,
    Object? completed = null,
  }) {
    return _then(_value.copyWith(
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      currentMinutes: null == currentMinutes
          ? _value.currentMinutes
          : currentMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      percentageCompleted: null == percentageCompleted
          ? _value.percentageCompleted
          : percentageCompleted // ignore: cast_nullable_to_non_nullable
              as double,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyEvolutionImplCopyWith<$Res>
    implements $WeeklyEvolutionCopyWith<$Res> {
  factory _$$WeeklyEvolutionImplCopyWith(_$WeeklyEvolutionImpl value,
          $Res Function(_$WeeklyEvolutionImpl) then) =
      __$$WeeklyEvolutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime weekStartDate,
      int goalMinutes,
      int currentMinutes,
      double percentageCompleted,
      bool completed});
}

/// @nodoc
class __$$WeeklyEvolutionImplCopyWithImpl<$Res>
    extends _$WeeklyEvolutionCopyWithImpl<$Res, _$WeeklyEvolutionImpl>
    implements _$$WeeklyEvolutionImplCopyWith<$Res> {
  __$$WeeklyEvolutionImplCopyWithImpl(
      _$WeeklyEvolutionImpl _value, $Res Function(_$WeeklyEvolutionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyEvolution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStartDate = null,
    Object? goalMinutes = null,
    Object? currentMinutes = null,
    Object? percentageCompleted = null,
    Object? completed = null,
  }) {
    return _then(_$WeeklyEvolutionImpl(
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      currentMinutes: null == currentMinutes
          ? _value.currentMinutes
          : currentMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      percentageCompleted: null == percentageCompleted
          ? _value.percentageCompleted
          : percentageCompleted // ignore: cast_nullable_to_non_nullable
              as double,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyEvolutionImpl extends _WeeklyEvolution {
  const _$WeeklyEvolutionImpl(
      {required this.weekStartDate,
      required this.goalMinutes,
      required this.currentMinutes,
      required this.percentageCompleted,
      required this.completed})
      : super._();

  factory _$WeeklyEvolutionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyEvolutionImplFromJson(json);

  /// Data de início da semana
  @override
  final DateTime weekStartDate;

  /// Meta em minutos para a semana
  @override
  final int goalMinutes;

  /// Minutos realizados na semana
  @override
  final int currentMinutes;

  /// Percentual completado
  @override
  final double percentageCompleted;

  /// Se a meta foi completada
  @override
  final bool completed;

  @override
  String toString() {
    return 'WeeklyEvolution(weekStartDate: $weekStartDate, goalMinutes: $goalMinutes, currentMinutes: $currentMinutes, percentageCompleted: $percentageCompleted, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyEvolutionImpl &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.goalMinutes, goalMinutes) ||
                other.goalMinutes == goalMinutes) &&
            (identical(other.currentMinutes, currentMinutes) ||
                other.currentMinutes == currentMinutes) &&
            (identical(other.percentageCompleted, percentageCompleted) ||
                other.percentageCompleted == percentageCompleted) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, weekStartDate, goalMinutes,
      currentMinutes, percentageCompleted, completed);

  /// Create a copy of WeeklyEvolution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyEvolutionImplCopyWith<_$WeeklyEvolutionImpl> get copyWith =>
      __$$WeeklyEvolutionImplCopyWithImpl<_$WeeklyEvolutionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyEvolutionImplToJson(
      this,
    );
  }
}

abstract class _WeeklyEvolution extends WeeklyEvolution {
  const factory _WeeklyEvolution(
      {required final DateTime weekStartDate,
      required final int goalMinutes,
      required final int currentMinutes,
      required final double percentageCompleted,
      required final bool completed}) = _$WeeklyEvolutionImpl;
  const _WeeklyEvolution._() : super._();

  factory _WeeklyEvolution.fromJson(Map<String, dynamic> json) =
      _$WeeklyEvolutionImpl.fromJson;

  /// Data de início da semana
  @override
  DateTime get weekStartDate;

  /// Meta em minutos para a semana
  @override
  int get goalMinutes;

  /// Minutos realizados na semana
  @override
  int get currentMinutes;

  /// Percentual completado
  @override
  double get percentageCompleted;

  /// Se a meta foi completada
  @override
  bool get completed;

  /// Create a copy of WeeklyEvolution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyEvolutionImplCopyWith<_$WeeklyEvolutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
