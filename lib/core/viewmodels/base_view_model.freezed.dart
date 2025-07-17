// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BaseState<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) data,
    required TResult Function(String message, AppException? exception) error,
    required TResult Function(T? cachedData) offline,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? data,
    TResult? Function(String message, AppException? exception)? error,
    TResult? Function(T? cachedData)? offline,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? data,
    TResult Function(String message, AppException? exception)? error,
    TResult Function(T? cachedData)? offline,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BaseStateInitial<T> value) initial,
    required TResult Function(BaseStateLoading<T> value) loading,
    required TResult Function(BaseStateData<T> value) data,
    required TResult Function(BaseStateError<T> value) error,
    required TResult Function(BaseStateOffline<T> value) offline,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BaseStateInitial<T> value)? initial,
    TResult? Function(BaseStateLoading<T> value)? loading,
    TResult? Function(BaseStateData<T> value)? data,
    TResult? Function(BaseStateError<T> value)? error,
    TResult? Function(BaseStateOffline<T> value)? offline,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BaseStateInitial<T> value)? initial,
    TResult Function(BaseStateLoading<T> value)? loading,
    TResult Function(BaseStateData<T> value)? data,
    TResult Function(BaseStateError<T> value)? error,
    TResult Function(BaseStateOffline<T> value)? offline,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseStateCopyWith<T, $Res> {
  factory $BaseStateCopyWith(
          BaseState<T> value, $Res Function(BaseState<T>) then) =
      _$BaseStateCopyWithImpl<T, $Res, BaseState<T>>;
}

