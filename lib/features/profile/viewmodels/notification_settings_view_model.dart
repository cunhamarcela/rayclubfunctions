// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/error_handler.dart';
import 'package:ray_club_app/features/profile/models/notification_settings_state.dart';
import 'package:ray_club_app/features/profile/models/notification_type.dart';
import 'package:ray_club_app/features/profile/repositories/notification_settings_repository_interface.dart';

/// Provider para o repositório
final notificationSettingsRepositoryProvider = Provider<NotificationSettingsRepositoryInterface>((ref) {
  // Implementação será injetada na configuração da app
  throw UnimplementedError();
});

/// Provider para o ViewModel de configurações de notificação
final notificationSettingsViewModelProvider = StateNotifierProvider<NotificationSettingsViewModel, NotificationSettingsState>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  final errorHandler = ref.watch(ErrorHandler.provider);
  return NotificationSettingsViewModel(repository, errorHandler);
});

/// ViewModel para gerenciar configurações de notificação
class NotificationSettingsViewModel extends StateNotifier<NotificationSettingsState> {
  final NotificationSettingsRepositoryInterface _repository;
  final ErrorHandler _errorHandler;

  /// Construtor
  NotificationSettingsViewModel(this._repository, this._errorHandler) : super(const NotificationSettingsState()) {
    loadSettings();
  }

  /// Carrega todas as configurações de notificação
  Future<void> loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      final settings = await _repository.loadNotificationSettings();
      
      state = state.copyWith(
        isLoading: false,
        masterSwitchEnabled: settings['masterSwitch'] as bool,
        notificationSettings: settings['notificationSettings'] as Map<NotificationType, bool>,
        reminderTime: settings['reminderTime'] as TimeOfDay,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Atualiza o interruptor mestre de notificações
  Future<void> updateMasterSwitch(bool enabled) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      await _repository.updateMasterSwitch(enabled);
      
      state = state.copyWith(
        isLoading: false,
        masterSwitchEnabled: enabled,
        changesSaved: true,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Atualiza a configuração de um tipo específico de notificação
  Future<void> updateNotificationSetting(NotificationType type, bool enabled) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      await _repository.updateNotificationSetting(type, enabled);
      
      final updatedSettings = Map<NotificationType, bool>.from(state.notificationSettings);
      updatedSettings[type] = enabled;
      
      state = state.copyWith(
        isLoading: false,
        notificationSettings: updatedSettings,
        changesSaved: true,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Atualiza o horário do lembrete diário
  Future<void> updateReminderTime(TimeOfDay timeOfDay) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      await _repository.updateReminderTime(timeOfDay);
      
      state = state.copyWith(
        isLoading: false,
        reminderTime: timeOfDay,
        changesSaved: true,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Formata um TimeOfDay para exibição
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    String period = timeOfDay.hour >= 12 ? 'PM' : 'AM';
    int hour = timeOfDay.hour > 12 ? timeOfDay.hour - 12 : timeOfDay.hour;
    hour = hour == 0 ? 12 : hour;
    String minute = timeOfDay.minute < 10 ? '0${timeOfDay.minute}' : '${timeOfDay.minute}';
    return '$hour:$minute $period';
  }
} 