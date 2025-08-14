-- ================================================================
-- TESTE DA VERSÃO FINAL DEFINITIVA
-- Execute APÓS sql/stripe_webhook_functions_final_clean.sql
-- ================================================================

-- 1. VERIFICAR SE AS FUNÇÕES ANTIGAS FORAM REMOVIDAS
SELECT 'Verificando remoção das funções antigas...' as status;

SELECT 
  COUNT(*) as funcoes_antigas_restantes,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ TODAS REMOVIDAS'
    ELSE '❌ AINDA EXISTEM FUNÇÕES ANTIGAS'
  END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name = 'update_user_level_by_email';

-- 2. VERIFICAR SE AS NOVAS FUNÇÕES FORAM CRIADAS
SELECT 'Verificando novas funções...' as status;

SELECT 
  routine_name as funcao,
  COUNT(*) as versoes,
  CASE 
    WHEN COUNT(*) = 1 THEN '✅ ÚNICA VERSÃO'
    ELSE '❌ MÚLTIPLAS VERSÕES'
  END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('stripe_update_user_level', 'stripe_check_payment_status')
GROUP BY routine_name
ORDER BY routine_name;

-- 3. ENCONTRAR UM USUÁRIO REAL PARA TESTE
SELECT 'Buscando usuário real...' as info;

SELECT 
  p.email,
  'Copie este email para usar no teste abaixo ↓' as instrucao
FROM profiles p
INNER JOIN auth.users au ON au.id = p.id
WHERE p.email IS NOT NULL
LIMIT 1;

-- 4. TESTE DA NOVA FUNÇÃO
SELECT 'Testando nova função stripe_update_user_level...' as info;

-- SUBSTITUA o email abaixo pelo encontrado acima
SELECT stripe_update_user_level(
  'SUBSTITUA_PELO_EMAIL_ENCONTRADO',  -- ← Cole o email real aqui
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp with time zone
) as resultado_teste;

-- 5. VERIFICAR SE O USUÁRIO FOI PROMOVIDO
SELECT 'Verificando se a promoção funcionou...' as info;

SELECT 
  p.email,
  upl.current_level,
  to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI') as expira_em,
  array_length(upl.unlocked_features, 1) as features_total,
  upl.unlocked_features
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'SUBSTITUA_PELO_EMAIL_ENCONTRADO'  -- ← Mesmo email aqui
LIMIT 1;

-- 6. VERIFICAR LOGS DE PAGAMENTO
SELECT 'Logs de pagamento criados...' as info;

SELECT 
  email,
  level_updated,
  status,
  COALESCE(error_message, 'Sem erro') as erro,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as criado_em
FROM payment_logs 
ORDER BY created_at DESC
LIMIT 3;

-- 7. TESTE DA FUNÇÃO DE STATUS
SELECT 'Testando função de status...' as info;

SELECT stripe_check_payment_status('SUBSTITUA_PELO_EMAIL_ENCONTRADO') as status_completo;

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email = 'SUBSTITUA_PELO_EMAIL_ENCONTRADO'
        AND upl.current_level = 'expert'
    ) THEN '🎉 SUCESSO TOTAL! Sistema Stripe funcionando!'
    ELSE '⚠️ Sistema criado mas teste não foi completo'
  END as resultado_final; 