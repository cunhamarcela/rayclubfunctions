// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_event_bus.freezed.dart';
part 'app_event_bus.g.dart';

/// Constantes para tipos de eventos para evitar erros de digitação
class EventTypes {
  // Eventos de autenticação
  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'register';
  static const String passwordReset = 'password_reset';
  
  // Eventos de treino
  static const String workoutStarted = 'started';
  static const String workoutCompleted = 'completed';
  static const String workoutCancelled = 'cancelled';
  static const String workoutUpdated = 'updated';
  
  // Eventos de desafio
  static const String challengeCreated = 'created';
  static const String challengeJoined = 'joined';
  static const String challengeCompleted = 'completed';
  static const String challengeLeft = 'left';
  static const String challengeInvited = 'invited';
  
  // Eventos de nutrição
  static const String mealAdded = 'added';
  static const String mealUpdated = 'updated';
  static const String mealRemoved = 'removed';
  
  // Eventos de benefícios
  static const String benefitClaimed = 'claimed';
  static const String benefitUsed = 'used';
  static const String benefitExpired = 'expired';
}

/// Classe abstrata base para todos os eventos da aplicação
@freezed
class AppEvent with _$AppEvent {
  /// Evento de autenticação (login, logout, etc)
  const factory AppEvent.auth({
    required String type,
    String? userId,
    Map<String, dynamic>? data,
  }) = AuthEvent;
  
  /// Evento de treino (criação, atualização, etc)
  const factory AppEvent.workout({
    required String type,
    required String workoutId,
    Map<String, dynamic>? data,
  }) = WorkoutEvent;
  
  /// Evento de desafio (criação, participação, etc)
  const factory AppEvent.challenge({
    required String type,
    required String challengeId,
    Map<String, dynamic>? data,
  }) = ChallengeEvent;
  
  /// Evento de nutrição (criação de refeição, atualização, etc)
  const factory AppEvent.nutrition({
    required String type,
    String? mealId,
    Map<String, dynamic>? data,
  }) = NutritionEvent;
  
  /// Evento de benefícios (uso de cupom, etc)
  const factory AppEvent.benefits({
    required String type,
    String? benefitId,
    Map<String, dynamic>? data,
  }) = BenefitsEvent;
  
  /// Evento de conectividade (online, offline)
  const factory AppEvent.connectivity({
    required bool isOnline,
    String? timestamp,
  }) = ConnectivityEvent;
  
  /// Evento personalizado para casos específicos
  const factory AppEvent.custom({
    required String name,
    required Map<String, dynamic> data,
  }) = CustomEvent;
  
  factory AppEvent.fromJson(Map<String, dynamic> json) => _$AppEventFromJson(json);
}

/// Interface para logging de eventos
abstract class EventLogger {
  void logEvent(AppEvent event);
}

/// Logger padrão que registra no console
class DefaultEventLogger implements EventLogger {
  @override
  void logEvent(AppEvent event) {
    if (kDebugMode) {
      print('AppEvent: ${event.runtimeType} - ${_getEventDescription(event)}');
    }
  }
  
  String _getEventDescription(AppEvent event) {
    return event.when(
      auth: (type, userId, data) => 'Auth[$type] userId: $userId',
      workout: (type, workoutId, data) => 'Workout[$type] workoutId: $workoutId',
      challenge: (type, challengeId, data) => 'Challenge[$type] challengeId: $challengeId',
      nutrition: (type, mealId, data) => 'Nutrition[$type] mealId: $mealId',
      benefits: (type, benefitId, data) => 'Benefits[$type] benefitId: $benefitId',
      connectivity: (isOnline, timestamp) => 'Connectivity[${isOnline ? 'online' : 'offline'}]',
      custom: (name, data) => 'Custom[$name]',
    );
  }
}

/// EventBus para gerenciar a comunicação assíncrona entre features
class AppEventBus {
  /// Controlador de stream para eventos
  final StreamController<AppEvent> _eventController = StreamController<AppEvent>.broadcast();
  
  /// Logger para registrar eventos
  final EventLogger _logger;
  
  /// Lista de subscriptions para facilitar limpeza
  final List<StreamSubscription> _subscriptions = [];
  
  AppEventBus({EventLogger? logger}) : _logger = logger ?? DefaultEventLogger();
  
  /// Stream pública para permitir que components se inscrevam aos eventos
  Stream<AppEvent> get events => _eventController.stream;
  
