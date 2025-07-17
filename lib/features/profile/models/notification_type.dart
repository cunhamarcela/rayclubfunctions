// Flutter imports:
import 'package:flutter/material.dart';

/// Tipos de notificações disponíveis
enum NotificationType {
  /// Notificações de treino
  workout,
  
  /// Notificações de lembretes
  reminder,
  
  /// Notificações de desafios
  challenge,
  
  /// Notificações de nutrição
  nutrition,
  
  /// Notificações de novidades e promoções
  promotion
}

/// Extensão para obter informações sobre cada tipo de notificação
extension NotificationTypeExtension on NotificationType {
  /// Chave para armazenar no SharedPreferences
  String get prefsKey {
    return 'notification_${toString().split('.').last}';
  }
  
  /// Título para exibição
  String get title {
    switch (this) {
      case NotificationType.workout:
        return 'Lembretes de treino';
      case NotificationType.reminder:
        return 'Lembretes diários';
      case NotificationType.challenge:
        return 'Notificações de desafios';
      case NotificationType.nutrition:
        return 'Lembretes de nutrição';
      case NotificationType.promotion:
        return 'Novidades e promoções';
    }
  }
  
  /// Descrição detalhada da notificação
  String get description {
    switch (this) {
      case NotificationType.workout:
        return 'Receba lembretes sobre seus treinos programados e notificações quando completar metas.';
      case NotificationType.reminder:
        return 'Lembretes diários para manter sua rotina de atividades físicas.';
      case NotificationType.challenge:
        return 'Notificações sobre novos desafios, convites e atualizações de ranking.';
      case NotificationType.nutrition:
        return 'Lembretes para registrar suas refeições e hidratação.';
      case NotificationType.promotion:
        return 'Informações sobre novos benefícios, cupons e ofertas exclusivas.';
    }
  }
  
  /// Ícone representativo
  IconData get icon {
    switch (this) {
      case NotificationType.workout:
        return Icons.fitness_center;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.challenge:
        return Icons.emoji_events;
      case NotificationType.nutrition:
        return Icons.restaurant;
      case NotificationType.promotion:
        return Icons.card_giftcard;
    }
  }
} 