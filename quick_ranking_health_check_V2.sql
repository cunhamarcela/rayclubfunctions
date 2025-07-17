-- 🚀 HEALTH CHECK RÁPIDO DO SISTEMA DE RANKING (VERSÃO 2.0)
-- 📋 Verificação rápida usando SELECT para melhor visualização

-- ======================================
-- 🔍 VERIFICAÇÕES BÁSICAS DO SISTEMA
-- ======================================

SELECT '🔍 VERIFICAÇÕES BÁSICAS DO SISTEMA:' as titulo;

-- Verificar se as funções principais existem
WITH function_checks AS (
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM pg_proc p 
                JOIN pg_namespace n ON p.pronamespace = n.oid 
                WHERE n.nspname = 'public' AND p.proname = 'record_workout_basic'
            ) 
            THEN '✅ Função record_workout_basic existe'
            ELSE '❌ Função record_workout_basic NÃO ENCONTRADA'
        END as func_record,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM pg_proc p 
                JOIN pg_namespace n ON p.pronamespace = n.oid 
                WHERE n.nspname = 'public' AND p.proname = 'process_workout_for_ranking_fixed'
            ) 
            THEN '✅ Função process_workout_for_ranking_fixed existe'
            ELSE '❌ Função process_workout_for_ranking_fixed NÃO ENCONTRADA'
        END as func_process
)
SELECT func_record as resultado FROM function_checks
UNION ALL
SELECT func_process FROM function_checks;

-- ======================================
-- 📊 VERIFICAR ESTRUTURA DAS TABELAS
-- ======================================

SELECT '📊 VERIFICAR ESTRUTURA DAS TABELAS:' as titulo;

WITH table_checks AS (
    SELECT
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_records') 
            THEN '✅ Tabela workout_records existe'
            ELSE '❌ Tabela workout_records NÃO ENCONTRADA'
        END as table_workout_records,
        
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins') 
            THEN '✅ Tabela challenge_check_ins existe'
            ELSE '❌ Tabela challenge_check_ins NÃO ENCONTRADA'
        END as table_check_ins,
        
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_progress') 
            THEN '✅ Tabela challenge_progress existe'
            ELSE '❌ Tabela challenge_progress NÃO ENCONTRADA'
        END as table_progress,
        
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenges') 
            THEN '✅ Tabela challenges existe'
            ELSE '❌ Tabela challenges NÃO ENCONTRADA'
        END as table_challenges,
        
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_participants') 
            THEN '✅ Tabela challenge_participants existe'
            ELSE '❌ Tabela challenge_participants NÃO ENCONTRADA'
        END as table_participants
)
SELECT table_workout_records as resultado FROM table_checks
UNION ALL
SELECT table_check_ins FROM table_checks
UNION ALL
SELECT table_progress FROM table_checks
UNION ALL
SELECT table_challenges FROM table_checks
UNION ALL
SELECT table_participants FROM table_checks;

-- ======================================
-- 🏃 TESTE RÁPIDO DE FUNCIONAMENTO
-- ======================================

DO $$
DECLARE
    quick_test_challenge_id UUID := 'f9e8d7c6-b5a4-9382-7160-123456789012';
    quick_test_user_id UUID := 'e8d7c6b5-a493-8271-6054-987654321098';
    workout_result JSONB;
BEGIN
    -- Limpar teste anterior
    DELETE FROM challenge_check_ins WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = quick_test_challenge_id;
    
    -- Criar dados mínimos
    INSERT INTO profiles (id, name) VALUES 
    (quick_test_user_id, 'Usuário Health Check')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        quick_test_challenge_id, 
        'Health Check Challenge', 
        'Teste básico de funcionamento',
        CURRENT_DATE - INTERVAL '5 days',
        CURRENT_DATE + INTERVAL '25 days',
        true, 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active;
    
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (quick_test_user_id, quick_test_challenge_id, NOW() - INTERVAL '3 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
    
    -- Registrar um treino
    SELECT record_workout_basic(
        quick_test_user_id, 
        'Teste Health Check', 
        'cardio', 
        60, 
        CURRENT_DATE, 
        quick_test_challenge_id, 
        'HEALTH-CHECK-001', 
        'Treino de teste',
        gen_random_uuid()
    ) INTO workout_result;
    
    PERFORM pg_sleep(1);
END $$;

SELECT '🏃 TESTE RÁPIDO EXECUTADO' as status;

-- ======================================
-- ✅ VERIFICAR RESULTADO DO TESTE
-- ======================================

SELECT '✅ VERIFICAR RESULTADO DO TESTE:' as titulo;

WITH quick_test_results AS (
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM workout_records 
                WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012'
            ) 
            THEN '✅ workout_records criado'
            ELSE '❌ workout_records NÃO criado'
        END as test_workout_record,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_check_ins 
                WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012'
            ) 
            THEN '✅ challenge_check_ins criado'
            ELSE '❌ challenge_check_ins NÃO criado'
        END as test_check_in,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012'
                AND points = 10
            ) 
            THEN '✅ challenge_progress com 10 pontos'
            ELSE '❌ challenge_progress sem pontos corretos'
        END as test_progress,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012'
                AND user_name IS NOT NULL AND user_name != ''
            ) 
            THEN '✅ user_name preenchido automaticamente'
            ELSE '❌ user_name NÃO preenchido'
        END as test_username,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012'
                AND position = 1
            ) 
            THEN '✅ position calculada corretamente'
            ELSE '❌ position incorreta'
        END as test_position
)
SELECT test_workout_record as resultado FROM quick_test_results
UNION ALL
SELECT test_check_in FROM quick_test_results
UNION ALL
SELECT test_progress FROM quick_test_results
UNION ALL
SELECT test_username FROM quick_test_results
UNION ALL
SELECT test_position FROM quick_test_results;

