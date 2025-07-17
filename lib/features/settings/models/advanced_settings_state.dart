// Package imports:
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'advanced_settings_state.freezed.dart';
part 'advanced_settings_state.g.dart';

/// Estado para o gerenciamento de configurações avançadas do aplicativo.
@freezed
class AdvancedSettingsState with _$AdvancedSettingsState {
  const factory AdvancedSettingsState({
    /// Idioma selecionado (código do locale)
    @Default('pt_BR') String languageCode,
    
    /// Modo de tema
    @Default(ThemeMode.system) ThemeMode themeMode,
    
    /// Configurações de privacidade
    @Default(PrivacySettings()) PrivacySettings privacySettings,
    
    /// Configurações de notificação
    @Default(NotificationSettings()) NotificationSettings notificationSettings,
    
    /// Data da última sincronização
    DateTime? lastSyncedAt,
    
    /// Indica se as configurações estão sendo sincronizadas
    @Default(false) bool isSyncing,
    
    /// Indica se está carregando dados
    @Default(false) bool isLoading,
    
    /// Mensagem de erro, se houver
    String? errorMessage,
  }) = _AdvancedSettingsState;
  
  factory AdvancedSettingsState.fromJson(Map<String, dynamic> json) => 
      _$AdvancedSettingsStateFromJson(json);
}

/// Configurações de privacidade
@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    /// Compartilhar dados de atividade com amigos
    @Default(true) bool shareActivityWithFriends,
    
    /// Permitir que outros usuários me encontrem
    @Default(true) bool allowFindingMe,
    
    /// Tornar meu perfil visível para todos
    @Default(true) bool publicProfile,
    
    /// Mostrar minha posição no ranking público
    @Default(true) bool showInRanking,
    
    /// Compartilhar dados para análise de uso
    @Default(true) bool shareAnalyticsData,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => 
      _$PrivacySettingsFromJson(json);
}

/// Configurações de notificação
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    /// Habilitar notificações
    @Default(true) bool enableNotifications,
    
    /// Notificações de treino
    @Default(true) bool workoutReminders,
    
    /// Lembretes diários
    @Default(true) bool dailyReminders,
    
    /// Notificações de desafios
    @Default(true) bool challengeUpdates,
    
    /// Lembretes de nutrição
    @Default(true) bool nutritionReminders,
    
    /// Novidades e promoções
    @Default(true) bool promotionalNotifications,
    
    /// Horário para lembretes diários
    @Default('18:00') String reminderTime,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => 
      _$NotificationSettingsFromJson(json);
} 