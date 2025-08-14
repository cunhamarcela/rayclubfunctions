-- ================================================================
-- CORRIGIR DESSINCRONIZAÇÃO DE IDs ENTRE auth.users E profiles
-- Problema: Usuários existem nas duas tabelas mas com IDs diferentes
-- ================================================================

-- 1. DIAGNÓSTICO COMPLETO DA DESSINCRONIZAÇÃO
SELECT 'Analisando dessincronização de IDs...' as diagnostico;

-- Mostrar os IDs em ambas as tabelas
SELECT 
  'Comparação de IDs:' as tipo,
  p.email,
  p.id as profile_id,
  au.id as auth_users_id,
  CASE 
    WHEN p.id = au.id THEN '✅ SINCRONIZADO'
    WHEN au.id IS NULL THEN '❌ NÃO EXISTE em auth.users'
    WHEN p.id IS NULL THEN '❌ NÃO EXISTE em profiles'
    ELSE '⚠️ IDs DIFERENTES - DESSINCRONIZADO'
  END as status_sincronia
FROM profiles p
FULL OUTER JOIN auth.users au ON au.email = p.email
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
   OR au.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY COALESCE(p.email, au.email);

-- 2. ESTRATÉGIA: ATUALIZAR profiles PARA USAR OS IDs DE auth.users
SELECT 'Corrigindo IDs em profiles para corresponder a auth.users...' as acao;

-- Backup dos IDs antigos antes da correção
CREATE TEMP TABLE backup_profile_ids AS
SELECT email, id as old_profile_id
FROM profiles 
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

SELECT 'Backup dos IDs antigos criado!' as backup_status;

-- 3. ATUALIZAR profiles COM OS IDs CORRETOS DE auth.users
DO $$
DECLARE
  sync_rec RECORD;
  old_id UUID;
  new_id UUID;
BEGIN
  FOR sync_rec IN 
    SELECT au.id as auth_id, au.email, p.id as profile_id
    FROM auth.users au
    JOIN profiles p ON p.email = au.email
    WHERE au.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
      AND au.id != p.id  -- Apenas onde os IDs são diferentes
  LOOP
    old_id := sync_rec.profile_id;
    new_id := sync_rec.auth_id;
    
    RAISE NOTICE 'Sincronizando %: % → %', sync_rec.email, old_id, new_id;
    
    -- PRIMEIRO: Atualizar referências em user_progress_level
    UPDATE user_progress_level 
    SET user_id = new_id 
    WHERE user_id = old_id;
    
    -- SEGUNDO: Atualizar o ID em profiles
    UPDATE profiles 
    SET id = new_id 
    WHERE id = old_id;
    
    RAISE NOTICE 'Usuário % sincronizado com sucesso!', sync_rec.email;
  END LOOP;
END $$;

-- 4. VERIFICAR SE A SINCRONIZAÇÃO FUNCIONOU
SELECT 'Verificando sincronização após correção...' as verificacao;

SELECT 
  p.email,
  p.id as profile_id,
  au.id as auth_id,
  CASE 
    WHEN p.id = au.id THEN '✅ SINCRONIZADO PERFEITAMENTE'
    ELSE '❌ AINDA DESSINCRONIZADO'
  END as status_final
FROM profiles p
JOIN auth.users au ON au.email = p.email
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 5. AGORA EXECUTAR A PROMOÇÃO COM IDs CORRETOS
SELECT 'Executando promoções para expert com IDs sincronizados...' as promocao;

-- Promover cliente.novo (30 dias)
SELECT stripe_update_user_level(
  'cliente.novo@stripe.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp with time zone,
  'cus_stripe_12345',
  'sub_stripe_67890',
  'sync_final_1_' || extract(epoch from now())::text
) as resultado_cliente_novo;

