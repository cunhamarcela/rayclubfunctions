-- ====================================================================
-- MONITOR DE SAÚDE SIMPLES - Execute periodicamente para monitorar
-- ====================================================================

-- Execute este script a cada 30 minutos para monitorar o sistema

SELECT '🏥 MONITOR DE SAÚDE DO SISTEMA' as titulo, NOW() as timestamp;

-- =============================================
-- MÉTRICAS PRINCIPAIS (ÚLTIMAS 2 HORAS)
-- =============================================

-- 1. Treinos registrados com sucesso
SELECT 
    '✅ Treinos Registrados (2h)' as metrica,
    COUNT(*) as total,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    CASE 
        WHEN COUNT(*) > 0 THEN '🟢 SAUDÁVEL' 
        ELSE '🔴 SEM ATIVIDADE' 
    END as status
FROM workout_records 
WHERE created_at >= NOW() - INTERVAL '2 hours';

-- 2. Erros críticos
SELECT 
    '❌ Erros USER_NOT_FOUND (2h)' as metrica,
    COUNT(*) as total,
    CASE 
        WHEN COUNT(*) = 0 THEN '🟢 ZERO ERROS' 
        WHEN COUNT(*) < 5 THEN '🟡 POUCOS ERROS'
        ELSE '🔴 MUITOS ERROS' 
    END as status
FROM check_in_error_logs 
WHERE error_type = 'AUTH_ERROR' 
  AND created_at >= NOW() - INTERVAL '2 hours';

-- 3. Performance da função principal
DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    execution_time NUMERIC;
    test_user_id UUID;
    test_result JSONB;
BEGIN
    -- Pegar usuário válido para teste
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        start_time := clock_timestamp();
        
        -- Teste de performance
        SELECT record_workout_basic(
            test_user_id,
            'Monitor Health Test',
            'Test',
            30,
            NOW(),
            NULL, NULL, 'Health check test', NULL
        ) INTO test_result;
        
        end_time := clock_timestamp();
        execution_time := EXTRACT(MILLISECONDS FROM (end_time - start_time));
        
        -- Criar tabela temporária para resultados se não existir
        CREATE TEMP TABLE IF NOT EXISTS temp_health_results (
            categoria TEXT,
            valor TEXT,
            status TEXT
        );
        
        INSERT INTO temp_health_results VALUES (
            'Performance Test',
            execution_time || ' ms',
            CASE 
                WHEN execution_time < 100 THEN '🟢 EXCELENTE'
                WHEN execution_time < 500 THEN '🟡 BOA'
                ELSE '🔴 LENTA'
            END
        );
        
        INSERT INTO temp_health_results VALUES (
            'Função Status',
            CASE WHEN (test_result->>'success')::boolean THEN 'Funcionando' ELSE 'Falha' END,
            CASE WHEN (test_result->>'success')::boolean THEN '🟢 FUNCIONANDO' ELSE '🔴 FALHA' END
        );
    ELSE
        CREATE TEMP TABLE IF NOT EXISTS temp_health_results (
            categoria TEXT,
            valor TEXT,
            status TEXT
        );
        
        INSERT INTO temp_health_results VALUES (
            'Teste de Performance',
            'Não executado',
            '⚠️ Nenhum usuário encontrado'
        );
    END IF;
END $$;

-- Mostrar resultados do teste de performance
SELECT * FROM temp_health_results WHERE categoria IS NOT NULL;

-- 4. Status geral do sistema
WITH health_metrics AS (
    SELECT 
        (SELECT COUNT(*) FROM workout_records WHERE created_at >= NOW() - INTERVAL '2 hours') as recent_workouts,
        (SELECT COUNT(*) FROM check_in_error_logs WHERE error_type = 'AUTH_ERROR' AND created_at >= NOW() - INTERVAL '2 hours') as auth_errors,
        (SELECT COUNT(*) FROM auth.users) as total_users,
        (SELECT COUNT(*) FROM pg_proc WHERE proname = 'record_workout_basic') as function_exists
)
SELECT 
    '🎯 STATUS GERAL' as categoria,
    CASE 
        WHEN function_exists = 0 THEN '🔴 FUNÇÃO AUSENTE'
        WHEN auth_errors > 10 THEN '🔴 MUITOS ERROS'
        WHEN recent_workouts = 0 THEN '🟡 SEM ATIVIDADE'
        WHEN recent_workouts > 0 AND auth_errors = 0 THEN '🟢 SISTEMA SAUDÁVEL'
        ELSE '🟡 ATENÇÃO NECESSÁRIA'
    END as status_sistema,
    recent_workouts as treinos_2h,
    auth_errors as erros_auth_2h,
    total_users as usuarios_totais
FROM health_metrics;

-- =============================================
-- ALERTAS AUTOMÁTICOS
-- =============================================

-- Alertas automáticos (usando SELECT para mostrar no terminal)
WITH alert_data AS (
    SELECT 
        (SELECT COUNT(*) FROM check_in_error_logs 
         WHERE error_type = 'AUTH_ERROR' 
           AND created_at >= NOW() - INTERVAL '1 hour') as errors_1h,
        (SELECT COUNT(*) FROM workout_records 
         WHERE created_at >= NOW() - INTERVAL '4 hours') as workouts_4h
)
SELECT 
    '🚨 ALERTAS AUTOMÁTICOS' as categoria,
    CASE 
        WHEN errors_1h > 5 THEN '🔴 ALERTA: ' || errors_1h || ' erros AUTH_ERROR na última hora!'
        WHEN workouts_4h = 0 THEN '⚠️ ALERTA: Nenhum treino registrado nas últimas 4 horas!'
        ELSE '✅ Sistema sem alertas críticos'
    END as status_alerta,
    errors_1h as erros_ultima_hora,
    workouts_4h as treinos_ultimas_4h
FROM alert_data;

-- =============================================
-- TIMESTAMP DO ÚLTIMO CHECK
-- =============================================

SELECT 
    '⏰ ÚLTIMO HEALTH CHECK' as info,
    NOW() as timestamp,
    'Execute novamente em 30 minutos' as proximo_check; 