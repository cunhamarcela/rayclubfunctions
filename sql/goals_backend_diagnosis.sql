-- ========================================
-- SCRIPT DE DIAGNÓSTICO - SISTEMA DE METAS RAY CLUB
-- ========================================
-- Data: 29 de Janeiro de 2025 às 18:00
-- Objetivo: Verificar estado atual do backend ANTES de qualquer migração
-- Referência: Diagnóstico seguro do sistema de metas

-- IMPORTANTE: Este script é SOMENTE LEITURA
-- Não faz nenhuma alteração no banco de dados

\echo '🔍 ========================================='
\echo '🔍 DIAGNÓSTICO COMPLETO - SISTEMA DE METAS'
\echo '🔍 ========================================='

-- 1. VERIFICAR TODAS AS TABELAS RELACIONADAS A METAS
\echo ''
\echo '📊 1. TABELAS DE METAS EXISTENTES:'
\echo '=================================='

SELECT 
    table_name,
    table_type,
    CASE 
        WHEN table_name LIKE '%goal%' THEN '🎯 META'
        WHEN table_name LIKE '%workout%' THEN '💪 TREINO'
        ELSE '📝 OUTRO'
    END as categoria
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND (
        table_name LIKE '%goal%' 
        OR table_name LIKE '%weekly%'
        OR table_name LIKE '%workout_category%'
    )
ORDER BY table_name;

-- 2. ESTRUTURA DETALHADA DE CADA TABELA DE METAS
\echo ''
\echo '🏗️ 2. ESTRUTURA DAS TABELAS DE METAS:'
\echo '=================================='

-- user_goals
\echo ''
\echo '📋 TABELA: user_goals'
\echo '---------------------'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- workout_category_goals
\echo ''
\echo '📋 TABELA: workout_category_goals'
\echo '--------------------------------'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'workout_category_goals' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- weekly_goals
\echo ''
\echo '📋 TABELA: weekly_goals'
\echo '----------------------'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'weekly_goals' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- personalized_weekly_goals
\echo ''
\echo '📋 TABELA: personalized_weekly_goals'
\echo '-----------------------------------'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'personalized_weekly_goals' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. VERIFICAR TRIGGERS E FUNÇÕES RELACIONADAS A METAS
\echo ''
\echo '⚡ 3. TRIGGERS E FUNÇÕES EXISTENTES:'
\echo '=================================='

-- Triggers relacionados a metas
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers 
WHERE trigger_name LIKE '%goal%' 
    OR event_object_table LIKE '%goal%'
    OR trigger_name LIKE '%workout%category%'
ORDER BY trigger_name;

-- Funções relacionadas a metas
\echo ''
\echo '🔧 FUNÇÕES RELACIONADAS A METAS:'
\echo '-------------------------------'
SELECT 
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND (
        routine_name LIKE '%goal%' 
        OR routine_name LIKE '%workout_category%'
    )
ORDER BY routine_name;

-- 4. CONTAGEM DE DADOS EXISTENTES
\echo ''
\echo '📈 4. DADOS EXISTENTES NAS TABELAS:'
\echo '=================================='

-- Verificar se as tabelas existem antes de contar
DO $$
DECLARE
    table_exists boolean;
BEGIN
    -- user_goals
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'user_goals'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '📊 user_goals: % registros', (SELECT COUNT(*) FROM user_goals);
    ELSE
        RAISE NOTICE '❌ user_goals: TABELA NÃO EXISTE';
    END IF;

    -- workout_category_goals
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'workout_category_goals'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '📊 workout_category_goals: % registros', (SELECT COUNT(*) FROM workout_category_goals);
    ELSE
        RAISE NOTICE '❌ workout_category_goals: TABELA NÃO EXISTE';
    END IF;

    -- weekly_goals
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'weekly_goals'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '📊 weekly_goals: % registros', (SELECT COUNT(*) FROM weekly_goals);
    ELSE
        RAISE NOTICE '❌ weekly_goals: TABELA NÃO EXISTE';
    END IF;

    -- personalized_weekly_goals
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'personalized_weekly_goals'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '📊 personalized_weekly_goals: % registros', (SELECT COUNT(*) FROM personalized_weekly_goals);
    ELSE
        RAISE NOTICE '❌ personalized_weekly_goals: TABELA NÃO EXISTE';
    END IF;
END $$;

-- 5. VERIFICAR INTEGRAÇÃO COM TABELA DE TREINOS
\echo ''
\echo '🔗 5. INTEGRAÇÃO COM SISTEMA DE TREINOS:'
\echo '======================================='

-- Verificar se existe a tabela workout_records
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'workout_records'
) as workout_records_exists;

-- Verificar campos que podem conectar treinos com metas
SELECT 
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'workout_records' 
    AND table_schema = 'public'
    AND (
        column_name LIKE '%category%'
        OR column_name LIKE '%type%'
        OR column_name LIKE '%goal%'
    )
ORDER BY column_name;

-- 6. VERIFICAR CONSTRAINTS E ÍNDICES
\echo ''
\echo '🔒 6. CONSTRAINTS E ÍNDICES:'
\echo '============================'

-- Primary keys das tabelas de metas
SELECT 
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.table_name LIKE '%goal%'
    AND tc.constraint_type = 'PRIMARY KEY'
ORDER BY tc.table_name;

-- Foreign keys das tabelas de metas
SELECT 
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.table_name LIKE '%goal%'
    AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;

-- 7. VERIFICAR POLÍTICAS RLS (ROW LEVEL SECURITY)
\echo ''
\echo '🛡️ 7. POLÍTICAS DE SEGURANÇA (RLS):'
\echo '=================================='

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename LIKE '%goal%'
ORDER BY tablename, policyname;

-- 8. RESUMO E RECOMENDAÇÕES
\echo ''
\echo '📋 8. RESUMO DO DIAGNÓSTICO:'
\echo '============================'
\echo ''
\echo '✅ VERIFICAÇÃO COMPLETA REALIZADA!'
\echo ''
\echo '📌 PRÓXIMOS PASSOS RECOMENDADOS:'
\echo '  1. Analisar os resultados acima'
\echo '  2. Identificar conflitos potenciais'
\echo '  3. Decidir se a migração é necessária'
\echo '  4. Fazer backup antes de qualquer alteração'
\echo ''
\echo '⚠️  ATENÇÃO: NÃO rode a migração sem antes analisar estes resultados!'
\echo ''
\echo '🔍 Diagnóstico finalizado em:' 
SELECT NOW(); 