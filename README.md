Este repositório contém o código-fonte e documentação do Ray Club App, uma aplicação de fitness e bem-estar desenvolvida com Flutter e Supabase.

## 🚀 Status Atual

O projeto está em fase final de preparação para lançamento, com **90% das funcionalidades totalmente implementadas**. A arquitetura MVVM com Riverpod está completamente estabelecida, com toda a base de código organizada por features.

### Destaques das Implementações Recentes:
- ✅ Sistema avançado de tratamento de erros com hierarquia unificada de exceções
- ✅ Sistema completo de comunicação entre features via SharedAppState e AppEventBus
- ✅ Mecanismo robusto de suporte offline com sincronização automática
- ✅ Sistema de QR Code para validação de benefícios e cupons
- ✅ Autenticação social totalmente integrada (Google, Apple)
- ✅ Detecção automática de cupons expirados
- ✅ Performance otimizada para renderização de listas e gerenciamento de estado
- ✅ Atualização em tempo real do dashboard via eventos PostgreSQL

## Documentação

O projeto contém vários arquivos de documentação que cobrem diferentes aspectos:

- [Documentação Técnica](./TECHNICAL_DOCUMENTATION.md) - Detalhes da arquitetura, tratamento de erros e padrões técnicos
- [Arquitetura](./ARCHITECTURE.md) - Descrição da arquitetura MVVM com Riverpod
- [Checklist Atualizado](./UPDATED_CHECKLIST.md) - Status atual e próximos passos do desenvolvimento
- [Relatório de Conclusão](./COMPLETION_REPORT.md) - Melhorias implementadas e estado atual das features
- [Guia de Migração](./MIGRATION-GUIDE.md) - Status da migração e próximos passos
- [Contexto](./CONTEXT.md) - Visão geral do aplicativo e suas funcionalidades
- [Documentação Supabase](./docs/supabase_schema.sql) - Esquema do banco de dados Supabase
- [Comunicação Entre Features](./lib/core/errors/README.md) - Como usar o sistema de comunicação entre features
- [Guia de Resolução de Inconsistências](docs/RESOLUCAO_INCONSISTENCIAS.md)
- [Exemplo de Implementação MVVM](docs/MVVM_EXEMPLO.md)

## Estrutura do Projeto

O projeto segue a arquitetura MVVM (Model-View-ViewModel) com Riverpod para gerenciamento de estado, organizado por features.

### Principais Componentes

- **Features**: Módulos independentes da aplicação (auth, home, nutrition, workout, challenges, benefits, profile, intro, progress)
- **Core**: Componentes essenciais compartilhados (serviços, error handling, eventos, state management, router)
- **Services**: Serviços globais da aplicação (api, auth, http, storage, notifications)
- **Shared**: Widgets e utilidades reutilizáveis

### Estrutura de Diretórios

```
lib/
├── core/                      # Componentes essenciais da aplicação
│   ├── components/            # Componentes base reutilizáveis
│   ├── config/                # Configurações da aplicação
│   ├── constants/             # Constantes da aplicação
│   ├── di/                    # Injeção de dependências
│   ├── errors/                # Sistema unificado de tratamento de erros
│   ├── events/                # Sistema de eventos para comunicação
│   ├── exceptions/            # Definições de exceções específicas
│   ├── localization/          # Suporte a múltiplos idiomas
│   ├── offline/               # Gerenciamento de estado offline
│   ├── providers/             # Providers globais do Riverpod
│   ├── router/                # Configuração de rotas com auto_route
│   ├── services/              # Serviços core da aplicação
│   ├── tests/                 # Testes para componentes core
│   ├── theme/                 # Definições de tema e estilos
│   └── widgets/               # Widgets compartilhados
│
├── features/                  # Features organizadas por domínio
│   ├── app/                   # Configuração geral do aplicativo
│   ├── auth/                  # Autenticação e login
│   ├── benefits/              # Cupons e benefícios
│   ├── challenges/            # Sistema de desafios
│   ├── home/                  # Tela inicial
│   ├── intro/                 # Introdução ao app
│   ├── nutrition/             # Nutrição e refeições
│   ├── profile/               # Perfil de usuário
│   ├── progress/              # Acompanhamento de progresso
│   └── workout/               # Sistema de treinos
│
├── services/                  # Serviços globais da aplicação
├── shared/                    # Componentes compartilhados
├── utils/                     # Utilitários globais
├── db/                        # Acesso ao banco de dados
└── main.dart                  # Ponto de entrada da aplicação
```

