-- Debug script para rastrear todo o fluxo de registro de treino
-- Este script vai executar cada passo manualmente para identificar onde está falhando

-- Limpar dados de teste anteriores
DELETE FROM workout_processing_queue WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%teste%'
);
DELETE FROM challenge_check_ins WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%teste%'
);
DELETE FROM challenge_progress WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%teste%'
);
DELETE FROM workout_records WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%teste%'
);

-- Verificar usuários de teste
SELECT 'STEP 1: Verificando usuários de teste' as debug_step;
SELECT id, email FROM auth.users WHERE email LIKE '%teste%' ORDER BY email;

-- Verificar challenges ativos
SELECT 'STEP 2: Verificando challenges ativos' as debug_step;
SELECT id, name, active FROM challenges WHERE active = true;

-- STEP 3: Executar record_workout_basic para primeiro usuário
SELECT 'STEP 3: Executando record_workout_basic para usuário 1' as debug_step;
DO $$
DECLARE
    user_test_1 uuid;
    challenge_test uuid;
    result_msg text;
BEGIN
    -- Buscar usuário e challenge
    SELECT id INTO user_test_1 FROM auth.users WHERE email = 'teste1@email.com';
    SELECT id INTO challenge_test FROM challenges WHERE active = true LIMIT 1;
    
    IF user_test_1 IS NULL THEN
        RAISE NOTICE 'ERRO: Usuário teste1@email.com não encontrado';
        RETURN;
    END IF;
    
    IF challenge_test IS NULL THEN
        RAISE NOTICE 'ERRO: Nenhum challenge ativo encontrado';
        RETURN;
    END IF;
    
    RAISE NOTICE 'Usuário: %, Challenge: %', user_test_1, challenge_test;
    
    -- Chamar função
    SELECT record_workout_basic(
        gen_random_uuid(),  -- p_workout_record_id
        user_test_1,        -- p_user_id
        challenge_test,     -- p_challenge_id
        'Treino Teste 1',   -- p_workout_name
        45,                 -- p_duration_minutes
        300,                -- p_calories_burned
        'Treino completado com sucesso', -- p_notes
        NOW(),              -- p_performed_at
        'standard'          -- p_workout_type
    ) INTO result_msg;
    
    RAISE NOTICE 'Resultado record_workout_basic: %', result_msg;
END
$$;

-- STEP 4: Verificar se foi inserido na queue
SELECT 'STEP 4: Verificando workout_processing_queue' as debug_step;
SELECT 
    wpq.id,
    wpq.user_id,
    wpq.challenge_id,
    wpq.workout_name,
    wpq.processed,
    wpq.created_at,
    u.email
FROM workout_processing_queue wpq
JOIN auth.users u ON wpq.user_id = u.id
WHERE u.email LIKE '%teste%'
ORDER BY wpq.created_at DESC;

-- STEP 5: Tentar processar manualmente a queue
SELECT 'STEP 5: Processando queue manualmente' as debug_step;
DO $$
DECLARE
    queue_record RECORD;
    process_result text;
BEGIN
    -- Buscar primeiro item não processado da queue
    SELECT * INTO queue_record 
    FROM workout_processing_queue wpq
    JOIN auth.users u ON wpq.user_id = u.id
    WHERE u.email LIKE '%teste%' 
    AND wpq.processed = false
    ORDER BY wpq.created_at
    LIMIT 1;
    
    IF queue_record.id IS NULL THEN
        RAISE NOTICE 'ERRO: Nenhum item na queue para processar';
        RETURN;
    END IF;
    
    RAISE NOTICE 'Processando queue item: %', queue_record.id;
    
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

-- STEP 6: Verificar registros criados
SELECT 'STEP 6: Verificando workout_records criados' as debug_step;
SELECT 
    wr.id,
    wr.user_id,
    wr.challenge_id,
    wr.workout_name,
    wr.duration_minutes,
    wr.calories_burned,
    wr.performed_at,
    u.email
FROM workout_records wr
JOIN auth.users u ON wr.user_id = u.id
WHERE u.email LIKE '%teste%'
ORDER BY wr.performed_at DESC;

-- STEP 7: Verificar check-ins criados
SELECT 'STEP 7: Verificando challenge_check_ins criados' as debug_step;
SELECT 
    cci.id,
    cci.user_id,
    cci.challenge_id,
    cci.workout_record_id,
    cci.points_earned,
    cci.checked_in_at,
    u.email
FROM challenge_check_ins cci
JOIN auth.users u ON cci.user_id = u.id
WHERE u.email LIKE '%teste%'
ORDER BY cci.checked_in_at DESC;

-- STEP 8: Verificar progresso atualizado
SELECT 'STEP 8: Verificando challenge_progress atualizado' as debug_step;
SELECT 
    cp.user_id,
    cp.challenge_id,
    cp.total_points,
    cp.check_ins_count,
    cp.current_rank,
    cp.progress_percentage,
    cp.last_check_in,
    u.email
FROM challenge_progress cp
JOIN auth.users u ON cp.user_id = u.id
WHERE u.email LIKE '%teste%'
ORDER BY cp.total_points DESC;

-- STEP 9: Verificar se queue foi marcada como processada
SELECT 'STEP 9: Verificando status final da queue' as debug_step;
SELECT 
    wpq.id,
    wpq.user_id,
    wpq.processed,
    wpq.processed_at,
    wpq.error_message,
    u.email
FROM workout_processing_queue wpq
JOIN auth.users u ON wpq.user_id = u.id
WHERE u.email LIKE '%teste%'
ORDER BY wpq.created_at DESC; 