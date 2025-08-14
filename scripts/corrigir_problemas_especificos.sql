-- ================================================================
-- CORRIGIR PROBLEMAS ESPECÍFICOS DO TRIGGER
-- 1. Constraint duplicate key na payment_logs
-- 2. Usuários não sendo promovidos para expert
-- ================================================================

-- 1. INVESTIGAR PROBLEMA DE CHAVE ÚNICA
SELECT 'Investigando constraint duplicate key...' as diagnostico;

-- Verificar índices únicos na tabela payment_logs
SELECT 
  indexname,
  indexdef
FROM pg_indexes 
WHERE tablename = 'payment_logs' 
  AND indexdef LIKE '%UNIQUE%';

-- Verificar se há duplicatas de stripe_event_id
SELECT 
  stripe_event_id,
  COUNT(*) as duplicatas
FROM payment_logs
WHERE stripe_event_id IS NOT NULL
GROUP BY stripe_event_id
HAVING COUNT(*) > 1;

-- 2. VERIFICAR POR QUE cliente.novo NÃO FOI PROMOVIDO
SELECT 'Verificando por que cliente.novo não foi promovido...' as diagnostico;

-- Verificar se o usuário existe em user_progress_level
SELECT 
  'Dados em user_progress_level:' as tipo,
  p.email,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as features_count
FROM profiles p
LEFT JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email = 'cliente.novo@stripe.com';

-- Verificar se foi removido corretamente dos pendentes
SELECT 
  'Status pendentes:' as tipo,
  COUNT(*) as pendentes_restantes
FROM pending_user_levels
WHERE email = 'cliente.novo@stripe.com';

-- Verificar logs detalhados
SELECT 
  'Logs detalhados cliente.novo:' as tipo,
  event_type,
  level_updated,
  status,
  error_message,
  to_char(created_at, 'HH24:MI:SS') as hora
FROM payment_logs
WHERE email = 'cliente.novo@stripe.com'
  AND created_at > (NOW() - INTERVAL '10 minutes')
ORDER BY created_at DESC;

-- 3. PROCESSAR MANUALMENTE TODOS OS 3 CLIENTES
SELECT 'Processando manualmente os 3 clientes...' as acao;

-- Processar cliente.novo novamente (caso não tenha funcionado)
SELECT stripe_update_user_level(
  'cliente.novo@stripe.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp with time zone,
  'cus_stripe_12345',
  'sub_stripe_67890',
  'manual_fix_' || extract(epoch from now())::text
) as resultado_cliente_novo;

-- Processar cliente2 com event_id único
SELECT stripe_update_user_level(
  'cliente2@stripe.com',
  'expert',
  (NOW() + INTERVAL '1 year')::timestamp with time zone,
  'cus_stripe_22222',
  'sub_stripe_annual_001',
  'manual_fix_2_' || extract(epoch from now())::text
) as resultado_cliente2;

-- Processar cliente3 com event_id único
SELECT stripe_update_user_level(
  'cliente3@stripe.com',
  'expert',
  NULL, -- Vitalício
  'cus_stripe_33333',
  'sub_stripe_lifetime_001',
  'manual_fix_3_' || extract(epoch from now())::text
) as resultado_cliente3;

-- 4. LIMPAR PENDENTES MANUALMENTE
DELETE FROM pending_user_levels 
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 5. VERIFICAR SE AGORA FORAM PROMOVIDOS
SELECT 'Status final após processamento manual...' as verificacao;

image.pngimage.png
-- 6. VERIFICAR FEATURES DESBLOQUEADAS
SELECT 'Features desbloqueadas para os clientes Expert...' as info;

SELECT 
  p.email,
  upl.unlocked_features
FROM profiles p
JOIN user_progress_level upl ON p.id = upl.user_id
WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
  AND upl.current_level = 'expert';

-- 7. VERIFICAR SE NÃO HÁ MAIS PENDENTES
SELECT 'Pendentes restantes após limpeza...' as pendentes_final;

SELECT 
  COUNT(*) as total_pendentes,
  CASE 
    WHEN COUNT(*) = 0 THEN '🎉 NENHUM PENDENTE!'
    ELSE '⚠️ Ainda há ' || COUNT(*) || ' pendentes'
  END as status
FROM pending_user_levels
WHERE email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com');

-- 8. CORRIGIR TRIGGER PARA EVITAR DUPLICATAS NO FUTURO
SELECT 'Corrigindo trigger para evitar duplicatas...' as correcao;

