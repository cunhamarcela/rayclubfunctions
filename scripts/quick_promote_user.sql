-- ================================================================
-- SCRIPT RÁPIDO PARA PROMOVER USUÁRIOS MANUALMENTE
-- Use este script para promover usuários que pagaram mas não foram
-- atualizados automaticamente (enquanto webhook não está ativo)
-- ================================================================

-- ⚠️  INSTRUÇÕES:
-- 1. Substitua 'EMAIL_DO_USUARIO' pelo email real do cliente
-- 2. Ajuste a data de expiração se necessário
-- 3. Execute no SQL Editor do Supabase

-- 🎯 PROMOVER USUÁRIO ESPECÍFICO
-- Substitua o email abaixo:
SELECT update_user_level_by_email(
  'EMAIL_DO_USUARIO_AQUI',  -- 👈 SUBSTITUA PELO EMAIL REAL
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp
) as resultado;

-- ================================================================
-- EXEMPLOS DE USO:
-- ================================================================

-- Exemplo 1: Promover usuário com 30 dias
-- SELECT update_user_level_by_email(
--   'cliente@exemplo.com',
--   'expert', 
--   (NOW() + INTERVAL '30 days')::timestamp
-- );

-- Exemplo 2: Promover usuário com acesso permanente
-- SELECT update_user_level_by_email(
--   'cliente@exemplo.com',
--   'expert', 
--   NULL  -- NULL = nunca expira
-- );

-- Exemplo 3: Reverter usuário para básico
-- SELECT update_user_level_by_email(
--   'ex-cliente@exemplo.com',
--   'basic', 
--   NULL
-- );

-- ================================================================
-- VERIFICAR SE A PROMOÇÃO FUNCIONOU:
-- ================================================================

-- Verificar nível do usuário (substitua o email):
-- SELECT 
--   u.email,
--   upl.current_level,
--   upl.level_expires_at,
--   upl.unlocked_features
-- FROM auth.users u
-- LEFT JOIN user_progress_level upl ON u.id = upl.user_id
-- WHERE u.email = 'EMAIL_DO_USUARIO_AQUI';

-- ================================================================
-- VERIFICAR TODOS OS USUÁRIOS EXPERT:
-- ================================================================

-- SELECT 
--   u.email,
--   upl.current_level,
--   upl.level_expires_at,
--   CASE 
--     WHEN upl.level_expires_at IS NULL THEN 'Permanente'
--     WHEN upl.level_expires_at > NOW() THEN 'Ativo'
--     ELSE 'Expirado'
--   END as status_acesso
-- FROM auth.users u
-- JOIN user_progress_level upl ON u.id = upl.user_id
-- WHERE upl.current_level = 'expert'
-- ORDER BY upl.created_at DESC; 