-- 🚀 VERIFICAÇÃO RÁPIDA DA SAÚDE DO SISTEMA DE RANKING
-- 📋 Diagnóstico em menos de 1 minuto

-- ======================================
-- 🔍 VERIFICAR EXISTÊNCIA DAS FUNÇÕES PRINCIPAIS
-- ======================================

DO $$
DECLARE
    function_count INTEGER;
    missing_functions TEXT := '';
BEGIN
    RAISE NOTICE '🔍 VERIFICANDO funções de ranking...';
    
    -- Verificar record_workout_basic
    SELECT COUNT(*) INTO function_count
    FROM information_schema.routines 
    WHERE routine_name = 'record_workout_basic' 
    AND routine_type = 'FUNCTION';
    
    IF function_count = 0 THEN
        missing_functions := missing_functions || 'record_workout_basic; ';
    END IF;
    
    -- Verificar process_workout_for_ranking_fixed
    SELECT COUNT(*) INTO function_count
    FROM information_schema.routines 
    WHERE routine_name = 'process_workout_for_ranking_fixed' 
    AND routine_type = 'FUNCTION';
    
    IF function_count = 0 THEN
        missing_functions := missing_functions || 'process_workout_for_ranking_fixed; ';
    END IF;
    
    -- Verificar update_challenge_ranking
    SELECT COUNT(*) INTO function_count
    FROM information_schema.routines 
    WHERE routine_name = 'update_challenge_ranking' 
    AND routine_type = 'FUNCTION';
    
    IF function_count = 0 THEN
        missing_functions := missing_functions || 'update_challenge_ranking; ';
    END IF;
    
    IF missing_functions = '' THEN
        RAISE NOTICE '✅ Todas as funções principais existem';
    ELSE
        RAISE NOTICE '❌ FUNÇÕES FALTANDO: %', missing_functions;
    END IF;
END $$;

-- ======================================
-- 📊 VERIFICAR ESTRUTURA DAS TABELAS
-- ======================================

DO $$
DECLARE
    table_issues TEXT := '';
BEGIN
    RAISE NOTICE '📊 VERIFICANDO estrutura das tabelas...';
    
    -- Verificar challenge_progress
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'challenge_progress'
    ) THEN
        table_issues := table_issues || 'challenge_progress ausente; ';
    END IF;
    
    -- Verificar challenge_check_ins
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'challenge_check_ins'
    ) THEN
        table_issues := table_issues || 'challenge_check_ins ausente; ';
    END IF;
    
    -- Verificar workout_records
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'workout_records'
    ) THEN
        table_issues := table_issues || 'workout_records ausente; ';
    END IF;
    
    IF table_issues = '' THEN
        RAISE NOTICE '✅ Todas as tabelas principais existem';
    ELSE
        RAISE NOTICE '❌ TABELAS COM PROBLEMAS: %', table_issues;
    END IF;
END $$;

-- ======================================
-- 🎯 TESTE RÁPIDO DE FUNCIONALIDADE
-- ======================================

DO $$
DECLARE
    quick_test_challenge_id UUID := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
    quick_test_user_id UUID := 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj';
    workout_result JSONB;
    progress_exists BOOLEAN;
    check_in_exists BOOLEAN;
    function_works BOOLEAN := true;
