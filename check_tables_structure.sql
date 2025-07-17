-- ============================================================================
-- VERIFICAR ESTRUTURA DAS TABELAS ANTES DOS TESTES
-- ============================================================================

-- 1. Verificar se as tabelas existem
SELECT 
    'TABELAS EXISTENTES:' as verificacao,
    string_agg(table_name, ', ') as tabelas_encontradas
FROM information_schema.tables 
WHERE table_name IN ('challenges', 'challenge_participants', 'challenge_check_ins', 'challenge_progress', 'workout_records', 'profiles')
AND table_schema = 'public';

-- 2. Estrutura da tabela challenges
SELECT '📋 ESTRUTURA DA TABELA CHALLENGES:' as secao;
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenges' 
ORDER BY ordinal_position;

-- 3. Estrutura da tabela challenge_check_ins
SELECT '📋 ESTRUTURA DA TABELA CHALLENGE_CHECK_INS:' as secao;
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenge_check_ins' 
ORDER BY ordinal_position;

-- 4. Estrutura da tabela challenge_progress
SELECT '📋 ESTRUTURA DA TABELA CHALLENGE_PROGRESS:' as secao;
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenge_progress' 
ORDER BY ordinal_position;

-- 5. Estrutura da tabela workout_records
SELECT '📋 ESTRUTURA DA TABELA WORKOUT_RECORDS:' as secao;
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_records' 
ORDER BY ordinal_position;

-- 6. Verificar se existem dados de teste
SELECT '📊 DADOS EXISTENTES PARA TESTE:' as secao;

SELECT 
    'USUÁRIOS:' as tabela,
    COUNT(*) as quantidade
FROM profiles
WHERE email NOT LIKE 'teste_%'

UNION ALL

SELECT 
    'DESAFIOS ATIVOS:' as tabela,
    COUNT(*) as quantidade
FROM challenges
WHERE end_date > NOW()

UNION ALL

SELECT 
    'CHALLENGE_PARTICIPANTS:' as tabela,
    COUNT(*) as quantidade
FROM challenge_participants

UNION ALL

SELECT 
    'CHALLENGE_CHECK_INS:' as tabela,
    COUNT(*) as quantidade
FROM challenge_check_ins

UNION ALL

SELECT 
    'CHALLENGE_PROGRESS:' as tabela,
    COUNT(*) as quantidade
FROM challenge_progress

UNION ALL

SELECT 
    'WORKOUT_RECORDS:' as tabela,
    COUNT(*) as quantidade
FROM workout_records;

-- 7. Verificar funções importantes
SELECT '🔧 FUNÇÕES DISPONÍVEIS:' as secao;

SELECT 
    proname as function_name,
    CASE 
        WHEN proname = 'record_workout_basic' THEN '✅ FUNDAMENTAL'
        WHEN proname = 'process_workout_for_ranking' THEN '✅ FUNDAMENTAL'  
        WHEN proname = 'record_challenge_check_in_v2' THEN '✅ INTERFACE APP'
        ELSE '📝 AUXILIAR'
    END as importancia
FROM pg_proc 
WHERE proname IN (
    'record_workout_basic',
    'process_workout_for_ranking', 
    'process_workout_for_ranking_fixed',
    'record_challenge_check_in_v2'
)
ORDER BY importancia DESC, proname;

-- 8. Resumo para validação
SELECT '🎯 RESUMO PARA TESTES:' as secao;

WITH table_checks AS (
    SELECT 
        EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'challenges') as has_challenges,
        EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins') as has_check_ins,
        EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_progress') as has_progress,
        EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_records') as has_workouts,
        EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') as has_profiles
),
function_checks AS (
    SELECT 
        EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic') as has_record_function,
        EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'process_workout_for_ranking') as has_ranking_function
),
data_checks AS (
    SELECT 
        (SELECT COUNT(*) FROM profiles WHERE email NOT LIKE 'teste_%') as user_count,
        (SELECT COUNT(*) FROM challenges WHERE end_date > NOW()) as active_challenge_count
)
SELECT 
    CASE 
        WHEN tc.has_challenges AND tc.has_check_ins AND tc.has_progress AND tc.has_workouts AND tc.has_profiles
        THEN '✅ Todas as tabelas existem'
        ELSE '❌ Faltam tabelas importantes'
    END as status_tabelas,
    
    CASE 
        WHEN fc.has_record_function AND fc.has_ranking_function
        THEN '✅ Funções principais existem'
        ELSE '❌ Faltam funções importantes'
    END as status_funcoes,
    
    CASE 
        WHEN dc.user_count > 0 AND dc.active_challenge_count > 0
        THEN '✅ Dados suficientes para teste'
        ELSE '⚠️ Poucos dados - teste pode precisar criar dados próprios'
    END as status_dados,
    
    dc.user_count as usuarios_disponiveis,
    dc.active_challenge_count as desafios_ativos
    
FROM table_checks tc, function_checks fc, data_checks dc; 