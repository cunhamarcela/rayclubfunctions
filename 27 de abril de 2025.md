# Ray Club App - Plano de Correção e Implementação

**Data:** 27 de abril de 2025

## Índice
1. [Visão Geral](#visão-geral)
2. [Análise de Problemas](#análise-de-problemas)
3. [Plano de Correção por Fases](#plano-de-correção-por-fases)
4. [Métricas de Sucesso](#métricas-de-sucesso)
5. [Cronograma](#cronograma)

## Visão Geral

Este documento apresenta um plano detalhado para correção das inconsistências e implementação das funcionalidades faltantes no Ray Club App. Com base na análise realizada em 26 de abril de 2025, identificamos diversos problemas que necessitam de atenção imediata para garantir que o aplicativo atenda às expectativas dos usuários e mantenha a integridade dos dados.

O plano está organizado em fases sequenciais, priorizando a infraestrutura básica, seguida pela implementação das funcionalidades principais e, por fim, refinamentos e otimizações.

## Análise de Problemas

### 1. Problemas Gerais de Arquitetura

1. **Simulação vs. Realidade**:
   - Repositórios "mock" em uso extensivo no lugar de implementações reais
   - Dados simulados sem persistência ou sincronização com backend

2. **Conexão Supabase Incompleta**:
   - SDK configurado mas pouco utilizado para persistência real
   - Tabelas e SQL criados mas não totalmente integrados

3. **Gerenciamento de Estado Inconsistente**:
   - Alguns ViewModels funcionam corretamente com Riverpod
   - Outros mantêm estado apenas localmente, ignorando o padrão MVVM

4. **Navegação Fragmentada**:
   - Rotas definidas mas não implementadas
   - Parâmetros de rota às vezes inválidos

### 2. Problemas Específicos por Tela

#### 2.1 Tela de Configurações
- Persistência local em vez de sincronizada com Supabase
- Botões de navegação quebrados ou incompletos
- Implementações parciais (idioma, validação de BD)

#### 2.2 Tela de Perfil
- Dados estáticos sem conexão com atividade real
- Metas não funcionais sem persistência
- Sistema de avatar limitado

#### 2.3 Tela de Progresso/Dashboard
- Dados fictícios para água, treinos e calendário
- Gráficos com dados estáticos
- Calendário não funcional

#### 2.4 Tela de Benefícios
- Dados mockados de cupons e benefícios
- Cupons e QR codes não funcionais
- Sistema de resgate não implementado

#### 2.5 Tela de Ajuda e Tutoriais
- FAQs hardcoded
- Tutoriais não implementados
- Formulário de contato inativo

#### 2.6 Social e Grupos
- Funcionalidade social limitada
- Grupos não funcionais
- Comunicação entre usuários inexistente

#### 2.7 Desafios e Progresso
- Check-ins simulados
- Ranking estático
- Progresso não persistente
- **✓ CORRIGIDO:** Divergência entre implementação do repositório e modelo de Desafio para upload de imagens

## Plano de Correção por Fases

### Fase 1: Infraestrutura e Fundação (Prioridade: Alta)

#### 1.1 Integração Completa com Supabase
- **Objetivo**: Garantir que todos os dados sejam persistidos corretamente no Supabase
- **Tarefas**:
  - Implementar `SupabaseProfileRepository` para substituir versões mock
  - Implementar `SupabaseBenefitRepository` para gerenciar cupons e benefícios
  - Implementar `SupabaseHelpRepository` para FAQs e conteúdo de ajuda
  - Implementar repositórios reais para todas as features que usam dados mockados
  - Criar/atualizar triggers no banco de dados para atualização de rankings e progresso
  - Implementar sistema de cache para funcionamento offline
  - **✓ IMPLEMENTADO:** Adicionar campo `localImagePath` ao modelo Challenge para suportar corretamente o upload de imagens no SupabaseChallengeRepository

**Exemplo de implementação para SupabaseProfileRepository**:
```dart
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao carregar perfil do usuário',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _supabase
          .from('user_profiles')
          .upsert(profile.toJson());
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar perfil do usuário',
        originalError: e,
      );
    }
  }

  // Implementar demais métodos
}
```

**Implementação do campo localImagePath no Challenge model**:
```dart
@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    required String description,
    String? imageUrl,
    // Campo adicionado para suportar upload de imagens
    String? localImagePath,
    required DateTime startDate,
    required DateTime endDate,
    @Default('normal') String type,
    required int points,
    // ...outros campos
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
}
```

#### 1.2 Correção do Sistema de Navegação
- **Objetivo**: Garantir que todas as rotas funcionem corretamente
- **Tarefas**:
  - Revisar e corrigir todas as definições de rotas em `app_router.dart`
  - Implementar telas faltantes para rotas definidas
  - Corrigir o sistema de validação de parâmetros em todas as rotas
  - Implementar guards de autenticação consistentes

**Exemplo de correção para rota de Alterar Senha**:
```dart
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  final ProviderRef _ref;

  AppRouter(this._ref);

  @override
  List<AutoRoute> get routes => [
        // Rotas existentes...
        
        AutoRoute(
          path: AppRoutes.changePassword,
          page: ChangePasswordRoute.page,
          guards: [LayeredAuthGuard(_ref)],
        ),
        
        // Outras rotas...
  ];
}
```

#### 1.3 Padronização do Gerenciamento de Estado
- **Objetivo**: Garantir que todo o app siga o padrão MVVM com Riverpod
- **Tarefas**:
  - Auditar todos os ViewModels para verificar conformidade com o padrão
  - Refatorar componentes que usam setState para usar ViewModels
  - Padronizar a estrutura de estados em todos os ViewModels usando Freezed
  - Implementar providers para injeção de dependências de forma consistente

**Exemplo de implementação padrão para ViewModel**:
```dart
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _SettingsStateInitial;
  const factory SettingsState.loading() = _SettingsStateLoading;
  const factory SettingsState.loaded({
    required ThemeMode themeMode,
    required String language,
    required bool notificationsEnabled,
  }) = _SettingsStateLoaded;
  const factory SettingsState.error(String message) = _SettingsStateError;
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;
  final AuthService _authService;

  SettingsViewModel(this._repository, this._authService) 
      : super(const SettingsState.initial());

  Future<void> loadSettings() async {
    state = const SettingsState.loading();
    
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = const SettingsState.error('Usuário não autenticado');
        return;
      }
      
      final settings = await _repository.getUserSettings(userId);
      
      state = SettingsState.loaded(
        themeMode: settings.themeMode,
        language: settings.language,
        notificationsEnabled: settings.notificationsEnabled,
      );
    } catch (e) {
      state = SettingsState.error(e.toString());
    }
  }

  // Outros métodos...
}
```

### Fase 2: Implementação de Funcionalidades Essenciais (Prioridade: Alta)

#### 2.1 Sistema de Perfil Completo
- **Objetivo**: Implementar funcionalidade completa de perfil de usuário
- **Tarefas**:
  - Implementar upload e gerenciamento de fotos de perfil
  - Implementar sistema de estatísticas reais (treinos, desafios, dias ativos)
  - Desenvolver sistema persistente de metas com acompanhamento
  - Implementar tela de edição de perfil funcional
  - Implementar tela de alteração de senha

**Exemplo para Upload de Foto**:
```dart
class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final StorageService _storageService;

  ProfileViewModel(this._repository, this._storageService) 
      : super(const ProfileState.initial());

  Future<void> uploadProfilePhoto(File photo) async {
    state = const ProfileState.loading();
    
    try {
      final userId = _authService.currentUser!.id;
      
      // Upload da foto para o storage
      final photoUrl = await _storageService.uploadProfilePhoto(
        userId: userId,
        photoFile: photo,
      );
      
      // Atualizar perfil com nova URL
      final currentProfile = await _repository.getUserProfile(userId);
      final updatedProfile = currentProfile.copyWith(
        photoUrl: photoUrl,
      );
      
      await _repository.updateUserProfile(updatedProfile);
      
      // Atualizar estado
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e) {
      state = ProfileState.error(e.toString());
    }
  }

  // Outros métodos...
}
```

#### 2.2 Dashboard e Progresso Funcional
- **Objetivo**: Implementar sistema real de acompanhamento de progresso
- **Tarefas**:
  - Desenvolver sistema de rastreamento de água persistente
  - Implementar gráficos baseados em dados reais do usuário
  - Criar calendário funcional que reflita atividades reais
  - Desenvolver métricas em tempo real para progresso

**Exemplo de Rastreador de Água**:
```dart
class WaterIntakeViewModel extends StateNotifier<WaterIntakeState> {
  final WaterIntakeRepository _repository;
  final AuthService _authService;

  WaterIntakeViewModel(this._repository, this._authService) 
      : super(const WaterIntakeState.initial());

  Future<void> loadWaterIntake(DateTime date) async {
    state = const WaterIntakeState.loading();
    
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = const WaterIntakeState.error('Usuário não autenticado');
        return;
      }
      
      final waterIntake = await _repository.getWaterIntake(userId, date);
      
      state = WaterIntakeState.loaded(
        date: date,
        cups: waterIntake.cups,
        goal: waterIntake.goal,
      );
    } catch (e) {
      state = WaterIntakeState.error(e.toString());
    }
  }

  Future<void> addWaterCup() async {
    if (state is! _WaterIntakeStateLoaded) return;
    
    final currentState = state as _WaterIntakeStateLoaded;
    final newCups = currentState.cups + 1;
    
    // Atualizar estado imediatamente para feedback rápido
    state = currentState.copyWith(cups: newCups);
    
    try {
      final userId = _authService.currentUser!.id;
      
      // Persistir no banco
      await _repository.updateWaterIntake(
        userId: userId,
        date: currentState.date,
        cups: newCups,
      );
    } catch (e) {
      // Reverter estado em caso de erro
      state = currentState;
      state = WaterIntakeState.error(e.toString());
    }
  }

  // Método para remover copo...
}
```

#### 2.3 Sistema de Desafios Real
- **Objetivo**: Implementar sistema completo de desafios com persistência
- **Tarefas**:
  - Desenvolver sistema de check-in com persistência no Supabase
  - Implementar cálculo de pontos e ranking em tempo real
  - Criar sistema de notificações para lembrete de desafios
  - Desenvolver histórico de participação em desafios
  - Implementar upload de imagens para desafios (usando o campo `localImagePath` adicionado na Fase 1)

**Exemplo de Check-in em Desafio**:
```dart
class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repository;
  final AuthService _authService;

  ChallengeViewModel(this._repository, this._authService) 
      : super(const ChallengeState.initial());

  Future<void> performCheckIn(String challengeId) async {
    if (state is! _ChallengeStateLoaded) return;
    
    state = const ChallengeState.loading();
    
    try {
      final userId = _authService.currentUser!.id;
      final userName = _authService.currentUser!.displayName;
      final userPhotoUrl = _authService.currentUser!.photoURL;
      
      // Registrar check-in
      await _repository.registerCheckIn(
        challengeId: challengeId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
      );
      
      // Obter challenge atualizado
      final challenge = await _repository.getChallengeDetails(challengeId);
      final userProgress = await _repository.getUserChallengeProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      state = ChallengeState.loaded(
        challenge: challenge,
        userProgress: userProgress,
        participants: await _repository.getChallengeParticipants(challengeId),
      );
    } catch (e) {
      state = ChallengeState.error(e.toString());
    }
  }

  // Outros métodos...
}
```

### Fase 3: Integração e Melhorias (Prioridade: Média)

#### 3.1 Sistema de Benefícios e Cupons
- **Objetivo**: Implementar sistema funcional de cupons e benefícios
- **Tarefas**:
  - Desenvolver sistema de cupons com persistência real
  - Implementar geração de QR codes funcionais
  - Criar sistema de resgate de benefícios que se comunique com parceiros
  - Implementar histórico de cupons e benefícios utilizados

**Exemplo de Implementação de QR Code**:
```dart
class BenefitViewModel extends StateNotifier<BenefitState> {
  final BenefitRepository _repository;
  final QRService _qrService;

  BenefitViewModel(this._repository, this._qrService) 
      : super(const BenefitState.initial());

  Future<void> generateQRCode(String benefitId) async {
    state = const BenefitState.loading();
    
    try {
      final userId = _authService.currentUser!.id;
      
      // Obter benefício
      final benefit = await _repository.getBenefitById(benefitId);
      
      // Gerar código único para este benefício
      final redemptionCode = await _repository.generateRedemptionCode(
        userId: userId,
        benefitId: benefitId,
      );
      
      // Gerar QR code com dados do código
      final qrCodeData = _qrService.generateQRCodeData(
        userId: userId,
        benefitId: benefitId,
        redemptionCode: redemptionCode,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      
      state = BenefitState.qrCodeGenerated(
        benefit: benefit,
        qrCodeData: qrCodeData,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
    } catch (e) {
      state = BenefitState.error(e.toString());
    }
  }

  // Outros métodos...
}
```

#### 3.2 Sistema de FAQs e Tutoriais Dinâmico
- **Objetivo**: Implementar sistema de ajuda dinâmico baseado em backend
- **Tarefas**:
  - Desenvolver carregamento de FAQs do Supabase
  - Implementar sistema de tutoriais com conteúdo multimídia
  - Criar formulário de contato funcional que envia mensagens reais
  - Implementar sistema de busca para conteúdo de ajuda

**Exemplo de Carregamento de FAQs**:
```dart
class HelpViewModel extends StateNotifier<HelpState> {
  final HelpRepository _repository;

  HelpViewModel(this._repository) : super(const HelpState.initial());

  Future<void> loadFAQs() async {
    state = const HelpState.loading();
    
    try {
      final faqs = await _repository.getFAQs();
      
      state = HelpState.faqsLoaded(faqs: faqs);
    } catch (e) {
      state = HelpState.error(e.toString());
    }
  }

  Future<void> searchHelp(String query) async {
    state = const HelpState.searching();
    
    try {
      final results = await _repository.searchHelp(query);
      
      state = HelpState.searchResults(
        faqs: results.faqs,
        tutorials: results.tutorials,
        articles: results.articles,
      );
    } catch (e) {
      state = HelpState.error(e.toString());
    }
  }

  // Outros métodos...
}
```



### Fase 4: Polimento e Otimização (Prioridade: Média-Baixa)

#### 4.1 Implementação de Configurações Avançadas
- **Objetivo**: Completar e sincronizar todas as configurações do usuário
- **Tarefas**:
  - Implementar mudança de idioma funcional que afete todo o app
  - Criar sincronização de preferências entre dispositivos
  - Desenvolver configurações avançadas de privacidade
  - Implementar configurações de notificações granulares

**Exemplo de Mudança de Idioma**:
```dart
class LocaleViewModel extends StateNotifier<LocaleState> {
  final SettingsRepository _repository;
  final AuthService _authService;

  LocaleViewModel(this._repository, this._authService) 
      : super(const LocaleState.initial());

  Future<void> loadLocale() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId != null) {
        final settings = await _repository.getUserSettings(userId);
        
        // Converter string para Locale
        final locale = _parseLocale(settings.language);
        state = LocaleState.loaded(locale: locale);
      } else {
        // Usar locale do dispositivo
        state = const LocaleState.loaded(locale: null);
      }
    } catch (e) {
      // Em caso de erro, usar locale padrão
      state = const LocaleState.loaded(locale: Locale('pt', 'BR'));
    }
  }

  Future<void> changeLocale(Locale locale) async {
    state = LocaleState.loaded(locale: locale);
    
    try {
      final userId = _authService.currentUser?.id;
      if (userId != null) {
        // Persistir no Supabase
        await _repository.updateUserSettings(
          userId: userId,
          language: '${locale.languageCode}_${locale.countryCode}',
        );
      }
    } catch (e) {
      // Notificar erro mas manter locale alterado
      debugPrint('Erro ao persistir locale: $e');
    }
  }

  Locale? _parseLocale(String? localeString) {
    if (localeString == null) return null;
    
    final parts = localeString.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else if (parts.length == 1) {
      return Locale(parts[0]);
    }
    
    return null;
  }
}
```

#### 4.2 Otimização de Desempenho e Memória
- **Objetivo**: Melhorar o desempenho geral e uso de recursos do app
- **Tarefas**:
  - Implementar cache inteligente para dados frequentemente acessados
  - Otimizar carregamento de imagens e assets
  - Reduzir uso de memória em listas com muitos itens
  - Implementar lazy loading para dados volumosos

**Exemplo de Cache Inteligente**:
```dart
class SmartCacheService implements CacheService {
  final SharedPreferences _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _expiry = {};

  SmartCacheService(this._prefs);

  @override
  Future<T?> get<T>(String key) async {
    // Verificar cache em memória primeiro (mais rápido)
    if (_memoryCache.containsKey(key)) {
      if (_expiry[key]!.isAfter(DateTime.now())) {
        return _memoryCache[key] as T?;
      } else {
        // Expirado, remover
        _memoryCache.remove(key);
        _expiry.remove(key);
      }
    }
    
    // Verificar cache persistente
    if (_prefs.containsKey(key)) {
      final data = _prefs.getString(key);
      if (data != null) {
        final decoded = jsonDecode(data);
        
        // Verificar expiração
        final expires = decoded['_expires'] as int?;
        if (expires != null && 
            DateTime.fromMillisecondsSinceEpoch(expires).isAfter(DateTime.now())) {
          
          final value = _deserialize<T>(decoded['value']);
          
          // Adicionar ao cache em memória
          _memoryCache[key] = value;
          _expiry[key] = DateTime.fromMillisecondsSinceEpoch(expires);
          
          return value;
        } else {
          // Expirado, remover
          await _prefs.remove(key);
        }
      }
    }
    
    return null;
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? expiry}) async {
    final expiryTime = expiry != null 
        ? DateTime.now().add(expiry)
        : DateTime.now().add(const Duration(days: 1));
    
    // Salvar em memória
    _memoryCache[key] = value;
    _expiry[key] = expiryTime;
    
    // Persistir
    final data = {
      'value': _serialize(value),
      '_expires': expiryTime.millisecondsSinceEpoch,
    };
    
    await _prefs.setString(key, jsonEncode(data));
  }

  // Implementar outros métodos...

  dynamic _serialize(dynamic value) {
    // Implementação da serialização baseada no tipo
  }
  
  T? _deserialize<T>(dynamic value) {
    // Implementação da deserialização baseada no tipo
  }
}
```

#### 4.3 Testes Automatizados
- **Objetivo**: Garantir robustez e qualidade do código
- **Tarefas**:
  - Implementar testes unitários para todos os ViewModels
  - Criar testes de widgets para componentes críticos
  - Desenvolver testes de integração para fluxos principais
  - Configurar pipeline de CI/CD para execução automática de testes

**Exemplo de Teste para ViewModel**:
```dart
void main() {
  late MockProfileRepository repository;
  late MockAuthService authService;
  late ProfileViewModel viewModel;

  setUp(() {
    repository = MockProfileRepository();
    authService = MockAuthService();
    viewModel = ProfileViewModel(repository, authService);
  });

  group('ProfileViewModel', () {
    test('initial state is ProfileState.initial', () {
      expect(viewModel.debugState, isA<_ProfileStateInitial>());
    });

    test('loadProfile changes state to loading then loaded on success', () async {
      // Arrange
      final userId = 'test-user-id';
      final profile = UserProfile(
        id: userId,
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: null,
      );
      
      when(authService.currentUser).thenReturn(User(id: userId));
      when(repository.getUserProfile(userId))
          .thenAnswer((_) async => profile);
      
      // Act
      await viewModel.loadProfile();
      
      // Assert
      verify(repository.getUserProfile(userId)).called(1);
      
      expect(viewModel.debugState, isA<_ProfileStateLoaded>());
      final loadedState = viewModel.debugState as _ProfileStateLoaded;
      expect(loadedState.profile, equals(profile));
    });

    test('loadProfile changes state to error on failure', () async {
      // Arrange
      final userId = 'test-user-id';
      final errorMessage = 'Network error';
      
      when(authService.currentUser).thenReturn(User(id: userId));
      when(repository.getUserProfile(userId))
          .thenThrow(Exception(errorMessage));
      
      // Act
      await viewModel.loadProfile();
      
      // Assert
      verify(repository.getUserProfile(userId)).called(1);
      
      expect(viewModel.debugState, isA<_ProfileStateError>());
      final errorState = viewModel.debugState as _ProfileStateError;
      expect(errorState.message, contains(errorMessage));
    });

    // Mais testes...
  });
}
```

## Métricas de Sucesso

Para garantir que o projeto de correção seja bem-sucedido, estabelecemos as seguintes métricas:

1. **Integridade do Código**:
   - 100% das funcionalidades seguem o padrão MVVM
   - 0 ocorrências de `setState()` no código
   - Cobertura de testes > 80%

2. **Persistência de Dados**:
   - 100% das ações do usuário persistem no Supabase
   - Sistema funcional offline-first com sincronização
   - Zero perda de dados durante transições

3. **Experiência do Usuário**:
   - Tempo de carregamento inicial < 2 segundos
   - Tempo de resposta para ações < 500ms
   - Zero "telas em construção" ou funcionalidades incompletas

4. **Qualidade do Código**:
   - Code lint sem warnings
   - Documentação completa para API pública
   - Padrão de commits e PRs seguindo convenções definidas

## Cronograma

| Fase | Descrição | Estimativa | Prioridade | Dependências |
|------|-----------|------------|------------|--------------|
| 1.1 | Integração Completa com Supabase | 2 semanas | Alta | - |
| 1.2 | Correção do Sistema de Navegação | 1 semana | Alta | - |
| 1.3 | Padronização do Gerenciamento de Estado | 2 semanas | Alta | - |
| 2.1 | Sistema de Perfil Completo | 2 semanas | Alta | 1.1, 1.3 |
| 2.2 | Dashboard e Progresso Funcional | 2 semanas | Alta | 1.1, 1.3 |
| 2.3 | Sistema de Desafios Real | 3 semanas | Alta | 1.1, 1.3 |
| 3.1 | Sistema de Benefícios e Cupons | 2 semanas | Média | 1.1, 1.3 |
| 3.2 | Sistema de FAQs e Tutoriais Dinâmico | 2 semanas | Média | 1.1, 1.3 |
| 3.3 | Funcionalidades Sociais | 3 semanas | Média | 1.1, 1.3, 2.1 |
| 4.1 | Implementação de Configurações Avançadas | 1 semana | Média-Baixa | 1.1, 1.3 |
| 4.2 | Otimização de Desempenho e Memória | 2 semanas | Média-Baixa | Todas |
| 4.3 | Testes Automatizados | Contínuo | Média-Baixa | Implementação de cada feature |

Total estimado: 14-16 semanas para implementação completa de todas as correções e melhorias.

---

Este plano representa uma abordagem estruturada para corrigir as inconsistências do Ray Club App, priorizando a infraestrutura básica e as funcionalidades essenciais, seguindo estritamente o padrão MVVM com Riverpod. A implementação será realizada em fases, garantindo que cada componente seja testado e funcione corretamente antes de avançar para o próximo. 