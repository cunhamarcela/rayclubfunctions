// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecipeFilter _$RecipeFilterFromJson(Map<String, dynamic> json) {
  return _RecipeFilter.fromJson(json);
}

/// @nodoc
mixin _$RecipeFilter {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  RecipeFilterCategory get category => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;

  /// Serializes this RecipeFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecipeFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeFilterCopyWith<RecipeFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeFilterCopyWith<$Res> {
  factory $RecipeFilterCopyWith(
          RecipeFilter value, $Res Function(RecipeFilter) then) =
      _$RecipeFilterCopyWithImpl<$Res, RecipeFilter>;
  @useResult
  $Res call(
      {String id, String name, RecipeFilterCategory category, bool isSelected});
}

/// @nodoc
class _$RecipeFilterCopyWithImpl<$Res, $Val extends RecipeFilter>
    implements $RecipeFilterCopyWith<$Res> {
  _$RecipeFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? isSelected = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecipeFilterCategory,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeFilterImplCopyWith<$Res>
    implements $RecipeFilterCopyWith<$Res> {
  factory _$$RecipeFilterImplCopyWith(
          _$RecipeFilterImpl value, $Res Function(_$RecipeFilterImpl) then) =
      __$$RecipeFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, RecipeFilterCategory category, bool isSelected});
}

