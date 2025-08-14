-- ================================================================
-- PROMOVER USUÁRIO REAL - VERSÃO SUPER SEGURA
-- Este script verifica tudo antes de promover para evitar erros
-- ================================================================

-- ⚠️  SUBSTITUA O EMAIL ABAIXO PELO EMAIL REAL DO CLIENTE ⚠️
-- EXEMPLO: 'cliente@email.com'

DO $$
DECLARE
  target_email TEXT := 'EMAIL_DO_CLIENTE@SUBSTITUIR.com';  -- 👈 MUDE AQUI
  user_found BOOLEAN := FALSE;
  user_id_found UUID;
  auth_user_exists BOOLEAN := FALSE;
  profile_exists BOOLEAN := FALSE;
  result JSON;
BEGIN
  -- ================================================================
  -- 1. VERIFICAÇÕES DE SEGURANÇA
  -- ================================================================
  
  RAISE NOTICE '';
  RAISE NOTICE '🔍 VERIFICANDO USUÁRIO: %', target_email;
  RAISE NOTICE '================================';
  
  -- Verificar se email está em formato válido
  IF target_email = 'EMAIL_DO_CLIENTE@SUBSTITUIR.com' THEN
    RAISE EXCEPTION '❌ ERRO: Você precisa substituir o email de exemplo pelo email real do cliente!';
  END IF;
  
  -- Verificar se usuário existe em profiles
  SELECT id INTO user_id_found FROM profiles WHERE email = target_email;
  IF FOUND THEN
    profile_exists := TRUE;
    RAISE NOTICE '✅ Usuário encontrado em profiles: %', user_id_found;
  ELSE
    RAISE NOTICE '❌ Usuário NÃO encontrado em profiles';
  END IF;
  
  -- Verificar se usuário existe em auth.users
  IF profile_exists THEN
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = user_id_found) INTO auth_user_exists;
    IF auth_user_exists THEN
      RAISE NOTICE '✅ Usuário existe em auth.users';
      user_found := TRUE;
    ELSE
      RAISE NOTICE '❌ Usuário NÃO existe em auth.users (problema de sincronização)';
    END IF;
  END IF;
  
  -- Verificar se já é expert
  IF user_found THEN
    IF EXISTS(SELECT 1 FROM user_progress_level WHERE user_id = user_id_found AND current_level = 'expert') THEN
      RAISE NOTICE '⚠️  Usuário já é EXPERT! Continuando para atualizar data de expiração...';
    ELSE
      RAISE NOTICE '📝 Usuário atual: BASIC (será promovido para EXPERT)';
    END IF;
  END IF;
  
  -- ================================================================
  -- 2. EXECUTAR PROMOÇÃO (se passou em todas as verificações)
  -- ================================================================
  
  IF user_found THEN
    RAISE NOTICE '';
    RAISE NOTICE '🚀 PROMOVENDO USUÁRIO...';
    RAISE NOTICE '=====================';
    
    -- Chamar função de promoção
    SELECT update_user_level_by_email(
      target_email,
      'expert',
      (NOW() + INTERVAL '30 days')::timestamp
    ) INTO result;
    
    -- Mostrar resultado
    RAISE NOTICE 'Resultado: %', result;
    
    -- Verificar se deu certo
    IF result->>'success' = 'true' THEN
      RAISE NOTICE '';
      RAISE NOTICE '🎉 SUCESSO! Usuário promovido para EXPERT!';
      RAISE NOTICE '📅 Acesso válido até: %', (NOW() + INTERVAL '30 days')::date;
    ELSE
      RAISE NOTICE '';
      RAISE NOTICE '❌ ERRO na promoção: %', result->>'error';
    END IF;
    
  ELSE
    RAISE NOTICE '';
    RAISE NOTICE '🚫 PROMOÇÃO CANCELADA - Usuário não pode ser promovido';
    RAISE NOTICE 'Motivos possíveis:';
    RAISE NOTICE '- Email não encontrado em profiles';
    RAISE NOTICE '- Usuário não sincronizado com auth.users';
    RAISE NOTICE '- Problema na estrutura do banco de dados';
    RAISE NOTICE '';
    RAISE NOTICE '💡 SOLUÇÕES:';
    RAISE NOTICE '1. Verifique se o email está correto';
    RAISE NOTICE '2. Execute: sql/fix_user_not_found_issue_complete.sql';
    RAISE NOTICE '3. Ou adicione como pendente manualmente';
  END IF;
  
END $$;

-- ================================================================
-- 3. VERIFICAR RESULTADO DA PROMOÇÃO
-- ================================================================

-- Verificar se o usuário foi promovido (SUBSTITUA O EMAIL)
SELECT 
  p.email,
  p.name,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features,
  CASE 
    WHEN upl.current_level = 'expert' THEN '🎉 PROMOVIDO COM SUCESSO!'
    WHEN upl.current_level = 'basic' THEN '❌ AINDA É BÁSICO'
    ELSE '❓ STATUS INDEFINIDO'
  END as status_promocao,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN '♾️  Permanente'
    WHEN upl.level_expires_at > NOW() THEN '✅ Ativo até ' || upl.level_expires_at::date
    ELSE '❌ Expirado'
  END as status_acesso
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'EMAIL_DO_CLIENTE@SUBSTITUIR.com';  -- 👈 MUDE AQUI TAMBÉM

-- ================================================================
-- 4. LISTAR TODOS OS EXPERTS ATUAIS
-- ================================================================

SELECT 
  '📊 USUÁRIOS EXPERT ATUAIS:' as info;

SELECT 
  p.email,
  p.name,
  upl.current_level,
  upl.level_expires_at,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN '♾️  Permanente'
    WHEN upl.level_expires_at > NOW() THEN '✅ Ativo'
    ELSE '❌ Expirado'
  END as status_acesso,
  upl.created_at as promovido_em
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.created_at DESC
LIMIT 10;

-- ================================================================
-- INSTRUÇÕES DE USO:
-- ================================================================

-- 1. SUBSTITUA o email 'EMAIL_DO_CLIENTE@SUBSTITUIR.com' pelo email real
-- 2. EXECUTE este script completo no SQL Editor do Supabase
-- 3. VERIFIQUE os resultados nas mensagens do console
-- 4. CONFIRME na tabela de resultados se a promoção funcionou 