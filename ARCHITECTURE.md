# Ray Club App - Arquitectura

## Padrão de Arquitetura MVVM

O Ray Club App segue o padrão Model-View-ViewModel (MVVM) com Riverpod para gerenciamento de estado. Esta arquitetura foi escolhida para proporcionar:

1. **Separação de responsabilidades**: UI, lógica de negócios e dados são claramente separados
2. **Testabilidade**: ViewModels e Models são facilmente testáveis independentemente da UI
3. **Reusabilidade**: Código reutilizável entre diferentes partes do aplicativo

## Estrutura de Pastas

```
lib/
├── core/                      # Componentes essenciais da aplicação
│   ├── components/            # Componentes base reutilizáveis
│   ├── config/                # Configurações da aplicação
│   ├── constants/             # Constantes da aplicação (cores, strings, etc.)
│   ├── di/                    # Injeção de dependências
│   ├── errors/                # Sistema unificado de tratamento de erros
│   ├── events/                # Sistema de eventos para comunicação entre features
│   ├── exceptions/            # Definições de exceções específicas 
│   ├── localization/          # Suporte a múltiplos idiomas
│   ├── offline/               # Gerenciamento de estado offline
│   ├── providers/             # Providers globais do Riverpod
│   ├── router/                # Configuração de rotas com auto_route
│   ├── services/              # Serviços core da aplicação
│   ├── tests/                 # Testes para componentes core
│   ├── theme/                 # Definições de tema e estilos
│   └── widgets/               # Widgets compartilhados entre features
│
├── db/                        # Configuração e acesso ao banco de dados
│
├── features/                  # Recursos da aplicação organizados por domínio
│   ├── app/                   # Configuração geral do aplicativo
│   ├── auth/                  # Feature de autenticação
│   ├── benefits/              # Feature de benefícios e cupons
│   ├── challenges/            # Feature de desafios
│   ├── home/                  # Feature da tela inicial
│   ├── intro/                 # Feature de introdução ao app
│   ├── nutrition/             # Feature de nutrição (modelo para outras features)
│   ├── profile/               # Feature de perfil do usuário
│   ├── progress/              # Feature de acompanhamento de progresso
│   └── workout/               # Feature de treinos
│       ├── models/            # Modelos de dados para a feature
│       ├── repositories/      # Repositórios para acesso a dados
│       ├── screens/           # Telas da feature
│       ├── viewmodels/        # ViewModels para gerenciar o estado da feature
│       └── widgets/           # Widgets específicos da feature
│
├── services/                  # Serviços globais da aplicação
│   ├── api_service.dart       # Serviço de API
│   ├── auth_service.dart      # Serviço de autenticação
│   ├── deep_link_service.dart # Serviço para manipulação de deep links
│   ├── http_service.dart      # Cliente HTTP centralizado com interceptors
│   ├── notification_service.dart # Serviço de notificações
│   ├── remote_logging_service.dart # Logging remoto
│   ├── secure_storage_service.dart # Armazenamento seguro
│   ├── storage_service.dart   # Interface de abstração para armazenamento
│   ├── supabase_service.dart  # Wrapper para serviços do Supabase
│   └── supabase_storage_service.dart # Implementação do storage com Supabase
│
├── shared/                    # Componentes compartilhados entre features
│   └── widgets/               # Widgets reutilizáveis
│
├── utils/                     # Utilitários globais
│   └── performance_monitor.dart # Monitoramento de performance
│
└── main.dart                  # Ponto de entrada da aplicação
```

## Estrutura de Testes

```
test/
├── core/                      # Testes para componentes core
├── features/                  # Testes para features individuais
│   ├── auth/                  # Testes para autenticação
│   ├── nutrition/             # Testes para nutrição
│   │   ├── viewmodels/        # Testes para viewmodels
│   │   └── nutrition_screen_test.dart # Testes para UI
│   └── [outras features]/     # Testes para outras features
├── integration/               # Testes de integração entre componentes
├── services/                  # Testes para serviços
├── utils/                     # Testes para utilitários
└── README.md                  # Documentação de testes
```

## Camadas da Arquitetura

### Model

- Representa os dados e lógica de negócios
- Classes imutáveis, definidas com `freezed`
- Responsável pela validação, transformação e manipulação de dados

Exemplo:
```dart
@freezed
class Meal with _$Meal {
  const factory Meal({
    required String id,
    required String name,
    required DateTime dateTime,
    required int calories,
    // ...
  }) = _Meal;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
}
```

### Repository

