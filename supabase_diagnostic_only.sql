-- ================================================================
-- SCRIPT DE DIAGNÓSTICO SUPABASE (APENAS LEITURA)
-- ================================================================
-- Este script apenas verifica o estado atual sem alterar nada
-- Execute este primeiro para entender o que precisa ser alterado
-- ================================================================

-- ================================================================
-- PARTE 1: VERIFICAÇÕES DE CONFIGURAÇÃO GERAL
-- ================================================================

-- 1.1. Informações de timezone
SELECT 
    '=== CONFIGURAÇÕES DE TIMEZONE ===' as section,
    current_setting('timezone') as current_timezone,
    NOW() as utc_now,
    NOW() AT TIME ZONE 'America/Sao_Paulo' as sao_paulo_time,
    CURRENT_DATE as current_date,
    DATE(NOW() AT TIME ZONE 'America/Sao_Paulo') as sao_paulo_date;

-- 1.2. Verificar versão do PostgreSQL
SELECT 
    '=== INFORMAÇÕES DO BANCO ===' as section,
    version() as postgresql_version,
    current_database() as database_name,
    current_user as current_user;

-- ================================================================
-- PARTE 2: VERIFICAÇÃO DE ESTRUTURA DAS TABELAS
-- ================================================================

-- 2.1. Listar todas as tabelas principais
SELECT 
    '=== TABELAS EXISTENTES ===' as section,
    table_name,
    CASE 
        WHEN table_name IN ('challenge_check_ins', 'challenge_progress', 'challenges', 'profiles', 'user_progress') 
        THEN '✅ PRINCIPAL'
        ELSE '📋 OUTRAS'
    END as importance
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY importance, table_name;

-- 2.2. Estrutura da tabela challenge_check_ins
SELECT 
    '=== ESTRUTURA: challenge_check_ins ===' as section,
    column_name,
    data_type,
    is_nullable,
    column_default,
    CASE 
        WHEN column_name IN ('check_in_date', 'created_at', 'user_id', 'challenge_id') 
        THEN '🔑 CRÍTICA'
        ELSE '📝 NORMAL'
    END as importance
FROM information_schema.columns 
WHERE table_name = 'challenge_check_ins' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2.3. Estrutura da tabela challenge_progress
SELECT 
    '=== ESTRUTURA: challenge_progress ===' as section,
    column_name,
    data_type,
    is_nullable,
    column_default,
    CASE 
        WHEN column_name IN ('last_check_in', 'consecutive_days', 'user_id', 'challenge_id') 
        THEN '🔑 CRÍTICA'
        ELSE '📝 NORMAL'
    END as importance
FROM information_schema.columns 
WHERE table_name = 'challenge_progress' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2.4. Verificar índices existentes
SELECT 
    '=== ÍNDICES EXISTENTES ===' as section,
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('challenge_check_ins', 'challenge_progress')
ORDER BY tablename, indexname;

-- ================================================================
-- PARTE 3: VERIFICAÇÃO DE FUNÇÕES
-- ================================================================

-- 3.1. Listar funções relacionadas a check-ins
SELECT 
    '=== FUNÇÕES EXISTENTES ===' as section,
    routine_name,
    routine_type,
    CASE 
        WHEN routine_name LIKE '%check_in%' THEN '🎯 CHECK-IN'
        WHEN routine_name LIKE '%challenge%' THEN '🏆 CHALLENGE'
        ELSE '📋 OUTRAS'
    END as category
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND (routine_name LIKE '%check_in%' OR routine_name LIKE '%challenge%')
ORDER BY category, routine_name;

-- 3.2. Verificar assinatura da função record_challenge_check_in_v2
SELECT 
    '=== ASSINATURA: record_challenge_check_in_v2 ===' as section,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'record_challenge_check_in_v2';

-- 3.3. Verificar outras versões da função
SELECT 
    '=== TODAS AS VERSÕES DE CHECK-IN ===' as section,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    p.prokind as function_kind
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname LIKE '%check_in%'
ORDER BY p.proname;

-- ================================================================
-- PARTE 4: VERIFICAÇÃO DE DADOS EXISTENTES
-- ================================================================

-- 4.1. Estatísticas das tabelas principais
SELECT 
    '=== ESTATÍSTICAS DE DADOS ===' as section,
    'challenge_check_ins' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT challenge_id) as unique_challenges,
    MIN(check_in_date) as oldest_check_in,
    MAX(check_in_date) as newest_check_in
FROM challenge_check_ins
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins')

UNION ALL

SELECT 
    '=== ESTATÍSTICAS DE DADOS ===' as section,
    'challenge_progress' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT challenge_id) as unique_challenges,
    MIN(last_check_in) as oldest_check_in,
    MAX(last_check_in) as newest_check_in
FROM challenge_progress
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_progress')

UNION ALL

SELECT 
    '=== ESTATÍSTICAS DE DADOS ===' as section,
    'challenges' as table_name,
    COUNT(*) as total_records,
    NULL as unique_users,
    COUNT(*) as unique_challenges,
    MIN(created_at) as oldest_check_in,
    MAX(created_at) as newest_check_in
