# Documentação Técnica: Ray Club App

## 1. Visão Geral do Projeto

### 1.1 Introdução

O Ray Club App é uma aplicação mobile desenvolvida em Flutter que segue a arquitetura MVVM (Model-View-ViewModel) com Riverpod para gerenciamento de estado. O aplicativo permite o gerenciamento de nutrição, treinos e outros dados relacionados à saúde e bem-estar dos usuários.

A base de dados utilizada é o Supabase (PostgreSQL), aproveitando seus recursos de autenticação, armazenamento e banco de dados relacional.

### 1.2 Objetivos Técnicos

- Manter separação clara de responsabilidades seguindo MVVM
- Garantir tratamento robusto de erros em todas as camadas
- Implementar segurança e validação rigorosa de dados
- Oferecer persistência confiável e eficiente de dados
- Permitir operações offline com sincronização posterior
- Monitorar performance de operações críticas

## 2. Arquitetura do Sistema

### 2.1 Estrutura de Diretórios

O projeto segue uma organização por features, cada uma contendo:

```
lib/
├── core/                      # Componentes essenciais da aplicação
│   ├── components/            # Componentes base reutilizáveis
│   ├── config/                # Configurações da aplicação
│   ├── constants/             # Constantes da aplicação
│   ├── di/                    # Injeção de dependências
│   ├── errors/                # Sistema de tratamento de erro  
│   ├── events/                # Sistema de eventos para comunicação
│   ├── exceptions/            # Definições de exceções específicas
│   ├── localization/          # Internacionalização
│   ├── offline/               # Gerenciamento de estado offline
│   ├── providers/             # Providers globais
│   ├── router/                # Configuração de rotas com auto_route
│   ├── services/              # Serviços core
│   ├── tests/                 # Testes para componentes core
│   ├── theme/                 # Definições de tema e estilos
│   └── widgets/               # Widgets compartilhados
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
│   ├── nutrition/             # Feature de nutrição
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
│   ├── http_service.dart      # Cliente HTTP centralizado
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

### 2.2 Fluxo de Dados

O fluxo de dados segue o padrão MVVM com adaptações para o Riverpod:

1. **Model**: Define a estrutura dos dados e validações básicas
2. **Repository**: Responsável pela fonte de dados e operações CRUD
3. **ViewModel**: Gerencia estado e lógica de negócios
4. **View**: Apresenta a UI e captura interações do usuário

A comunicação entre camadas é unidirecional, garantindo previsibilidade:
- Views consomem estado dos ViewModels e disparam ações
- ViewModels processam ações e atualizam seu estado
- Repositories gerenciam acesso a dados locais e remotos

## 3. Sistema de Tratamento de Erros

### 3.1 Hierarquia de Exceções

Implementamos uma hierarquia unificada de exceções com base na classe `AppException`:

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
  
  @override
  String toString() => message;
}

// Exceções específicas por categoria
class NetworkException extends AppException { ... }
class AuthException extends AppException { ... }
class ValidationException extends AppException { ... }
class StorageException extends AppException { ... }
class NotificationException extends AppException { ... }
// ... outras exceções específicas
```

### 3.2 Classificador de Erros

O `ErrorClassifier` analisa exceções e as classifica em tipos específicos:

```dart
class ErrorClassifier {
  static AppException classifyError(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      return error;
    }
    
    // Análise heurística por tipo de erro
    final String errorString = error.toString().toLowerCase();
    
    if (_isNetworkError(errorString)) {
      return NetworkException(...);
    }
    
    // ... outras classificações
    
    return AppException(...); // Fallback
  }
  
  // Métodos auxiliares para reconhecimento de padrões
  static bool _isNetworkError(String errorString) { ... }
  static bool _isAuthError(String errorString) { ... }
  // ...
}
```

### 3.3 Manipulador Global de Erros

Implementamos um `ErrorHandler` global para captura e processamento de exceções:

