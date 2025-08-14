# Cardio Ranking (Ray Club)

## Objetivo
Ranking simples baseado na soma dos minutos de treinos de modalidade cardio.

## SQL (Supabase)
Função RPC: `get_cardio_ranking(date_from timestamptz = null, date_to timestamptz = null)`.

Parâmetros opcionais filtram por `date` (ou a coluna temporal real) e modalidade é case-insensitive via `lower(workout_type) = 'cardio'`. Durações nulas/zero são ignoradas.

Retorno:
- `user_id uuid`
- `full_name text`
- `avatar_url text`
- `total_cardio_minutes int`

RLS: por padrão a função respeita RLS. Se necessário, considerar `SECURITY DEFINER` com `SET search_path = public;` e permissões restritas a `authenticated`.

Índices sugeridos:
- `(lower(workout_type), date)`
- `(user_id)`

## Flutter
Arquivos adicionados:
- `lib/features/ranking/data/cardio_ranking_entry.dart`
- `lib/features/ranking/data/ranking_service.dart`
- `lib/features/ranking/presentation/cardio_ranking_provider.dart`
- `lib/features/ranking/presentation/cardio_ranking_list.dart`
- `lib/features/ranking/screens/cardio_ranking_screen.dart`

Rota: `'/ranking/cardio'` (`CardioRankingRoute`).

Uso básico:
```dart
context.router.push(const CardioRankingRoute());
```

Filtro por datas:
```dart
final service = RankingService();
final last30 = await service.getCardioRanking(
  from: DateTime.now().toUtc().subtract(const Duration(days: 30)),
  to: DateTime.now().toUtc(),
);
```

## Teste
- `test/cardio_ranking_entry_test.dart` valida mapeamento do modelo.

## Aceite
- RPC executa sem erros e retorna ordenado por `total_cardio_minutes desc` com desempate por `full_name asc`/`user_id asc`.
- UI lista posição, avatar, nome e total de minutos.
- Perfis sem cardio não aparecem.
- Filtro de data opcional funciona.

## Data
- 2025-08-12  
- Autor/IA: IA  
- Contexto: Implementação de Ranking de Cardio isolado do ranking de desafios.


