-- ========================================
-- VERIFICAÇÃO FUNÇÕES WEEKLY GOALS NO SUPABASE
-- ========================================
-- Data: 2025-01-27 22:15
-- Objetivo: Verificar quais funções existem e quais estão faltando

-- 1. VERIFICAR TABELA WEEKLY_GOALS
SELECT 
    'VERIFICAÇÃO TABELA WEEKLY_GOALS:' as titulo;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'weekly_goals')
        THEN '✅ Tabela weekly_goals EXISTE'
        ELSE '❌ Tabela weekly_goals NÃO EXISTE'
    END as status_tabela;

-- 2. VERIFICAR FUNÇÕES EXISTENTES
SELECT 
    'FUNÇÕES WEEKLY GOALS EXISTENTES:' as titulo;

SELECT 
    p.proname as nome_funcao,
    pg_get_function_arguments(p.oid) as parametros,
    pg_get_function_result(p.oid) as retorno
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND (
    p.proname LIKE '%weekly%goal%' OR
    p.proname IN ('get_or_create_weekly_goal', 'add_workout_minutes_to_goal', 'update_weekly_goal')
)
ORDER BY p.proname;

-- 3. LISTAR TODAS AS FUNÇÕES DO SISTEMA
SELECT 
    'TODAS AS FUNÇÕES DISPONÍVEIS:' as titulo;

SELECT 
    p.proname as nome_funcao
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname NOT LIKE 'pg_%'
ORDER BY p.proname;

-- 4. VERIFICAR CÁLCULO DE SEMANA (para confirmar que funciona)
SELECT 
    'CÁLCULO SEMANA ATUAL:' as info,
    CURRENT_DATE as hoje,
    date_trunc('week', CURRENT_DATE) as inicio_semana,
    date_trunc('week', CURRENT_DATE) + interval '6 days' as fim_semana,
    EXTRACT(dow FROM CURRENT_DATE) as dia_semana;

-- 5. VERIFICAR SE EXISTE ALGUM REGISTRO DE WEEKLY GOALS
SELECT 
    'REGISTROS WEEKLY GOALS EXISTENTES:' as titulo;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'weekly_goals')
        THEN (
            SELECT COALESCE(COUNT(*)::text, '0') || ' registros encontrados'
            FROM weekly_goals
        )
        ELSE 'Tabela não existe'
    END as total_registros; 