-- SCRIPT SIMPLES PARA EXECUTAR NO SUPABASE DASHBOARD
-- Copie e cole este código no SQL Editor do Supabase

-- 1. VERIFICAR O PROBLEMA ATUAL
SELECT 
    'PROBLEMA ATUAL' as status,
    c.title as desafio,
    DATE_PART('day', c.end_date - c.start_date)::int + 1 as dias_desafio,
    COUNT(cci.id) as total_checkins_registrados
FROM challenges c
LEFT JOIN challenge_check_ins cci ON cci.challenge_id = c.id
WHERE c.id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY c.id, c.title, c.start_date, c.end_date;

-- 2. DELETAR TODAS AS DUPLICATAS (MANTER APENAS 1 POR DIA POR USUÁRIO)
WITH checkins_to_keep AS (
    SELECT 
        cci.id,
        ROW_NUMBER() OVER (
            PARTITION BY cci.user_id, cci.challenge_id, DATE(cci.check_in_date) 
            ORDER BY cci.created_at ASC
        ) as rn
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
DELETE FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND id NOT IN (
    SELECT id FROM checkins_to_keep WHERE rn = 1
);

-- 3. RECALCULAR PROGRESSO
WITH correct_progress AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date)) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date)) * 10 as total_points,
        MAX(cci.check_in_date) as last_check_in_date
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    GROUP BY cci.user_id, cci.challenge_id
)
UPDATE challenge_progress cp
SET 
    check_ins_count = correct_progress.correct_check_ins_count,
    total_check_ins = correct_progress.correct_check_ins_count,
    points = correct_progress.total_points,
    last_check_in = correct_progress.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress.correct_check_ins_count * 100.0) / 3),
    updated_at = NOW()
FROM correct_progress
WHERE cp.user_id = correct_progress.user_id 
AND cp.challenge_id = correct_progress.challenge_id;

-- 4. RECALCULAR RANKING
WITH ranked_users AS (
    SELECT
        cp.user_id,
        cp.challenge_id,
        DENSE_RANK() OVER (
            ORDER BY cp.points DESC, cp.last_check_in ASC NULLS LAST
        ) AS new_position
    FROM challenge_progress cp
    WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id 
AND cp.user_id = ru.user_id;

-- 5. VERIFICAR RESULTADO
SELECT 
    'RESULTADO FINAL' as status,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    cp.position,
    (SELECT COUNT(DISTINCT DATE(cci.check_in_date)) 
     FROM challenge_check_ins cci 
     WHERE cci.user_id = p.id AND cci.challenge_id = cp.challenge_id) as verificacao_checkins
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.position; 