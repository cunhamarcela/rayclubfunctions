// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import '../events/app_event_bus.dart';

// Mock de logger para testes
class MockEventLogger implements EventLogger {
  final List<AppEvent> loggedEvents = [];
  
  @override
  void logEvent(AppEvent event) {
    loggedEvents.add(event);
  }
}

void main() {
  late ProviderContainer container;
  late AppEventBus eventBus;
  late MockEventLogger mockLogger;
  
  setUp(() {
    mockLogger = MockEventLogger();
    eventBus = AppEventBus(logger: mockLogger);
    
    container = ProviderContainer(
      overrides: [
        appEventBusProvider.overrideWithValue(eventBus),
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
  });
  
  group('AppEventBus', () {
    test('deve publicar e receber eventos', () async {
      // Preparar para receber evento
      bool receivedEvent = false;
      final event = AppEvent.auth(
        type: EventTypes.login,
        userId: 'user-123',
      );
      
      // Inscrever-se para eventos
      final subscription = eventBus.events.listen((receivedEvent) {
        expect(receivedEvent, equals(event));
        receivedEvent = true;
      });
      
      // Publicar evento
      eventBus.publish(event);
      
      // Verificar que o evento foi logado
      expect(mockLogger.loggedEvents.length, equals(1));
      expect(mockLogger.loggedEvents.first, equals(event));
      
      // Limpar
      await subscription.cancel();
    });
    
    test('deve filtrar eventos por tipo', () async {
      // Publicar diferentes tipos de eventos
      final authEvent = AppEvent.auth(type: EventTypes.login, userId: 'user-123');
      final workoutEvent = AppEvent.workout(type: EventTypes.workoutCompleted, workoutId: 'workout-123');
      final challengeEvent = AppEvent.challenge(type: EventTypes.challengeCompleted, challengeId: 'challenge-123');
      
      // Contadores para verificar quantos eventos de cada tipo foram recebidos
      int authEventsReceived = 0;
      int workoutEventsReceived = 0;
      
      // Escutar apenas eventos de autenticação
      final authSubscription = eventBus.onAuth().listen((_) {
        authEventsReceived++;
      });
      
      // Escutar apenas eventos de treino
      final workoutSubscription = eventBus.onWorkout().listen((_) {
        workoutEventsReceived++;
      });
      
      // Publicar todos os eventos
      eventBus.publish(authEvent);
      eventBus.publish(workoutEvent);
      eventBus.publish(challengeEvent);
      
      // Aguardar processamento assíncrono
      await Future.delayed(Duration.zero);
      
      // Verificar que apenas os eventos corretos foram recebidos
      expect(authEventsReceived, equals(1));
      expect(workoutEventsReceived, equals(1));
      
      // Limpar
      await authSubscription.cancel();
      await workoutSubscription.cancel();
    });
    
    test('deve filtrar eventos por tipo específico', () async {
      // Publicar eventos de mesmo tipo com subtipos diferentes
      final loginEvent = AppEvent.auth(type: EventTypes.login, userId: 'user-123');
      final logoutEvent = AppEvent.auth(type: EventTypes.logout, userId: 'user-123');
      
      // Contadores para verificar quantos eventos de cada subtipo foram recebidos
      int loginEventsReceived = 0;
      int totalAuthEventsReceived = 0;
      
      // Escutar apenas eventos de login
      final loginSubscription = eventBus.onAuth(EventTypes.login).listen((_) {
        loginEventsReceived++;
      });
      
      // Escutar todos os eventos de autenticação
      final authSubscription = eventBus.onAuth().listen((_) {
        totalAuthEventsReceived++;
      });
      
      // Publicar os eventos
      eventBus.publish(loginEvent);
      eventBus.publish(logoutEvent);
      
      // Aguardar processamento assíncrono
      await Future.delayed(Duration.zero);
      
      // Verificar que os eventos foram filtrados corretamente
      expect(loginEventsReceived, equals(1));
      expect(totalAuthEventsReceived, equals(2));
      
      // Limpar
      await loginSubscription.cancel();
      await authSubscription.cancel();
    });
    
    test('deve tratar erros em listeners corretamente', () async {
      // Evento para testar
      final event = AppEvent.custom(name: 'test', data: {'value': 42});
      
      // Flag para verificar se o onError foi chamado
      bool errorHandled = false;
      
      // Criar um listener que lança uma exceção
      final subscription = eventBus.listen<AppEvent>(
        eventBus.events,
        (_) {
          throw Exception('Erro de teste');
        },
        onError: (e, _) {
          errorHandled = true;
        },
      );
      
      // Publicar o evento
      eventBus.publish(event);
      
      // Aguardar processamento assíncrono
      await Future.delayed(Duration.zero);
      
      // Verificar que o erro foi tratado
      expect(errorHandled, isTrue);
      
      // Limpar
      await subscription.cancel();
    });
    
    test('deve limpar subscriptions ao cancelar dispose', () async {
      // Criar uma nova instância do EventBus para este teste
      final localEventBus = AppEventBus();
      int eventsReceived = 0;
      
      // Adicionar subscriptions
      localEventBus.listen<AppEvent>(
        localEventBus.events,
        (_) {
          eventsReceived++;
        },
      );
      
      // Verificar que eventos são recebidos
      localEventBus.publish(AppEvent.custom(name: 'test', data: {}));
      await Future.delayed(Duration.zero);
      expect(eventsReceived, equals(1));
      
      // Fazer dispose e verificar que eventos não são mais recebidos
      localEventBus.dispose();
      
      // Publicar novamente não deve aumentar o contador
      try {
        localEventBus.publish(AppEvent.custom(name: 'test2', data: {}));
      } catch (_) {
        // Ignorar erros de stream fechada
      }
      
      await Future.delayed(Duration.zero);
      expect(eventsReceived, equals(1));
    });
  });
  
  group('EventTypes constants', () {
    test('deve ter todas as constantes necessárias', () {
      // Verificar que as constantes de autenticação estão definidas
      expect(EventTypes.login, isNotEmpty);
      expect(EventTypes.logout, isNotEmpty);
      expect(EventTypes.register, isNotEmpty);
      
      // Verificar que constantes de treino estão definidas
      expect(EventTypes.workoutCompleted, isNotEmpty);
      expect(EventTypes.workoutStarted, isNotEmpty);
      
      // Verificar que constantes de desafio estão definidas
      expect(EventTypes.challengeCompleted, isNotEmpty);
      expect(EventTypes.challengeJoined, isNotEmpty);
      
      // Verificar que constantes não são iguais
      expect(EventTypes.login, isNot(equals(EventTypes.logout)));
      expect(EventTypes.workoutCompleted, isNot(equals(EventTypes.workoutStarted)));
    });
  });
  
  group('Providers', () {
    test('appEventsStreamProvider deve expor eventos', () async {
      // Criar um listener para o provider de stream
      final listener = Listener<AsyncValue<AppEvent>>();
      
      // Adicionar o listener
      container.listen(
        appEventsStreamProvider,
        listener,
        fireImmediately: true,
      );
      
      // Verificar o estado inicial
      verify(listener(const AsyncValue<AppEvent>.loading())).called(1);
      
      // Publicar um evento
      final event = AppEvent.auth(type: EventTypes.login, userId: 'user-123');
      eventBus.publish(event);
      
      // Aguardar processamento assíncrono
      await Future.delayed(Duration.zero);
      
      // Verificar que o provider recebeu o evento
      verify(listener(any)).called(2);
    });
    
    test('authEventsProvider deve filtrar eventos', () async {
      // Criar um listener para o provider de eventos de auth
      final listener = Listener<AsyncValue<AuthEvent>>();
      
      // Adicionar o listener com filtro de login
      container.listen(
        authEventsProvider(EventTypes.login),
        listener,
        fireImmediately: true,
      );
      
      // Verificar o estado inicial
      verify(listener(const AsyncValue<AuthEvent>.loading())).called(1);
      
      // Publicar um evento de logout (não deve ser capturado)
      final logoutEvent = AppEvent.auth(type: EventTypes.logout, userId: 'user-123');
      eventBus.publish(logoutEvent);
      
      // Publicar um evento de login (deve ser capturado)
      final loginEvent = AppEvent.auth(type: EventTypes.login, userId: 'user-123');
      eventBus.publish(loginEvent);
      
      // Aguardar processamento assíncrono
      await Future.delayed(Duration.zero);
      
      // Verificar que o provider recebeu apenas o evento de login
      verify(listener(any)).called(2);
    });
  });
}

// Helper para verificação de chamadas de listeners
class Listener<T> extends Mock {
  void call(T value);
} 
