# Ray Club - Documentação Completa do Aplicativo

## Visão Geral
O Ray Club é um aplicativo de fitness e bem-estar que oferece uma experiência gamificada para treinos e desafios. O app foi desenvolvido para motivar usuários a manterem uma rotina de exercícios através de desafios, recompensas e uma comunidade engajada, utilizando o padrão MVVM com Riverpod para gerenciamento de estado.

## Fluxo Completo do Aplicativo

### 1. Introdução e Autenticação

#### 1.1 Tela de Introdução (Onboarding)
**Objetivo**: Apresentar o aplicativo e direcionar o usuário para login ou visualização do conteúdo.

**Implementação Técnica**:
- **Arquivo Principal**: `lib/features/intro/screens/intro_screen.dart`
- **Rota**: Definida como `IntroRoute` em `app_router.gr.dart` e constante `AppRoutes.intro` ('/intro')
- **Componentes-chave**:
  - `SafeArea` com `Column` para organização vertical
  - `_buildLogoSection()` para exibição da marca
  - `_buildActionButtons()` para botões de ação
- **Persistência**:
  - Utiliza `SharedPreferences` com chave `has_seen_intro` (boolean)
  - Método `_markIntroAsSeen()` salva estado para não exibir novamente

**Fluxo de Dados**:
```
1. App verifica SharedPreferences.getBool('has_seen_intro')
2. Se falso ou nulo, exibe IntroScreen
3. Ao clicar em botão, chama _markIntroAsSeen() e navega para próxima tela
4. Navegação: context.router.replaceNamed('/') ou context.router.replaceNamed('/login')
```

#### 1.2 Tela de Login
**Objetivo**: Autenticar usuários existentes.

**Implementação Técnica**:
- **Arquivo Principal**: `lib/features/auth/screens/login_screen.dart`
- **ViewModel**: `lib/features/auth/viewmodels/auth_view_model.dart`
- **Repositório**: `lib/features/auth/repositories/auth_repository.dart`
- **Rota**: `AppRoutes.login` ('/login')
- **Estado**: Gerenciado por `AuthState` (freezed) com variantes:
  - `initial()`, `loading()`, `authenticated(user)`, `error(message)`

**Tabelas Supabase**:
- Utiliza **auth.users** (gerenciada pelo Supabase Auth)
  - Colunas principais: `id` (UUID), `email`, `password` (hash), `created_at`
- **profiles**: Armazena dados adicionais do usuário
  - Colunas: `id` (UUID, igual ao auth.users.id), `name`, `email`, `photo_url`, `daily_water_goal`, `is_admin`

**Métodos Principais**:
- `signIn(email, password)`: Autentica usuário
  - Fluxo: Valida entrada → Verifica existência do email → Tenta login com Supabase → Retorna usuário
- `isEmailRegistered(email)`: Verifica se email já existe
- Validações: Expressão regular `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$` para emails

**Códigos de Erro**:
- `email_not_found`: Email não encontrado
- `invalid_credentials`: Credenciais inválidas
- `auth_error`: Erro geral de autenticação

#### 1.3 Tela de Registro (Sign Up)
**Objetivo**: Cadastrar novos usuários.

**Implementação Técnica**:
- **Arquivo Principal**: `lib/features/auth/screens/signup_screen.dart`
- **Compartilha ViewModel/Repositório**: Com Login
- **Rota**: `AppRoutes.signup` ('/signup')

**Fluxo de API**:
```
1. Validação de campos (email, senha, nome)
2. Verificação se email existe: isEmailRegistered()
3. Chamada Supabase: _supabaseClient.auth.signUp()
4. Parâmetros: email, password, data: {'name': name}
5. Tentativa de login automático se necessário
6. Criação automática de perfil via trigger SQL
```

**Trigger SQL (Supabase)**: 
```sql
CREATE TRIGGER create_profile_after_signup
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION create_profile_for_user();

CREATE FUNCTION create_profile_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### 1.4 Esqueci Minha Senha
**Objetivo**: Permitir recuperação de acesso.

**Implementação Técnica**:
- **Arquivos**: 
  - `lib/features/auth/screens/forgot_password_screen.dart`
  - `lib/features/auth/screens/reset_password_screen.dart`
- **Rotas**: 
  - `AppRoutes.forgotPassword` ('/forgot-password')
  - `AppRoutes.resetPassword` ('/reset-password')

**Métodos**:
- `resetPassword(String email)` em `AuthRepository`
  - Implementação: `_supabaseClient.auth.resetPasswordForEmail(email)`
  - Gera token enviado por email automaticamente

**Fluxo Completo**:
```
1. Usuário insere email em ForgotPasswordScreen
2. App chama resetPassword(email)
3. Supabase envia email com link mágico
4. Link redireciona para app via deep link
5. App processa parâmetros e navega para ResetPasswordScreen
6. Usuário define nova senha
7. Nova senha enviada via _supabaseClient.auth.updateUser()
```

### 2. Navegação Principal

#### 2.1 Barra de Navegação Inferior
**Objetivo**: Navegação primária entre áreas do app.

**Implementação Técnica**:
- **Arquivo Principal**: `lib/shared/bottom_navigation_bar.dart`
- **Classe**: `SharedBottomNavigationBar`
- **Props**:
  - `currentIndex`: Índice do item selecionado (0-4)
  - Itens fixos: Home (0), Treinos (1), Registrar Exercício (2), Nutrição (3), Desafios (4)

**Métodos de Navegação**:
```dart
// Home
context.router.replace(const HomeRoute())

// Treinos
context.router.replaceNamed(AppRoutes.workout)

// Nutrição 
context.router.replaceNamed(AppRoutes.nutrition)