/// @nodoc
class _$BaseStateCopyWithImpl<T, $Res, $Val extends BaseState<T>>
    implements $BaseStateCopyWith<T, $Res> {
  _$BaseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BaseStateInitialImplCopyWith<T, $Res> {
  factory _$$BaseStateInitialImplCopyWith(_$BaseStateInitialImpl<T> value,
          $Res Function(_$BaseStateInitialImpl<T>) then) =
      __$$BaseStateInitialImplCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$BaseStateInitialImplCopyWithImpl<T, $Res>
    extends _$BaseStateCopyWithImpl<T, $Res, _$BaseStateInitialImpl<T>>
    implements _$$BaseStateInitialImplCopyWith<T, $Res> {
  __$$BaseStateInitialImplCopyWithImpl(_$BaseStateInitialImpl<T> _value,
      $Res Function(_$BaseStateInitialImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BaseStateInitialImpl<T>
    with DiagnosticableTreeMixin
    implements BaseStateInitial<T> {
  const _$BaseStateInitialImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BaseState<$T>.initial()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'BaseState<$T>.initial'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseStateInitialImpl<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) data,
    required TResult Function(String message, AppException? exception) error,
    required TResult Function(T? cachedData) offline,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? data,
    TResult? Function(String message, AppException? exception)? error,
    TResult? Function(T? cachedData)? offline,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? data,
    TResult Function(String message, AppException? exception)? error,
    TResult Function(T? cachedData)? offline,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BaseStateInitial<T> value) initial,
    required TResult Function(BaseStateLoading<T> value) loading,
    required TResult Function(BaseStateData<T> value) data,
    required TResult Function(BaseStateError<T> value) error,
    required TResult Function(BaseStateOffline<T> value) offline,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BaseStateInitial<T> value)? initial,
    TResult? Function(BaseStateLoading<T> value)? loading,
    TResult? Function(BaseStateData<T> value)? data,
    TResult? Function(BaseStateError<T> value)? error,
    TResult? Function(BaseStateOffline<T> value)? offline,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BaseStateInitial<T> value)? initial,
    TResult Function(BaseStateLoading<T> value)? loading,
    TResult Function(BaseStateData<T> value)? data,
    TResult Function(BaseStateError<T> value)? error,
    TResult Function(BaseStateOffline<T> value)? offline,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class BaseStateInitial<T> implements BaseState<T> {
  const factory BaseStateInitial() = _$BaseStateInitialImpl<T>;
}

/// @nodoc
abstract class _$$BaseStateLoadingImplCopyWith<T, $Res> {
  factory _$$BaseStateLoadingImplCopyWith(_$BaseStateLoadingImpl<T> value,
          $Res Function(_$BaseStateLoadingImpl<T>) then) =
      __$$BaseStateLoadingImplCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$BaseStateLoadingImplCopyWithImpl<T, $Res>
    extends _$BaseStateCopyWithImpl<T, $Res, _$BaseStateLoadingImpl<T>>
    implements _$$BaseStateLoadingImplCopyWith<T, $Res> {
  __$$BaseStateLoadingImplCopyWithImpl(_$BaseStateLoadingImpl<T> _value,
      $Res Function(_$BaseStateLoadingImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BaseStateLoadingImpl<T>
    with DiagnosticableTreeMixin
    implements BaseStateLoading<T> {
  const _$BaseStateLoadingImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BaseState<$T>.loading()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'BaseState<$T>.loading'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseStateLoadingImpl<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) data,
    required TResult Function(String message, AppException? exception) error,
    required TResult Function(T? cachedData) offline,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? data,
    TResult? Function(String message, AppException? exception)? error,
    TResult? Function(T? cachedData)? offline,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? data,
    TResult Function(String message, AppException? exception)? error,
    TResult Function(T? cachedData)? offline,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BaseStateInitial<T> value) initial,
    required TResult Function(BaseStateLoading<T> value) loading,
    required TResult Function(BaseStateData<T> value) data,
    required TResult Function(BaseStateError<T> value) error,
    required TResult Function(BaseStateOffline<T> value) offline,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BaseStateInitial<T> value)? initial,
    TResult? Function(BaseStateLoading<T> value)? loading,
    TResult? Function(BaseStateData<T> value)? data,
    TResult? Function(BaseStateError<T> value)? error,
    TResult? Function(BaseStateOffline<T> value)? offline,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BaseStateInitial<T> value)? initial,
    TResult Function(BaseStateLoading<T> value)? loading,
    TResult Function(BaseStateData<T> value)? data,
    TResult Function(BaseStateError<T> value)? error,
    TResult Function(BaseStateOffline<T> value)? offline,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class BaseStateLoading<T> implements BaseState<T> {
  const factory BaseStateLoading() = _$BaseStateLoadingImpl<T>;
}

/// @nodoc
abstract class _$$BaseStateDataImplCopyWith<T, $Res> {
  factory _$$BaseStateDataImplCopyWith(_$BaseStateDataImpl<T> value,
          $Res Function(_$BaseStateDataImpl<T>) then) =
      __$$BaseStateDataImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$$BaseStateDataImplCopyWithImpl<T, $Res>
    extends _$BaseStateCopyWithImpl<T, $Res, _$BaseStateDataImpl<T>>
    implements _$$BaseStateDataImplCopyWith<T, $Res> {
  __$$BaseStateDataImplCopyWithImpl(_$BaseStateDataImpl<T> _value,
      $Res Function(_$BaseStateDataImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$BaseStateDataImpl<T>(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$BaseStateDataImpl<T>
    with DiagnosticableTreeMixin
    implements BaseStateData<T> {
  const _$BaseStateDataImpl({required this.data});

  @override
  final T data;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BaseState<$T>.data(data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BaseState<$T>.data'))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseStateDataImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseStateDataImplCopyWith<T, _$BaseStateDataImpl<T>> get copyWith =>
      __$$BaseStateDataImplCopyWithImpl<T, _$BaseStateDataImpl<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) data,
    required TResult Function(String message, AppException? exception) error,
    required TResult Function(T? cachedData) offline,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? data,
    TResult? Function(String message, AppException? exception)? error,
    TResult? Function(T? cachedData)? offline,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? data,
    TResult Function(String message, AppException? exception)? error,
    TResult Function(T? cachedData)? offline,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BaseStateInitial<T> value) initial,
    required TResult Function(BaseStateLoading<T> value) loading,
    required TResult Function(BaseStateData<T> value) data,
    required TResult Function(BaseStateError<T> value) error,
    required TResult Function(BaseStateOffline<T> value) offline,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BaseStateInitial<T> value)? initial,
    TResult? Function(BaseStateLoading<T> value)? loading,
    TResult? Function(BaseStateData<T> value)? data,
    TResult? Function(BaseStateError<T> value)? error,
    TResult? Function(BaseStateOffline<T> value)? offline,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BaseStateInitial<T> value)? initial,
    TResult Function(BaseStateLoading<T> value)? loading,
    TResult Function(BaseStateData<T> value)? data,
    TResult Function(BaseStateError<T> value)? error,
    TResult Function(BaseStateOffline<T> value)? offline,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class BaseStateData<T> implements BaseState<T> {
  const factory BaseStateData({required final T data}) = _$BaseStateDataImpl<T>;

  T get data;

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseStateDataImplCopyWith<T, _$BaseStateDataImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BaseStateErrorImplCopyWith<T, $Res> {
  factory _$$BaseStateErrorImplCopyWith(_$BaseStateErrorImpl<T> value,
          $Res Function(_$BaseStateErrorImpl<T>) then) =
      __$$BaseStateErrorImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({String message, AppException? exception});
}

/// @nodoc
class __$$BaseStateErrorImplCopyWithImpl<T, $Res>
    extends _$BaseStateCopyWithImpl<T, $Res, _$BaseStateErrorImpl<T>>
    implements _$$BaseStateErrorImplCopyWith<T, $Res> {
  __$$BaseStateErrorImplCopyWithImpl(_$BaseStateErrorImpl<T> _value,
      $Res Function(_$BaseStateErrorImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? exception = freezed,
  }) {
    return _then(_$BaseStateErrorImpl<T>(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      exception: freezed == exception
          ? _value.exception
          : exception // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ));
  }
}

/// @nodoc

class _$BaseStateErrorImpl<T>
    with DiagnosticableTreeMixin
    implements BaseStateError<T> {
  const _$BaseStateErrorImpl({required this.message, this.exception});

  @override
  final String message;
  @override
  final AppException? exception;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BaseState<$T>.error(message: $message, exception: $exception)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BaseState<$T>.error'))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('exception', exception));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseStateErrorImpl<T> &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.exception, exception) ||
                other.exception == exception));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, exception);

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseStateErrorImplCopyWith<T, _$BaseStateErrorImpl<T>> get copyWith =>
      __$$BaseStateErrorImplCopyWithImpl<T, _$BaseStateErrorImpl<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) data,
    required TResult Function(String message, AppException? exception) error,
    required TResult Function(T? cachedData) offline,
  }) {
    return error(message, exception);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? data,
    TResult? Function(String message, AppException? exception)? error,
    TResult? Function(T? cachedData)? offline,
  }) {
    return error?.call(message, exception);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? data,
    TResult Function(String message, AppException? exception)? error,
    TResult Function(T? cachedData)? offline,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, exception);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BaseStateInitial<T> value) initial,
    required TResult Function(BaseStateLoading<T> value) loading,
    required TResult Function(BaseStateData<T> value) data,
    required TResult Function(BaseStateError<T> value) error,
    required TResult Function(BaseStateOffline<T> value) offline,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BaseStateInitial<T> value)? initial,
    TResult? Function(BaseStateLoading<T> value)? loading,
    TResult? Function(BaseStateData<T> value)? data,
    TResult? Function(BaseStateError<T> value)? error,
    TResult? Function(BaseStateOffline<T> value)? offline,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BaseStateInitial<T> value)? initial,
    TResult Function(BaseStateLoading<T> value)? loading,
    TResult Function(BaseStateData<T> value)? data,
    TResult Function(BaseStateError<T> value)? error,
    TResult Function(BaseStateOffline<T> value)? offline,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class BaseStateError<T> implements BaseState<T> {
  const factory BaseStateError(
      {required final String message,
      final AppException? exception}) = _$BaseStateErrorImpl<T>;

  String get message;
  AppException? get exception;

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseStateErrorImplCopyWith<T, _$BaseStateErrorImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BaseStateOfflineImplCopyWith<T, $Res> {
  factory _$$BaseStateOfflineImplCopyWith(_$BaseStateOfflineImpl<T> value,
          $Res Function(_$BaseStateOfflineImpl<T>) then) =
      __$$BaseStateOfflineImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T? cachedData});
}

