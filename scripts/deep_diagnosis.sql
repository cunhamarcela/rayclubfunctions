-- Script para diagnóstico profundo do problema

-- 1. Verificar os treinos recentes e seus IDs
SELECT 
    id,
    workout_id,
    challenge_id,
    user_id,
    created_at,
    date,
    duration_minutes
FROM 
    workout_records
WHERE 
    created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    created_at DESC;

-- 2. Verificar se os treinos estão na fila e seu status
SELECT 
    q.workout_id,
    q.challenge_id,
    q.processed_for_ranking,
    q.processed_for_dashboard,
    q.processing_error,
    q.created_at,
    q.processed_at
FROM 
    workout_processing_queue q
WHERE 
    q.created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    q.created_at DESC;

-- 3. Verificar se algum check-in foi criado
SELECT 
    c.id,
    c.challenge_id,
    c.user_id,
    c.check_in_date,
    c.workout_id,
    c.points_earned,
    c.created_at
FROM 
    challenge_check_ins c
WHERE 
    c.created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    c.created_at DESC;

-- 4. Verificar se houve atualizações no challenge_progress
SELECT 
    cp.challenge_id,
    cp.user_id,
    cp.points_earned,
    cp.check_ins_count,
    cp.last_check_in,
    cp.updated_at
FROM 
    challenge_progress cp
WHERE 
    cp.updated_at > NOW() - INTERVAL '1 day'
ORDER BY 
    cp.updated_at DESC;

-- 5. Verificar a definição da função de processamento de dashboard
SELECT
    prosrc
FROM
    pg_proc
WHERE
    proname = 'process_workout_for_dashboard'
LIMIT 1;

-- 6. Verificar registros de erro
SELECT 
    workout_id,
    user_id,
    challenge_id,
    error_message,
    status,
    created_at
FROM 
    check_in_error_logs
WHERE 
    created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    created_at DESC;

-- 7. Verificar a query que o app usa para ranking
-- Aqui está uma aproximação da query que o app pode estar usando
SELECT 
    cp.challenge_id,
    c.name as challenge_name,
    cp.user_id,
    cp.user_name,
    cp.points_earned,
    cp.check_ins_count,
    cp.last_check_in,
    cp.completion_percentage
FROM 
    challenge_progress cp
JOIN 
    challenges c ON cp.challenge_id = c.id
WHERE 
    c.status = 'active'
    -- Filtro adicional para desafio específico se necessário
    -- AND cp.challenge_id = 'CHALLENGE_ID_AQUI'
ORDER BY 
    cp.points_earned DESC, cp.last_check_in DESC
LIMIT 20; 