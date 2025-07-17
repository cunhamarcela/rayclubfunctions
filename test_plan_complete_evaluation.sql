-- ====================================================================
-- PLANO DE TESTES COMPLETO - AVALIAÇÃO DE IMPACTOS DA CORREÇÃO
-- ====================================================================

-- Execute este script no Console SQL do Supabase para avaliar os impactos

-- =============================================
-- ETAPA 1: TESTES FUNCIONAIS BÁSICOS
-- =============================================

SELECT '🧪 ETAPA 1: TESTES FUNCIONAIS BÁSICOS' as teste;

-- Criar tabela temporária para resultados dos testes
CREATE TEMP TABLE temp_test_results (
    categoria TEXT,
    resultado TEXT, 
    detalhes TEXT
);

-- Teste 1: Função existe e está ativa
SELECT 
    'Função record_workout_basic' as componente,
    CASE WHEN COUNT(*) > 0 THEN '✅ ATIVA' ELSE '❌ AUSENTE' END as status,
    COUNT(*) as versoes
FROM pg_proc 
WHERE proname = 'record_workout_basic';

-- Teste 2: Testar com usuários que estavam falhando
DO $$
DECLARE
    test_users UUID[] := ARRAY[
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '711c907f-1ce5-4013-bdc6-7b58d645fb6d'::UUID
    ];
    test_result JSONB;
    user_id UUID;
    success_count INTEGER := 0;
    total_tests INTEGER := 0;
BEGIN
    FOREACH user_id IN ARRAY test_users LOOP
        total_tests := total_tests + 1;
        
        -- Testar registro de treino
        SELECT record_workout_basic(
            user_id,
            'Teste Pós-Correção',
            'Funcional',
            30,
            NOW(),
            NULL,
            NULL,
            'Teste após correção USER_NOT_FOUND',
            NULL
        ) INTO test_result;
        
        IF (test_result->>'success')::boolean THEN
            success_count := success_count + 1;
        END IF;
    END LOOP;
    
    -- Mostrar resultados usando SELECT
    INSERT INTO temp_test_results (categoria, resultado, detalhes) VALUES 
        ('TESTE USUÁRIOS PROBLEMÁTICOS', 
         success_count || '/' || total_tests || ' usuários conseguiram registrar',
         'Testados usuários que estavam falhando com USER_NOT_FOUND');
END $$;

-- Reexecutar o teste para mostrar resultados
DO $$
DECLARE
    test_users UUID[] := ARRAY[
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '711c907f-1ce5-4013-bdc6-7b58d645fb6d'::UUID
    ];
    test_result JSONB;
    user_id UUID;
    success_count INTEGER := 0;
    total_tests INTEGER := 0;
    user_results TEXT := '';
BEGIN
    FOREACH user_id IN ARRAY test_users LOOP
        total_tests := total_tests + 1;
        
        SELECT record_workout_basic(
            user_id,
            'Teste Pós-Correção',
            'Funcional',
            30,
            NOW(),
            NULL,
            NULL,
            'Teste após correção USER_NOT_FOUND',
            NULL
        ) INTO test_result;
        
        IF (test_result->>'success')::boolean THEN
            success_count := success_count + 1;
            user_results := user_results || '✅ ' || substring(user_id::text, 1, 8) || ': ' || (test_result->>'message') || E'\n';
        ELSE
            user_results := user_results || '❌ ' || substring(user_id::text, 1, 8) || ': ' || (test_result->>'error_code') || E'\n';
        END IF;
    END LOOP;
    
    INSERT INTO temp_test_results VALUES 
        ('RESULTADO FINAL', success_count || '/' || total_tests || ' sucessos', user_results);
END $$;

SELECT * FROM temp_test_results;

-- =============================================
-- ETAPA 2: TESTES DE PERFORMANCE
-- =============================================

SELECT '⚡ ETAPA 2: TESTES DE PERFORMANCE' as teste;

-- Teste de performance: Medir tempo de execução
DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    execution_time INTERVAL;
    test_user_id UUID;
    test_result JSONB;
    i INTEGER;
    total_time INTERVAL := '0 seconds'::INTERVAL;
    avg_time NUMERIC;