## Sistemas Avançados Implementados

### 1. Sistema de Tratamento de Erros

Um sistema unificado para tratamento de exceções que inclui:
- Hierarquia de exceções baseada em `AppException`
- `ErrorClassifier` para categorização automática de erros
- Middleware `AppProviderObserver` para capturar erros em providers
- Sistema de validação de formulários (`FormValidator`)
- Sanitização automática de dados sensíveis nos logs

### 2. Comunicação Entre Features

Dois mecanismos principais para comunicação desacoplada entre features:

#### SharedAppState
Estado global imutável persistente entre sessões:
```dart
final sharedStateProvider = StateNotifierProvider<SharedStateNotifier, SharedAppState>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SharedStateNotifier(sharedPreferences);
});

// Uso
final userName = ref.watch(sharedStateProvider).userName;

// Atualização
ref.read(sharedStateProvider.notifier).updateUserInfo(
  userName: 'Novo Nome',
  isSubscriber: true,
);
```

#### AppEventBus
Sistema publish-subscribe para comunicação assíncrona:
```dart
// Publicar evento
ref.read(appEventBusProvider).publish(
  AppEvent.challenge(
    type: EventTypes.challengeJoined,
    challengeId: 'challenge-123',
  ),
);

// Escutar eventos
final subscription = ref.read(appEventBusProvider).listen(
  ref.read(challengeEventsProvider(EventTypes.challengeCompleted)).stream,
  (event) {
    // Reagir ao evento
  }
);
```

### 3. Suporte Offline Robusto

Sistema completo para operações quando sem conectividade:
- Cache local com Hive para dados frequentemente acessados
- Fila de operações para sincronização quando voltar online
- Indicador visual de estado de conectividade
- Detecção automática de mudanças na conectividade
- Sincronização em background

### 4. Sistema de Benefícios Aprimorado

Melhorias no sistema de cupons e benefícios:
- Validação via QR Code
- Detecção automática de cupons expirados
- Histórico de utilização
- Sistema de reativação para administradores

## Testes

O projeto implementa uma estratégia abrangente de testes seguindo a pirâmide de testes:

- **Testes Unitários**: Para Models, ViewModels e componentes core
- **Testes de Integração**: Para workflows entre componentes
- **Testes de Widget**: Para componentes de UI

### Progresso de Testes

- Core: 100% testado (AppException, ErrorHandler, SharedStateProvider, AppEventBus, StorageService)
- ViewModels: 100% testado (Auth, Workout, Profile, Challenge, Nutrition, Meal, Benefit)
- Repositories: 100% testado
- UI: 75% testado (fluxo de autenticação concluído)

Para contribuir com testes ou entender a abordagem de testes, consulte o [Guia de Testes](./docs/TESTING_GUIDE.md).

## Métricas e Telemetria

O aplicativo implementa sistemas avançados para monitoramento:
- Rastreamento de desempenho para operações críticas
- Métricas de tempo para upload/download
- Monitoramento de uso de memória e disco
- Analytics para eventos chave e funis de conversão

## Status Atual

Todas as features principais estão implementadas seguindo o padrão MVVM, com integração total ao Supabase:

- **Features Completas**: Auth, Home, Workout, Nutrition, Profile, Challenges, Benefits, Intro, Progress
- **Migração de Código**: 100% do código migrado para a nova arquitetura
- **Sistema Offline**: 100% implementado com cache estratégico e sincronização
- **Comunicação Entre Features**: 100% implementado e documentado
- **UI/UX**: Melhorias na experiência do usuário, animações e transições

### Progresso nos testes:
- Testes Unitários para componentes Core: 100% concluído
- Testes de ViewModels: 100% concluído 
- Testes de UI: 75% concluído (pendente componentes compartilhados)

