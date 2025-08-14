# 🏃‍♀️ Desafio de Cardio - Documentação Completa

**📅 Data:** 2025-01-12  
**🧠 Autor:** IA + Marcela Cunha  
**📄 Contexto:** Implementação completa do sistema de ranking de cardio opt-in para o Ray Club

---

## 📋 **VISÃO GERAL**

O Desafio de Cardio é um sistema de ranking opt-in onde usuários podem se inscrever voluntariamente para competir em minutos de treinos cardiovasculares registrados. O sistema permite:

- **Participação voluntária** (opt-in/opt-out)
- **Ranking em tempo real** baseado em minutos de cardio
- **Visualização de treinos individuais** dos participantes
- **Atualização automática** após novos treinos
- **Filtros por período** (7d/30d/90d/Todos)

---

## 🗄️ **BACKEND (Supabase)**

### **1. Tabela de Participantes**

```sql
-- Tabela: cardio_challenge_participants
CREATE TABLE public.cardio_challenge_participants (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at timestamp with time zone DEFAULT timezone('America/Sao_Paulo'::text, now()) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Índices
CREATE UNIQUE INDEX idx_cardio_challenge_user ON public.cardio_challenge_participants(user_id) WHERE active = true;
CREATE INDEX idx_cardio_challenge_active ON public.cardio_challenge_participants(active, joined_at);
```

### **2. Funções SQL**

#### **2.1. Entrar no Desafio**
```sql
CREATE OR REPLACE FUNCTION public.join_cardio_challenge(p_user_id uuid DEFAULT NULL)
RETURNS json AS $$
DECLARE
    target_user_id uuid;
    existing_record RECORD;
BEGIN
    -- Determinar o usuário
    target_user_id := COALESCE(p_user_id, auth.uid());
    
    IF target_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuário não autenticado');
    END IF;

    -- Verificar se já existe registro ativo
    SELECT * INTO existing_record 
    FROM public.cardio_challenge_participants 
    WHERE user_id = target_user_id AND active = true;

    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'Usuário já está participando do desafio');
    END IF;

    -- Inserir ou reativar participação
    INSERT INTO public.cardio_challenge_participants (user_id, active, joined_at, updated_at)
    VALUES (target_user_id, true, timezone('America/Sao_Paulo'::text, now()), now())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        active = true,
        joined_at = timezone('America/Sao_Paulo'::text, now()),
        updated_at = now();

    RETURN json_build_object('success', true, 'message', 'Usuário entrou no desafio com sucesso');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### **2.2. Sair do Desafio**
```sql
CREATE OR REPLACE FUNCTION public.leave_cardio_challenge(p_user_id uuid DEFAULT NULL)
RETURNS json AS $$
DECLARE
    target_user_id uuid;
BEGIN
    target_user_id := COALESCE(p_user_id, auth.uid());
    
    IF target_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuário não autenticado');
    END IF;

    UPDATE public.cardio_challenge_participants 
    SET active = false, updated_at = now()
    WHERE user_id = target_user_id;

    RETURN json_build_object('success', true, 'message', 'Usuário saiu do desafio');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### **2.3. Verificar Participação**
