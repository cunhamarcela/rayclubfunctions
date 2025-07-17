-- 🔍 INVESTIGAÇÃO: Usuário bc0bfc71 - 429 Check-ins Duplicados
-- Data: 2025-01-11
-- Problema: 429 check-ins registrados quando deveria ter apenas 16

SET timezone = 'America/Sao_Paulo';

-- 1️⃣ ANÁLISE DETALHADA DOS CHECK-INS DUPLICADOS
SELECT 
    '🔍 DUPLICADOS POR DIA' as status,
    check_in_date::date as data,
    COUNT(*) as total_checkins_no_dia,
    COUNT(DISTINCT workout_id) as treinos_distintos,
    STRING_AGG(DISTINCT 
        CASE 
            WHEN workout_id IS NULL THEN '❌ Manual/Órfão'
            ELSE '✅ Com treino'
        END, ', '
    ) as tipos_checkin,
    MIN(created_at) as primeiro_checkin,
    MAX(created_at) as ultimo_checkin,
    EXTRACT(EPOCH FROM (MAX(created_at) - MIN(created_at)))/60 as diferenca_minutos
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY check_in_date::date
ORDER BY data DESC;

-- 2️⃣ ANÁLISE DOS CHECK-INS MAIS PROBLEMÁTICOS
SELECT 
    '🚨 DIAS COM MAIS DUPLICATAS' as status,
    check_in_date::date as data,
    COUNT(*) as total_duplicados,
    STRING_AGG(
        CASE 
            WHEN workout_id IS NULL THEN 'Manual'
            ELSE COALESCE(workout_name, 'Treino sem nome')
        END, 
        ' | ' ORDER BY created_at
    ) as checkins_detalhados
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON cci.workout_id = wr.id
WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY check_in_date::date
HAVING COUNT(*) > 5  -- Dias com mais de 5 check-ins
ORDER BY total_duplicados DESC, data DESC;

-- 3️⃣ PADRÃO TEMPORAL DOS CHECK-INS
SELECT 
    '📊 PADRÃO DE CRIAÇÃO' as status,
    DATE_TRUNC('hour', created_at) as hora_criacao,
    COUNT(*) as checkins_criados,
    COUNT(DISTINCT check_in_date::date) as dias_afetados,
    STRING_AGG(DISTINCT check_in_date::date::text, ', ' ORDER BY check_in_date::date) as datas_afetadas
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY DATE_TRUNC('hour', created_at)
HAVING COUNT(*) > 10  -- Horas com mais de 10 check-ins criados
ORDER BY checkins_criados DESC;

-- 4️⃣ COMPARAÇÃO: TREINOS vs CHECK-INS POR DIA
WITH treinos_por_dia AS (
    SELECT 
        workout_date::date as data,
        COUNT(*) as total_treinos,
        COUNT(CASE WHEN duration_minutes >= 45 THEN 1 END) as treinos_validos,
        STRING_AGG(workout_name || ' (' || duration_minutes || 'min)', ', ') as treinos_detalhes
    FROM workout_records 
    WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
        AND workout_date >= '2025-05-25'
        AND workout_date <= '2025-06-10'
    GROUP BY workout_date::date
),
checkins_por_dia AS (
    SELECT 
        check_in_date::date as data,
        COUNT(*) as total_checkins,
        COUNT(DISTINCT workout_id) as treinos_checkin_distintos
    FROM challenge_check_ins
    WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
        AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    GROUP BY check_in_date::date
)
SELECT 
    '⚖️ TREINOS vs CHECK-INS' as status,
    COALESCE(t.data, c.data) as data,
    COALESCE(t.total_treinos, 0) as treinos_registrados,
    COALESCE(t.treinos_validos, 0) as treinos_validos_45min,
    COALESCE(c.total_checkins, 0) as checkins_registrados,
    CASE 
        WHEN c.total_checkins > 1 THEN '🚨 DUPLICADO (' || c.total_checkins || 'x)'
        WHEN c.total_checkins = 1 THEN '✅ Normal'
        WHEN c.total_checkins IS NULL THEN '❌ Sem check-in'
    END as status_checkin,
    t.treinos_detalhes
FROM treinos_por_dia t
FULL OUTER JOIN checkins_por_dia c ON t.data = c.data
ORDER BY data DESC;

-- 5️⃣ IDENTIFICAR CHECK-INS PARA LIMPEZA
SELECT 
    '🧹 CHECK-INS PARA REMOVER' as status,
    check_in_date::date as data,
    COUNT(*) as total_checkins,
    COUNT(*) - 1 as checkins_para_remover,
    STRING_AGG(
        id::text || ' (' || 
        CASE WHEN workout_id IS NULL THEN 'Manual' ELSE 'Treino' END || 
        ' - ' || created_at::time || ')',
        ', ' ORDER BY created_at DESC
    ) as ids_para_analise
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY check_in_date::date
HAVING COUNT(*) > 1
ORDER BY total_checkins DESC, data DESC;

-- 6️⃣ RESUMO FINAL
SELECT 
    '📋 RESUMO FINAL' as status,
    COUNT(*) as total_checkins_atual,
    COUNT(DISTINCT check_in_date::date) as dias_unicos,
    COUNT(*) - COUNT(DISTINCT check_in_date::date) as checkins_duplicados_para_remover,
    SUM(points) as pontos_atuais,
    COUNT(DISTINCT check_in_date::date) * 10 as pontos_corretos,
    SUM(points) - (COUNT(DISTINCT check_in_date::date) * 10) as pontos_excesso
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 