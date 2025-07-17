-- Script para verificar se as atualizações foram efetivamente realizadas (corrigido)

-- 1. Verificar os registros na fila de processamento
SELECT 
    processed_for_ranking, 
    processed_for_dashboard, 
    COUNT(*) 
FROM 
    workout_processing_queue 
GROUP BY 
    processed_for_ranking, processed_for_dashboard;

-- 2. Verificar check-ins de desafios para os últimos treinos processados (com conversão de tipo)
SELECT 
    q.workout_id,
    q.challenge_id,
    q.processed_for_ranking,
    q.processed_for_dashboard,
    -- Verificar se check-in foi criado (com conversão de tipo)
    EXISTS (
        SELECT 1 
        FROM challenge_check_ins c 
        WHERE c.workout_id = q.workout_id::TEXT  -- Converter UUID para TEXT
    ) as has_challenge_check_in
FROM 
    workout_processing_queue q
WHERE 
    q.processed_for_ranking = true
    AND q.processed_at > NOW() - INTERVAL '1 day'
ORDER BY 
    q.processed_at DESC;

-- 3. Verificar os workout_records que têm challenge_id
SELECT 
    id,
    workout_id,
    user_id,
    challenge_id,
    workout_name,
    created_at
FROM 
    workout_records
WHERE 
    created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    created_at DESC;

-- 4. Verificar atualizações no user_progress (com verificação de NULL)
SELECT 
    w.user_id,
    w.id as workout_id,
    up.challenge_points,
    up.updated_at,
    q.processed_at,
    -- Verificar se a última atualização foi após o processamento
    CASE WHEN up.updated_at IS NULL THEN FALSE
         WHEN q.processed_at IS NULL THEN FALSE
         ELSE up.updated_at > q.processed_at 
    END as updated_after_processing
FROM 
    workout_records w
LEFT JOIN 
    workout_processing_queue q ON w.id = q.workout_id
LEFT JOIN 
    user_progress up ON w.user_id = up.user_id
WHERE 
    w.created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    w.created_at DESC;

-- 5. Verificar atualizações no challenge_progress (com verificação de NULL e conversão de tipo)
SELECT 
    w.user_id,
    w.challenge_id,
    w.id as workout_id,
    cp.points_earned,
    cp.check_ins_count,
    cp.updated_at,
    q.processed_at,
    -- Verificar se a última atualização foi após o processamento
    CASE WHEN cp.updated_at IS NULL THEN FALSE
         WHEN q.processed_at IS NULL THEN FALSE
         ELSE cp.updated_at > q.processed_at 
    END as updated_after_processing
FROM 
    workout_records w
LEFT JOIN 
    workout_processing_queue q ON w.id = q.workout_id
LEFT JOIN 
    challenge_progress cp ON w.user_id = cp.user_id AND w.challenge_id = cp.challenge_id
WHERE 
    w.created_at > NOW() - INTERVAL '1 day'
    AND w.challenge_id IS NOT NULL
ORDER BY 
    w.created_at DESC;

-- 6. Verificar se existem check-ins criados para os treinos recentes
SELECT 
    wr.id as workout_record_id,
    wr.workout_id as external_workout_id,
    wr.challenge_id,
    wr.created_at as workout_recorded_at,
    cc.id as checkin_id,
    cc.check_in_date,
    cc.created_at as checkin_created_at
FROM 
    workout_records wr
LEFT JOIN 
    challenge_check_ins cc ON cc.workout_id = wr.workout_id::TEXT
WHERE 
    wr.created_at > NOW() - INTERVAL '1 day'
ORDER BY 
    wr.created_at DESC; 