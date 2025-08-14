-- ================================================================
-- TESTE RÁPIDO DAS NOVAS FUNÇÕES STRIPE
-- Execute após sql/stripe_webhook_functions_final_fixed.sql
-- ================================================================

-- 1. VERIFICAR SE AS FUNÇÕES FORAM CRIADAS
SELECT 'Verificando funções criadas...' as status;

SELECT 
  routine_name as funcao_criada,
  '✅ OK' as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'update_user_level_by_email',
    'check_payment_status',
    'process_pending_user_levels',
    'trigger_process_pending_users',
    'cleanup_old_payment_logs'
  )
ORDER BY routine_name;

-- 2. TESTE COM USUÁRIO REAL (se existir)
DO $$
DECLARE
  test_email TEXT;
  test_result JSON;
BEGIN
  -- Buscar um usuário real que existe em ambas as tabelas
  SELECT p.email INTO test_email
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email IS NOT NULL
  LIMIT 1;
  
  IF test_email IS NOT NULL THEN
    RAISE NOTICE '📧 Testando com usuário real: %', test_email;
    
    -- Testar a função
    SELECT update_user_level_by_email(
      test_email,
      'expert',
      (NOW() + INTERVAL '30 days')::timestamp
    ) INTO test_result;
    
    RAISE NOTICE '📊 Resultado: %', test_result;
    
    -- Verificar se deu certo
    IF test_result->>'success' = 'true' THEN
      RAISE NOTICE '🎉 SUCESSO! Função funcionando corretamente!';
    ELSE
      RAISE NOTICE '❌ Erro: %', test_result->>'error';
    END IF;
  ELSE
    RAISE NOTICE '⚠️  Nenhum usuário real encontrado para teste';
    RAISE NOTICE '💡 Testando com usuário pendente...';
    
    -- Testar com usuário que não existe (deve ir para pendentes)
    SELECT update_user_level_by_email(
      'teste.pendente@exemplo.com',
      'expert',
      (NOW() + INTERVAL '30 days')::timestamp
    ) INTO test_result;
    
    RAISE NOTICE '📊 Resultado pendente: %', test_result;
  END IF;
END $$;

-- 3. LISTAR USUÁRIOS EXPERT ATUAIS
SELECT 'Usuários Expert atuais:' as info;

SELECT 
  p.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as features_count,
  upl.created_at as promovido_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.created_at DESC;

-- 4. VERIFICAR LOGS DE PAGAMENTO
SELECT 'Logs de pagamento recentes:' as info;

SELECT 
  email,
  level_updated,
  status,
  error_message,
  created_at
FROM payment_logs 
ORDER BY created_at DESC
LIMIT 5;

-- 5. VERIFICAR USUÁRIOS PENDENTES
SELECT 'Usuários pendentes:' as info;

SELECT 
  email,
  level,
  expires_at,
  created_at
FROM pending_user_levels
ORDER BY created_at DESC;

SELECT '✅ TESTE CONCLUÍDO!' as final_status; 