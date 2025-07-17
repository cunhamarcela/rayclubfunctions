-- Script de Diagnóstico para Problemas de Ranking e Dashboard
-- Este script analisa e verifica as estruturas, funções e triggers relacionadas
-- à atualização de ranking e dashboard após registro de treinos

-- 1. Verificar a estrutura da tabela workout_records
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns 
WHERE 
    table_name = 'workout_records'
ORDER BY 
    ordinal_position;

-- 2. Verificar a estrutura da tabela challenge_check_ins
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns 
WHERE 
    table_name = 'challenge_check_ins'
ORDER BY 
    ordinal_position;

-- 3. Verificar a estrutura da tabela challenge_progress
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns 
WHERE 
    table_name = 'challenge_progress'
ORDER BY 
    ordinal_position;

-- 4. Verificar a estrutura da tabela user_progress
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns 
WHERE 
    table_name = 'user_progress'
ORDER BY 
    ordinal_position;

-- 5. Verificar a função record_challenge_check_in_v2
SELECT 
    pg_get_functiondef(oid) as function_definition
FROM 
    pg_proc 
WHERE 
    proname = 'record_challenge_check_in_v2';

-- 6. Verificar a função process_workout_for_dashboard
SELECT 
    pg_get_functiondef(oid) as function_definition
FROM 
    pg_proc 
WHERE 
    proname = 'process_workout_for_dashboard';

-- 7. Verificar a função process_workout_for_ranking
SELECT 
    pg_get_functiondef(oid) as function_definition
FROM 
    pg_proc 
WHERE 
    proname = 'process_workout_for_ranking';

-- 8. Verificar a função get_dashboard_data
SELECT 
    pg_get_functiondef(oid) as function_definition
FROM 
    pg_proc 
WHERE 
    proname = 'get_dashboard_data';

-- 9. Verificar triggers na tabela workout_records
SELECT 
    trigger_name,
    event_manipulation,
    action_statement
FROM 
    information_schema.triggers
WHERE 
    event_object_table = 'workout_records';

-- 10. Verificar triggers na tabela challenge_check_ins
SELECT 
    trigger_name,
    event_manipulation,
    action_statement
FROM 
    information_schema.triggers
WHERE 
    event_object_table = 'challenge_check_ins';

-- 11. Verificar triggers na tabela challenge_progress
SELECT 
    trigger_name,
    event_manipulation,
    action_statement
FROM 
    information_schema.triggers
WHERE 
    event_object_table = 'challenge_progress';

-- 12. Verificar eventos recentes de registros de treinos
SELECT 
    id, 
    user_id, 
    workout_name, 
    workout_type, 
    date, 
    duration_minutes, 
    created_at
FROM 
    workout_records
ORDER BY 
    created_at DESC
LIMIT 10;

-- 13. Verificar check-ins de desafios recentes
SELECT 
    id, 
    user_id, 
    challenge_id, 
    check_in_date, 
    points, 
    workout_id, 
    created_at
FROM 
    challenge_check_ins
ORDER BY 
    created_at DESC
LIMIT 10;

-- 14. Verificar atualizações recentes de progresso de desafios
SELECT 
    id, 
    user_id, 
    challenge_id, 
    points, 
    check_ins_count, 
    updated_at
FROM 
    challenge_progress
ORDER BY 
    updated_at DESC
LIMIT 10;

-- 15. Verificar atualizações recentes de dashboard
SELECT 
    id, 
    user_id, 
    current_streak, 
    longest_streak, 
    total_workouts, 
    updated_at
FROM 
    user_progress
ORDER BY 
    updated_at DESC
LIMIT 10;

-- 16. Verificar logs de erros de check-in
SELECT 
    id,
    user_id,
    challenge_id,
    workout_id,
    error_message,
    created_at
FROM 
    check_in_error_logs
ORDER BY 
    created_at DESC
LIMIT 10;

-- 17. Verificar se existem inconsistências entre workout_records e challenge_check_ins
WITH recent_workouts AS (
    SELECT 
        id, 
        user_id, 
        date
    FROM 
        workout_records
    ORDER BY 
        created_at DESC
    LIMIT 20
)
SELECT 
    w.id as workout_id, 
    w.user_id, 
    w.date as workout_date,
    COUNT(c.id) as check_in_count
FROM 
    recent_workouts w
LEFT JOIN 
    challenge_check_ins c ON c.workout_id = w.id
GROUP BY 
    w.id, w.user_id, w.date
ORDER BY 
    check_in_count ASC;

-- 18. Verificar funções e procedures usando NOTIFY que podem afetar o processamento assíncrono
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as function_arguments
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON p.pronamespace = n.oid
WHERE 
    pg_get_functiondef(p.oid) LIKE '%NOTIFY%'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 
    n.nspname, p.proname;

-- 19. Testar a função record_challenge_check_in_v2 com um caso real
-- (NOTA: Este comando deve ser usado com cuidado, substitua os IDs por valores reais do ambiente)
/*
SELECT 
    record_challenge_check_in_v2(
        '00000000-0000-0000-0000-000000000000'::uuid, -- challenge_id
        NOW()::timestamptz, -- date
        60, -- duration_minutes
        '00000000-0000-0000-0000-000000000000'::uuid, -- user_id
        '00000000-0000-0000-0000-000000000000'::uuid, -- workout_id
        'Teste de Diagnóstico', -- workout_name
        'strength' -- workout_type
    );
*/

-- 20. Verificar dependências entre funções (quais funções chamam outras)
WITH RECURSIVE function_calls AS (
    SELECT 
        p.oid,
        p.proname as calling_function,
        p.proname as original_function,
        NULL::text as called_function,
        0 as level
    FROM 
        pg_proc p
    JOIN 
        pg_namespace n ON p.pronamespace = n.oid
    WHERE 
        n.nspname NOT IN ('pg_catalog', 'information_schema')
        AND (p.proname = 'record_challenge_check_in_v2' 
             OR p.proname = 'process_workout_for_dashboard' 
             OR p.proname = 'process_workout_for_ranking')
    
    UNION ALL
    
    SELECT 
        p.oid,
        c.calling_function,
        c.original_function,
        p2.proname as called_function,
        c.level + 1
    FROM 
        function_calls c
    JOIN 
        pg_proc p ON c.oid = p.oid
    JOIN 
        pg_proc p2 ON pg_get_functiondef(p.oid) LIKE '%' || p2.proname || '%'
    JOIN 
        pg_namespace n ON p2.pronamespace = n.oid
    WHERE 
        n.nspname NOT IN ('pg_catalog', 'information_schema')
        AND p2.proname <> c.calling_function
        AND c.level < 5
)
SELECT DISTINCT
    original_function,
    called_function,
    level
FROM 
    function_calls
WHERE 
    called_function IS NOT NULL
ORDER BY 
    original_function, level, called_function; 