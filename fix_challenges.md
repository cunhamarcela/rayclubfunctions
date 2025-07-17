# Plano para Correção do Sistema de Check-in de Desafios

## Problema Identificado

Foi identificado um erro no processo de registro de treinos e check-ins no sistema Ray Club, impedindo que os check-ins sejam realizados corretamente. O principal problema está relacionado à incompatibilidade entre os nomes de parâmetros usados no código Flutter e os esperados pela função RPC no Supabase.

**Erro específico:**
```
PostgrestException(message: Could not find the function public.record_challenge_check_in(_challenge_id, _check_in_date, _duration_minutes, _user_id, _user_name, _user_photo_url, _workout_id, _workout_name, _workout_type) in the schema cache
```

O erro indica que o código Flutter está tentando chamar a função `record_challenge_check_in` com parâmetros que começam com underscore (_), mas a função SQL espera parâmetros nomeados com sufixo "_param".

## Plano de Correção

### 1. Sincronização dos Parâmetros de Chamada RPC

1. **Atualizar a Classe de Constantes**
   - Modificar o arquivo `lib/features/challenges/constants/challenge_rpc_params.dart` para definir corretamente os nomes dos parâmetros e campos de retorno da função RPC.
   - Remover referências a parâmetros que não são usados na função atual.

2. **Atualizar a Chamada RPC no Serviço de Treinos**
   - Modificar o arquivo `lib/features/challenges/services/workout_challenge_service.dart` para usar as constantes de `ChallengeRpcParams` em vez de strings literais.
   - Modificar a ordem e o nome dos parâmetros para corresponder ao que a função SQL espera.
   - Melhorar o tratamento dos valores de retorno, usando operadores de null-safety.

### 2. Atualização da Função SQL no Supabase

1. **Criar Nova Função SQL com Parâmetros Corretos**
   - Desenvolver uma função SQL atualizada em `atualizar_rpc_check_in.sql` que aceite exatamente os parâmetros esperados pelo código Flutter.
   - Garantir que a ordem dos parâmetros corresponda à ordem usada no código Flutter.
   - Implementar tratamento adequado de streak (sequência de dias) e pontos.

2. **Melhorar Retorno da Função SQL**
   - Retornar campos adicionais como `points_earned`, `streak` e `is_already_checked_in`.
   - Utilizar maiúsculas para constantes booleanas (TRUE/FALSE) por consistência.

### 3. Correção do Sistema de Atualização de Progresso

1. **Atualizar Lógica de Progresso do Desafio**
   - Modificar a função SQL para atualizar automaticamente o progresso do usuário no desafio.
   - Criar entradas de progresso para usuários que ainda não têm (novos participantes).
   - Implementar cálculo de bônus por sequência de dias (streak).

2. **Corrigir Inconsistências de Nomenclatura de Colunas**
   - Garantir uso consistente de `check_ins_count` em vez de `total_check_ins`.
   - Verificar existência de colunas antes de acessá-las.

## Implementação

1. **Fase 1: Atualização do Código Flutter**
   - ✅ Atualizar `ChallengeRpcParams` para refletir os parâmetros corretos.
   - ✅ Atualizar o método `_processChallengeCheckIn` no `WorkoutChallengeService`.
   - ✅ Melhorar tratamento de erros e logging para facilitar depuração.

2. **Fase 2: Atualização do Supabase**
   - ✅ Criar script SQL atualizado com a função `record_challenge_check_in` corrigida.
   - ⏳ Executar o script no console do Supabase ou via ferramenta administrativa.
   - ⏳ Verificar se a função foi criada/atualizada corretamente via consulta ao esquema.

3. **Fase 3: Testes e Validação**
   - ⏳ Testar registro de treino e check-in via aplicativo.
   - ⏳ Verificar atualizações de ranking e progresso.
   - ⏳ Monitorar registros de log para garantir funcionamento correto.

## Mapeamento de Campos

### Parâmetros da Função RPC
| Código Flutter                       | Função SQL                 |
|-------------------------------------|----------------------------|
| `challengeIdParam: challenge.id`    | `challenge_id_param`       |
| `dateParam: record.date.toIso8601String()` | `date_param`        |
| `durationMinutesParam: record.durationMinutes` | `duration_minutes_param` |
| `userIdParam: userId`               | `user_id_param`            |
| `workoutIdParam: record.id`         | `workout_id_param`         |
| `workoutNameParam: record.workoutName` | `workout_name_param`    |
| `workoutTypeParam: record.workoutType` | `workout_type_param`    |

### Campos de Retorno
| Código Flutter                       | Função SQL                 |
|-------------------------------------|----------------------------|
| `successField`                      | `success`                  |
| `messageField`                      | `message`                  |
| `isAlreadyCheckedInField`           | `is_already_checked_in`    |
| `pointsEarnedField`                 | `points_earned`            |
| `streakField`                       | `streak`                   |
| `checkInIdField`                    | `check_in_id`              |

## Conclusão

Após a implementação deste plano, o sistema de registro de treinos deverá funcionar corretamente, alimentando o ranking e progresso dos desafios no app Ray Club. Estas alterações garantirão consistência entre o frontend (Flutter) e o backend (Supabase), eliminando erros de nomenclatura e falta de sincronização. 