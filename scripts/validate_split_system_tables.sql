-- Script de validação das tabelas do Sistema Split
-- Este script verifica se as tabelas e índices necessários para o sistema split
-- foram criados corretamente e gera um relatório de status.

DO $$
DECLARE
    table_count INT;
    column_count INT;
    index_count INT;
    report JSONB := '{}'::JSONB;
    table_report JSONB;
BEGIN
    RAISE NOTICE '===== VALIDAÇÃO DO SISTEMA SPLIT DE REGISTRO DE TREINOS =====';
    RAISE NOTICE '';
    
    -- Verificação da tabela workout_processing_queue
    SELECT COUNT(*) INTO table_count FROM pg_tables 
    WHERE schemaname = 'public' AND tablename = 'workout_processing_queue';
    
    table_report := jsonb_build_object(
        'exists', table_count > 0,
        'columns', '{}'::JSONB,
        'indexes', '{}'::JSONB
    );
    
    IF table_count > 0 THEN
        RAISE NOTICE 'Tabela workout_processing_queue: ✅ EXISTE';
        
        -- Verificação de colunas
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'workout_id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, workout_id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna workout_id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'user_id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, user_id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna user_id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'challenge_id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, challenge_id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna challenge_id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processed_for_ranking'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, processed_for_ranking}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna processed_for_ranking: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processed_for_dashboard'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, processed_for_dashboard}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna processed_for_dashboard: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processing_error'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, processing_error}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna processing_error: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'created_at'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, created_at}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna created_at: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processed_at'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, processed_at}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna processed_at: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        -- Verificação de índices
        SELECT COUNT(*) INTO index_count FROM pg_indexes 
        WHERE schemaname = 'public' AND tablename = 'workout_processing_queue' AND indexname = 'idx_workout_queue_processing';
        
        table_report := jsonb_set(table_report, '{indexes, idx_workout_queue_processing}', to_jsonb(index_count > 0));
        RAISE NOTICE '  - Índice idx_workout_queue_processing: %', CASE WHEN index_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        
        SELECT COUNT(*) INTO index_count FROM pg_indexes 
        WHERE schemaname = 'public' AND tablename = 'workout_processing_queue' AND indexname = 'idx_workout_queue_workout_id';
        
        table_report := jsonb_set(table_report, '{indexes, idx_workout_queue_workout_id}', to_jsonb(index_count > 0));
        RAISE NOTICE '  - Índice idx_workout_queue_workout_id: %', CASE WHEN index_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
    ELSE
        RAISE NOTICE 'Tabela workout_processing_queue: ❌ NÃO EXISTE';
    END IF;
    
    report := jsonb_set(report, '{workout_processing_queue}', table_report);
    
    RAISE NOTICE '';
    
    -- Verificação da tabela check_in_error_logs
    SELECT COUNT(*) INTO table_count FROM pg_tables 
    WHERE schemaname = 'public' AND tablename = 'check_in_error_logs';
    
    table_report := jsonb_build_object(
        'exists', table_count > 0,
        'columns', '{}'::JSONB,
        'indexes', '{}'::JSONB
    );
    
    IF table_count > 0 THEN
        RAISE NOTICE 'Tabela check_in_error_logs: ✅ EXISTE';
        
        -- Verificação de colunas
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'user_id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, user_id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna user_id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'challenge_id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, challenge_id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna challenge_id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'workout_id'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, workout_id}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna workout_id: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'request_data'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, request_data}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna request_data: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'response_data'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, response_data}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna response_data: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'error_message'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, error_message}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna error_message: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'error_detail'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, error_detail}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna error_detail: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'status'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, status}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna status: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        FOR column_count IN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'created_at'
        ) LOOP
            table_report := jsonb_set(table_report, '{columns, created_at}', to_jsonb(column_count > 0));
            RAISE NOTICE '  - Coluna created_at: %', CASE WHEN column_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        END LOOP;
        
        -- Verificação de índices
        SELECT COUNT(*) INTO index_count FROM pg_indexes 
        WHERE schemaname = 'public' AND tablename = 'check_in_error_logs' AND indexname = 'idx_checkin_error_logs_user';
        
        table_report := jsonb_set(table_report, '{indexes, idx_checkin_error_logs_user}', to_jsonb(index_count > 0));
        RAISE NOTICE '  - Índice idx_checkin_error_logs_user: %', CASE WHEN index_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
        
        SELECT COUNT(*) INTO index_count FROM pg_indexes 
        WHERE schemaname = 'public' AND tablename = 'check_in_error_logs' AND indexname = 'idx_checkin_error_logs_date';
        
        table_report := jsonb_set(table_report, '{indexes, idx_checkin_error_logs_date}', to_jsonb(index_count > 0));
        RAISE NOTICE '  - Índice idx_checkin_error_logs_date: %', CASE WHEN index_count > 0 THEN '✅ OK' ELSE '❌ AUSENTE' END;
    ELSE
        RAISE NOTICE 'Tabela check_in_error_logs: ❌ NÃO EXISTE';
    END IF;
    
    report := jsonb_set(report, '{check_in_error_logs}', table_report);
    
    RAISE NOTICE '';
    RAISE NOTICE '===== VALIDAÇÃO DE FUNÇÕES =====';
    
    -- Verificação das funções
    FOR table_count IN (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'record_workout_basic' AND prokind = 'f'
    ) LOOP
        report := jsonb_set(report, '{functions, record_workout_basic}', to_jsonb(table_count > 0));
        RAISE NOTICE 'Função record_workout_basic: %', CASE WHEN table_count > 0 THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END;
    END LOOP;
    
    FOR table_count IN (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'process_workout_for_ranking' AND prokind = 'f'
    ) LOOP
        report := jsonb_set(report, '{functions, process_workout_for_ranking}', to_jsonb(table_count > 0));
        RAISE NOTICE 'Função process_workout_for_ranking: %', CASE WHEN table_count > 0 THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END;
    END LOOP;
    
    FOR table_count IN (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'process_workout_for_dashboard' AND prokind = 'f'
    ) LOOP
        report := jsonb_set(report, '{functions, process_workout_for_dashboard}', to_jsonb(table_count > 0));
        RAISE NOTICE 'Função process_workout_for_dashboard: %', CASE WHEN table_count > 0 THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END;
    END LOOP;
    
    FOR table_count IN (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'retry_workout_processing' AND prokind = 'f'
    ) LOOP
        report := jsonb_set(report, '{functions, retry_workout_processing}', to_jsonb(table_count > 0));
        RAISE NOTICE 'Função retry_workout_processing: %', CASE WHEN table_count > 0 THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END;
    END LOOP;
    
    -- Problema de overload
    SELECT COUNT(*) INTO table_count FROM pg_proc 
    WHERE proname = 'record_challenge_check_in_v2' AND prokind = 'f';
    
    report := jsonb_set(report, '{functions, record_challenge_check_in_v2_count}', to_jsonb(table_count));
    RAISE NOTICE 'Função record_challenge_check_in_v2: % versões encontradas (%)', 
        CASE 
            WHEN table_count = 0 THEN '❌ NENHUMA' 
            WHEN table_count = 1 THEN '✅ OK' 
            ELSE '⚠️ MÚLTIPLAS' 
        END,
        table_count;
    
    IF table_count > 1 THEN
        RAISE NOTICE 'ALERTA: Múltiplas versões da função record_challenge_check_in_v2 encontradas, causando ambiguidade!';
        RAISE NOTICE 'Esse é provavelmente o motivo do erro que você está enfrentando.';
    END IF;
    
    -- Resumo
    RAISE NOTICE '';
    RAISE NOTICE '===== SUMÁRIO =====';
    RAISE NOTICE 'Status das tabelas necessárias:';
    RAISE NOTICE '  - workout_processing_queue: %', CASE WHEN (report->'workout_processing_queue'->>'exists')::BOOLEAN THEN '✅ OK' ELSE '❌ FALTANDO' END;
    RAISE NOTICE '  - check_in_error_logs: %', CASE WHEN (report->'check_in_error_logs'->>'exists')::BOOLEAN THEN '✅ OK' ELSE '❌ FALTANDO' END;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Status das funções necessárias:';
    RAISE NOTICE '  - record_workout_basic: %', CASE WHEN (report->'functions'->>'record_workout_basic')::BOOLEAN THEN '✅ OK' ELSE '❌ FALTANDO' END;
    RAISE NOTICE '  - process_workout_for_ranking: %', CASE WHEN (report->'functions'->>'process_workout_for_ranking')::BOOLEAN THEN '✅ OK' ELSE '❌ FALTANDO' END;
    RAISE NOTICE '  - process_workout_for_dashboard: %', CASE WHEN (report->'functions'->>'process_workout_for_dashboard')::BOOLEAN THEN '✅ OK' ELSE '❌ FALTANDO' END;
    RAISE NOTICE '  - retry_workout_processing: %', CASE WHEN (report->'functions'->>'retry_workout_processing')::BOOLEAN THEN '✅ OK' ELSE '❌ FALTANDO' END;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Problemas críticos identificados:';
    IF (report->'functions'->>'record_challenge_check_in_v2_count')::INT > 1 THEN
        RAISE NOTICE '  - ⚠️ Ambiguidade na função record_challenge_check_in_v2 (encontradas % versões)', (report->'functions'->>'record_challenge_check_in_v2_count')::INT;
    ELSIF (report->'functions'->>'record_challenge_check_in_v2_count')::INT = 0 THEN
        RAISE NOTICE '  - ❌ Função record_challenge_check_in_v2 não encontrada';
    ELSE
        RAISE NOTICE '  - ✅ Nenhum problema crítico identificado';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Relatório completo (formato JSON):';
    RAISE NOTICE '%', report;
END $$;

-- Consulta para mostrar as diferentes assinaturas da função record_challenge_check_in_v2
SELECT 
    p.proname as "Nome da Função",
    pg_get_function_arguments(p.oid) as "Argumentos",
    pg_get_function_result(p.oid) as "Tipo de Retorno",
    obj_description(p.oid, 'pg_proc') as "Descrição"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public' AND
    p.proname = 'record_challenge_check_in_v2'
ORDER BY p.proname; 