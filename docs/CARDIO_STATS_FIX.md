# Correção da Discrepância nas Estatísticas de Cardio

## Problema Identificado

Quando um usuário clica em um participante no ranking do desafio de cardio, as estatísticas mostradas no topo da tela (ex: "3 treinos") não correspondem à quantidade real de treinos listados abaixo (que podem ser muito mais).

## Causa Raiz

O problema estava na função `getParticipantCardioStats()` no arquivo `ranking_service.dart`, que estava usando uma **estimativa** baseada na divisão dos minutos totais por 50 (assumindo ~50min por treino), enquanto a lista de treinos usava a função RPC `get_participant_cardio_workouts` que retorna os dados reais.

### Código Problemático (linha 347)
```dart
// ⚠️ TEMPORÁRIO: Usar estimativa de treinos baseada nos minutos totais
final estimatedWorkouts = totalMinutes > 0 ? (totalMinutes / 50).round() : 0; // ~50min por treino
```

## Solução Implementada (Abordagem Conservadora)

### 1. Nova Função RPC no Banco de Dados

Criada a função `get_participant_cardio_count()` que:
- Bypassa limitações do Row Level Security (RLS)
- Retorna contagem exata de treinos e minutos
- Usa **exatamente os mesmos filtros** que `get_participant_cardio_workouts`
- Usa `SECURITY DEFINER` para executar com privilégios do owner

**Arquivo:** `sql/get_participant_cardio_count.sql`

### 2. Atualização Conservadora do Código Dart

Modificada a função `getParticipantCardioStats()` para:
- **TENTAR** usar a nova função RPC para contagem exata (se disponível)
- **MANTER** fallback completo para o método original (estimativa)
- **NÃO QUEBRAR** funcionalidade existente para outros usuários

**Arquivo:** `lib/features/ranking/data/ranking_service.dart`

### 3. Script de Aplicação

Criado script SQL para aplicar a função no Supabase Dashboard:
**Arquivo:** `scripts/apply_cardio_count_function.sql`

## Como Aplicar a Correção

1. **Aplicar a função SQL no Supabase:**
   - Acesse o Supabase Dashboard
   - Vá para SQL Editor
   - Execute o conteúdo do arquivo `scripts/apply_cardio_count_function.sql`

2. **Testar a aplicação:**
   - Reinicie o app Flutter
   - Navegue para o ranking de cardio
   - Clique em um participante
   - Verifique se as estatísticas agora correspondem à lista de treinos

## Resultado Esperado

Após aplicar o script SQL:
- ✅ **Para usuários com discrepância:** Estatísticas mostrarão contagem exata
- ✅ **Para usuários funcionando:** Comportamento permanece inalterado
- ✅ Lista de treinos continua mostrando todos os treinos reais
- ✅ Números ficam consistentes entre estatísticas e lista
- ✅ Performance mantida com uso de RPC otimizada
- ✅ **Zero risco** de quebrar funcionalidade existente

## Arquivos Modificados

- `lib/features/ranking/data/ranking_service.dart` - Lógica de contagem corrigida
- `sql/get_participant_cardio_count.sql` - Nova função RPC
- `scripts/apply_cardio_count_function.sql` - Script de aplicação
- `docs/CARDIO_STATS_FIX.md` - Esta documentação

## Notas Técnicas

- A função RPC usa `SECURITY DEFINER` para contornar limitações do RLS
- Mantém-se fallback para compatibilidade durante a transição
- Logs detalhados para debugging durante a implementação
