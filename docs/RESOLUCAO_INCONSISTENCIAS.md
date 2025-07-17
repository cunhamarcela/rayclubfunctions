# Guia de Resolução de Inconsistências - Ray Club App

Este documento fornece um guia passo a passo para resolver inconsistências na estrutura de código do aplicativo Ray Club, especialmente em relação à implementação da arquitetura MVVM e ao uso do banco de dados Supabase.

## Sumário

1. [Introdução](#introdução)
2. [Problemas Identificados](#problemas-identificados)
3. [Padrões de Código](#padrões-de-código)
4. [Plano de Resolução](#plano-de-resolução)
5. [Migração para Viewmodels](#migração-para-viewmodels)
6. [Tratamento de Erros](#tratamento-de-erros)
7. [Gestão de Estado](#gestão-de-estado)
8. [Testes](#testes)
9. [Checklist de Implementação](#checklist-de-implementação)

## Introdução

O projeto Ray Club foi desenvolvido com a intenção de seguir a arquitetura MVVM (Model-View-ViewModel), mas durante a implementação várias inconsistências surgiram que afetam a manutenção, legibilidade e escalabilidade do código.

Este guia tem como objetivo padronizar a implementação do MVVM em todas as telas do aplicativo, garantindo uma melhor organização do código e facilitando a implementação de novas funcionalidades.

## Problemas Identificados

### Problemas Estruturais

1. **Uso inconsistente do padrão MVVM**:
   - Algumas telas usam `setState()` em vez de ViewModels.
   - Mistura de gerenciamento de estado direto na UI.

2. **Force unwrapping de variáveis opcionais**:
   - Uso excessivo de `!` para acessar valores opcionais sem verificação adequada.

3. **Tratamento inadequado de erros**:
   - Falta de tratamento estruturado para erros no banco de dados.
   - Ausência de feedback adequado ao usuário.

4. **Inconsistência na nomeação**:
   - Diversos padrões de nomeação em diferentes partes do código.

5. **Problemas de navegação**:
   - Uso inconsistente do pacote auto_route.

### Problemas no Acesso a Dados

1. **Uso inconsistente do Supabase**:
   - Acesso direto ao Supabase em alguns ViewModels, enquanto outros usam repositórios.
   - Falta de verificação da existência de tabelas antes de operações.

2. **Falta de encapsulamento**:
   - Regras de negócio misturadas com acesso a dados.

3. **Falta de tipos bem definidos**:
   - Uso excessivo de `dynamic` e `Map<String, dynamic>`.

## Padrões de Código

Para garantir consistência, seguiremos estes padrões:

### Estrutura de Pastas

```
lib/
  ├── core/
  │   ├── config/
  │   ├── errors/
  │   ├── localization/
  │   ├── navigation/
  │   ├── theme/
  │   ├── utils/
  │   └── widgets/
  │
  ├── features/
  │   ├── feature_name/
  │   │   ├── models/
  │   │   ├── repositories/
  │   │   ├── screens/
  │   │   └── viewmodels/
  │   └── ...
  │
  └── main.dart
```

### Convenções de Nomenclatura

- **Arquivos**: snake_case (ex: `user_profile_screen.dart`)
- **Classes**: PascalCase (ex: `UserProfileScreen`)
- **Variáveis e Métodos**: camelCase (ex: `getUserProfile()`)
- **Constantes**: SCREAMING_SNAKE_CASE (ex: `DEFAULT_TIMEOUT`)
- **Enums**: PascalCase para o tipo, PascalCase para valores (ex: `enum UserRole { Admin, Regular, Guest }`)

### Padronização de ViewModels

Todos os ViewModels devem:
1. Estender `StateNotifier<T>` onde T é um estado Freezed
2. Ser expostos via `StateNotifierProvider`
3. Conter apenas a lógica de negócios, delegando o acesso a dados para repositórios
4. Seguir a nomenclatura `NomeFeatureViewModel`

### Padronização de Estados

Todos os estados devem:
1. Ser implementados usando o package Freezed
2. Incluir estados de carregamento, erro e sucesso
3. Seguir a nomenclatura `NomeFeatureState`

## Plano de Resolução

### Fase 1: Refatoração de Estrutura e Modelos

1. Migrar todos os modelos para usar Freezed
2. Criar estados Freezed para cada feature
3. Padronizar as estruturas de pastas

### Fase 2: Implementação de Repositórios

1. Criar interfaces de repositório para cada feature
2. Implementar repositórios concretos para Supabase
3. Adicionar verificações de tabelas e tratamento de erros

### Fase 3: Migração para ViewModels

1. Criar ViewModels para cada tela seguindo o padrão
2. Remover `setState()` e gerenciamento de estado direto das telas
3. Implementar providers para todos os ViewModels

### Fase 4: Refatoração da UI

1. Converter StatefulWidgets para ConsumerWidgets quando possível
2. Implementar tratamento adequado de loading e erros em todas as telas
3. Padronizar widgets reutilizáveis

### Fase 5: Testes e Documentação

1. Adicionar testes para ViewModels e Repositórios
2. Documentar todas as classes principais
3. Criar exemplos de uso para novas implementações

## Migração para Viewmodels

### Exemplo de Refatoração: De StatefulWidget para ViewModel

#### Antes:

```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String selectedLanguage = 'pt_BR';
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final client = Supabase.instance.client;
      final response = await client.from('user_settings').select().single();
      
      setState(() {
        isDarkMode = response['dark_mode'] ?? false;
        selectedLanguage = response['language'] ?? 'pt_BR';
      });
    } catch (e) {
      // Tratamento de erro inadequado
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  // Resto da implementação...
}
```

#### Depois:

```dart
// Estado (settings_state.dart)
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isDarkMode,
    @Default('pt_BR') String selectedLanguage,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SettingsState;
}

// Repositório (settings_repository.dart)
abstract class SettingsRepository {
  Future<Map<String, dynamic>> getSettings();
  Future<void> updateSettings({bool? isDarkMode, String? language});
}

// ViewModel (settings_view_model.dart)
class SettingsViewModel extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;
  
  SettingsViewModel(this._repository) : super(const SettingsState());
  
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final settings = await _repository.getSettings();
      state = state.copyWith(
        isDarkMode: settings['dark_mode'] ?? false,
        selectedLanguage: settings['language'] ?? 'pt_BR',
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler();
      final message = errorHandler.getUserFriendlyMessage(e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
      
      errorHandler.handle(e, stackTrace);
    }
  }
  
  // Outros métodos do ViewModel...
}

// Tela (settings_screen.dart)
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    
    useEffect(() {
      ref.read(settingsViewModelProvider.notifier).loadSettings();
      return null;
    }, const []);
    
    if (settingsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (settingsState.errorMessage != null) {
      return Center(
        child: AppErrorWidget(
          message: settingsState.errorMessage!,
          onRetry: () => ref.read(settingsViewModelProvider.notifier).loadSettings(),
        ),
      );
    }
    
    // Implementação da UI usando settingsState...
  }
}
```

## Tratamento de Erros

Para padronizar o tratamento de erros, criamos classes específicas:

1. **AppException**: Classe base para exceções do aplicativo
2. **ErrorHandler**: Centraliza o tratamento de erros
3. **ErrorObserver**: Observa erros em providers Riverpod

### Exemplo de uso do ErrorHandler:

```dart
try {
  // Código que pode lançar erro
} catch (e, stackTrace) {
  final errorHandler = ref.read(errorHandlerProvider);
  errorHandler.handle(e, stackTrace); 
  
  // Atualizar estado com erro
  state = state.copyWith(
    isLoading: false,
    errorMessage: errorHandler.getUserFriendlyMessage(e),
  );
}
```

## Gestão de Estado

Para gerenciar o estado do aplicativo, usamos Riverpod com StateNotifier:

```dart
// Definir o provider
final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsViewModel(repository);
});

// Usar em ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    
    // Uso do state e viewModel...
  }
}
```

## Testes

Para garantir a qualidade do código, adicione testes para cada camada:

1. **Testes de ViewModel**: Verifique se o estado é atualizado corretamente
2. **Testes de Repositório**: Verifique se a comunicação com o Supabase funciona conforme esperado
3. **Testes de Widget**: Verifique se a UI reflete corretamente o estado

## Checklist de Implementação

Use esta checklist para verificar se cada tela está adequadamente refatorada:

- [ ] Criação de modelo Freezed para a entidade
- [ ] Criação de estado Freezed para a feature
- [ ] Criação de interface de repositório
- [ ] Implementação do repositório para Supabase
- [ ] Implementação do ViewModel usando StateNotifier
- [ ] Configuração do provider para o ViewModel
- [ ] Refatoração da tela para usar o ViewModel
- [ ] Implementação de tratamento de loading e erros
- [ ] Adição de testes para o ViewModel
- [ ] Adição de testes para o repositório
- [ ] Verificação da consistência de nomenclatura

### Passos para Aplicar no Projeto

1. Execute o comando para instalar dependências necessárias:
   ```
   flutter pub add flutter_riverpod freezed_annotation json_annotation
   flutter pub add --dev build_runner freezed json_serializable
   ```

2. Para cada feature, crie os arquivos necessários seguindo a estrutura indicada

3. Após criar ou modificar modelos Freezed, execute:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Refatore cada tela, começando pelas mais simples e avançando para as mais complexas

5. Adicione testes para validar a refatoração

---

**Observação**: Este documento será atualizado conforme a refatoração avança. Recomenda-se revisá-lo periodicamente para garantir que a implementação siga as diretrizes aqui estabelecidas. 