// Desafios
context.router.replaceNamed(AppRoutes.challenges)
```

**Componente Central (Botão de Registro)**:
- `_buildCenterButton(context)` - Modal popup para registro de exercício
- Implementa `showModalBottomSheet()` com `RegisterExerciseSheet`

**Estilização**:
- Container com `boxShadow` e `border` para destacar visualmente
- `Padding` interno com valores precisos: 8.0 vertical
- Ícones alternam entre outline (não selecionado) e filled (selecionado)

#### 2.2 Guarda de Autenticação (Auth Guard)
**Objetivo**: Proteger rotas autenticadas.

**Implementação Técnica**:
- **Arquivo**: `lib/core/router/layered_auth_guard.dart`
- **Classe**: `LayeredAuthGuard` implementa `AutoRouteGuard`
- **Método Principal**: `onNavigation(NavigationResolver resolver, StackRouter router)`

**Lógica de Verificação**:
```dart
final authState = _ref.read(authViewModelProvider);
  
authState.maybeWhen(
  authenticated: (_) => resolver.next(true), // Autenticado: permite navegação
  orElse: () {
    // Não autenticado: redireciona para login
    router.push(const LoginRoute());
    resolver.next(false);
  },
)
```

**Rotas Protegidas**: Todas as rotas exceto as listadas em `AppRoutes.publicRoutes` (login, signup, intro, etc)

#### 2.3 Menu Lateral (Drawer)
**Objetivo**: Acesso a funcionalidades secundárias.

**Implementação Técnica**:
- **Localização**: Método `_buildDrawer()` dentro da `HomeScreen`
- **Componente**: `Drawer` com `ListView` para itens de menu
- **Método Builder**: `_buildDrawerItem(context, {icon, title, onTap})`

**Rotas de Navegação**:
```dart
// Dashboard
context.router.pushNamed('/progress/day/1')

// Treinos
context.router.replaceNamed('/workouts')

// Nutrição
context.router.replaceNamed('/nutrition')

// Desafio
context.router.push(const ChallengesListRoute())

