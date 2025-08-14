-- ================================================================
-- TESTE DA VERSÃO CORRIGIDA DAS FUNÇÕES STRIPE
-- Execute após sql/stripe_webhook_functions_fixed.sql
-- ================================================================

\echo '🔧 TESTANDO VERSÃO CORRIGIDA DO STRIPE'
\echo '======================================'

-- 1. CRIAR USUÁRIO DE TESTE NA TABELA PROFILES
\echo ''
\echo '👤 1. CRIANDO USUÁRIO DE TESTE...'

-- Primeiro vamos verificar se a tabela profiles existe
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') 
    THEN '✅ Tabela profiles encontrada'
    ELSE '❌ Tabela profiles não encontrada'
  END as status_profiles;

-- Criar usuário de teste na tabela profiles
INSERT INTO profiles (
  id, 
  name, 
  email,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'Teste Stripe',
  'teste.stripe.corrigido@rayclub.com',
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- 2. TESTAR A FUNÇÃO CORRIGIDA
\echo ''
\echo '🎯 2. TESTANDO FUNÇÃO CORRIGIDA...'

SELECT update_user_level_by_email(
  'teste.stripe.corrigido@rayclub.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp,
  'cus_test_corrigido',
  'sub_test_corrigido',
  'evt_test_corrigido'
) as resultado_corrigido;

-- 3. VERIFICAR SE FUNCIONOU
\echo ''
\echo '✅ 3. VERIFICANDO RESULTADO...'

SELECT 
  p.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features,
  upl.unlocked_features
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'teste.stripe.corrigido@rayclub.com';

-- 4. VERIFICAR LOGS
\echo ''
\echo '📊 4. VERIFICANDO LOGS...'

SELECT 
  email,
  event_type,
  level_updated,
  status,
  error_message,
  stripe_customer_id,
  created_at
FROM payment_logs 
WHERE email = 'teste.stripe.corrigido@rayclub.com'
ORDER BY created_at DESC;

-- 5. TESTAR FUNÇÃO DE STATUS
\echo ''
\echo '🔍 5. TESTANDO CHECK STATUS...'

SELECT check_payment_status('teste.stripe.corrigido@rayclub.com') as status_corrigido;

-- 6. TESTAR USUÁRIO PENDENTE
\echo ''
\echo '⏳ 6. TESTANDO USUÁRIO PENDENTE...'

SELECT update_user_level_by_email(
  'pendente.corrigido@rayclub.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp,
  'cus_pending_corrigido',
  'sub_pending_corrigido',
  'evt_pending_corrigido'
) as resultado_pendente_corrigido;

-- Verificar se foi salvo como pendente
SELECT 
  email,
  level,
  expires_at,
  stripe_customer_id,
  created_at
FROM pending_user_levels 
WHERE email = 'pendente.corrigido@rayclub.com';

-- 7. SIMULAR CADASTRO DO USUÁRIO PENDENTE
\echo ''
\echo '🔄 7. SIMULANDO CADASTRO DE USUÁRIO PENDENTE...'

-- Inserir o usuário "pendente" na tabela profiles para acionar o trigger
INSERT INTO profiles (
  id, 
  name, 
  email,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'Usuário Pendente',
  'pendente.corrigido@rayclub.com',
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- Verificar se o trigger processou automaticamente
SELECT 
  p.email,
  upl.current_level,
  upl.level_expires_at,
  CASE 
    WHEN upl.current_level = 'expert' THEN '✅ TRIGGER FUNCIONOU'
    ELSE '❌ TRIGGER NÃO FUNCIONOU'
  END as trigger_status
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'pendente.corrigido@rayclub.com';

-- 8. LIMPEZA
\echo ''
\echo '🧹 8. LIMPANDO DADOS DE TESTE...'

DELETE FROM payment_logs WHERE email IN ('teste.stripe.corrigido@rayclub.com', 'pendente.corrigido@rayclub.com');
DELETE FROM user_progress_level WHERE user_id IN (
  SELECT id FROM profiles WHERE email IN ('teste.stripe.corrigido@rayclub.com', 'pendente.corrigido@rayclub.com')
);
DELETE FROM pending_user_levels WHERE email IN ('teste.stripe.corrigido@rayclub.com', 'pendente.corrigido@rayclub.com');
DELETE FROM profiles WHERE email IN ('teste.stripe.corrigido@rayclub.com', 'pendente.corrigido@rayclub.com');

\echo ''
\echo '✅ TESTE CORRIGIDO CONCLUÍDO!'
\echo '============================'
\echo ''
\echo 'Se todos os resultados mostraram success: true, a correção funcionou!'
\echo ''
\echo '📋 PRÓXIMOS PASSOS:'
\echo '1. ✅ Usar o painel admin no app para promover usuários'
\echo '2. ✅ Deploy da Edge Function'
\echo '3. ✅ Configurar webhook no Stripe' 