BEGIN
    -- Pegar um usuário válido para teste
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    -- Executar 10 testes para calcular média
    FOR i IN 1..10 LOOP
        start_time := clock_timestamp();
        
        SELECT record_workout_basic(
            test_user_id,
            'Teste Performance ' || i,
            'Cardio',
            45,
            NOW() + (i || ' minutes')::INTERVAL, -- Diferentes datas para evitar duplicatas
            NULL,
            NULL,
            'Teste de performance',
            NULL
        ) INTO test_result;
        
        end_time := clock_timestamp();
        execution_time := end_time - start_time;
        total_time := total_time + execution_time;
        
    END LOOP;
    
    avg_time := EXTRACT(MILLISECONDS FROM total_time) / 10;
    
    -- Inserir resultado de performance na tabela temporária
    INSERT INTO temp_test_results VALUES (
        'PERFORMANCE TEST',
        'Tempo médio: ' || avg_time || ' ms',
        CASE 
            WHEN avg_time < 100 THEN '🚀 EXCELENTE (< 100ms)'
            WHEN avg_time < 500 THEN '✅ BOA (< 500ms)'
            ELSE '⚠️ PRECISA OTIMIZAÇÃO (> 500ms)'
        END
    );
END $$;

-- =============================================
-- ETAPA 3: TESTES DE CENÁRIOS EDGE CASES
-- =============================================

SELECT '🔍 ETAPA 3: TESTES DE CENÁRIOS ESPECIAIS' as teste;

-- Teste 3: Usuário inexistente
SELECT 
    'Teste usuário inexistente' as cenario,
    (record_workout_basic(
        '00000000-0000-0000-0000-000000000000'::UUID,
        'Teste Usuário Fake',
        'Teste',
        30,
        NOW(),
        NULL, NULL, '', NULL
    )->>'error_code') as resultado_esperado_USER_NOT_AUTHENTICATED;

-- Teste 4: Parâmetros inválidos
SELECT 
    'Teste parâmetros nulos' as cenario,
    (record_workout_basic(
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    )->>'error_code') as resultado_esperado_MISSING_USER_ID;

-- Teste 5: Duplicatas
DO $$
DECLARE
    test_user_id UUID;
    result1 JSONB;
    result2 JSONB;
BEGIN
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    -- Primeiro registro
    SELECT record_workout_basic(
        test_user_id,
        'Teste Duplicata',
        'Funcional',
        45,
        CURRENT_DATE::TIMESTAMP,
        NULL, NULL, 'Primeiro registro', NULL
    ) INTO result1;
    
    -- Segundo registro idêntico
    SELECT record_workout_basic(
        test_user_id,
        'Teste Duplicata',
        'Funcional',
        45,
        CURRENT_DATE::TIMESTAMP,
        NULL, NULL, 'Segundo registro', NULL
    ) INTO result2;
    
    -- Inserir resultado do teste de duplicatas
    INSERT INTO temp_test_results VALUES (
        'TESTE ANTI-DUPLICATA',
        CASE 
            WHEN (result2->>'is_duplicate')::boolean THEN '✅ FUNCIONANDO'
            ELSE '⚠️ VERIFICAR'
        END,
        'Primeiro: ' || (result1->>'success') || ' | Segundo: ' || COALESCE(result2->>'is_duplicate', 'false')
    );
END $$;

-- =============================================
-- ETAPA 4: MONITORAMENTO DE LOGS
-- =============================================

SELECT '📊 ETAPA 4: ANÁLISE DE LOGS E ERROS' as teste;

-- Verificar erros recentes (últimas 2 horas)
SELECT 
    'Erros pós-correção (2h)' as periodo,
    error_type,
    COUNT(*) as quantidade
FROM check_in_error_logs 
WHERE created_at >= NOW() - INTERVAL '2 hours'
GROUP BY error_type
ORDER BY quantidade DESC;

-- Verificar registros de treino recentes
SELECT 
    'Treinos registrados (1h)' as periodo,
    COUNT(*) as total_treinos,
    COUNT(DISTINCT user_id) as usuarios_distintos