/// @nodoc
class __$$BaseStateOfflineImplCopyWithImpl<T, $Res>
    extends _$BaseStateCopyWithImpl<T, $Res, _$BaseStateOfflineImpl<T>>
    implements _$$BaseStateOfflineImplCopyWith<T, $Res> {
  __$$BaseStateOfflineImplCopyWithImpl(_$BaseStateOfflineImpl<T> _value,
      $Res Function(_$BaseStateOfflineImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cachedData = freezed,
  }) {
    return _then(_$BaseStateOfflineImpl<T>(
      cachedData: freezed == cachedData
          ? _value.cachedData
          : cachedData // ignore: cast_nullable_to_non_nullable
              as T?,
    ));
  }
}

/// @nodoc

class _$BaseStateOfflineImpl<T>
    with DiagnosticableTreeMixin
    implements BaseStateOffline<T> {
  const _$BaseStateOfflineImpl({this.cachedData});

  @override
  final T? cachedData;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BaseState<$T>.offline(cachedData: $cachedData)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BaseState<$T>.offline'))
      ..add(DiagnosticsProperty('cachedData', cachedData));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseStateOfflineImpl<T> &&
            const DeepCollectionEquality()
                .equals(other.cachedData, cachedData));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(cachedData));

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseStateOfflineImplCopyWith<T, _$BaseStateOfflineImpl<T>> get copyWith =>
      __$$BaseStateOfflineImplCopyWithImpl<T, _$BaseStateOfflineImpl<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) data,
    required TResult Function(String message, AppException? exception) error,
    required TResult Function(T? cachedData) offline,
  }) {
    return offline(cachedData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? data,
    TResult? Function(String message, AppException? exception)? error,
    TResult? Function(T? cachedData)? offline,
  }) {
    return offline?.call(cachedData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? data,
    TResult Function(String message, AppException? exception)? error,
    TResult Function(T? cachedData)? offline,
    required TResult orElse(),
  }) {
    if (offline != null) {
      return offline(cachedData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BaseStateInitial<T> value) initial,
    required TResult Function(BaseStateLoading<T> value) loading,
    required TResult Function(BaseStateData<T> value) data,
    required TResult Function(BaseStateError<T> value) error,
    required TResult Function(BaseStateOffline<T> value) offline,
  }) {
    return offline(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BaseStateInitial<T> value)? initial,
    TResult? Function(BaseStateLoading<T> value)? loading,
    TResult? Function(BaseStateData<T> value)? data,
    TResult? Function(BaseStateError<T> value)? error,
    TResult? Function(BaseStateOffline<T> value)? offline,
  }) {
    return offline?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BaseStateInitial<T> value)? initial,
    TResult Function(BaseStateLoading<T> value)? loading,
    TResult Function(BaseStateData<T> value)? data,
    TResult Function(BaseStateError<T> value)? error,
    TResult Function(BaseStateOffline<T> value)? offline,
    required TResult orElse(),
  }) {
    if (offline != null) {
      return offline(this);
    }
    return orElse();
  }
}

abstract class BaseStateOffline<T> implements BaseState<T> {
  const factory BaseStateOffline({final T? cachedData}) =
      _$BaseStateOfflineImpl<T>;

  T? get cachedData;

  /// Create a copy of BaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseStateOfflineImplCopyWith<T, _$BaseStateOfflineImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
