-- ================================================================
-- TESTE: SIMULAR REGISTRO DE USUÁRIO COM PAGAMENTO STRIPE PENDENTE
-- Execute APÓS scripts/teste_usuario_novo_stripe.sql
-- ================================================================

-- CENÁRIO: Cliente que comprou no Stripe agora se registra no app
-- O trigger deve automaticamente promover ele para expert

-- 1. VERIFICAR PAGAMENTOS PENDENTES ANTES DO REGISTRO
SELECT 'Pagamentos pendentes antes do registro...' as info;

SELECT 
  email,
  level,
  CASE 
    WHEN expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  stripe_customer_id
FROM pending_user_levels
WHERE email = 'cliente.novo@stripe.com';

-- 2. SIMULAR CRIAÇÃO DO USUÁRIO NA TABELA profiles
-- (Normalmente isso acontece quando o usuário se registra no app)
SELECT 'Simulando registro do usuário no app...' as acao;

-- Primeiro, criar na tabela auth.users (simulando Supabase Auth)
-- NOTA: Em produção, isso é feito automaticamente pelo Supabase
INSERT INTO auth.users (
  id, 
  email, 
  created_at, 
  updated_at,
  email_confirmed_at,
  confirmation_sent_at
) VALUES (
  gen_random_uuid(),
  'cliente.novo@stripe.com',
  NOW(),
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- Agora criar na tabela profiles (isso dispara o trigger!)
INSERT INTO profiles (
  id,
  email,
  created_at,
  updated_at
) 
SELECT 
  au.id,
  'cliente.novo@stripe.com',
  NOW(),
  NOW()
FROM auth.users au 
WHERE au.email = 'cliente.novo@stripe.com'
ON CONFLICT (email) DO NOTHING;

-- 3. AGUARDAR UM MOMENTO PARA O TRIGGER PROCESSAR
SELECT 'Trigger executado! Verificando resultados...' as status;

-- 4. VERIFICAR SE O USUÁRIO FOI PROMOVIDO AUTOMATICAMENTE
SELECT 'Status do usuário após registro...' as info;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Nunca expira'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as total_features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as promovido_em
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'cliente.novo@stripe.com';

-- 5. VERIFICAR SE FOI REMOVIDO DA TABELA DE PENDENTES
SELECT 'Verificando se foi removido dos pendentes...' as info;

SELECT 
  COUNT(*) as usuarios_pendentes_restantes,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ Removido dos pendentes (correto!)'
    ELSE '❌ Ainda está na tabela de pendentes'
  END as status
FROM pending_user_levels
WHERE email = 'cliente.novo@stripe.com';

-- 6. VERIFICAR LOGS DE PAGAMENTO ATUALIZADOS
SELECT 'Logs de pagamento atualizados...' as info;

SELECT 
  email,
  level_updated,
  status,
  stripe_customer_id,
  stripe_event_id,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as criado_em,
  to_char(updated_at, 'DD/MM/YYYY HH24:MI') as atualizado_em,
  COALESCE(error_message, 'Sem erro') as resultado
FROM payment_logs
WHERE email = 'cliente.novo@stripe.com'
ORDER BY created_at DESC;

-- 7. TESTAR FUNÇÃO DE STATUS
SELECT 'Status completo do cliente...' as info;

SELECT stripe_check_payment_status('cliente.novo@stripe.com') as status_completo;

-- ================================================================
-- RESULTADO ESPERADO DO TRIGGER AUTOMÁTICO:
-- ================================================================

SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email = 'cliente.novo@stripe.com'
        AND upl.current_level = 'expert'
    ) THEN '🎉 TRIGGER FUNCIONOU! Usuário automaticamente promovido!'
    ELSE '❌ Trigger falhou - usuário não foi promovido automaticamente'
  END as resultado_trigger;

-- ================================================================
-- TESTE ADICIONAL: SIMULAR MAIS REGISTROS
-- ================================================================

-- Registrar cliente2 (assinatura anual)
INSERT INTO auth.users (id, email, created_at, updated_at, email_confirmed_at)
VALUES (gen_random_uuid(), 'cliente2@stripe.com', NOW(), NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

INSERT INTO profiles (id, email, created_at, updated_at)
SELECT au.id, 'cliente2@stripe.com', NOW(), NOW()
FROM auth.users au WHERE au.email = 'cliente2@stripe.com'
ON CONFLICT (email) DO NOTHING;

-- Registrar cliente3 (vitalício)
INSERT INTO auth.users (id, email, created_at, updated_at, email_confirmed_at)
VALUES (gen_random_uuid(), 'cliente3@stripe.com', NOW(), NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

INSERT INTO profiles (id, email, created_at, updated_at)
SELECT au.id, 'cliente3@stripe.com', NOW(), NOW()
FROM auth.users au WHERE au.email = 'cliente3@stripe.com'
ON CONFLICT (email) DO NOTHING;

-- 8. VER TODOS OS USUÁRIOS EXPERT AGORA
SELECT 'Todos os usuários Expert (incluindo os novos)...' as final_info;

SELECT 
  p.email,
  upl.current_level,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY')
  END as tipo_assinatura,
  array_length(upl.unlocked_features, 1) as features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as promovido_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.updated_at DESC; 