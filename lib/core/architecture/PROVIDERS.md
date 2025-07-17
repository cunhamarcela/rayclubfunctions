# Ray Club App - Guia de Organização de Providers

Este documento define a estrutura padronizada para organização de providers no aplicativo Ray Club, seguindo o padrão MVVM com Riverpod.

## Organização de Providers

### 1. Providers de Recursos Globais

Os providers globais que fornecem serviços compartilhados em toda a aplicação devem ser definidos em:

```
lib/core/providers/
```

Exemplos:
- `supabase_providers.dart` - Acesso ao cliente Supabase
- `dio_provider.dart` - Cliente HTTP
- `shared_preferences_provider.dart` - Acesso a SharedPreferences
- `environment_provider.dart` - Configurações de ambiente

### 2. Providers por Feature

Cada feature deve ter seus providers específicos organizados da seguinte forma:

```
lib/features/feature_name/providers/
```

#### Convenções de Nomenclatura:

1. O arquivo principal de providers de uma feature deve ser nomeado: `feature_providers.dart`
   - Exemplo: `challenge_providers.dart`, `auth_providers.dart`

2. Para features complexas, os providers podem ser separados em múltiplos arquivos por funcionalidade.
   - Exemplo: `challenge_ranking_providers.dart`, `challenge_group_providers.dart`

#### Estrutura Interna dos Providers:

Os providers de uma feature devem seguir esta ordem:

1. **Repository Providers**: Fornecem acesso aos repositories
   ```dart
   final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
     final client = ref.watch(supabaseClientProvider);
     return SupabaseChallengeRepository(client);
   });
   ```

2. **Service Providers**: Fornecem acesso a serviços específicos da feature
   ```dart
   final challengeRealtimeServiceProvider = Provider<ChallengeRealtimeService>((ref) {
     final repository = ref.watch(challengeRepositoryProvider);
     return ChallengeRealtimeService(repository);
   });
   ```

3. **ViewModel Providers**: Gerenciam o estado e a lógica
   ```dart
   final challengeViewModelProvider = StateNotifierProvider<ChallengeViewModel, ChallengeState>((ref) {
     final repository = ref.watch(challengeRepositoryProvider);
     return ChallengeViewModel(repository);
   });
   ```

4. **Dados Derivados/Calculados**: Providers que derivam dados de outros providers
   ```dart
   final activeChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
     final repository = ref.watch(challengeRepositoryProvider);
     return repository.getActiveChallenges();
   });
   ```

## Regras para Evitar Duplicações

1. **Localização Centralizada**: Cada provider deve ser definido em apenas um local
   - Os providers de feature devem estar nos arquivos de providers da feature
   - Remova definições duplicadas em arquivos de repository ou model

2. **Referências Cruzadas**: Ao referenciar providers entre features, importe o provider do seu local oficial
   - Não redefina providers de outras features

3. **Comentários de Clareza**: Se um provider está definido em outro arquivo, adicione um comentário indicando onde encontrá-lo:
   ```dart
   // O authRepositoryProvider está definido em lib/features/auth/providers/auth_providers.dart
   ```

4. **Importação Explícita**: Sempre importe explicitamente os providers que você usa:
   ```dart
   import 'package:ray_club_app/features/auth/providers/auth_providers.dart' show authRepositoryProvider;
   ```

## Exemplos de Boa Organização

### Arquivo: `lib/features/challenges/providers/challenge_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/challenge_repository.dart';
import '../repositories/supabase_challenge_repository.dart';
import '../../auth/providers/auth_providers.dart' show authRepositoryProvider;

// Repository Providers
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChallengeRepository(client);
});

// Dados Derivados
final activeChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getActiveChallenges();
});
``` 