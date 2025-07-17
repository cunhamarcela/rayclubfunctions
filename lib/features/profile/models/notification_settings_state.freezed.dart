// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationSettingsState {
  /// Indica se o carregamento está em progresso
  bool get isLoading => throw _privateConstructorUsedError;

  /// Mensagem de erro, se houver
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Estado do interruptor mestre de notificações
  bool get masterSwitchEnabled => throw _privateConstructorUsedError;

  /// Configurações individuais para cada tipo de notificação
  Map<NotificationType, bool> get notificationSettings =>
      throw _privateConstructorUsedError;

  /// Horário para lembretes diários
  TimeOfDay get reminderTime => throw _privateConstructorUsedError;

  /// Indica se as alterações foram salvas com sucesso
  bool get changesSaved => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsStateCopyWith<NotificationSettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsStateCopyWith<$Res> {
  factory $NotificationSettingsStateCopyWith(NotificationSettingsState value,
          $Res Function(NotificationSettingsState) then) =
      _$NotificationSettingsStateCopyWithImpl<$Res, NotificationSettingsState>;
  @useResult
  $Res call(
      {bool isLoading,
      String? errorMessage,
      bool masterSwitchEnabled,
      Map<NotificationType, bool> notificationSettings,
      TimeOfDay reminderTime,
      bool changesSaved});
}

/// @nodoc
class _$NotificationSettingsStateCopyWithImpl<$Res,
        $Val extends NotificationSettingsState>
    implements $NotificationSettingsStateCopyWith<$Res> {
  _$NotificationSettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? masterSwitchEnabled = null,
    Object? notificationSettings = null,
    Object? reminderTime = null,
    Object? changesSaved = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      masterSwitchEnabled: null == masterSwitchEnabled
          ? _value.masterSwitchEnabled
          : masterSwitchEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationSettings: null == notificationSettings
          ? _value.notificationSettings
          : notificationSettings // ignore: cast_nullable_to_non_nullable
              as Map<NotificationType, bool>,
      reminderTime: null == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      changesSaved: null == changesSaved
          ? _value.changesSaved
          : changesSaved // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsStateImplCopyWith<$Res>
    implements $NotificationSettingsStateCopyWith<$Res> {
  factory _$$NotificationSettingsStateImplCopyWith(
          _$NotificationSettingsStateImpl value,
          $Res Function(_$NotificationSettingsStateImpl) then) =
      __$$NotificationSettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? errorMessage,
      bool masterSwitchEnabled,
      Map<NotificationType, bool> notificationSettings,
      TimeOfDay reminderTime,
      bool changesSaved});
}

/// @nodoc
class __$$NotificationSettingsStateImplCopyWithImpl<$Res>
    extends _$NotificationSettingsStateCopyWithImpl<$Res,
        _$NotificationSettingsStateImpl>
    implements _$$NotificationSettingsStateImplCopyWith<$Res> {
  __$$NotificationSettingsStateImplCopyWithImpl(
      _$NotificationSettingsStateImpl _value,
      $Res Function(_$NotificationSettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? masterSwitchEnabled = null,
    Object? notificationSettings = null,
    Object? reminderTime = null,
    Object? changesSaved = null,
  }) {
    return _then(_$NotificationSettingsStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      masterSwitchEnabled: null == masterSwitchEnabled
          ? _value.masterSwitchEnabled
          : masterSwitchEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationSettings: null == notificationSettings
          ? _value._notificationSettings
          : notificationSettings // ignore: cast_nullable_to_non_nullable
              as Map<NotificationType, bool>,
      reminderTime: null == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      changesSaved: null == changesSaved
          ? _value.changesSaved
          : changesSaved // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NotificationSettingsStateImpl implements _NotificationSettingsState {
  const _$NotificationSettingsStateImpl(
      {this.isLoading = false,
      this.errorMessage,
      this.masterSwitchEnabled = true,
      final Map<NotificationType, bool> notificationSettings = const {},
      this.reminderTime = const TimeOfDay(hour: 18, minute: 0),
      this.changesSaved = false})
      : _notificationSettings = notificationSettings;

  /// Indica se o carregamento está em progresso
  @override
  @JsonKey()
  final bool isLoading;

  /// Mensagem de erro, se houver
  @override
  final String? errorMessage;

  /// Estado do interruptor mestre de notificações
  @override
  @JsonKey()
  final bool masterSwitchEnabled;

  /// Configurações individuais para cada tipo de notificação
  final Map<NotificationType, bool> _notificationSettings;

  /// Configurações individuais para cada tipo de notificação
  @override
  @JsonKey()
  Map<NotificationType, bool> get notificationSettings {
    if (_notificationSettings is EqualUnmodifiableMapView)
      return _notificationSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_notificationSettings);
  }

  /// Horário para lembretes diários
  @override
  @JsonKey()
  final TimeOfDay reminderTime;

  /// Indica se as alterações foram salvas com sucesso
  @override
  @JsonKey()
  final bool changesSaved;

  @override
  String toString() {
    return 'NotificationSettingsState(isLoading: $isLoading, errorMessage: $errorMessage, masterSwitchEnabled: $masterSwitchEnabled, notificationSettings: $notificationSettings, reminderTime: $reminderTime, changesSaved: $changesSaved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.masterSwitchEnabled, masterSwitchEnabled) ||
                other.masterSwitchEnabled == masterSwitchEnabled) &&
            const DeepCollectionEquality()
                .equals(other._notificationSettings, _notificationSettings) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.changesSaved, changesSaved) ||
                other.changesSaved == changesSaved));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      errorMessage,
      masterSwitchEnabled,
      const DeepCollectionEquality().hash(_notificationSettings),
      reminderTime,
      changesSaved);

  /// Create a copy of NotificationSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsStateImplCopyWith<_$NotificationSettingsStateImpl>
      get copyWith => __$$NotificationSettingsStateImplCopyWithImpl<
          _$NotificationSettingsStateImpl>(this, _$identity);
}

abstract class _NotificationSettingsState implements NotificationSettingsState {
  const factory _NotificationSettingsState(
      {final bool isLoading,
      final String? errorMessage,
      final bool masterSwitchEnabled,
      final Map<NotificationType, bool> notificationSettings,
      final TimeOfDay reminderTime,
      final bool changesSaved}) = _$NotificationSettingsStateImpl;

  /// Indica se o carregamento está em progresso
  @override
  bool get isLoading;

  /// Mensagem de erro, se houver
  @override
  String? get errorMessage;

  /// Estado do interruptor mestre de notificações
  @override
  bool get masterSwitchEnabled;

  /// Configurações individuais para cada tipo de notificação
  @override
  Map<NotificationType, bool> get notificationSettings;

  /// Horário para lembretes diários
  @override
  TimeOfDay get reminderTime;

  /// Indica se as alterações foram salvas com sucesso
  @override
  bool get changesSaved;

  /// Create a copy of NotificationSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsStateImplCopyWith<_$NotificationSettingsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
