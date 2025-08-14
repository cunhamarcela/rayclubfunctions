-- ================================================================
-- TESTE: USUÁRIO NOVO QUE COMPROU NO STRIPE (MAS AINDA NÃO SE REGISTROU)
-- Este teste simula um cenário real do Stripe webhook
-- ================================================================

-- CENÁRIO: Cliente comprou no Stripe mas ainda não criou conta no app

-- 1. SIMULAR PAGAMENTO DE CLIENTE QUE NÃO EXISTE AINDA
SELECT 'Simulando pagamento Stripe de cliente novo...' as teste;

SELECT stripe_update_user_level(
  'cliente.novo@stripe.com',                          -- Email que NÃO existe no sistema
  'expert',                                           -- Nível expert
  (NOW() + INTERVAL '30 days')::timestamp with time zone,  -- 30 dias
  'cus_stripe_12345',                                 -- Customer ID do Stripe
  'sub_stripe_67890',                                 -- Subscription ID do Stripe  
  'evt_stripe_webhook_001'                            -- Event ID do webhook
) as resultado_pagamento_pendente;

-- 2. VERIFICAR SE FOI SALVO COMO PENDENTE
SELECT 'Verificando se foi salvo na tabela de pendentes...' as info;

SELECT 
  email,
  level,
  to_char(expires_at, 'DD/MM/YYYY HH24:MI') as expira_em,
  stripe_customer_id,
  stripe_subscription_id,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as criado_em
FROM pending_user_levels
WHERE email = 'cliente.novo@stripe.com';

-- 3. VERIFICAR LOG DE PAGAMENTO
SELECT 'Log do pagamento criado...' as info;

SELECT 
  email,
  level_updated,
  status,
  stripe_customer_id,
  stripe_subscription_id,
  stripe_event_id,
  error_message,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as processado_em
FROM payment_logs
WHERE email = 'cliente.novo@stripe.com'
ORDER BY created_at DESC;

-- 4. SIMULAR MAIS ALGUNS PAGAMENTOS STRIPE PENDENTES
SELECT 'Simulando mais pagamentos Stripe...' as info;

-- Cliente 2: Assinatura anual
SELECT stripe_update_user_level(
  'cliente2@stripe.com',
  'expert',
  (NOW() + INTERVAL '1 year')::timestamp with time zone,
  'cus_stripe_22222',
  'sub_stripe_annual_001'
) as pagamento_anual;

-- Cliente 3: Acesso vitalício 
SELECT stripe_update_user_level(
  'cliente3@stripe.com',
  'expert',
  NULL,  -- Nunca expira
  'cus_stripe_33333',
  'sub_stripe_lifetime_001'
) as pagamento_vitalicio;

-- 5. VER TODOS OS PAGAMENTOS PENDENTES
SELECT 'Todos os pagamentos pendentes aguardando registro...' as info;

SELECT 
  email,
  level,
  CASE 
    WHEN expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(expires_at, 'DD/MM/YYYY')
  END as tipo_assinatura,
  stripe_customer_id,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as pagamento_em
FROM pending_user_levels
ORDER BY created_at DESC;

-- 6. VER TODOS OS LOGS DE PAGAMENTO STRIPE
SELECT 'Histórico completo de pagamentos Stripe...' as info;

SELECT 
  email,
  level_updated,
  status,
  stripe_customer_id,
  stripe_event_id,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as processado_em,
  COALESCE(error_message, 'Sucesso') as resultado
FROM payment_logs
WHERE stripe_customer_id IS NOT NULL
ORDER BY created_at DESC;

-- ================================================================
-- RESULTADO ESPERADO:
-- ================================================================

SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM pending_user_levels WHERE email LIKE '%@stripe.com') 
    THEN '🎉 SUCESSO! Pagamentos Stripe salvos como pendentes!'
    ELSE '❌ Erro: Pagamentos não foram salvos'
  END as resultado_teste;

-- ================================================================
-- PRÓXIMO PASSO: 
-- ================================================================

/*
AGORA SIMULE O CLIENTE SE REGISTRANDO NO APP:

1. Vá no seu app Flutter
2. Registre um novo usuário com email: cliente.novo@stripe.com  
3. O trigger automático vai processar o pagamento pendente
4. O usuário será automaticamente promovido para expert!

OU execute o próximo script: teste_registro_usuario.sql
*/ 