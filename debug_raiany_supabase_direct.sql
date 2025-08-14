-- DEBUG DIRETO NO SUPABASE: Treinos de Cardio da Raiany Ricardo
-- Execute este SQL completo no Supabase SQL Editor

-- 1. INFORMAÇÕES DA RAIANY
SELECT '=== INFORMAÇÕES DA RAIANY RICARDO ===' as info;
SELECT 
    id,
    name,
    email,
    created_at
FROM public.profiles 
WHERE id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

-- 2. TODOS OS TREINOS DELA (QUALQUER TIPO)
SELECT '=== TODOS OS TREINOS DA RAIANY ===' as info;
SELECT 
    id,
    workout_name,
    workout_type,
    date,
    duration_minutes,
    is_completed,
    created_at
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
ORDER BY date DESC;

-- 3. APENAS TREINOS DE CARDIO
SELECT '=== TREINOS DE CARDIO DA RAIANY ===' as info;
SELECT 
    id,
    workout_name,
    workout_type,
    date,
    duration_minutes,
    is_completed,
    created_at
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0
ORDER BY date DESC;

-- 4. ESTATÍSTICAS DE CARDIO
SELECT '=== ESTATÍSTICAS DE CARDIO DA RAIANY ===' as info;
SELECT 
    COUNT(*) as total_treinos,
    SUM(duration_minutes) as total_minutos,
    ROUND(AVG(duration_minutes)) as media_minutos,
    MIN(date) as primeiro_treino,
    MAX(date) as ultimo_treino
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0;

-- 5. TREINOS POR MÊS/ANO
SELECT '=== TREINOS DE CARDIO POR MÊS/ANO ===' as info;
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

-- 6. STATUS NO DESAFIO CARDIO
SELECT '=== STATUS NO DESAFIO DE CARDIO ===' as info;
SELECT 
    user_id,
    active,
    joined_at,
    created_at
FROM public.cardio_challenge_participants 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

-- 7. RESULTADO DA FUNÇÃO GET_CARDIO_RANKING (SOMENTE RAIANY)
SELECT '=== RESULTADO DA FUNÇÃO GET_CARDIO_RANKING ===' as info;
SELECT * FROM public.get_cardio_ranking()
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

-- 8. COMPARAÇÃO: TREINOS MAIS RECENTES (ÚLTIMOS 10)
SELECT '=== ÚLTIMOS 10 TREINOS DE CARDIO DA RAIANY ===' as info;
SELECT 
    workout_name,
    date,
    duration_minutes,
    created_at
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
  AND workout_type = 'Cardio'
  AND duration_minutes > 0
ORDER BY date DESC
LIMIT 10;

