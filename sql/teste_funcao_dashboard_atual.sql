-- ========================================
-- TESTE DA FUNÇÃO get_dashboard_core ATUAL
-- ========================================
-- Usuário: 01d4a292-1873-4af6-948b-a55eed56d6b9 (Marcela)
-- Objetivo: Ver como a função atual calcula os minutos

-- 1. DADOS BRUTOS DO USUÁRIO
SELECT 
    '📊 DADOS BRUTOS DO USUÁRIO MARCELA' as secao;

-- Dados na tabela user_progress
SELECT 
    'USER_PROGRESS (dados armazenados):' as fonte,
    workouts as treinos_total,
    total_duration as minutos_armazenados,
    days_trained_this_month as dias_mes,
    current_streak,
    points,
    last_updated
FROM user_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 2. CÁLCULOS DIRETOS DOS WORKOUT_RECORDS
SELECT 
    '📅 CÁLCULOS DIRETOS DOS WORKOUT_RECORDS' as secao;

-- Total de todos os tempos
SELECT 
    'TODOS OS TREINOS:' as periodo,
    COUNT(*) as treinos,
    SUM(duration_minutes) as minutos,
    COUNT(DISTINCT DATE(date)) as dias_unicos,
    MIN(date) as primeiro_treino,
    MAX(date) as ultimo_treino
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'

UNION ALL

-- Apenas do mês atual (janeiro 2025)
SELECT 
    'MÊS ATUAL (2025-01):' as periodo,
    COUNT(*) as treinos,
    SUM(duration_minutes) as minutos,
    COUNT(DISTINCT DATE(date)) as dias_unicos,
    MIN(date) as primeiro_treino,
    MAX(date) as ultimo_treino
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE_PART('year', date) = 2025
AND DATE_PART('month', date) = 1;

-- 3. TESTAR A FUNÇÃO ATUAL
SELECT 
    '🧪 RESULTADO DA FUNÇÃO get_dashboard_core ATUAL' as secao;

-- Executar a função e mostrar os resultados
SELECT 
    (result->>'total_workouts')::int as treinos_funcao,
    (result->>'total_duration')::int as minutos_funcao,
    (result->>'days_trained_this_month')::int as dias_mes_funcao,
    result->>'last_updated' as ultima_atualizacao
FROM (
    SELECT get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid) as result
) teste;

-- 4. COMPARAÇÃO E DIAGNÓSTICO
SELECT 
    '🔍 ANÁLISE: A FUNÇÃO ESTÁ CALCULANDO CORRETAMENTE?' as secao;

-- Esta query vai nos mostrar se a função está retornando:
-- A) Minutos de todos os tempos, OU
-- B) Minutos apenas do mês atual

WITH dados_reais AS (
    SELECT 
        COUNT(*) as treinos_total,
        SUM(duration_minutes) as minutos_total,
        (SELECT SUM(duration_minutes) 
         FROM workout_records 
         WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
         AND DATE_PART('year', date) = 2025
         AND DATE_PART('month', date) = 1) as minutos_mes_atual
    FROM workout_records 
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
),
resultado_funcao AS (
    SELECT 
        (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_duration')::int as minutos_funcao
)
SELECT 
    dr.treinos_total,
    dr.minutos_total,
    dr.minutos_mes_atual,
    rf.minutos_funcao,
    CASE 
        WHEN rf.minutos_funcao = dr.minutos_total THEN '❌ Função retorna TODOS os minutos (problema atual)'
        WHEN rf.minutos_funcao = dr.minutos_mes_atual THEN '✅ Função retorna minutos do MÊS ATUAL (correto)'
        ELSE '⚠️ Função retorna valor diferente dos dois cálculos'
    END as diagnostico
FROM dados_reais dr, resultado_funcao rf; 