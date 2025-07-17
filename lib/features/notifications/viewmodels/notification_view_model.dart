import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository) : super(const NotificationState.initial());

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    state = const NotificationState.loading();

    try {
      final notifications = await _repository.getNotifications(unreadOnly: unreadOnly);
      final unreadCount = await _repository.getUnreadCount();

      state = NotificationState.loaded(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = NotificationState.error(e.toString());
    }
  }

  Future<void> markAsRead(List<String> notificationIds) async {
    if (state is! _NotificationStateLoaded) return;

    try {
      await _repository.markAsRead(notificationIds);
      
      // Atualiza o estado localmente
      final currentState = state as _NotificationStateLoaded;
      
      // Atualiza as notificações marcadas como lidas
      final updatedNotifications = currentState.notifications.map((notification) {
        if (notificationIds.contains(notification.id)) {
          return notification.copyWith(
            isRead: true, 
            readAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();
      
      // Atualiza o contador de não lidas
      final newUnreadCount = await _repository.getUnreadCount();
      
      state = NotificationState.loaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      // Não alterar o estado em caso de erro, apenas log
      // para evitar perda da lista de notificações
      print('Erro ao marcar notificações como lidas: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (state is! _NotificationStateLoaded) return;
    
    final currentState = state as _NotificationStateLoaded;
    final unreadIds = currentState.notifications
        .where((notification) => !notification.isRead)
        .map((notification) => notification.id)
        .toList();
    
    if (unreadIds.isEmpty) return;
    
    await markAsRead(unreadIds);
  }
} 