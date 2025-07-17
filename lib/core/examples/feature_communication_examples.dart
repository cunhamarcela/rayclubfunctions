// Este arquivo contém exemplos de como usar os mecanismos de comunicação entre features
// Não é parte da aplicação principal, serve apenas como documentação e exemplo

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../events/app_event_bus.dart';
import '../providers/shared_state_provider.dart';

/// Exemplo de Provider para o ViewModel
final exampleViewModelProvider = StateNotifierProvider<ExampleViewModel, void>((ref) {
  return ExampleViewModel(ref);
});

/// Exemplo de ViewModel que usa o sistema de comunicação entre features
class ExampleViewModel extends StateNotifier<void> {
  final Ref _ref;
  final List<StreamSubscription> _subscriptions = [];
  
  ExampleViewModel(this._ref) : super(null) {
    // Configurar listeners para eventos necessários
    _setupEventListeners();
  }
  
  void _setupEventListeners() {
    // Escutar eventos de desafios usando o provider específico
    // Este padrão permite que diferentes features respondam a eventos
    // sem conhecer detalhes da implementação de outras features
    final challengeEventStream = _ref.read(challengeEventsProvider(EventTypes.challengeCompleted)).stream;
    
    // Usar o método listen do EventBus que já trata erros internamente
    final subscription1 = _ref.read(appEventBusProvider).listen(
      challengeEventStream,
      (event) {
        // Quando um desafio for completado, atualizar o estado compartilhado
        _ref.read(sharedStateProvider.notifier).setCustomData(
          'lastCompletedChallenge', 
          {'id': event.challengeId, 'timestamp': DateTime.now().toIso8601String()}
        );
        
        // Executar lógica específica desta feature em resposta ao evento de outra feature
        _handleChallengeCompleted(event.challengeId, event.data);
      },
      onError: (error, stackTrace) {
        debugPrint('Erro ao processar evento de desafio: $error');
      }
    );
    
    // Guardar a subscription para cancelar depois
    _subscriptions.add(subscription1);
    
    // Escutar mudanças no modo offline
    final connectivityEventStream = _ref.read(connectivityEventsProvider).stream;
    final subscription2 = _ref.read(appEventBusProvider).listen(
      connectivityEventStream,
      (event) {
        // Atualizar o estado compartilhado
        _ref.read(sharedStateProvider.notifier).setOfflineMode(!event.isOnline);
        
        // Adaptar o comportamento desta feature com base no status de conectividade
        _handleConnectivityChange(event.isOnline);
      }
    );
    
    // Guardar a subscription para cancelar depois
    _subscriptions.add(subscription2);
  }
  
  void _handleChallengeCompleted(String challengeId, Map<String, dynamic>? data) {
    // Lógica específica da feature para lidar com a conclusão de um desafio
    // Por exemplo, mostrar uma notificação ou desbloquear um recurso
  }
  
  void _handleConnectivityChange(bool isOnline) {
    // Adaptar comportamento com base na conectividade
    // Por exemplo, desativar certas funcionalidades quando offline
  }
  
  /// Exemplo de método que publica eventos para outras features
  void completeWorkout(String workoutId, Map<String, dynamic> workoutData) {
    try {
      // Validar dados antes de prosseguir
      if (workoutId.isEmpty) {
        throw ArgumentError('workoutId não pode ser vazio');
      }
      
      // Atualizar o estado compartilhado
      _ref.read(sharedStateProvider.notifier).setCurrentWorkout(workoutId);
      
      // Publicar um evento para que outras features possam reagir
      _ref.read(appEventBusProvider).publish(
        AppEvent.workout(
          type: EventTypes.workoutCompleted,
          workoutId: workoutId,
          data: workoutData,
        ),
      );
    } catch (e) {
      debugPrint('Erro ao completar treino: $e');
      rethrow; // Repassar o erro para ser tratado por quem chamou o método
    }
  }
  
  /// Exemplo de método que acessa estado compartilhado
  void navigateToChallengeDetails() {
    // Acessar dados do estado compartilhado
    final challengeId = _ref.read(sharedStateProvider).currentChallengeId;
    
    if (challengeId != null) {
      // Usar o ID para navegação ou outra lógica
      // ...
    }
  }
  
  @override
  void dispose() {
    // Cancelar todas as subscriptions para evitar memory leaks
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    super.dispose();
  }
}

/// Exemplo de Widget que demonstra o uso do sistema de eventos e estado compartilhado
class ExampleFeatureWidget extends ConsumerWidget {
  const ExampleFeatureWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o estado compartilhado
    final sharedState = ref.watch(sharedStateProvider);
    
    // Observar eventos específicos usando um Stream Provider
    final workoutEvents = ref.watch(workoutEventsProvider(EventTypes.workoutCompleted));
    
    // Garantir que o ViewModel está inicializado
    ref.watch(exampleViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo de Comunicação entre Features'),
      ),
      body: Column(
        children: [
          // Exibir informações do estado compartilhado
          ListTile(
            title: const Text('Nome do Usuário:'),
            subtitle: Text(sharedState.userName ?? 'Não definido'),
          ),
          ListTile(
            title: const Text('Status de Assinatura:'),
            subtitle: Text(sharedState.isSubscriber ? 'Assinante' : 'Não assinante'),
          ),
          ListTile(
            title: const Text('Modo Offline:'),
            subtitle: Text(sharedState.isOfflineMode ? 'Ativo' : 'Inativo'),
          ),
          
          // Exemplo de botão que dispara um evento usando constantes de tipos
          ElevatedButton(
            onPressed: () {
              try {
                // Publicar um evento que outras features podem escutar
                ref.read(appEventBusProvider).publish(
                  AppEvent.challenge(
                    type: EventTypes.challengeJoined,
                    challengeId: 'example-challenge-123',
                    data: {'joinedAt': DateTime.now().toIso8601String()},
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao participar do desafio: $e')),
                );
              }
            },
            child: const Text('Participar de Desafio (Dispara Evento)'),
          ),
          
          // Exemplo de botão que atualiza o estado compartilhado
          ElevatedButton(
            onPressed: () {
              try {
                // Atualizar o estado compartilhado
                ref.read(sharedStateProvider.notifier).updateUserInfo(
                  userName: 'Usuário Exemplo',
                  isSubscriber: true,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar informações: $e')),
                );
              }
            },
            child: const Text('Atualizar Informações do Usuário'),
          ),
          
          // Exemplo de completar um treino usando o ViewModel
          ElevatedButton(
            onPressed: () {
              try {
                ref.read(exampleViewModelProvider.notifier).completeWorkout(
                  'example-workout-456',
                  {
                    'duration': 45,
                    'calories': 350,
                    'completed_at': DateTime.now().toIso8601String(),
                  },
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Treino concluído com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao concluir treino: $e')),
                );
              }
            },
            child: const Text('Concluir Treino'),
          ),
          
          // Exibir stream de eventos (apenas para demonstração)
          Expanded(
            child: workoutEvents.when(
              data: (events) => const Center(
                child: Text('Escutando eventos de treino concluído...'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erro ao escutar eventos: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
