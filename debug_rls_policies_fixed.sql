-- VERIFICAR POLÍTICAS RLS NA TABELA workout_records (CORRIGIDO)
-- Data: 2025-08-13
-- Objetivo: Descobrir se RLS está limitando acesso a treinos de outros usuários

-- 1. Verificar se RLS está habilitado (query corrigida)
SELECT 
    schemaname, 
    tablename, 
    rowsecurity
FROM pg_tables 
WHERE tablename = 'workout_records';

-- 2. Listar todas as políticas RLS da tabela workout_records
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'workout_records'
ORDER BY policyname;

-- 3. Verificar informações da tabela
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_name = 'workout_records';

-- 4. TESTE DIRETO: Contar treinos da Raiany sem filtros de usuário
SELECT 'TESTE DIRETO - Contagem de treinos da Raiany:' as info;
SELECT COUNT(*) as total_treinos
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0;

-- 5. TESTE DIRETO: Primeiros 10 treinos da Raiany
SELECT 'TESTE DIRETO - Primeiros 10 treinos da Raiany:' as info;
SELECT 
    id,
    workout_name,
    workout_type,
    date,
    duration_minutes,
    created_at
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0
ORDER BY date DESC
LIMIT 10;

-- 6. TESTE: Treinos por mês da Raiany
SELECT 'TREINOS DA RAIANY POR MÊS:' as info;
SELECT 
    DATE_TRUNC('month', date) as mes_ano,
    COUNT(*) as qtd_treinos,
    SUM(duration_minutes) as total_minutos,
    STRING_AGG(workout_name, ', ' ORDER BY date DESC) as treinos
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0
GROUP BY DATE_TRUNC('month', date)
ORDER BY mes_ano DESC;

