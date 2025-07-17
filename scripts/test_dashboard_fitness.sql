-- Script para testar a função get_dashboard_fitness
-- Vamos verificar os dados retornados para a usuária Marcela

-- Primeiro, vamos ver os workout_records da usuária na semana atual
SELECT 
    DATE(wr.date) as data_treino,
    wr.workout_name,
    wr.workout_type,
    wr.duration_minutes,
    wr.created_at
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE(wr.date) >= CURRENT_DATE - INTERVAL '6 days'
AND DATE(wr.date) <= CURRENT_DATE
ORDER BY wr.date DESC;

-- Agora vamos testar a função get_dashboard_fitness
SELECT get_dashboard_fitness(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
    1,  -- Janeiro
    2025  -- 2025
);

-- Vamos ver os dados da semana atual de forma mais detalhada
SELECT 
    'Semana atual (últimos 7 dias)' as periodo,
    COUNT(*) as total_treinos,
    SUM(wr.duration_minutes) as total_minutos,
    COUNT(DISTINCT wr.workout_type) as tipos_treino,
    COUNT(DISTINCT DATE(wr.date)) as dias_treinados
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE(wr.date) >= CURRENT_DATE - INTERVAL '6 days'
AND DATE(wr.date) <= CURRENT_DATE

UNION ALL

SELECT 
    'Semana atual (segunda a domingo)' as periodo,
    COUNT(*) as total_treinos,
    SUM(wr.duration_minutes) as total_minutos,
    COUNT(DISTINCT wr.workout_type) as tipos_treino,
    COUNT(DISTINCT DATE(wr.date)) as dias_treinados
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE(wr.date) >= DATE_TRUNC('week', CURRENT_DATE)
AND DATE(wr.date) <= CURRENT_DATE

UNION ALL

SELECT 
    'Mês atual (Janeiro 2025)' as periodo,
    COUNT(*) as total_treinos,
    SUM(wr.duration_minutes) as total_minutos,
    COUNT(DISTINCT wr.workout_type) as tipos_treino,
    COUNT(DISTINCT DATE(wr.date)) as dias_treinados
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE(wr.date) >= DATE('2025-01-01')
AND DATE(wr.date) <= DATE('2025-01-31'); 