// Benefícios
context.router.replaceNamed('/benefits')
```

### 3. Tela Principal (Home)

#### 3.1 Estrutura da Home
**Objetivo**: Hub central de informações e ações.

**Implementação Técnica**:
- **Arquivo**: `lib/features/home/screens/home_screen.dart`
- **ViewModel**: `HomeViewModel` com `AsyncValue<HomeData>`
- **Rota**: `AppRoutes.home` ('/')
- **Layout**: `CustomScrollView` com múltiplos `SliverList` para componentes

**Modelo de Dados**:
```dart
@freezed
class HomeData with _$HomeData {
  const factory HomeData({
    required UserProfile profile,
    required UserProgress progress,
    required List<Workout> popularWorkouts,
    required List<Benefit> featuredBenefits,
    required List<PartnerStudio> partnerStudios,
    required List<Banner> activeBanners,
  }) = _HomeData;
}
```

**Componentes Principais**:
1. **Appbar com Saudação**:
   - `_buildFlexibleAppBar()` com SliverAppBar flexível
   - Saudação dinâmica baseada na hora do dia e nome do usuário

2. **Grid de Acesso Rápido**:
   - `_buildQuickAccessGrid(context)`
   - Grid 4x2 com ícones e ações para funcionalidades frequentes
   - Cada item: {icon, title, color, secondaryColor, onTap}

3. **Widget de Onboarding**:
   - `_buildOnboardingWidget(context)`
   - PageView deslizável com `SmoothPageIndicator`
   - Cards informativos sobre o desafio principal

4. **Dashboard de Progresso**:
   - `_buildProgressDashboard(context, data.progress)`
   - Visualização de streak, pontos acumulados e rank atual
   - Usa `GaugeChart` para visualização circular

**Carregamento de Dados**:
```dart
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final profile = await ref.watch(profileRepositoryProvider).getUserProfile();
  final progress = await ref.watch(progressRepositoryProvider).getUserProgress();
  final workouts = await ref.watch(workoutRepositoryProvider).getPopularWorkouts();
  final benefits = await ref.watch(benefitRepositoryProvider).getFeaturedBenefits();
  final banners = await ref.watch(bannerRepositoryProvider).getActiveBanners();
  final studios = await ref.watch(studioRepositoryProvider).getPartnerStudios();
  
  return HomeData(
    profile: profile,
    progress: progress,
    popularWorkouts: workouts,
    featuredBenefits: benefits,
    activeBanners: banners,
    partnerStudios: studios,
  );
});
```

#### 3.2 Onboarding do Desafio
**Objetivo**: Explicar o funcionamento do desafio principal.

**Implementação Técnica**:
- **Componente**: `_buildOnboardingWidget(context)` dentro da `HomeScreen`
- **Controller**: `PageController(viewportFraction: 0.93)`
- **Indicador**: `SmoothPageIndicator` com `WormEffect`

**Estrutura de Dados**:
```dart
final onboardingItems = [
  {
    'title': 'Regras do Desafio',
    'description': 'Conheça as regras e condições para participar do Desafio Ray de 21 dias',
    'icon': Icons.rule_folder,
    'color': const Color(0xFFFF8A80),
    'bgColor': const Color(0xFFFFEBEE),
    'action': 'Ver regras',
    'onTap': () => context.router.push(const ChallengesListRoute()),
  },
  // Outros itens...
];
```

**Componente Visual**:
- Banner principal seguido de cards informativos
- Cada card: título, descrição, ícone, botão de ação
- Estilização com gradientes e sombras para profundidade visual

### 4. Sistema de Desafios

#### 4.1 Estrutura de Dados de Desafios

**Modelo Principal - Desafio**:
```dart
@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,                 // UUID
    required String title,              // Título do desafio
    required String description,        // Descrição detalhada
    String? imageUrl,                   // URL da imagem  
    String? localImagePath,             // Caminho temp para upload
    required DateTime startDate,        // Data início
    required DateTime endDate,          // Data término
    @Default('normal') String type,     // Tipo: normal, featured, official
    required int points,                // Pontos por check-in
    List<String>? requirements,         // Requisitos para participação
    @Default(true) bool active,         // Status ativo/inativo
    required String creatorId,          // ID do criador
    @Default(false) bool isOfficial,    // Flag para desafio oficial
    List<String>? invitedUsers,         // IDs de usuários convidados
    DateTime? createdAt,                // Data criação
    DateTime? updatedAt,                // Data atualização
    int? participantsCount,             // Contador de participantes
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => 
    _$ChallengeFromJson(json);
}
```

**Tabelas Supabase**:
1. **challenges**:
  - `id` UUID PRIMARY KEY
   - `title` TEXT NOT NULL
   - `description` TEXT NOT NULL
   - `image_url` TEXT
   - `local_image_path` TEXT
   - `start_date` TIMESTAMP WITH TIME ZONE NOT NULL
   - `end_date` TIMESTAMP WITH TIME ZONE NOT NULL
   - `type` TEXT NOT NULL DEFAULT 'normal'
   - `points` INTEGER NOT NULL
   - `requirements` TEXT[]
   - `active` BOOLEAN NOT NULL DEFAULT true
   - `creator_id` UUID NOT NULL (foreign key para auth.users)
   - `is_official` BOOLEAN NOT NULL DEFAULT false
   - `invited_users` UUID[]
  - `created_at` TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   - `updated_at` TIMESTAMP WITH TIME ZONE

2. **challenge_participants**:
   - `id` UUID PRIMARY KEY
   - `challenge_id` UUID NOT NULL (foreign key para challenges)
   - `user_id` UUID NOT NULL (foreign key para auth.users)
   - `joined_at` TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
   - Índice: (`challenge_id`, `user_id`) UNIQUE

3. **challenge_check_ins**:
   - `id` UUID PRIMARY KEY
   - `challenge_id` UUID NOT NULL (foreign key para challenges)
   - `user_id` UUID NOT NULL (foreign key para auth.users)
   - `check_in_date` DATE NOT NULL
   - `created_at` TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   - `photo_url` TEXT
   - `notes` TEXT
   - Índice: (`challenge_id`, `user_id`, `check_in_date`) UNIQUE

4. **challenge_progress**:
   - `id` UUID PRIMARY KEY
   - `challenge_id` UUID NOT NULL (foreign key para challenges)
   - `user_id` UUID NOT NULL (foreign key para auth.users)
   - `points` INTEGER NOT NULL DEFAULT 0
   - `position` INTEGER
   - `total_check_ins` INTEGER NOT NULL DEFAULT 0
   - `consecutive_days` INTEGER NOT NULL DEFAULT 0
   - `last_check_in` TIMESTAMP WITH TIME ZONE
   - `created_at` TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   - `updated_at` TIMESTAMP WITH TIME ZONE
   - `user_name` TEXT
   - `user_photo_url` TEXT

5. **challenge_groups**:
   - `id` UUID PRIMARY KEY
   - `challenge_id` UUID NOT NULL (foreign key para challenges)
   - `creator_id` UUID NOT NULL (foreign key para auth.users)
   - `name` TEXT NOT NULL
   - `description` TEXT
   - `created_at` TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   - `updated_at` TIMESTAMP WITH TIME ZONE
   - `is_public` BOOLEAN NOT NULL DEFAULT false
   - `member_ids` UUID[] NOT NULL DEFAULT '{}'

6. **challenge_group_members**:
   - `id` UUID PRIMARY KEY
   - `group_id` UUID NOT NULL (foreign key para challenge_groups)
   - `user_id` UUID NOT NULL (foreign key para auth.users)
   - `joined_at` TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
   - `created_at` TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
   - `updated_at` TIMESTAMP WITH TIME ZONE

7. **challenge_group_invites**:
  - `id` UUID PRIMARY KEY
   - `group_id` UUID NOT NULL (foreign key para challenge_groups)
   - `inviter_id` UUID NOT NULL (foreign key para auth.users)
   - `invitee_id` UUID NOT NULL (foreign key para auth.users)
   - `status` INTEGER NOT NULL DEFAULT 0 (0=pending, 1=accepted, 2=declined)
  - `created_at` TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   - `updated_at` TIMESTAMP WITH TIME ZONE

#### 4.2 Lista de Desafios e Filtros

**Implementação Técnica**:
- **Arquivos Principais**:
  - `lib/features/challenges/screens/challenges_list_screen.dart`
  - `lib/features/challenges/viewmodels/challenge_view_model.dart`
  - `lib/features/challenges/repositories/challenge_repository.dart`
- **Rota**: `AppRoutes.challenges` ('/challenges')

**Método de Carregamento**:
```dart
Future<void> loadChallenges() async {
  try {
    state = state.copyWith(isLoading: true);
    
    // Carregar desafios com filtros aplicados
    final challenges = await _repository.getChallenges(
      filters: state.filters,
      searchTerm: state.searchTerm,
      includeInactive: state.showInactiveRecords,
    );
    
    // Garantir que o desafio oficial esteja na lista
    final officialChallenge = await _repository.getOfficialChallenge();
    
    // Verificar se o desafio oficial já está na lista
    if (officialChallenge != null && 
        !challenges.any((c) => c.id == officialChallenge.id)) {
      challenges.insert(0, officialChallenge);
    }
    
    state = state.copyWith(
      challenges: challenges,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      errorMessage: _getErrorMessage(e),
      isLoading: false,
    );
  }
}
```

**Query SQL para Filtros**:
```sql
CREATE OR REPLACE FUNCTION search_challenges(
  search_term TEXT DEFAULT NULL,
  category_filter TEXT DEFAULT NULL,
  status_filter TEXT DEFAULT NULL,
  sort_by TEXT DEFAULT 'created_at',
  sort_order TEXT DEFAULT 'desc',
  limit_param INTEGER DEFAULT 100,
  offset_param INTEGER DEFAULT 0
) RETURNS SETOF challenges AS $$
DECLARE
  where_clause TEXT := '';
  order_clause TEXT;
  query_text TEXT;
