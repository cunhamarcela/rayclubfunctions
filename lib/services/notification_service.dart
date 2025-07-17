// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../core/di/base_service.dart';
import '../core/errors/app_exception.dart';
import '../features/profile/models/notification_model.dart';

/// Serviço para gerenciar notificações da aplicação
class NotificationService implements BaseService {
  final SupabaseClient _supabase;
  final FlutterLocalNotificationsPlugin _localNotifications;
  
  StreamSubscription? _realTimeSubscription;
  RealtimeChannel? _realtimeChannel;
  bool _initialized = false;

  /// Tipos de notificações suportadas
  static const String typeChallenge = 'challenge';
  static const String typeWorkout = 'workout';
  static const String typeCoupon = 'coupon';
  static const String typeSystem = 'system';

  NotificationService({
    required SupabaseClient supabase,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _supabase = supabase,
       _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();
  
  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    try {
      // Inicializar notificações locais
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      
      _initialized = true;
    } catch (e) {
      throw AppException(
        message: 'Erro ao inicializar serviço de notificações: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Busca notificações do usuário atual
  Future<List<AppNotification>> getNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }
      
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);
      
      return (response as List)
          .map((item) => AppNotification.fromJson(item))
          .toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar notificações: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Busca as notificações não lidas para o usuário atual
  Future<List<AppNotification>> getUnreadNotifications() async {
    if (!_initialized) {
      throw AppException(
        message: 'Notification service not initialized',
        code: 'NotificationService.getUnreadNotifications',
        stackTrace: StackTrace.current,
      );
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }
      
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .eq('read_at', '')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => AppNotification.fromJson(item))
          .toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar notificações não lidas: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Marca uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    if (!_initialized) {
      throw AppException(
        message: 'Notification service not initialized',
        code: 'NotificationService.markAsRead',
        stackTrace: StackTrace.current,
      );
    }

    try {
      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId)
          .eq('read_at', '');
    } catch (e) {
      throw AppException(
        message: 'Erro ao marcar notificação como lida: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Marca todas as notificações como lidas
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return;
      }
      
      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', user.id)
          .eq('read_at', '');
    } catch (e) {
      throw AppException(
        message: 'Erro ao marcar todas notificações como lidas: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Cria uma nova notificação no banco de dados
  Future<AppNotification> createNotification({
    required String userId,
    required String type,
    required String content,
  }) async {
    try {
      final notification = {
        'user_id': userId,
        'type': type,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('notifications')
          .insert(notification)
          .select()
          .single();
      
      return AppNotification.fromJson(response);
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar notificação: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Envia uma notificação local para o dispositivo
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'ray_club_channel',
        'Ray Club Notificações',
        channelDescription: 'Canal para notificações do Ray Club',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      throw AppException(
        message: 'Erro ao mostrar notificação local: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  /// Obtém o título para a notificação baseado no tipo
  String _getNotificationTitle(String type) {
    switch (type) {
      case typeChallenge:
        return 'Novo Desafio';
      case typeWorkout:
        return 'Atividade de Treino';
      case typeCoupon:
        return 'Novo Cupom Disponível';
      case typeSystem:
      default:
        return 'Ray Club';
    }
  }

  @override
  Future<void> dispose() async {
    await unsubscribeFromRealTimeNotifications();
  }
  
  /// Cancela a inscrição de notificações em tempo real
  Future<void> unsubscribeFromRealTimeNotifications() async {
    await _realTimeSubscription?.cancel();
    _realTimeSubscription = null;
    
    if (_realtimeChannel != null) {
      await _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }
  
  /// Inicia escuta por notificações em tempo real para o usuário atual
  Future<void> startListeningForNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return;
    }
    
    // Cancela qualquer inscrição existente
    await unsubscribeFromRealTimeNotifications();
    
    // Inicia nova inscrição
    _realtimeChannel = _supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final notification = AppNotification.fromJson(
              payload.newRecord
            );
            
            // Mostra notificação local
            showLocalNotification(
              title: _getNotificationTitle(notification.type),
              body: notification.content,
            );
          },
        )
        .subscribe();
  }
}
