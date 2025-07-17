# Instruções para Correção de Funções SQL no Supabase

## Problema
O app Ray Club está enfrentando problemas com o registro de check-ins em desafios:
1. Erro "type 'Null' is not a subtype of type 'String' in type cast" quando valores nulos são encontrados
2. Verificação incorreta de check-ins duplicados, que mostra erro mesmo quando o usuário ainda não fez check-in
3. Desafios não aparecem corretamente no dashboard e no ranking

## Solução
Precisamos atualizar as funções SQL no banco de dados Supabase para corrigir esses problemas. As funções atualizadas estão no arquivo `fix_challenge_checkin_function.sql` e garantem:
- Tratamento correto de valores nulos
- Verificação precisa de check-ins duplicados
- Formato de retorno padronizado para a função principal

## Instruções para Implementação

### 1. Acesse o Painel do Supabase
1. Abra o navegador e acesse: https://app.supabase.com/
2. Faça login em sua conta
3. Selecione o projeto do Ray Club

### 2. Acesse o Editor SQL
1. No menu lateral, clique em "SQL Editor" ou "Editor SQL"
2. Clique em "New Query" ou "Nova Consulta"

### 3. Execute o Script SQL
1. Copie todo o conteúdo do arquivo `fix_challenge_checkin_function.sql`
2. Cole no editor SQL do Supabase
3. Clique em "Run" ou "Executar"

### 4. Solução de Problemas
Se ocorrer algum erro relacionado à sintaxe das funções:

#### Erro: "cannot change name of input parameter"
Este erro ocorre quando tentamos alterar nomes de parâmetros de funções existentes. O script já tenta remover várias versões possíveis das funções, mas se ainda houver erro:

1. Execute primeiro apenas os comandos DROP:
```sql
DROP FUNCTION IF EXISTS public.record_challenge_check_in(uuid, timestamptz, integer, uuid, text, text, text);
DROP FUNCTION IF EXISTS public.record_challenge_check_in_v2(uuid, timestamptz, integer, uuid, text, text, text);
DROP FUNCTION IF EXISTS public.record_challenge_check_in(uuid, timestamptz, integer, uuid, uuid, text, text);
DROP FUNCTION IF EXISTS public.record_challenge_check_in(challenge_id_param uuid, date_param timestamptz, duration_minutes_param integer, user_id_param uuid, workout_id_param text, workout_name_param text, workout_type_param text);
DROP FUNCTION IF EXISTS public.has_checked_in_today(uuid, uuid);
DROP FUNCTION IF EXISTS public.get_current_streak(uuid, uuid);
DROP FUNCTION IF EXISTS public.get_current_streak(user_id_param uuid, challenge_id_param uuid);
```

2. Se ainda houver erro, você pode descobrir a assinatura exata da função com:
```sql
SELECT 
  p.proname AS function_name,
  pg_get_function_identity_arguments(p.oid) AS function_arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE 
  n.nspname = 'public' AND 
  p.proname IN ('record_challenge_check_in', 'record_challenge_check_in_v2', 'has_checked_in_today', 'get_current_streak');
```

3. Depois execute as funções CREATE OR REPLACE separadamente

### 5. Verificação
Após executar com sucesso, você pode testar as funções com:

```sql
-- Testar has_checked_in_today
SELECT has_checked_in_today('01d4a292-1873-4af6-948b-a55eed56d6b9', '61eb5cae-c2a8-42c6-9c4c-e86b7ff186b5');

-- Testar get_current_streak
SELECT get_current_streak('01d4a292-1873-4af6-948b-a55eed56d6b9', '61eb5cae-c2a8-42c6-9c4c-e86b7ff186b5');
```

## O que foi corrigido
1. **Tratamento de valores nulos**: Todas as funções agora usam COALESCE para tratar valores null
2. **Verificação precisa de check-ins**: A função agora compara corretamente as datas
3. **Parâmetros consistentes**: A função tem nomes de parâmetros e estrutura padronizados
4. **Tratamento de erros**: Melhores mensagens de erro e prevenção de quebras no app 