```dart
class ErrorHandler {
  static RemoteLoggingService? _remoteLoggingService;
  
  // Configuração do serviço de logging
  static void setRemoteLoggingService(RemoteLoggingService service) {
    _remoteLoggingService = service;
  }
  
  // Tratamento centralizado de erros
  static void handleError(Object error, [StackTrace? stackTrace]) {
    stackTrace ??= StackTrace.current;
    final appError = ErrorClassifier.classifyError(error, stackTrace);
    
    // Log local do erro
    LogUtils.error(...);
    
    // Log remoto se disponível
    _remoteLoggingService?.logError(...);
  }
  
  // Mensagens amigáveis para o usuário
  static String getUserFriendlyMessage(AppException exception) { ... }
}
```

### 3.4 Observer de Providers Riverpod

Adicionalmente, implementamos um `AppProviderObserver` para capturar erros em providers:

```dart
class AppProviderObserver extends ProviderObserver {
  ProviderContainer? _container;
  
  void setContainer(ProviderContainer container) {
    _container = container;
  }
  
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final appError = ErrorClassifier.classifyError(error, stackTrace);
    
    // Implementação de logs e telemetria
    // ...
    
    // Prevenção contra recursão infinita
    if (error.toString().contains('remoteLoggingService')) {
      // Tratamento especial para evitar loops
    }
  }
}
```

### 3.5 Justificativa Técnica

Este sistema foi projetado para:
- Evitar duplicação de código no tratamento de erros
- Garantir logs consistentes em todos os pontos da aplicação
- Facilitar o diagnóstico de problemas em produção
- Apresentar mensagens amigáveis para o usuário final

## 4. Armazenamento Seguro de Dados

### 4.1 Serviço de Armazenamento Seguro

O `SecureStorageService` encapsula operações seguras de persistência:

```dart
class SecureStorageService implements StorageServiceInterface {
  late FlutterSecureStorage _secureStorage;
  final String _prefix = 'rayclub_';
  bool _initialized = false;
  
  // Inicialização com criptografia
  Future<void> initialize() async {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    
    // Validação e dados de teste em debug
    if (kDebugMode) {
      final testData = {'initialized': true, 'timestamp': DateTime.now().toIso8601String()};
      await writeObject('test_data_initialized', testData);
    }
    
    _initialized = true;
  }
  
  // Operações com validação de inicialização
  Future<void> writeString(String key, String value) async {
    _ensureInitialized();
    // Implementação com tratamento de erros
  }
  
  // Métodos para diferentes tipos de dados
  Future<String?> readString(String key) async { ... }
  Future<void> writeBool(String key, bool value) async { ... }
  Future<bool?> readBool(String key) async { ... }
  Future<void> writeObject(String key, Map<String, dynamic> value) async { ... }
  Future<Map<String, dynamic>?> readObject(String key) async { ... }
  
  // Operações auxiliares
  Future<bool> containsKey(String key) async { ... }
  Future<void> deleteValue(String key) async { ... }
  Future<void> deleteAll() async { ... }
  Future<Map<String, String>> readAll() async { ... }
  
  // Validação de estado
  void _ensureInitialized() {
    if (!_initialized) {
      throw SecureStorageException(
        message: 'Serviço de armazenamento seguro não inicializado',
        code: 'service_not_initialized',
      );
    }
  }
}
```

### 4.2 Provider de Serviço Seguro

A injeção e gerenciamento do ciclo de vida é feito via Riverpod:

```dart
// Definido em lib/core/providers/service_providers.dart
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final service = SecureStorageService();
  
  // Inicialização e disposição automática
  service.initialize();
  ref.onDispose(() => service.dispose());
  
  return service;
});
```

### 4.3 Justificativa da Implementação

- **Segurança**: Utiliza criptografia nativa de cada plataforma
- **Isolamento**: Prefixo de chaves para evitar colisões
- **Validação**: Verificação de inicialização antes de qualquer operação
- **Testabilidade**: Interface bem definida facilita mocks para testes

## 5. Serviço de Armazenamento de Arquivos

### 5.1 Interface de Abstração

Para permitir diferentes implementações e facilitar testes:

```dart
abstract class StorageService {
  String get currentBucket;
  bool get isInitialized;
  
  Future<void> initialize();
  Future<void> setBucket(StorageBucketType bucketType);
  void setAccessPolicy(StorageAccessType accessType);
  
  Future<String> uploadFile({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  });
  
  Future<File> downloadFile({
    required String remotePath,
    required String localPath,
  });
  
  Future<String> getPublicUrl(String path);
  Future<void> deleteFile(String path);
  
  Future<void> dispose();
}
```

