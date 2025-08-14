-- ================================================================
-- TESTE: REGISTRO DE USUÁRIO COM PAGAMENTO STRIPE PENDENTE (CORRIGIDO)
-- Execute APÓS scripts/teste_usuario_novo_stripe.sql
-- ================================================================

-- CENÁRIO: Cliente que comprou no Stripe agora se registra no app
-- CORREÇÃO: Lida com emails que já podem existir em auth.users

-- 1. VERIFICAR PAGAMENTOS PENDENTES ANTES DO REGISTRO
SELECT 'Pagamentos pendentes antes do registro...' as info;

SELECT 
  email,
  level,
  CASE 
    WHEN expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  stripe_customer_id
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY email;

-- 2. FUNÇÃO PARA SIMULAR REGISTRO SEGURO
CREATE OR REPLACE FUNCTION simular_registro_usuario(email_input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  user_id_var UUID;
BEGIN
  -- Buscar ou criar usuário em auth.users
  SELECT id INTO user_id_var
  FROM auth.users 
  WHERE email = email_input;
  
  IF user_id_var IS NULL THEN
    -- Criar novo usuário em auth.users
    INSERT INTO auth.users (
      id, email, created_at, updated_at, email_confirmed_at
    ) VALUES (
      gen_random_uuid(), email_input, NOW(), NOW(), NOW()
    ) RETURNING id INTO user_id_var;
  END IF;
  
  -- Criar ou atualizar na tabela profiles (isso dispara o trigger!)
  INSERT INTO profiles (
    id, email, created_at, updated_at
  ) VALUES (
    user_id_var, email_input, NOW(), NOW()
  ) ON CONFLICT (id) DO UPDATE SET
    updated_at = NOW();
    
  RETURN 'Usuário registrado: ' || email_input;
END;
$$;

-- 3. SIMULAR REGISTRO DOS 3 CLIENTES
SELECT 'Simulando registro dos clientes...' as acao;

SELECT simular_registro_usuario('cliente.novo@stripe.com') as resultado1;
SELECT simular_registro_usuario('cliente2@stripe.com') as resultado2;
SELECT simular_registro_usuario('cliente3@stripe.com') as resultado3;

-- 4. AGUARDAR TRIGGER PROCESSAR
SELECT 'Triggers executados! Verificando resultados...' as status;

-- 5. VERIFICAR SE OS USUÁRIOS FORAM PROMOVIDOS AUTOMATICAMENTE
SELECT 'Status dos usuários após registro...' as info;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as total_features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as promovido_em
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY p.email;

-- 6. VERIFICAR SE FORAM REMOVIDOS DA TABELA DE PENDENTES
SELECT 'Verificando remoção dos pendentes...' as info;

SELECT 
  COUNT(*) as usuarios_pendentes_restantes,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ TODOS removidos dos pendentes!'
    ELSE '⚠️ Ainda há ' || COUNT(*) || ' usuários pendentes'
  END as status
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 7. VER LOGS DE PAGAMENTO ATUALIZADOS
SELECT 'Logs de pagamento processados...' as info;

SELECT 
  email,
  level_updated,
  status,
  stripe_customer_id,
  to_char(created_at, 'DD/MM/YYYY HH24:MI') as criado_em,
  to_char(updated_at, 'DD/MM/YYYY HH24:MI') as processado_em,
  COALESCE(error_message, 'Processado com sucesso') as resultado
FROM payment_logs
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY email, created_at DESC;

-- 8. TESTAR FUNÇÃO DE STATUS PARA TODOS
SELECT 'Status completo dos clientes...' as info;

SELECT 
  'cliente.novo@stripe.com' as cliente,
  stripe_check_payment_status('cliente.novo@stripe.com') as status
UNION ALL
SELECT 
  'cliente2@stripe.com' as cliente,
  stripe_check_payment_status('cliente2@stripe.com') as status
UNION ALL
SELECT 
  'cliente3@stripe.com' as cliente,
  stripe_check_payment_status('cliente3@stripe.com') as status;

-- ================================================================
-- RESULTADO FINAL DO TRIGGER AUTOMÁTICO:
-- ================================================================

SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉 SUCESSO TOTAL! Todos os 3 clientes promovidos automaticamente!'
    ELSE '⚠️ Nem todos os clientes foram promovidos - verificar trigger'
  END as resultado_final;

-- 9. RESUMO COMPLETO: TODOS OS USUÁRIOS EXPERT
SELECT 'RESUMO: Todos os usuários Expert no sistema...' as final_info;

SELECT 
  p.email,
  upl.current_level,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício 🔥'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY')
  END as tipo_assinatura,
  array_length(upl.unlocked_features, 1) as features,
  to_char(upl.updated_at, 'DD/MM/YYYY HH24:MI') as promovido_em,
  CASE 
    WHEN p.email LIKE '%@stripe.com' THEN '🛒 Cliente Stripe'
    ELSE '👤 Usuário Manual'
  END as origem
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE upl.current_level = 'expert'
ORDER BY upl.updated_at DESC;

-- LIMPAR FUNÇÃO TEMPORÁRIA
DROP FUNCTION IF EXISTS simular_registro_usuario(TEXT); 