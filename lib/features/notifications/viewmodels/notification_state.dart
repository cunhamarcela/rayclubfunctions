import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/notification.dart';

part 'notification_state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _NotificationStateInitial;
  const factory NotificationState.loading() = _NotificationStateLoading;
  const factory NotificationState.loaded({
    required List<Notification> notifications,
    required int unreadCount,
  }) = _NotificationStateLoaded;
  const factory NotificationState.error(String message) = _NotificationStateError;
} 