BEGIN
    RAISE NOTICE '🎯 EXECUTANDO teste rápido...';
    
    -- Limpar dados de teste anterior
    DELETE FROM challenge_progress WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM challenge_check_ins WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = quick_test_challenge_id;
    
    -- Preparar dados mínimos
    INSERT INTO profiles (id, name) VALUES (quick_test_user_id, 'Teste Rápido')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    INSERT INTO challenges (
        id, title, start_date, end_date, active, status, type
    ) VALUES (
        quick_test_challenge_id, 'Teste Rápido', 
        CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '25 days',
        true, 'active', 'fitness'
    ) ON CONFLICT (id) DO UPDATE SET active = EXCLUDED.active;
    
    INSERT INTO challenge_participants (user_id, challenge_id) VALUES 
    (quick_test_user_id, quick_test_challenge_id)
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
    
    -- Tentar registrar um treino
    BEGIN
        SELECT record_workout_basic(
            quick_test_user_id, 'TESTE-RAPIDO-001', 'Teste', 'cardio', 
            60, CURRENT_DATE, quick_test_challenge_id, 'Teste rápido'
        ) INTO workout_result;
        
        IF workout_result->'success' = 'true'::jsonb THEN
            RAISE NOTICE '✅ record_workout_basic funcionando';
        ELSE
            RAISE NOTICE '❌ record_workout_basic falhou: %', workout_result->'error';
            function_works := false;
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO na record_workout_basic: %', SQLERRM;
        function_works := false;
    END;
    
    -- Aguardar processamento
    PERFORM pg_sleep(1);
    
    -- Verificar se foi criado challenge_progress
    SELECT EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = quick_test_challenge_id 
        AND user_id = quick_test_user_id
    ) INTO progress_exists;
    
    -- Verificar se foi criado challenge_check_ins
    SELECT EXISTS (
        SELECT 1 FROM challenge_check_ins 
        WHERE challenge_id = quick_test_challenge_id 
        AND user_id = quick_test_user_id
    ) INTO check_in_exists;
    
    IF progress_exists THEN
        RAISE NOTICE '✅ challenge_progress criado automaticamente';
    ELSE
        RAISE NOTICE '❌ challenge_progress NÃO foi criado';
        function_works := false;
    END IF;
    
    IF check_in_exists THEN
        RAISE NOTICE '✅ challenge_check_ins criado automaticamente';
    ELSE
        RAISE NOTICE '❌ challenge_check_ins NÃO foi criado';
        function_works := false;
    END IF;
    
    -- Limpar dados de teste
    DELETE FROM challenge_progress WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM challenge_check_ins WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = quick_test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = quick_test_challenge_id;
    
    -- Resultado final
    IF function_works THEN
        RAISE NOTICE '🎉 SISTEMA DE RANKING FUNCIONANDO!';
    ELSE
        RAISE NOTICE '🚨 SISTEMA DE RANKING COM PROBLEMAS!';
    END IF;
END $$;

-- ======================================
-- 📈 ESTATÍSTICAS ATUAIS DO SISTEMA
-- ======================================

DO $$
DECLARE
    total_progress INTEGER;
    total_check_ins INTEGER;
    total_workouts INTEGER;
    active_challenges INTEGER;
BEGIN
    RAISE NOTICE '📈 ESTATÍSTICAS ATUAIS:';
    
    SELECT COUNT(*) INTO total_progress FROM challenge_progress;
    SELECT COUNT(*) INTO total_check_ins FROM challenge_check_ins;
    SELECT COUNT(*) INTO total_workouts FROM workout_records;
    SELECT COUNT(*) INTO active_challenges FROM challenges WHERE active = true;
    
    RAISE NOTICE '   📊 Total de registros de progresso: %', total_progress;
    RAISE NOTICE '   📊 Total de check-ins válidos: %', total_check_ins;
    RAISE NOTICE '   📊 Total de treinos registrados: %', total_workouts;
    RAISE NOTICE '   📊 Desafios ativos: %', active_challenges;
    
    -- Calcular taxa de conversão de treinos para check-ins
    IF total_workouts > 0 THEN
        RAISE NOTICE '   📊 Taxa de conversão treino→check-in: %% (%/%)', 
                     ROUND((total_check_ins * 100.0) / total_workouts, 2),
                     total_check_ins, total_workouts;
    END IF;
END $$;

-- ======================================
-- 🏆 TOP 5 DO RANKING GERAL (se houver dados)
-- ======================================

DO $$
DECLARE
    has_data BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM challenge_progress LIMIT 1) INTO has_data;
    
    IF has_data THEN
        RAISE NOTICE '🏆 TOP 5 RANKING GERAL:';
    ELSE
        RAISE NOTICE '📭 Nenhum dado de ranking encontrado ainda';
    END IF;
END $$;

-- Mostrar top 5 apenas se houver dados
WITH top_users AS (
    SELECT 
        user_name,
        SUM(points) as total_points,
        SUM(check_ins_count) as total_check_ins,
        COUNT(DISTINCT challenge_id) as challenges_participated
    FROM challenge_progress 
    WHERE user_name IS NOT NULL
    GROUP BY user_name
    ORDER BY total_points DESC, total_check_ins DESC
    LIMIT 5
)
SELECT 
    ROW_NUMBER() OVER () as posicao,
    user_name as nome,
    total_points as pontos,
    total_check_ins as check_ins,
    challenges_participated as desafios
FROM top_users
WHERE EXISTS (SELECT 1 FROM challenge_progress LIMIT 1);

RAISE NOTICE '=====================================';
RAISE NOTICE '🚀 VERIFICAÇÃO DE SAÚDE CONCLUÍDA!';
RAISE NOTICE '====================================='; 