### 5.2 Implementação com Supabase

A implementação concreta utiliza Supabase:

```dart
class SupabaseStorageService implements StorageService {
  final SupabaseClient _supabaseClient;
  final List<FileValidator> _validators = [];
  
  // Mapeamento configurável entre ambientes
  final Map<StorageBucketType, String> _bucketNames = {
    StorageBucketType.profilePictures: dotenv.env['BUCKET_PROFILE_PICTURES'] ?? 'profile_pictures',
    StorageBucketType.mealImages: dotenv.env['BUCKET_MEAL_IMAGES'] ?? 'meal_images',
    StorageBucketType.workoutImages: dotenv.env['BUCKET_WORKOUT_IMAGES'] ?? 'workout_images',
    StorageBucketType.challengeImages: dotenv.env['BUCKET_CHALLENGE_IMAGES'] ?? 'challenge_images',
    StorageBucketType.benefitImages: dotenv.env['BUCKET_BENEFIT_IMAGES'] ?? 'benefit_images',
    // ... outros buckets
  };
  
  // Inicialização com validadores padrão
  SupabaseStorageService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient {
    _validators.add(FileSizeValidator(maxSizeInBytes: 5 * 1024 * 1024));
    _validators.add(FileTypeValidator(allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf']));
  }
  
  // Implementação de upload com validação
  @override
  Future<String> uploadFile({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    _ensureInitialized();
    
    // Validação de arquivos antes do upload
    for (final validator in _validators) {
      await validator.validate(file);
    }
    
    // Segmentação por usuário em buckets privados
    String uploadPath = path;
    if (_currentAccessPolicy == StorageAccessType.private) {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        uploadPath = 'users/$userId/$path';
      }
    }
    
    // Upload e retorno de URL/path
    // ...
  }
  
  // Outras implementações...
}
```

### 5.3 Validadores de Arquivo

Implementamos validadores extensíveis:

```dart
abstract class FileValidator {
  Future<void> validate(File file);
}

class FileSizeValidator implements FileValidator {
  final int maxSizeInBytes;
  
  FileSizeValidator({required this.maxSizeInBytes});
  
  @override
  Future<void> validate(File file) async {
    final size = await file.length();
    if (size > maxSizeInBytes) {
      throw FileValidationException(
        message: 'Arquivo excede o tamanho máximo permitido',
        code: 'file_too_large',
      );
    }
  }
}

class FileTypeValidator implements FileValidator { ... }
```

### 5.4 Motivos para Esta Abordagem

- **Segurança**: Validação antes do upload previne arquivos maliciosos
- **Flexibilidade**: Configuração dinâmica por ambiente via variáveis
- **Isolamento**: Segmentação por usuário em buckets privados
- **Manutenibilidade**: Fácil adicionar novos tipos de buckets

## 6. Monitoramento de Performance

### 6.1 PerformanceMonitor

Criamos um sistema completo para monitorar operações críticas:

```dart
class PerformanceMonitor {
  static final Map<String, _Operation> _activeOperations = {};
  static final Map<String, List<int>> _operationHistory = {};
  static RemoteLoggingService? _remoteLoggingService;
  
  // Configuração global
  static void setRemoteLoggingService(RemoteLoggingService service) {
    _remoteLoggingService = service;
  }
  
  // API para monitoramento
  static String startOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final uniqueId = '${operationName}_${DateTime.now().millisecondsSinceEpoch}_${_activeOperations.length}';
    // Inicialização e registro da operação
    return uniqueId;
  }
  
  static void endOperation(String operationId, {bool success = true, String? error}) {
    // Cálculo de duração e registro de métricas
    // ...
    
    // Envio para telemetria remota
    _remoteLoggingService?.logMetric(
      metricName: 'operation_duration',
      value: duration.toDouble(),
      unit: 'ms',
      dimensions: {
        'operation': operation.name,
        'success': success.toString(),
        ...?operation.metadata,
      },
    );
  }
  
  // Wrappers para facilitar uso
  static Future<T> trackAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final operationId = startOperation(operationName, metadata: metadata);
    try {
      final result = await operation();
      endOperation(operationId, success: true);
      return result;
    } catch (e) {
      endOperation(operationId, success: false, error: e.toString());
      rethrow;
    }
  }
  
  static T track<T>(String operationName, T Function() operation, {Map<String, dynamic>? metadata}) { ... }
  
  // Estatísticas e análise
  static Map<String, Map<String, dynamic>> getStatistics() { ... }
}
```