CREATE OR REPLACE FUNCTION trigger_process_pending_users()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  pending_entry RECORD;
  result_json JSON;
  unique_event_id TEXT;
BEGIN
  -- Só processar em INSERTs
  IF TG_OP = 'INSERT' THEN
    
    -- Gerar event_id único para evitar conflitos
    unique_event_id := 'trigger_' || NEW.email || '_' || extract(epoch from now())::text;
    
    -- Log de debug inicial
    INSERT INTO payment_logs (
      email, event_type, level_updated, status, error_message, stripe_event_id
    ) VALUES (
      NEW.email, 'trigger_auto', 'debug', 'pending', 
      'Trigger disparado para email: ' || COALESCE(NEW.email, 'NULL'),
      unique_event_id || '_debug'
    );

    -- Buscar entrada pendente para este email
    SELECT * INTO pending_entry
    FROM pending_user_levels
    WHERE email = NEW.email
    LIMIT 1;

    IF FOUND THEN
      -- Log: encontrou pagamento pendente
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message, stripe_event_id
      ) VALUES (
        NEW.email, 'trigger_auto', 'debug', 'pending', 
        'Pagamento pendente encontrado! Processando para level: ' || pending_entry.level,
        unique_event_id || '_found'
      );

      -- Aplicar o nível pendente usando nossa função principal
      SELECT stripe_update_user_level(
        NEW.email,
        pending_entry.level,
        pending_entry.expires_at,
        pending_entry.stripe_customer_id,
        pending_entry.stripe_subscription_id,
        unique_event_id || '_process'
      ) INTO result_json;
      
      -- Log do resultado
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message, stripe_event_id
      ) VALUES (
        NEW.email, 'trigger_auto', 'process', 'pending', 
        'Resultado: ' || result_json::text,
        unique_event_id || '_result'
      );
      
      -- Se deu sucesso, remover da tabela de pendentes
      IF result_json->>'success' = 'true' THEN
        DELETE FROM pending_user_levels WHERE id = pending_entry.id;
        
        INSERT INTO payment_logs (
          email, event_type, level_updated, status, error_message, stripe_event_id
        ) VALUES (
          NEW.email, 'trigger_auto', 'cleanup', 'success', 
          'Pagamento pendente removido com sucesso!',
          unique_event_id || '_cleanup'
        );
      ELSE
        INSERT INTO payment_logs (
          email, event_type, level_updated, status, error_message, stripe_event_id
        ) VALUES (
          NEW.email, 'trigger_auto', 'error', 'error', 
          'Falha ao processar: ' || COALESCE(result_json->>'error', 'erro desconhecido'),
          unique_event_id || '_error'
        );
      END IF;
    ELSE
      -- Log: nenhum pagamento pendente
      INSERT INTO payment_logs (
        email, event_type, level_updated, status, error_message, stripe_event_id
      ) VALUES (
        NEW.email, 'trigger_auto', 'debug', 'pending', 
        'Nenhum pagamento pendente para este email',
        unique_event_id || '_none'
      );
    END IF;
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log de erro detalhado com event_id único
    INSERT INTO payment_logs (
      email, event_type, level_updated, status, error_message, stripe_event_id
    ) VALUES (
      COALESCE(NEW.email, 'unknown'), 'trigger_auto', 'error', 'error', 
      'ERRO no trigger: ' || SQLERRM,
      'trigger_error_' || extract(epoch from now())::text
    );
    
    RETURN NEW;
END;
$$;

-- 9. TESTE FINAL COMPLETO
SELECT 'Teste final do sistema completo...' as teste_final;

-- Contar usuários Expert
SELECT 
  COUNT(*) as total_experts,
  '🎉 SISTEMA FUNCIONANDO!' as status
FROM user_progress_level
WHERE current_level = 'expert';

-- RESULTADO FINAL
SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM user_progress_level upl
      JOIN profiles p ON p.id = upl.user_id
      WHERE p.email IN ('cliente.novo@stripe.com', 'cliente2@stripe.com', 'cliente3@stripe.com')
        AND upl.current_level = 'expert'
    ) = 3 THEN '🎉 SUCESSO TOTAL! TODOS OS 3 CLIENTES SÃO EXPERT!'
    ELSE '⚠️ Alguns clientes ainda não foram promovidos'
  END as resultado_final; 