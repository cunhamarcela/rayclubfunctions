-- ================================================================
-- CORRIGIR SINCRONIZAÇÃO ENTRE auth.users E profiles  
-- Problema: Usuários existem em profiles mas não em auth.users
-- ================================================================

-- 1. VERIFICAR O PROBLEMA
SELECT 'Verificando dessincronia entre tabelas...' as diagnostico;

-- Usuários que existem em profiles mas não em auth.users
SELECT 
  'Usuários órfãos em profiles:' as tipo,
  p.email,
  p.id as profile_id,
  CASE 
    WHEN au.id IS NULL THEN '❌ NÃO EXISTE em auth.users'
    ELSE '✅ Existe em auth.users'
  END as status_auth
FROM profiles p
LEFT JOIN auth.users au ON au.id = p.id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 2. SOLUÇÃO 1: CRIAR OS USUÁRIOS EM auth.users COM OS MESMOS IDs
SELECT 'Criando usuários em auth.users com IDs corretos...' as acao;

DO $$
DECLARE
  profile_rec RECORD;
BEGIN
  FOR profile_rec IN 
    SELECT p.id, p.email FROM profiles p
    LEFT JOIN auth.users au ON au.id = p.id
    WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
      AND au.id IS NULL
  LOOP
    RAISE NOTICE 'Criando usuário em auth.users: % com ID: %', profile_rec.email, profile_rec.id;
    
    INSERT INTO auth.users (
      id, 
      email, 
      created_at, 
      updated_at,
      email_confirmed_at,
      confirmation_sent_at
    ) VALUES (
      profile_rec.id,  -- ← USAR O MESMO ID da tabela profiles
      profile_rec.email,
      NOW(),
      NOW(),
      NOW(),
      NOW()
    ) ON CONFLICT (id) DO UPDATE SET
      email = profile_rec.email,
      updated_at = NOW();
  END LOOP;
END $$;

-- 3. VERIFICAR SE A SINCRONIZAÇÃO FUNCIONOU
SELECT 'Verificando sincronização após correção...' as verificacao;

SELECT 
  p.email,
  p.id as profile_id,
  au.id as auth_id,
  CASE 
    WHEN p.id = au.id THEN '✅ SINCRONIZADO'
    ELSE '❌ IDs DIFERENTES'
  END as status_sincronia
FROM profiles p
JOIN auth.users au ON au.email = p.email
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 4. AGORA TESTAR A FUNÇÃO stripe_update_user_level
SELECT 'Testando função após sincronização...' as teste;

-- Testar com cliente.novo (30 dias)
SELECT stripe_update_user_level(
  'cliente.novo@stripe.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp with time zone,
  'cus_stripe_12345',
  'sub_stripe_67890',
  'sync_fix_1_' || extract(epoch from now())::text
) as resultado_pos_sync_1;

-- Testar com cliente2 (1 ano)  
SELECT stripe_update_user_level(
  'cliente2@stripe.com',
  'expert',
  (NOW() + INTERVAL '1 year')::timestamp with time zone,
  'cus_stripe_22222',
  'sub_stripe_annual_001',
  'sync_fix_2_' || extract(epoch from now())::text
) as resultado_pos_sync_2;

-- Testar com cliente3 (vitalício)
SELECT stripe_update_user_level(
  'cliente3@stripe.com',
  'expert',
  NULL,  -- Vitalício
  'cus_stripe_33333',
  'sub_stripe_lifetime_001',
  'sync_fix_3_' || extract(epoch from now())::text
) as resultado_pos_sync_3;

-- 5. VERIFICAR SE AGORA FORAM PROMOVIDOS PARA EXPERT
SELECT 'Status final após sincronização...' as resultado_final;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício ♾️'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as features_total,
  CASE 
    WHEN upl.current_level = 'expert' THEN '🎉 EXPERT!'
    WHEN upl.current_level IS NULL THEN '❌ SEM REGISTRO'
    ELSE '❌ BASIC'
  END as status_promocao,
  upl.unlocked_features
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY p.email;

-- 6. VERIFICAR SE HÁ PENDENTES RESTANTES
SELECT 'Verificando pendentes após correção...' as pendentes;

SELECT 
  COUNT(*) as total_pendentes,
  CASE 
    WHEN COUNT(*) = 0 THEN '🎉 NENHUM PENDENTE!'
    ELSE '⚠️ Ainda há ' || COUNT(*) || ' pendentes'
  END as status_pendentes
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 7. CONTAR TOTAL DE USUÁRIOS EXPERT
SELECT 'Estatísticas finais...' as estatisticas;

SELECT 
  COUNT(*) as total_experts_sistema,
  COUNT(CASE WHEN p.email LIKE '%@stripe.com' THEN 1 END) as clientes_stripe_expert,
  '🎉 SISTEMA FUNCIONANDO!' as status
FROM user_progress_level upl
JOIN profiles p ON p.id = upl.user_id
WHERE upl.current_level = 'expert';

-- 8. CRIAR FUNÇÃO AUXILIAR PARA SINCRONIZAÇÃO FUTURA
SELECT 'Criando função auxiliar para sincronização...' as util;

CREATE OR REPLACE FUNCTION sync_user_between_tables(email_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  profile_id UUID;
  auth_exists BOOLEAN;
BEGIN
  -- Buscar ID do usuário em profiles
  SELECT id INTO profile_id FROM profiles WHERE email = email_input;
  
  IF profile_id IS NULL THEN
    RETURN 'Usuário não encontrado em profiles';
  END IF;
  
  -- Verificar se existe em auth.users
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = profile_id) INTO auth_exists;
  
  IF NOT auth_exists THEN
    -- Criar em auth.users com o mesmo ID
    INSERT INTO auth.users (
      id, email, created_at, updated_at, email_confirmed_at
    ) VALUES (
      profile_id, email_input, NOW(), NOW(), NOW()
    );
    
    RETURN 'Usuário sincronizado com sucesso';
  ELSE
    RETURN 'Usuário já estava sincronizado';
  END IF;
END;
$$;

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉 SUCESSO TOTAL! TODOS OS 3 CLIENTES PROMOVIDOS PARA EXPERT!'
    ELSE '⚠️ Nem todos foram promovidos - verificar logs'
  END as resultado_conclusivo; 