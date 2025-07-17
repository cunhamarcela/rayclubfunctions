-- INVESTIGAR E CORRIGIR PROBLEMA DE FUSO HORÁRIO
-- Pessoas com 40 pontos deveriam ter apenas 3 check-ins (26, 27, 28)

-- ========================================
-- PASSO 1: INVESTIGAR AS USUÁRIAS COM 40 PONTOS
-- ========================================

-- Ver todas as datas de check-in das líderes
SELECT 
    'INVESTIGAÇÃO LÍDERES' as tipo,
    p.name as usuario,
    cci.check_in_date as data_hora_completa,
    DATE(cci.check_in_date) as data_apenas,
    DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') as data_brasil,
    cci.created_at,
    cci.workout_name
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND p.name IN ('Flávia Martins Vasconcelos Filiu', 'Gabriela Bacelar')
ORDER BY p.name, cci.check_in_date;

-- ========================================
-- PASSO 2: VER TODAS AS DATAS ÚNICAS NO SISTEMA
-- ========================================

-- Ver quantas datas diferentes existem no sistema
SELECT 
    'DATAS NO SISTEMA' as tipo,
    DATE(cci.check_in_date) as data_utc,
    DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') as data_brasil,
    COUNT(DISTINCT cci.user_id) as usuarios_nesta_data,
    COUNT(*) as total_checkins
FROM challenge_check_ins cci
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY DATE(cci.check_in_date), DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')
ORDER BY data_utc;

-- ========================================
-- PASSO 3: RECALCULAR USANDO FUSO HORÁRIO BRASILEIRO
-- ========================================

-- Recalcular progresso usando data brasileira
WITH correct_progress_brazil AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) * 10 as total_points,
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
    check_ins_count = correct_progress_brazil.correct_check_ins_count,
    total_check_ins = correct_progress_brazil.correct_check_ins_count,
    points = correct_progress_brazil.total_points,
    last_check_in = correct_progress_brazil.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress_brazil.correct_check_ins_count * 100.0) / 20),
    updated_at = NOW(),
    user_name = correct_progress_brazil.user_name,
    user_photo_url = correct_progress_brazil.user_photo_url
FROM correct_progress_brazil
WHERE cp.user_id = correct_progress_brazil.user_id 
AND cp.challenge_id = correct_progress_brazil.challenge_id;

-- ========================================
-- PASSO 4: RECALCULAR RANKING COM DADOS CORRETOS
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
AND cp.user_id = ru.user_id;

-- ========================================
-- PASSO 5: VERIFICAR RESULTADO CORRIGIDO
-- ========================================

-- Ver o ranking corrigido
SELECT 
    'RANKING CORRIGIDO' as status,
    cp.position,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    (SELECT COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) 
     FROM challenge_check_ins cci 
     WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id) as verificacao_dias_brasil
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.position
LIMIT 20;

-- ========================================
-- PASSO 6: VERIFICAR ESPECIFICAMENTE AS EX-LÍDERES
-- ========================================

-- Ver detalhes das usuárias que tinham 40 pontos
SELECT 
    'VERIFICAÇÃO EX-LÍDERES' as tipo,
    p.name as usuario,
    cp.points as pontos_atuais,
    cp.check_ins_count as checkins_atuais,
    STRING_AGG(
        DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::text, 
        ', ' ORDER BY DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')
    ) as datas_brasil
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
LEFT JOIN challenge_check_ins cci ON cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND p.name IN ('Flávia Martins Vasconcelos Filiu', 'Gabriela Bacelar')
GROUP BY p.name, cp.points, cp.check_ins_count
ORDER BY p.name; 