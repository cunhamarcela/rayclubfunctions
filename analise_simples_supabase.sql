-- =====================================================================================
-- ANÁLISE SIMPLES: CHECK-INS PRÉ-DESAFIO (VERSÃO SUPABASE)
-- Descrição: Análise rápida dos check-ins inválidos
-- Compatível com: Supabase PostgreSQL
-- =====================================================================================

-- 1. RESUMO GERAL DOS CHECK-INS INVÁLIDOS
SELECT 
    '🚨 RESUMO GERAL' as categoria,
    COUNT(*) as total_checkins_invalidos,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    SUM(points) as pontos_indevidos,
    MIN(check_in_date) as primeiro_checkin_invalido,
    MAX(check_in_date) as ultimo_checkin_invalido
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03';

-- 2. DETALHAMENTO POR DATA
SELECT 
    '📅 POR DATA' as categoria,
    DATE(check_in_date) as data_checkin,
    COUNT(*) as checkins_no_dia,
    COUNT(DISTINCT user_id) as usuarios_no_dia,
    SUM(points) as pontos_no_dia
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03'
GROUP BY DATE(check_in_date)
ORDER BY data_checkin;

-- 3. DETALHAMENTO POR TIPO (Manual vs Com Treino)
SELECT 
    '📊 POR TIPO' as categoria,
    CASE 
        WHEN workout_id IS NULL THEN 'Manual'
        ELSE 'Com Treino'
    END as tipo_checkin,
    COUNT(*) as quantidade,
    COUNT(DISTINCT user_id) as usuarios,
    SUM(points) as pontos
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03'
GROUP BY (workout_id IS NULL)
ORDER BY tipo_checkin;

-- 4. LISTA DOS PRIMEIROS 20 CHECK-INS INVÁLIDOS
SELECT 
    '🔍 DETALHES' as categoria,
    user_id,
    check_in_date,
    points,
    CASE 
        WHEN workout_id IS NULL THEN 'Manual'
        ELSE 'Com Treino'
    END as tipo,
    workout_id,
    EXTRACT(EPOCH FROM ('2025-05-26 00:00:00-03'::TIMESTAMP WITH TIME ZONE - check_in_date))/3600 as horas_antes_inicio
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03'
ORDER BY check_in_date, user_id
LIMIT 20;

-- 5. VERIFICAÇÃO DE FUSO HORÁRIO
SELECT 
    '🌍 FUSO HORÁRIO' as categoria,
    '2025-05-26 00:00:00-03'::TIMESTAMP WITH TIME ZONE as inicio_oficial,
    NOW() as agora,
    EXTRACT(TIMEZONE FROM NOW())/3600 as fuso_atual_horas,
    'Check-ins antes de 26/05 00:00 são inválidos' as regra;

-- 6. IMPACTO NO RANKING (Top 10 usuários afetados)
SELECT 
    '🏆 RANKING AFETADO' as categoria,
    cp.user_id,
    cp.total_check_ins,
    cp.total_points,
    cp.current_rank,
    COUNT(cci.id) as checkins_invalidos,
    SUM(cci.points) as pontos_invalidos
FROM challenge_progress cp
JOIN challenge_check_ins cci ON cp.user_id = cci.user_id AND cp.challenge_id = cci.challenge_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND cci.check_in_date < '2025-05-26 00:00:00-03'
GROUP BY cp.user_id, cp.total_check_ins, cp.total_points, cp.current_rank
ORDER BY cp.current_rank
LIMIT 10; 