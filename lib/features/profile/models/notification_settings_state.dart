// Package imports:
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/profile/models/notification_type.dart';

part 'notification_settings_state.freezed.dart';
// We are still going to use the freezed part but not the g.dart part
// since we're not directly serializing this state to JSON
// part 'notification_settings_state.g.dart';

/// Estado do ViewModel para as configurações de notificação
@freezed
class NotificationSettingsState with _$NotificationSettingsState {
  /// Construtor factory para o estado
  const factory NotificationSettingsState({
    /// Indica se o carregamento está em progresso
    @Default(false) bool isLoading,
    
    /// Mensagem de erro, se houver
    String? errorMessage,
    
    /// Estado do interruptor mestre de notificações
    @Default(true) bool masterSwitchEnabled,
    
    /// Configurações individuais para cada tipo de notificação
    @Default({}) Map<NotificationType, bool> notificationSettings,
    
    /// Horário para lembretes diários
    @Default(TimeOfDay(hour: 18, minute: 0)) TimeOfDay reminderTime,
    
    /// Indica se as alterações foram salvas com sucesso
    @Default(false) bool changesSaved,
  }) = _NotificationSettingsState;
}

/// Conversor personalizado para TimeOfDay
class TimeOfDayConverter implements JsonConverter<TimeOfDay, Map<String, dynamic>> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(Map<String, dynamic> json) {
    return TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int);
  }

  @override
  Map<String, dynamic> toJson(TimeOfDay timeOfDay) {
    return {'hour': timeOfDay.hour, 'minute': timeOfDay.minute};
  }
} 