# Teste das Funções de Treino - Resultados Esperados

## IDs de Teste
- **User ID**: `01d4a292-1873-4af6-948b-a55eed56d6b9`
- **Challenge ID**: `29c91ea0-7dc1-486f-8e4a-86686cbf5f82`

## Como Executar o Teste

1. Execute o script `test_specific_ids.sql` no seu ambiente de banco de dados
2. Observe os resultados de cada etapa

## Resultados Esperados

### ✅ Primeira Execução (Primeiro treino do dia)

**Função `record_workout_basic`:**
```json
{
  "success": true,
  "message": "Treino registrado com sucesso",
  "workout_id": "uuid-gerado",
  "internal_workout_id": "uuid-gerado"
}
```

**Verificações após primeira execução:**
- ✅ 1 novo registro em `workout_records` 
- ✅ 1 novo registro em `challenge_check_ins` (se não existia check-in para hoje)
- ✅ 1 registro atualizado/criado em `challenge_progress` com:
  - `points` incrementados em +10
  - `check_ins_count` incrementado
  - `completion_percentage` recalculada
  - `last_check_in` atualizado

### ✅ Segunda Execução (Teste de duplicata - mesmo dia)

**Função `record_workout_basic`:**
```json
{
  "success": true,
  "message": "Treino registrado com sucesso",
  "workout_id": "uuid-gerado-2",
  "internal_workout_id": "uuid-gerado-2"
}
```

**Verificações após segunda execução:**
- ✅ 2 registros em `workout_records` (treino é registrado)
- ✅ Ainda apenas 1 registro em `challenge_check_ins` para hoje (NÃO cria duplicata)
- ✅ `challenge_progress` NÃO é alterado (pontos e contagem permanecem iguais)

## Validações da Função `process_workout_for_ranking_one_per_day`

### ✅ Validações que devem passar:
1. Usuário existe ✅
2. Desafio existe ✅  
3. Usuário participa do desafio ✅
4. Duração >= 45 minutos ✅

### ✅ Lógica de check-in único por dia:
1. Primeiro treino do dia → Cria check-in ✅
2. Segundo treino do dia → NÃO cria check-in (log: "Check-in já existe") ✅

### ✅ Atualizações corretas:
1. `challenge_check_ins`: 1 registro por dia ✅
2. `challenge_progress`: Contagem correta de dias únicos ✅
3. `workout_records`: NÃO atualiza pontos (removido) ✅

## Casos de Erro Esperados

### ❌ Se duração < 45 minutos:
```json
{
  "success": true,
  "message": "Treino registrado com sucesso"
}
```
Mas **não criará check-in** (log: "Duração mínima não atingida")

### ❌ Se usuário não participa do desafio:
```json
{
  "success": true, 
  "message": "Treino registrado com sucesso"
}
```
Mas **não criará check-in** (log: "Usuário não participa deste desafio")

## Comando para Executar

```sql
-- Execute este arquivo no seu ambiente SQL:
\i test_specific_ids.sql
```

Ou copie e cole o conteúdo diretamente no seu cliente SQL.

## Limpeza Após Teste (Opcional)

```sql
-- Para limpar os dados de teste (CUIDADO - só execute se necessário)
DELETE FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND DATE(check_in_date) = CURRENT_DATE;

DELETE FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND workout_name LIKE '%Teste%';
``` 