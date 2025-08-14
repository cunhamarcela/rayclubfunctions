-- ========================================
-- TESTE: DASHBOARD COM PERÍODO
-- ========================================
-- Data: 2025-01-27
-- Objetivo: Testar a nova funcionalidade de período no dashboard
-- Execute este script no Supabase SQL Editor

-- ========================================
-- CONFIGURAÇÕES DO TESTE
-- ========================================
-- Substitua este UUID pelo seu ID de usuário
\set user_test_id '01d4a292-1873-4af6-948b-a55eed56d6b9'

SELECT 
    '🧪 INICIANDO TESTES DO DASHBOARD COM PERÍODO' as status,
    'Usuário: 01d4a292-1873-4af6-948b-a55eed56d6b9' as usuario_teste;

-- ========================================
-- TESTE 1: ESTE MÊS (JANEIRO 2025)
-- ========================================
SELECT 
    '📅 TESTE 1: ESTE MÊS' as teste,
    '01/01/2025 - 31/01/2025' as periodo;

SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    '2025-01-01'::DATE,
    '2025-01-31'::DATE
) as resultado_este_mes;

-- ========================================
-- TESTE 2: ESTA SEMANA
-- ========================================
SELECT 
    '📅 TESTE 2: ESTA SEMANA' as teste,
    DATE_TRUNC('week', CURRENT_DATE)::DATE as inicio_semana,
    (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE as fim_semana;

SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    DATE_TRUNC('week', CURRENT_DATE)::DATE,
    (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE
) as resultado_esta_semana;

-- ========================================
-- TESTE 3: ÚLTIMOS 30 DIAS
-- ========================================
SELECT 
    '📅 TESTE 3: ÚLTIMOS 30 DIAS' as teste,
    (CURRENT_DATE - INTERVAL '30 days')::DATE as inicio,
    CURRENT_DATE as fim;

SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    (CURRENT_DATE - INTERVAL '30 days')::DATE,
    CURRENT_DATE
) as resultado_ultimos_30_dias;

-- ========================================
-- TESTE 4: PERÍODO ESPECÍFICO (MAIO 2025)
-- ========================================
SELECT 
    '📅 TESTE 4: MAIO 2025' as teste,
    '01/05/2025 - 31/05/2025' as periodo;

SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    '2025-05-01'::DATE,
    '2025-05-31'::DATE
) as resultado_maio_2025;

-- ========================================
-- TESTE 5: COMPARATIVO COM FUNÇÃO LEGACY
-- ========================================
SELECT 
    '🔄 TESTE 5: COMPARATIVO LEGACY vs NOVO' as teste;

-- Função antiga (deveria dar resultado igual ao "este mês")
SELECT 
    'LEGACY' as tipo,
    get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid) as resultado
UNION ALL
-- Função nova com período = este mês
SELECT 
    'NOVO' as tipo,
    get_dashboard_core_with_period(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        DATE_TRUNC('month', CURRENT_DATE)::DATE,
        (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE
    ) as resultado;

-- ========================================
-- TESTE 6: VALIDAÇÃO DE DADOS
-- ========================================
SELECT 
    '📊 TESTE 6: VALIDAÇÃO DOS DADOS' as teste;

-- Contar treinos manualmente por período para validar
WITH periodos AS (
    SELECT 
        'Este mês' as periodo,
        DATE_TRUNC('month', CURRENT_DATE)::DATE as inicio,
        (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE as fim
    UNION ALL
    SELECT 
        'Esta semana',
        DATE_TRUNC('week', CURRENT_DATE)::DATE,
        (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE
    UNION ALL
    SELECT 
        'Últimos 30 dias',
        (CURRENT_DATE - INTERVAL '30 days')::DATE,
        CURRENT_DATE
),
contagens AS (
    SELECT 
        p.periodo,
        p.inicio,
        p.fim,
        COUNT(wr.*) as total_treinos,
        COALESCE(SUM(wr.duration_minutes), 0) as total_minutos,
        COUNT(DISTINCT DATE(wr.date)) as dias_unicos
    FROM periodos p
    LEFT JOIN workout_records wr ON (
        wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
        AND wr.is_completed = TRUE
        AND wr.date >= p.inicio
        AND wr.date <= p.fim
    )
    GROUP BY p.periodo, p.inicio, p.fim
)
SELECT 
    periodo,
    CONCAT(TO_CHAR(inicio, 'DD/MM'), ' - ', TO_CHAR(fim, 'DD/MM')) as datas,
    total_treinos,
    total_minutos,
    dias_unicos
FROM contagens
ORDER BY inicio;

-- ========================================
-- TESTE 7: PERFORMANCE
-- ========================================
SELECT 
    '⚡ TESTE 7: PERFORMANCE' as teste;

-- Testar tempo de execução
\timing on

SELECT 
    'NOVA FUNÇÃO' as tipo,
    extract(epoch from now()) as inicio_timestamp;
    
SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    '2025-01-01'::DATE,
    '2025-12-31'::DATE
) as resultado_ano_completo;

SELECT 
    'CONCLUÍDO' as status,
    extract(epoch from now()) as fim_timestamp;

\timing off

-- ========================================
-- RESULTADO FINAL
-- ========================================
SELECT 
    '✅ TESTES CONCLUÍDOS' as status,
    'Verifique os resultados acima' as instrucao,
    'Se todos os testes retornaram dados válidos, a implementação está funcionando!' as conclusao; 