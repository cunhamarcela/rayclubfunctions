-- ================================================================
-- EXEMPLO SIMPLES: COMO PROMOVER CLIENTES STRIPE PARA EXPERT
-- Use após executar sql/stripe_webhook_functions_clean.sql
-- ================================================================

-- PASSO 1: PROMOVER UM CLIENTE ESPECÍFICO
-- Substitua o email pelo cliente real que comprou no Stripe

SELECT update_user_level_by_email(
  'cliente@exemplo.com',                              -- ← Email do cliente que comprou
  'expert',                                           -- Nível expert
  (NOW() + INTERVAL '30 days')::timestamp            -- Expira em 30 dias
) as resultado_promocao;

-- ================================================================
-- DIFERENTES OPÇÕES DE TEMPO:
-- ================================================================

-- Para assinatura mensal:
/*
SELECT update_user_level_by_email(
  'cliente@exemplo.com',
  'expert',
  (NOW() + INTERVAL '1 month')::timestamp
);
*/

-- Para assinatura anual:
/*
SELECT update_user_level_by_email(
  'cliente@exemplo.com',
  'expert',
  (NOW() + INTERVAL '1 year')::timestamp
);
*/

-- Para acesso vitalício (nunca expira):
/*
SELECT update_user_level_by_email(
  'cliente@exemplo.com',
  'expert',
  NULL
);
*/

-- ================================================================
-- VERIFICAR SE DEU CERTO:
-- ================================================================

-- Verificar status do cliente após promoção:
SELECT check_payment_status('cliente@exemplo.com') as status_cliente;

-- ================================================================
-- VER TODOS OS USUÁRIOS EXPERT:
-- ================================================================

SELECT 
  p.email,
  upl.current_level,
  to_char(upl.level_expires_at, 'DD/MM/YYYY') as expira_em,
  array_length(upl.unlocked_features, 1) as features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as promovido_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.updated_at DESC;

-- ================================================================
-- TEMPLATE PARA COPIAR E COLAR:
-- ================================================================

/*
-- Cole isto e substitua apenas o email:

SELECT update_user_level_by_email(
  'EMAIL_DO_CLIENTE_AQUI',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp
) as resultado;

-- Verificar se deu certo:
SELECT check_payment_status('EMAIL_DO_CLIENTE_AQUI') as status;
*/ 