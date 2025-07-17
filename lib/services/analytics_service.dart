// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../core/di/base_service.dart';
import '../utils/uuid_extensions.dart';
import '../core/services/app_tracking_service.dart';

class AnalyticsService implements BaseService {
  final bool enabled;
  final String key;
  bool _initialized = false;
  bool _trackingAuthorized = false;

  AnalyticsService({
    required this.enabled,
    required this.key,
  });

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (!enabled) return;

    // Verificar se o tracking está autorizado
    _trackingAuthorized = await AppTrackingService.isTrackingAuthorized();
    debugPrint('📊 Analytics: Tracking autorizado = $_trackingAuthorized');

    // Inicializar serviço de analytics
    _initialized = true;
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!enabled || !_trackingAuthorized) {
      debugPrint('📊 Analytics: Evento não registrado (tracking não autorizado)');
      return;
    }

    // Validar UUIDs em parâmetros conhecidos
    final Map<String, dynamic> validatedParams = {};
    
    // Copiar parâmetros originais
    if (parameters != null) {
      validatedParams.addAll(parameters);
      
      // Validar campos conhecidos que são UUIDs
      final uuidFields = [
        'userId', 'user_id',
        'challengeId', 'challenge_id',
        'workoutId', 'workout_id',
        'groupId', 'group_id',
        'id', 'benefitId', 'eventId'
      ];
      
      for (final field in uuidFields) {
        if (validatedParams.containsKey(field) && validatedParams[field] is String) {
          validatedParams[field] = (validatedParams[field] as String).toValidUuid();
        }
      }
    }

    // Implementar logging de eventos
    print('Analytics Event: $name, Parameters: $validatedParams');
  }

  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!enabled || !_trackingAuthorized) {
      debugPrint('📊 Analytics: Propriedades não registradas (tracking não autorizado)');
      return;
    }

    // Validar UUIDs em propriedades conhecidas
    final Map<String, dynamic> validatedProps = Map.from(properties);
    
    // Validar userId, se presente
    if (validatedProps.containsKey('userId') && validatedProps['userId'] is String) {
      validatedProps['userId'] = (validatedProps['userId'] as String).toValidUuid();
    }
    if (validatedProps.containsKey('user_id') && validatedProps['user_id'] is String) {
      validatedProps['user_id'] = (validatedProps['user_id'] as String).toValidUuid();
    }

    // Implementar propriedades do usuário
    print('User Properties: $validatedProps');
  }

  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    if (!enabled) return;

    // Implementar logging de erros
    print('Error: $error\nStackTrace: $stackTrace');
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}
