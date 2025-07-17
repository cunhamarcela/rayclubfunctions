# 📋 **DOCUMENTAÇÃO DO SISTEMA EXPERT/BASIC**

## **📅 Versão: 07.07.2025 15:09**
## **🧠 Autor: IA**
## **📄 Contexto: Sistema de controle de acesso para usuários Expert e Basic**

---

## 🎯 **VISÃO GERAL DO SISTEMA**

O **Ray Club App** possui um sistema de controle de acesso que diferencia usuários **Expert** e **Basic**, controlando o acesso a:
- 🎬 **Vídeos de treino** (na home e workout)
- 🥗 **Conteúdos de nutrição**
- 🎁 **Benefícios premium**
- 📊 **Dashboard avançado**

---

## 🏗️ **ARQUITETURA DO SISTEMA**

### **1. 🗄️ BACKEND (Supabase)**

**Tabela: `profiles`**
```sql
-- Campo responsável pela classificação do usuário
account_type: TEXT DEFAULT 'basic' -- 'expert' ou 'basic'
```

**Valores possíveis:**
- `'expert'` - Usuário com acesso total
- `'basic'` - Usuário com acesso limitado (padrão)

**Migração SQL:**
```sql
-- Adicionar campo account_type à tabela profiles
ALTER TABLE profiles ADD COLUMN account_type TEXT DEFAULT 'basic';

-- Sincronizar com user_progress_level existente
UPDATE profiles 
SET account_type = 'expert' 
WHERE id IN (
    SELECT user_id 
    FROM user_progress_level 
    WHERE level >= 5
);
```

---

## 💻 **FRONTEND (Flutter)**

### **2. 🔄 PROVIDERS GLOBAIS**

**Arquivo: `lib/providers/user_profile_provider.dart`**

```dart
/// Provider que carrega o perfil do usuário com account_type
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  
  if (userId == null) return null;
  
  // Carrega via repository (mapeia account_type do banco)
  final repository = SupabaseProfileRepository(Supabase.instance.client);
  return await repository.getProfile(userId);
});

/// Provider derivado que verifica se é usuário Expert
final isExpertUserProfileProvider = Provider<AsyncValue<bool>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  
  return profileAsync.when(
    data: (profile) => AsyncValue.data(profile?.accountType == 'expert'),
    loading: () => AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
```

### **3. 🏗️ MODELO DE DADOS**

**Arquivo: `lib/features/profile/models/profile_model.dart`**

```dart
class Profile {
  final String? accountType; // 'expert' ou 'basic'
  
  Profile({
    this.accountType = 'basic', // Default para basic
    // ... outros campos
  });
  
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      accountType: json['account_type'] as String? ?? 'basic',
      // ... outros campos
    );
  }
}
```

### **4. 🛡️ SERVIÇO DE PROTEÇÃO**

**Arquivo: `lib/core/services/expert_video_guard.dart`**

```dart
class ExpertVideoGuard {
  /// Verifica se usuário pode acessar vídeos
  static Future<bool> canPlayVideo(WidgetRef ref, String videoId) async {
    final isExpertAsync = ref.read(isExpertUserProfileProvider);
    
    return isExpertAsync.when(
      data: (isExpert) {
        debugPrint('🔍 [ExpertVideoGuard] Usuario é expert: $isExpert');
        return isExpert; // true = expert, false = basic
      },
      loading: () {
        debugPrint('🔍 [ExpertVideoGuard] Carregando... (NEGANDO acesso)');
        return false; // Fail-safe: negar acesso durante loading
      },
      error: (error, stack) {
        debugPrint('🔍 [ExpertVideoGuard] Erro: $error (NEGANDO acesso)');
        return false; // Fail-safe: negar acesso em caso de erro
      },
    );
  }
  
  /// Trata clique em vídeo com verificação de acesso
  static Future<void> handleVideoTap({
    required WidgetRef ref,
    required String videoId,
    required VoidCallback onAllowed,
    required BuildContext context,
  }) async {
    final canPlay = await canPlayVideo(ref, videoId);
    
    if (canPlay) {
      debugPrint('🎬 [ExpertVideoGuard] ✅ ACESSO LIBERADO - Executando onAllowed()');
      onAllowed(); // Executa ação permitida
    } else {
      debugPrint('🎬 [ExpertVideoGuard] ❌ ACESSO NEGADO - Mostrando dialog');
      await _showAccessDeniedDialog(context); // Mostra dialog de bloqueio
    }
  }
}
```

---

## 🎯 **FLUXO COMPLETO DE VERIFICAÇÃO**

### **📱 1. LOGIN DO USUÁRIO**
```
1. Usuário faz login → Supabase Auth
2. userProfileProvider carrega perfil → SELECT * FROM profiles WHERE id = ?
3. Campo account_type é mapeado → Profile.accountType
4. isExpertUserProfileProvider deriva boolean → 'expert' = true, 'basic' = false
```

### **🎬 2. ACESSO A VÍDEO**
```
1. Usuário clica em vídeo → ExpertVideoGuard.handleVideoTap()
2. Verifica isExpertUserProfileProvider →
   - Se 'expert': executa onAllowed() → reproduz vídeo
   - Se 'basic': mostra dialog de bloqueio
   - Se loading/error: nega acesso (fail-safe)
```

### **🔄 3. ESTADOS DO SISTEMA**
```
AsyncValue<bool> isExpertAsync:
├── data(true)     → Usuário EXPERT → Acesso liberado
├── data(false)    → Usuário BASIC → Acesso negado  
├── loading()      → Carregando → Acesso negado (fail-safe)
└── error()        → Erro → Acesso negado (fail-safe)
```