- Responsável por acessar fontes de dados (API, banco de dados, cache)
- Abstrai detalhes de implementação de fontes de dados
- Gerencia conversão entre dados brutos e modelos
- Lida com tratamento de erros específicos de fonte de dados

Exemplo:
```dart
class MealRepository {
  final SupabaseClient _client;
  
  MealRepository(this._client);
  
  Future<List<Meal>> getMeals({required String userId}) async {
    try {
      final response = await _client
        .from('meals')
        .select()
        .eq('user_id', userId);
        
      return response.map((data) => Meal.fromJson(data)).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to fetch meals');
    }
  }
  
  // ...
}
```

### ViewModel

- Gerencia o estado da UI e responde a interações do usuário
- Expõe estado através de providers Riverpod
- Coordena interações entre repositories e models
- Lida com tratamento de erros de nível de aplicação

Exemplo:
```dart
final mealViewModelProvider = StateNotifierProvider<MealViewModel, MealState>((ref) {
  return MealViewModel(ref.watch(mealRepositoryProvider));
});

class MealViewModel extends StateNotifier<MealState> {
  final MealRepository _repository;
  
  MealViewModel(this._repository) : super(const MealState());
  
  Future<void> loadMeals(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final meals = await _repository.getMeals(userId: userId);
      state = state.copyWith(meals: meals, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  // ...
}
```

### View

- Representa a UI (telas e widgets)
- Renderiza dados do ViewModel
- Envia eventos de interface do usuário para o ViewModel
- Não contém lógica de negócios

Exemplo:
```dart
class NutritionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealState = ref.watch(mealViewModelProvider);
    
    return Scaffold(
      // ...
      body: mealState.isLoading 
        ? const CircularProgressIndicator()
        : ListView.builder(
            itemCount: mealState.meals.length,
            itemBuilder: (context, index) => MealCard(
              meal: mealState.meals[index],
              onTap: () => ref.read(mealViewModelProvider.notifier).selectMeal(index),
            ),
          ),
      // ...
    );
  }
}
```

## Gerenciamento de Estado com Riverpod

- Providers são definidos globalmente para serviços e repositórios
- ViewModels são expostos como StateNotifierProviders
- Estados complexos utilizam Freezed para imutabilidade e copy-with

### Tipos de Providers Utilizados

- **Provider**: Para serviços e repositórios que não mudam de estado
- **StateProvider**: Para estados simples e primitivos
- **StateNotifierProvider**: Para estados complexos gerenciados por um StateNotifier
- **FutureProvider**: Para valores assíncronos que são carregados uma vez
- **StreamProvider**: Para fluxos de dados que mudam ao longo do tempo

## Comunicação Entre Features

O Ray Club App implementa dois mecanismos principais para comunicação entre features, permitindo que features interajam sem criar dependências diretas:

### 1. Estado Compartilhado via SharedAppState

O `SharedAppState` é um estado global imutável que pode ser acessado e modificado por qualquer feature:

```dart
// Definição do estado compartilhado
@freezed
class SharedAppState with _$SharedAppState {
  const factory SharedAppState({
    String? userId,
    String? userName,
    @Default(false) bool isSubscriber,
    String? currentChallengeId,
    String? currentWorkoutId,
    @Default(false) bool isOfflineMode,
    String? lastVisitedRoute,
    @Default({}) Map<String, dynamic> customData,
  }) = _SharedAppState;
}

// Provider global
final sharedStateProvider = StateNotifierProvider<SharedStateNotifier, SharedAppState>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SharedStateNotifier(sharedPreferences);
});
```

#### Principais Características:
- Estado persistente entre sessões via SharedPreferences
- Validação de entradas para garantir consistência
- Dados customizáveis via mapa `customData`
- Uso simplificado com Riverpod

#### Exemplo de Uso:
```dart
// Leitura do estado
final userName = ref.watch(sharedStateProvider).userName;

// Modificação do estado
ref.read(sharedStateProvider.notifier).updateUserInfo(
  userName: 'Novo Nome',
  isSubscriber: true,
);
```

### 2. Sistema de Eventos via AppEventBus

O `AppEventBus` implementa um padrão publish-subscribe para comunicação assíncrona entre features:

```dart
// Definição de tipos de eventos
@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.auth({
    required String type,
    String? userId,
    Map<String, dynamic>? data,
  }) = AuthEvent;
  
  const factory AppEvent.workout({...}) = WorkoutEvent;
  const factory AppEvent.challenge({...}) = ChallengeEvent;
  // outros tipos de eventos...
}

// Provider para o EventBus
final appEventBusProvider = Provider<AppEventBus>((ref) {
  final eventBus = AppEventBus();
  ref.onDispose(() => eventBus.dispose());
  return eventBus;
});
```