### 6.2 Integração com Telemetria

Estendemos o `RemoteLoggingService` para incluir métricas:

```dart
class RemoteLoggingService {
  // ... implementação existente
  
  /// Loga uma métrica de desempenho no serviço remoto
  Future<void> logMetric({
    required String metricName,
    required double value,
    String unit = '',
    Map<String, String>? dimensions,
  }) async {
    if (!_initialized) return;
    
    try {
      // Preparar dados da métrica
      final metric = {
        'name': metricName,
        'value': value,
        'unit': unit,
        'timestamp': DateTime.now().toIso8601String(),
        'environment': dotenv.env['ENVIRONMENT'] ?? 'development',
        // Outros metadados contextuais
      };
      
      // Em ambiente de desenvolvimento, apenas logar localmente
      if (kDebugMode) {
        LogUtils.debug('Métrica: $metricName = $value $unit', ...);
        return;
      }
      
      // Enviar para o endpoint de métricas
      await _dio.post(_endpoint, data: jsonEncode(metric), ...);
    } catch (e) {
      // Falhar silenciosamente para não interromper fluxos principais
      LogUtils.warning('Falha ao enviar métrica para o serviço remoto', ...);
    }
  }
}
```

### 6.3 Aplicação Prática

Exemplo de uso no repositório de refeições:

```dart
// Em SupabaseMealRepository
@override
Future<String> uploadMealImage(String mealId, String localImagePath) async {
  return PerformanceMonitor.trackAsync('meal_image_upload', () async {
    try {
      // Implementação regular
      // ...
    } catch (e, stackTrace) {
      // Tratamento de erros
      // ...
    }
  }, metadata: {
    'mealId': mealId, 
    'fileSize': File(localImagePath).lengthSync()
  });
}
```

### 6.4 Justificativa da Abordagem

- **Diagnóstico**: Facilita identificação de operações lentas
- **Métricas**: Permite análise de tendências de performance
- **Baixo Acoplamento**: Implementação não-intrusiva via wrappers
- **Degradação Suave**: Falhas de telemetria não afetam funcionalidades

## 7. Suporte Offline

O aplicativo implementa suporte completo a operações offline com sincronização automática.

### 7.1 Cache Local com Hive

Utilizamos Hive para armazenamento local eficiente:

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
  
  Future<void> delete(String key) async {
    await _cache.delete(key);
  }
  
  Future<void> clear() async {
    await _cache.clear();
  }
}
```

### 7.2 Sistema de Filas para Operações

Implementamos um sistema de filas para operações que falham quando offline:

```dart
class OperationQueue {
  final List<PendingOperation> _pendingOperations = [];
  final CacheService _cacheService;
  static const String _queueKey = 'operation_queue';
  
  OperationQueue(this._cacheService);
  
  Future<void> initialize() async {
    final queue = _cacheService.get<List<dynamic>>(_queueKey);
    if (queue != null) {
      _pendingOperations.addAll(
        queue.map((data) => PendingOperation.fromJson(data))
      );
    }
  }
  
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
        LogUtils.warning('Falha ao processar operação em fila: ${operation.type}', error: e);
      }
    }
    
    _saveQueue();
  }
  
  Future<void> _saveQueue() async {
    await _cacheService.put(
      _queueKey, 
      _pendingOperations.map((op) => op.toJson()).toList()
    );
  }
}
```

### 7.3 Detecção de Conectividade

Monitoramento contínuo do estado de conectividade:

```dart
class ConnectivityService {
  final StreamController<ConnectivityStatus> _statusController = StreamController<ConnectivityStatus>.broadcast();
  
  Stream<ConnectivityStatus> get status => _statusController.stream;
  ConnectivityStatus _lastStatus = ConnectivityStatus.unknown;
  
  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((result) {
      final status = _getStatusFromResult(result);
      if (status != _lastStatus) {
        _lastStatus = status;
        _statusController.add(status);
      }
    });
    