BEGIN
  -- Construir cláusula WHERE com base nos filtros
  IF search_term IS NOT NULL AND search_term <> '' THEN
    where_clause := where_clause || ' AND (title ILIKE ''%' || search_term || '%'' OR description ILIKE ''%' || search_term || '%'')';
  END IF;
  
  IF category_filter IS NOT NULL AND category_filter <> '' THEN
    where_clause := where_clause || ' AND type = ''' || category_filter || '''';
  END IF;
  
  IF status_filter IS NOT NULL AND status_filter <> '' THEN
    where_clause := where_clause || ' AND active = ' || (status_filter = 'active');
  END IF;
  
  -- Construir e executar a query completa
  query_text := '
    SELECT * FROM challenges
    WHERE 1=1' || where_clause || '
    ORDER BY ' || sort_by || ' ' || sort_order || '
    LIMIT ' || limit_param || ' OFFSET ' || offset_param;
  
  RETURN QUERY EXECUTE query_text;
END;
$$ LANGUAGE plpgsql;
```

#### 4.3 Detalhe do Desafio e Check-In

**Implementação Técnica**:
- **Arquivos Principais**:
  - `lib/features/challenges/screens/challenge_detail_screen.dart` 
  - `lib/features/challenges/viewmodels/challenge_detail_view_model.dart`
- **Rota**: `AppRoutes.challengeDetail(challengeId)` ('/challenges/:challengeId')

**Modelo de Estado**:
```dart
@freezed
class ChallengeDetailState with _$ChallengeDetailState {
  const factory ChallengeDetailState({
    Challenge? challenge,
    @Default([]) List<ChallengeParticipant> participants,
    ChallengeProgress? userProgress,
    @Default(false) bool isParticipant,
    @Default(false) bool hasCheckedInToday,
    @Default(false) bool isLoading,
    String? errorMessage,
    // Mais propriedades...
  }) = _ChallengeDetailState;
}
```

**Método de Check-In**:
```dart
Future<void> performCheckIn(String challengeId) async {
  try {
    state = state.copyWith(isCheckingIn: true);
    
    // Registrar check-in no repositório
    await _repository.registerCheckIn(
      challengeId: challengeId,
      // Opcionalmente com foto e notas
      photoUrl: state.checkInPhotoUrl,
      notes: state.checkInNotes,
    );
    
    // Recarregar os dados atualizados
    await loadChallengeDetails(challengeId);
    
    state = state.copyWith(
      hasCheckedInToday: true,
      isCheckingIn: false,
      checkInSuccess: true,
      checkInNotes: null,
      checkInPhotoUrl: null,
    );
  } catch (e) {
    state = state.copyWith(
      errorMessage: _getErrorMessage(e),
      isCheckingIn: false,
    );
  }
}
```

**Integração com Registro de Treino**:
A partir da versão mais recente, o fluxo de check-in foi integrado com o sistema de registro de treinos para simplificar a experiência do usuário e unificar as duas funcionalidades.

**Implementação Técnica**:
- **Arquivos Principais**:
  - `lib/features/challenges/screens/challenge_detail_screen.dart` (Botão de check-in)
  - `lib/features/home/widgets/register_exercise_sheet.dart` (Formulário de registro)
  - `lib/shared/bottom_navigation_bar.dart` (Botão de registro geral)

**Fluxo de Interação**:
1. Usuário clica no botão "Fazer Check-in" na tela de detalhes do desafio
2. O sistema abre o `RegisterExerciseSheet` com o ID do desafio como parâmetro
3. A UI adapta-se para indicar que o treino será registrado como check-in para o desafio
4. Ao finalizar o registro, o sistema:
   - Cria um registro na tabela `workout_records`
   - Registra um check-in na tabela `challenge_check_ins` para o desafio específico
   - Atualiza o progresso e o ranking do usuário no desafio

**Código para Abertura do Sheet**:
```dart
// No FloatingActionButton da ChallengeDetailScreen
FloatingActionButton.extended(
  onPressed: () {
    showRegisterExerciseSheet(context, challengeId: challenge.id);
  },
  label: const Text('Fazer Check-in'),
  icon: const Icon(Icons.add_task),
)
```

**Implementação do RegisterWorkoutViewModel**:
```dart
// Método específico para check-in de desafio no RegisterWorkoutViewModel
Future<RegisterWorkoutResult> registerWorkoutForSpecificChallenge({
  required String name,
  required String type,
  required int durationMinutes,
  required double intensity,
  required String challengeId,
}) async {
  // Cria o registro de treino
  final record = WorkoutRecord(...);
  
  // Salva o registro
  final savedRecord = await _repository.createWorkoutRecord(record);
  
  // Registra o check-in específico para o desafio
  final checkInResult = await challengeRepo.recordChallengeCheckIn(
    challengeId: challengeId,
    userId: userId,
    workoutId: savedRecord.id,
    workoutName: savedRecord.workoutName,
    workoutType: savedRecord.workoutType,
    date: savedRecord.date,
    durationMinutes: savedRecord.durationMinutes,
  );
  
  return RegisterWorkoutResult(...);
}
```

**SQL para Check-In e Atualização de Progresso**:
```sql
-- Trigger SQL para atualizar progresso após check-in
CREATE OR REPLACE FUNCTION update_challenge_progress_on_checkin()
RETURNS TRIGGER AS $$
DECLARE
    consecutive_days_count INTEGER;
    last_check_in_date DATE;
    total_check_ins_count INTEGER;
    streak_bonus INTEGER;
BEGIN
    -- Obter o último check-in
    SELECT 
        consecutive_days,
        CAST(last_check_in AS DATE),
        total_check_ins
    INTO 
        consecutive_days_count,
        last_check_in_date,
        total_check_ins_count
    FROM 
        challenge_progress
    WHERE 
        challenge_id = NEW.challenge_id AND 
        user_id = NEW.user_id;
    
    -- Se nunca houve check-in anterior, inicializar valores
    IF last_check_in_date IS NULL THEN
        consecutive_days_count := 1;
        total_check_ins_count := 1;
    ELSE
        -- Verificar se o último check-in foi ontem
        IF last_check_in_date = CURRENT_DATE - INTERVAL '1 day' THEN
            consecutive_days_count := consecutive_days_count + 1;
        -- Se for outro dia (sem ser hoje que já verificamos antes)
        ELSIF last_check_in_date < CURRENT_DATE - INTERVAL '1 day' THEN
            consecutive_days_count := 1; -- Reinicia streak
        END IF;
        
        total_check_ins_count := total_check_ins_count + 1;
    END IF;
    
    -- Calcular bônus de streak
    IF consecutive_days_count >= 30 THEN
        streak_bonus := 5;
    ELSIF consecutive_days_count >= 15 THEN
        streak_bonus := 3;
    ELSIF consecutive_days_count >= 7 THEN
        streak_bonus := 2;
    ELSIF consecutive_days_count >= 3 THEN
        streak_bonus := 1;
    ELSE
        streak_bonus := 0;
    END IF;
    
    -- Obter pontos base do desafio
    DECLARE
        base_points INTEGER;
    BEGIN
        SELECT points INTO base_points
        FROM challenges
        WHERE id = NEW.challenge_id;
        
        -- Atualizar progresso
        UPDATE challenge_progress
        SET 
            total_check_ins = total_check_ins_count,
            consecutive_days = consecutive_days_count,
            last_check_in = NEW.created_at,
            points = points + base_points + streak_bonus,
            updated_at = NOW()
        WHERE 
            challenge_id = NEW.challenge_id AND 
            user_id = NEW.user_id;
    END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger
CREATE TRIGGER update_progress_after_checkin
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_challenge_progress_on_checkin();
```

#### 4.3.1 Resolução de Conflitos com Triggers em Check-ins

**Problema Identificado**: A implementação original de check-ins dependia de triggers no banco de dados que tentavam acessar um campo `status` inexistente na tabela `challenge_check_ins`, causando o erro: `PostgrestException(message: record "new" has no field "status", code: 42703)`.

**Solução Implementada**: 
- Desativação dos triggers problemáticos que causavam o erro:
  ```sql
  ALTER TABLE challenge_check_ins DISABLE TRIGGER tr_update_user_progress_on_checkin;
  ALTER TABLE challenge_check_ins DISABLE TRIGGER trg_update_progress_on_check_in;
  ALTER TABLE challenge_check_ins DISABLE TRIGGER trigger_update_challenge_ranking;
  ALTER TABLE challenge_check_ins DISABLE TRIGGER update_progress_after_checkin;
  ALTER TABLE challenge_check_ins DISABLE TRIGGER update_streak_on_checkin;
  ALTER TABLE challenge_check_ins DISABLE TRIGGER update_profile_stats_on_checkin_trigger;
  ```

- Criação de uma nova implementação da função `record_challenge_check_in_v2` que:
  1. Não depende de triggers, realizando todas as atualizações necessárias diretamente
  2. Mantém a compatibilidade com a API existente no aplicativo
  3. Gerencia verificações de existência de check-ins duplicados
  4. Atualiza adequadamente o progresso, streak e ranking dos usuários
  5. Gerencia atualizações nas tabelas `challenge_progress`, `challenge_participants` e `user_progress`
  6. Inclui tratamento seguro de erros com mensagens compreensíveis
  7. Usa nomes de colunas corretos para cada tabela (`check_ins_count` para challenge_progress, `total_check_ins` para user_progress)
  8. Qualifica corretamente referências a colunas para evitar ambiguidades

**Detalhes da Implementação**:
- A função centralizada usa joins e subconsultas para evitar ambiguidades em nomes de colunas
- Implementação transacional completa com tratamento de erros explícito
- Todas as consultas críticas usam `FOR UPDATE` para prevenir condições de corrida
- Todas as atualizações que antes eram feitas por triggers agora são realizadas em sequência dentro da mesma transação

**Diagramas de Sequência**:
1. **Fluxo de Check-in (Nova Implementação)**:
   ```
   App → record_challenge_check_in_v2() → Verifica duplicação → Obtém dados do usuário e desafio
   → Calcula streak → Insere check-in → Atualiza challenge_progress → Atualiza participants
   → Atualiza user_progress → Recalcula ranking → Retorna resultado
   ```

2. **Tratamento de Erros**:
   ```
   Em caso de exceção → Registra erro em check_in_error_logs → Retorna mensagem amigável ao usuário
   ```

**Impacto**: Essa alteração elimina a dependência de triggers problemáticos, tornando o processo de check-in mais robusto e confiável, sem alterar a API pública utilizada pelo aplicativo Flutter.

#### 4.4 Ranking do Desafio e Filtros por Grupo

**Implementação Técnica**:
- **Arquivos Principais**:
  - `lib/features/challenges/screens/challenge_ranking_screen.dart`
  - `lib/features/challenges/viewmodels/challenge_ranking_view_model.dart`
  - `lib/features/challenges/services/realtime_service.dart`
- **Rota**: `AppRoutes.challengeRanking(challengeId)` ('/challenges/ranking/:challengeId')

**Método de Filtro por Grupo**:
```dart
Future<void> filterRankingByGroup(String? groupId) async {
  try {
    state = state.copyWith(isLoading: true);
    
    if (state.challengeId == null) {
      throw AppException(message: 'ID do desafio não definido');
    }
    
    // Cancelar qualquer assinatura de stream existente
    _rankingSubscription?.cancel();
    
    // Configurar nova observação com ou sem filtro de grupo
    if (groupId != null) {
      _rankingSubscription = _realtimeService.watchGroupRanking(
        groupId
      ).listen(_handleRankingUpdate);
      
      // Carregar dados iniciais do grupo
      final ranking = await _repository.getGroupRanking(groupId);
      state = state.copyWith(
        progressList: ranking,
        selectedGroupIdForFilter: groupId,
        isLoading: false
      );
    } else {
      _rankingSubscription = _realtimeService.watchChallengeParticipants(
        state.challengeId!
      ).listen(_handleRankingUpdate);
      
      // Carregar dados iniciais gerais
      final ranking = await _repository.getChallengeProgress(state.challengeId!);
      state = state.copyWith(
        progressList: ranking,
        selectedGroupIdForFilter: null,
        isLoading: false
      );
    }
  } catch (e) {
    state = state.copyWith(
      errorMessage: _getErrorMessage(e),
      isLoading: false
    );
  }
}
```

**Função SQL para Ranking por Grupo**:
```sql
-- Função para obter o ranking de um grupo específico
CREATE OR REPLACE FUNCTION get_group_ranking(group_id_param UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  user_name TEXT,
  user_photo_url TEXT,
  challenge_id UUID,
  points INTEGER,
  "position" INTEGER,  -- Nome entre aspas por ser palavra reservada
  consecutive_days INTEGER,
  total_check_ins INTEGER,
  last_check_in TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
  challenge_id_var UUID;
BEGIN
  -- Obter ID do desafio do grupo
  SELECT challenge_id INTO challenge_id_var
  FROM challenge_groups
  WHERE id = group_id_param;
  
  -- Retornar ranking dos membros do grupo
  RETURN QUERY
  SELECT 
    cp.id,
    cp.user_id,
    cp.user_name,
    cp.user_photo_url,
    cp.challenge_id,
    cp.points,
    ROW_NUMBER() OVER(ORDER BY cp.points DESC)::INTEGER as "position",
    cp.consecutive_days,
    cp.check_ins_count as total_check_ins,
    cp.last_check_in
  FROM 
    challenge_progress cp
  JOIN 
    challenge_group_members cgm 
    ON cp.user_id = cgm.user_id 
  WHERE 
    cgm.group_id = group_id_param
    AND cp.challenge_id = challenge_id_var
  ORDER BY 
    cp.points DESC;
END;
$$ LANGUAGE plpgsql;
```

**Função para Verificação de Acesso a Grupos**:
```sql
-- Verifica se um usuário pode acessar um grupo específico
CREATE OR REPLACE FUNCTION can_access_group(user_id_param UUID, group_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
  is_member BOOLEAN;
  is_public BOOLEAN;
BEGIN
  -- Verificar se o grupo é público
  SELECT COALESCE(is_public, false) INTO is_public
  FROM challenge_groups
  WHERE id = group_id_param;
  
  -- Se for público, qualquer um pode ver
  IF is_public THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar se o usuário é membro
  SELECT EXISTS (
    SELECT 1 FROM challenge_group_members
    WHERE group_id = group_id_param AND user_id = user_id_param
  ) INTO is_member;
  
  RETURN is_member;
END;
$$ LANGUAGE plpgsql;
```

**Interface de Filtro por Grupo**:
```dart
Widget _buildGroupFilter(
  List<ChallengeGroup> userGroups,
  String? selectedGroupId,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por grupo:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String?>(
              value: selectedGroupId,
              icon: const Icon(Icons.filter_list),
              isExpanded: true,
              hint: const Text('Todos os participantes'),
              items: [
                // Opção para todos os participantes
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos os participantes'),
                ),
                // Opções para cada grupo do usuário
                ...userGroups.map((group) => DropdownMenuItem<String?>(
                      value: group.id,
                      child: Text(
                        group.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ],
              onChanged: (String? newGroupId) {
                ref.read(challengeRankingViewModelProvider.notifier)
                  .filterRankingByGroup(newGroupId);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
```

**Serviço de Tempo Real**:
Para suportar a visualização em tempo real do ranking de grupos, foi implementado o `RealtimeService` que observa as atualizações na tabela `challenge_progress`. O método `watchGroupRanking` usa rxdart para combinar streams e manter os dados atualizados:

```dart
Stream<List<ChallengeProgress>> watchGroupRanking(String groupId) {
  // Usar a função RPC get_group_ranking para obter o ranking inicial
  final initialRankingFuture = _client
      .rpc('get_group_ranking', params: {'group_id_param': groupId})
      .then((data) => 
          data.map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
              .toList());
  
  // Buscar o challenge_id e membros do grupo para observar atualizações
  final challengeIdFuture = _client
      .from('challenge_groups')
      .select('challenge_id')
      .eq('id', groupId)
      .single()
      .then((data) => data['challenge_id'] as String);
  
  // Configurar stream para observar mudanças nos dados dos membros
  final updatesStreamFuture = challengeIdFuture.then((challengeId) {
    return _client
        .from('challenge_group_members')
        .select('user_id')
        .eq('group_id', groupId)
        .then((data) {
          final memberIds = data.map((item) => item['user_id'] as String).toList();
          
          return _client
              .from('challenge_progress')
              .stream(primaryKey: ['id'])
              .eq('challenge_id', challengeId)
              .inFilter('user_id', memberIds)
              .map((data) => data
                  .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
                  .toList());
        });
  });
  
  // Combinar streams para obter dados iniciais e atualizações
  return initialRankingFuture.asStream()
      .concatWith([updatesStreamFuture.asStream().switchMap((stream) => stream)]);
}
```

Com essa implementação, os usuários podem facilmente alternar entre visualizar o ranking geral de um desafio e o ranking específico de um grupo, com as posições e pontuações atualizadas em tempo real através do sistema de subscrição do Supabase.

### 5. Rastreamento de Água

#### 5.1 Interface
**Objetivo**: Monitorar consumo diário de água.
**Componentes**:
- Contador de copos
- Gráfico de progresso
- Botões para adicionar/remover copos
- Meta diária configurável

#### 5.2 Implementação
**Detalhes**:
- Tabela `water_intake` relaciona `user_id` com data e quantidade
- Métodos `addGlass()` e `removeGlass()` com otimismo de UI
- Histórico de consumo e médias
- Atualização automática de estatísticas via triggers SQL
- Implementado em `WaterIntakeViewModel` e `WaterIntakeRepository`

### 6. Sistema de Perfil e Progresso

#### 6.1 Perfil do Usuário
**Objetivo**: Exibir e permitir edição de informações pessoais.
**Componentes**:
- Foto de perfil
- Informações pessoais (nome, email)
- Estatísticas de atividades
- Metas definidas
- Histórico de treinos

#### 6.2 Dashboard de Progresso
**Objetivo**: Visualização do progresso geral.
**Funcionalidades**:
- Calendário com registro de atividades
- Gráficos de evolução
- Estatísticas de participação em desafios
- Metas e atual progresso

#### 6.3 Metas
**Objetivo**: Definir e acompanhar objetivos pessoais.
**Tipos de metas**:
- Peso corporal
- Frequência de treinos
- Consumo de água
- Personalizada
- Usa `UserGoal` como modelo e `GoalFormScreen` para entrada

### 7. Sistema de Treinos

#### 7.1 Lista de Treinos
**Objetivo**: Mostrar treinos disponíveis.
**Funcionalidades**:
- Categorização (força, cardio, etc.)
- Filtros por duração e nível
- Treinos favoritos
- Histórico de realizados

#### 7.2 Detalhe do Treino
**Objetivo**: Exibir informações e permitir início.
**Componentes**:
- Descrição e imagens
- Lista de exercícios com séries e repetições
- Botão para iniciar treino
- Opção para salvar como favorito

#### 7.3 Registro de Treino
**Objetivo**: Documentar conclusão para pontuação.
**Fluxo**:
- Seleção do treino realizado
- Entrada de informações adicionais
- Upload opcional de foto comprobatória
- Conversão em pontos para desafios
- Modal implementado em `RegisterExerciseSheet`

### 8. Sistema de Benefícios

#### 8.1 Lista de Benefícios
**Objetivo**: Exibir cupons e benefícios disponíveis.
**Funcionalidades**:
- Categorização por parceiros
- Requisitos de pontos para resgate
- Indicadores de disponibilidade e prazo
- Implementado em `BenefitsListScreen`

#### 8.2 Detalhe do Benefício
**Objetivo**: Exibir informações e permitir resgate.
**Componentes**:
- Descrição e termos
- Botão de resgate
- Implementado em `

### 9. Sistema de UI e Estilo

#### 9.1 Sistema de Cores
**Objetivo**: Fornecer uma paleta de cores consistente para toda a aplicação.

**Implementação Técnica**:
- **Arquivo Principal**: `lib/core/theme/app_colors.dart`
- **Arquivo de Redirecionamento**: `lib/core/constants/app_colors.dart` (para compatibilidade)
- **Funcionalidades**:
  - Sistema centralizado de cores
  - Cores principais e secundárias baseadas na identidade visual do Ray Club
  - Métodos de utilidade para transparência (`opacity10`, `opacity20`, etc.)
  - Gradientes predefinidos

**Paleta de Cores Principais**:
```dart
// Cores principais (conforme guia de design)
static const Color primary = Color(0xFFF8F1E7); // Bege principal (#F8F1E7)
static const Color secondary = Color(0xFFF38638); // Laranja/âmbar (#F38638)
static const Color accent = Color(0xFFCDA8F0); // Lilás/lavanda (#CDA8F0)

// Cores secundárias
static const Color textDark = Color(0xFF4D4D4D); // Cinza escuro (#4D4D4D)
static const Color backgroundMedium = Color(0xFFE6E6E6); // Cinza claro (#E6E6E6)
static const Color info = Color(0xFFEFB9B7); // Rosa claro/coral (#EFB9B7)
static const Color error = Color(0xFFEE583F); // Vermelho/laranja (#EE583F)
static const Color warning = Color(0xFFFEDC94); // Amarelo claro/pêssego (#FEDC94)
```

**Uso no Código**:
```dart
// Exemplo de uso em componentes
Container(
  decoration: BoxDecoration(
    color: AppColors.background,
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Text(
    'Exemplo de texto',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

**Métodos de Utilidade**:
```dart
// Métodos para substituir o withOpacity() (depreciado)
static Color opacity10(Color color) => color.withAlpha(26);  // ~10% de 255
static Color opacity20(Color color) => color.withAlpha(51);  // ~20% de 255
static Color opacity50(Color color) => color.withAlpha(128); // ~50% de 255
```

**Compatibilidade**:
A classe AppColors é acessível tanto via `core/theme/app_colors.dart` (recomendado) quanto via `core/constants/app_colors.dart` (redirecionamento) para garantir compatibilidade com código existente.

#### 9.2 Sistema de Tipografia
**Objetivo**: Padronizar estilos de texto na aplicação.

**Implementação Técnica**:
- **Arquivo Principal**: `lib/core/theme/app_typography.dart`
- **Arquivo de Redirecionamento**: `lib/core/constants/app_typography.dart` (para compatibilidade)

**Estilos Principais**:
```dart
// Headings com fonte Century Gothic
static const TextStyle headingLarge = TextStyle(
  fontFamily: 'CenturyGothic',
  fontSize: 28,
  fontWeight: FontWeight.w700,
  height: 1.2,
  color: AppColors.textDark,
  letterSpacing: -0.5,
);

// Body text
static const TextStyle bodyMedium = TextStyle(
  fontFamily: 'CenturyGothic',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: 1.4,
  color: AppColors.textDark,
);
```

**Uso no Código**:
```dart
Text(
  'Cabeçalho do app',
  style: AppTypography.headingLarge,
)
```

### 10. Sistema de Mappers

#### 10.1 Visão Geral
**Objetivo**: Realizar a conversão segura entre os dados retornados pelo Supabase e os modelos da aplicação.

**Implementação Técnica**:
- **Arquivos Principais**:
  - `lib/features/challenges/mappers/challenge_mapper.dart` 
  - `lib/features/benefits/mappers/benefit_mapper.dart`
- **Funcionalidades Principais**:
  - Conversão de convenções de nomenclatura (snake_case para camelCase)
  - Tratamento de valores nulos
  - Conversão segura de tipos de dados
  - Fornecimento de valores padrão para campos opcionais

**Problemas Resolvidos**:
- Erro "type 'Null' is not a subtype of type 'String' in type cast"
- Inconsistência entre formatos de dados do backend e frontend
- Manipulação segura de arrays e campos opcionais
- Conversão de tipos complexos (enums, datas, etc.)

#### 10.2 Challenge Mapper

**Implementação Técnica**:
- **Arquivo**: `lib/features/challenges/mappers/challenge_mapper.dart`
- **Classe**: `ChallengeMapper` com métodos estáticos
- **Método Principal**: `fromSupabase(Map<String, dynamic> json)`

**Funcionalidades**:
- Conversão de campos em snake_case (ex: `image_url`) para camelCase (ex: `imageUrl`)
- Tratamento seguro de arrays (requirements, participants, invitedUsers)
- Conversão segura de datas e integers
- Detecção inteligente de quando o mapper é necessário via `needsMapper()`

**Integração**:
```dart
// Em SupabaseChallengeRepository
Challenge _mapSupabaseToChallenge(Map<String, dynamic> json) {
  // Usar o ChallengeMapper em vez da implementação manual
  return ChallengeMapper.fromSupabase(json);
}
```

#### 10.3 Benefit Mapper

**Implementação Técnica**:
- **Arquivo**: `lib/features/benefits/mappers/benefit_mapper.dart`
- **Classe**: `BenefitMapper` com métodos estáticos
- **Método Principal**: `fromSupabase(Map<String, dynamic> json)`

**Funcionalidades**:
- Conversão de campos em snake_case para camelCase
- Mapeamento de strings de tipo para o enum `BenefitType` 
- Tratamento seguro de campos nulos com valores padrão
- Abordagem de fallback: tenta primeiro via `fromJson`, depois manualmente

**Método para Conversão de Enum**:
```dart
static BenefitType _parseBenefitType(dynamic value) {
  if (value == null) return BenefitType.coupon;
  if (value is BenefitType) return value;
  
  final typeStr = value.toString().toLowerCase();
  
  switch (typeStr) {
    case 'coupon': return BenefitType.coupon;
    case 'qrcode':
    case 'qr_code':
    case 'qr': return BenefitType.qrCode;
    case 'link':
    case 'url':
    case 'web': return BenefitType.link;
    default: return BenefitType.coupon;
  }
}
```

#### 10.4 Integração com Repositórios

**Padrão de Uso**:
1. Verificação se o mapper é necessário através do método `needsMapper()`
2. Uso prioritário do mapper para conversão segura de dados
3. Fallback para o método `fromJson` padrão quando apropriado

**Exemplo de Implementação**:
```dart
Future<Challenge> getChallengeById(String id) async {
  try {
    final response = await _client
        .from(_challengesTable)
        .select()
        .eq('id', id)
        .single();
    
    // Verificar se precisa de mapper personalizado
    if (ChallengeMapper.needsMapper(response)) {
      return ChallengeMapper.fromSupabase(response);
    }
    
    // Caso contrário, usar método padrão do Freezed
    return Challenge.fromJson(response);
  } catch (e, stackTrace) {
    throw _handleError(e, stackTrace, 'Erro ao buscar detalhes do desafio');
  }
}
```

**Métodos Auxiliares Comuns**:
- `_parseDateTime()`: Conversão segura de strings e timestamps para DateTime
- `_parseInt()`: Conversão segura de diversos formatos para int
- `_parseStringArray()`: Conversão segura de diversos formatos para List<String>
- `toSupabase()`: Conversão do modelo para o formato do Supabase (snake_case)

#### 10.5 Benefícios da Implementação

1. **Robustez**: Eliminação de erros de tipo nulo em tempo de execução
2. **Manutenção**: Centralização da lógica de conversão em classes específicas
3. **Clareza**: Separação de responsabilidades entre repositórios e conversão de dados
4. **Flexibilidade**: Adaptação a diversos formatos de dados do backend
5. **Testabilidade**: Facilitação da criação de testes unitários específicos para conversão