  /// Publica um evento no barramento
  void publish(AppEvent event) {
    try {
      _logger.logEvent(event);
      _eventController.add(event);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Erro ao publicar evento: $e');
        print(stackTrace);
      }
    }
  }
  
  /// Adiciona um listener genérico com tratamento de erro
  StreamSubscription<T> listen<T extends AppEvent>(
    Stream<T> stream, 
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      (event) {
        try {
          onData(event);
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('Erro em listener de evento: $e');
            print(stackTrace);
          }
          if (onError != null) {
            onError(e, stackTrace);
          }
        }
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    
    _subscriptions.add(subscription);
    return subscription;
  }
  
  /// Fecha o controlador de stream e cancela todas as subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _eventController.close();
  }
  
  /// Filtra eventos por tipo
  Stream<T> on<T extends AppEvent>() {
    return events.where((event) => event is T).cast<T>();
  }
  
  /// Filtra eventos específicos de autenticação
  Stream<AuthEvent> onAuth([String? typeFilter]) {
    return events
        .where((event) => event is AuthEvent)
        .cast<AuthEvent>()
        .where((event) => typeFilter == null || event.type == typeFilter);
  }
  
  /// Filtra eventos específicos de treino
  Stream<WorkoutEvent> onWorkout([String? typeFilter]) {
    return events
        .where((event) => event is WorkoutEvent)
        .cast<WorkoutEvent>()
        .where((event) => typeFilter == null || event.type == typeFilter);
  }
  
  /// Filtra eventos específicos de desafio
  Stream<ChallengeEvent> onChallenge([String? typeFilter]) {
    return events
        .where((event) => event is ChallengeEvent)
        .cast<ChallengeEvent>()
        .where((event) => typeFilter == null || event.type == typeFilter);
  }
  
  /// Filtra eventos específicos de nutrição
  Stream<NutritionEvent> onNutrition([String? typeFilter]) {
    return events
        .where((event) => event is NutritionEvent)
        .cast<NutritionEvent>()
        .where((event) => typeFilter == null || event.type == typeFilter);
  }
  
  /// Filtra eventos específicos de benefícios
  Stream<BenefitsEvent> onBenefits([String? typeFilter]) {
    return events
        .where((event) => event is BenefitsEvent)
        .cast<BenefitsEvent>()
        .where((event) => typeFilter == null || event.type == typeFilter);
  }
  
  /// Filtra eventos de conectividade
  Stream<ConnectivityEvent> onConnectivity() {
    return events
        .where((event) => event is ConnectivityEvent)
        .cast<ConnectivityEvent>();
  }
  
  /// Filtra eventos customizados por nome
  Stream<CustomEvent> onCustom([String? name]) {
    return events
        .where((event) => event is CustomEvent)
        .cast<CustomEvent>()
        .where((event) => name == null || event.name == name);
  }
}

/// Provider global para acesso ao EventBus
final appEventBusProvider = Provider<AppEventBus>((ref) {
  final eventBus = AppEventBus();
  
  // Garante que o EventBus será encerrado corretamente quando o provider for descartado
  ref.onDispose(() {
    eventBus.dispose();
  });
  
  return eventBus;
});

/// Provider que expõe um Stream de todos os eventos
final appEventsStreamProvider = StreamProvider<AppEvent>((ref) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.events;
});

/// Provider que expõe um Stream de eventos de autenticação
final authEventsProvider = StreamProvider.family<AuthEvent, String?>((ref, typeFilter) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onAuth(typeFilter);
});

/// Provider que expõe um Stream de eventos de treino
final workoutEventsProvider = StreamProvider.family<WorkoutEvent, String?>((ref, typeFilter) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onWorkout(typeFilter);
});

/// Provider que expõe um Stream de eventos de desafio
final challengeEventsProvider = StreamProvider.family<ChallengeEvent, String?>((ref, typeFilter) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onChallenge(typeFilter);
});

/// Provider que expõe um Stream de eventos de nutrição
final nutritionEventsProvider = StreamProvider.family<NutritionEvent, String?>((ref, typeFilter) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onNutrition(typeFilter);
});

/// Provider que expõe um Stream de eventos de benefícios
final benefitsEventsProvider = StreamProvider.family<BenefitsEvent, String?>((ref, typeFilter) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onBenefits(typeFilter);
});

/// Provider que expõe um Stream de eventos de conectividade
final connectivityEventsProvider = StreamProvider<ConnectivityEvent>((ref) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onConnectivity();
});

/// Provider que expõe um Stream de eventos customizados
final customEventsProvider = StreamProvider.family<CustomEvent, String?>((ref, name) {
  final eventBus = ref.watch(appEventBusProvider);
  return eventBus.onCustom(name);
}); 
