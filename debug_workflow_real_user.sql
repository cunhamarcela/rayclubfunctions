-- Debug script para testar o fluxo com usuário real
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- Challenge ID: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- Limpar dados de teste anteriores para este usuário
DELETE FROM workout_processing_queue WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

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

-- STEP 4: Executar record_workout_basic para o usuário real
SELECT 'STEP 4: Executando record_workout_basic para usuário real' as debug_step;
DO $$
DECLARE
    result_msg text;
BEGIN
    -- Chamar função com IDs reais
    SELECT record_workout_basic(
        gen_random_uuid(),  -- p_workout_record_id
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,  -- p_user_id
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- p_challenge_id
        'Treino Debug Real',   -- p_workout_name
        60,                 -- p_duration_minutes
        400,                -- p_calories_burned
        'Teste de debug com usuário real', -- p_notes
        NOW(),              -- p_performed_at
        'standard'          -- p_workout_type
    ) INTO result_msg;
    
    RAISE NOTICE 'Resultado record_workout_basic: %', result_msg;
END
$$;

-- STEP 5: Verificar se foi inserido na queue
SELECT 'STEP 5: Verificando workout_processing_queue' as debug_step;
SELECT 
    wpq.id,
    wpq.user_id,
    wpq.challenge_id,
    wpq.workout_name,
    wpq.processed,
    wpq.created_at
FROM workout_processing_queue wpq
WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY wpq.created_at DESC
LIMIT 5;

-- STEP 6: Tentar processar manualmente a queue
SELECT 'STEP 6: Processando queue manualmente' as debug_step;
DO $$
DECLARE
    queue_record RECORD;
    process_result text;
BEGIN
    -- Buscar último item não processado da queue para este usuário
    SELECT * INTO queue_record 
    FROM workout_processing_queue wpq
    WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
    AND wpq.processed = false
    ORDER BY wpq.created_at DESC
    LIMIT 1;
    
    IF queue_record.id IS NULL THEN
        RAISE NOTICE 'ERRO: Nenhum item na queue para processar para este usuário';
        RETURN;
    END IF;
    
    RAISE NOTICE 'Processando queue item: %', queue_record.id;
    RAISE NOTICE 'Workout: %, Duração: % min, Calorias: %', 
        queue_record.workout_name, 
        queue_record.duration_minutes, 
        queue_record.calories_burned;
    
    -- Chamar função de processamento
    SELECT process_workout_for_ranking_one_per_day(
        queue_record.id,
        queue_record.user_id,
        queue_record.challenge_id,
        queue_record.workout_name,
        queue_record.duration_minutes,
        queue_record.calories_burned,
        queue_record.notes,
        queue_record.performed_at,
        queue_record.workout_type
    ) INTO process_result;
    
    RAISE NOTICE 'Resultado process_workout_for_ranking_one_per_day: %', process_result;
END
$$;

-- STEP 7: Verificar workout_records criados
SELECT 'STEP 7: Verificando workout_records criados' as debug_step;
SELECT 
    wr.id,
    wr.user_id,
    wr.challenge_id,
    wr.workout_name,
    wr.duration_minutes,
    wr.calories_burned,
    wr.performed_at
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY wr.performed_at DESC
LIMIT 5;

-- STEP 8: Verificar challenge_check_ins criados
SELECT 'STEP 8: Verificando challenge_check_ins criados' as debug_step;
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

-- STEP 9: Verificar progresso atualizado
SELECT 'STEP 9: Verificando challenge_progress atualizado' as debug_step;
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

-- STEP 10: Verificar status final da queue
SELECT 'STEP 10: Verificando status final da queue' as debug_step;
SELECT 
    wpq.id,
    wpq.user_id,
    wpq.processed,
    wpq.processed_at,
    wpq.error_message
FROM workout_processing_queue wpq
WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY wpq.created_at DESC
LIMIT 3;

-- STEP 11: Verificar ranking geral do challenge
SELECT 'STEP 11: Ranking geral do challenge' as debug_step;
SELECT 
    cp.current_rank,
    cp.total_points,
    cp.check_ins_count,
    u.email,
    cp.progress_percentage
FROM challenge_progress cp
JOIN auth.users u ON cp.user_id = u.id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.current_rank ASC
LIMIT 10; 