#### Principais Características:
- Tipagem forte com Freezed
- Filtros para tipos específicos de eventos
- Tratamento de erros em listeners
- Prevenção de memory leaks
- Mecanismo de log para depuração

#### Exemplo de Uso:
```dart
// Publicar evento
ref.read(appEventBusProvider).publish(
  AppEvent.challenge(
    type: EventTypes.challengeJoined,
    challengeId: 'challenge-123',
    data: {'joinedAt': DateTime.now().toIso8601String()},
  ),
);

// Escutar eventos em um ViewModel
final subscription = ref.read(appEventBusProvider).listen(
  ref.read(challengeEventsProvider(EventTypes.challengeCompleted)).stream,
  (event) {
    // Reagir ao evento
  }
);

// Importante: cancelar a subscription no dispose
@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

## Sistema de Tratamento de Erros

O app implementa um sistema unificado de tratamento de erros com os seguintes componentes:

### Hierarquia de Exceções

```dart
// Classe base para todas as exceções da aplicação
class AppException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;
  final String? code;
  
  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.code,
  });
}

// Exceções específicas para diferentes cenários
class NetworkException extends AppException { ... }
class AuthException extends AppException { ... }
class StorageException extends AppException { ... }
class ValidationException extends AppException { ... }
```

### ErrorClassifier

Um utilitário central que analisa e categoriza os erros:

```dart
class ErrorClassifier {
  static AppException classifyError(Object error, StackTrace stackTrace) {
    if (error is AppException) return error;
    
    // Análise heurística do erro
    final String errorString = error.toString();
    
    if (errorString.contains('connection') || errorString.contains('network')) {
      return NetworkException(...);
    }
    
    // Outras categorizações...
    
    return AppException(message: 'Erro desconhecido: $errorString');
  }
}
```

### AppProviderObserver

Middleware para capturar e tratar erros em providers:

```dart
class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final appError = ErrorClassifier.classifyError(error, stackTrace);
    
    // Logging centralizado e notificação ao usuário
    // ...
  }
}
```

## Sistema de Navegação e Roteamento

O app utiliza auto_route para gerenciamento de rotas typesafe:

```dart
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    // Auth routes
    AutoRoute(
      page: LoginRoute.page, 
      path: '/login',
      guards: [AnonymousGuard()],
    ),
    AutoRoute(
      page: RegisterRoute.page, 
      path: '/register',
      guards: [AnonymousGuard()],
    ),
    
    // Main app routes
    AutoRoute(
      page: HomeRoute.page,
      path: '/home',
      guards: [AuthGuard()],
      children: [
        AutoRoute(
          page: DashboardRoute.page,
          path: 'dashboard',
          initial: true,
        ),
        AutoRoute(
          page: WorkoutListRoute.page,
          path: 'workouts',
        ),
        // Outras rotas filhas...
      ],
    ),
    
    // Rotas específicas
    AutoRoute(
      page: ChallengeDetailsRoute.page,
      path: '/challenge/:id',
      guards: [AuthGuard()],
    ),
    
    // Rota inicial
    AutoRoute(
      page: IntroRoute.page,
      path: '/',
      initial: true,
    ),
    
    // Rotas de redirecionamento
    AutoRoute(
      page: SplashRoute.page,
      path: '/splash',
    ),
    
    // Rota 404
    AutoRoute(
      page: NotFoundRoute.page,
      path: '*',
    ),
  ];
}
```

### Guardas de Rota

Para proteção de rotas autenticadas:

```dart
class AuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    BuildContext context,
    NavigationResolver resolver,
  ) async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session != null) {
      return true;
    }
    
    // Redirecionar para login
    AutoRouter.of(context).replaceAll([const LoginRoute()]);
    return false;
  }
}
```

## Testes

Cada camada pode ser testada independentemente:

- **Models**: Testes unitários para validação e lógica de negócios
- **Repositories**: Testes de integração para acesso a dados
- **ViewModels**: Testes unitários com mocks para lógica de UI
- **Views**: Testes de widget para comportamento da UI
- **Core**: Testes para componentes essenciais (SharedAppState, AppEventBus, etc.)

```dart
// Exemplo de teste de ViewModel
void main() {
  late MockMealRepository repository;
  late MealViewModel viewModel;

  setUp(() {
    repository = MockMealRepository();
    viewModel = MealViewModel(repository);
  });

  test('loadMeals atualiza estado corretamente em caso de sucesso', () async {
    // Arrange
    final meals = [
      Meal(id: '1', name: 'Café da manhã', calories: 500, dateTime: DateTime.now()),
      Meal(id: '2', name: 'Almoço', calories: 800, dateTime: DateTime.now()),
    ];
    when(() => repository.getMeals(userId: any(named: 'userId')))
        .thenAnswer((_) async => meals);

    // Act
    await viewModel.loadMeals('user-123');

    // Assert
    expect(viewModel.state.isLoading, false);
    expect(viewModel.state.meals, meals);
    expect(viewModel.state.error, null);
  });
}
```

## Integração com Supabase

### Autenticação

A autenticação utiliza o serviço Supabase Auth para:
- Login com email/senha
- Login social com Google
- Persistência de sessão
- Recuperação de senha

### Banco de Dados

O banco de dados PostgreSQL do Supabase é utilizado com:
- Row Level Security para cada tabela
- Triggers para atualizações automáticas
- Integridade referencial com chaves estrangeiras

### Storage

O armazenamento de arquivos usa o Supabase Storage:
- Buckets configurados para diferentes tipos de conteúdo
- Políticas de acesso baseadas no usuário
- Upload otimizado com compressão de imagens

## Suporte Offline

O aplicativo implementa suporte completo a operações offline:

### Cache Local

Utilizando Hive para armazenamento local:

```dart
class CacheService {
  late Box<dynamic> _cache;
  
