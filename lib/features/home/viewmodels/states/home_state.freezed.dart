// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeState {
  /// Dados completos da Home
  HomeData? get data => throw _privateConstructorUsedError;

  /// Flag para indicar se está carregando
  bool get isLoading => throw _privateConstructorUsedError;

  /// Mensagem de erro se houver falha
  String? get error => throw _privateConstructorUsedError;

  /// Índice do banner atual na exibição
  int get currentBannerIndex => throw _privateConstructorUsedError;

  /// Flag para indicar se a tela foi inicializada
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {HomeData? data,
      bool isLoading,
      String? error,
      int currentBannerIndex,
      bool isInitialized});

  $HomeDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? currentBannerIndex = null,
    Object? isInitialized = null,
  }) {
    return _then(_value.copyWith(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as HomeData?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentBannerIndex: null == currentBannerIndex
          ? _value.currentBannerIndex
          : currentBannerIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HomeDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $HomeDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HomeData? data,
      bool isLoading,
      String? error,
      int currentBannerIndex,
      bool isInitialized});

  @override
  $HomeDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? currentBannerIndex = null,
    Object? isInitialized = null,
  }) {
    return _then(_$HomeStateImpl(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as HomeData?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentBannerIndex: null == currentBannerIndex
          ? _value.currentBannerIndex
          : currentBannerIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl(
      {this.data,
      this.isLoading = false,
      this.error,
      this.currentBannerIndex = 0,
      this.isInitialized = false});

  /// Dados completos da Home
  @override
  final HomeData? data;

  /// Flag para indicar se está carregando
  @override
  @JsonKey()
  final bool isLoading;

  /// Mensagem de erro se houver falha
  @override
  final String? error;

  /// Índice do banner atual na exibição
  @override
  @JsonKey()
  final int currentBannerIndex;

  /// Flag para indicar se a tela foi inicializada
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString() {
    return 'HomeState(data: $data, isLoading: $isLoading, error: $error, currentBannerIndex: $currentBannerIndex, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentBannerIndex, currentBannerIndex) ||
                other.currentBannerIndex == currentBannerIndex) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, data, isLoading, error, currentBannerIndex, isInitialized);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState(
      {final HomeData? data,
      final bool isLoading,
      final String? error,
      final int currentBannerIndex,
      final bool isInitialized}) = _$HomeStateImpl;

  /// Dados completos da Home
  @override
  HomeData? get data;

  /// Flag para indicar se está carregando
  @override
  bool get isLoading;

  /// Mensagem de erro se houver falha
  @override
  String? get error;

  /// Índice do banner atual na exibição
  @override
  int get currentBannerIndex;

  /// Flag para indicar se a tela foi inicializada
  @override
  bool get isInitialized;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
