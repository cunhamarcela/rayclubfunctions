-- Script de validação das tabelas do Sistema Split que retorna resultados como tabela
-- Esta versão é otimizada para o Supabase SQL Editor, que não exibe mensagens RAISE NOTICE

WITH table_validation AS (
    -- Valida a existência das tabelas necessárias
    SELECT 
        'workout_processing_queue' as table_name,
        EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'workout_processing_queue') as exists,
        
        -- Verifica colunas
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'id') as has_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'workout_id') as has_workout_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'user_id') as has_user_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'challenge_id') as has_challenge_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processed_for_ranking') as has_processed_for_ranking,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processed_for_dashboard') as has_processed_for_dashboard,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processing_error') as has_processing_error,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'created_at') as has_created_at,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'workout_processing_queue' AND column_name = 'processed_at') as has_processed_at,
        
        -- Verifica índices
        EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'workout_processing_queue' AND indexname = 'idx_workout_queue_processing') as has_idx_processing,
        EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'workout_processing_queue' AND indexname = 'idx_workout_queue_workout_id') as has_idx_workout_id
    
    UNION ALL
    
    SELECT 
        'check_in_error_logs' as table_name,
        EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'check_in_error_logs') as exists,
        
        -- Verifica colunas
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'id') as has_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'workout_id') as has_workout_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'user_id') as has_user_id,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'challenge_id') as has_challenge_id,
        false as has_processed_for_ranking, -- N/A para esta tabela
        false as has_processed_for_dashboard, -- N/A para esta tabela
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'error_message') as has_processing_error,
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'check_in_error_logs' AND column_name = 'created_at') as has_created_at,
        false as has_processed_at, -- N/A para esta tabela
        
        -- Verifica índices
        EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'check_in_error_logs' AND indexname = 'idx_checkin_error_logs_user') as has_idx_user,
        EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'check_in_error_logs' AND indexname = 'idx_checkin_error_logs_date') as has_idx_date
),

function_validation AS (
    -- Valida existência das funções
    SELECT 
        'record_workout_basic' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic' AND prokind = 'f') as exists
    
    UNION ALL
    
    SELECT 
        'process_workout_for_ranking' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'process_workout_for_ranking' AND prokind = 'f') as exists
        
    UNION ALL
    
    SELECT 
        'process_workout_for_dashboard' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'process_workout_for_dashboard' AND prokind = 'f') as exists
        
    UNION ALL
    
    SELECT 
        'retry_workout_processing' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'retry_workout_processing' AND prokind = 'f') as exists
),

record_challenge_check_in_v2_count AS (
    -- Conta quantas versões da função record_challenge_check_in_v2 existem
    SELECT COUNT(*) as count
    FROM pg_proc 
    WHERE proname = 'record_challenge_check_in_v2' AND prokind = 'f'
),

record_challenge_check_in_v2_details AS (
    -- Obtém detalhes das diferentes assinaturas da função record_challenge_check_in_v2
    SELECT 
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments,
        pg_get_function_result(p.oid) as return_type
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE 
        n.nspname = 'public' AND
        p.proname = 'record_challenge_check_in_v2'
)

-- Resultado Final: Overview do status
SELECT 'Tabelas' as category, 
       SUM(CASE WHEN exists THEN 1 ELSE 0 END) as implemented,
       COUNT(*) as total,
       SUM(CASE WHEN exists THEN 1 ELSE 0 END)::float / COUNT(*) * 100 as percentage
FROM table_validation

UNION ALL

SELECT 'Funções' as category, 
       SUM(CASE WHEN exists THEN 1 ELSE 0 END) as implemented,
       COUNT(*) as total,
       SUM(CASE WHEN exists THEN 1 ELSE 0 END)::float / COUNT(*) * 100 as percentage
FROM function_validation

UNION ALL

SELECT 'Problema Crítico: record_challenge_check_in_v2' as category,
       CASE WHEN count > 1 THEN count ELSE 0 END as implemented,
       1 as total,
       CASE WHEN count > 1 THEN 100.0 ELSE 0.0 END as percentage
FROM record_challenge_check_in_v2_count;

-- Detalhes das tabelas
SELECT table_name,
       exists,
       CASE WHEN exists THEN 'OK' ELSE 'FALTANDO' END as status
FROM table_validation
ORDER BY table_name;

-- Detalhes das funções
SELECT function_name,
       exists,
       CASE WHEN exists THEN 'OK' ELSE 'FALTANDO' END as status
FROM function_validation
ORDER BY function_name;

-- Detalhes do problema de ambiguidade
SELECT 'record_challenge_check_in_v2' as function_name,
       count,
       CASE 
           WHEN count = 0 THEN 'FALTANDO'
           WHEN count = 1 THEN 'OK'
           ELSE 'MÚLTIPLAS VERSÕES (AMBIGUIDADE)'
       END as status
FROM record_challenge_check_in_v2_count;

-- Detalhe das diferentes assinaturas da função
SELECT * FROM record_challenge_check_in_v2_details; 