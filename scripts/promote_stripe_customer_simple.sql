-- ================================================================
-- PROMOÇÃO MANUAL DE CLIENTES STRIPE PARA EXPERT
-- Use este script para promover usuários que compraram no Stripe
-- ================================================================

-- INSTRUÇÕES:
-- 1. Substitua 'email@cliente.com' pelo email real do cliente
-- 2. Ajuste a data de expiração se necessário (padrão: 30 dias)
-- 3. Execute no SQL Editor do Supabase

-- ================================================================
-- EXEMPLO DE USO:
-- ================================================================

-- PROMOVER UM CLIENTE ESPECÍFICO:
SELECT update_user_level_by_email(
  'email@cliente.com',              -- ← SUBSTITUA pelo email real
  'expert',                         -- Nível expert
  (NOW() + INTERVAL '30 days')::timestamp  -- Expira em 30 dias
) as resultado_promocao;

-- ================================================================
-- VERIFICAR SE DEU CERTO:
-- ================================================================

-- Ver o status do cliente após promoção:
SELECT check_payment_status('email@cliente.com') as status_cliente;  -- ← SUBSTITUA pelo email real

-- ================================================================
-- PROMOVER MÚLTIPLOS CLIENTES (EXEMPLO):
-- ================================================================

/*
-- Descomente e ajuste os emails conforme necessário:

SELECT update_user_level_by_email('cliente1@email.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp);
SELECT update_user_level_by_email('cliente2@email.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp);
SELECT update_user_level_by_email('cliente3@email.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp);
*/

-- ================================================================
-- LISTAR TODOS OS USUÁRIOS EXPERT ATUAIS:
-- ================================================================

SELECT 
  '📋 Usuários Expert atuais:' as info,
  '' as email,
  '' as level,
  '' as expires_at
UNION ALL
SELECT 
  '→',
  p.email,
  upl.current_level,
  to_char(upl.level_expires_at, 'DD/MM/YYYY') as expires_at
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY email DESC;

-- ================================================================
-- EXEMPLO COMPLETO COM CLIENTE STRIPE:
-- ================================================================

/*
-- Para um cliente que comprou uma assinatura anual:
SELECT update_user_level_by_email(
  'cliente@stripe.com',             -- Email do cliente
  'expert',                         -- Nível expert
  (NOW() + INTERVAL '1 year')::timestamp  -- Expira em 1 ano
);

-- Para um cliente que comprou acesso mensal:
SELECT update_user_level_by_email(
  'cliente@stripe.com',             -- Email do cliente
  'expert',                         -- Nível expert
  (NOW() + INTERVAL '1 month')::timestamp  -- Expira em 1 mês
);

-- Para acesso vitalício (sem expiração):
SELECT update_user_level_by_email(
  'cliente@stripe.com',             -- Email do cliente
  'expert',                         -- Nível expert
  NULL                              -- Nunca expira
);
*/

-- ================================================================
-- TEMPLATE PARA COPIAR E USAR:
-- ================================================================

/*
SELECT update_user_level_by_email(
  'DIGITE_O_EMAIL_AQUI',           -- ← Email do cliente
  'expert',                        -- Nível expert
  (NOW() + INTERVAL '30 days')::timestamp  -- ← Ajuste o período
) as resultado;
*/ 