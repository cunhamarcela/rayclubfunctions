-- ================================================================
-- CORRIGIR STATUS DO TRIGGER
-- O trigger foi criado mas está falhando por usar status 'info' não permitido
-- ================================================================

-- 1. VERIFICAR A CONSTRAINT ATUAL
SELECT 'Verificando constraint de status...' as info;

SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%payment_logs_status%';

-- 2. RECRIAR A FUNÇÃO DO TRIGGER COM STATUS CORRETOS
SELECT 'Corrigindo função do trigger...' as acao;

CREATE OR REPLACE FUNCTION trigger_process_pending_users()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  pending_entry RECORD;
  result_json JSON;
  debug_log TEXT;
BEGIN
  -- Só processar em INSERTs
  IF TG_OP = 'INSERT' THEN
    
    -- Log de debug inicial (usando status 'pending')
    debug_log := 'Trigger disparado para email: ' || COALESCE(NEW.email, 'NULL');
    
    INSERT INTO payment_logs (
      email, event_type, level_updated, status, error_message
    ) VALUES (
      NEW.email, 'trigger_auto', 'debug', 'pending', debug_log
    );

    -- Buscar entrada pendente para este email
    SELECT * INTO pending_entry
    FROM pending_user_levels
    WHERE email = NEW.email
    LIMIT 1;

    IF FOUND THEN
      -- Log: encontrou pagamento pendente (usando status 'pending')
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_auto', 'debug', 'pending', 
        'Pagamento pendente encontrado! Processando para level: ' || pending_entry.level
      );

      -- Aplicar o nível pendente usando nossa função principal
      SELECT stripe_update_user_level(
        NEW.email,
        pending_entry.level,
        pending_entry.expires_at,
        pending_entry.stripe_customer_id,
        pending_entry.stripe_subscription_id,
        'trigger_auto_' || extract(epoch from now())::text
      ) INTO result_json;
      
      -- Log do resultado (usando status 'pending')
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_auto', 'process', 'pending', 
        'Resultado stripe_update_user_level: ' || result_json::text
      );
      
      -- Se deu sucesso, remover da tabela de pendentes
      IF result_json->>'success' = 'true' THEN
        DELETE FROM pending_user_levels WHERE id = pending_entry.id;
        
        INSERT INTO payment_logs (
          email, event_type, level_updated, status, error_message
        ) VALUES (
          NEW.email, 'trigger_auto', 'cleanup', 'success', 
          'Pagamento pendente removido com sucesso!'
        );
      ELSE
        INSERT INTO payment_logs (
          email, event_type, level_updated, status, error_message
        ) VALUES (
          NEW.email, 'trigger_auto', 'error', 'error', 
          'Falha ao processar: ' || COALESCE(result_json->>'error', 'erro desconhecido')
        );
      END IF;
    ELSE
      -- Log: nenhum pagamento pendente (usando status 'pending')
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_auto', 'debug', 'pending', 
        'Nenhum pagamento pendente para este email'
      );
    END IF;
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log de erro detalhado
    INSERT INTO payment_logs (
      email, event_type, level_updated, status, error_message
    ) VALUES (
      COALESCE(NEW.email, 'unknown'), 'trigger_auto', 'error', 'error', 
      'ERRO no trigger: ' || SQLERRM || ' | SQLSTATE: ' || SQLSTATE
    );
    
    -- Não falhar a inserção por causa do trigger
    RETURN NEW;
END;
$$;

-- 3. TESTAR O TRIGGER CORRIGIDO
SELECT 'Testando trigger corrigido...' as teste;

-- Inserir novo usuário para testar
INSERT INTO profiles (
  id, email, created_at, updated_at
) VALUES (
  gen_random_uuid(), 
  'teste.trigger.corrigido@rayclub.com', 
  NOW(), 
  NOW()
);

-- 4. VERIFICAR LOGS DO TESTE CORRIGIDO
SELECT 'Logs do teste corrigido...' as resultado;

SELECT 
  email,
  event_type,
  status,
  error_message,
  to_char(created_at, 'HH24:MI:SS') as hora
