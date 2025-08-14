-- VERIFICAR SE A POLÍTICA FOI CRIADA CORRETAMENTE
-- Execute no Supabase SQL Editor

-- 1. VERIFICAR POLÍTICAS ATUAIS
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
AND cmd = 'SELECT'
ORDER BY policyname;

-- 2. VERIFICAR SE A POLÍTICA ANTIGA FOI REMOVIDA
SELECT count(*) as politicas_antigas
FROM pg_policies 
WHERE tablename = 'workout_records' 
AND policyname = 'Usuários podem ver seus próprios registros';

-- 3. VERIFICAR SE A NOVA POLÍTICA EXISTE  
SELECT count(*) as nova_politica
FROM pg_policies 
WHERE tablename = 'workout_records' 
AND policyname = 'Ver treinos próprios e do desafio de cardio';

-- 4. TESTAR A POLÍTICA MANUALMENTE
-- Simular consulta como se fosse a Marcela vendo treinos da Raiany
SET session_replication_role = replica;
SET LOCAL rls.cardio_challenge_user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'; -- Marcela

SELECT 
    id, 
    workout_name, 
    workout_type, 
    date, 
    duration_minutes
FROM workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3' -- Raiany
AND workout_type = 'Cardio'
AND date >= '2025-08-01'
ORDER BY date DESC
LIMIT 5;

