# Sistema de Comunicação Entre Features

Este diretório contém os mecanismos de comunicação entre features implementados no Ray Club App.

## Componentes Principais

### 1. Estado Compartilhado com `SharedAppState`

O `SharedAppState` é um estado global imutável que permite compartilhar dados entre features sem criar dependências diretas.

#### Principais Características:
- Estado imutável usando Freezed
- Persistência automática entre sessões
- Validação de entradas para garantir consistência
- Suporte para dados personalizados via `customData`

#### Como Usar:

```dart
// Para ler dados
final userName = ref.watch(sharedStateProvider).userName;

// Para modificar dados
ref.read(sharedStateProvider.notifier).updateUserInfo(
  userName: 'Novo Nome',
  isSubscriber: true,
);

// Para armazenar dados personalizados
ref.read(sharedStateProvider.notifier).setCustomData('chave', valor);

// Para recuperar dados personalizados
final valor = ref.read(sharedStateProvider.notifier).getCustomData('chave');
```

### 2. Sistema de Eventos com `AppEventBus`

O `AppEventBus` implementa um padrão publish-subscribe para comunicação assíncrona desacoplada entre features.

#### Principais Características:
- Tipagem forte com Freezed
- Suporte para diferentes tipos de eventos (auth, workout, challenge, etc.)
- Logging automático
- Tratamento de erros em listeners
- Prevenção de vazamentos de memória

#### Tipos de Eventos:
- `AuthEvent`: Eventos de autenticação (login, logout, etc.)
- `WorkoutEvent`: Eventos relacionados a treinos
- `ChallengeEvent`: Eventos relacionados a desafios
- `NutritionEvent`: Eventos relacionados a nutrição
- `BenefitsEvent`: Eventos relacionados a benefícios
- `ConnectivityEvent`: Eventos de conectividade
- `CustomEvent`: Eventos personalizados

#### Como Publicar Eventos:

```dart
// Publicar evento
ref.read(appEventBusProvider).publish(
  AppEvent.challenge(
    type: EventTypes.challengeJoined,
    challengeId: 'challenge-123',
    data: {'joinedAt': DateTime.now().toIso8601String()},
  ),
);
```

#### Como Escutar Eventos:

```dart
// Em um ViewModel
final challengeStream = ref.read(challengeEventsProvider(EventTypes.challengeCompleted)).stream;

// Usar o método listen do EventBus que trata erros internamente
final subscription = ref.read(appEventBusProvider).listen(
  challengeStream,
  (event) {
    // Reagir ao evento
  }
);

// Importante: cancelar a subscription para evitar vazamentos de memória
@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

## Boas Práticas

1. **Sempre cancele subscriptions**: Para evitar vazamentos de memória, cancele todas as subscriptions no método `dispose()`.

2. **Use as constantes de `EventTypes`**: Para evitar erros de digitação e padronizar os tipos de eventos.

3. **Valide dados antes de armazenar no estado compartilhado**: O validador integrado ajuda a garantir a consistência dos dados.

4. **Use tratamento de erros**: Sempre trate erros ao publicar ou consumir eventos para evitar falhas silenciosas.

5. **Documente eventos personalizados**: Se criar novos tipos de eventos, adicione constantes a `EventTypes` e documente seu uso.

## Exemplo Completo

Veja um exemplo completo de uso nos arquivos:
- `lib/core/examples/feature_communication_examples.dart`: Demonstra cenários de uso práticos

## Testes

Os seguintes testes garantem o funcionamento correto desses componentes:
- `lib/core/tests/shared_state_provider_test.dart`: Testes para o estado compartilhado
- `lib/core/tests/app_event_bus_test.dart`: Testes para o sistema de eventos 