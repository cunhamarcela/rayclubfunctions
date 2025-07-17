-- Script de teste para verificar a função get_dashboard_fitness
-- Testando com o usuário Marcela: 01d4a292-1873-4af6-948b-a55eed56d6b9

-- Primeiro, vamos verificar se a função existe
SELECT 
    p.proname as function_name,
    p.pronargs as arg_count,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname = 'get_dashboard_fitness';

-- Testar a função com parâmetros válidos
SELECT get_dashboard_fitness(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
    7,
    2025
);

-- Verificar se há dados para esse usuário
SELECT 
    COUNT(*) as total_workouts,
    MIN(date) as first_workout,
    MAX(date) as last_workout
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- Verificar dados do user_progress
SELECT 
    workouts,
    points,
    current_streak,
    total_duration,
    level,
    achievements
FROM user_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'; 