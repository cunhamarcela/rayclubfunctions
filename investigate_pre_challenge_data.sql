-- 🔍 INVESTIGAÇÃO: Dados Pré-Desafio (Antes de 26/05/2025)
-- Data: 2025-01-11
-- Objetivo: Identificar usuários e treinos adicionados antes do início oficial

SET timezone = 'America/Sao_Paulo';

-- 🎯 IDENTIFICAR O CHALLENGE (Ray Challenge)
SELECT 
    '🎯 INFORMAÇÕES DO CHALLENGE' as status,
    id as challenge_id,
    name as nome_challenge,
    start_date as data_inicio_oficial,
    end_date as data_fim_oficial,
    created_at as criado_em
FROM challenges 
WHERE id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 👥 USUÁRIOS COM CHECK-INS ANTES DE 26/05/2025
WITH usuarios_pre_challenge AS (
    SELECT DISTINCT 
        cci.user_id,
        MIN(cci.check_in_date) as primeiro_checkin,
        COUNT(*) as total_checkins_pre_challenge,
        SUM(cci.points) as pontos_pre_challenge
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        AND cci.check_in_date < '2025-05-26'
    GROUP BY cci.user_id
)
SELECT 
    '👥 USUÁRIOS COM CHECK-INS PRÉ-DESAFIO' as status,
    upc.user_id,
    upc.primeiro_checkin,
    upc.total_checkins_pre_challenge,
    upc.pontos_pre_challenge,
    EXTRACT(DAYS FROM ('2025-05-26'::date - upc.primeiro_checkin::date)) as dias_antes_inicio
FROM usuarios_pre_challenge upc
ORDER BY upc.primeiro_checkin ASC;

-- 🏋️ TREINOS REGISTRADOS ANTES DE 26/05/2025
SELECT 
    '🏋️ TREINOS PRÉ-DESAFIO' as status,
    wr.id as workout_id,
    wr.user_id,
    wr.workout_name as nome_treino,
    wr.workout_type as tipo_treino,
    wr.duration_minutes as duracao_minutos,
    wr.workout_date as data_treino,
    wr.created_at as criado_em,
    CASE 
        WHEN wr.duration_minutes >= 45 THEN '✅ Válido para check-in'
        ELSE '⚠️ Duração insuficiente'
    END as status_duracao,
    EXTRACT(DAYS FROM ('2025-05-26'::date - wr.workout_date::date)) as dias_antes_inicio
FROM workout_records wr
WHERE wr.workout_date < '2025-05-26'
    AND wr.user_id IN (
        SELECT DISTINCT user_id 
        FROM challenge_check_ins 
        WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    )
ORDER BY wr.workout_date ASC, wr.created_at ASC;

-- 📊 CHECK-INS DETALHADOS PRÉ-DESAFIO
SELECT 
    '📊 CHECK-INS PRÉ-DESAFIO DETALHADOS' as status,
    cci.id as checkin_id,
    cci.user_id,
    cci.check_in_date as data_checkin,
    cci.points as pontos,
    cci.workout_id,
    COALESCE(wr.workout_name, 'Check-in manual') as nome_treino,
    COALESCE(wr.workout_type, 'Manual') as tipo_treino,
    COALESCE(wr.duration_minutes, 0) as duracao_treino,
    cci.created_at as checkin_criado_em,
    CASE 
        WHEN cci.workout_id IS NOT NULL THEN '✅ Com treino'
        ELSE '❌ Manual'
    END as tipo_checkin,
    EXTRACT(DAYS FROM ('2025-05-26'::date - cci.check_in_date::date)) as dias_antes_inicio
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON cci.workout_id = wr.id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    AND cci.check_in_date < '2025-05-26'
ORDER BY cci.check_in_date ASC, cci.created_at ASC;

