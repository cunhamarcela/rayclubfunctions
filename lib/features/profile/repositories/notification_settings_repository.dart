// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/profile/repositories/notification_settings_repository_interface.dart';
import 'package:ray_club_app/features/profile/screens/notification_settings_screen.dart';

/// Implementação do repositório de configurações de notificação usando SharedPreferences
class NotificationSettingsRepository implements NotificationSettingsRepositoryInterface {
  /// Chave para o interruptor mestre
  static const String _masterSwitchKey = 'notifications_enabled';
  
  /// Prefixo para hora do lembrete
  static const String _reminderHourKey = 'notification_reminder_hour';
  
  /// Prefixo para minuto do lembrete
  static const String _reminderMinuteKey = 'notification_reminder_minute';
  
  @override
  Future<Map<String, dynamic>> loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Carregar configuração mestra
      final masterSwitch = prefs.getBool(_masterSwitchKey) ?? true;
      
      // Carregar configurações individuais
      final Map<NotificationType, bool> notificationSettings = {};
      for (final type in NotificationType.values) {
        notificationSettings[type] = prefs.getBool(type.prefsKey) ?? true;
      }
      
      // Carregar horário do lembrete
      final reminderHour = prefs.getInt(_reminderHourKey) ?? 18;
      final reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;
      final reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
      
      return {
        'masterSwitch': masterSwitch,
        'notificationSettings': notificationSettings,
        'reminderTime': reminderTime,
      };
    } catch (e) {
      throw StorageException(
        message: 'Erro ao carregar configurações de notificação',
        originalException: e,
      );
    }
  }
  
  @override
  Future<void> updateMasterSwitch(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_masterSwitchKey, enabled);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar interruptor mestre de notificações',
        originalException: e,
      );
    }
  }
  
  @override
  Future<void> updateNotificationSetting(NotificationType type, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(type.prefsKey, enabled);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar configuração de notificação',
        originalException: e,
      );
    }
  }
  
  @override
  Future<void> updateReminderTime(TimeOfDay timeOfDay) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderHourKey, timeOfDay.hour);
      await prefs.setInt(_reminderMinuteKey, timeOfDay.minute);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar horário de lembrete',
        originalException: e,
      );
    }
  }
} 