**Nota Importante**: A feature Community foi removida do escopo do projeto.

## Próximos Passos

1. Implementar testes para componentes compartilhados
2. Reduzir tamanho do aplicativo através de otimização de assets
3. Configurar variantes de build para diferentes ambientes
4. Finalizar preparativos para lançamento nas lojas

## Configuração de Autenticação OAuth

Para configurar corretamente a autenticação OAuth com Google, siga estas instruções:

### 1. Configuração Supabase

No projeto Supabase:
- Adicione os seguintes URLs de redirecionamento:
  - `rayclub://login-callback/` (para Android/iOS)
  - `https://rayclub.vercel.app/auth/callback` (para Web)
  - `http://localhost:3000/auth/callback` (para desenvolvimento local)
- Em "Authentication > Settings > URL Configuration":
  - Site URL: `https://rayclub.vercel.app`
  - Redirect URLs: adicionar todos os URLs listados acima
  - Desmarque "Dangerously enable new browsers sessions outside of an iframe"

### 2. Configuração Google Cloud Platform (GCP)

No console do Google Cloud Platform:
- Adicione os URLs de redirecionamento autorizados:
  - `https://[SEU-PROJETO].supabase.co/auth/v1/callback`
- Adicione as origens JavaScript autorizadas:
  - `https://[SEU-PROJETO].supabase.co`
  - `https://rayclub.vercel.app`

### 3. Configuração Android

No arquivo `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="rayclub" android:host="login-callback" />
</intent-filter>
```

### 4. Configuração iOS

No arquivo `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>rayclub</string>
    </array>
  </dict>
</array>
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### 5. Diagnóstico

O aplicativo inclui ferramentas de diagnóstico para depurar problemas de autenticação:
- Verifique os logs do console com o prefixo 🔍 para informações detalhadas
- No modo de debug, a tela de login executa `AuthDebugUtils.printAuthDebugInfo()`
- Execute `DeepLinkService.printDeepLinkInfo()` para diagnóstico de deep linking

### 6. Fluxo de Autenticação

O fluxo PKCE é utilizado para autenticação segura:
1. A aplicação inicia o login com `signInWithGoogle()`
2. O navegador é aberto para autenticação
3. Após login bem-sucedido, o usuário é redirecionado via deep link
4. `DeepLinkService` processa o retorno e finaliza a autenticação

Para mais detalhes técnicos, consulte os arquivos:
- `lib/features/auth/repositories/auth_repository.dart`
- `lib/services/deep_link_service.dart`
- `lib/features/auth/viewmodels/auth_view_model.dart`

## Arquitetura MVVM

A arquitetura MVVM (Model-View-ViewModel) separa as responsabilidades em:

- **Model**: Representa os dados e regras de negócio
- **View**: Interface de usuário (Widgets e Screens)
- **ViewModel**: Intermedia a comunicação entre a View e o Model, gerencia o estado

## Dependências Principais

- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod): Gerenciamento de estado
- [freezed](https://pub.dev/packages/freezed): Geração de código para classes imutáveis
- [auto_route](https://pub.dev/packages/auto_route): Navegação
- [supabase](https://pub.dev/packages/supabase_flutter): Banco de dados e autenticação

## Migração de Banco de Dados

O projeto utiliza o [Supabase](https://supabase.io/) como backend. As migrações de banco de dados estão definidas no diretório `sql/`.

## Executando o Projeto

1. Clone o repositório
2. Instale as dependências:
```bash
flutter pub get
```
3. Execute os geradores de código:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
4. Execute o app:
```bash
flutter run
```

## Guia de Contribuição

1. Familiarize-se com a [Resolução de Inconsistências](docs/RESOLUCAO_INCONSISTENCIAS.md)
2. Siga o [Exemplo de Implementação MVVM](docs/MVVM_EXEMPLO.md) para novas features
3. Criar testes unitários para ViewModels e Repositories
4. Utilize HookConsumerWidget para as telas
5. Faça o tratamento adequado de erros e estados de carregamento
