-- Script para identificar o mês com mais treinos da usuária
-- E navegar para esse mês no dashboard

-- Primeiro, vamos ver quais meses a usuária tem treinos
SELECT 
    EXTRACT(YEAR FROM wr.date) as ano,
    EXTRACT(MONTH FROM wr.date) as mes,
    COUNT(*) as total_treinos,
    SUM(wr.duration_minutes) as total_minutos,
    MIN(DATE(wr.date)) as primeiro_treino,
    MAX(DATE(wr.date)) as ultimo_treino
FROM workout_records wr
WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
GROUP BY EXTRACT(YEAR FROM wr.date), EXTRACT(MONTH FROM wr.date)
ORDER BY ano DESC, mes DESC;

-- Agora vamos testar a função para julho 2025 (onde estão os treinos)
SELECT get_dashboard_fitness(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
    7,  -- Julho
    2025  -- 2025
); 