FROM workout_records 
WHERE created_at >= NOW() - INTERVAL '1 hour';

-- Comparar erros antes vs depois da correção
WITH before_fix AS (
    SELECT COUNT(*) as erros_antes
    FROM check_in_error_logs 
    WHERE error_type = 'AUTH_ERROR' 
    AND created_at < NOW() - INTERVAL '1 hour'
    AND created_at >= NOW() - INTERVAL '24 hours'
),
after_fix AS (
    SELECT COUNT(*) as erros_depois
    FROM check_in_error_logs 
    WHERE error_type = 'AUTH_ERROR' 
    AND created_at >= NOW() - INTERVAL '1 hour'
)
SELECT 
    'Comparação de erros AUTH_ERROR' as metrica,
    bf.erros_antes,
    af.erros_depois,
    CASE 
        WHEN af.erros_depois < bf.erros_antes THEN '✅ MELHOROU'
        WHEN af.erros_depois = bf.erros_antes THEN '➖ ESTÁVEL'
        ELSE '⚠️ PIOROU'
    END as tendencia
FROM before_fix bf, after_fix af;

-- =============================================
-- ETAPA 5: VERIFICAÇÃO DE DEPENDÊNCIAS
-- =============================================

SELECT '🔗 ETAPA 5: VERIFICAÇÃO DE SISTEMAS DEPENDENTES' as teste;

-- Verificar se workout_processing_queue está funcionando
SELECT 
    'Sistema de processamento assíncrono' as sistema,
    COUNT(*) as itens_na_fila,
    COUNT(CASE WHEN processed_for_ranking = false THEN 1 END) as pendentes_ranking,
    COUNT(CASE WHEN processed_for_dashboard = false THEN 1 END) as pendentes_dashboard
FROM workout_processing_queue 
WHERE created_at >= NOW() - INTERVAL '1 hour';

-- Verificar integridade de challenges
SELECT 
    'Integridade challenge_id' as verificacao,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN challenge_id IS NOT NULL THEN 1 END) as com_challenge,
    COUNT(CASE WHEN challenge_id IS NULL THEN 1 END) as sem_challenge
FROM workout_records 
WHERE created_at >= NOW() - INTERVAL '1 hour';

-- =============================================
-- RELATÓRIO FINAL DE SAÚDE DO SISTEMA
-- =============================================

SELECT '📋 RELATÓRIO FINAL DE SAÚDE DO SISTEMA' as titulo;

WITH system_health AS (
    SELECT 
        (SELECT COUNT(*) FROM pg_proc WHERE proname = 'record_workout_basic') as funcao_ativa,
        (SELECT COUNT(*) FROM workout_records WHERE created_at >= NOW() - INTERVAL '1 hour') as treinos_1h,
        (SELECT COUNT(*) FROM check_in_error_logs WHERE error_type = 'AUTH_ERROR' AND created_at >= NOW() - INTERVAL '1 hour') as erros_auth_1h,
        (SELECT COUNT(*) FROM auth.users) as total_usuarios,
        (SELECT AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) FROM workout_records WHERE created_at >= NOW() - INTERVAL '1 hour') as tempo_medio_processamento
)
SELECT 
    NOW() as data_avaliacao,
    CASE WHEN funcao_ativa > 0 THEN '✅' ELSE '❌' END || ' Função Principal' as status_funcao,
    CASE WHEN treinos_1h > 0 THEN '✅' ELSE '⚠️' END || ' Registros Recentes (' || treinos_1h || ')' as status_registros,
    CASE WHEN erros_auth_1h = 0 THEN '✅' ELSE '⚠️' END || ' Erros AUTH (' || erros_auth_1h || ')' as status_erros,
    '👥 ' || total_usuarios || ' usuários no sistema' as info_usuarios,
    CASE 
        WHEN tempo_medio_processamento < 1 THEN '🚀 Performance excelente'
        WHEN tempo_medio_processamento < 5 THEN '✅ Performance boa'
        ELSE '⚠️ Performance revisar'
    END as status_performance
FROM system_health;

SELECT '🎯 AVALIAÇÃO COMPLETA FINALIZADA' as resultado; 