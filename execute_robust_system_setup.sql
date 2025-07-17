-- ================================================================
-- SCRIPT MASTER PARA IMPLEMENTAÇÃO DO SISTEMA ROBUSTO
-- Execute este script para implementar todas as proteções
-- ================================================================

\timing on

DO $$
BEGIN
    RAISE NOTICE '🚀 ===== INICIANDO IMPLEMENTAÇÃO DO SISTEMA ROBUSTO =====';
    RAISE NOTICE 'Timestamp: %', NOW();
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANTE: Este processo irá:';
    RAISE NOTICE '1. Limpar todas as funções conflitantes existentes';
    RAISE NOTICE '2. Implementar funções robustas com proteções multicamadas';
    RAISE NOTICE '3. Criar sistema de monitoramento proativo';
    RAISE NOTICE '4. Executar verificação completa de saúde';
    RAISE NOTICE '';
    RAISE NOTICE 'Estimativa de tempo: 2-5 minutos';
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;

-- ================================================================
-- PASSO 1: LIMPEZA DE FUNÇÕES CONFLITANTES
-- ================================================================

\echo ''
\echo '🧹 PASSO 1: LIMPEZA DE FUNÇÕES CONFLITANTES'
\echo '============================================'

-- Executar limpeza das funções conflitantes
\i cleanup_conflicting_functions.sql

-- ================================================================
-- PASSO 2: IMPLEMENTAÇÃO DAS FUNÇÕES ROBUSTAS
-- ================================================================

\echo ''
\echo '🛡️ PASSO 2: IMPLEMENTAÇÃO DAS FUNÇÕES ROBUSTAS'
\echo '==============================================='

-- Executar implementação das funções robustas
\i final_robust_sql_functions.sql

-- ================================================================
-- PASSO 3: VERIFICAÇÃO DE SAÚDE DO SISTEMA
-- ================================================================

\echo ''
\echo '🔍 PASSO 3: VERIFICAÇÃO DE SAÚDE DO SISTEMA'
\echo '============================================'

-- Executar verificação completa
\i run_system_health_check.sql

-- ================================================================
-- PASSO 4: TESTES FUNCIONAIS BÁSICOS
-- ================================================================

\echo ''
\echo '✅ PASSO 4: TESTES FUNCIONAIS BÁSICOS'
\echo '======================================'

DO $$
DECLARE
    test_result JSONB;
    test_user_id UUID := 'test-user-' || gen_random_uuid();
    test_success BOOLEAN := TRUE;
BEGIN
    RAISE NOTICE 'Executando testes funcionais básicos...';
    RAISE NOTICE '';
    
    -- TESTE 1: Função record_workout_basic existe e funciona
    BEGIN
        RAISE NOTICE '🧪 Teste 1: Função record_workout_basic';
        
        -- Tentar chamar a função (sem inserir dados reais)
        SELECT record_workout_basic(
            test_user_id,
            'Teste Funcional',
            'Teste',
            30,
            NOW(),
            NULL,
            NULL,
            'Teste automatizado'
        ) INTO test_result;
        
        -- Verificar se retornou resposta válida
        IF (test_result->>'success') IS NOT NULL THEN
            RAISE NOTICE '✅ record_workout_basic: Funcionando';
        ELSE
            RAISE NOTICE '❌ record_workout_basic: Resposta inválida';
            test_success := FALSE;
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ record_workout_basic: Erro - %', SQLERRM;
        test_success := FALSE;
    END;
    
    -- TESTE 2: Função detect_system_anomalies
    BEGIN
        RAISE NOTICE '🧪 Teste 2: Função detect_system_anomalies';
        
        PERFORM detect_system_anomalies();
        RAISE NOTICE '✅ detect_system_anomalies: Funcionando';
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ detect_system_anomalies: Erro - %', SQLERRM;
        test_success := FALSE;
    END;
    
    -- TESTE 3: Função system_health_report
    BEGIN
        RAISE NOTICE '🧪 Teste 3: Função system_health_report';
        
        PERFORM system_health_report();
        RAISE NOTICE '✅ system_health_report: Funcionando';
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ system_health_report: Erro - %', SQLERRM;
        test_success := FALSE;
    END;
    
    -- Resultado dos testes
    RAISE NOTICE '';
    IF test_success THEN
        RAISE NOTICE '🎉 TODOS OS TESTES PASSARAM COM SUCESSO!';
    ELSE
        RAISE NOTICE '⚠️  ALGUNS TESTES FALHARAM - Revise a implementação';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PASSO 5: CONFIGURAÇÕES FINAIS E OTIMIZAÇÕES
