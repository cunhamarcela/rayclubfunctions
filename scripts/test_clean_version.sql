-- ================================================================
-- TESTE SIMPLES DA VERSÃO LIMPA
-- Execute APÓS sql/stripe_webhook_functions_clean.sql
-- ================================================================

-- 1. VERIFICAR SE CADA FUNÇÃO TEM APENAS 1 VERSÃO
SELECT 'Verificando versões das funções...' as status;

SELECT 
  routine_name as funcao,
  COUNT(*) as total_versoes,
  CASE 
    WHEN COUNT(*) = 1 THEN '✅ ÚNICA VERSÃO'
    ELSE '❌ MÚLTIPLAS VERSÕES'
  END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'update_user_level_by_email',
    'check_payment_status',
    'process_pending_user_levels',
    'trigger_process_pending_users',
    'cleanup_old_payment_logs'
  )
GROUP BY routine_name
ORDER BY routine_name;

-- 2. TESTE SIMPLES - ENCONTRAR UM USUÁRIO REAL
SELECT 'Buscando usuário real para teste...' as info;

-- Buscar um usuário que existe em ambas as tabelas
SELECT 
  p.email,
  '← Este usuário será usado no teste' as info
FROM profiles p
INNER JOIN auth.users au ON au.id = p.id
WHERE p.email IS NOT NULL
LIMIT 1;

-- 3. TESTE DA FUNÇÃO (substitua o email)
SELECT 'Testando função com usuário real...' as info;

-- SUBSTITUA 'test@example.com' pelo email encontrado acima
SELECT update_user_level_by_email(
  'test@example.com',  -- ← SUBSTITUA pelo email real encontrado acima
  'expert'::text,
  (NOW() + INTERVAL '30 days')::timestamp with time zone
) as resultado_teste;

-- 4. VERIFICAR SE O USUÁRIO FOI PROMOVIDO
SELECT 'Verificando se a promoção funcionou...' as info;

SELECT 
  p.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'test@example.com'  -- ← SUBSTITUA pelo mesmo email
LIMIT 1;

-- 5. VERIFICAR LOGS DE PAGAMENTO
SELECT 'Logs de pagamento criados...' as info;

SELECT 
  email,
  level_updated,
  status,
  error_message,
  created_at
FROM payment_logs 
ORDER BY created_at DESC
LIMIT 3;

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email = 'test@example.com'  -- ← SUBSTITUA pelo mesmo email
        AND upl.current_level = 'expert'
    ) THEN '🎉 SUCESSO! Usuário promovido para EXPERT!'
    ELSE '⚠️ Teste não completou - verifique os logs'
  END as resultado_final; 