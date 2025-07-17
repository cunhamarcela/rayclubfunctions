-- Debug script corrigido com ordem correta dos parâmetros
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- Challenge ID: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- Verificar usuário
SELECT 'STEP 1: Verificando usuário real' as debug_step;
SELECT id, email FROM auth.users WHERE id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- Verificar challenge específico
SELECT 'STEP 2: Verificando challenge específico' as debug_step;
SELECT id, name, active FROM challenges WHERE id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Verificar progresso atual do usuário no challenge
SELECT 'STEP 3: Progresso atual do usuário no challenge' as debug_step;
SELECT 
    cp.user_id,
    cp.challenge_id,
    cp.total_points,
    cp.check_ins_count,
    cp.current_rank,
    cp.progress_percentage,
    cp.last_check_in
FROM challenge_progress cp
WHERE cp.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- STEP 4: Executar record_workout_basic com ordem correta dos parâmetros
SELECT 'STEP 4: Executando record_workout_basic (ordem correta)' as debug_step;
DO $$
DECLARE
    result_msg jsonb;
BEGIN
    -- Chamar função com ordem correta:
    -- 1. p_user_id
    -- 2. p_workout_name  
    -- 3. p_workout_type
    -- 4. p_duration_minutes
    -- 5. p_date
    -- 6. p_challenge_id
    -- 7. p_workout_id
    -- 8. p_notes
    -- 9. p_workout_record_id
    
    SELECT record_workout_basic(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,  -- p_user_id
        'Treino Debug Real Corrigido',                  -- p_workout_name
        'standard',                                     -- p_workout_type
        60,                                            -- p_duration_minutes
        NOW(),                                         -- p_date
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, -- p_challenge_id
        'DEBUG-' || gen_random_uuid()::text,           -- p_workout_id
        'Teste com ordem correta dos parâmetros',      -- p_notes
        gen_random_uuid()                              -- p_workout_record_id
    ) INTO result_msg;
    
    RAISE NOTICE 'Resultado record_workout_basic: %', result_msg;
END
$$;

-- STEP 5: Verificar workout_records criados recentemente
SELECT 'STEP 5: Verificando workout_records criados' as debug_step;
SELECT 
    wr.id,
    wr.user_id,
    wr.challenge_id,
    wr.workout_name,
    wr.duration_minutes,
    wr.workout_date,
    wr.created_at
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY wr.created_at DESC
LIMIT 5;

-- STEP 6: Verificar challenge_check_ins criados recentemente
SELECT 'STEP 6: Verificando challenge_check_ins criados' as debug_step;
SELECT 
    cci.id,
    cci.user_id,
    cci.challenge_id,
    cci.workout_record_id,
    cci.points_earned,
    cci.checked_in_at
FROM challenge_check_ins cci
WHERE cci.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY cci.checked_in_at DESC
LIMIT 5;

-- STEP 7: Verificar progresso atualizado
SELECT 'STEP 7: Verificando challenge_progress atualizado' as debug_step;
SELECT 
    cp.user_id,
    cp.challenge_id,
    cp.total_points,
    cp.check_ins_count,
    cp.current_rank,
    cp.progress_percentage,
    cp.last_check_in
FROM challenge_progress cp
WHERE cp.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- STEP 8: Verificar se há erros na workout_processing_queue
SELECT 'STEP 8: Verificando status da workout_processing_queue' as debug_step;
SELECT 
    wpq.id,
    wpq.user_id,
    wpq.processed_for_ranking,
    wpq.processed_for_dashboard,
    wpq.created_at,
    wpq.processed_at
FROM workout_processing_queue wpq
WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY wpq.created_at DESC
LIMIT 3;

-- STEP 9: Comparar dados antes vs depois
SELECT 'STEP 9: Resumo final - Comparação' as debug_step;
SELECT 
    'Antes do teste' as momento,
    40 as pontos_antes,
    4 as checkins_antes,
    86 as posicao_antes
UNION ALL
SELECT 
    'Depois do teste' as momento,
    cp.total_points as pontos_depois,
    cp.check_ins_count as checkins_depois,
    cp.current_rank as posicao_depois
FROM challenge_progress cp
WHERE cp.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 