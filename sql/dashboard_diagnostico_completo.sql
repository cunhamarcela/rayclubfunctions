-- ========================================
-- DIAGNÓSTICO COMPLETO: DASHBOARD SISTEMA
-- ========================================
-- Data: 2025-01-22
-- Execute este script no SQL Editor do Supabase para entender o estado atual
-- ANTES de fazer qualquer alteração no sistema

-- ========================================
-- 1. VERIFICAR FUNÇÕES EXISTENTES
-- ========================================

SELECT 
    '🔍 FUNÇÕES RELACIONADAS AO DASHBOARD' as secao;

SELECT 
    p.proname as nome_funcao,
    p.pronargs as qtd_parametros,
    pg_get_function_result(p.oid) as tipo_retorno,
    pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND (
    p.proname LIKE '%dashboard%' 
    OR p.proname IN ('get_dashboard_core', 'get_dashboard_data', 'get_dashboard_fitness')
)
ORDER BY p.proname;

-- ========================================
-- 2. VERIFICAR ESTRUTURA DA TABELA USER_PROGRESS
-- ========================================

SELECT 
    '📊 ESTRUTURA DA TABELA USER_PROGRESS' as secao;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_progress'
ORDER BY ordinal_position;

-- ========================================
-- 3. VERIFICAR DADOS REAIS DE UM USUÁRIO
-- ========================================

SELECT 
    '👤 DADOS REAIS DO USUÁRIO (SAMPLE)' as secao;

-- Buscar um usuário que tenha dados
WITH sample_user AS (
    SELECT user_id, COUNT(*) as workout_count
    FROM workout_records 
    GROUP BY user_id 
    HAVING COUNT(*) > 0
    ORDER BY workout_count DESC
    LIMIT 1
)
SELECT 
    'USER_PROGRESS:' as fonte,
    up.user_id::text as user_id,
    up.workouts as total_workouts,
    up.points as total_points,
    up.total_duration as duration_all_time,
    up.days_trained_this_month,
    up.current_streak,
    up.longest_streak,
    up.last_updated
FROM user_progress up
JOIN sample_user su ON up.user_id = su.user_id

UNION ALL

SELECT 
    'WORKOUT_RECORDS (MÊS ATUAL):' as fonte,
    wr.user_id::text,
    COUNT(*)::int as workouts_mes_atual,
    SUM(wr.duration_minutes)::int as minutos_mes_atual,
    COUNT(DISTINCT DATE(wr.date))::int as dias_unicos_mes,
    NULL::int, NULL::int, NULL::int,
    NULL::timestamp
FROM workout_records wr
JOIN sample_user su ON wr.user_id = su.user_id
WHERE DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE)
GROUP BY wr.user_id

UNION ALL

SELECT 
    'WORKOUT_RECORDS (TODOS):' as fonte,
    wr.user_id::text,
    COUNT(*)::int as workouts_total,
    SUM(wr.duration_minutes)::int as minutos_total,
    COUNT(DISTINCT DATE(wr.date))::int as dias_unicos_total,
    NULL::int, NULL::int, NULL::int,
    NULL::timestamp
FROM workout_records wr
JOIN sample_user su ON wr.user_id = su.user_id
GROUP BY wr.user_id;

-- ========================================
-- 4. VERIFICAR SE get_dashboard_core EXISTE E FUNCIONA
-- ========================================

SELECT 
    '🧪 TESTE DA FUNÇÃO ATUAL' as secao;

DO $$
DECLARE
    test_user_id UUID;
    test_result JSON;
    funcao_existe BOOLEAN;
BEGIN
    -- Verificar se a função existe
    SELECT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'get_dashboard_core'
    ) INTO funcao_existe;
    
    IF funcao_existe THEN
        RAISE NOTICE '✅ Função get_dashboard_core existe';
        
        -- Buscar um usuário para teste
        SELECT user_id INTO test_user_id 
        FROM workout_records 
        GROUP BY user_id 
        HAVING COUNT(*) > 0
        LIMIT 1;
        
        IF test_user_id IS NOT NULL THEN
            -- Testar a função
            SELECT get_dashboard_core(test_user_id) INTO test_result;
            
            RAISE NOTICE '📊 Resultado atual:';
            RAISE NOTICE '  - total_workouts: %', (test_result->>'total_workouts')::int;
            RAISE NOTICE '  - total_duration: %', (test_result->>'total_duration')::int;
            RAISE NOTICE '  - days_trained_this_month: %', (test_result->>'days_trained_this_month')::int;
        ELSE
            RAISE NOTICE '⚠️ Nenhum usuário com treinos encontrado para teste';
        END IF;
    ELSE
        RAISE NOTICE '❌ Função get_dashboard_core NÃO existe';
        RAISE NOTICE '💡 Precisamos criar a função';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao testar função: %', SQLERRM;
END $$;

-- ========================================
-- 5. VERIFICAR DADOS DOS TREINOS POR MÊS
-- ========================================

SELECT 
    '📅 DISTRIBUIÇÃO DE TREINOS POR MÊS' as secao;

SELECT 
    TO_CHAR(wr.date, 'YYYY-MM') as mes,
    COUNT(*) as total_treinos,
    SUM(wr.duration_minutes) as total_minutos,
    COUNT(DISTINCT wr.user_id) as usuarios_ativos,
    COUNT(DISTINCT DATE(wr.date)) as dias_com_treino
FROM workout_records wr
WHERE wr.date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(wr.date, 'YYYY-MM')
ORDER BY mes DESC;

-- ========================================
-- 6. VERIFICAR O QUE O DashboardRepository ESPERA
-- ========================================

SELECT 
    '🔧 COMPATIBILIDADE COM FLUTTER' as secao;

-- A função deve retornar um JSON compatível com DashboardData.fromJson()
-- Campos esperados:
-- - total_workouts (int)
-- - total_duration (int) ← ESTA É A MUDANÇA
-- - days_trained_this_month (int)
-- - workouts_by_type (Map<String, dynamic>)
-- - recent_workouts (List)
-- - challenge_progress (Map)
-- - last_updated (DateTime)

SELECT 
    'O DashboardRepository está chamando:' as info,
    '.rpc(''get_dashboard_core'', params: {''user_id_param'': userId})' as chamada;

-- ========================================
-- RESUMO
-- ========================================

SELECT 
    '📋 PRÓXIMOS PASSOS' as secao;

SELECT 
    'Após executar este diagnóstico:' as passo,
    '1. Verificar se get_dashboard_core existe' as acao
UNION ALL
SELECT 
    '2. Se existe:', 
    'Modificar para calcular total_duration apenas do mês atual'
UNION ALL
SELECT 
    '3. Se não existe:', 
    'Criar a função com a lógica correta'
UNION ALL
SELECT 
    '4. Testar:', 
    'Verificar se os valores estão corretos no app'; 