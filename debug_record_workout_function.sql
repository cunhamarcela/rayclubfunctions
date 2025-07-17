-- 🔍 DEBUG DA FUNÇÃO RECORD_WORKOUT_BASIC
-- 📋 Investigação detalhada do problema

-- ======================================
-- 🔍 VERIFICAR SE A FUNÇÃO EXISTE
-- ======================================

SELECT '🔍 VERIFICAR SE A FUNÇÃO EXISTE:' as titulo;

SELECT 
    p.proname as nome_funcao,
    pg_get_function_arguments(p.oid) as argumentos,
    pg_get_function_result(p.oid) as retorno
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'record_workout_basic';

-- ======================================
-- 🧹 LIMPEZA PARA TESTE DEBUG
-- ======================================

DO $$
DECLARE
    debug_challenge_id UUID := '11111111-2222-3333-4444-555555555555';
    debug_user_id UUID := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
BEGIN
    DELETE FROM challenge_check_ins WHERE challenge_id = debug_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = debug_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = debug_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = debug_challenge_id;
END $$;

SELECT '🧹 LIMPEZA DEBUG EXECUTADA' as status;

-- ======================================
-- 📊 CRIAR DADOS MÍNIMOS PARA TESTE
-- ======================================

DO $$
DECLARE
    debug_challenge_id UUID := '11111111-2222-3333-4444-555555555555';
    debug_user_id UUID := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
