// Project imports:
import '../features/notifications/models/notification.dart';

/// Extensões e utilidades para trabalhar com notificações
extension NotificationExtensions on Notification {
  /// Converte a string de data para um objeto DateTime
  DateTime? get readAtDate => readAt;
  
  /// Converte a string de data de criação para um objeto DateTime
  DateTime get createdAtDate => createdAt;
  
  /// Verifica se a notificação foi lida
  bool get isNotificationRead => isRead;
  
  /// Retorna um ícone apropriado para o tipo de notificação
  String get iconForType {
    switch (type) {
      case 'challenge':
        return 'assets/icons/challenge.png';
      case 'workout':
        return 'assets/icons/workout.png';
      case 'coupon':
        return 'assets/icons/coupon.png';
      case 'system':
      default:
        return 'assets/icons/system.png';
    }
  }
  
  /// Retorna uma cor apropriada para o tipo de notificação (em hexadecimal)
  String get colorForType {
    switch (type) {
      case 'challenge':
        return '#FF5722'; // Laranja
      case 'workout':
        return '#4CAF50'; // Verde
      case 'coupon':
        return '#2196F3'; // Azul
      case 'system':
      default:
        return '#9E9E9E'; // Cinza
    }
  }
}

/// Classe de utilidade para operações comuns de notificações
class NotificationUtils {
  /// Formata uma lista de notificações agrupadas por data (hoje, ontem, esta semana, etc.)
  static Map<String, List<Notification>> groupByDate(
    List<Notification> notifications
  ) {
    final Map<String, List<Notification>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    for (final notification in notifications) {
      final createdAt = notification.createdAtDate;
      final notificationDate = DateTime(
        createdAt.year,
        createdAt.month,
        createdAt.day,
      );
      
      String group;
      if (notificationDate == today) {
        group = 'Hoje';
      } else if (notificationDate == yesterday) {
        group = 'Ontem';
      } else if (now.difference(notificationDate).inDays <= 7) {
        group = 'Esta Semana';
      } else if (now.difference(notificationDate).inDays <= 30) {
        group = 'Este Mês';
      } else {
        group = 'Anteriores';
      }
      
      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      
      grouped[group]!.add(notification);
    }
    
    return grouped;
  }
  
  /// Filtra notificações por tipo
  static List<Notification> filterByType(
    List<Notification> notifications,
    String type,
  ) {
    return notifications.where((n) => n.type == type).toList();
  }
  
  /// Filtra notificações não lidas
  static List<Notification> filterUnread(
    List<Notification> notifications,
  ) {
    return notifications.where((n) => !n.isRead).toList();
  }
  
  /// Conta notificações não lidas
  static int countUnread(List<Notification> notifications) {
    return notifications.where((n) => !n.isRead).length;
  }
}

/// Utilitários para gerenciar notificações do app

/// Verifica se uma notificação é nova (não lida)
bool isNotificationNew(Notification notification) {
  return !notification.isRead;
}

/// Retorna o tempo relativo desde a criação da notificação
String getNotificationTimeAgo(Notification notification) {
  final now = DateTime.now();
  final difference = now.difference(notification.createdAt);

  if (notification.isRead) {
    return 'Lida';
  }

  if (difference.inDays > 0) {
    switch (notification.type) {
      case 'challenge':
        return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      case 'workout':
        return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      case 'coupon':
        return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      case 'system':
      default:
        return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    }
  } else if (difference.inHours > 0) {
    return 'há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
  } else if (difference.inMinutes > 0) {
    return 'há ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
  } else {
    return 'agora';
  }
} 