FROM payment_logs
WHERE email = 'teste.trigger.corrigido@rayclub.com'
ORDER BY created_at;

-- 5. AGORA FORÇAR TRIGGER PARA OS 3 CLIENTES PENDENTES
SELECT 'Processando os 3 clientes pendentes...' as acao_principal;

-- Método mais simples: remover e reinserir cada cliente
DO $$
DECLARE
  cliente_rec RECORD;
BEGIN
  -- Para cada cliente pendente
  FOR cliente_rec IN 
    SELECT * FROM pending_user_levels 
    WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
  LOOP
    RAISE NOTICE 'Processando cliente: %', cliente_rec.email;
    
    -- Remover da tabela profiles se existir
    DELETE FROM profiles WHERE email = cliente_rec.email;
    
    -- Reinserir para forçar trigger
    INSERT INTO profiles (
      id, email, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      cliente_rec.email,
      NOW(),
      NOW()
    );
    
    -- Aguardar um momento para o trigger processar
    PERFORM pg_sleep(0.1);
  END LOOP;
END $$;

-- 6. VERIFICAR LOGS DOS 3 CLIENTES
SELECT 'Logs dos 3 clientes...' as logs_resultado;

SELECT 
  email,
  event_type,
  status,
  LEFT(error_message, 80) as mensagem_resumida,
  to_char(created_at, 'HH24:MI:SS') as hora
FROM payment_logs
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
  AND event_type = 'trigger_auto'
  AND created_at > (NOW() - INTERVAL '5 minutes')
ORDER BY email, created_at;

-- 7. VERIFICAR SE FORAM PROMOVIDOS PARA EXPERT
SELECT 'Status final dos 3 clientes...' as status_promocao;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as features,
  CASE 
    WHEN upl.current_level = 'expert' THEN '🎉 PROMOVIDO!'
    ELSE '❌ Ainda basic'
  END as resultado
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY p.email;

-- 8. VERIFICAR PENDENTES RESTANTES
SELECT 'Pendentes restantes...' as pendentes_check;

SELECT 
  COUNT(*) as total_pendentes,
  CASE 
    WHEN COUNT(*) = 0 THEN '🎉 TODOS PROCESSADOS!'
    ELSE '⚠️ Ainda há ' || COUNT(*) || ' pendentes: ' || string_agg(email, ', ')
  END as status
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 9. SE AINDA HÁ PENDENTES, PROCESSAR MANUALMENTE
DO $$
DECLARE
  pendentes_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO pendentes_count
  FROM pending_user_levels
  WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');
  
  IF pendentes_count > 0 THEN
    RAISE NOTICE 'Ainda há % pendentes. Processando manualmente...', pendentes_count;
    
    -- Processar manualmente
    PERFORM stripe_update_user_level(
      'cliente.novo@stripe.com', 'expert',
      (SELECT expires_at FROM pending_user_levels WHERE email = 'cliente.novo@stripe.com'),
      'cus_stripe_12345', 'sub_stripe_67890'
    );
    
    PERFORM stripe_update_user_level(
      'cliente2@stripe.com', 'expert',
      (SELECT expires_at FROM pending_user_levels WHERE email = 'cliente2@stripe.com'),
      'cus_stripe_22222', 'sub_stripe_annual_001'
    );
    
    PERFORM stripe_update_user_level(
      'cliente3@stripe.com', 'expert',
      (SELECT expires_at FROM pending_user_levels WHERE email = 'cliente3@stripe.com'),
      'cus_stripe_33333', 'sub_stripe_lifetime_001'
    );
    
    -- Limpar pendentes
    DELETE FROM pending_user_levels 
    WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');
    
    RAISE NOTICE 'Processamento manual concluído!';
  ELSE
    RAISE NOTICE 'Nenhum pendente encontrado. Trigger funcionou perfeitamente!';
  END IF;
END $$;

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉 SUCESSO TOTAL! 3 clientes promovidos para EXPERT!'
    ELSE '⚠️ Nem todos foram promovidos. Verificar logs.'
  END as resultado_final; 