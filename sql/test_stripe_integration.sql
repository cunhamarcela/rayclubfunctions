-- ================================================================
-- TESTE COMPLETO DA INTEGRAÇÃO STRIPE
-- Execute este script após instalar stripe_webhook_functions.sql
-- ================================================================

\echo '🧪 INICIANDO TESTES DA INTEGRAÇÃO STRIPE'
\echo '========================================'

-- 1. VERIFICAR SE TODAS AS TABELAS FORAM CRIADAS
\echo ''
\echo '📋 1. VERIFICANDO TABELAS...'

SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_logs') 
    THEN '✅ payment_logs'
    ELSE '❌ payment_logs FALTANDO'
  END as status_payment_logs,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pending_user_levels') 
    THEN '✅ pending_user_levels'
    ELSE '❌ pending_user_levels FALTANDO'
  END as status_pending_levels,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_progress_level') 
    THEN '✅ user_progress_level'
    ELSE '❌ user_progress_level FALTANDO'
  END as status_user_progress;

-- 2. VERIFICAR SE TODAS AS FUNÇÕES FORAM CRIADAS
\echo ''
\echo '🔧 2. VERIFICANDO FUNÇÕES...'

SELECT 
  routine_name as funcao,
  CASE 
    WHEN routine_name IS NOT NULL THEN '✅ CRIADA'
    ELSE '❌ FALTANDO'
  END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'update_user_level_by_email',
    'process_pending_user_levels',
    'check_payment_status',
    'trigger_process_pending_users',
    'cleanup_old_payment_logs'
  )
ORDER BY routine_name;

-- 3. TESTE DA FUNÇÃO PRINCIPAL (usuário fictício)
\echo ''
\echo '🎯 3. TESTANDO FUNÇÃO PRINCIPAL...'

-- Criar um usuário de teste
INSERT INTO auth.users (
  id, 
  email, 
  encrypted_password, 
  email_confirmed_at, 
  created_at, 
  updated_at
) VALUES (
  gen_random_uuid(),
  'teste.stripe@rayclub.com',
  crypt('senha123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- Testar promoção para expert
SELECT update_user_level_by_email(
  'teste.stripe@rayclub.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp,
  'cus_test123',
  'sub_test456',
  'evt_test789'
) as resultado_promocao;

-- 4. VERIFICAR SE A PROMOÇÃO FUNCIONOU
\echo ''
\echo '✅ 4. VERIFICANDO RESULTADO...'

SELECT 
  u.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features,
  upl.unlocked_features
FROM auth.users u
LEFT JOIN user_progress_level upl ON u.id = upl.user_id
WHERE u.email = 'teste.stripe@rayclub.com';

-- 5. VERIFICAR LOGS DE PAGAMENTO
\echo ''
\echo '📊 5. VERIFICANDO LOGS...'

SELECT 
  email,
  event_type,
  level_updated,
  status,
  stripe_customer_id,
  created_at
FROM payment_logs 
WHERE email = 'teste.stripe@rayclub.com'
ORDER BY created_at DESC;

-- 6. TESTAR USUÁRIO PENDENTE
\echo ''
\echo '⏳ 6. TESTANDO USUÁRIO PENDENTE...'

-- Simular usuário que comprou mas ainda não se cadastrou
SELECT update_user_level_by_email(
  'pendente@rayclub.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp,
  'cus_pending123',
  'sub_pending456',
  'evt_pending789'
) as resultado_pendente;

-- Verificar se foi salvo como pendente
SELECT 
  email,
  level,
  expires_at,
  stripe_customer_id,
  created_at
FROM pending_user_levels 
WHERE email = 'pendente@rayclub.com';

-- 7. TESTAR FUNÇÃO DE STATUS
\echo ''
\echo '🔍 7. TESTANDO VERIFICAÇÃO DE STATUS...'

SELECT check_payment_status('teste.stripe@rayclub.com') as status_completo;

-- 8. TESTAR PROCESSAMENTO DE PENDENTES
\echo ''
\echo '🔄 8. TESTANDO PROCESSAMENTO DE PENDENTES...'

SELECT process_pending_user_levels() as resultado_processamento;

-- 9. LIMPAR DADOS DE TESTE
\echo ''
\echo '🧹 9. LIMPANDO DADOS DE TESTE...'

-- Remover usuário de teste
DELETE FROM payment_logs WHERE email IN ('teste.stripe@rayclub.com', 'pendente@rayclub.com');
DELETE FROM user_progress_level WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN ('teste.stripe@rayclub.com', 'pendente@rayclub.com')
);
DELETE FROM pending_user_levels WHERE email IN ('teste.stripe@rayclub.com', 'pendente@rayclub.com');
DELETE FROM auth.users WHERE email IN ('teste.stripe@rayclub.com', 'pendente@rayclub.com');

\echo ''
\echo '✅ TESTE CONCLUÍDO!'
\echo '=================='
\echo ''
\echo 'Se todos os itens acima mostraram ✅, a integração está funcionando!'
\echo ''
\echo '📋 PRÓXIMOS PASSOS:'
\echo '1. Deploy da Edge Function: supabase functions deploy stripe-webhook'
\echo '2. Configurar variáveis de ambiente no Supabase'
\echo '3. Adicionar webhook no Stripe Dashboard'
\echo '4. Testar com compra real' 