/// @nodoc
class __$$RecipeFilterImplCopyWithImpl<$Res>
    extends _$RecipeFilterCopyWithImpl<$Res, _$RecipeFilterImpl>
    implements _$$RecipeFilterImplCopyWith<$Res> {
  __$$RecipeFilterImplCopyWithImpl(
      _$RecipeFilterImpl _value, $Res Function(_$RecipeFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecipeFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? isSelected = null,
  }) {
    return _then(_$RecipeFilterImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecipeFilterCategory,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeFilterImpl implements _RecipeFilter {
  const _$RecipeFilterImpl(
      {required this.id,
      required this.name,
      required this.category,
      this.isSelected = false});

  factory _$RecipeFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeFilterImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final RecipeFilterCategory category;
  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'RecipeFilter(id: $id, name: $name, category: $category, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeFilterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, category, isSelected);

  /// Create a copy of RecipeFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeFilterImplCopyWith<_$RecipeFilterImpl> get copyWith =>
      __$$RecipeFilterImplCopyWithImpl<_$RecipeFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeFilterImplToJson(
      this,
    );
  }
}

abstract class _RecipeFilter implements RecipeFilter {
  const factory _RecipeFilter(
      {required final String id,
      required final String name,
      required final RecipeFilterCategory category,
      final bool isSelected}) = _$RecipeFilterImpl;

  factory _RecipeFilter.fromJson(Map<String, dynamic> json) =
      _$RecipeFilterImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  RecipeFilterCategory get category;
  @override
  bool get isSelected;

  /// Create a copy of RecipeFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeFilterImplCopyWith<_$RecipeFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecipeFilterState _$RecipeFilterStateFromJson(Map<String, dynamic> json) {
  return _RecipeFilterState.fromJson(json);
}

/// @nodoc
mixin _$RecipeFilterState {
  List<RecipeFilter> get availableFilters => throw _privateConstructorUsedError;
  List<RecipeFilter> get selectedFilters => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this RecipeFilterState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecipeFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeFilterStateCopyWith<RecipeFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeFilterStateCopyWith<$Res> {
  factory $RecipeFilterStateCopyWith(
          RecipeFilterState value, $Res Function(RecipeFilterState) then) =
      _$RecipeFilterStateCopyWithImpl<$Res, RecipeFilterState>;
  @useResult
  $Res call(
      {List<RecipeFilter> availableFilters,
      List<RecipeFilter> selectedFilters,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$RecipeFilterStateCopyWithImpl<$Res, $Val extends RecipeFilterState>
    implements $RecipeFilterStateCopyWith<$Res> {
  _$RecipeFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableFilters = null,
    Object? selectedFilters = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      availableFilters: null == availableFilters
          ? _value.availableFilters
          : availableFilters // ignore: cast_nullable_to_non_nullable
              as List<RecipeFilter>,
      selectedFilters: null == selectedFilters
          ? _value.selectedFilters
          : selectedFilters // ignore: cast_nullable_to_non_nullable
              as List<RecipeFilter>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeFilterStateImplCopyWith<$Res>
    implements $RecipeFilterStateCopyWith<$Res> {
  factory _$$RecipeFilterStateImplCopyWith(_$RecipeFilterStateImpl value,
          $Res Function(_$RecipeFilterStateImpl) then) =
      __$$RecipeFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<RecipeFilter> availableFilters,
      List<RecipeFilter> selectedFilters,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$RecipeFilterStateImplCopyWithImpl<$Res>
    extends _$RecipeFilterStateCopyWithImpl<$Res, _$RecipeFilterStateImpl>
    implements _$$RecipeFilterStateImplCopyWith<$Res> {
  __$$RecipeFilterStateImplCopyWithImpl(_$RecipeFilterStateImpl _value,
      $Res Function(_$RecipeFilterStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecipeFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableFilters = null,
    Object? selectedFilters = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$RecipeFilterStateImpl(
      availableFilters: null == availableFilters
          ? _value._availableFilters
          : availableFilters // ignore: cast_nullable_to_non_nullable
              as List<RecipeFilter>,
      selectedFilters: null == selectedFilters
          ? _value._selectedFilters
          : selectedFilters // ignore: cast_nullable_to_non_nullable
              as List<RecipeFilter>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeFilterStateImpl implements _RecipeFilterState {
  const _$RecipeFilterStateImpl(
      {final List<RecipeFilter> availableFilters = const [],
      final List<RecipeFilter> selectedFilters = const [],
      this.isLoading = false,
      this.errorMessage})
      : _availableFilters = availableFilters,
        _selectedFilters = selectedFilters;

  factory _$RecipeFilterStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeFilterStateImplFromJson(json);

  final List<RecipeFilter> _availableFilters;
  @override
  @JsonKey()
  List<RecipeFilter> get availableFilters {
    if (_availableFilters is EqualUnmodifiableListView)
      return _availableFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableFilters);
  }

  final List<RecipeFilter> _selectedFilters;
  @override
  @JsonKey()
  List<RecipeFilter> get selectedFilters {
    if (_selectedFilters is EqualUnmodifiableListView) return _selectedFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedFilters);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'RecipeFilterState(availableFilters: $availableFilters, selectedFilters: $selectedFilters, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeFilterStateImpl &&
            const DeepCollectionEquality()
                .equals(other._availableFilters, _availableFilters) &&
            const DeepCollectionEquality()
                .equals(other._selectedFilters, _selectedFilters) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_availableFilters),
      const DeepCollectionEquality().hash(_selectedFilters),
      isLoading,
      errorMessage);

  /// Create a copy of RecipeFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeFilterStateImplCopyWith<_$RecipeFilterStateImpl> get copyWith =>
      __$$RecipeFilterStateImplCopyWithImpl<_$RecipeFilterStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeFilterStateImplToJson(
      this,
    );
  }
}

abstract class _RecipeFilterState implements RecipeFilterState {
  const factory _RecipeFilterState(
      {final List<RecipeFilter> availableFilters,
      final List<RecipeFilter> selectedFilters,
      final bool isLoading,
      final String? errorMessage}) = _$RecipeFilterStateImpl;

  factory _RecipeFilterState.fromJson(Map<String, dynamic> json) =
      _$RecipeFilterStateImpl.fromJson;

  @override
  List<RecipeFilter> get availableFilters;
  @override
  List<RecipeFilter> get selectedFilters;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of RecipeFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeFilterStateImplCopyWith<_$RecipeFilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