-- Promover cliente2 (1 ano)
SELECT stripe_update_user_level(
  'cliente2@stripe.com',
  'expert',
  (NOW() + INTERVAL '1 year')::timestamp with time zone,
  'cus_stripe_22222',
  'sub_stripe_annual_001',
  'sync_final_2_' || extract(epoch from now())::text
) as resultado_cliente2;

-- Promover cliente3 (vitalício)
SELECT stripe_update_user_level(
  'cliente3@stripe.com',
  'expert',
  NULL,  -- Vitalício
  'cus_stripe_33333',
  'sub_stripe_lifetime_001',
  'sync_final_3_' || extract(epoch from now())::text
) as resultado_cliente3;

-- 6. VERIFICAÇÃO FINAL - STATUS DOS CLIENTES
SELECT 'STATUS FINAL DOS CLIENTES APÓS SINCRONIZAÇÃO...' as status_final;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício ♾️'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as features_total,
  CASE 
    WHEN upl.current_level = 'expert' THEN '🎉 EXPERT CONFIRMADO!'
    WHEN upl.current_level IS NULL THEN '❌ SEM REGISTRO'
    ELSE '❌ AINDA BASIC'
  END as status_promocao,
  upl.unlocked_features as features_desbloqueadas
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY p.email;

-- 7. VERIFICAR PENDENTES (DEVE SER ZERO)
SELECT 'Verificando usuários pendentes...' as pendentes_check;

SELECT 
  COUNT(*) as total_pendentes,
  CASE 
    WHEN COUNT(*) = 0 THEN '🎉 ZERO PENDENTES - PERFEITO!'
    ELSE '⚠️ Ainda há ' || COUNT(*) || ' pendentes: ' || string_agg(email, ', ')
  END as status_pendentes
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 8. ESTATÍSTICAS GERAIS DO SISTEMA
SELECT 'Estatísticas do sistema pós-correção...' as estatisticas;

SELECT 
  COUNT(*) as total_usuarios_expert,
  COUNT(CASE WHEN p.email LIKE '%@stripe.com' THEN 1 END) as clientes_stripe_expert,
  ROUND(
    COUNT(CASE WHEN p.email LIKE '%@stripe.com' THEN 1 END) * 100.0 / COUNT(*), 
    2
  ) as percentual_stripe,
  '🚀 SISTEMA STRIPE OPERACIONAL!' as status_sistema
FROM user_progress_level upl
JOIN profiles p ON p.id = upl.user_id
WHERE upl.current_level = 'expert';

-- 9. TESTE FINAL - FUNÇÃO sync_user_between_tables
SELECT 'Testando função auxiliar...' as teste_funcao;

CREATE OR REPLACE FUNCTION sync_user_between_tables(email_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  profile_id UUID;
  auth_id UUID;
BEGIN
  -- Buscar IDs nas duas tabelas
  SELECT p.id, au.id INTO profile_id, auth_id
  FROM profiles p
  JOIN auth.users au ON au.email = p.email
  WHERE p.email = email_input;
  
  IF profile_id IS NULL THEN
    RETURN 'Usuário não encontrado';
  END IF;
  
  IF profile_id = auth_id THEN
    RETURN 'Usuário já sincronizado';
  ELSE
    -- Atualizar user_progress_level primeiro
    UPDATE user_progress_level SET user_id = auth_id WHERE user_id = profile_id;
    -- Atualizar profiles
    UPDATE profiles SET id = auth_id WHERE id = profile_id;
    RETURN 'Usuário sincronizado: ' || profile_id::text || ' → ' || auth_id::text;
  END IF;
END;
$$;

-- RESULTADO CONCLUSIVO
SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉🎉 MISSÃO CUMPRIDA! TODOS OS 3 CLIENTES SÃO EXPERT! 🎉🎉'
    ELSE '⚠️ Verificar manualmente - nem todos foram promovidos'
  END as resultado_final,
  NOW() as horario_conclusao;

-- Mostrar backup para referência
SELECT 'IDs antigos salvos no backup:' as backup_info;
SELECT * FROM backup_profile_ids; 