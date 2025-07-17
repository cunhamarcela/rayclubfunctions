// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_section_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSection _$WorkoutSectionFromJson(Map<String, dynamic> json) {
  return _WorkoutSection.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSection {
  /// Nome da seção
  String get name => throw _privateConstructorUsedError;

  /// Descrição da seção (opcional)
  String? get description => throw _privateConstructorUsedError;

  /// Ordem da seção no treino
  int get order => throw _privateConstructorUsedError;

  /// Lista de exercícios na seção
  List<Exercise> get exercises => throw _privateConstructorUsedError;

  /// Tempo estimado em minutos para esta seção
  int get estimatedTimeMinutes => throw _privateConstructorUsedError;

  /// Serializes this WorkoutSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutSectionCopyWith<WorkoutSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSectionCopyWith<$Res> {
  factory $WorkoutSectionCopyWith(
          WorkoutSection value, $Res Function(WorkoutSection) then) =
      _$WorkoutSectionCopyWithImpl<$Res, WorkoutSection>;
  @useResult
  $Res call(
      {String name,
      String? description,
      int order,
      List<Exercise> exercises,
      int estimatedTimeMinutes});
}

/// @nodoc
class _$WorkoutSectionCopyWithImpl<$Res, $Val extends WorkoutSection>
    implements $WorkoutSectionCopyWith<$Res> {
  _$WorkoutSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? order = null,
    Object? exercises = null,
    Object? estimatedTimeMinutes = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      estimatedTimeMinutes: null == estimatedTimeMinutes
          ? _value.estimatedTimeMinutes
          : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSectionImplCopyWith<$Res>
    implements $WorkoutSectionCopyWith<$Res> {
  factory _$$WorkoutSectionImplCopyWith(_$WorkoutSectionImpl value,
          $Res Function(_$WorkoutSectionImpl) then) =
      __$$WorkoutSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      int order,
      List<Exercise> exercises,
      int estimatedTimeMinutes});
}

/// @nodoc
class __$$WorkoutSectionImplCopyWithImpl<$Res>
    extends _$WorkoutSectionCopyWithImpl<$Res, _$WorkoutSectionImpl>
    implements _$$WorkoutSectionImplCopyWith<$Res> {
  __$$WorkoutSectionImplCopyWithImpl(
      _$WorkoutSectionImpl _value, $Res Function(_$WorkoutSectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? order = null,
    Object? exercises = null,
    Object? estimatedTimeMinutes = null,
  }) {
    return _then(_$WorkoutSectionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      estimatedTimeMinutes: null == estimatedTimeMinutes
          ? _value.estimatedTimeMinutes
          : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSectionImpl implements _WorkoutSection {
  const _$WorkoutSectionImpl(
      {required this.name,
      this.description,
      this.order = 0,
      required final List<Exercise> exercises,
      this.estimatedTimeMinutes = 0})
      : _exercises = exercises;

  factory _$WorkoutSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSectionImplFromJson(json);

  /// Nome da seção
  @override
  final String name;

  /// Descrição da seção (opcional)
  @override
  final String? description;

  /// Ordem da seção no treino
  @override
  @JsonKey()
  final int order;

  /// Lista de exercícios na seção
  final List<Exercise> _exercises;

  /// Lista de exercícios na seção
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  /// Tempo estimado em minutos para esta seção
  @override
  @JsonKey()
  final int estimatedTimeMinutes;

  @override
  String toString() {
    return 'WorkoutSection(name: $name, description: $description, order: $order, exercises: $exercises, estimatedTimeMinutes: $estimatedTimeMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSectionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.estimatedTimeMinutes, estimatedTimeMinutes) ||
                other.estimatedTimeMinutes == estimatedTimeMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description, order,
      const DeepCollectionEquality().hash(_exercises), estimatedTimeMinutes);

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSectionImplCopyWith<_$WorkoutSectionImpl> get copyWith =>
      __$$WorkoutSectionImplCopyWithImpl<_$WorkoutSectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSectionImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSection implements WorkoutSection {
  const factory _WorkoutSection(
      {required final String name,
      final String? description,
      final int order,
      required final List<Exercise> exercises,
      final int estimatedTimeMinutes}) = _$WorkoutSectionImpl;

  factory _WorkoutSection.fromJson(Map<String, dynamic> json) =
      _$WorkoutSectionImpl.fromJson;

  /// Nome da seção
  @override
  String get name;

  /// Descrição da seção (opcional)
  @override
  String? get description;

  /// Ordem da seção no treino
  @override
  int get order;

  /// Lista de exercícios na seção
  @override
  List<Exercise> get exercises;

  /// Tempo estimado em minutos para esta seção
  @override
  int get estimatedTimeMinutes;

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutSectionImplCopyWith<_$WorkoutSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
