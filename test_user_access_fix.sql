-- ========================================
-- TESTE DO USUÁRIO ESPECÍFICO
-- ========================================
-- Para verificar se as correções funcionaram

-- 1. Verificar o usuário atual dos logs (ace751a7-16c0-4f50-9da9-6fb9e90e2f33)
SELECT 
  'USUÁRIO DE TESTE' as tipo,
  id,
  name,
  email,
  account_type,
  created_at,
  CASE 
    WHEN account_type = 'expert' THEN '🌟 EXPERT - ACESSO TOTAL'
    WHEN account_type = 'basic' THEN '👤 BASIC - ACESSO LIMITADO'
    WHEN account_type IS NULL THEN '❌ NULL - PROBLEMA!'
    ELSE '⚠️ TIPO DESCONHECIDO'
  END as status_acesso
FROM profiles 
WHERE id = 'ace751a7-16c0-4f50-9da9-6fb9e90e2f33';

-- 2. Verificar se existe no user_progress_level
SELECT 
  'USER_PROGRESS_LEVEL' as tipo,
  user_id,
  current_level,
  level_expires_at,
  unlocked_features,
  last_activity
FROM user_progress_level 
WHERE user_id = 'ace751a7-16c0-4f50-9da9-6fb9e90e2f33';

-- 3. Forçar correção manual se ainda estiver NULL
UPDATE profiles 
SET account_type = 'basic'
WHERE id = 'ace751a7-16c0-4f50-9da9-6fb9e90e2f33'
  AND account_type IS NULL;

-- 4. Verificar resultado final
SELECT 
  'RESULTADO FINAL' as tipo,
  id,
  name,
  email,
  account_type,
  CASE 
    WHEN account_type = 'basic' THEN '✅ CORRIGIDO - ACESSO BÁSICO'
    WHEN account_type = 'expert' THEN '🌟 EXPERT - ACESSO TOTAL'
    ELSE '❌ AINDA COM PROBLEMA'
  END as resultado
FROM profiles 
WHERE id = 'ace751a7-16c0-4f50-9da9-6fb9e90e2f33';

-- 5. Verificar estatísticas gerais
SELECT 
  'ESTATÍSTICAS GERAIS' as tipo,
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN account_type = 'basic' THEN 1 END) as basic_count,
  COUNT(CASE WHEN account_type = 'expert' THEN 1 END) as expert_count,
  COUNT(CASE WHEN account_type IS NULL THEN 1 END) as null_count,
  ROUND(
    100.0 * COUNT(CASE WHEN account_type IS NULL THEN 1 END) / COUNT(*), 
    2
  ) as percentage_null
FROM profiles;
