-- Script para verificar a implementação do sistema split
-- Verifica se todas as funções necessárias existem e identifica problemas

-- 1. Verificar todas as funções necessárias
SELECT 
    function_name,
    EXISTS (
        SELECT 1 FROM pg_proc 
        WHERE proname = function_name 
        AND prokind = 'f'
    ) as exists
FROM (
    VALUES 
        ('record_workout_basic'),
        ('process_workout_for_ranking'),
        ('process_workout_for_dashboard'),
        ('retry_workout_processing'),
        ('diagnose_and_recover_workout_records'),
        ('record_challenge_check_in_v2')
) as required_functions(function_name);

-- 2. Verificar a assinatura da função record_challenge_check_in_v2
SELECT 
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type,
    COUNT(*) OVER() as total_versions
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public' AND
    p.proname = 'record_challenge_check_in_v2';

-- 3. Verificar a existência de tabelas de suporte
SELECT 
    table_name,
    EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = table_name
    ) as exists
FROM (
    VALUES 
        ('workout_processing_queue'),
        ('check_in_error_logs')
) as required_tables(table_name);

-- 4. Verificar quantidade de versões da função record_challenge_check_in_v2
-- Isso é crucial pois múltiplas versões causam ambiguidade
SELECT
    'record_challenge_check_in_v2' as function_name,
    COUNT(*) as versions,
    CASE 
        WHEN COUNT(*) = 0 THEN 'FALTANDO'
        WHEN COUNT(*) = 1 THEN 'OK'
        ELSE 'AMBIGUIDADE: ' || COUNT(*) || ' versões encontradas'
    END as status
FROM 
    pg_proc 
WHERE 
    proname = 'record_challenge_check_in_v2' 
    AND prokind = 'f';

-- 5. Verificar fila de processamento
SELECT 
    COUNT(*) as total_records,
    SUM(CASE WHEN processed_for_ranking AND processed_for_dashboard THEN 1 ELSE 0 END) as fully_processed,
    SUM(CASE WHEN NOT processed_for_ranking OR NOT processed_for_dashboard THEN 1 ELSE 0 END) as pending_processing
FROM 
    workout_processing_queue
WHERE 
    created_at > NOW() - INTERVAL '24 hours';

-- 6. Verificar erros recentes
SELECT 
    status,
    COUNT(*) as count
FROM 
    check_in_error_logs
WHERE 
    created_at > NOW() - INTERVAL '24 hours'
GROUP BY 
    status; 