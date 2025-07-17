// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'featured_content_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeaturedContentState {
  List<FeaturedContent> get contents => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  FeaturedContent? get selectedContent => throw _privateConstructorUsedError;

  /// Create a copy of FeaturedContentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeaturedContentStateCopyWith<FeaturedContentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeaturedContentStateCopyWith<$Res> {
  factory $FeaturedContentStateCopyWith(FeaturedContentState value,
          $Res Function(FeaturedContentState) then) =
      _$FeaturedContentStateCopyWithImpl<$Res, FeaturedContentState>;
  @useResult
  $Res call(
      {List<FeaturedContent> contents,
      bool isLoading,
      String? error,
      FeaturedContent? selectedContent});

  $FeaturedContentCopyWith<$Res>? get selectedContent;
}

/// @nodoc
class _$FeaturedContentStateCopyWithImpl<$Res,
        $Val extends FeaturedContentState>
    implements $FeaturedContentStateCopyWith<$Res> {
  _$FeaturedContentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeaturedContentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contents = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedContent = freezed,
  }) {
    return _then(_value.copyWith(
      contents: null == contents
          ? _value.contents
          : contents // ignore: cast_nullable_to_non_nullable
              as List<FeaturedContent>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedContent: freezed == selectedContent
          ? _value.selectedContent
          : selectedContent // ignore: cast_nullable_to_non_nullable
              as FeaturedContent?,
    ) as $Val);
  }

  /// Create a copy of FeaturedContentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeaturedContentCopyWith<$Res>? get selectedContent {
    if (_value.selectedContent == null) {
      return null;
    }

    return $FeaturedContentCopyWith<$Res>(_value.selectedContent!, (value) {
      return _then(_value.copyWith(selectedContent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeaturedContentStateImplCopyWith<$Res>
    implements $FeaturedContentStateCopyWith<$Res> {
  factory _$$FeaturedContentStateImplCopyWith(_$FeaturedContentStateImpl value,
          $Res Function(_$FeaturedContentStateImpl) then) =
      __$$FeaturedContentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<FeaturedContent> contents,
      bool isLoading,
      String? error,
      FeaturedContent? selectedContent});

  @override
  $FeaturedContentCopyWith<$Res>? get selectedContent;
}

/// @nodoc
class __$$FeaturedContentStateImplCopyWithImpl<$Res>
    extends _$FeaturedContentStateCopyWithImpl<$Res, _$FeaturedContentStateImpl>
    implements _$$FeaturedContentStateImplCopyWith<$Res> {
  __$$FeaturedContentStateImplCopyWithImpl(_$FeaturedContentStateImpl _value,
      $Res Function(_$FeaturedContentStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeaturedContentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contents = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedContent = freezed,
  }) {
    return _then(_$FeaturedContentStateImpl(
      contents: null == contents
          ? _value._contents
          : contents // ignore: cast_nullable_to_non_nullable
              as List<FeaturedContent>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedContent: freezed == selectedContent
          ? _value.selectedContent
          : selectedContent // ignore: cast_nullable_to_non_nullable
              as FeaturedContent?,
    ));
  }
}

/// @nodoc

class _$FeaturedContentStateImpl implements _FeaturedContentState {
  const _$FeaturedContentStateImpl(
      {final List<FeaturedContent> contents = const [],
      this.isLoading = true,
      this.error,
      this.selectedContent})
      : _contents = contents;

  final List<FeaturedContent> _contents;
  @override
  @JsonKey()
  List<FeaturedContent> get contents {
    if (_contents is EqualUnmodifiableListView) return _contents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contents);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final FeaturedContent? selectedContent;

  @override
  String toString() {
    return 'FeaturedContentState(contents: $contents, isLoading: $isLoading, error: $error, selectedContent: $selectedContent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeaturedContentStateImpl &&
            const DeepCollectionEquality().equals(other._contents, _contents) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedContent, selectedContent) ||
                other.selectedContent == selectedContent));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_contents),
      isLoading,
      error,
      selectedContent);

  /// Create a copy of FeaturedContentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeaturedContentStateImplCopyWith<_$FeaturedContentStateImpl>
      get copyWith =>
          __$$FeaturedContentStateImplCopyWithImpl<_$FeaturedContentStateImpl>(
              this, _$identity);
}

abstract class _FeaturedContentState implements FeaturedContentState {
  const factory _FeaturedContentState(
      {final List<FeaturedContent> contents,
      final bool isLoading,
      final String? error,
      final FeaturedContent? selectedContent}) = _$FeaturedContentStateImpl;

  @override
  List<FeaturedContent> get contents;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  FeaturedContent? get selectedContent;

  /// Create a copy of FeaturedContentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeaturedContentStateImplCopyWith<_$FeaturedContentStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
