-- VERIFICAR POLÍTICAS RLS NA TABELA workout_records
-- Data: 2025-08-13
-- Objetivo: Descobrir se RLS está limitando acesso a treinos de outros usuários

-- 1. Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity, forcerowsecurity 
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
WHERE tablename = 'workout_records';

-- 3. Verificar se existe diferença de acesso para usuários diferentes
-- Simular como se fosse a Marcela vendo treinos da Raiany
SELECT 'TESTE DIRETO - Treinos da Raiany (bbea26ca-f34c-499f-ad3a-48646a614cd3):' as info;
SELECT 
    id,
    workout_name,
    workout_type,
    date,
    duration_minutes,
    user_id,
    created_at
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0
ORDER BY date DESC;

-- 4. Contar TODOS os treinos de cardio da Raiany
SELECT 'CONTAGEM TOTAL - Treinos de Cardio da Raiany:' as info;
SELECT COUNT(*) as total_treinos
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0;

-- 5. Verificar se há diferença por período
SELECT 'TREINOS POR PERÍODO:' as info;
SELECT 
    DATE_TRUNC('month', date) as mes_ano,
    COUNT(*) as qtd_treinos,
    SUM(duration_minutes) as total_minutos
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0
GROUP BY DATE_TRUNC('month', date)
ORDER BY mes_ano DESC;

