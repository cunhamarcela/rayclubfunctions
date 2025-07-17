# 🚀 Implementação no Flutter - Sistema de Vídeos por Nível

## 📋 **Como Implementar no App**

### **OPÇÃO 1: Usar Função RPC (Recomendado)**

```dart
// Em seu repository ou service
class VideoRepository {
  final SupabaseClient _supabase;
  
  VideoRepository(this._supabase);
  
  Future<List<Map<String, dynamic>>> getVideosForCurrentUser() async {
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) {
      return []; // Usuário não logado = sem vídeos
    }
    
    try {
      // Usar a função RPC que controla o acesso automaticamente
      final response = await _supabase.rpc(
        'get_videos_for_user',
        params: {'user_id_param': userId}
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao buscar vídeos: $e');
      return []; // Em caso de erro, não mostrar vídeos
    }
  }
  
  // Verificar se usuário é expert (opcional)
  Future<bool> isCurrentUserExpert() async {
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) return false;
    
    try {
      final result = await _supabase.rpc(
        'check_if_user_is_expert',
        params: {'check_user_id': userId}
      );
      
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}
```

### **OPÇÃO 2: Verificar Nível Primeiro**

```dart
class VideoService {
  final SupabaseClient _supabase;
  
  VideoService(this._supabase);
  
  Future<List<Map<String, dynamic>>> getVideos() async {
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) {
      return []; // Não logado = sem vídeos
    }
    
    // Primeiro verificar se é expert
    final isExpert = await _checkIfUserIsExpert(userId);
    
    if (isExpert) {
      // Expert: buscar todos os vídeos
      final response = await _supabase
          .from('workout_videos')
          .select()
          .order('order_index');
      
      return List<Map<String, dynamic>>.from(response);
    } else {
      // Basic: retornar lista vazia
      return [];
    }
  }
  
  Future<bool> _checkIfUserIsExpert(String userId) async {
    try {
      final result = await _supabase.rpc(
        'check_if_user_is_expert',
        params: {'check_user_id': userId}
      );
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}
```

### **OPÇÃO 3: Provider com Riverpod**

```dart
// Provider do repository
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return VideoRepository(supabase);
});

// Provider dos vídeos
final videosProvider = FutureProvider<List<WorkoutVideo>>((ref) async {
  final repository = ref.watch(videoRepositoryProvider);
  final videosData = await repository.getVideosForCurrentUser();
  
  return videosData.map((data) => WorkoutVideo.fromJson(data)).toList();
});

// Provider do status expert
final isExpertProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(videoRepositoryProvider);
  return await repository.isCurrentUserExpert();
});

// No widget
class VideosScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videosProvider);
    final isExpertAsync = ref.watch(isExpertProvider);
    
    return videosAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return isExpertAsync.when(
            data: (isExpert) => isExpert 
              ? const Text('Nenhum vídeo disponível')
              : const UpgradeToExpertWidget(),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const UpgradeToExpertWidget(),
          );
        }
        
        return VideosList(videos: videos);
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

## 🎯 **Comportamento Esperado**

### **Usuário EXPERT:**
- `getVideosForCurrentUser()` retorna todos os 40 vídeos
- `isCurrentUserExpert()` retorna `true`
- App mostra todos os vídeos normalmente

### **Usuário BASIC:**
- `getVideosForCurrentUser()` retorna lista vazia `[]`
- `isCurrentUserExpert()` retorna `false`
- App mostra tela de upgrade ou placeholder

### **Usuário NÃO LOGADO:**
- `getVideosForCurrentUser()` retorna lista vazia `[]`
- `isCurrentUserExpert()` retorna `false`
- App mostra tela de login

## 🔧 **Vantagens desta Abordagem:**

1. **✅ Segurança no Backend**: Controle total no Supabase
2. **✅ Performance**: Uma única chamada RPC
3. **✅ Simplicidade**: Não precisa gerenciar RLS no Flutter
4. **✅ Testável**: Pode testar com qualquer user_id
5. **✅ Flexível**: Fácil de modificar regras no futuro

## 🧪 **Para Testar:**

1. Execute o script `sql/fix_rls_without_auth_uid.sql`
2. Implemente uma das opções acima
3. Teste com usuários basic e expert
4. Verifique se funciona como esperado

O sistema agora não depende de `auth.uid()` e funciona diretamente com os `user_id` da sua tabela! 🎉 