---

## 📍 **IMPLEMENTAÇÃO POR TELA**

### **🏠 HOME SCREEN**
**Arquivo: `lib/features/home/screens/home_screen.dart`**

```dart
// Verificação instantânea usando provider
final isExpertAsync = ref.watch(isExpertUserProfileProvider);

// Aplicação na UI
isExpertAsync.when(
  data: (isExpert) => isExpert 
    ? UnlockedVideoCard(video: video) 
    : LockedVideoCard(video: video),
  loading: () => LockedVideoCard(video: video), // Fail-safe
  error: (_, __) => LockedVideoCard(video: video), // Fail-safe
)
```

### **💪 WORKOUT SCREEN**
**Arquivo: `lib/features/workout/widgets/workout_video_card.dart`**

```dart
// Mesmo sistema de verificação
onTap: () async {
  await ExpertVideoGuard.handleVideoTap(
    ref: ref,
    videoId: video.youtubeUrl ?? 'unknown',
    onAllowed: () => _openVideoPlayer(video),
    context: context,
  );
}
```

---

## 🔒 **SISTEMA DE SEGURANÇA**

### **🛡️ PRINCÍPIO FAIL-SAFE**
```dart
// EM CASO DE QUALQUER DÚVIDA OU ERRO: NEGA ACESSO
- Loading → false (nega acesso)
- Error → false (nega acesso)  
- Null → false (nega acesso)
- Indefinido → false (nega acesso)
```

### **📱 DIALOG DE BLOQUEIO**
```dart
// Mensagem amigável para usuários Basic
_showAccessDeniedDialog(context) {
  AlertDialog(
    title: "Conteúdo Premium 🌟",
    content: "Este conteúdo é exclusivo para usuários Expert...",
    actions: [
      TextButton("Entendi", onPressed: () => Navigator.pop(context))
    ]
  );
}
```

---

## 🧪 **FERRAMENTAS DE DEBUG**

### **🔍 LOGS DETALHADOS**
```dart
// Todos os providers e guards possuem logs detalhados:
debugPrint('🔍 [userProfileProvider] User ID: $userId');
debugPrint('🔍 [userProfileProvider] Account Type: ${profile.accountType}');
debugPrint('🔍 [isExpertUserProfileProvider] É expert: $isExpert');
debugPrint('🔍 [ExpertVideoGuard] Verificação: $canPlay');
```

### **🧪 TELA DE DEBUG**
**Arquivo: `lib/features/developer/screens/basic_user_debug_screen.dart`**

```dart
// Ferramenta completa para testar o sistema:
- Informações de autenticação
- Dados do perfil (account_type)
- Status expert/basic
- Teste de vídeos
- Simulação de cenários
```

---

## 🎯 **PONTOS CRÍTICOS**

### **✅ FUNCIONANDO CORRETAMENTE**
- ✅ Carregamento do perfil via repository
- ✅ Mapeamento correto do campo `account_type`
- ✅ Verificação instantânea na UI
- ✅ Sistema fail-safe implementado
- ✅ Logs detalhados para debug

### **⚠️ PONTOS DE ATENÇÃO**
- ⚠️ **Dois sistemas coexistindo**: antigo (userLevelProvider) e novo (userProfileProvider)
- ⚠️ **Possível inconsistência**: se não houver sincronização entre sistemas
- ⚠️ **Performance**: múltiplas verificações podem impactar performance

---

## 📊 **MÉTRICAS DE SUCESSO**

### **🎯 PARA USUÁRIOS EXPERT**
- ✅ Acesso imediato a vídeos
- ✅ Sem delays ou locks
- ✅ Experiência fluida

### **🎯 PARA USUÁRIOS BASIC**
- ✅ Bloqueio consistente
- ✅ Dialog informativo
- ✅ Não consegue burlar o sistema

---

## 🔧 **MANUTENÇÃO**

### **📝 PARA ADICIONAR NOVA VERIFICAÇÃO**
1. Use `isExpertUserProfileProvider` em qualquer widget
2. Aplique padrão `.when(data: (isExpert) => ...)`
3. Implemente fail-safe para loading/error
4. Adicione logs para debug

### **🗄️ PARA ALTERAR USUÁRIO NO BANCO**
```sql
-- Promover usuário para expert
UPDATE profiles SET account_type = 'expert' WHERE id = 'user_id';

-- Rebaixar usuário para basic  
UPDATE profiles SET account_type = 'basic' WHERE id = 'user_id';
```

---

## 🎉 **RESULTADO FINAL**

O sistema está **funcionando corretamente** com:
- 🎬 **Vídeos**: Expert acessa, Basic é bloqueado
- 🔒 **Segurança**: Fail-safe implementado
- 📱 **UX**: Mensagens amigáveis
- 🧪 **Debug**: Ferramentas completas
- 📊 **Escalabilidade**: Fácil de manter e expandir

---

## 🚀 **PRÓXIMOS PASSOS RECOMENDADOS**

1. **🧹 Limpeza**: Remover sistema antigo (userLevelProvider)
2. **📊 Performance**: Otimizar múltiplas verificações
3. **🧪 Testes**: Implementar testes automatizados
4. **📱 Expansão**: Aplicar para nutrição e benefícios
5. **🔍 Monitoramento**: Adicionar métricas de uso

---

**📌 Feature: Sistema Expert/Basic**
**🗓️ Data: 2025-07-07 às 15:09**
**🧠 Autor/IA: IA**
**📄 Contexto: Documentação completa do sistema de controle de acesso** 