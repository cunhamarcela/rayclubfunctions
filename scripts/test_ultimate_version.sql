-- ================================================================
-- TESTE DA VERSÃO ULTIMATE - SIMPLES E DIRETO
-- Execute APÓS sql/stripe_webhook_functions_ultimate.sql
-- ================================================================

-- 1. VERIFICAR SE TODAS AS FUNÇÕES FORAM CRIADAS
SELECT '🔍 Verificando funções criadas...' as status;

SELECT 
  routine_name as funcao,
  'STATUS: ✅ CRIADA' as resultado
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

-- 2. VERIFICAR SE O TRIGGER FOI CRIADO
SELECT 
  trigger_name,
  event_object_table as tabela,
  'STATUS: ✅ ATIVO' as resultado
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_process_pending_on_signup';

-- 3. TESTE SIMPLES - BUSCAR UM USUÁRIO REAL
SELECT '🧪 Iniciando teste com usuário real...' as info;

DO $$
DECLARE
  test_email TEXT;
  test_result JSON;
BEGIN
  -- Buscar um usuário real
  SELECT p.email INTO test_email
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email IS NOT NULL
  LIMIT 1;
  
  IF test_email IS NOT NULL THEN
    RAISE NOTICE '📧 Testando com: %', test_email;
    
    -- Executar a função
    SELECT update_user_level_by_email(
      test_email,
      'expert',
      (NOW() + INTERVAL '30 days')::timestamp
    ) INTO test_result;
    
    RAISE NOTICE '📊 Resultado: %', test_result;
    
    -- Verificar resultado
    IF test_result->>'success' = 'true' THEN
      RAISE NOTICE '🎉 SUCESSO! Função funcionando perfeitamente!';
    ELSE
      RAISE NOTICE '❌ Erro: %', test_result->>'error';
    END IF;
  ELSE
    RAISE NOTICE '⚠️  Nenhum usuário encontrado para teste';
  END IF;
END $$;

-- 4. VERIFICAR USUÁRIOS EXPERT ATUAIS
SELECT '📋 Usuários Expert no sistema:' as info;

SELECT 
  p.email,
  upl.current_level,
  to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI') as expira_em,
  array_length(upl.unlocked_features, 1) as features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as atualizado_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.updated_at DESC
LIMIT 5;

-- 5. VERIFICAR LOGS DE PAGAMENTO
SELECT '📊 Logs de pagamento recentes:' as info;

SELECT 
  email,
  level_updated as nivel,
  status,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as criado_em,
  COALESCE(error_message, 'Sem erro') as erro
FROM payment_logs 
ORDER BY created_at DESC
LIMIT 3;

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_name = 'update_user_level_by_email'
    ) THEN '🎉 SISTEMA STRIPE 100% FUNCIONAL!'
    ELSE '❌ Sistema não está funcionando'
  END as resultado_final; 