-- =====================================================
-- INVESTIGAÇÃO: PROBLEMA EM JUNHO 2025
-- =====================================================
-- Este script investiga o pico de registros problemáticos em junho 2025

-- =====================================================
-- PARTE 1: ANÁLISE DETALHADA DE JUNHO 2025
-- =====================================================

-- Analisar distribuição diária em junho 2025
SELECT 
    '=== REGISTROS DIÁRIOS EM JUNHO 2025 - CHALLENGE_CHECK_INS ===' as section;

WITH daily_analysis AS (
    SELECT 
        DATE(created_at) as creation_date,
        COUNT(*) as total_records,
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) as problematic_records,
        ROUND(
            (COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) * 100.0) / 
            COUNT(*), 2
        ) as problematic_percentage,
        MIN(DATE(created_at) - DATE(check_in_date)) as min_diff,
        MAX(DATE(created_at) - DATE(check_in_date)) as max_diff,
        AVG(DATE(created_at) - DATE(check_in_date)) as avg_diff
    FROM challenge_check_ins
    WHERE DATE(created_at) >= '2025-06-01' 
      AND DATE(created_at) < '2025-07-01'
    GROUP BY DATE(created_at)
    ORDER BY creation_date
)
SELECT 
    creation_date,
    total_records,
    problematic_records,
    problematic_percentage,
    min_diff,
    max_diff,
    ROUND(avg_diff, 2) as avg_diff,
    CASE 
        WHEN problematic_percentage > 50 THEN '🚨 CRÍTICO'
        WHEN problematic_percentage > 30 THEN '⚠️ ALTO'
        WHEN problematic_percentage > 10 THEN '🟡 MÉDIO'
        ELSE '✅ NORMAL'
    END as status
FROM daily_analysis;

-- =====================================================
-- PARTE 2: IDENTIFICAR DIAS PROBLEMÁTICOS ESPECÍFICOS
-- =====================================================

SELECT 
    '=== DIAS MAIS PROBLEMÁTICOS EM JUNHO 2025 ===' as section;

WITH problematic_days AS (
    SELECT 
        DATE(created_at) as creation_date,
        COUNT(*) as total_records,
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) as very_old_records,
        STRING_AGG(
            DISTINCT (DATE(created_at) - DATE(check_in_date))::TEXT, 
            ', ' ORDER BY (DATE(created_at) - DATE(check_in_date))::TEXT
        ) as diff_pattern
    FROM challenge_check_ins
    WHERE DATE(created_at) >= '2025-06-01' 
      AND DATE(created_at) < '2025-07-01'
      AND DATE(created_at) - DATE(check_in_date) > 7
    GROUP BY DATE(created_at)
    ORDER BY very_old_records DESC
    LIMIT 10
)
SELECT 
    creation_date,
    total_records,
    very_old_records,
    diff_pattern as days_difference_pattern
FROM problematic_days;

-- =====================================================
-- PARTE 3: ANÁLISE DE USUÁRIOS AFETADOS
-- =====================================================

SELECT 
    '=== USUÁRIOS MAIS AFETADOS EM JUNHO 2025 ===' as section;

WITH user_analysis AS (
    SELECT 
        user_id,
        COUNT(*) as total_checkins,
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) as problematic_checkins,
        ROUND(
            (COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) * 100.0) / 
            COUNT(*), 2
        ) as problematic_percentage,
        MIN(DATE(created_at)) as first_problematic_date,
        MAX(DATE(created_at)) as last_problematic_date
    FROM challenge_check_ins
    WHERE DATE(created_at) >= '2025-06-01' 
      AND DATE(created_at) < '2025-07-01'
      AND DATE(created_at) - DATE(check_in_date) > 7
    GROUP BY user_id
    ORDER BY problematic_checkins DESC
    LIMIT 15
)
SELECT 
    user_id,
    total_checkins,
    problematic_checkins,
    problematic_percentage,
    first_problematic_date,
    last_problematic_date,
    (last_problematic_date - first_problematic_date) as problematic_period_days
FROM user_analysis;

-- =====================================================
-- PARTE 4: ANÁLISE DE PADRÕES DE CHECK-IN_DATE
-- =====================================================

