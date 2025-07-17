// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Notification> notifications, int unreadCount)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Notification> notifications, int unreadCount)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Notification> notifications, int unreadCount)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NotificationStateInitial value) initial,
    required TResult Function(_NotificationStateLoading value) loading,
    required TResult Function(_NotificationStateLoaded value) loaded,
    required TResult Function(_NotificationStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NotificationStateInitial value)? initial,
    TResult? Function(_NotificationStateLoading value)? loading,
    TResult? Function(_NotificationStateLoaded value)? loaded,
    TResult? Function(_NotificationStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NotificationStateInitial value)? initial,
    TResult Function(_NotificationStateLoading value)? loading,
    TResult Function(_NotificationStateLoaded value)? loaded,
    TResult Function(_NotificationStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationStateCopyWith<$Res> {
  factory $NotificationStateCopyWith(
          NotificationState value, $Res Function(NotificationState) then) =
      _$NotificationStateCopyWithImpl<$Res, NotificationState>;
}

/// @nodoc
class _$NotificationStateCopyWithImpl<$Res, $Val extends NotificationState>
    implements $NotificationStateCopyWith<$Res> {
  _$NotificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NotificationStateInitialImplCopyWith<$Res> {
  factory _$$NotificationStateInitialImplCopyWith(
          _$NotificationStateInitialImpl value,
          $Res Function(_$NotificationStateInitialImpl) then) =
      __$$NotificationStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NotificationStateInitialImplCopyWithImpl<$Res>
    extends _$NotificationStateCopyWithImpl<$Res,
        _$NotificationStateInitialImpl>
    implements _$$NotificationStateInitialImplCopyWith<$Res> {
  __$$NotificationStateInitialImplCopyWithImpl(
      _$NotificationStateInitialImpl _value,
      $Res Function(_$NotificationStateInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NotificationStateInitialImpl implements _NotificationStateInitial {
  const _$NotificationStateInitialImpl();

  @override
  String toString() {
    return 'NotificationState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Notification> notifications, int unreadCount)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Notification> notifications, int unreadCount)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Notification> notifications, int unreadCount)? loaded,
    TResult Function(String message)? error,
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
    required TResult Function(_NotificationStateInitial value) initial,
    required TResult Function(_NotificationStateLoading value) loading,
    required TResult Function(_NotificationStateLoaded value) loaded,
    required TResult Function(_NotificationStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NotificationStateInitial value)? initial,
    TResult? Function(_NotificationStateLoading value)? loading,
    TResult? Function(_NotificationStateLoaded value)? loaded,
    TResult? Function(_NotificationStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NotificationStateInitial value)? initial,
    TResult Function(_NotificationStateLoading value)? loading,
    TResult Function(_NotificationStateLoaded value)? loaded,
    TResult Function(_NotificationStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _NotificationStateInitial implements NotificationState {
  const factory _NotificationStateInitial() = _$NotificationStateInitialImpl;
}

/// @nodoc
abstract class _$$NotificationStateLoadingImplCopyWith<$Res> {
  factory _$$NotificationStateLoadingImplCopyWith(
          _$NotificationStateLoadingImpl value,
          $Res Function(_$NotificationStateLoadingImpl) then) =
      __$$NotificationStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NotificationStateLoadingImplCopyWithImpl<$Res>
    extends _$NotificationStateCopyWithImpl<$Res,
        _$NotificationStateLoadingImpl>
    implements _$$NotificationStateLoadingImplCopyWith<$Res> {
  __$$NotificationStateLoadingImplCopyWithImpl(
      _$NotificationStateLoadingImpl _value,
      $Res Function(_$NotificationStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NotificationStateLoadingImpl implements _NotificationStateLoading {
  const _$NotificationStateLoadingImpl();

  @override
  String toString() {
    return 'NotificationState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Notification> notifications, int unreadCount)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Notification> notifications, int unreadCount)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Notification> notifications, int unreadCount)? loaded,
    TResult Function(String message)? error,
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
    required TResult Function(_NotificationStateInitial value) initial,
    required TResult Function(_NotificationStateLoading value) loading,
    required TResult Function(_NotificationStateLoaded value) loaded,
    required TResult Function(_NotificationStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NotificationStateInitial value)? initial,
    TResult? Function(_NotificationStateLoading value)? loading,
    TResult? Function(_NotificationStateLoaded value)? loaded,
    TResult? Function(_NotificationStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NotificationStateInitial value)? initial,
    TResult Function(_NotificationStateLoading value)? loading,
    TResult Function(_NotificationStateLoaded value)? loaded,
    TResult Function(_NotificationStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _NotificationStateLoading implements NotificationState {
  const factory _NotificationStateLoading() = _$NotificationStateLoadingImpl;
}

/// @nodoc
abstract class _$$NotificationStateLoadedImplCopyWith<$Res> {
  factory _$$NotificationStateLoadedImplCopyWith(
          _$NotificationStateLoadedImpl value,
          $Res Function(_$NotificationStateLoadedImpl) then) =
      __$$NotificationStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Notification> notifications, int unreadCount});
}

/// @nodoc
class __$$NotificationStateLoadedImplCopyWithImpl<$Res>
    extends _$NotificationStateCopyWithImpl<$Res, _$NotificationStateLoadedImpl>
    implements _$$NotificationStateLoadedImplCopyWith<$Res> {
  __$$NotificationStateLoadedImplCopyWithImpl(
      _$NotificationStateLoadedImpl _value,
      $Res Function(_$NotificationStateLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? unreadCount = null,
  }) {
    return _then(_$NotificationStateLoadedImpl(
      notifications: null == notifications
          ? _value._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<Notification>,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$NotificationStateLoadedImpl implements _NotificationStateLoaded {
  const _$NotificationStateLoadedImpl(
      {required final List<Notification> notifications,
      required this.unreadCount})
      : _notifications = notifications;

  final List<Notification> _notifications;
  @override
  List<Notification> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  final int unreadCount;

  @override
  String toString() {
    return 'NotificationState.loaded(notifications: $notifications, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStateLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_notifications), unreadCount);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationStateLoadedImplCopyWith<_$NotificationStateLoadedImpl>
      get copyWith => __$$NotificationStateLoadedImplCopyWithImpl<
          _$NotificationStateLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Notification> notifications, int unreadCount)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(notifications, unreadCount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Notification> notifications, int unreadCount)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(notifications, unreadCount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Notification> notifications, int unreadCount)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(notifications, unreadCount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NotificationStateInitial value) initial,
    required TResult Function(_NotificationStateLoading value) loading,
    required TResult Function(_NotificationStateLoaded value) loaded,
    required TResult Function(_NotificationStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NotificationStateInitial value)? initial,
    TResult? Function(_NotificationStateLoading value)? loading,
    TResult? Function(_NotificationStateLoaded value)? loaded,
    TResult? Function(_NotificationStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NotificationStateInitial value)? initial,
    TResult Function(_NotificationStateLoading value)? loading,
    TResult Function(_NotificationStateLoaded value)? loaded,
    TResult Function(_NotificationStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _NotificationStateLoaded implements NotificationState {
  const factory _NotificationStateLoaded(
      {required final List<Notification> notifications,
      required final int unreadCount}) = _$NotificationStateLoadedImpl;

  List<Notification> get notifications;
  int get unreadCount;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationStateLoadedImplCopyWith<_$NotificationStateLoadedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotificationStateErrorImplCopyWith<$Res> {
  factory _$$NotificationStateErrorImplCopyWith(
          _$NotificationStateErrorImpl value,
          $Res Function(_$NotificationStateErrorImpl) then) =
      __$$NotificationStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NotificationStateErrorImplCopyWithImpl<$Res>
    extends _$NotificationStateCopyWithImpl<$Res, _$NotificationStateErrorImpl>
    implements _$$NotificationStateErrorImplCopyWith<$Res> {
  __$$NotificationStateErrorImplCopyWithImpl(
      _$NotificationStateErrorImpl _value,
      $Res Function(_$NotificationStateErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$NotificationStateErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NotificationStateErrorImpl implements _NotificationStateError {
  const _$NotificationStateErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationStateErrorImplCopyWith<_$NotificationStateErrorImpl>
      get copyWith => __$$NotificationStateErrorImplCopyWithImpl<
          _$NotificationStateErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Notification> notifications, int unreadCount)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Notification> notifications, int unreadCount)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Notification> notifications, int unreadCount)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NotificationStateInitial value) initial,
    required TResult Function(_NotificationStateLoading value) loading,
    required TResult Function(_NotificationStateLoaded value) loaded,
    required TResult Function(_NotificationStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NotificationStateInitial value)? initial,
    TResult? Function(_NotificationStateLoading value)? loading,
    TResult? Function(_NotificationStateLoaded value)? loaded,
    TResult? Function(_NotificationStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NotificationStateInitial value)? initial,
    TResult Function(_NotificationStateLoading value)? loading,
    TResult Function(_NotificationStateLoaded value)? loaded,
    TResult Function(_NotificationStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _NotificationStateError implements NotificationState {
  const factory _NotificationStateError(final String message) =
      _$NotificationStateErrorImpl;

  String get message;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationStateErrorImplCopyWith<_$NotificationStateErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