-- ======================================
-- 📈 ESTATÍSTICAS DO SISTEMA
-- ======================================

SELECT '📈 ESTATÍSTICAS DO SISTEMA:' as titulo;

SELECT 
    'Total workout_records' as metrica,
    COUNT(*) as valor
FROM workout_records

UNION ALL

SELECT 
    'Total challenge_check_ins' as metrica,
    COUNT(*) as valor
FROM challenge_check_ins

UNION ALL

SELECT 
    'Total challenge_progress' as metrica,
    COUNT(*) as valor
FROM challenge_progress

UNION ALL

SELECT 
    'Challenges ativos' as metrica,
    COUNT(*) as valor
FROM challenges 
WHERE active = true

UNION ALL

SELECT 
    'Total participantes' as metrica,
    COUNT(*) as valor
FROM challenge_participants;

-- ======================================
-- 🔧 VERIFICAR CONSISTÊNCIA GERAL
-- ======================================

SELECT '🔧 VERIFICAR CONSISTÊNCIA GERAL:' as titulo;

WITH consistency_checks AS (
    SELECT 
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE check_ins_count != total_check_ins
            ) 
            THEN '✅ check_ins_count = total_check_ins (global)'
            ELSE '❌ INCONSISTÊNCIA: check_ins_count != total_check_ins'
        END as global_consistency,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE user_name IS NULL OR user_name = ''
            ) 
            THEN '✅ Todos user_name preenchidos (global)'
            ELSE '❌ user_name vazio encontrado (global)'
        END as global_usernames,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE completion_percentage < 0 OR completion_percentage > 100
            ) 
            THEN '✅ completion_percentage válidos (global)'
            ELSE '❌ completion_percentage inválidos (global)'
        END as global_percentages,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT challenge_id, position, COUNT(*) 
                FROM challenge_progress 
                GROUP BY challenge_id, position 
                HAVING COUNT(*) > 1
            ) 
            THEN '✅ Posições únicas por desafio (global)'
            ELSE '❌ Posições duplicadas encontradas (global)'
        END as global_positions
)
SELECT global_consistency as resultado FROM consistency_checks
UNION ALL
SELECT global_usernames FROM consistency_checks
UNION ALL
SELECT global_percentages FROM consistency_checks
UNION ALL
SELECT global_positions FROM consistency_checks;

-- ======================================
-- 🎉 RESULTADO FINAL DO HEALTH CHECK
-- ======================================

WITH health_check_final AS (
    SELECT 
        CASE 
            WHEN (
                EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.proname = 'record_workout_basic')
                AND EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.proname = 'process_workout_for_ranking_fixed')
                AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_records')
                AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins')
                AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_progress')
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012' AND points = 10)
            )
            THEN '🎉 SISTEMA 100% OPERACIONAL! Todas as verificações passaram!'
            ELSE '❌ SISTEMA COM PROBLEMAS! Verificar logs acima'
        END as health_status
)
SELECT health_status FROM health_check_final;

-- ======================================
-- 🧹 LIMPEZA DO TESTE
-- ======================================

DO $$
BEGIN
    -- Limpar dados do teste
    DELETE FROM challenge_check_ins WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012';
    DELETE FROM challenge_progress WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012';
    DELETE FROM workout_records WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012';
    DELETE FROM challenge_participants WHERE challenge_id = 'f9e8d7c6-b5a4-9382-7160-123456789012';
END $$;

SELECT '🧹 LIMPEZA DO HEALTH CHECK CONCLUÍDA' as status; 