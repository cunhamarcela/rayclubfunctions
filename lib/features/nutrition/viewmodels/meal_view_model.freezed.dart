// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MealState {
  List<Meal> get meals => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isMealAdded => throw _privateConstructorUsedError;
  bool get isMealUpdated => throw _privateConstructorUsedError;
  bool get isMealDeleted => throw _privateConstructorUsedError;

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealStateCopyWith<MealState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealStateCopyWith<$Res> {
  factory $MealStateCopyWith(MealState value, $Res Function(MealState) then) =
      _$MealStateCopyWithImpl<$Res, MealState>;
  @useResult
  $Res call(
      {List<Meal> meals,
      bool isLoading,
      String? error,
      bool isMealAdded,
      bool isMealUpdated,
      bool isMealDeleted});
}

/// @nodoc
class _$MealStateCopyWithImpl<$Res, $Val extends MealState>
    implements $MealStateCopyWith<$Res> {
  _$MealStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meals = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isMealAdded = null,
    Object? isMealUpdated = null,
    Object? isMealDeleted = null,
  }) {
    return _then(_value.copyWith(
      meals: null == meals
          ? _value.meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<Meal>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isMealAdded: null == isMealAdded
          ? _value.isMealAdded
          : isMealAdded // ignore: cast_nullable_to_non_nullable
              as bool,
      isMealUpdated: null == isMealUpdated
          ? _value.isMealUpdated
          : isMealUpdated // ignore: cast_nullable_to_non_nullable
              as bool,
      isMealDeleted: null == isMealDeleted
          ? _value.isMealDeleted
          : isMealDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealStateImplCopyWith<$Res>
    implements $MealStateCopyWith<$Res> {
  factory _$$MealStateImplCopyWith(
          _$MealStateImpl value, $Res Function(_$MealStateImpl) then) =
      __$$MealStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Meal> meals,
      bool isLoading,
      String? error,
      bool isMealAdded,
      bool isMealUpdated,
      bool isMealDeleted});
}

/// @nodoc
class __$$MealStateImplCopyWithImpl<$Res>
    extends _$MealStateCopyWithImpl<$Res, _$MealStateImpl>
    implements _$$MealStateImplCopyWith<$Res> {
  __$$MealStateImplCopyWithImpl(
      _$MealStateImpl _value, $Res Function(_$MealStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meals = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isMealAdded = null,
    Object? isMealUpdated = null,
    Object? isMealDeleted = null,
  }) {
    return _then(_$MealStateImpl(
      meals: null == meals
          ? _value._meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<Meal>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isMealAdded: null == isMealAdded
          ? _value.isMealAdded
          : isMealAdded // ignore: cast_nullable_to_non_nullable
              as bool,
      isMealUpdated: null == isMealUpdated
          ? _value.isMealUpdated
          : isMealUpdated // ignore: cast_nullable_to_non_nullable
              as bool,
      isMealDeleted: null == isMealDeleted
          ? _value.isMealDeleted
          : isMealDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MealStateImpl implements _MealState {
  const _$MealStateImpl(
      {final List<Meal> meals = const [],
      this.isLoading = false,
      this.error,
      this.isMealAdded = false,
      this.isMealUpdated = false,
      this.isMealDeleted = false})
      : _meals = meals;

  final List<Meal> _meals;
  @override
  @JsonKey()
  List<Meal> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isMealAdded;
  @override
  @JsonKey()
  final bool isMealUpdated;
  @override
  @JsonKey()
  final bool isMealDeleted;

  @override
  String toString() {
    return 'MealState(meals: $meals, isLoading: $isLoading, error: $error, isMealAdded: $isMealAdded, isMealUpdated: $isMealUpdated, isMealDeleted: $isMealDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealStateImpl &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isMealAdded, isMealAdded) ||
                other.isMealAdded == isMealAdded) &&
            (identical(other.isMealUpdated, isMealUpdated) ||
                other.isMealUpdated == isMealUpdated) &&
            (identical(other.isMealDeleted, isMealDeleted) ||
                other.isMealDeleted == isMealDeleted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_meals),
      isLoading,
      error,
      isMealAdded,
      isMealUpdated,
      isMealDeleted);

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealStateImplCopyWith<_$MealStateImpl> get copyWith =>
      __$$MealStateImplCopyWithImpl<_$MealStateImpl>(this, _$identity);
}

abstract class _MealState implements MealState {
  const factory _MealState(
      {final List<Meal> meals,
      final bool isLoading,
      final String? error,
      final bool isMealAdded,
      final bool isMealUpdated,
      final bool isMealDeleted}) = _$MealStateImpl;

  @override
  List<Meal> get meals;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  bool get isMealAdded;
  @override
  bool get isMealUpdated;
  @override
  bool get isMealDeleted;

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealStateImplCopyWith<_$MealStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
