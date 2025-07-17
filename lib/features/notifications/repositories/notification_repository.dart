import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/exceptions/app_exception.dart';
import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications({required bool unreadOnly});
  Future<void> markAsRead(List<String> notificationIds);
  Future<int> getUnreadCount();
}

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabase;

  SupabaseNotificationRepository(this._supabase);

  @override
  Future<List<Notification>> getNotifications({required bool unreadOnly}) async {
    try {
      final query = _supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      if (unreadOnly) {
        query.eq('is_read', false);
      }

      final response = await query;
      
      return response
          .map((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      throw StorageException(
        message: 'Erro ao carregar notificações',
        originalError: e,
      );
    }
  }

  @override
  Future<void> markAsRead(List<String> notificationIds) async {
    try {
      await _supabase.rpc(
        'mark_notifications_as_read',
        params: {'p_notification_ids': notificationIds},
      );
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
      throw StorageException(
        message: 'Erro ao marcar notificações como lidas',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id', count: CountOption.exact)
          .eq('is_read', false);
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      throw StorageException(
        message: 'Erro ao contar notificações não lidas',
        originalError: e,
      );
    }
  }
} 