-- =====================================================
-- VERIFICAR ESTRUTURA REAL DAS TABELAS
-- =====================================================
-- Este script verifica a estrutura das tabelas para identificar
-- os nomes corretos das colunas antes de aplicar correções

-- =====================================================
-- PARTE 1: ESTRUTURA DA TABELA workout_records
-- =====================================================

SELECT 
    '=== ESTRUTURA workout_records ===' as section,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_records' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- =====================================================
-- PARTE 2: ESTRUTURA DA TABELA challenge_check_ins
-- =====================================================

SELECT 
    '=== ESTRUTURA challenge_check_ins ===' as section,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenge_check_ins' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- =====================================================
-- PARTE 3: VERIFICAR CONSTRAINTS E ÍNDICES
-- =====================================================

-- Verificar constraints das tabelas
SELECT 
    '=== CONSTRAINTS workout_records ===' as section,
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'workout_records'
AND table_schema = 'public';

SELECT 
    '=== CONSTRAINTS challenge_check_ins ===' as section,
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'challenge_check_ins'
AND table_schema = 'public';

-- =====================================================
-- PARTE 4: VERIFICAR FUNÇÕES EXISTENTES
-- =====================================================

-- Listar funções relacionadas a workout
SELECT 
    '=== FUNÇÕES RELACIONADAS A WORKOUT ===' as section,
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name ILIKE '%workout%'
ORDER BY routine_name;

-- Listar funções relacionadas a challenge
SELECT 
    '=== FUNÇÕES RELACIONADAS A CHALLENGE ===' as section,
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name ILIKE '%challenge%'
ORDER BY routine_name;

-- =====================================================
-- PARTE 5: AMOSTRA DE DADOS DAS TABELAS
-- =====================================================

-- Mostrar algumas linhas de workout_records para entender a estrutura
SELECT 
    '=== AMOSTRA workout_records ===' as section;

SELECT * 
FROM workout_records 
LIMIT 3;

-- Mostrar algumas linhas de challenge_check_ins para entender a estrutura
SELECT 
    '=== AMOSTRA challenge_check_ins ===' as section;

SELECT * 
FROM challenge_check_ins 
LIMIT 3;

-- =====================================================
-- PARTE 6: VERIFICAR TIMEZONE ATUAL
-- =====================================================

SELECT 
    '=== CONFIGURAÇÃO ATUAL ===' as section,
    current_setting('timezone') as timezone_atual,
    NOW() as utc_now,
    NOW() AT TIME ZONE 'America/Sao_Paulo' as sao_paulo_now,
    CURRENT_DATE as current_date,
    DATE(NOW() AT TIME ZONE 'America/Sao_Paulo') as sao_paulo_date; 