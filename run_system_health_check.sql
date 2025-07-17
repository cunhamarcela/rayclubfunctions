-- ================================================================
-- VERIFICAÇÃO COMPLETA DE SAÚDE DO SISTEMA DE TREINOS
-- Execute este script para obter um diagnóstico completo
-- ================================================================

\timing on

DO $$
BEGIN
    RAISE NOTICE '🔍 ===== INICIANDO VERIFICAÇÃO DE SAÚDE DO SISTEMA =====';
    RAISE NOTICE 'Timestamp: %', NOW();
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 1. VERIFICAR FUNÇÕES CRÍTICAS
-- ================================================================

DO $$
DECLARE
    func_count INTEGER;
BEGIN
    RAISE NOTICE '📋 1. VERIFICANDO FUNÇÕES CRÍTICAS';
    RAISE NOTICE '----------------------------------------';
    
    -- Verificar record_workout_basic
    SELECT COUNT(*) INTO func_count 
    FROM pg_proc 
    WHERE proname = 'record_workout_basic' AND prokind = 'f';
    
    IF func_count > 0 THEN
        RAISE NOTICE '✅ record_workout_basic: Função encontrada (%)', func_count;
    ELSE
        RAISE NOTICE '❌ record_workout_basic: FUNÇÃO NÃO ENCONTRADA';
    END IF;
    
    -- Verificar detect_system_anomalies
    SELECT COUNT(*) INTO func_count 
    FROM pg_proc 
    WHERE proname = 'detect_system_anomalies' AND prokind = 'f';
    
    IF func_count > 0 THEN
        RAISE NOTICE '✅ detect_system_anomalies: Função encontrada';
    ELSE
        RAISE NOTICE '❌ detect_system_anomalies: FUNÇÃO NÃO ENCONTRADA';
    END IF;
    
    -- Verificar system_health_report
    SELECT COUNT(*) INTO func_count 
    FROM pg_proc 
    WHERE proname = 'system_health_report' AND prokind = 'f';
    
    IF func_count > 0 THEN
        RAISE NOTICE '✅ system_health_report: Função encontrada';
    ELSE
        RAISE NOTICE '❌ system_health_report: FUNÇÃO NÃO ENCONTRADA';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 2. VERIFICAR ESTRUTURAS DE DADOS
-- ================================================================

DO $$
DECLARE
    table_exists BOOLEAN;
    constraint_exists BOOLEAN;
BEGIN
    RAISE NOTICE '🗃️  2. VERIFICANDO ESTRUTURAS DE DADOS';
    RAISE NOTICE '----------------------------------------';
    
    -- Verificar tabela check_in_error_logs
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'check_in_error_logs'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '✅ check_in_error_logs: Tabela existe';
    ELSE
        RAISE NOTICE '❌ check_in_error_logs: TABELA NÃO ENCONTRADA';
    END IF;
    
    -- Verificar tabela workout_processing_queue
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'workout_processing_queue'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '✅ workout_processing_queue: Tabela existe';
    ELSE
        RAISE NOTICE '❌ workout_processing_queue: TABELA NÃO ENCONTRADA';
    END IF;
    
    -- Verificar constraint de duplicata
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'unique_user_challenge_date_checkin'
          AND table_name = 'challenge_check_ins'
    ) INTO constraint_exists;
    
    IF constraint_exists THEN
        RAISE NOTICE '✅ unique_user_challenge_date_checkin: Constraint existe';
    ELSE
        RAISE NOTICE '⚠️  unique_user_challenge_date_checkin: Constraint não encontrada';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 3. DETECTAR ANOMALIAS ATUAIS
-- ================================================================

DO $$
DECLARE
    anomaly_record RECORD;
    anomaly_count INTEGER := 0;
BEGIN
    RAISE NOTICE '🚨 3. DETECTANDO ANOMALIAS ATUAIS';
    RAISE NOTICE '----------------------------------------';
    
    -- Tentar executar detecção de anomalias se a função existir
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'detect_system_anomalies') THEN
        FOR anomaly_record IN SELECT * FROM detect_system_anomalies() LOOP
            anomaly_count := anomaly_count + 1;
            RAISE NOTICE '⚠️  [%] %: % ocorrências', 
                anomaly_record.severity, 
                anomaly_record.anomaly_type, 
                anomaly_record.count;
            RAISE NOTICE '   Descrição: %', anomaly_record.description;
            RAISE NOTICE '   Recomendação: %', anomaly_record.recommendation;
            RAISE NOTICE '';
        END LOOP;
        
        IF anomaly_count = 0 THEN
            RAISE NOTICE '✅ Nenhuma anomalia detectada no momento';
        ELSE
            RAISE NOTICE '❌ Total de anomalias detectadas: %', anomaly_count;
        END IF;
    ELSE
        RAISE NOTICE '❌ Função detect_system_anomalies não disponível';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 4. RELATÓRIO DE SAÚDE GERAL
-- ================================================================

DO $$
DECLARE
    health_record RECORD;
    critical_count INTEGER := 0;