SELECT 
    '=== PADRÕES DE CHECK_IN_DATE EM REGISTROS PROBLEMÁTICOS ===' as section;

WITH checkin_date_analysis AS (
    SELECT 
        DATE(check_in_date) as checkin_date,
        COUNT(*) as records_count,
        COUNT(DISTINCT user_id) as unique_users,
        MIN(DATE(created_at)) as earliest_creation,
        MAX(DATE(created_at)) as latest_creation,
        (MAX(DATE(created_at)) - MIN(DATE(created_at))) as creation_span_days
    FROM challenge_check_ins
    WHERE DATE(created_at) >= '2025-06-01' 
      AND DATE(created_at) < '2025-07-01'
      AND DATE(created_at) - DATE(check_in_date) > 7
    GROUP BY DATE(check_in_date)
    ORDER BY records_count DESC
    LIMIT 10
)
SELECT 
    checkin_date,
    records_count,
    unique_users,
    earliest_creation,
    latest_creation,
    creation_span_days,
    CASE 
        WHEN creation_span_days = 0 THEN '⚡ BULK INSERT'
        WHEN creation_span_days <= 3 THEN '🟡 CONCENTRADO'
        ELSE '🟠 DISTRIBUÍDO'
    END as pattern_type
FROM checkin_date_analysis;

-- =====================================================
-- PARTE 5: COMPARAÇÃO COM MAIO 2025
-- =====================================================

SELECT 
    '=== COMPARAÇÃO MAIO vs JUNHO 2025 ===' as section;

WITH monthly_comparison AS (
    SELECT 
        TO_CHAR(created_at, 'YYYY-MM') as month,
        COUNT(*) as total_records,
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) as problematic_records,
        ROUND(
            (COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) * 100.0) / 
            COUNT(*), 2
        ) as problematic_percentage,
        COUNT(DISTINCT user_id) as unique_users,
        ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT user_id), 2) as avg_checkins_per_user
    FROM challenge_check_ins
    WHERE DATE(created_at) >= '2025-05-01' 
      AND DATE(created_at) < '2025-07-01'
    GROUP BY TO_CHAR(created_at, 'YYYY-MM')
    ORDER BY month
)
SELECT 
    month,
    total_records,
    problematic_records,
    problematic_percentage,
    unique_users,
    avg_checkins_per_user,
    CASE 
        WHEN month = '2025-06' THEN '📈 PROBLEMA IDENTIFICADO'
        ELSE '✅ NORMAL'
    END as status
FROM monthly_comparison;

-- =====================================================
-- PARTE 6: HIPÓTESES E RECOMENDAÇÕES
-- =====================================================

SELECT 
    '=== HIPÓTESES PARA O PROBLEMA ===' as section;

WITH hypothesis AS (
    SELECT 1 as order_num, 'Migração de dados históricos' as hypothesis, 
           'Dados antigos importados em junho sem ajuste de datas' as description,
           'ALTA' as probability
    UNION ALL
    SELECT 2, 'Bulk insert de registros retroativos', 
           'Usuários registrando múltiplos check-ins antigos de uma vez',
           'ALTA' as probability
    UNION ALL
    SELECT 3, 'Bug no sistema de datas', 
           'Problema temporário na aplicação com cálculo de datas',
           'MÉDIA' as probability
    UNION ALL
    SELECT 4, 'Mudança no comportamento do usuário', 
           'Usuários começaram a registrar check-ins muito retroativos',
           'BAIXA' as probability
)
SELECT 
    hypothesis,
    description,
    probability
FROM hypothesis
ORDER BY order_num;

-- =====================================================
-- RESUMO EXECUTIVO
-- =====================================================

SELECT 'INVESTIGAÇÃO DE JUNHO 2025 CONCLUÍDA!' as final_status;

/*
OBJETIVO DA INVESTIGAÇÃO:
- Identificar causa raiz do pico de 29.01% de registros problemáticos em junho 2025
- Comparar com maio 2025 (apenas 7.23% problemáticos)  
- Determinar se é migração, bug ou comportamento do usuário
- Criar plano de correção específico

PRÓXIMOS PASSOS:
1. Executar este script para obter dados detalhados
2. Analisar padrões identificados
3. Decidir sobre correções baseadas nos achados
4. Implementar validações preventivas
*/ 