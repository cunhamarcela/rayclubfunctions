-- Script simplificado para corrigir duplicação de check-ins
-- Execute este primeiro para testar

-- 1. LIMPAR DUPLICATAS EXISTENTES
WITH duplicates AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, challenge_id, DATE(check_in_date) 
            ORDER BY created_at DESC
        ) as rn
    FROM challenge_check_ins
)
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id FROM duplicates WHERE rn > 1
);

-- 2. RECALCULAR CHALLENGE_PROGRESS
WITH correct_counts AS (
    SELECT 
        cci.challenge_id,
        cci.user_id,
        COUNT(*) as real_check_ins,
        COUNT(*) * 10 as real_points,
        MAX(cci.check_in_date) as last_check_in,
        COALESCE(p.name, 'Usuário') as user_name,
        p.photo_url as user_photo_url
    FROM challenge_check_ins cci
    LEFT JOIN profiles p ON p.id = cci.user_id
    GROUP BY cci.challenge_id, cci.user_id, p.name, p.photo_url
)
UPDATE challenge_progress cp
SET 
    points = cc.real_points,
    check_ins_count = cc.real_check_ins,
    total_check_ins = cc.real_check_ins,
    last_check_in = cc.last_check_in,
    user_name = cc.user_name,
    user_photo_url = cc.user_photo_url,
    updated_at = NOW()
FROM correct_counts cc
WHERE cp.challenge_id = cc.challenge_id 
  AND cp.user_id = cc.user_id;

-- 3. ADICIONAR CONSTRAINT SIMPLES (apenas para workout_id)
ALTER TABLE challenge_check_ins 
ADD CONSTRAINT IF NOT EXISTS unique_user_challenge_workout_checkin 
UNIQUE (user_id, challenge_id, workout_id);

-- 4. VERIFICAR RESULTADO
SELECT 
    'Duplicatas restantes' as status,
    COUNT(*) as quantidade
FROM (
    SELECT user_id, challenge_id, DATE(check_in_date)
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date)
    HAVING COUNT(*) > 1
) duplicates; 