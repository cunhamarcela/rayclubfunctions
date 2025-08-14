-- ================================================================
-- PROMOVER USUÁRIO REAL PARA EXPERT - SCRIPT IMEDIATO
-- Execute este comando para promover um usuário que já pagou
-- ================================================================

-- ⚠️  SUBSTITUA O EMAIL ABAIXO PELO EMAIL REAL DO CLIENTE ⚠️

-- Exemplo de uso (SUBSTITUA O EMAIL):
SELECT update_user_level_by_email(
  'EMAIL_REAL_DO_CLIENTE@AQUI.com',  -- 👈 MUDE AQUI
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp
) as resultado;

-- ================================================================
-- VERIFICAR SE A PROMOÇÃO FUNCIONOU:
-- ================================================================

SELECT 
  p.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features,
  CASE 
    WHEN upl.current_level = 'expert' THEN '✅ PROMOVIDO COM SUCESSO'
    ELSE '❌ AINDA NÃO É EXPERT'
  END as status_promocao
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'EMAIL_REAL_DO_CLIENTE@AQUI.com';  -- 👈 MUDE AQUI TAMBÉM

-- ================================================================
-- LISTAR TODOS OS USUÁRIOS EXPERT ATUAIS:
-- ================================================================

SELECT 
  p.email,
  p.name,
  upl.current_level,
  upl.level_expires_at,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN '🔄 Permanente'
    WHEN upl.level_expires_at > NOW() THEN '✅ Ativo'
    ELSE '❌ Expirado'
  END as status_acesso,
  upl.created_at as promovido_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.created_at DESC;

-- ================================================================
-- EXEMPLOS RÁPIDOS DE USO:
-- ================================================================

-- Promover com 30 dias:
-- SELECT update_user_level_by_email('cliente@email.com', 'expert', (NOW() + INTERVAL '30 days')::timestamp);

-- Promover permanente:
-- SELECT update_user_level_by_email('cliente@email.com', 'expert', NULL);

-- Reverter para básico:
-- SELECT update_user_level_by_email('ex-cliente@email.com', 'basic', NULL); 