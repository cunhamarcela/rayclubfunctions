// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdvancedSettingsStateImpl _$$AdvancedSettingsStateImplFromJson(
        Map<String, dynamic> json) =>
    _$AdvancedSettingsStateImpl(
      languageCode: json['languageCode'] as String? ?? 'pt_BR',
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      privacySettings: json['privacySettings'] == null
          ? const PrivacySettings()
          : PrivacySettings.fromJson(
              json['privacySettings'] as Map<String, dynamic>),
      notificationSettings: json['notificationSettings'] == null
          ? const NotificationSettings()
          : NotificationSettings.fromJson(
              json['notificationSettings'] as Map<String, dynamic>),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      isSyncing: json['isSyncing'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$AdvancedSettingsStateImplToJson(
        _$AdvancedSettingsStateImpl instance) =>
    <String, dynamic>{
      'languageCode': instance.languageCode,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'privacySettings': instance.privacySettings.toJson(),
      'notificationSettings': instance.notificationSettings.toJson(),
      if (instance.lastSyncedAt?.toIso8601String() case final value?)
        'lastSyncedAt': value,
      'isSyncing': instance.isSyncing,
      'isLoading': instance.isLoading,
      if (instance.errorMessage case final value?) 'errorMessage': value,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

_$PrivacySettingsImpl _$$PrivacySettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacySettingsImpl(
      shareActivityWithFriends:
          json['shareActivityWithFriends'] as bool? ?? true,
      allowFindingMe: json['allowFindingMe'] as bool? ?? true,
      publicProfile: json['publicProfile'] as bool? ?? true,
      showInRanking: json['showInRanking'] as bool? ?? true,
      shareAnalyticsData: json['shareAnalyticsData'] as bool? ?? true,
    );

Map<String, dynamic> _$$PrivacySettingsImplToJson(
        _$PrivacySettingsImpl instance) =>
    <String, dynamic>{
      'shareActivityWithFriends': instance.shareActivityWithFriends,
      'allowFindingMe': instance.allowFindingMe,
      'publicProfile': instance.publicProfile,
      'showInRanking': instance.showInRanking,
      'shareAnalyticsData': instance.shareAnalyticsData,
    };

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      workoutReminders: json['workoutReminders'] as bool? ?? true,
      dailyReminders: json['dailyReminders'] as bool? ?? true,
      challengeUpdates: json['challengeUpdates'] as bool? ?? true,
      nutritionReminders: json['nutritionReminders'] as bool? ?? true,
      promotionalNotifications:
          json['promotionalNotifications'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? '18:00',
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enableNotifications': instance.enableNotifications,
      'workoutReminders': instance.workoutReminders,
      'dailyReminders': instance.dailyReminders,
      'challengeUpdates': instance.challengeUpdates,
      'nutritionReminders': instance.nutritionReminders,
      'promotionalNotifications': instance.promotionalNotifications,
      'reminderTime': instance.reminderTime,
    };
