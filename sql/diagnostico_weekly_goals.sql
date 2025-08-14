-- ========================================
-- DIAGNÓSTICO WEEKLY GOALS SYSTEM
-- ========================================
-- Data: 2025-01-27 21:45
-- Descoberta: Dashboard usa sistema simples, mas existe sistema avançado!

-- 1. VERIFICAR SE SISTEMA DE WEEKLY GOALS ESTÁ ATIVO
SELECT 
    'DIAGNÓSTICO SISTEMA WEEKLY GOALS:' as titulo;

-- Verificar se tabela existe
SELECT 
    'VERIFICAÇÃO TABELA:' as secao,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'weekly_goals')
        THEN '✅ Tabela weekly_goals EXISTE'
        ELSE '❌ Tabela weekly_goals NÃO EXISTE'
    END as status_tabela;

-- Verificar funções
SELECT 
    'VERIFICAÇÃO FUNÇÕES:' as secao,
    p.proname as funcao,
    '✅ EXISTE' as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN ('get_or_create_weekly_goal', 'add_workout_minutes_to_goal', 'update_weekly_goal')
ORDER BY p.proname;

-- 2. VERIFICAR DADOS ATUAIS DO USUÁRIO
SELECT 
    'DADOS SEMANA ATUAL:' as secao,
    'User: 01d4a292-1873-4af6-948b-a55eed56d6b9' as usuario;

-- Testar função get_or_create_weekly_goal
SELECT 
    'TESTE WEEKLY GOAL:' as teste,
    * 
FROM get_or_create_weekly_goal('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- Verificar se existe registro na tabela
SELECT 
    'REGISTRO DIRETO NA TABELA:' as secao,
    id,
    goal_minutes,
    current_minutes,
    week_start_date,
    week_end_date,
    completed,
    created_at
FROM weekly_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
ORDER BY week_start_date DESC
LIMIT 5;

-- 3. VERIFICAR CÁLCULO DA SEMANA
SELECT 
    'CÁLCULO SEMANA ATUAL:' as info,
    CURRENT_DATE as hoje,
    date_trunc('week', CURRENT_DATE)::date as inicio_semana,
    (date_trunc('week', CURRENT_DATE)::date + interval '6 days')::date as fim_semana,
    EXTRACT(dow FROM CURRENT_DATE) as dia_semana; -- 0=domingo, 1=segunda

-- 4. PROBLEMA IDENTIFICADO
SELECT 
    'PROBLEMA IDENTIFICADO:' as titulo,
    'Dashboard usa sistema SIMPLES (180 hard-coded)' as problema1,
    'Existe sistema AVANÇADO (weekly_goals table)' as descoberta,
    'Precisa conectar dashboard ao sistema real' as solucao; 