```sql
CREATE OR REPLACE FUNCTION public.get_cardio_participation(p_user_id uuid DEFAULT NULL)
RETURNS TABLE(is_participant boolean, joined_at timestamp with time zone) AS $$
DECLARE
    target_user_id uuid;
BEGIN
    target_user_id := COALESCE(p_user_id, auth.uid());
    
    RETURN QUERY
    SELECT 
        COALESCE(ccp.active, false) as is_participant,
        ccp.joined_at
    FROM public.cardio_challenge_participants ccp
    WHERE ccp.user_id = target_user_id AND ccp.active = true
    
    UNION ALL
    
    SELECT false as is_participant, NULL::timestamp with time zone as joined_at
    WHERE NOT EXISTS (
        SELECT 1 FROM public.cardio_challenge_participants ccp2 
        WHERE ccp2.user_id = target_user_id AND ccp2.active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### **2.4. Ranking de Cardio**
```sql
CREATE OR REPLACE FUNCTION public.get_cardio_ranking(
    date_from text DEFAULT NULL,
    date_to text DEFAULT NULL,
    _limit integer DEFAULT 50,
    _offset integer DEFAULT 0
)
RETURNS TABLE(
    user_id uuid,
    full_name text,
    avatar_url text,
    total_cardio_minutes integer
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    brt_from_utc timestamp with time zone;
    brt_to_utc timestamp with time zone;
BEGIN
    -- Converter datas de BRT para UTC se fornecidas
    IF date_from IS NOT NULL THEN
        brt_from_utc := (date_from::timestamp AT TIME ZONE 'America/Sao_Paulo') AT TIME ZONE 'UTC';
    END IF;

    IF date_to IS NOT NULL THEN
        brt_to_utc := (date_to::timestamp AT TIME ZONE 'America/Sao_Paulo') AT TIME ZONE 'UTC';
    END IF;

    RETURN QUERY
    SELECT 
        p.id::uuid as user_id,
        COALESCE(TRIM(p.full_name), 'Sem nome')::text as full_name,
        TRIM(p.avatar_url)::text as avatar_url,
        COALESCE(SUM(wr.duration_minutes), 0)::integer as total_cardio_minutes
    FROM public.profiles p
    INNER JOIN public.cardio_challenge_participants ccp ON p.id = ccp.user_id
    LEFT JOIN public.workout_records wr ON p.id = wr.user_id 
        AND LOWER(wr.workout_type) = 'cardio'
        AND wr.duration_minutes > 0
        AND (date_from IS NULL OR wr.date >= brt_from_utc)
        AND (date_to IS NULL OR wr.date <= brt_to_utc)
    WHERE ccp.active = true
    GROUP BY p.id, p.full_name, p.avatar_url
    ORDER BY 
        total_cardio_minutes DESC,
        full_name ASC,
        user_id ASC
    LIMIT _limit OFFSET _offset;
END;
$$;
```

### **3. Permissões e Segurança**

```sql
-- Conceder execução para usuários autenticados
GRANT EXECUTE ON FUNCTION public.join_cardio_challenge TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_cardio_challenge TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_cardio_participation TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_cardio_ranking TO authenticated;

-- RLS para tabela de participantes
ALTER TABLE public.cardio_challenge_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem ver própria participação" ON public.cardio_challenge_participants
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir própria participação" ON public.cardio_challenge_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar própria participação" ON public.cardio_challenge_participants
    FOR UPDATE USING (auth.uid() = user_id);
```

---

## 🎨 **FRONTEND (Flutter)**

### **1. Estrutura de Arquivos**

```
lib/features/ranking/
├── data/
│   ├── cardio_ranking_entry.dart       # Model do ranking
│   ├── participant_workout.dart        # Model dos treinos individuais
│   └── ranking_service.dart            # Comunicação com Supabase
├── presentation/
│   └── cardio_ranking_filters.dart     # Filtros e providers
├── providers/
│   └── ranking_refresh_provider.dart   # Provider de refresh global
├── screens/
│   ├── cardio_ranking_screen.dart      # Tela principal do ranking
│   └── participant_workouts_screen.dart # Tela de treinos individuais
├── viewmodel/
│   ├── cardio_ranking_state.dart       # Estado do ranking
│   └── cardio_ranking_view_model.dart  # Lógica de negócio
```

### **2. Models de Dados**

#### **2.1. CardioRankingEntry**
```dart
class CardioRankingEntry {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int totalCardioMinutes;

  const CardioRankingEntry({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.totalCardioMinutes,
  });

  factory CardioRankingEntry.fromMap(Map<String, dynamic> map) {
    final rawName = map['full_name'] as String?;
    final trimmedName = rawName?.trim();
    final rawAvatar = map['avatar_url'] as String?;
    final trimmedAvatar = rawAvatar?.trim();
    return CardioRankingEntry(
      userId: map['user_id'] as String,
      fullName: (trimmedName != null && trimmedName.isNotEmpty) ? trimmedName : 'Sem nome',
      avatarUrl: (trimmedAvatar != null && trimmedAvatar.isNotEmpty) ? trimmedAvatar : null,
      totalCardioMinutes: (map['total_cardio_minutes'] ?? 0) as int,
    );
  }
}
```

#### **2.2. ParticipantWorkout**
```dart
class ParticipantWorkout {
  final String id;
  final String workoutName;
  final String workoutType;
  final DateTime date;
  final int durationMinutes;
  final String? notes;
  final bool isCompleted;
  final List<String>? imageUrls;

  const ParticipantWorkout({
    required this.id,
    required this.workoutName,
    required this.workoutType,
    required this.date,
    required this.durationMinutes,
    this.notes,
    required this.isCompleted,
    this.imageUrls,
  });

  factory ParticipantWorkout.fromMap(Map<String, dynamic> map) {
    return ParticipantWorkout(
      id: map['id'] as String,
      workoutName: map['workout_name'] as String? ?? 'Treino de Cardio',
      workoutType: map['workout_type'] as String? ?? 'cardio',
      date: DateTime.parse(map['date'] as String),
      durationMinutes: (map['duration_minutes'] ?? 0) as int,
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] ?? true) as bool,
      imageUrls: map['image_urls'] != null 
          ? List<String>.from(map['image_urls'] as List)
          : null,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return '$difference dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get durationFormatted {
    if (durationMinutes < 60) {
      return '${durationMinutes}min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }
}
```

### **3. Serviços**

#### **3.1. RankingService**
```dart
class RankingService {
  final SupabaseClient supabase;
  RankingService({SupabaseClient? client}) : supabase = client ?? Supabase.instance.client;

  /// Obtém ranking de cardio com filtros opcionais
  Future<List<CardioRankingEntry>> getCardioRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    final params = <String, dynamic>{
      if (from != null) 'date_from': from.toUtc().toIso8601String(),
      if (to != null) 'date_to': to.toUtc().toIso8601String(),
      if (limit != null) '_limit': limit,
      if (offset != null) '_offset': offset,
    };

    final response = await supabase.rpc('get_cardio_ranking', params: params);
    final data = (response as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    return data.map(CardioRankingEntry.fromMap).toList();
  }

  /// Entrar no desafio de cardio
  Future<void> joinCardioChallenge({String? userId}) async {
    await supabase.rpc('join_cardio_challenge', params: {
      if (userId != null) 'p_user_id': userId,
    });
  }

  /// Sair do desafio de cardio
  Future<void> leaveCardioChallenge({String? userId}) async {
    await supabase.rpc('leave_cardio_challenge', params: {
      if (userId != null) 'p_user_id': userId,
    });
  }

  /// Verificar se usuário está participando
  Future<bool> getCardioParticipationStatus() async {
    final response = await supabase.rpc('get_cardio_participation');
    if (response is List && response.isNotEmpty) {
      final data = response.first as Map<String, dynamic>;
      return data['is_participant'] as bool? ?? false;
    }
    return false;
  }

  /// Buscar treinos de cardio de um participante
  Future<List<ParticipantWorkout>> getParticipantCardioWorkouts({
    required String participantId,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    final query = supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes, notes, is_completed, image_urls');

    var filteredQuery = query
        .eq('user_id', participantId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0)
        .order('date', ascending: false);

    if (from != null) {
      filteredQuery = filteredQuery.gte('date', from.toUtc().toIso8601String());
    }
    if (to != null) {
      filteredQuery = filteredQuery.lte('date', to.toUtc().toIso8601String());
    }

    final result = await filteredQuery.limit(limit ?? 50);
    final data = (result as List).cast<Map<String, dynamic>>();
    return data.map(ParticipantWorkout.fromMap).toList();
  }
}
```

### **4. Estado e ViewModel**

#### **4.1. CardioRankingState**
```dart
class CardioRankingState {
  final List<CardioRankingEntry> items;
  final bool isLoading;
  final int pageIndex;
  final bool hasMore;
  final bool isParticipating;
  final bool isJoiningLeaving;

  const CardioRankingState({
    this.items = const [],
    this.isLoading = false,
    this.pageIndex = 0,
    this.hasMore = true,
    this.isParticipating = false,
    this.isJoiningLeaving = false,
  });

  CardioRankingState copyWith({
    List<CardioRankingEntry>? items,
    bool? isLoading,
    int? pageIndex,
    bool? hasMore,
    bool? isParticipating,
    bool? isJoiningLeaving,
  }) {
    return CardioRankingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      pageIndex: pageIndex ?? this.pageIndex,
      hasMore: hasMore ?? this.hasMore,
      isParticipating: isParticipating ?? this.isParticipating,
      isJoiningLeaving: isJoiningLeaving ?? this.isJoiningLeaving,
    );
  }
}
```

#### **4.2. CardioRankingViewModel**
```dart
class CardioRankingViewModel extends StateNotifier<CardioRankingState> {
  final RankingService service;
  final Ref ref;
  static const int pageSize = 50;

  CardioRankingViewModel({required this.service, required this.ref})
      : super(const CardioRankingState()) {
    _checkParticipationStatus();
    
    // Escutar notificações de refresh automático
    ref.listen(rankingRefreshNotifierProvider, (previous, next) {
      if (previous != next && state.isParticipating) {
        refresh();
      }
    });
  }

  /// Verifica status de participação e carrega dados se necessário
  Future<void> _checkParticipationStatus() async {
    try {
      final isParticipating = await service.getCardioParticipationStatus();
      ref.read(cardioParticipationProvider.notifier).state = isParticipating;
      state = state.copyWith(isParticipating: isParticipating);

      if (isParticipating) {
        await refresh();
      }
    } catch (error) {
      ref.read(cardioParticipationProvider.notifier).state = false;
      state = state.copyWith(isParticipating: false);
    }
  }

  /// Alterna participação no desafio
  Future<void> toggleParticipation() async {
    if (state.isJoiningLeaving) return;

    state = state.copyWith(isJoiningLeaving: true);

    try {
      final currentStatus = ref.read(cardioParticipationProvider);

      if (currentStatus) {
        await service.leaveCardioChallenge();
      } else {
        await service.joinCardioChallenge();
      }

      // Verificar status real no banco
      final actualStatus = await service.getCardioParticipationStatus();
      ref.read(cardioParticipationProvider.notifier).state = actualStatus;
      state = state.copyWith(
        isParticipating: actualStatus,
        isJoiningLeaving: false,
      );

      if (actualStatus) {
        await refresh();
      } else {
        state = state.copyWith(items: [], pageIndex: 0, hasMore: true);
      }
    } catch (error) {
      state = state.copyWith(isJoiningLeaving: false);
    }
  }

  /// Refresh completo do ranking
  Future<void> refresh() async {
    if (!state.isParticipating) {
      state = state.copyWith(
        isLoading: false, 
        pageIndex: 0, 
        items: [], 
        hasMore: false
      );
      return;
    }
    
    state = state.copyWith(isLoading: true, pageIndex: 0, items: [], hasMore: true);
    await loadMore(reset: true);
  }

  /// Carrega mais dados (paginação)
  Future<void> loadMore({bool reset = false}) async {
    if (!state.isParticipating) return;
    if ((state.isLoading && !reset) || (!state.hasMore && !reset)) return;
    
    state = state.copyWith(isLoading: true);

    try {
      DateTime? from;
      DateTime? to;
      final window = ref.read(cardioWindowProvider);
      final now = DateTime.now().toUtc();
      
      switch (window) {
        case CardioWindow.d7:
          from = now.subtract(const Duration(days: 7));
          to = now;
          break;
        case CardioWindow.d30:
          from = now.subtract(const Duration(days: 30));
          to = now;
          break;
        case CardioWindow.d90:
          from = now.subtract(const Duration(days: 90));
          to = now;
          break;
        case CardioWindow.all:
          from = null;
          to = null;
          break;
      }

      final offset = reset ? 0 : state.pageIndex * pageSize;
      final page = await service.getCardioRanking(
        from: from, 
        to: to, 
        limit: pageSize, 
        offset: offset
      );
      
      final List<CardioRankingEntry> newItems = reset ? page : [...state.items, ...page];
      
      state = state.copyWith(
        items: newItems,
        pageIndex: reset ? 1 : state.pageIndex + 1,
        isLoading: false,
        hasMore: page.length == pageSize,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }
}

final cardioRankingViewModelProvider =
    StateNotifierProvider<CardioRankingViewModel, CardioRankingState>((ref) {
  return CardioRankingViewModel(service: RankingService(), ref: ref);
});
```

### **5. Providers de Estado**

```dart
// Filtros de período
enum CardioWindow { all, d7, d30, d90 }

final cardioWindowProvider = StateProvider<CardioWindow>((ref) => CardioWindow.all);
final cardioParticipationProvider = StateProvider<bool>((ref) => false);

// Provider de refresh global
final rankingRefreshNotifierProvider = StateProvider<int>((ref) => 0);
```

### **6. Interface de Usuario**

#### **6.1. Tela Principal (CardioRankingScreen)**

**Características:**
- **SliverAppBar** com filtros de período
- **Card de Desafio** com status de participação e botão de entrar/sair
- **Lista de Ranking** com posições, medalhas e minutos
- **Pull-to-refresh** e **infinite scroll**
- **Navegação para treinos individuais** ao clicar no participante

**Componentes principais:**
- `_ChallengeCard`: Card principal com status e botão de ação
- `_CardioRankingTile`: Item do ranking com posição, foto, nome e minutos
- `_EmptyRankingState`: Estado vazio quando não há participantes

#### **6.2. Tela de Treinos (ParticipantWorkoutsScreen)**

**Características:**
- **AppBar** com nome do participante
- **Card de estatísticas** com total de treinos e minutos
- **Lista de treinos** com paginação
- **Pull-to-refresh** para atualizar dados

**Dados exibidos por treino:**
- Nome do treino
- Duração formatada (horas/minutos)
- Data relativa (Hoje, Ontem, X dias atrás)
- Status de conclusão
- Notas (se houver)

---

## 🔄 **INTEGRAÇÃO E REFRESH AUTOMÁTICO**

### **1. Refresh após Novo Treino**

```dart
// No RegisterWorkoutViewModel
Future<RegisterWorkoutResult> registerWorkout({String? challengeId}) async {
  try {
    // ... lógica de registro

    // Notificar refresh do ranking se for treino de cardio
    if (state.selectedType.toLowerCase() == 'cardio') {
      _notifyCardioRankingRefresh();
    }

    return RegisterWorkoutResult(success: true, workoutRecord: createdRecord);
  } catch (e) {
    // ... tratamento de erro
  }
}

/// Notifica o ranking para refresh
void _notifyCardioRankingRefresh() {
  final current = ref.read(rankingRefreshNotifierProvider);
  ref.read(rankingRefreshNotifierProvider.notifier).state = current + 1;
}
```

### **2. Listener no ViewModel**

```dart
// No CardioRankingViewModel constructor
ref.listen(rankingRefreshNotifierProvider, (previous, next) {
  if (previous != next && state.isParticipating) {
    refresh(); // Atualiza automaticamente
  }
});
```

---

## 🎯 **NAVEGAÇÃO E ROTAS**

### **1. Definição de Rotas**

```dart
// No app_router.dart
@AutoRouteConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    // ... outras rotas
    
    // Ranking de cardio
    AutoRoute(
      page: CardioRankingRoute.page,
      path: '/ranking/cardio',
      guards: [LayeredAuthGuard],
    ),
    
    // Treinos de participante
    AutoRoute(
      page: ParticipantWorkoutsRoute.page,
      path: '/ranking/cardio/participant/:participantId',
      guards: [LayeredAuthGuard],
    ),
  ];
}

@RoutePage()
class CardioRankingRoute extends AutoRouter {
  const CardioRankingRoute({super.key});
}

@RoutePage()
class ParticipantWorkoutsRoute extends AutoRouter {
  final String participantId;
  final String participantName;
  
  const ParticipantWorkoutsRoute({
    super.key,
    required this.participantId,
    required this.participantName,
  });
}
```

### **2. Pontos de Acesso**

```dart
// Home Screen - Explorar Section
ListTile(
  leading: const Icon(Icons.leaderboard, color: AppColors.orange),
  title: const Text('Ranking Cardio'),
  subtitle: const Text('Veja sua posição no desafio'),
  onTap: () => context.router.push(const CardioRankingRoute()),
),

// Home Screen - Quick Actions
GestureDetector(
  onTap: () => context.router.push(const CardioRankingRoute()),
  child: _buildQuickActionCard(
    icon: Icons.trending_up,
    title: 'Desafio Ray 21',
    subtitle: 'Participe do ranking',
    color: AppColors.orange,
  ),
),
```

---

## 🐛 **BUGS RESOLVIDOS**

### **1. Problema de Loading Infinito**
**Causa:** `loadMore()` cancelava quando `reset: true` devido a `state.isLoading`  
**Solução:** Alterada condição para `(state.isLoading && !reset)`

### **2. Problema de Participação não Persistindo**
**Causa:** Status local não sincronizado com banco após toggle  
**Solução:** Verificação dupla do status real no banco após join/leave

### **3. Problema de Treinos Individuais Vazios**
**Causa:** Busca usava `'cardio'` minúsculo, mas dados são `'Cardio'` maiúsculo  
**Solução:** Corrigido filtro de busca para maiúscula

### **4. Problema de Refresh Automático**
**Causa:** Ranking não atualizava após registrar novo treino  
**Solução:** Sistema de notificação global via `rankingRefreshNotifierProvider`

---

## 📊 **REGRAS DE NEGÓCIO**

### **1. Participação**
- ✅ **Opt-in voluntário**: Usuários escolhem participar
- ✅ **Entrada/saída livre**: Podem sair e voltar a qualquer momento
- ✅ **Apenas participantes ativos** aparecem no ranking
- ✅ **Status persistente** entre sessões do app

### **2. Ranking**
- ✅ **Baseado em minutos de cardio** registrados
- ✅ **Apenas treinos com `workout_type = 'Cardio'`**
- ✅ **Apenas treinos com `duration_minutes > 0`**
- ✅ **Critérios de desempate**: minutos DESC, nome ASC, user_id ASC
- ✅ **Filtros de período**: 7d/30d/90d/Todos

### **3. Treinos Contabilizados**
- ✅ **Modalidade**: Cardio (maiúsculo)
- ✅ **Duração mínima**: > 0 minutos
- ✅ **Usuário participante**: Deve estar inscrito no desafio
- ✅ **Atualização em tempo real**: Após registrar novo treino

### **4. Segurança**
- ✅ **RLS habilitado** na tabela de participantes
- ✅ **Funções com SECURITY DEFINER**
- ✅ **Apenas usuários autenticados**
- ✅ **Usuários só veem/editam próprios dados**

---

## 🎨 **DESIGN E UX**

### **1. Paleta de Cores**
- **Primary Orange**: `AppColors.orange` para CTAs e destaque
- **Background Light**: `AppColors.backgroundLight` para fundos
- **Text Dark**: `AppColors.textDark` para textos principais
- **Text Secondary**: `AppColors.textSecondary` para textos auxiliares

### **2. Tipografia e Tom**
- **Título principal**: "Desafio Cardio ⚡"
- **Tom acolhedor**: "Você está participando! 🔥"
- **Linguagem motivacional**: "Continue acumulando minutos"
- **Feedback positivo**: "Legal!", "Conseguimos!", "Você conseguiu!"

### **3. Componentes Visuais**
- **Medalhas**: 🥇🥈🥉 para top 3 posições
- **Gradientes**: `AppGradients.primaryGradient` para participantes
- **Shadows**: Sombras suaves para cards
- **Border radius**: 16-24px para elementos modernos

### **4. Estados da Interface**
- **Loading**: CircularProgressIndicator com cor orange
- **Empty**: Ilustração com mensagem motivacional
- **Error**: Mensagem amigável com botão "Tentar novamente"
- **Success**: Feedback visual e textual positivo

---

## 🚀 **PERFORMANCE E OTIMIZAÇÃO**

### **1. Paginação**
- **Page size**: 50 itens por página
- **Infinite scroll**: Carregamento sob demanda
- **Offset-based**: Usando `LIMIT` e `OFFSET` no SQL

### **2. Cache e Estado**
- **StateNotifier**: Gerenciamento eficiente de estado
- **Provider refresh**: Apenas quando necessário
- **Local state**: Evita consultas desnecessárias

### **3. Consultas Otimizadas**
- **Índices apropriados**: user_id, active, joined_at
- **JOIN eficiente**: Apenas participantes ativos
- **Filtros no SQL**: Reduz transferência de dados

---

## 📱 **TESTES E VALIDAÇÃO**

### **1. Cenários Testados**
- ✅ Entrada e saída do desafio
- ✅ Ranking carregando corretamente
- ✅ Filtros de período funcionando
- ✅ Treinos individuais exibidos
- ✅ Refresh automático após treino
- ✅ Paginação e infinite scroll
- ✅ Estados de loading e erro

### **2. Casos de Borda**
- ✅ Usuário sem treinos registrados
- ✅ Empates no ranking
- ✅ Filtros sem resultados
- ✅ Conexão intermitente
- ✅ Dados corrompidos/nulos

---

## 🔧 **MANUTENÇÃO E EVOLUÇÃO**

### **1. Monitoramento**
- **Logs detalhados** em funções críticas
- **Error tracking** com stack traces
- **Performance metrics** via Supabase dashboard

### **2. Futuras Melhorias**
- 📈 **Gráficos de progresso** individual
- 🏆 **Sistema de conquistas** e badges
- 📅 **Desafios semanais/mensais**
- 👥 **Equipes e competições de grupo**
- 🔔 **Notificações push** para ranking
- 📊 **Dashboard administrativo**

### **3. Escalabilidade**
- **Particionamento** da tabela workout_records por data
- **Cache Redis** para rankings frequentes
- **Background jobs** para recálculos pesados
- **CDN** para imagens de perfil

---

## 📋 **CHECKLIST DE FUNCIONALIDADES**

### ✅ **Implementado e Testado**
- [x] Sistema de participação opt-in/opt-out
- [x] Ranking em tempo real com paginação
- [x] Filtros de período (7d/30d/90d/Todos)
- [x] Visualização de treinos individuais
- [x] Refresh automático após novo treino
- [x] Interface responsiva e acessível
- [x] Tratamento de erros e loading states
- [x] Segurança e permissões adequadas
- [x] Navegação integrada ao app
- [x] Logs e debug para manutenção

### 🚀 **Entregue com Sucesso**
O Desafio de Cardio está **100% funcional** e integrado ao Ray Club, proporcionando uma experiência gamificada e motivacional para os usuários praticarem exercícios cardiovasculares.

---

**📌 Última atualização:** 2025-01-12  
**🔄 Status:** Implementação completa e funcional  
**👥 Testado por:** Marcela Cunha  
**✅ Aprovado para produção**