BEGIN
    -- Criar usuário de teste
    INSERT INTO profiles (id, name) VALUES 
    (debug_user_id, 'Debug User Test')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Criar desafio de teste
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        debug_challenge_id, 
        'Debug Challenge', 
        'Teste de debug',
        CURRENT_DATE - INTERVAL '5 days',
        CURRENT_DATE + INTERVAL '25 days',
        true, 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active;
    
    -- Inscrever usuário no desafio
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (debug_user_id, debug_challenge_id, NOW() - INTERVAL '3 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
END $$;

SELECT '📊 DADOS DEBUG CRIADOS' as status;

-- ======================================
-- 🔍 VERIFICAR DADOS CRIADOS
-- ======================================

SELECT '🔍 VERIFICAR DADOS CRIADOS:' as titulo;

SELECT 'profiles' as tabela, COUNT(*) as registros
FROM profiles 
WHERE id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

UNION ALL

SELECT 'challenges' as tabela, COUNT(*) as registros
FROM challenges 
WHERE id = '11111111-2222-3333-4444-555555555555'

UNION ALL

SELECT 'challenge_participants' as tabela, COUNT(*) as registros
FROM challenge_participants 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555';

-- ======================================
-- 🧪 TESTE INDIVIDUAL DA FUNÇÃO
-- ======================================

DO $$
DECLARE
    debug_challenge_id UUID := '11111111-2222-3333-4444-555555555555';
    debug_user_id UUID := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
    result_json JSONB;
    error_occurred BOOLEAN := FALSE;
    error_message TEXT;
BEGIN
    -- Tentar executar a função
    BEGIN
        SELECT record_workout_basic(
            debug_user_id,              -- p_user_id
            'Teste Debug',              -- p_workout_name
            'cardio',                   -- p_workout_type
            60,                         -- p_duration_minutes
            CURRENT_DATE,               -- p_date
            debug_challenge_id,         -- p_challenge_id
            'DEBUG-001',                -- p_workout_id
            'Teste de debug',           -- p_notes
            gen_random_uuid()           -- p_workout_record_id
        ) INTO result_json;
        
        RAISE NOTICE 'SUCESSO! Resultado: %', result_json;
        
    EXCEPTION WHEN OTHERS THEN
        error_occurred := TRUE;
        error_message := SQLERRM;
        RAISE NOTICE 'ERRO na função: %', error_message;
    END;
    
    -- Aguardar um pouco
    PERFORM pg_sleep(1);
END $$;

SELECT '🧪 TESTE INDIVIDUAL EXECUTADO (ver logs acima)' as status;

-- ======================================
-- 📊 VERIFICAR RESULTADOS DO TESTE
-- ======================================

SELECT '📊 VERIFICAR RESULTADOS DO TESTE:' as titulo;

SELECT 'workout_records' as tabela, COUNT(*) as criados
FROM workout_records 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555'

UNION ALL

SELECT 'challenge_check_ins' as tabela, COUNT(*) as criados
FROM challenge_check_ins 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555'

UNION ALL

SELECT 'challenge_progress' as tabela, COUNT(*) as criados
FROM challenge_progress 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555';

-- ======================================
-- 🔍 INSPECIONAR WORKOUT_RECORDS CRIADO
-- ======================================

SELECT '🔍 INSPECIONAR WORKOUT_RECORDS CRIADO:' as titulo;

SELECT *
FROM workout_records 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555'
LIMIT 5;

-- ======================================
-- 🔍 INSPECIONAR CHALLENGE_CHECK_INS CRIADO
-- ======================================

SELECT '🔍 INSPECIONAR CHALLENGE_CHECK_INS CRIADO:' as titulo;

SELECT *
FROM challenge_check_ins 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555'
LIMIT 5;

-- ======================================
-- 🔍 INSPECIONAR CHALLENGE_PROGRESS CRIADO
-- ======================================

SELECT '🔍 INSPECIONAR CHALLENGE_PROGRESS CRIADO:' as titulo;

SELECT *
FROM challenge_progress 
WHERE challenge_id = '11111111-2222-3333-4444-555555555555'
LIMIT 5;

-- ======================================
-- 🔍 VERIFICAR CONDIÇÕES DE VALIDAÇÃO
-- ======================================

SELECT '🔍 VERIFICAR CONDIÇÕES DE VALIDAÇÃO:' as titulo;

WITH validation_check AS (
    SELECT 
        wr.id,
        wr.user_id,
        wr.duration_minutes,
        wr.workout_date,
        wr.challenge_id,
        c.active as challenge_active,
        c.start_date,
        c.end_date,
        cp.user_id as participant_exists,
        CASE 
            WHEN wr.duration_minutes >= 45 THEN 'Duração OK (≥45min)'
            ELSE 'Duração INSUFICIENTE (<45min)'
        END as duration_check,
        CASE 
            WHEN c.active = true THEN 'Challenge ATIVO'
            ELSE 'Challenge INATIVO'
        END as challenge_check,
        CASE 
            WHEN wr.workout_date BETWEEN c.start_date AND c.end_date THEN 'Data OK'
            ELSE 'Data FORA do período'
        END as date_check,
        CASE 
            WHEN cp.user_id IS NOT NULL THEN 'Usuário INSCRITO'
            ELSE 'Usuário NÃO INSCRITO'
        END as participation_check
    FROM workout_records wr
    LEFT JOIN challenges c ON c.id = wr.challenge_id
    LEFT JOIN challenge_participants cp ON cp.user_id = wr.user_id AND cp.challenge_id = wr.challenge_id
    WHERE wr.challenge_id = '11111111-2222-3333-4444-555555555555'
)
SELECT * FROM validation_check;

-- ======================================
-- 🧹 LIMPEZA FINAL DO DEBUG
-- ======================================

DO $$
BEGIN
    DELETE FROM challenge_check_ins WHERE challenge_id = '11111111-2222-3333-4444-555555555555';
    DELETE FROM challenge_progress WHERE challenge_id = '11111111-2222-3333-4444-555555555555';
    DELETE FROM workout_records WHERE challenge_id = '11111111-2222-3333-4444-555555555555';
    DELETE FROM challenge_participants WHERE challenge_id = '11111111-2222-3333-4444-555555555555';
END $$;

SELECT '🧹 LIMPEZA DEBUG FINAL EXECUTADA' as status; 