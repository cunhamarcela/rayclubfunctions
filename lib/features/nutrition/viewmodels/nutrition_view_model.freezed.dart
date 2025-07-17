// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NutritionState {
  List<NutritionItem> get nutritionItems => throw _privateConstructorUsedError;
  List<NutritionItem> get filteredItems => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String get currentFilter => throw _privateConstructorUsedError;

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionStateCopyWith<NutritionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionStateCopyWith<$Res> {
  factory $NutritionStateCopyWith(
          NutritionState value, $Res Function(NutritionState) then) =
      _$NutritionStateCopyWithImpl<$Res, NutritionState>;
  @useResult
  $Res call(
      {List<NutritionItem> nutritionItems,
      List<NutritionItem> filteredItems,
      bool isLoading,
      String? errorMessage,
      String currentFilter});
}

/// @nodoc
class _$NutritionStateCopyWithImpl<$Res, $Val extends NutritionState>
    implements $NutritionStateCopyWith<$Res> {
  _$NutritionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nutritionItems = null,
    Object? filteredItems = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? currentFilter = null,
  }) {
    return _then(_value.copyWith(
      nutritionItems: null == nutritionItems
          ? _value.nutritionItems
          : nutritionItems // ignore: cast_nullable_to_non_nullable
              as List<NutritionItem>,
      filteredItems: null == filteredItems
          ? _value.filteredItems
          : filteredItems // ignore: cast_nullable_to_non_nullable
              as List<NutritionItem>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      currentFilter: null == currentFilter
          ? _value.currentFilter
          : currentFilter // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NutritionStateImplCopyWith<$Res>
    implements $NutritionStateCopyWith<$Res> {
  factory _$$NutritionStateImplCopyWith(_$NutritionStateImpl value,
          $Res Function(_$NutritionStateImpl) then) =
      __$$NutritionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<NutritionItem> nutritionItems,
      List<NutritionItem> filteredItems,
      bool isLoading,
      String? errorMessage,
      String currentFilter});
}

/// @nodoc
class __$$NutritionStateImplCopyWithImpl<$Res>
    extends _$NutritionStateCopyWithImpl<$Res, _$NutritionStateImpl>
    implements _$$NutritionStateImplCopyWith<$Res> {
  __$$NutritionStateImplCopyWithImpl(
      _$NutritionStateImpl _value, $Res Function(_$NutritionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nutritionItems = null,
    Object? filteredItems = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? currentFilter = null,
  }) {
    return _then(_$NutritionStateImpl(
      nutritionItems: null == nutritionItems
          ? _value._nutritionItems
          : nutritionItems // ignore: cast_nullable_to_non_nullable
              as List<NutritionItem>,
      filteredItems: null == filteredItems
          ? _value._filteredItems
          : filteredItems // ignore: cast_nullable_to_non_nullable
              as List<NutritionItem>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      currentFilter: null == currentFilter
          ? _value.currentFilter
          : currentFilter // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NutritionStateImpl implements _NutritionState {
  const _$NutritionStateImpl(
      {final List<NutritionItem> nutritionItems = const [],
      final List<NutritionItem> filteredItems = const [],
      this.isLoading = false,
      this.errorMessage,
      this.currentFilter = 'all'})
      : _nutritionItems = nutritionItems,
        _filteredItems = filteredItems;

  final List<NutritionItem> _nutritionItems;
  @override
  @JsonKey()
  List<NutritionItem> get nutritionItems {
    if (_nutritionItems is EqualUnmodifiableListView) return _nutritionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nutritionItems);
  }

  final List<NutritionItem> _filteredItems;
  @override
  @JsonKey()
  List<NutritionItem> get filteredItems {
    if (_filteredItems is EqualUnmodifiableListView) return _filteredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredItems);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final String currentFilter;

  @override
  String toString() {
    return 'NutritionState(nutritionItems: $nutritionItems, filteredItems: $filteredItems, isLoading: $isLoading, errorMessage: $errorMessage, currentFilter: $currentFilter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionStateImpl &&
            const DeepCollectionEquality()
                .equals(other._nutritionItems, _nutritionItems) &&
            const DeepCollectionEquality()
                .equals(other._filteredItems, _filteredItems) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.currentFilter, currentFilter) ||
                other.currentFilter == currentFilter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_nutritionItems),
      const DeepCollectionEquality().hash(_filteredItems),
      isLoading,
      errorMessage,
      currentFilter);

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionStateImplCopyWith<_$NutritionStateImpl> get copyWith =>
      __$$NutritionStateImplCopyWithImpl<_$NutritionStateImpl>(
          this, _$identity);
}

abstract class _NutritionState implements NutritionState {
  const factory _NutritionState(
      {final List<NutritionItem> nutritionItems,
      final List<NutritionItem> filteredItems,
      final bool isLoading,
      final String? errorMessage,
      final String currentFilter}) = _$NutritionStateImpl;

  @override
  List<NutritionItem> get nutritionItems;
  @override
  List<NutritionItem> get filteredItems;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  String get currentFilter;

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionStateImplCopyWith<_$NutritionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