FROM challenges
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenges');

-- 4.2. Exemplos de dados de check-ins recentes
SELECT 
    '=== EXEMPLOS: check-ins recentes ===' as section,
    id,
    workout_name,
    check_in_date,
    DATE(check_in_date) as check_in_day,
    created_at,
    DATE(created_at) as created_day,
    CASE 
        WHEN DATE(check_in_date) = DATE(created_at) THEN '✅ MESMO DIA'
        ELSE '⚠️ DIAS DIFERENTES'
    END as date_consistency
FROM challenge_check_ins
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins')
ORDER BY created_at DESC 
LIMIT 10;

-- 4.3. Verificar possíveis problemas de timezone
SELECT 
    '=== ANÁLISE DE TIMEZONE ===' as section,
    DATE(check_in_date) as check_in_day,
    DATE(created_at) as created_day,
    COUNT(*) as occurrences,
    CASE 
        WHEN DATE(check_in_date) = DATE(created_at) THEN '✅ CONSISTENTE'
        ELSE '⚠️ INCONSISTENTE'
    END as consistency_status
FROM challenge_check_ins
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins')
GROUP BY DATE(check_in_date), DATE(created_at)
ORDER BY occurrences DESC
LIMIT 20;

-- ================================================================
-- PARTE 5: VERIFICAÇÃO DE POLÍTICAS RLS
-- ================================================================

-- 5.1. Verificar status do RLS
SELECT 
    '=== STATUS ROW LEVEL SECURITY ===' as section,
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity THEN '🔒 HABILITADO'
        ELSE '🔓 DESABILITADO'
    END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('challenge_check_ins', 'challenge_progress', 'challenges', 'profiles', 'user_progress')
ORDER BY tablename;

-- 5.2. Listar políticas existentes
SELECT 
    '=== POLÍTICAS RLS EXISTENTES ===' as section,
    schemaname,
    tablename,
    policyname,
    cmd as command_type,
    CASE 
        WHEN cmd = 'SELECT' THEN '👁️ LEITURA'
        WHEN cmd = 'INSERT' THEN '➕ INSERÇÃO'
        WHEN cmd = 'UPDATE' THEN '✏️ ATUALIZAÇÃO'
        WHEN cmd = 'DELETE' THEN '🗑️ EXCLUSÃO'
        ELSE '❓ OUTROS'
    END as command_description
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('challenge_check_ins', 'challenge_progress', 'challenges', 'profiles', 'user_progress')
ORDER BY tablename, policyname;

-- ================================================================
-- PARTE 6: VERIFICAÇÃO DE TRIGGERS
-- ================================================================

-- 6.1. Listar triggers existentes
SELECT 
    '=== TRIGGERS EXISTENTES ===' as section,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    CASE 
        WHEN trigger_name LIKE '%updated_at%' THEN '⏰ TIMESTAMP'
        WHEN trigger_name LIKE '%ranking%' THEN '🏆 RANKING'
        ELSE '📋 OUTROS'
    END as trigger_type
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table IN ('challenge_check_ins', 'challenge_progress', 'challenges', 'profiles', 'user_progress')
ORDER BY event_object_table, trigger_name;

-- ================================================================
-- PARTE 7: PROBLEMAS POTENCIAIS IDENTIFICADOS
-- ================================================================

-- 7.1. Check-ins com datas inconsistentes (possível problema de timezone)
SELECT 
    '=== POSSÍVEIS PROBLEMAS DE TIMEZONE ===' as section,
    COUNT(*) as total_inconsistent,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM challenge_check_ins) as percentage_inconsistent
FROM challenge_check_ins 
WHERE DATE(check_in_date) != DATE(created_at)
AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins');

-- 7.2. Check-ins duplicados por usuário/desafio/data
SELECT 
    '=== POSSÍVEIS CHECK-INS DUPLICADOS ===' as section,
    user_id,
    challenge_id,
    DATE(check_in_date) as check_in_day,
    COUNT(*) as duplicate_count
FROM challenge_check_ins
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_check_ins')
GROUP BY user_id, challenge_id, DATE(check_in_date)
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- ================================================================
-- PARTE 8: RESUMO EXECUTIVO
-- ================================================================

-- 8.1. Resumo geral do diagnóstico
SELECT 
    '=== RESUMO EXECUTIVO ===' as section,
    'Diagnóstico concluído em ' || NOW()::text as completion_time,
    'Execute as correções apenas após revisar todos os resultados acima' as recommendation;

-- ================================================================
-- FIM DO DIAGNÓSTICO
-- ================================================================
-- 
-- PRÓXIMOS PASSOS:
-- 1. Revise todos os resultados acima
-- 2. Identifique quais alterações são realmente necessárias
-- 3. Execute apenas as correções específicas identificadas
-- 4. NUNCA execute alterações em massa sem entender o impacto
-- ================================================================ 