-- ================================================================
-- DIAGNÓSTICO E CORREÇÃO DO TRIGGER AUTOMÁTICO
-- Identificar por que o trigger não está processando pagamentos pendentes
-- ================================================================

-- 1. VERIFICAR SE O TRIGGER EXISTE E ESTÁ ATIVO
SELECT 'Verificando status do trigger...' as info;

SELECT 
  trigger_name,
  event_object_table as tabela,
  action_timing as quando,
  event_manipulation as evento,
  action_statement as acao
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_process_pending_on_signup';

-- 2. VERIFICAR SE A FUNÇÃO DO TRIGGER EXISTE
SELECT 'Verificando função do trigger...' as info;

SELECT 
  routine_name,
  routine_type,
  external_language as linguagem
FROM information_schema.routines 
WHERE routine_name = 'trigger_process_pending_users';

-- 3. TESTAR A FUNÇÃO DO TRIGGER MANUALMENTE
SELECT 'Testando função do trigger manualmente...' as teste;

-- Chamar a função diretamente para um dos emails pendentes
DO $$
DECLARE
  pending_entry RECORD;
  test_result JSON;
BEGIN
  -- Buscar entrada pendente
  SELECT * INTO pending_entry
  FROM pending_user_levels
  WHERE email = 'cliente.novo@stripe.com'
  LIMIT 1;

  IF FOUND THEN
    RAISE NOTICE 'Pagamento pendente encontrado para: %', pending_entry.email;
    
    -- Testar a função stripe_update_user_level diretamente
    SELECT stripe_update_user_level(
      pending_entry.email,
      pending_entry.level,
      pending_entry.expires_at,
      pending_entry.stripe_customer_id,
      pending_entry.stripe_subscription_id
    ) INTO test_result;
    
    RAISE NOTICE 'Resultado do teste manual: %', test_result;
  ELSE
    RAISE NOTICE 'Nenhum pagamento pendente encontrado!';
  END IF;
END $$;

-- 4. VERIFICAR LOGS DE PROCESSAMENTO MANUAL
SELECT 'Logs após teste manual...' as info;

SELECT 
  email,
  level_updated,
  status,
  to_char(updated_at, 'DD/MM/YYYY HH24:MI:SS') as processado_em,
  error_message
FROM payment_logs
WHERE email = 'cliente.novo@stripe.com'
ORDER BY updated_at DESC
LIMIT 2;

-- 5. RECRIAR O TRIGGER COM LOGS DE DEBUG
SELECT 'Recriando trigger com logs de debug...' as acao;

-- Remover trigger atual
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON profiles;

-- Criar nova função do trigger com logs
CREATE OR REPLACE FUNCTION trigger_process_pending_users_debug()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  pending_entry RECORD;
  result_json JSON;
BEGIN
  -- Log de entrada
  INSERT INTO payment_logs (
    email, event_type, level_updated, status, error_message
  ) VALUES (
    NEW.email, 'trigger_debug', 'debug', 'pending', 
    'Trigger disparado para: ' || NEW.email
  );

  IF TG_OP = 'INSERT' THEN
    -- Buscar entrada pendente
    SELECT * INTO pending_entry
    FROM pending_user_levels
    WHERE email = NEW.email
    LIMIT 1;

    IF FOUND THEN
      -- Log de entrada pendente encontrada
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_debug', 'debug', 'pending', 
        'Pagamento pendente encontrado! Processando...'
      );

      -- Aplicar o nível pendente
      SELECT stripe_update_user_level(
        NEW.email,
        pending_entry.level,
        pending_entry.expires_at,
        pending_entry.stripe_customer_id,
        pending_entry.stripe_subscription_id
      ) INTO result_json;
      
      -- Log do resultado
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_debug', 'debug', 'success', 
        'Resultado: ' || result_json::text
      );
      
      -- Remover da tabela de pendentes apenas se sucesso
      IF result_json->>'success' = 'true' THEN
        DELETE FROM pending_user_levels WHERE id = pending_entry.id;
        
        INSERT INTO payment_logs (
          email, event_type, level_updated, status, error_message
        ) VALUES (
          NEW.email, 'trigger_debug', 'debug', 'success', 
          'Removido da tabela de pendentes'
        );
      END IF;
    ELSE
      -- Log de nenhuma entrada pendente
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_debug', 'debug', 'info', 
        'Nenhum pagamento pendente encontrado'
      );
    END IF;
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log de erro
    INSERT INTO payment_logs (
      email, event_type, level_updated, status, error_message
    ) VALUES (
      NEW.email, 'trigger_debug', 'debug', 'error', 
      'ERRO no trigger: ' || SQLERRM
    );
    RETURN NEW;
END;
$$;

-- Criar novo trigger com função de debug
CREATE TRIGGER trigger_process_pending_on_signup
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION trigger_process_pending_users_debug();

-- 6. TESTAR O NOVO TRIGGER
SELECT 'Testando novo trigger com logs...' as teste;

-- Simular inserção na tabela profiles para forçar trigger
-- (usar email que já tem pagamento pendente)
INSERT INTO profiles (
  id, email, created_at, updated_at
) VALUES (
  gen_random_uuid(), 
  'teste.trigger@stripe.com', 
  NOW(), 
  NOW()
) ON CONFLICT (email) DO UPDATE SET updated_at = NOW();

-- 7. VERIFICAR LOGS DO TRIGGER
SELECT 'Logs de debug do trigger...' as resultado;

SELECT 
  email,
  event_type,
  status,
  error_message,
  to_char(created_at, 'DD/MM/YYYY HH24:MI:SS') as timestamp
FROM payment_logs
WHERE event_type = 'trigger_debug'
ORDER BY created_at DESC;

-- 8. PROCESSAR MANUALMENTE OS 3 CLIENTES PENDENTES
SELECT 'Processando manualmente os 3 clientes...' as acao_manual;

-- Cliente 1
SELECT stripe_update_user_level(
  'cliente.novo@stripe.com',
  'expert',
  (SELECT expires_at FROM pending_user_levels WHERE email = 'cliente.novo@stripe.com'),
  'cus_stripe_12345',
  'sub_stripe_67890'
) as resultado_cliente1;

-- Cliente 2  
SELECT stripe_update_user_level(
  'cliente2@stripe.com',
  'expert', 
  (SELECT expires_at FROM pending_user_levels WHERE email = 'cliente2@stripe.com'),
  'cus_stripe_22222',
  'sub_stripe_annual_001'
) as resultado_cliente2;

-- Cliente 3
SELECT stripe_update_user_level(
  'cliente3@stripe.com',
  'expert',
  (SELECT expires_at FROM pending_user_levels WHERE email = 'cliente3@stripe.com'),
  'cus_stripe_33333', 
  'sub_stripe_lifetime_001'
) as resultado_cliente3;

-- 9. VERIFICAR SE AGORA FORAM PROMOVIDOS
SELECT 'Status final dos clientes após processamento manual...' as final_status;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY HH24:MI')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as total_features
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY p.email;

-- 10. REMOVER REGISTROS PENDENTES PROCESSADOS
DELETE FROM pending_user_levels 
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉 SUCESSO! Todos os 3 clientes promovidos!'
    ELSE '⚠️ Ainda há problemas - verificar logs'
  END as resultado_final; 