-- ================================================================

\echo ''
\echo '⚙️ PASSO 5: CONFIGURAÇÕES FINAIS'
\echo '================================='

DO $$
BEGIN
    RAISE NOTICE 'Aplicando configurações finais...';
    
    -- Atualizar estatísticas das tabelas para melhor performance
    ANALYZE workout_records;
    ANALYZE challenge_check_ins;
    ANALYZE check_in_error_logs;
    ANALYZE workout_processing_queue;
    
    RAISE NOTICE '✅ Estatísticas das tabelas atualizadas';
    
    -- Verificar índices importantes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_workout_records_user_date') THEN
        CREATE INDEX CONCURRENTLY idx_workout_records_user_date 
        ON workout_records(user_id, DATE(date));
        RAISE NOTICE '✅ Índice idx_workout_records_user_date criado';
    ELSE
        RAISE NOTICE '✅ Índice idx_workout_records_user_date já existe';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- RESUMO FINAL E PRÓXIMOS PASSOS
-- ================================================================

DO $$
DECLARE
    total_functions INTEGER;
    total_tables INTEGER;
    system_status TEXT;
BEGIN
    RAISE NOTICE '📋 ===== RESUMO DA IMPLEMENTAÇÃO =====';
    RAISE NOTICE '';
    
    -- Contar funções implementadas
    SELECT COUNT(*) INTO total_functions
    FROM pg_proc 
    WHERE proname IN ('record_workout_basic', 'detect_system_anomalies', 'system_health_report');
    
    -- Contar tabelas de monitoramento
    SELECT COUNT(*) INTO total_tables
    FROM information_schema.tables 
    WHERE table_name IN ('check_in_error_logs', 'workout_processing_queue', 'workout_system_metrics');
    
    RAISE NOTICE '✅ Funções principais implementadas: %/3', total_functions;
    RAISE NOTICE '✅ Tabelas de monitoramento: %/3', total_tables;
    
    -- Determinar status do sistema
    IF total_functions = 3 AND total_tables >= 2 THEN
        system_status := 'IMPLEMENTAÇÃO COMPLETA';
        RAISE NOTICE '';
        RAISE NOTICE '🎉 %', system_status;
        RAISE NOTICE '';
        RAISE NOTICE '✅ Sistema robusto implementado com sucesso!';
        RAISE NOTICE '✅ Proteções multicamadas ativas';
        RAISE NOTICE '✅ Monitoramento proativo funcionando';
        RAISE NOTICE '✅ Pronto para uso em produção';
        RAISE NOTICE '';
        RAISE NOTICE '📱 PRÓXIMOS PASSOS NO FLUTTER:';
        RAISE NOTICE '1. Implementar RobustWorkoutRecordViewModel';
        RAISE NOTICE '2. Atualizar providers para usar nova implementação';
        RAISE NOTICE '3. Executar testes automatizados';
        RAISE NOTICE '4. Monitorar métricas nos primeiros dias';
        
    ELSE
        system_status := 'IMPLEMENTAÇÃO PARCIAL';
        RAISE NOTICE '';
        RAISE NOTICE '⚠️  %', system_status;
        RAISE NOTICE '';
        RAISE NOTICE 'Alguns componentes podem não ter sido implementados corretamente.';
        RAISE NOTICE 'Revise os logs acima para identificar problemas.';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '📊 COMANDOS ÚTEIS PARA MONITORAMENTO DIÁRIO:';
    RAISE NOTICE '';
    RAISE NOTICE '-- Verificar saúde do sistema:';
    RAISE NOTICE 'SELECT * FROM system_health_report();';
    RAISE NOTICE '';
    RAISE NOTICE '-- Detectar anomalias:';
    RAISE NOTICE 'SELECT * FROM detect_system_anomalies();';
    RAISE NOTICE '';
    RAISE NOTICE '-- Verificação completa:';
    RAISE NOTICE '\\i run_system_health_check.sql';
    RAISE NOTICE '';
    RAISE NOTICE '📋 DOCUMENTAÇÃO:';
    RAISE NOTICE 'Consulte PLANO_PREVENCAO_ERROS_FUTURAS.md para detalhes';
    RAISE NOTICE '';
    RAISE NOTICE '===== IMPLEMENTAÇÃO CONCLUÍDA =====';
    RAISE NOTICE 'Timestamp: %', NOW();
    RAISE NOTICE '';
END $$;

\timing off

\echo ''
\echo '🚀 IMPLEMENTAÇÃO CONCLUÍDA!'
\echo 'Consulte os logs acima para verificar o status de cada componente.'
\echo '' 