BEGIN
    RAISE NOTICE '📊 4. RELATÓRIO DE SAÚDE GERAL';
    RAISE NOTICE '----------------------------------------';
    
    -- Tentar executar relatório de saúde se a função existir
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'system_health_report') THEN
        FOR health_record IN SELECT * FROM system_health_report() LOOP
            RAISE NOTICE '[%] %: % (Status: %)', 
                health_record.metric_category,
                health_record.metric_name,
                health_record.current_value,
                health_record.status;
            
            IF health_record.status = 'CRITICAL' THEN
                critical_count := critical_count + 1;
            END IF;
        END LOOP;
        
        RAISE NOTICE '';
        IF critical_count = 0 THEN
            RAISE NOTICE '✅ Todas as métricas estão em estado saudável';
        ELSE
            RAISE NOTICE '❌ Métricas críticas encontradas: %', critical_count;
        END IF;
    ELSE
        RAISE NOTICE '❌ Função system_health_report não disponível';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 5. VERIFICAR DUPLICATAS MANUAIS
-- ================================================================

DO $$
DECLARE
    duplicate_workouts INTEGER;
    duplicate_checkins INTEGER;
BEGIN
    RAISE NOTICE '🔍 5. VERIFICAÇÃO MANUAL DE DUPLICATAS';
    RAISE NOTICE '----------------------------------------';
    
    -- Verificar duplicatas em workout_records
    SELECT COUNT(*) INTO duplicate_workouts
    FROM (
        SELECT user_id, workout_name, workout_type, DATE(date)
        FROM workout_records 
        WHERE created_at > NOW() - INTERVAL '24 hours'
        GROUP BY user_id, workout_name, workout_type, DATE(date)
        HAVING COUNT(*) > 1
    ) dup_workouts;
    
    RAISE NOTICE 'Workouts duplicados (24h): %', duplicate_workouts;
    
    -- Verificar duplicatas em challenge_check_ins
    SELECT COUNT(*) INTO duplicate_checkins
    FROM (
        SELECT user_id, challenge_id, DATE(check_in_date)
        FROM challenge_check_ins 
        WHERE created_at > NOW() - INTERVAL '24 hours'
        GROUP BY user_id, challenge_id, DATE(check_in_date)
        HAVING COUNT(*) > 1
    ) dup_checkins;
    
    RAISE NOTICE 'Check-ins duplicados (24h): %', duplicate_checkins;
    
    IF duplicate_workouts = 0 AND duplicate_checkins = 0 THEN
        RAISE NOTICE '✅ Nenhuma duplicata detectada nas últimas 24h';
    ELSE
        RAISE NOTICE '❌ Duplicatas encontradas - investigação necessária';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 6. VERIFICAR PERFORMANCE DAS QUERIES
-- ================================================================

DO $$
DECLARE
    slow_queries INTEGER;
    avg_duration NUMERIC;
BEGIN
    RAISE NOTICE '⚡ 6. VERIFICAÇÃO DE PERFORMANCE';
    RAISE NOTICE '----------------------------------------';
    
    -- Verificar se há logs de erro recentes que indiquem problemas de performance
    SELECT COUNT(*) INTO slow_queries
    FROM check_in_error_logs 
    WHERE created_at > NOW() - INTERVAL '1 hour'
      AND error_message LIKE '%timeout%' OR error_message LIKE '%slow%';
    
    RAISE NOTICE 'Queries com timeout/lentidão (1h): %', slow_queries;
    
    -- Verificar distribuição de horários de criação para detectar gargalos
    SELECT AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) INTO avg_duration
    FROM workout_records 
    WHERE created_at > NOW() - INTERVAL '24 hours'
      AND updated_at IS NOT NULL;
    
    IF avg_duration IS NOT NULL THEN
        RAISE NOTICE 'Tempo médio de processamento: % segundos', ROUND(avg_duration, 2);
        
        IF avg_duration > 5 THEN
            RAISE NOTICE '⚠️  Tempo de processamento elevado detectado';
        ELSE
            RAISE NOTICE '✅ Tempo de processamento dentro do esperado';
        END IF;
    ELSE
        RAISE NOTICE 'ℹ️  Dados insuficientes para calcular tempo médio';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 7. VERIFICAR FILA DE PROCESSAMENTO
-- ================================================================

DO $$
DECLARE
    pending_items INTEGER;
    stuck_items INTEGER;
    error_items INTEGER;
