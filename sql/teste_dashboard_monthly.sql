-- ========================================
-- TESTE DASHBOARD MENSAL COMPLETO
-- ========================================
-- Data: 2025-01-27 21:15
-- Objetivo: Testar se a função get_user_dashboard_stats funciona com dados mensais

-- Executar primeiro os scripts:
-- 1. sql/verificar_dashboard_functions.sql
-- 2. sql/create_get_user_dashboard_stats.sql

-- TESTE 1: Verificar se a função foi criada
SELECT 
    'TESTE 1: VERIFICAÇÃO DA FUNÇÃO' as teste,
    p.proname as nome_funcao,
    pg_get_function_arguments(p.oid) as parametros,
    '✅ FUNÇÃO CRIADA COM SUCESSO' as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname = 'get_user_dashboard_stats';

-- TESTE 2: Executar a função (usando o User ID do log fornecido)
SELECT 
    'TESTE 2: EXECUÇÃO DA FUNÇÃO' as teste,
    get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid) as resultado;

-- TESTE 3: Verificar campos específicos
SELECT 
    'TESTE 3: VERIFICAÇÃO DOS CAMPOS' as teste,
    (get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'workout_count')::int as treinos_total,
    (get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_minutes')::int as minutos_mes,
    (get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'streak_days')::int as dias_streak,
    CASE 
        WHEN (get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_minutes')::int > 0
        THEN '✅ DADOS MENSAIS FUNCIONANDO'
        ELSE '⚠️ Verificar dados'
    END as status_mensal;

-- TESTE 4: Comparar com get_dashboard_core original
SELECT 
    'TESTE 4: COMPARAÇÃO COM ORIGINAL' as teste,
    (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_duration')::int as minutos_core,
    (get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_minutes')::int as minutos_stats,
    CASE 
        WHEN (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_duration')::int = 
             (get_user_dashboard_stats('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_minutes')::int
        THEN '✅ DADOS CONSISTENTES'
        ELSE '❌ DADOS INCONSISTENTES'
    END as consistencia;

-- RESULTADO ESPERADO NO FLUTTER
SELECT 
    'RESULTADO PARA O FLUTTER:' as info,
    'DashboardService agora deve funcionar com dados mensais' as observacao,
    'Os minutos mostrados serão apenas do mês atual' as comportamento; 