import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    @Default(false) bool isRead,
    required DateTime createdAt,
    DateTime? readAt,
    @Default({}) Map<String, dynamic> data,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
} 