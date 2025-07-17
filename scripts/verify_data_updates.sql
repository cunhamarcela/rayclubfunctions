-- Script para verificar se as atualizações foram efetivamente realizadas

-- 1. Verificar os registros na fila de processamento
SELECT 
    processed_for_ranking, 
    processed_for_dashboard, 
    COUNT(*) 
FROM 
    workout_processing_queue 
GROUP BY 
    processed_for_ranking, processed_for_dashboard;

-- 2. Verificar check-ins de desafios para os últimos treinos processados
SELECT 
    q.workout_id,
    q.challenge_id,
    q.processed_for_ranking,
    q.processed_for_dashboard,
    -- Verificar se check-in foi criado
    EXISTS (
        SELECT 1 
        FROM challenge_check_ins c 
        WHERE c.workout_id = q.workout_id
    ) as has_challenge_check_in
FROM 
    workout_processing_queue q
WHERE 
    q.processed_for_ranking = true
    AND q.processed_at > NOW() - INTERVAL '1 day'
ORDER BY 
    q.processed_at DESC;

-- 3. Verificar atualizações no user_progress
SELECT 
    w.user_id,
    w.id as workout_id,
    up.challenge_points,
    up.updated_at,
    -- Verificar se a última atualização foi após o processamento
    up.updated_at > q.processed_at as updated_after_processing
FROM 
    workout_records w
JOIN 
    workout_processing_queue q ON w.id = q.workout_id
JOIN 
    user_progress up ON w.user_id = up.user_id
WHERE 
    q.processed_for_dashboard = true
    AND q.processed_at > NOW() - INTERVAL '1 day'
ORDER BY 
    q.processed_at DESC;

-- 4. Verificar atualizações no challenge_progress
SELECT 
    w.user_id,
    w.challenge_id,
    w.id as workout_id,
    cp.points_earned,
    cp.check_ins_count,
    cp.updated_at,
    -- Verificar se a última atualização foi após o processamento
    cp.updated_at > q.processed_at as updated_after_processing
FROM 
    workout_records w
JOIN 
    workout_processing_queue q ON w.id = q.workout_id
JOIN 
    challenge_progress cp ON w.user_id = cp.user_id AND w.challenge_id = cp.challenge_id
WHERE 
    q.processed_for_ranking = true
    AND w.challenge_id IS NOT NULL
    AND q.processed_at > NOW() - INTERVAL '1 day'
ORDER BY 
    q.processed_at DESC; 