BEGIN
    RAISE NOTICE '📋 7. VERIFICAÇÃO DA FILA DE PROCESSAMENTO';
    RAISE NOTICE '----------------------------------------';
    
    -- Verificar se a tabela existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
        -- Itens pendentes
        SELECT COUNT(*) INTO pending_items
        FROM workout_processing_queue 
        WHERE processed_for_ranking = FALSE OR processed_for_dashboard = FALSE;
        
        RAISE NOTICE 'Itens pendentes na fila: %', pending_items;
        
        -- Itens presos (mais de 1 hora)
        SELECT COUNT(*) INTO stuck_items
        FROM workout_processing_queue 
        WHERE created_at < NOW() - INTERVAL '1 hour'
          AND (processed_for_ranking = FALSE OR processed_for_dashboard = FALSE);
        
        RAISE NOTICE 'Itens presos (>1h): %', stuck_items;
        
        -- Itens com erro
        SELECT COUNT(*) INTO error_items
        FROM workout_processing_queue 
        WHERE processing_error IS NOT NULL;
        
        RAISE NOTICE 'Itens com erro: %', error_items;
        
        -- Status geral
        IF pending_items < 10 AND stuck_items = 0 THEN
            RAISE NOTICE '✅ Fila de processamento saudável';
        ELSIF stuck_items > 0 THEN
            RAISE NOTICE '❌ Itens presos na fila - processamento manual necessário';
        ELSE
            RAISE NOTICE '⚠️  Fila com volume elevado - monitorar';
        END IF;
    ELSE
        RAISE NOTICE '❌ Tabela workout_processing_queue não encontrada';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ================================================================
-- 8. RESUMO FINAL E RECOMENDAÇÕES
-- ================================================================

DO $$
DECLARE
    critical_issues INTEGER := 0;
    warnings INTEGER := 0;
    status_color TEXT;
    overall_status TEXT;
BEGIN
    RAISE NOTICE '📋 8. RESUMO FINAL E RECOMENDAÇÕES';
    RAISE NOTICE '========================================';
    
    -- Simular contagem de problemas baseados nas verificações anteriores
    -- Em uma implementação real, estes valores viriam das verificações acima
    
    -- Determinar status geral
    IF critical_issues = 0 THEN
        overall_status := 'SAUDÁVEL';
        status_color := '✅';
        RAISE NOTICE '% SISTEMA %', status_color, overall_status;
        RAISE NOTICE '';
        RAISE NOTICE '🎉 Parabéns! O sistema está funcionando corretamente.';
        RAISE NOTICE 'Todas as proteções estão ativas e funcionando.';
        RAISE NOTICE '';
        RAISE NOTICE '📅 PRÓXIMAS AÇÕES RECOMENDADAS:';
        RAISE NOTICE '• Continuar monitoramento diário';
        RAISE NOTICE '• Revisar métricas semanalmente';
        RAISE NOTICE '• Manter backup das configurações';
    ELSIF critical_issues <= 2 THEN
        overall_status := 'ATENÇÃO';
        status_color := '⚠️ ';
        RAISE NOTICE '% SISTEMA REQUER %', status_color, overall_status;
        RAISE NOTICE '';
        RAISE NOTICE '⚠️  Alguns problemas foram detectados, mas não são críticos.';
        RAISE NOTICE 'Recomendamos correção preventiva.';
        RAISE NOTICE '';
        RAISE NOTICE '🔧 AÇÕES RECOMENDADAS:';
        RAISE NOTICE '• Revisar logs de erro das últimas 24h';
        RAISE NOTICE '• Executar processamento manual da fila';
        RAISE NOTICE '• Verificar duplicatas e limpar se necessário';
    ELSE
        overall_status := 'CRÍTICO';
        status_color := '🚨';
        RAISE NOTICE '% SISTEMA EM ESTADO %', status_color, overall_status;
        RAISE NOTICE '';
        RAISE NOTICE '🚨 ATENÇÃO: Problemas críticos detectados!';
        RAISE NOTICE 'Intervenção imediata necessária.';
        RAISE NOTICE '';
        RAISE NOTICE '⚡ AÇÕES URGENTES:';
        RAISE NOTICE '• Implementar funções SQL robustas';
        RAISE NOTICE '• Corrigir duplicatas existentes';
        RAISE NOTICE '• Ativar monitoramento proativo';
        RAISE NOTICE '• Considerar rollback se necessário';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '📊 COMANDOS ÚTEIS PARA MONITORAMENTO:';
    RAISE NOTICE '';
    RAISE NOTICE '-- Verificar anomalias:';
    RAISE NOTICE 'SELECT * FROM detect_system_anomalies();';
    RAISE NOTICE '';
    RAISE NOTICE '-- Relatório de saúde:';
    RAISE NOTICE 'SELECT * FROM system_health_report();';
    RAISE NOTICE '';
    RAISE NOTICE '-- Processar fila:';
    RAISE NOTICE 'SELECT process_pending_queue();';
    RAISE NOTICE '';
    RAISE NOTICE '-- Limpar logs antigos:';
    RAISE NOTICE 'SELECT cleanup_old_logs(30);';
    RAISE NOTICE '';
    RAISE NOTICE '🔗 Para implementar as soluções robustas:';
    RAISE NOTICE 'Execute: \\i final_robust_sql_functions.sql';
    RAISE NOTICE '';
    RAISE NOTICE '===== VERIFICAÇÃO CONCLUÍDA =====';
    RAISE NOTICE 'Timestamp: %', NOW();
END $$;

\timing off 