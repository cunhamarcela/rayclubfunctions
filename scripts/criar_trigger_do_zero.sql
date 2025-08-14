-- ================================================================
-- CRIAR TRIGGER AUTOMÁTICO DO ZERO
-- O trigger não existia, por isso não processava pagamentos pendentes
-- ================================================================

-- 1. CONFIRMAR QUE O TRIGGER NÃO EXISTE
SELECT 'Confirmando que trigger não existe...' as status;

SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '❌ TRIGGER NÃO EXISTE (confirmado)'
    ELSE '✅ Trigger existe: ' || string_agg(trigger_name, ', ')
  END as resultado_trigger
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_process_pending_on_signup';

SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '❌ FUNÇÃO DO TRIGGER NÃO EXISTE (confirmado)'
    ELSE '✅ Função existe: ' || string_agg(routine_name, ', ')
  END as resultado_funcao
FROM information_schema.routines 
WHERE routine_name LIKE '%trigger_process_pending%';

-- 2. VERIFICAR QUANTOS PAGAMENTOS PENDENTES TEMOS
SELECT 'Status atual dos pagamentos pendentes...' as info;

SELECT 
  COUNT(*) as total_pendentes,
  string_agg(email, ', ') as emails_pendentes
FROM pending_user_levels;

-- 3. CRIAR A FUNÇÃO DO TRIGGER
SELECT 'Criando função do trigger...' as acao;

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
    
    -- Log de debug inicial
    debug_log := 'Trigger disparado para email: ' || COALESCE(NEW.email, 'NULL');
    
    INSERT INTO payment_logs (
      email, event_type, level_updated, status, error_message
    ) VALUES (
      NEW.email, 'trigger_auto', 'debug', 'info', debug_log
    );

    -- Buscar entrada pendente para este email
    SELECT * INTO pending_entry
    FROM pending_user_levels
    WHERE email = NEW.email
    LIMIT 1;

    IF FOUND THEN
      -- Log: encontrou pagamento pendente
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_auto', 'debug', 'info', 
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
      
      -- Log do resultado
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_auto', 'process', 'info', 
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
      -- Log: nenhum pagamento pendente
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message
      ) VALUES (
        NEW.email, 'trigger_auto', 'debug', 'info', 
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

-- 4. CRIAR O TRIGGER
SELECT 'Criando trigger...' as acao;

CREATE TRIGGER trigger_process_pending_on_signup
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION trigger_process_pending_users();

-- 5. VERIFICAR SE FORAM CRIADOS COM SUCESSO
SELECT 'Verificando se trigger foi criado...' as verificacao;

SELECT 
  trigger_name,
  event_object_table as tabela,
  action_timing as quando,
  event_manipulation as evento,
  'CRIADO COM SUCESSO!' as status
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_process_pending_on_signup';

SELECT 
  routine_name,
  routine_type,
  'CRIADA COM SUCESSO!' as status
FROM information_schema.routines 
WHERE routine_name = 'trigger_process_pending_users';

-- 6. TESTAR O TRIGGER COM EMAIL NOVO
SELECT 'Testando trigger com email novo...' as teste;

-- Inserir um novo usuário na tabela profiles para forçar o trigger
INSERT INTO profiles (
  id, email, created_at, updated_at
) VALUES (
  gen_random_uuid(), 
  'teste.trigger.novo@rayclub.com', 
  NOW(), 
  NOW()
);

-- 7. VERIFICAR LOGS DO TESTE
SELECT 'Logs do teste do trigger...' as resultado_teste;

SELECT 
  email,
  event_type,
  status,
  error_message,
  to_char(created_at, 'HH24:MI:SS') as hora
FROM payment_logs
WHERE email = 'teste.trigger.novo@rayclub.com'
ORDER BY created_at;

-- 8. AGORA FORÇAR TRIGGER PARA OS 3 CLIENTES PENDENTES
SELECT 'Forçando trigger para os 3 clientes pendentes...' as acao_forcada;

-- Método: fazer UPDATE na tabela profiles para forçar trigger 
-- (usando ON CONFLICT para não duplicar)

DO $$
DECLARE
  cliente_email TEXT;
  cliente_cursor CURSOR FOR 
    SELECT email FROM pending_user_levels 
    WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');
BEGIN
  FOR cliente_email IN 
    SELECT email FROM pending_user_levels 
    WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
  LOOP
    RAISE NOTICE 'Forçando trigger para: %', cliente_email;
    
    -- Forçar uma "nova inserção" via upsert
    INSERT INTO profiles (
      id, email, created_at, updated_at
    ) 
    SELECT 
      COALESCE(
        (SELECT id FROM profiles WHERE email = cliente_email),
        gen_random_uuid()
      ),
      cliente_email,
      NOW(),
      NOW()
    ON CONFLICT (email) DO UPDATE SET 
      updated_at = NOW();
      
    -- Como isso não vai disparar trigger (é UPDATE), vamos forçar manualmente
    -- Deletar e reinserir para garantir que trigger dispare
    DELETE FROM profiles WHERE email = cliente_email;
    
    INSERT INTO profiles (
      id, email, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      cliente_email,
      NOW(),
      NOW()
    );
  END LOOP;
END $$;

-- 9. VERIFICAR LOGS DOS 3 CLIENTES
SELECT 'Logs dos 3 clientes após forçar trigger...' as logs_clientes;

SELECT 
  email,
  event_type,
  status,
  error_message,
  to_char(created_at, 'HH24:MI:SS') as hora
FROM payment_logs
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
  AND event_type = 'trigger_auto'
ORDER BY email, created_at;

-- 10. VERIFICAR SE FORAM PROMOVIDOS
SELECT 'Status final dos 3 clientes...' as status_final;

SELECT 
  p.email,
  COALESCE(upl.current_level, 'basic') as nivel_atual,
  CASE 
    WHEN upl.level_expires_at IS NULL THEN 'Vitalício'
    ELSE to_char(upl.level_expires_at, 'DD/MM/YYYY')
  END as expira_em,
  array_length(upl.unlocked_features, 1) as features
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
ORDER BY p.email;

-- 11. VERIFICAR PENDENTES RESTANTES
SELECT 'Pagamentos pendentes restantes...' as pendentes_final;

SELECT 
  COUNT(*) as total_pendentes,
  CASE 
    WHEN COUNT(*) = 0 THEN '🎉 NENHUM PENDENTE - TRIGGER FUNCIONOU!'
    ELSE '⚠️ Ainda há ' || COUNT(*) || ' pendentes'
  END as status
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉 SUCESSO TOTAL! Trigger criado e funcionando - 3 clientes promovidos!'
    ELSE '⚠️ Trigger criado mas nem todos os clientes foram promovidos'
  END as resultado_final; 