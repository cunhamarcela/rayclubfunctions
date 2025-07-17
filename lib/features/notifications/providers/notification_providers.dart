import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../repositories/notification_repository.dart';
import '../viewmodels/notification_state.dart';
import '../viewmodels/notification_view_model.dart';

// Provider para o repositório de notificações
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseNotificationRepository(supabase);
});

// Provider para o ViewModel de notificações
final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationViewModel(repository);
});

// Provider para o contador de notificações não lidas
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationViewModelProvider);
  
  return notificationState.maybeWhen(
    loaded: (_, unreadCount) => unreadCount,
    orElse: () => 0,
  );
}); 