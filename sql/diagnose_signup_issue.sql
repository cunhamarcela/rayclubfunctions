-- ================================================================
-- DIAGNÓSTICO COMPLETO DO PROBLEMA DE CADASTRO
-- Data: 2025-01-07 12:08
-- Objetivo: Identificar exatamente o que está causando o erro 500
-- ================================================================

-- VERIFICAÇÃO 1: TRIGGERS ATIVOS
SELECT 
  'TRIGGERS ATIVOS:' as check_type,
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation,
  trigger_schema
FROM information_schema.triggers 
WHERE trigger_name LIKE '%pending%' OR trigger_name LIKE '%stripe%'
ORDER BY trigger_name;

-- VERIFICAÇÃO 2: FUNÇÕES QUE PODEM ESTAR FALHANDO
SELECT 
  'FUNÇÕES RELACIONADAS:' as check_type,
  routine_name,
  routine_type,
  data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND (
    routine_name LIKE '%user_level%' OR 
    routine_name LIKE '%pending%' OR
    routine_name LIKE '%stripe%'
  )
ORDER BY routine_name;

-- VERIFICAÇÃO 3: TABELAS NECESSÁRIAS
SELECT 
  'TABELAS NECESSÁRIAS:' as check_type,
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND (
    table_name = 'pending_user_levels' OR
    table_name = 'payment_logs' OR
    table_name = 'user_progress_level' OR
    table_name = 'profiles'
  )
ORDER BY table_name;

-- VERIFICAÇÃO 4: CONSTRAINTS QUE PODEM ESTAR FALHANDO
SELECT 
  'CONSTRAINTS:' as check_type,
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public' 
  AND tc.table_name IN ('profiles', 'pending_user_levels', 'user_progress_level')
ORDER BY tc.table_name, tc.constraint_type;

-- VERIFICAÇÃO 5: ÚLTIMO TESTE DE CADASTRO
SELECT 
  'ÚLTIMOS PROFILES CRIADOS:' as check_type,
  id,
  email,
  full_name,
  created_at
FROM profiles 
ORDER BY created_at DESC 
LIMIT 5;

-- RESUMO DO DIAGNÓSTICO
SELECT 
  'DIAGNÓSTICO COMPLETO EXECUTADO EM: ' || NOW() as summary;
