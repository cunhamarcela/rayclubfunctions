// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/features/profile/models/notification_type.dart';

/// Interface para o repositório de configurações de notificação
abstract class NotificationSettingsRepositoryInterface {
  /// Carrega todas as configurações de notificação
  Future<Map<String, dynamic>> loadNotificationSettings();
  
  /// Atualiza o interruptor mestre de notificações
  Future<void> updateMasterSwitch(bool enabled);
  
  /// Atualiza a configuração de um tipo específico de notificação
  Future<void> updateNotificationSetting(NotificationType type, bool enabled);
  
  /// Atualiza o horário do lembrete diário
  Future<void> updateReminderTime(TimeOfDay timeOfDay);
} 