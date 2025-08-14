-- ================================================================
-- TESTE DA VERSÃO FINAL CORRIGIDA DAS FUNÇÕES STRIPE
-- Execute após sql/stripe_webhook_functions_final.sql
-- ================================================================

\echo '🔧 TESTANDO VERSÃO FINAL CORRIGIDA'
\echo '=================================='

-- 1. VERIFICAR ESTRUTURA DAS TABELAS
\echo ''
\echo '🔍 1. VERIFICANDO ESTRUTURA...'

-- Verificar se profiles existe e tem relação com auth.users
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') 
    THEN '✅ Tabela profiles encontrada'
    ELSE '❌ Tabela profiles não encontrada'
  END as status_profiles,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_progress_level') 
    THEN '✅ Tabela user_progress_level encontrada'
    ELSE '❌ Tabela user_progress_level não encontrada'
  END as status_user_progress_level;

-- Verificar se existe pelo menos um usuário válido
SELECT 
  COUNT(p.id) as profiles_count,
  COUNT(au.id) as auth_users_count,
  COUNT(CASE WHEN p.id = au.id THEN 1 END) as usuarios_sincronizados
FROM profiles p
FULL OUTER JOIN auth.users au ON au.id = p.id;

-- 2. CRIAR USUÁRIO DE TESTE SE NECESSÁRIO
\echo ''
\echo '👤 2. PREPARANDO USUÁRIO DE TESTE...'

-- Buscar um usuário real existente
DO $$
DECLARE
  test_email TEXT;
  test_user_id UUID;
BEGIN
  -- Tentar encontrar um usuário que existe em ambas as tabelas
  SELECT p.email, p.id INTO test_email, test_user_id
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email IS NOT NULL
  LIMIT 1;
  
  IF test_email IS NOT NULL THEN
    RAISE NOTICE 'Usuário de teste encontrado: % (ID: %)', test_email, test_user_id;
  ELSE
    RAISE NOTICE 'Nenhum usuário sincronizado encontrado. Criando usuário de teste...';
    
    -- Criar usuário de teste apenas em profiles (para simular problema)
    INSERT INTO profiles (
      id, 
      name, 
      email,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      'Teste Stripe Final',
      'teste.stripe.final@rayclub.com',
      NOW(),
      NOW()
    ) ON CONFLICT (email) DO NOTHING;
  END IF;
END $$;

-- 3. TESTAR A FUNÇÃO FINAL COM USUÁRIO REAL
\echo ''
\echo '🎯 3. TESTANDO FUNÇÃO FINAL...'

-- Testar com usuário real existente
DO $$
DECLARE
  test_email TEXT;
  test_result JSON;
BEGIN
  -- Buscar email de usuário real
  SELECT p.email INTO test_email
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email IS NOT NULL
  LIMIT 1;
  
  IF test_email IS NOT NULL THEN
    -- Testar com usuário real
    SELECT update_user_level_by_email(
      test_email,
      'expert',
      (NOW() + INTERVAL '30 days')::timestamp,
      'cus_test_final',
      'sub_test_final',
      'evt_test_final'
    ) INTO test_result;
    
    RAISE NOTICE 'Resultado para usuário real (%): %', test_email, test_result;
  ELSE
    RAISE NOTICE 'Nenhum usuário real encontrado para teste';
  END IF;
END $$;

-- 4. TESTAR COM USUÁRIO PENDENTE
\echo ''
\echo '⏳ 4. TESTANDO USUÁRIO PENDENTE...'

SELECT update_user_level_by_email(
  'pendente.final@rayclub.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp,
  'cus_pending_final',
  'sub_pending_final',
  'evt_pending_final'
) as resultado_pendente_final;

-- Verificar se foi salvo como pendente
SELECT 
  email,
  level,
  expires_at,
  stripe_customer_id,
  created_at
FROM pending_user_levels 
WHERE email = 'pendente.final@rayclub.com';

-- 5. VERIFICAR RESULTADOS
\echo ''
\echo '✅ 5. VERIFICANDO RESULTADOS...'

-- Listar usuários expert
SELECT 
  p.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features,
  CASE 
    WHEN upl.current_level = 'expert' THEN '✅ EXPERT'
    ELSE '❌ NÃO EXPERT'
  END as status_expert
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.created_at DESC;

-- Verificar logs de pagamento
SELECT 
  email,
  event_type,
  level_updated,
  status,
  error_message,
  stripe_customer_id,
  created_at
FROM payment_logs 
WHERE email LIKE '%final%' OR email LIKE '%teste%'
ORDER BY created_at DESC;

-- 6. TESTAR FUNÇÃO DE STATUS
\echo ''
\echo '🔍 6. TESTANDO CHECK STATUS...'

-- Testar com usuário que deve ser expert agora
DO $$
DECLARE
  test_email TEXT;
  status_result JSON;
BEGIN
  SELECT p.email INTO test_email
  FROM profiles p
  INNER JOIN user_progress_level upl ON p.id = upl.user_id
  WHERE upl.current_level = 'expert'
  LIMIT 1;
  
  IF test_email IS NOT NULL THEN
    SELECT check_payment_status(test_email) INTO status_result;
    RAISE NOTICE 'Status do usuário expert (%): %', test_email, status_result;
  END IF;
END $$;

-- 7. LIMPEZA
\echo ''
\echo '🧹 7. LIMPANDO DADOS DE TESTE...'

DELETE FROM payment_logs WHERE email LIKE '%final%' OR email LIKE '%teste%';
DELETE FROM user_progress_level WHERE user_id IN (
  SELECT id FROM profiles WHERE email LIKE '%final%' OR email LIKE '%teste%'
);
DELETE FROM pending_user_levels WHERE email LIKE '%final%' OR email LIKE '%teste%';
DELETE FROM profiles WHERE email LIKE '%final%' OR email LIKE '%teste%';

\echo ''
\echo '✅ TESTE FINAL CONCLUÍDO!'
\echo '========================='
\echo ''
\echo 'Se você viu mensagens com "success": true, a correção funcionou!'
\echo ''
\echo '📋 PRÓXIMOS PASSOS:'
\echo '1. ✅ Use a função para promover usuários reais'
\echo '2. ✅ Implemente o painel admin no app'
\echo '3. ✅ Configure o webhook do Stripe' 