    // Checar status inicial
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _lastStatus = _getStatusFromResult(result);
    _statusController.add(_lastStatus);
  }
  
  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.online;
      case ConnectivityResult.none:
        return ConnectivityStatus.offline;
      default:
        return ConnectivityStatus.unknown;
    }
  }
  
  void dispose() {
    _statusController.close();
  }
}

enum ConnectivityStatus {
  online,
  offline,
  unknown
}
```

### 7.4 UI para Comunicar Estado Offline

Widget de banner para informar o usuário sobre o status de conectividade:

```dart
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    
    if (connectivityStatus == ConnectivityStatus.offline) {
      return Container(
        color: Colors.red.shade800,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 8.0),
            const Text(
              'Você está offline. Algumas funcionalidades podem estar limitadas.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
```

### 7.5 Justificativa da Implementação

- **Experiência do Usuário**: Permite uso contínuo mesmo sem conexão
- **Resiliente a Falhas**: Operações são armazenadas e reexecutadas quando online
- **Transparência**: Comunicação clara sobre o status de conectividade
- **Eficiência**: Uso de Hive para armazenamento local de alto desempenho

## 8. Validação de Dados

### 8.1 Modelo Meal com Validação

Exemplo do modelo com documentação completa:

```dart
/// Representa uma refeição de usuário com informações nutricionais.
/// Este modelo é usado para armazenar e gerenciar dados de alimentação
/// como calorias, macronutrientes e metadados relacionados.
@freezed
class Meal with _$Meal {
  const factory Meal({
    /// Identificador único da refeição
    required String id,
    
    /// Nome da refeição (ex: "Café da manhã", "Almoço")
    required String name,
    
    /// Data e hora em que a refeição foi consumida
    required DateTime dateTime,
    
    /// Quantidade total de calorias (kcal)
    required int calories,
    
    /// Quantidade de proteínas em gramas
    required double proteins,
    
    /// Quantidade de carboidratos em gramas
    required double carbs,
    
    /// Quantidade de gorduras em gramas
    required double fats,
    
    /// Observações adicionais sobre a refeição
    String? notes,
    
    /// URL da imagem da refeição, quando disponível
    String? imageUrl,
    
    /// Indica se a refeição foi marcada como favorita
    @Default(false) bool isFavorite,
    
    /// Lista de tags para categorização (ex: "lowcarb", "vegetariano")
    @Default([]) List<String> tags,
  }) = _Meal;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  /// Cria uma refeição vazia com valores padrão
  /// Útil para inicializar formulários de criação de refeição
  factory Meal.empty() => Meal(
        id: '',
        name: '',
        dateTime: DateTime.now(),
        calories: 0,
        proteins: 0,
        carbs: 0,
        fats: 0,
      );
}
```

### 8.2 Validação no Repository

Implementação de validações no repositório:

```dart
@override
Future<Meal> saveMeal(Meal meal) async {
  try {
    // Validar valores numéricos
    if (meal.calories < 0) {
      throw ValidationException(
        message: 'Calorias não podem ser negativas',
        code: 'invalid_calories',
      );
    }
    
    if (meal.proteins < 0) {
      throw ValidationException(
        message: 'Proteínas não podem ser negativas',
        code: 'invalid_proteins',
      );
    }
    
    // Validações similares para outros campos
    
    // Garantir que user_id está definido como o usuário atual
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw AuthException(
        message: 'Usuário não autenticado',
        code: 'unauthenticated',
      );
    }
    
    // Implementação do save
    // ...
  } catch (e, stackTrace) {
    // Tratamento de erros
    // ...
  }
}

@override
Future<List<Meal>> getMealsByDateRange(DateTime startDate, DateTime endDate) async {
  try {
    // Validar que as datas estão em ordem correta
    if (startDate.isAfter(endDate)) {
      throw ValidationException(
        message: 'Data inicial não pode ser posterior à data final',
        code: 'invalid_date_range',
      );
    }
    
    // Implementação da consulta
    // ...
  } catch (e, stackTrace) {
    // Tratamento de erros
    // ...
  }
}
```

### 8.3 Motivações para Este Padrão de Validação

- **Defesa em Profundidade**: Validação em múltiplas camadas
- **Mensagens Específicas**: Erros claros sobre problemas específicos
- **Rastreabilidade**: Códigos de erro para diagnóstico
- **Prevenção de Inconsistência**: Garantia de integridade dos dados

## 9. Segurança SQL

### 9.1 Políticas de Acesso (RLS)

Implementamos segurança em nível de linha (RLS) para controle de acesso:

```sql
-- Habilitar RLS na tabela
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários comuns
-- Os usuários só podem ver e modificar suas próprias refeições
CREATE POLICY meals_select_policy ON meals
  FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY meals_insert_policy ON meals
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY meals_update_policy ON meals
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY meals_delete_policy ON meals
  FOR DELETE
  USING (user_id = auth.uid());

-- Políticas para administradores (via claims)
-- Administradores podem ver todas as refeições
CREATE POLICY meals_admin_select_policy ON meals
  FOR SELECT
  USING (
    (SELECT is_admin FROM users WHERE id = auth.uid())
  );
```

### 9.2 Funções SQL Seguras

Corrigimos a função para buscar refeições com validação adequada:

```sql
CREATE OR REPLACE FUNCTION get_meals_by_date_range(
  user_id_param UUID,
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE
)
RETURNS SETOF meals AS $$
DECLARE
  is_admin_user BOOLEAN;
BEGIN
  -- Verificar se o usuário é admin
  SELECT is_admin INTO is_admin_user FROM users WHERE id = auth.uid();
  
  -- Validar que o usuário tem permissão (é o próprio usuário ou é admin)
  IF user_id_param = auth.uid() OR is_admin_user = TRUE THEN
    RETURN QUERY
    SELECT *
    FROM meals
    WHERE user_id = user_id_param
      AND meal_time >= start_date
      AND meal_time <= end_date
    ORDER BY meal_time ASC;
  ELSE
    -- Se não for o próprio usuário ou admin, não retornar nenhum dado
    RAISE EXCEPTION 'Acesso não autorizado';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 9.3 Justificativa da Abordagem de Segurança

- **Defesa em Camadas**: Validação no app e no banco
- **Isolamento de Dados**: Usuários só acessam seus próprios registros
- **Privilégio Mínimo**: Funções com SECURITY DEFINER verificam permissões
- **Prevenção de Injeção SQL**: Consultas parametrizadas em todo código

## 10. Configuração e Inicialização

### 10.1 Arquivo Main

Configuração global de serviços:

```dart
void main() async {
  // Configurar tratamento de erros não capturados
  FlutterError.onError = (details) {
    ErrorHandler.handleError(details.exception, details.stack);
  };
  
  // Criar container de providers para acessar serviços na inicialização
  final container = ProviderContainer(
    observers: [appObserver],
  );
  
  // Configurar o observador de providers com o container
  appObserver.setContainer(container);
  
  // Configurar o serviço de log remoto para o ErrorHandler global
  ErrorHandler.setRemoteLoggingService(container.read(remoteLoggingServiceProvider));
  
  // Configurar o PerformanceMonitor para monitorar operações críticas
  PerformanceMonitor.setRemoteLoggingService(container.read(remoteLoggingServiceProvider));
  
  // Executar o app com o ProviderScope
  runApp(
    ProviderScope(
      parent: container,
      child: const RayClubApp(),
    ),
  );
}
```

### 10.2 Configuração de Ambiente

Utilizamos variáveis de ambiente para configuração entre ambientes:

```dart
// Exemplo de acesso a variáveis de ambiente
final apiUrl = dotenv.env['API_URL'] ?? 'https://api.default-environment.com';
final bucketName = dotenv.env['BUCKET_PROFILE_PICTURES'] ?? 'profile_pictures';
```

### 10.3 Justificativa para Esta Abordagem

- **Configuração Centralizada**: Inicialização de serviços em um único ponto
- **Flexibilidade**: Fácil alteração de configurações entre ambientes
- **Segurança**: Não há hardcoding de credenciais
- **Testabilidade**: Injeção de dependências facilita testes

## 11. Próximos Passos

De acordo com o checklist atualizado, as próximas melhorias incluem:

### 11.1 Testes para Componentes Compartilhados
- Implementar testes para navegação inferior (bottom navigation)
- Adicionar testes para componentes de cards e formulários 
- Verificar comportamento responsivo em diferentes tamanhos de tela

### 11.2 Otimização do Tamanho do App
- Otimizar assets e remover código não utilizado
- Configurar tree-shaking e code splitting
- Reduzir tamanho das imagens sem comprometer qualidade

### 11.3 Configuração de Variantes de Build
- Implementar configurações para ambientes development/staging/production
- Criar sistema de feature flags para lançamento gradual de funcionalidades
- Automatizar processo de build para diferentes ambientes via CI/CD

## 12. Guia de Contribuição

Para contribuir com o Ray Club App, siga estas diretrizes:

### 12.1 Padrões de Código
- Sempre siga o padrão MVVM com Riverpod
- Nunca use setState(), apenas ViewModels e Providers
- Todas as requisições HTTP devem usar Dio com tratamento de erros
- Valide variáveis de ambiente pelo .env (não coloque chaves no código)

### 12.2 Fluxo de Desenvolvimento
1. Crie uma branch a partir da `develop`
2. Implemente os testes antes ou junto com o código
3. Verifique cobertura de testes (meta: >70%)
4. Abra um Pull Request com descrição clara das mudanças

### 12.3 Documentação
- Documente classes e métodos relevantes
- Mantenha o README atualizado
- Atualize o checklist quando completar tarefas

## 13. Manutenção desta Documentação

### 13.1 Protocolo de Atualização

Este documento deve ser atualizado sempre que houver mudanças significativas no projeto. Como regra, deve-se atualizar a documentação:

1. **Após cada sprint**: Atualizações de funcionalidades concluídas
2. **Após mudanças arquiteturais**: Alterações em padrões ou estruturas existentes
3. **Ao adicionar novas dependências**: Documentar a finalidade e o uso
4. **Após correções críticas**: Documentar a natureza do problema e a solução

### 13.2 Responsabilidades

- Todo desenvolvedor que implementar uma mudança significativa é responsável por também atualizar a documentação correspondente
- O reviewer de Pull Requests deve verificar se a documentação foi devidamente atualizada
- Em caso de dúvida, prefira documentar mais detalhadamente

### 13.3 Script de Atualização Automática

Para facilitar a manutenção da documentação, use o script fornecido:

```bash
# Adicionar uma nova entrada no changelog
./scripts/update_docs.sh "Descrição da alteração realizada"
```

Este script:
- Adiciona automaticamente uma nova entrada no changelog com a data atual
- Usa seu nome de usuário do Git como autor
- Lembra você de atualizar as seções relevantes
- Sugere um comando para fazer commit das alterações

### 13.4 Changelog

Para facilitar o acompanhamento de mudanças na documentação, mantenha esta seção com as atualizações recentes:

| Data | Desenvolvedor | Descrição da Alteração |
|------|---------------|------------------------|
| 27/03/2025 | cunhamarcela | Implementação do ConnectivityBanner e ConnectivityBannerWrapper para indicação de status offline |
| 27/03/2025 | cunhamarcela | Implementação do sistema de cache estratégico para melhorar experiência offline |
| 26/03/2025 | cunhamarcela | Implementação de classe AppStrings para centralizar strings e preparar para internacionalização |
| 26/03/2025 | cunhamarcela | Otimização de renderização de listas e ScrollViews para melhor performance |
| 25/03/2025 | cunhamarcela | Migração completa da feature Profile para o padrão MVVM com Riverpod |
| 25/03/2025 | cunhamarcela | Remoção da feature Community do escopo do projeto |
| 25/03/2025 | cunhamarcela | Migração da feature Benefits para o padrão MVVM com Riverpod, incluindo sistema de expiração de cupons |
| 25/03/2025 | cunhamarcela | Migração da feature Workout para o padrão MVVM com Riverpod, incluindo modelos, repositórios, viewmodels e telas |
| 25/03/2025 | cunhamarcela | Implementação das telas de autenticação com design minimalista |
| 10/08/2023 | Equipe Inicial | Criação do documento |
| 15/08/2023 | Marcel Acunha | Implementação do sistema de tratamento de erros e atualizações na documentação |
| 17/08/2023 | Marcel Acunha | Adição do sistema de armazenamento seguro e monitoramento de performance |

---

Este documento será atualizado conforme o projeto evolui. Para dúvidas ou esclarecimentos, entre em contato com a equipe de desenvolvimento. 