-- 📈 ESTATÍSTICAS PRÉ-DESAFIO
WITH stats_pre_challenge AS (
    SELECT 
        COUNT(DISTINCT cci.user_id) as usuarios_pre_challenge,
        COUNT(*) as total_checkins_pre,
        SUM(cci.points) as total_pontos_pre,
        MIN(cci.check_in_date) as primeiro_checkin_sistema,
        MAX(cci.check_in_date) as ultimo_checkin_pre_inicio,
        COUNT(DISTINCT cci.check_in_date::date) as dias_unicos_pre
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        AND cci.check_in_date < '2025-05-26'
),
stats_treinos_pre AS (
    SELECT 
        COUNT(*) as total_treinos_pre,
        COUNT(CASE WHEN wr.duration_minutes >= 45 THEN 1 END) as treinos_validos_pre,
        ROUND(AVG(wr.duration_minutes), 1) as duracao_media_pre
    FROM workout_records wr
    WHERE wr.workout_date < '2025-05-26'
        AND wr.user_id IN (
            SELECT DISTINCT user_id 
            FROM challenge_check_ins 
            WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        )
)
SELECT 
    '📈 ESTATÍSTICAS PRÉ-DESAFIO' as status,
    spc.usuarios_pre_challenge,
    spc.total_checkins_pre,
    spc.total_pontos_pre,
    spc.dias_unicos_pre,
    spc.primeiro_checkin_sistema,
    spc.ultimo_checkin_pre_inicio,
    stp.total_treinos_pre,
    stp.treinos_validos_pre,
    stp.duracao_media_pre,
    EXTRACT(DAYS FROM ('2025-05-26'::date - spc.primeiro_checkin_sistema::date)) as dias_antes_inicio_oficial
FROM stats_pre_challenge spc, stats_treinos_pre stp;

-- 🚨 POSSÍVEIS PROBLEMAS IDENTIFICADOS
WITH problemas AS (
    SELECT 
        'CHECK-INS_ANTES_INICIO' as tipo_problema,
        COUNT(*) as quantidade,
        'Check-ins registrados antes do início oficial do desafio' as descricao
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        AND cci.check_in_date < '2025-05-26'
    
    UNION ALL
    
    SELECT 
        'TREINOS_RETROATIVOS' as tipo_problema,
        COUNT(*) as quantidade,
        'Treinos com data anterior mas criados depois do início' as descricao
    FROM workout_records wr
    WHERE wr.workout_date < '2025-05-26'
        AND wr.created_at >= '2025-05-26'
        AND wr.user_id IN (
            SELECT DISTINCT user_id 
            FROM challenge_check_ins 
            WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        )
)
SELECT 
    '🚨 PROBLEMAS IDENTIFICADOS' as status,
    tipo_problema,
    quantidade,
    descricao,
    CASE 
        WHEN quantidade > 0 THEN '⚠️ REQUER ATENÇÃO'
        ELSE '✅ OK'
    END as severidade
FROM problemas
WHERE quantidade > 0;

-- 🔍 ANÁLISE TEMPORAL DETALHADA
SELECT 
    '🔍 ANÁLISE TEMPORAL' as status,
    cci.check_in_date::date as data,
    COUNT(*) as checkins_no_dia,
    COUNT(DISTINCT cci.user_id) as usuarios_ativos,
    SUM(cci.points) as pontos_distribuidos,
    STRING_AGG(DISTINCT cci.user_id::text, ', ') as usuarios_ids,
    EXTRACT(DAYS FROM ('2025-05-26'::date - cci.check_in_date::date)) as dias_antes_inicio
FROM challenge_check_ins cci
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    AND cci.check_in_date < '2025-05-26'
GROUP BY cci.check_in_date::date
ORDER BY cci.check_in_date::date ASC;

-- 🔍 DETALHES DOS USUÁRIOS E TREINOS PRÉ-DESAFIO
SELECT 
    '🔍 USUÁRIOS E TREINOS PRÉ-DESAFIO' as status,
    cci.user_id,
    cci.check_in_date,
    cci.points,
    cci.workout_id,
    wr.workout_name,
    wr.workout_type,
    wr.duration_minutes,
    wr.workout_date,
    wr.created_at as treino_criado_em,
    CASE 
        WHEN wr.workout_date < '2025-05-26' AND wr.created_at < '2025-05-26' THEN '✅ Treino legítimo pré-desafio'
        WHEN wr.workout_date < '2025-05-26' AND wr.created_at >= '2025-05-26' THEN '⚠️ Treino retroativo'
        WHEN cci.workout_id IS NULL THEN '❌ Check-in manual'
        ELSE '❓ Situação indefinida'
    END as status_legitimidade
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON cci.workout_id = wr.id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    AND cci.check_in_date < '2025-05-26'
ORDER BY cci.check_in_date ASC, cci.user_id; 