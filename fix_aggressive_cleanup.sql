-- SCRIPT AGRESSIVO PARA LIMPEZA COMPLETA DE DUPLICATAS
-- Remove TODAS as duplicatas e reconstrói o sistema de check-ins corretamente

-- ========================================
-- PASSO 1: INVESTIGAR O PROBLEMA
-- ========================================
SELECT 
    'INVESTIGAÇÃO INICIAL' as tipo,
    c.title as desafio_nome,
    c.start_date,
    c.end_date,
    DATE_PART('day', c.end_date - c.start_date)::int + 1 as dias_totais_desafio,
    COUNT(cci.id) as total_checkins_registrados,
    COUNT(DISTINCT cci.user_id) as usuarios_participando,
    COUNT(DISTINCT DATE(cci.check_in_date)) as dias_unicos_com_checkin
FROM challenges c
LEFT JOIN challenge_check_ins cci ON cci.challenge_id = c.id
WHERE c.id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY c.id, c.title, c.start_date, c.end_date;

-- ========================================
-- PASSO 2: VERIFICAR DETALHES DAS DUPLICATAS
-- ========================================
SELECT 
    'DETALHES DUPLICATAS' as tipo,
    p.name as usuario,
    DATE(cci.check_in_date) as data_checkin,
    COUNT(*) as quantidade_checkins,
    STRING_AGG(cci.id::text, ', ') as ids_checkins
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY p.name, DATE(cci.check_in_date)
ORDER BY p.name, DATE(cci.check_in_date);

-- ========================================
-- PASSO 3: LIMPEZA AGRESSIVA - MANTER APENAS 1 CHECK-IN POR USUÁRIO POR DIA
-- ========================================

-- Primeiro, identificar quais check-ins manter (o mais antigo de cada dia)
WITH checkins_to_keep AS (
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
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
-- Deletar todos os check-ins duplicados (manter apenas rn = 1)
DELETE FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND id NOT IN (
    SELECT id FROM checkins_to_keep WHERE rn = 1
);

-- ========================================
-- PASSO 4: VERIFICAR SE A LIMPEZA FUNCIONOU
-- ========================================
SELECT 
    'APÓS LIMPEZA' as tipo,
    p.name as usuario,
    DATE(cci.check_in_date) as data_checkin,
    COUNT(*) as quantidade_checkins
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY p.name, DATE(cci.check_in_date)
HAVING COUNT(*) > 1
ORDER BY p.name, DATE(cci.check_in_date);

-- ========================================
-- PASSO 5: RECALCULAR PROGRESSO APENAS PARA ESTE DESAFIO
-- ========================================
WITH correct_progress AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date)) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date)) * 10 as total_points,
        MAX(cci.check_in_date) as last_check_in_date,
        COALESCE(p.name, 'Usuário') as user_name,
        p.photo_url as user_photo_url
    FROM challenge_check_ins cci
    LEFT JOIN profiles p ON p.id = cci.user_id
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    GROUP BY cci.user_id, cci.challenge_id, p.name, p.photo_url
)
UPDATE challenge_progress cp
SET 
    check_ins_count = correct_progress.correct_check_ins_count,
    total_check_ins = correct_progress.correct_check_ins_count,
    points = correct_progress.total_points,
    last_check_in = correct_progress.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress.correct_check_ins_count * 100.0) / 3), -- 3 dias no desafio
    updated_at = NOW(),
    user_name = correct_progress.user_name,
    user_photo_url = correct_progress.user_photo_url
FROM correct_progress
WHERE cp.user_id = correct_progress.user_id 
AND cp.challenge_id = correct_progress.challenge_id
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- ========================================
-- PASSO 6: RECALCULAR RANKING PARA ESTE DESAFIO
-- ========================================
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
                cp.points DESC,
                COALESCE(utw.total_workouts_ever, 0) DESC,
                cp.last_check_in ASC NULLS LAST
        ) AS new_position
    FROM challenge_progress cp
    LEFT JOIN user_total_workouts utw ON utw.user_id = cp.user_id
    WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id 
AND cp.user_id = ru.user_id
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- ========================================
-- PASSO 7: RESULTADO FINAL
-- ========================================
SELECT 
    'RESULTADO FINAL CORRIGIDO' as status,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    cp.total_check_ins,
    cp.position,
    (SELECT COUNT(*) FROM workout_records wr WHERE wr.user_id = p.id AND wr.challenge_id = cp.challenge_id) as total_treinos_desafio,
    (SELECT COUNT(DISTINCT DATE(cci.check_in_date)) FROM challenge_check_ins cci WHERE cci.user_id = p.id AND cci.challenge_id = cp.challenge_id) as check_ins_unicos_verificacao
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.position;

-- ========================================
-- PASSO 8: VERIFICAÇÃO FINAL DE DUPLICATAS
-- ========================================
SELECT 
    'VERIFICAÇÃO FINAL' as tipo,
    COALESCE(p.name, 'Usuário') as usuario,
    DATE(cci.check_in_date) as data_checkin,
    COUNT(*) as quantidade_checkins
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY p.name, DATE(cci.check_in_date)
ORDER BY p.name, DATE(cci.check_in_date); 