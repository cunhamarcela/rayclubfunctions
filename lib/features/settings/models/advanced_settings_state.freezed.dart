// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'advanced_settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdvancedSettingsState _$AdvancedSettingsStateFromJson(
    Map<String, dynamic> json) {
  return _AdvancedSettingsState.fromJson(json);
}

/// @nodoc
mixin _$AdvancedSettingsState {
  /// Idioma selecionado (código do locale)
  String get languageCode => throw _privateConstructorUsedError;

  /// Modo de tema
  ThemeMode get themeMode => throw _privateConstructorUsedError;

  /// Configurações de privacidade
  PrivacySettings get privacySettings => throw _privateConstructorUsedError;

  /// Configurações de notificação
  NotificationSettings get notificationSettings =>
      throw _privateConstructorUsedError;

  /// Data da última sincronização
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Indica se as configurações estão sendo sincronizadas
  bool get isSyncing => throw _privateConstructorUsedError;

  /// Indica se está carregando dados
  bool get isLoading => throw _privateConstructorUsedError;

  /// Mensagem de erro, se houver
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this AdvancedSettingsState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdvancedSettingsStateCopyWith<AdvancedSettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdvancedSettingsStateCopyWith<$Res> {
  factory $AdvancedSettingsStateCopyWith(AdvancedSettingsState value,
          $Res Function(AdvancedSettingsState) then) =
      _$AdvancedSettingsStateCopyWithImpl<$Res, AdvancedSettingsState>;
  @useResult
  $Res call(
      {String languageCode,
      ThemeMode themeMode,
      PrivacySettings privacySettings,
      NotificationSettings notificationSettings,
      DateTime? lastSyncedAt,
      bool isSyncing,
      bool isLoading,
      String? errorMessage});

  $PrivacySettingsCopyWith<$Res> get privacySettings;
  $NotificationSettingsCopyWith<$Res> get notificationSettings;
}

/// @nodoc
class _$AdvancedSettingsStateCopyWithImpl<$Res,
        $Val extends AdvancedSettingsState>
    implements $AdvancedSettingsStateCopyWith<$Res> {
  _$AdvancedSettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? languageCode = null,
    Object? themeMode = null,
    Object? privacySettings = null,
    Object? notificationSettings = null,
    Object? lastSyncedAt = freezed,
    Object? isSyncing = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      privacySettings: null == privacySettings
          ? _value.privacySettings
          : privacySettings // ignore: cast_nullable_to_non_nullable
              as PrivacySettings,
      notificationSettings: null == notificationSettings
          ? _value.notificationSettings
          : notificationSettings // ignore: cast_nullable_to_non_nullable
              as NotificationSettings,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
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

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PrivacySettingsCopyWith<$Res> get privacySettings {
    return $PrivacySettingsCopyWith<$Res>(_value.privacySettings, (value) {
      return _then(_value.copyWith(privacySettings: value) as $Val);
    });
  }

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationSettingsCopyWith<$Res> get notificationSettings {
    return $NotificationSettingsCopyWith<$Res>(_value.notificationSettings,
        (value) {
      return _then(_value.copyWith(notificationSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AdvancedSettingsStateImplCopyWith<$Res>
    implements $AdvancedSettingsStateCopyWith<$Res> {
  factory _$$AdvancedSettingsStateImplCopyWith(
          _$AdvancedSettingsStateImpl value,
          $Res Function(_$AdvancedSettingsStateImpl) then) =
      __$$AdvancedSettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String languageCode,
      ThemeMode themeMode,
      PrivacySettings privacySettings,
      NotificationSettings notificationSettings,
      DateTime? lastSyncedAt,
      bool isSyncing,
      bool isLoading,
      String? errorMessage});

  @override
  $PrivacySettingsCopyWith<$Res> get privacySettings;
  @override
  $NotificationSettingsCopyWith<$Res> get notificationSettings;
}

/// @nodoc
class __$$AdvancedSettingsStateImplCopyWithImpl<$Res>
    extends _$AdvancedSettingsStateCopyWithImpl<$Res,
        _$AdvancedSettingsStateImpl>
    implements _$$AdvancedSettingsStateImplCopyWith<$Res> {
  __$$AdvancedSettingsStateImplCopyWithImpl(_$AdvancedSettingsStateImpl _value,
      $Res Function(_$AdvancedSettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? languageCode = null,
    Object? themeMode = null,
    Object? privacySettings = null,
    Object? notificationSettings = null,
    Object? lastSyncedAt = freezed,
    Object? isSyncing = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$AdvancedSettingsStateImpl(
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      privacySettings: null == privacySettings
          ? _value.privacySettings
          : privacySettings // ignore: cast_nullable_to_non_nullable
              as PrivacySettings,
      notificationSettings: null == notificationSettings
          ? _value.notificationSettings
          : notificationSettings // ignore: cast_nullable_to_non_nullable
              as NotificationSettings,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$AdvancedSettingsStateImpl implements _AdvancedSettingsState {
  const _$AdvancedSettingsStateImpl(
      {this.languageCode = 'pt_BR',
      this.themeMode = ThemeMode.system,
      this.privacySettings = const PrivacySettings(),
      this.notificationSettings = const NotificationSettings(),
      this.lastSyncedAt,
      this.isSyncing = false,
      this.isLoading = false,
      this.errorMessage});

  factory _$AdvancedSettingsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdvancedSettingsStateImplFromJson(json);

  /// Idioma selecionado (código do locale)
  @override
  @JsonKey()
  final String languageCode;

  /// Modo de tema
  @override
  @JsonKey()
  final ThemeMode themeMode;

  /// Configurações de privacidade
  @override
  @JsonKey()
  final PrivacySettings privacySettings;

  /// Configurações de notificação
  @override
  @JsonKey()
  final NotificationSettings notificationSettings;

  /// Data da última sincronização
  @override
  final DateTime? lastSyncedAt;

  /// Indica se as configurações estão sendo sincronizadas
  @override
  @JsonKey()
  final bool isSyncing;

  /// Indica se está carregando dados
  @override
  @JsonKey()
  final bool isLoading;

  /// Mensagem de erro, se houver
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AdvancedSettingsState(languageCode: $languageCode, themeMode: $themeMode, privacySettings: $privacySettings, notificationSettings: $notificationSettings, lastSyncedAt: $lastSyncedAt, isSyncing: $isSyncing, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdvancedSettingsStateImpl &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.privacySettings, privacySettings) ||
                other.privacySettings == privacySettings) &&
            (identical(other.notificationSettings, notificationSettings) ||
                other.notificationSettings == notificationSettings) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      languageCode,
      themeMode,
      privacySettings,
      notificationSettings,
      lastSyncedAt,
      isSyncing,
      isLoading,
      errorMessage);

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdvancedSettingsStateImplCopyWith<_$AdvancedSettingsStateImpl>
      get copyWith => __$$AdvancedSettingsStateImplCopyWithImpl<
          _$AdvancedSettingsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdvancedSettingsStateImplToJson(
      this,
    );
  }
}

abstract class _AdvancedSettingsState implements AdvancedSettingsState {
  const factory _AdvancedSettingsState(
      {final String languageCode,
      final ThemeMode themeMode,
      final PrivacySettings privacySettings,
      final NotificationSettings notificationSettings,
      final DateTime? lastSyncedAt,
      final bool isSyncing,
      final bool isLoading,
      final String? errorMessage}) = _$AdvancedSettingsStateImpl;

  factory _AdvancedSettingsState.fromJson(Map<String, dynamic> json) =
      _$AdvancedSettingsStateImpl.fromJson;

  /// Idioma selecionado (código do locale)
  @override
  String get languageCode;

  /// Modo de tema
  @override
  ThemeMode get themeMode;

  /// Configurações de privacidade
  @override
  PrivacySettings get privacySettings;

  /// Configurações de notificação
  @override
  NotificationSettings get notificationSettings;

  /// Data da última sincronização
  @override
  DateTime? get lastSyncedAt;

  /// Indica se as configurações estão sendo sincronizadas
  @override
  bool get isSyncing;

  /// Indica se está carregando dados
  @override
  bool get isLoading;

  /// Mensagem de erro, se houver
  @override
  String? get errorMessage;

  /// Create a copy of AdvancedSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdvancedSettingsStateImplCopyWith<_$AdvancedSettingsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) {
  return _PrivacySettings.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettings {
  /// Compartilhar dados de atividade com amigos
  bool get shareActivityWithFriends => throw _privateConstructorUsedError;

  /// Permitir que outros usuários me encontrem
  bool get allowFindingMe => throw _privateConstructorUsedError;

  /// Tornar meu perfil visível para todos
  bool get publicProfile => throw _privateConstructorUsedError;

  /// Mostrar minha posição no ranking público
  bool get showInRanking => throw _privateConstructorUsedError;

  /// Compartilhar dados para análise de uso
  bool get shareAnalyticsData => throw _privateConstructorUsedError;

  /// Serializes this PrivacySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrivacySettingsCopyWith<PrivacySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsCopyWith<$Res> {
  factory $PrivacySettingsCopyWith(
          PrivacySettings value, $Res Function(PrivacySettings) then) =
      _$PrivacySettingsCopyWithImpl<$Res, PrivacySettings>;
  @useResult
  $Res call(
      {bool shareActivityWithFriends,
      bool allowFindingMe,
      bool publicProfile,
      bool showInRanking,
      bool shareAnalyticsData});
}

/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res, $Val extends PrivacySettings>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shareActivityWithFriends = null,
    Object? allowFindingMe = null,
    Object? publicProfile = null,
    Object? showInRanking = null,
    Object? shareAnalyticsData = null,
  }) {
    return _then(_value.copyWith(
      shareActivityWithFriends: null == shareActivityWithFriends
          ? _value.shareActivityWithFriends
          : shareActivityWithFriends // ignore: cast_nullable_to_non_nullable
              as bool,
      allowFindingMe: null == allowFindingMe
          ? _value.allowFindingMe
          : allowFindingMe // ignore: cast_nullable_to_non_nullable
              as bool,
      publicProfile: null == publicProfile
          ? _value.publicProfile
          : publicProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      showInRanking: null == showInRanking
          ? _value.showInRanking
          : showInRanking // ignore: cast_nullable_to_non_nullable
              as bool,
      shareAnalyticsData: null == shareAnalyticsData
          ? _value.shareAnalyticsData
          : shareAnalyticsData // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacySettingsImplCopyWith<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  factory _$$PrivacySettingsImplCopyWith(_$PrivacySettingsImpl value,
          $Res Function(_$PrivacySettingsImpl) then) =
      __$$PrivacySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool shareActivityWithFriends,
      bool allowFindingMe,
      bool publicProfile,
      bool showInRanking,
      bool shareAnalyticsData});
}

/// @nodoc
class __$$PrivacySettingsImplCopyWithImpl<$Res>
    extends _$PrivacySettingsCopyWithImpl<$Res, _$PrivacySettingsImpl>
    implements _$$PrivacySettingsImplCopyWith<$Res> {
  __$$PrivacySettingsImplCopyWithImpl(
      _$PrivacySettingsImpl _value, $Res Function(_$PrivacySettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shareActivityWithFriends = null,
    Object? allowFindingMe = null,
    Object? publicProfile = null,
    Object? showInRanking = null,
    Object? shareAnalyticsData = null,
  }) {
    return _then(_$PrivacySettingsImpl(
      shareActivityWithFriends: null == shareActivityWithFriends
          ? _value.shareActivityWithFriends
          : shareActivityWithFriends // ignore: cast_nullable_to_non_nullable
              as bool,
      allowFindingMe: null == allowFindingMe
          ? _value.allowFindingMe
          : allowFindingMe // ignore: cast_nullable_to_non_nullable
              as bool,
      publicProfile: null == publicProfile
          ? _value.publicProfile
          : publicProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      showInRanking: null == showInRanking
          ? _value.showInRanking
          : showInRanking // ignore: cast_nullable_to_non_nullable
              as bool,
      shareAnalyticsData: null == shareAnalyticsData
          ? _value.shareAnalyticsData
          : shareAnalyticsData // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsImpl implements _PrivacySettings {
  const _$PrivacySettingsImpl(
      {this.shareActivityWithFriends = true,
      this.allowFindingMe = true,
      this.publicProfile = true,
      this.showInRanking = true,
      this.shareAnalyticsData = true});

  factory _$PrivacySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsImplFromJson(json);

  /// Compartilhar dados de atividade com amigos
  @override
  @JsonKey()
  final bool shareActivityWithFriends;

  /// Permitir que outros usuários me encontrem
  @override
  @JsonKey()
  final bool allowFindingMe;

  /// Tornar meu perfil visível para todos
  @override
  @JsonKey()
  final bool publicProfile;

  /// Mostrar minha posição no ranking público
  @override
  @JsonKey()
  final bool showInRanking;

  /// Compartilhar dados para análise de uso
  @override
  @JsonKey()
  final bool shareAnalyticsData;

  @override
  String toString() {
    return 'PrivacySettings(shareActivityWithFriends: $shareActivityWithFriends, allowFindingMe: $allowFindingMe, publicProfile: $publicProfile, showInRanking: $showInRanking, shareAnalyticsData: $shareAnalyticsData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsImpl &&
            (identical(
                    other.shareActivityWithFriends, shareActivityWithFriends) ||
                other.shareActivityWithFriends == shareActivityWithFriends) &&
            (identical(other.allowFindingMe, allowFindingMe) ||
                other.allowFindingMe == allowFindingMe) &&
            (identical(other.publicProfile, publicProfile) ||
                other.publicProfile == publicProfile) &&
            (identical(other.showInRanking, showInRanking) ||
                other.showInRanking == showInRanking) &&
            (identical(other.shareAnalyticsData, shareAnalyticsData) ||
                other.shareAnalyticsData == shareAnalyticsData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, shareActivityWithFriends,
      allowFindingMe, publicProfile, showInRanking, shareAnalyticsData);

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      __$$PrivacySettingsImplCopyWithImpl<_$PrivacySettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsImplToJson(
      this,
    );
  }
}

abstract class _PrivacySettings implements PrivacySettings {
  const factory _PrivacySettings(
      {final bool shareActivityWithFriends,
      final bool allowFindingMe,
      final bool publicProfile,
      final bool showInRanking,
      final bool shareAnalyticsData}) = _$PrivacySettingsImpl;

  factory _PrivacySettings.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsImpl.fromJson;

  /// Compartilhar dados de atividade com amigos
  @override
  bool get shareActivityWithFriends;

  /// Permitir que outros usuários me encontrem
  @override
  bool get allowFindingMe;

  /// Tornar meu perfil visível para todos
  @override
  bool get publicProfile;

  /// Mostrar minha posição no ranking público
  @override
  bool get showInRanking;

  /// Compartilhar dados para análise de uso
  @override
  bool get shareAnalyticsData;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  /// Habilitar notificações
  bool get enableNotifications => throw _privateConstructorUsedError;

  /// Notificações de treino
  bool get workoutReminders => throw _privateConstructorUsedError;

  /// Lembretes diários
  bool get dailyReminders => throw _privateConstructorUsedError;

  /// Notificações de desafios
  bool get challengeUpdates => throw _privateConstructorUsedError;

  /// Lembretes de nutrição
  bool get nutritionReminders => throw _privateConstructorUsedError;

  /// Novidades e promoções
  bool get promotionalNotifications => throw _privateConstructorUsedError;

  /// Horário para lembretes diários
  String get reminderTime => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool enableNotifications,
      bool workoutReminders,
      bool dailyReminders,
      bool challengeUpdates,
      bool nutritionReminders,
      bool promotionalNotifications,
      String reminderTime});
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableNotifications = null,
    Object? workoutReminders = null,
    Object? dailyReminders = null,
    Object? challengeUpdates = null,
    Object? nutritionReminders = null,
    Object? promotionalNotifications = null,
    Object? reminderTime = null,
  }) {
    return _then(_value.copyWith(
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutReminders: null == workoutReminders
          ? _value.workoutReminders
          : workoutReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyReminders: null == dailyReminders
          ? _value.dailyReminders
          : dailyReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      challengeUpdates: null == challengeUpdates
          ? _value.challengeUpdates
          : challengeUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      nutritionReminders: null == nutritionReminders
          ? _value.nutritionReminders
          : nutritionReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      promotionalNotifications: null == promotionalNotifications
          ? _value.promotionalNotifications
          : promotionalNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderTime: null == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enableNotifications,
      bool workoutReminders,
      bool dailyReminders,
      bool challengeUpdates,
      bool nutritionReminders,
      bool promotionalNotifications,
      String reminderTime});
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableNotifications = null,
    Object? workoutReminders = null,
    Object? dailyReminders = null,
    Object? challengeUpdates = null,
    Object? nutritionReminders = null,
    Object? promotionalNotifications = null,
    Object? reminderTime = null,
  }) {
    return _then(_$NotificationSettingsImpl(
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutReminders: null == workoutReminders
          ? _value.workoutReminders
          : workoutReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyReminders: null == dailyReminders
          ? _value.dailyReminders
          : dailyReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      challengeUpdates: null == challengeUpdates
          ? _value.challengeUpdates
          : challengeUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      nutritionReminders: null == nutritionReminders
          ? _value.nutritionReminders
          : nutritionReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      promotionalNotifications: null == promotionalNotifications
          ? _value.promotionalNotifications
          : promotionalNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderTime: null == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.enableNotifications = true,
      this.workoutReminders = true,
      this.dailyReminders = true,
      this.challengeUpdates = true,
      this.nutritionReminders = true,
      this.promotionalNotifications = true,
      this.reminderTime = '18:00'});

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  /// Habilitar notificações
  @override
  @JsonKey()
  final bool enableNotifications;

  /// Notificações de treino
  @override
  @JsonKey()
  final bool workoutReminders;

  /// Lembretes diários
  @override
  @JsonKey()
  final bool dailyReminders;

  /// Notificações de desafios
  @override
  @JsonKey()
  final bool challengeUpdates;

  /// Lembretes de nutrição
  @override
  @JsonKey()
  final bool nutritionReminders;

  /// Novidades e promoções
  @override
  @JsonKey()
  final bool promotionalNotifications;

  /// Horário para lembretes diários
  @override
  @JsonKey()
  final String reminderTime;

  @override
  String toString() {
    return 'NotificationSettings(enableNotifications: $enableNotifications, workoutReminders: $workoutReminders, dailyReminders: $dailyReminders, challengeUpdates: $challengeUpdates, nutritionReminders: $nutritionReminders, promotionalNotifications: $promotionalNotifications, reminderTime: $reminderTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.workoutReminders, workoutReminders) ||
                other.workoutReminders == workoutReminders) &&
            (identical(other.dailyReminders, dailyReminders) ||
                other.dailyReminders == dailyReminders) &&
            (identical(other.challengeUpdates, challengeUpdates) ||
                other.challengeUpdates == challengeUpdates) &&
            (identical(other.nutritionReminders, nutritionReminders) ||
                other.nutritionReminders == nutritionReminders) &&
            (identical(
                    other.promotionalNotifications, promotionalNotifications) ||
                other.promotionalNotifications == promotionalNotifications) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enableNotifications,
      workoutReminders,
      dailyReminders,
      challengeUpdates,
      nutritionReminders,
      promotionalNotifications,
      reminderTime);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings(
      {final bool enableNotifications,
      final bool workoutReminders,
      final bool dailyReminders,
      final bool challengeUpdates,
      final bool nutritionReminders,
      final bool promotionalNotifications,
      final String reminderTime}) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  /// Habilitar notificações
  @override
  bool get enableNotifications;

  /// Notificações de treino
  @override
  bool get workoutReminders;

  /// Lembretes diários
  @override
  bool get dailyReminders;

  /// Notificações de desafios
  @override
  bool get challengeUpdates;

  /// Lembretes de nutrição
  @override
  bool get nutritionReminders;

  /// Novidades e promoções
  @override
  bool get promotionalNotifications;

  /// Horário para lembretes diários
  @override
  String get reminderTime;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
