-- =====================================================================================
-- ANÁLISE PRECISA: CHECK-INS PRÉ-DESAFIO INVÁLIDOS
-- Descrição: Identifica com precisão os check-ins que violam as regras do desafio
-- Foco: APENAS check-ins, não treinos (treinos podem ser retroativos legitimamente)
-- =====================================================================================

-- Constantes do desafio
WITH desafio_info AS (
    SELECT 
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID as challenge_id,
        '2025-05-26 00:00:00-03'::TIMESTAMP WITH TIME ZONE as inicio_oficial,
        '2025-07-06 23:59:59-03'::TIMESTAMP WITH TIME ZONE as fim_oficial
),

-- 1. ANÁLISE DOS CHECK-INS INVÁLIDOS (antes do início)
checkins_invalidos AS (
    SELECT 
        cci.id as checkin_id,
        cci.user_id,
        cci.check_in_date,
        cci.points,
        cci.workout_id,
        cci.created_at as checkin_criado_em,
        di.inicio_oficial,
        EXTRACT(EPOCH FROM (di.inicio_oficial - cci.check_in_date))/3600 as horas_antes_inicio,
        CASE 
            WHEN cci.workout_id IS NULL THEN 'Manual'
            ELSE 'Com Treino'
        END as tipo_checkin
    FROM challenge_check_ins cci
    CROSS JOIN desafio_info di
    WHERE cci.challenge_id = di.challenge_id
    AND cci.check_in_date < di.inicio_oficial
),

-- 2. INFORMAÇÕES DOS TREINOS ASSOCIADOS (se houver)
treinos_associados AS (
    SELECT 
        ci.checkin_id,
        ci.user_id,
        ci.check_in_date,
        ci.points,
        ci.tipo_checkin,
        ci.horas_antes_inicio,
        wr.id as workout_id,
        wr.name as workout_name,
        wr.workout_type,
        wr.duration_minutes,
        wr.workout_date,
        wr.created_at as treino_criado_em,
        CASE 
            WHEN wr.id IS NULL THEN '❌ Check-in Manual'
            WHEN wr.workout_date < '2025-05-26 00:00:00-03' THEN '⚠️ Treino Pré-Desafio'
            WHEN wr.workout_date >= '2025-05-26 00:00:00-03' THEN '✅ Treino Válido'
            ELSE '❓ Situação Indefinida'
        END as status_treino
    FROM checkins_invalidos ci
    LEFT JOIN workout_records wr ON ci.workout_id = wr.id
)

-- RELATÓRIO PRINCIPAL
SELECT 
    '🚨 CHECK-INS INVÁLIDOS IDENTIFICADOS' as secao,
    COUNT(*) as total_checkins_invalidos,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    SUM(points) as pontos_indevidos,
    MIN(check_in_date) as primeiro_checkin_invalido,
    MAX(check_in_date) as ultimo_checkin_invalido,
    ROUND(AVG(horas_antes_inicio), 2) as media_horas_antes_inicio
FROM treinos_associados

UNION ALL

-- DETALHAMENTO POR TIPO
SELECT 
    '📊 DETALHAMENTO POR TIPO' as secao,
    NULL as total_checkins_invalidos,
    NULL as usuarios_afetados,
    NULL as pontos_indevidos,
    NULL as primeiro_checkin_invalido,
    NULL as ultimo_checkin_invalido,
    NULL as media_horas_antes_inicio

UNION ALL

SELECT 
    '   - ' || tipo_checkin as secao,
    COUNT(*)::INTEGER,
    COUNT(DISTINCT user_id)::INTEGER,
    SUM(points)::INTEGER,
    MIN(check_in_date),
    MAX(check_in_date),
    ROUND(AVG(horas_antes_inicio), 2)
FROM treinos_associados
GROUP BY tipo_checkin

UNION ALL

-- DETALHAMENTO POR STATUS DO TREINO
SELECT 
    '📋 DETALHAMENTO POR STATUS DO TREINO' as secao,
    NULL, NULL, NULL, NULL, NULL, NULL

UNION ALL

SELECT 
    '   - ' || status_treino as secao,
    COUNT(*)::INTEGER,
    COUNT(DISTINCT user_id)::INTEGER,
    SUM(points)::INTEGER,
    MIN(check_in_date),
    MAX(check_in_date),
    ROUND(AVG(horas_antes_inicio), 2)
FROM treinos_associados
GROUP BY status_treino;

-- =====================================================================================
-- LISTA DETALHADA DOS CHECK-INS INVÁLIDOS
-- =====================================================================================

SELECT 
    '🔍 LISTA DETALHADA DOS CHECK-INS INVÁLIDOS' as status,
    ta.user_id,
    ta.check_in_date,
    ta.points,
    ta.horas_antes_inicio,
    ta.tipo_checkin,
    ta.status_treino,
    ta.workout_id,
    ta.workout_name,
    ta.workout_type,
    ta.duration_minutes,
    ta.workout_date,
    ta.treino_criado_em
FROM (
    SELECT 
        ci.user_id,
        ci.check_in_date,
        ci.points,
        ci.horas_antes_inicio,
        ci.tipo_checkin,
        CASE 
            WHEN wr.id IS NULL THEN '❌ Check-in Manual'
            WHEN wr.workout_date < '2025-05-26 00:00:00-03' THEN '⚠️ Treino Pré-Desafio'
            WHEN wr.workout_date >= '2025-05-26 00:00:00-03' THEN '✅ Treino Válido'
            ELSE '❓ Situação Indefinida'
        END as status_treino,
        wr.id as workout_id,
        wr.name as workout_name,
        wr.workout_type,
        wr.duration_minutes,
        wr.workout_date,
        wr.created_at as treino_criado_em
    FROM checkins_invalidos ci
    LEFT JOIN workout_records wr ON ci.workout_id = wr.id
) ta
ORDER BY ta.check_in_date, ta.user_id;

-- =====================================================================================
-- VERIFICAÇÃO DE FUSO HORÁRIO
-- =====================================================================================

SELECT 
    '🌍 VERIFICAÇÃO DE FUSO HORÁRIO' as status,
    '2025-05-26 00:00:00-03'::TIMESTAMP WITH TIME ZONE as inicio_oficial_desafio,
    NOW() as timestamp_atual,
    EXTRACT(TIMEZONE FROM NOW())/3600 as fuso_atual_horas,
    '25/05 às 21:00 = 3 horas antes do início' as exemplo_calculo,
    '24/05 às 21:00 = 27 horas antes do início' as exemplo_calculo_2;

-- =====================================================================================
-- IMPACTO NO RANKING (usuários que podem ter posições incorretas)
-- =====================================================================================

WITH usuarios_com_checkins_invalidos AS (
    SELECT DISTINCT cci.user_id
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    AND cci.check_in_date < '2025-05-26 00:00:00-03'
)

SELECT 
    '🏆 IMPACTO NO RANKING' as status,
    cp.user_id,
    cp.total_check_ins,
    cp.total_points,
    cp.current_rank,
    'Posição pode estar incorreta' as observacao
FROM challenge_progress cp
JOIN usuarios_com_checkins_invalidos uci ON cp.user_id = uci.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.current_rank
LIMIT 20; 