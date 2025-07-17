-- Script para corrigir inconsistência entre treinos e check-ins
-- Problema: Múltiplos check-ins por dia quando deveria ser apenas 1 por dia

-- 1. PRIMEIRO: Identificar e remover check-ins duplicados por data
WITH duplicated_checkins AS (
    SELECT 
        cci.id,
        cci.user_id,
        cci.challenge_id,
        DATE(cci.check_in_date) as check_date,
        ROW_NUMBER() OVER (
            PARTITION BY cci.user_id, cci.challenge_id, DATE(cci.check_in_date) 
            ORDER BY cci.created_at ASC
        ) as rn
    FROM challenge_check_ins cci
)
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id FROM duplicated_checkins WHERE rn > 1
);

-- 2. RECALCULAR progresso correto para todos os usuários
WITH correct_progress AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date)) as correct_check_ins_count,
        SUM(cci.points) as total_points,
        MAX(cci.check_in_date) as last_check_in_date,
        p.name as user_name,
        p.photo_url as user_photo_url
    FROM challenge_check_ins cci
    JOIN profiles p ON p.id = cci.user_id
    GROUP BY cci.user_id, cci.challenge_id, p.name, p.photo_url
)
UPDATE challenge_progress cp
SET 
    check_ins_count = correct_progress.correct_check_ins_count,
    total_check_ins = correct_progress.correct_check_ins_count,
    points = correct_progress.total_points,
    last_check_in = correct_progress.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress.correct_check_ins_count * 100.0) / 
        GREATEST(1, DATE_PART('day', c.end_date - c.start_date)::int + 1)),
    updated_at = NOW(),
    user_name = correct_progress.user_name,
    user_photo_url = correct_progress.user_photo_url
FROM correct_progress
JOIN challenges c ON c.id = correct_progress.challenge_id
WHERE cp.user_id = correct_progress.user_id 
AND cp.challenge_id = correct_progress.challenge_id;

-- 3. RECALCULAR rankings com critério correto de desempate
WITH user_total_workouts AS (
    SELECT 
        user_id,
        COUNT(*) as total_workouts_ever
    FROM workout_records
    GROUP BY user_id
),
ranked_users AS (
    SELECT
        cp.user_id,
        cp.challenge_id,
        DENSE_RANK() OVER (
            ORDER BY 
                cp.points DESC,                                    -- 1º: Pontos (dias com check-in)
                COALESCE(utw.total_workouts_ever, 0) DESC,         -- 2º: TOTAL de treinos do usuário
                cp.last_check_in ASC NULLS LAST                    -- 3º: Data do último check-in
        ) AS new_position
    FROM challenge_progress cp
    LEFT JOIN user_total_workouts utw ON utw.user_id = cp.user_id
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id AND cp.user_id = ru.user_id;

-- 4. VERIFICAR resultado final
SELECT 
    'RESULTADO FINAL' as status,
    p.name,
    cp.challenge_id,
    cp.points,
    cp.check_ins_count,
    cp.total_check_ins,
    cp.position,
    (SELECT COUNT(*) FROM workout_records wr WHERE wr.user_id = p.id) as total_treinos,
    (SELECT COUNT(DISTINCT DATE(cci.check_in_date)) FROM challenge_check_ins cci WHERE cci.user_id = p.id AND cci.challenge_id = cp.challenge_id) as check_ins_unicos
FROM challenge_progress cp
JOIN profiles p ON p.id = cp.user_id
WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
ORDER BY cp.challenge_id, cp.position; 