  Future<void> initialize() async {
    await Hive.initFlutter();
    _cache = await Hive.openBox('app_cache');
  }
  
  Future<void> put(String key, dynamic value) async {
    await _cache.put(key, value);
  }
  
  T? get<T>(String key) {
    return _cache.get(key) as T?;
  }
}
```

### Fila de Operações

Sistema para operações quando offline:

```dart
class OperationQueue {
  final List<PendingOperation> _pendingOperations = [];
  
  void addOperation(PendingOperation operation) {
    _pendingOperations.add(operation);
    _saveQueue();
  }
  
  Future<void> processQueue() async {
    if (_pendingOperations.isEmpty) return;
    
    for (final operation in List.from(_pendingOperations)) {
      try {
        await operation.execute();
        _pendingOperations.remove(operation);
      } catch (e) {
        // Falha ao processar, manter na fila
      }
    }
    
    _saveQueue();
  }
}
```

### Sincronização

Mecanismo para sincronização automática quando voltar online:

```dart
class ConnectivityService {
  final StreamController<bool> _connectivityStream = StreamController.broadcast();
  
  Stream<bool> get connectivityStream => _connectivityStream.stream;
  
  void initialize() {
    Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = result != ConnectivityResult.none;
      _connectivityStream.add(isConnected);
      
      if (isConnected) {
        // Processar fila quando voltar online
        getIt<OperationQueue>().processQueue();
      }
    });
  }
}
```

## Convenções de Código

1. **Nomenclatura**:
   - Classes: PascalCase (e.g., `MealRepository`)
   - Variáveis/métodos: camelCase (e.g., `getUserMeals()`)
   - Constantes: SNAKE_CASE (e.g., `MAX_MEAL_COUNT`)

2. **Documentação**:
   - Comentários para classes e métodos públicos
   - Docstrings para APIs externas

3. **Imports organizados**:
   - Dart/Flutter padrão
   - Pacotes externos
   - Imports do projeto

4. **Gestão de Estado**:
   - Evitar setState(), usar exclusivamente ViewModels e Providers
   - Estados complexos com classes Freezed
   - Estados simples com StateProvider

5. **Comunicação entre Features**:
   - Usar SharedAppState para estado compartilhado
   - Usar AppEventBus para comunicação assíncrona
   - Documentar eventos e dados compartilhados
   - Evitar acoplamento direto entre features

## Status da Implementação

### Features Implementadas (100%)
- Auth, Home, Nutrition, Workout, Profile, Challenges, Benefits, Intro, Progress
- Comunicação entre features (SharedAppState e AppEventBus)
- Sistema de expiração de cupons com verificação automática
- Sistema de fila para operações offline
- Widget de indicador de conectividade
- Extração de strings hardcoded para classe centralizada
- Cache estratégico para melhorar experiência offline
- Sistema de roteamento e guardas de rota com auto_route
- Integração completa com Deep Links para autenticação social

### Features Removidas do Escopo
- Community

## Próximos Passos

1. Implementar testes para componentes compartilhados
2. Reduzir tamanho do aplicativo através de otimização de assets
3. Configurar variantes de build para diferentes ambientes 