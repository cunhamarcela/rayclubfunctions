// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/advanced_settings_state.dart';

/// Interface para o repositório de configurações avançadas
abstract class AdvancedSettingsRepository {
  /// Carrega todas as configurações do usuário
  Future<AdvancedSettingsState> loadSettings(String userId);
  
  /// Salva todas as configurações do usuário
  Future<void> saveSettings(String userId, AdvancedSettingsState settings);
  
  /// Atualiza o idioma selecionado
  Future<void> updateLanguage(String userId, String languageCode);
  
  /// Atualiza o modo de tema
  Future<void> updateThemeMode(String userId, ThemeMode themeMode);
  
  /// Atualiza configurações de privacidade
  Future<void> updatePrivacySettings(String userId, PrivacySettings privacySettings);
  
  /// Atualiza configurações de notificação
  Future<void> updateNotificationSettings(String userId, NotificationSettings notificationSettings);
  
  /// Sincroniza configurações entre dispositivos
  Future<DateTime> syncSettings(String userId);
} 