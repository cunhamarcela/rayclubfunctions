-- 🧪 TESTE SIMPLES COM INSERT MANUAL
-- 📋 Verificar se as tabelas estão funcionando corretamente

-- ======================================
-- 🧹 LIMPEZA INICIAL
-- ======================================

DO $$
DECLARE
    simple_challenge_id UUID := '99999999-8888-7777-6666-555555555555';
    simple_user_id UUID := 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbbb';
BEGIN
    DELETE FROM challenge_check_ins WHERE challenge_id = simple_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = simple_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = simple_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = simple_challenge_id;
END $$;

SELECT '🧹 LIMPEZA SIMPLES EXECUTADA' as status;

-- ======================================
-- 📊 CRIAR DADOS BÁSICOS
-- ======================================

DO $$
DECLARE
    simple_challenge_id UUID := '99999999-8888-7777-6666-555555555555';
    simple_user_id UUID := 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbbb';
    workout_record_id UUID := gen_random_uuid();
BEGIN
    -- Criar usuário
    INSERT INTO profiles (id, name) VALUES 
    (simple_user_id, 'Simple Test User')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Criar desafio
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        simple_challenge_id, 
        'Simple Test Challenge', 
        'Teste manual simples',
        CURRENT_DATE - INTERVAL '5 days',
        CURRENT_DATE + INTERVAL '25 days',
        true, 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active;
    
    -- Inscrever usuário
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (simple_user_id, simple_challenge_id, NOW() - INTERVAL '3 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
    
    -- INSERIR MANUALMENTE NO WORKOUT_RECORDS
    INSERT INTO workout_records (
        id, user_id, workout_name, workout_type, duration_minutes,
        workout_date, challenge_id, workout_id, notes, created_at
    ) VALUES (
        workout_record_id,
        simple_user_id,
        'Treino Manual',
        'cardio',
        60,
        CURRENT_DATE,
        simple_challenge_id,
        'MANUAL-001',
        'Teste manual direto',
        NOW()
    );
    
    -- INSERIR MANUALMENTE NO CHALLENGE_CHECK_INS
    INSERT INTO challenge_check_ins (
        id, user_id, challenge_id, check_in_date, points_earned,
        workout_duration, created_at
    ) VALUES (
        gen_random_uuid(),
        simple_user_id,
        simple_challenge_id,
        CURRENT_DATE,
        10,
        60,
        NOW()
    );
    
    -- INSERIR MANUALMENTE NO CHALLENGE_PROGRESS
    INSERT INTO challenge_progress (
        id, user_id, challenge_id, points, check_ins_count, total_check_ins,
        completion_percentage, position, user_name, last_check_in,
        consecutive_days, completed, created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        simple_user_id,
        simple_challenge_id,
        10,
        1,
        1,
        3.33, -- assumindo 30 dias de desafio, 1/30 = 3.33%
        1,
        'Simple Test User',
        CURRENT_DATE,
        1,
        false,
        NOW(),
        NOW()
    ) ON CONFLICT (user_id, challenge_id) DO UPDATE SET
        points = EXCLUDED.points,
        check_ins_count = EXCLUDED.check_ins_count,
        total_check_ins = EXCLUDED.total_check_ins,
        completion_percentage = EXCLUDED.completion_percentage,
        position = EXCLUDED.position,
        last_check_in = EXCLUDED.last_check_in,
        updated_at = NOW();
        
END $$;

SELECT '📊 INSERÇÕES MANUAIS EXECUTADAS' as status;

-- ======================================
-- 🔍 VERIFICAR RESULTADOS
-- ======================================

SELECT '🔍 VERIFICAR RESULTADOS DAS INSERÇÕES MANUAIS:' as titulo;

SELECT 'workout_records' as tabela, COUNT(*) as registros
FROM workout_records 
WHERE challenge_id = '99999999-8888-7777-6666-555555555555'

UNION ALL

SELECT 'challenge_check_ins' as tabela, COUNT(*) as registros
FROM challenge_check_ins 
WHERE challenge_id = '99999999-8888-7777-6666-555555555555'

UNION ALL

SELECT 'challenge_progress' as tabela, COUNT(*) as registros
FROM challenge_progress 
WHERE challenge_id = '99999999-8888-7777-6666-555555555555';

-- ======================================
-- 📊 VISUALIZAR DADOS CRIADOS
-- ======================================

SELECT '📊 WORKOUT_RECORDS CRIADO:' as titulo;

SELECT *
FROM workout_records 
WHERE challenge_id = '99999999-8888-7777-6666-555555555555';

SELECT '📊 CHALLENGE_CHECK_INS CRIADO:' as titulo;

SELECT *
FROM challenge_check_ins 
WHERE challenge_id = '99999999-8888-7777-6666-555555555555';

SELECT '📊 CHALLENGE_PROGRESS CRIADO:' as titulo;

SELECT *
FROM challenge_progress 
WHERE challenge_id = '99999999-8888-7777-6666-555555555555';

-- ======================================
-- 🎯 CONCLUSÃO DO TESTE MANUAL
-- ======================================

WITH manual_test_validation AS (
    SELECT 
        CASE 
            WHEN EXISTS (SELECT 1 FROM workout_records WHERE challenge_id = '99999999-8888-7777-6666-555555555555') 
            THEN '✅ workout_records: FUNCIONANDO'
            ELSE '❌ workout_records: FALHA'
        END as test_workout_records,
        
        CASE 
            WHEN EXISTS (SELECT 1 FROM challenge_check_ins WHERE challenge_id = '99999999-8888-7777-6666-555555555555') 
            THEN '✅ challenge_check_ins: FUNCIONANDO'
            ELSE '❌ challenge_check_ins: FALHA'
        END as test_check_ins,
        
        CASE 
            WHEN EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = '99999999-8888-7777-6666-555555555555' AND points = 10) 
            THEN '✅ challenge_progress: FUNCIONANDO'
            ELSE '❌ challenge_progress: FALHA'
        END as test_progress
)
SELECT test_workout_records as resultado FROM manual_test_validation
UNION ALL
SELECT test_check_ins FROM manual_test_validation
UNION ALL
SELECT test_progress FROM manual_test_validation;

-- ======================================
-- 🧹 LIMPEZA FINAL
-- ======================================

DO $$
BEGIN
    DELETE FROM challenge_check_ins WHERE challenge_id = '99999999-8888-7777-6666-555555555555';
    DELETE FROM challenge_progress WHERE challenge_id = '99999999-8888-7777-6666-555555555555';
    DELETE FROM workout_records WHERE challenge_id = '99999999-8888-7777-6666-555555555555';
    DELETE FROM challenge_participants WHERE challenge_id = '99999999-8888-7777-6666-555555555555';
END $$;

SELECT '🧹 LIMPEZA FINAL DO TESTE MANUAL EXECUTADA' as status; 