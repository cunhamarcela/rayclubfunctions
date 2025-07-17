-- 🔍 INVESTIGAÇÃO SISTÊMICA: Duplicações de Check-ins em Todo o Sistema
-- Data: 2025-01-11
-- Objetivo: Identificar escala do problema e usuários afetados

SET timezone = 'America/Sao_Paulo';

-- 1️⃣ ESCALA GERAL DO PROBLEMA
SELECT 
    '📊 ESCALA GERAL' as status,
    COUNT(*) as total_checkins_sistema,
    COUNT(DISTINCT user_id) as usuarios_com_checkins,
    COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as dias_unicos_reais,
    COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as duplicados_totais_sistema,
    ROUND(
        (COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date))) * 100.0 / COUNT(*), 
        2
    ) as percentual_duplicados
FROM challenge_check_ins;

-- 2️⃣ USUÁRIOS MAIS AFETADOS (Top 20)
WITH duplicados_por_usuario AS (
    SELECT 
        user_id,
        challenge_id,
        COUNT(*) as total_checkins,
        COUNT(DISTINCT check_in_date::date) as dias_unicos,
        COUNT(*) - COUNT(DISTINCT check_in_date::date) as duplicados,
        SUM(points) as pontos_atuais,
        COUNT(DISTINCT check_in_date::date) * 10 as pontos_corretos,
        SUM(points) - (COUNT(DISTINCT check_in_date::date) * 10) as pontos_excesso
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id
    HAVING COUNT(*) > COUNT(DISTINCT check_in_date::date)  -- Apenas usuários com duplicados
)
SELECT 
    '🚨 TOP 20 USUÁRIOS AFETADOS' as status,
    user_id,
    challenge_id,
    total_checkins,
    dias_unicos,
    duplicados,
    pontos_excesso,
    CASE 
        WHEN duplicados > 100 THEN '🔥 CRÍTICO'
        WHEN duplicados > 50 THEN '⚠️ ALTO'
        WHEN duplicados > 10 THEN '⚡ MÉDIO'
        ELSE '📝 BAIXO'
    END as severidade
FROM duplicados_por_usuario
ORDER BY duplicados DESC
LIMIT 20;

-- 3️⃣ DISTRIBUIÇÃO POR SEVERIDADE
WITH duplicados_por_usuario AS (
    SELECT 
        user_id,
        challenge_id,
        COUNT(*) - COUNT(DISTINCT check_in_date::date) as duplicados
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id
    HAVING COUNT(*) > COUNT(DISTINCT check_in_date::date)
)
SELECT 
    '📈 DISTRIBUIÇÃO POR SEVERIDADE' as status,
    CASE 
        WHEN duplicados > 100 THEN '🔥 CRÍTICO (>100)'
        WHEN duplicados > 50 THEN '⚠️ ALTO (51-100)'
        WHEN duplicados > 10 THEN '⚡ MÉDIO (11-50)'
        ELSE '📝 BAIXO (1-10)'
    END as categoria,
    COUNT(*) as usuarios_afetados,
    SUM(duplicados) as total_duplicados_categoria,
    ROUND(AVG(duplicados), 1) as media_duplicados
FROM duplicados_por_usuario
GROUP BY 
    CASE 
        WHEN duplicados > 100 THEN 1
        WHEN duplicados > 50 THEN 2
        WHEN duplicados > 10 THEN 3
        ELSE 4
    END,
    CASE 
        WHEN duplicados > 100 THEN '🔥 CRÍTICO (>100)'
        WHEN duplicados > 50 THEN '⚠️ ALTO (51-100)'
        WHEN duplicados > 10 THEN '⚡ MÉDIO (11-50)'
        ELSE '📝 BAIXO (1-10)'
    END
ORDER BY 1;

-- 4️⃣ PADRÃO TEMPORAL - Quando os duplicados foram criados
SELECT 
    '📅 PADRÃO TEMPORAL' as status,
    DATE_TRUNC('day', created_at)::date as data_criacao,
    COUNT(*) as checkins_criados,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as duplicados_criados
FROM challenge_check_ins
WHERE created_at >= '2025-05-01'  -- Últimos meses
GROUP BY DATE_TRUNC('day', created_at)::date
HAVING COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) > 0
ORDER BY duplicados_criados DESC
LIMIT 10;

-- 5️⃣ CHALLENGES MAIS AFETADOS
WITH duplicados_por_challenge AS (
    SELECT 
        challenge_id,
        COUNT(*) as total_checkins,
        COUNT(DISTINCT user_id) as usuarios_participantes,
        COUNT(DISTINCT (user_id, check_in_date::date)) as dias_unicos,
        COUNT(*) - COUNT(DISTINCT (user_id, check_in_date::date)) as duplicados_total,
        SUM(points) as pontos_atuais,
        COUNT(DISTINCT (user_id, check_in_date::date)) * 10 as pontos_corretos
    FROM challenge_check_ins
    GROUP BY challenge_id
    HAVING COUNT(*) > COUNT(DISTINCT (user_id, check_in_date::date))
)
SELECT 
    '🎯 CHALLENGES AFETADOS' as status,
    challenge_id,
    usuarios_participantes,
    total_checkins,
    duplicados_total,
    ROUND(duplicados_total * 100.0 / total_checkins, 1) as percentual_duplicados,
    pontos_atuais - pontos_corretos as pontos_excesso
FROM duplicados_por_challenge
ORDER BY duplicados_total DESC;

-- 6️⃣ IMPACTO FINANCEIRO/PONTOS
WITH impacto_total AS (
    SELECT 
        COUNT(*) as total_checkins,
        COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as checkins_validos,
        COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as duplicados_sistema,
        SUM(points) as pontos_distribuidos,
        COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) * 10 as pontos_corretos
    FROM challenge_check_ins
)
SELECT 
    '💰 IMPACTO TOTAL' as status,
    duplicados_sistema as checkins_duplicados,
    pontos_distribuidos - pontos_corretos as pontos_excesso,
    ROUND((pontos_distribuidos - pontos_corretos) * 100.0 / pontos_distribuidos, 2) as percentual_inflacao_pontos,
    'R$ ' || ROUND((pontos_distribuidos - pontos_corretos) * 0.01, 2) as valor_estimado_excesso  -- Assumindo 1 ponto = R$ 0,01
FROM impacto_total;

-- 7️⃣ USUÁRIOS PARA LIMPEZA PRIORITÁRIA (>10 duplicados)
SELECT 
    '🎯 LISTA LIMPEZA PRIORITÁRIA' as status,
    user_id,
    challenge_id,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT check_in_date::date) as dias_unicos,
    COUNT(*) - COUNT(DISTINCT check_in_date::date) as duplicados_para_remover,
    SUM(points) as pontos_atuais,
    COUNT(DISTINCT check_in_date::date) * 10 as pontos_corretos
FROM challenge_check_ins
GROUP BY user_id, challenge_id
HAVING COUNT(*) - COUNT(DISTINCT check_in_date::date) > 10  -- Apenas casos significativos
ORDER BY COUNT(*) - COUNT(DISTINCT check_in_date::date) DESC; 