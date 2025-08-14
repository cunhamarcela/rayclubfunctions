-- ================================================================
-- COMO USAR AS NOVAS FUNÇÕES PARA PROMOVER CLIENTES STRIPE
-- Use após executar sql/stripe_webhook_functions_final_clean.sql
-- ================================================================

-- ================================================================
-- EXEMPLO 1: PROMOVER UM CLIENTE ESPECÍFICO
-- ================================================================

-- Substitua o email pelo cliente real que comprou no Stripe
SELECT stripe_update_user_level(
  'cliente@exemplo.com',                              -- ← Email do cliente
  'expert',                                           -- Nível expert
  (NOW() + INTERVAL '30 days')::timestamp with time zone  -- Expira em 30 dias
) as resultado_promocao;

-- ================================================================
-- EXEMPLO 2: DIFERENTES TIPOS DE ASSINATURA
-- ================================================================

-- Assinatura mensal (30 dias):
/*
SELECT stripe_update_user_level(
  'cliente@exemplo.com',
  'expert',
  (NOW() + INTERVAL '1 month')::timestamp with time zone
);
*/

-- Assinatura trimestral (3 meses):
/*
SELECT stripe_update_user_level(
  'cliente@exemplo.com',
  'expert',
  (NOW() + INTERVAL '3 months')::timestamp with time zone
);
*/

-- Assinatura anual (1 ano):
/*
SELECT stripe_update_user_level(
  'cliente@exemplo.com',
  'expert',
  (NOW() + INTERVAL '1 year')::timestamp with time zone
);
*/

-- Acesso vitalício (nunca expira):
/*
SELECT stripe_update_user_level(
  'cliente@exemplo.com',
  'expert',
  NULL  -- NULL = nunca expira
);
*/

-- ================================================================
-- EXEMPLO 3: VERIFICAR SE DEU CERTO
-- ================================================================

-- Verificar status do cliente após promoção:
SELECT stripe_check_payment_status('cliente@exemplo.com') as status_do_cliente;

-- ================================================================
-- EXEMPLO 4: PROMOVER MÚLTIPLOS CLIENTES
-- ================================================================

/*
-- Descomente e ajuste os emails conforme necessário:

SELECT stripe_update_user_level('cliente1@exemplo.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp with time zone);
SELECT stripe_update_user_level('cliente2@exemplo.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp with time zone);
SELECT stripe_update_user_level('cliente3@exemplo.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp with time zone);
*/

-- ================================================================
-- EXEMPLO 5: VER TODOS OS USUÁRIOS EXPERT
-- ================================================================

SELECT 
  p.email,
  upl.current_level,
  to_char(upl.level_expires_at, 'DD/MM/YYYY') as expira_em,
  array_length(upl.unlocked_features, 1) as total_features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as promovido_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.updated_at DESC;

-- ================================================================
-- EXEMPLO 6: VER LOGS DE PAGAMENTOS RECENTES
-- ================================================================

SELECT 
  email,
  level_updated as nivel,
  status,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as processado_em,
  COALESCE(error_message, 'Sucesso') as resultado
FROM payment_logs 
ORDER BY created_at DESC
LIMIT 10;

-- ================================================================
-- TEMPLATE PRONTO PARA USAR
-- ================================================================

/*
-- COPIE E COLE ESTE TEMPLATE:

-- 1. Promover cliente:
SELECT stripe_update_user_level(
  'EMAIL_DO_CLIENTE_AQUI',                          -- ← Substitua pelo email real
  'expert',                                         -- Sempre 'expert'
  (NOW() + INTERVAL '30 days')::timestamp with time zone  -- ← Ajuste o período
) as resultado;

-- 2. Verificar se deu certo:
SELECT stripe_check_payment_status('EMAIL_DO_CLIENTE_AQUI') as status;

-- 3. Ver features desbloqueadas:
SELECT 
  p.email,
  upl.current_level,
  upl.unlocked_features
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'EMAIL_DO_CLIENTE_AQUI';
*/

-- ================================================================
-- DICAS IMPORTANTES:
-- ================================================================

/*
🔹 Use 'expert' para clientes que compraram acesso premium
🔹 Use (NOW() + INTERVAL '30 days') para assinatura mensal
🔹 Use (NOW() + INTERVAL '1 year') para assinatura anual  
🔹 Use NULL para acesso vitalício
🔹 A função cria logs automáticos de todas as operações
🔹 Se o usuário não existir, será salvo como "pendente"
🔹 Quando o usuário se registrar, receberá o acesso automaticamente
*/ 