-- Verificação simplificada das tabelas
SELECT 
    tablename,
    'EXISTE' as status
FROM 
    pg_tables
WHERE 
    schemaname = 'public' 
    AND tablename IN ('workout_processing_queue', 'check_in_error_logs');

-- Verificação das funções
SELECT 
    proname as function_name,
    'EXISTE' as status
FROM 
    pg_proc 
WHERE 
    proname IN ('record_workout_basic', 'process_workout_for_ranking', 
                'process_workout_for_dashboard', 'retry_workout_processing')
    AND prokind = 'f';

-- Verificação do problema de ambiguidade
SELECT 
    'record_challenge_check_in_v2' as function_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'FALTANDO'
        WHEN COUNT(*) = 1 THEN 'OK'
        ELSE 'MÚLTIPLAS VERSÕES (AMBIGUIDADE)'
    END as status
FROM 
    pg_proc 
WHERE 
    proname = 'record_challenge_check_in_v2' 
    AND prokind = 'f';

-- Detalhe das diferentes assinaturas da função
SELECT 
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public' AND
    p.proname = 'record_challenge_check_in_v2'; 