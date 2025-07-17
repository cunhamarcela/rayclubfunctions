// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_highlights_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WeeklyHighlightsState {
  /// Lista de destaques da semana
  List<WeeklyHighlight> get highlights => throw _privateConstructorUsedError;

  /// Destaque selecionado atualmente
  WeeklyHighlight? get selectedHighlight => throw _privateConstructorUsedError;

  /// Flag indicando se está carregando
  bool get isLoading => throw _privateConstructorUsedError;

  /// Mensagem de erro, se houver
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyHighlightsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyHighlightsStateCopyWith<WeeklyHighlightsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyHighlightsStateCopyWith<$Res> {
  factory $WeeklyHighlightsStateCopyWith(WeeklyHighlightsState value,
          $Res Function(WeeklyHighlightsState) then) =
      _$WeeklyHighlightsStateCopyWithImpl<$Res, WeeklyHighlightsState>;
  @useResult
  $Res call(
      {List<WeeklyHighlight> highlights,
      WeeklyHighlight? selectedHighlight,
      bool isLoading,
      String? error});

  $WeeklyHighlightCopyWith<$Res>? get selectedHighlight;
}

/// @nodoc
class _$WeeklyHighlightsStateCopyWithImpl<$Res,
        $Val extends WeeklyHighlightsState>
    implements $WeeklyHighlightsStateCopyWith<$Res> {
  _$WeeklyHighlightsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyHighlightsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? highlights = null,
    Object? selectedHighlight = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<WeeklyHighlight>,
      selectedHighlight: freezed == selectedHighlight
          ? _value.selectedHighlight
          : selectedHighlight // ignore: cast_nullable_to_non_nullable
              as WeeklyHighlight?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of WeeklyHighlightsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeeklyHighlightCopyWith<$Res>? get selectedHighlight {
    if (_value.selectedHighlight == null) {
      return null;
    }

    return $WeeklyHighlightCopyWith<$Res>(_value.selectedHighlight!, (value) {
      return _then(_value.copyWith(selectedHighlight: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeeklyHighlightsStateImplCopyWith<$Res>
    implements $WeeklyHighlightsStateCopyWith<$Res> {
  factory _$$WeeklyHighlightsStateImplCopyWith(
          _$WeeklyHighlightsStateImpl value,
          $Res Function(_$WeeklyHighlightsStateImpl) then) =
      __$$WeeklyHighlightsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WeeklyHighlight> highlights,
      WeeklyHighlight? selectedHighlight,
      bool isLoading,
      String? error});

  @override
  $WeeklyHighlightCopyWith<$Res>? get selectedHighlight;
}

/// @nodoc
class __$$WeeklyHighlightsStateImplCopyWithImpl<$Res>
    extends _$WeeklyHighlightsStateCopyWithImpl<$Res,
        _$WeeklyHighlightsStateImpl>
    implements _$$WeeklyHighlightsStateImplCopyWith<$Res> {
  __$$WeeklyHighlightsStateImplCopyWithImpl(_$WeeklyHighlightsStateImpl _value,
      $Res Function(_$WeeklyHighlightsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyHighlightsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? highlights = null,
    Object? selectedHighlight = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$WeeklyHighlightsStateImpl(
      highlights: null == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<WeeklyHighlight>,
      selectedHighlight: freezed == selectedHighlight
          ? _value.selectedHighlight
          : selectedHighlight // ignore: cast_nullable_to_non_nullable
              as WeeklyHighlight?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WeeklyHighlightsStateImpl implements _WeeklyHighlightsState {
  const _$WeeklyHighlightsStateImpl(
      {final List<WeeklyHighlight> highlights = const [],
      this.selectedHighlight,
      this.isLoading = false,
      this.error})
      : _highlights = highlights;

  /// Lista de destaques da semana
  final List<WeeklyHighlight> _highlights;

  /// Lista de destaques da semana
  @override
  @JsonKey()
  List<WeeklyHighlight> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  /// Destaque selecionado atualmente
  @override
  final WeeklyHighlight? selectedHighlight;

  /// Flag indicando se está carregando
  @override
  @JsonKey()
  final bool isLoading;

  /// Mensagem de erro, se houver
  @override
  final String? error;

  @override
  String toString() {
    return 'WeeklyHighlightsState(highlights: $highlights, selectedHighlight: $selectedHighlight, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyHighlightsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights) &&
            (identical(other.selectedHighlight, selectedHighlight) ||
                other.selectedHighlight == selectedHighlight) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_highlights),
      selectedHighlight,
      isLoading,
      error);

  /// Create a copy of WeeklyHighlightsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyHighlightsStateImplCopyWith<_$WeeklyHighlightsStateImpl>
      get copyWith => __$$WeeklyHighlightsStateImplCopyWithImpl<
          _$WeeklyHighlightsStateImpl>(this, _$identity);
}

abstract class _WeeklyHighlightsState implements WeeklyHighlightsState {
  const factory _WeeklyHighlightsState(
      {final List<WeeklyHighlight> highlights,
      final WeeklyHighlight? selectedHighlight,
      final bool isLoading,
      final String? error}) = _$WeeklyHighlightsStateImpl;

  /// Lista de destaques da semana
  @override
  List<WeeklyHighlight> get highlights;

  /// Destaque selecionado atualmente
  @override
  WeeklyHighlight? get selectedHighlight;

  /// Flag indicando se está carregando
  @override
  bool get isLoading;

  /// Mensagem de erro, se houver
  @override
  String? get error;

  /// Create a copy of WeeklyHighlightsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyHighlightsStateImplCopyWith<_$WeeklyHighlightsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
