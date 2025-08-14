-- SCRIPT DE VERIFICAÇÃO: Treinos de Cardio da Raiany Ricardo
-- Data: 2025-08-13
-- Objetivo: Verificar se os dados estão corretos no banco

-- 1. Informações básicas da Raiany
SELECT 'INFORMAÇÕES DA RAIANY RICARDO:' as info;
SELECT 
    id,
    name,
    email,
    created_at,
    updated_at
FROM public.profiles 
WHERE id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

-- 2. TODOS os treinos da Raiany (qualquer tipo)
SELECT 'TODOS OS TREINOS DA RAIANY:' as info;
SELECT 
    id,
    workout_name,
    workout_type,
    date,
    duration_minutes,
    is_completed,
    created_at,
    updated_at
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
ORDER BY date DESC;

-- 3. APENAS treinos de CARDIO da Raiany
SELECT 'TREINOS DE CARDIO DA RAIANY:' as info;
SELECT 
    id,
    workout_name,
    workout_type,
    date,
    duration_minutes,
    is_completed,
    created_at,
    EXTRACT(YEAR FROM date) as ano_treino,
    EXTRACT(MONTH FROM date) as mes_treino
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
AND workout_type = 'Cardio'
AND duration_minutes > 0
ORDER BY date DESC;

-- 4. CONTAGEM e SOMA dos treinos de cardio
SELECT 'ESTATÍSTICAS DE CARDIO DA RAIANY:' as info;
SELECT 
    COUNT(*) as total_treinos_cardio,
    SUM(duration_minutes) as total_minutos_cardio,
    AVG(duration_minutes) as media_minutos_por_treino,
    MIN(date) as primeiro_treino,
    MAX(date) as ultimo_treino
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
AND workout_type = 'Cardio'
AND duration_minutes > 0;

-- 5. Treinos por mês/ano
SELECT 'TREINOS DE CARDIO POR MÊS/ANO:' as info;
SELECT 
    EXTRACT(YEAR FROM date) as ano,
    EXTRACT(MONTH FROM date) as mes,
    COUNT(*) as quantidade_treinos,
    SUM(duration_minutes) as total_minutos
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
AND workout_type = 'Cardio'
AND duration_minutes > 0
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date)
ORDER BY ano DESC, mes DESC;

-- 6. Verificar se há treinos com workout_type diferente de 'Cardio'
SELECT 'OUTROS TIPOS DE TREINO DA RAIANY:' as info;
SELECT 
    workout_type,
    COUNT(*) as quantidade
FROM public.workout_records 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3'
GROUP BY workout_type
ORDER BY quantidade DESC;

-- 7. Status da participação no desafio de cardio
SELECT 'STATUS NO DESAFIO DE CARDIO:' as info;
SELECT 
    user_id,
    active,
    joined_at,
    created_at
FROM public.cardio_challenge_participants 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

-- 8. Teste da função get_cardio_ranking (apenas para Raiany)
SELECT 'RESULTADO DA FUNÇÃO GET_CARDIO_RANKING:' as info;
SELECT * FROM public.get_cardio_ranking() 
WHERE user_id = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

