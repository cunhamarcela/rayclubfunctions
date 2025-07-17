// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type,
    required String content,
    @JsonKey(name: 'read_at') String? readAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}

/// Extensões e utilidades para trabalhar com notificações
extension NotificationExtensions on AppNotification {
  /// Converte a string de data para um objeto DateTime
  DateTime? get readAtDate => readAt != null ? DateTime.parse(readAt!) : null;
  
  /// Converte a string de data de criação para um objeto DateTime
  DateTime get createdAtDate => DateTime.parse(createdAt);
  
  /// Verifica se a notificação foi lida
  bool get isRead => readAt != null;
  
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
