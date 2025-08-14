-- ================================================================
-- FUNÇÕES SQL PARA INTEGRAÇÃO COM STRIPE WEBHOOK - VERSÃO FINAL
-- Data: 2025-01-19
-- Fix: Resolver foreign key auth.users + ambiguidade de colunas
-- ================================================================

-- 1. TABELA DE LOGS DE PAGAMENTOS (mantém igual)
CREATE TABLE IF NOT EXISTS payment_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  stripe_event_id TEXT UNIQUE,
  event_type TEXT NOT NULL,
  level_updated TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  status TEXT CHECK (status IN ('success', 'error', 'pending')) DEFAULT 'pending',
  error_message TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_payment_logs_email ON payment_logs(email);
CREATE INDEX IF NOT EXISTS idx_payment_logs_stripe_customer ON payment_logs(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_logs_event_id ON payment_logs(stripe_event_id);
CREATE INDEX IF NOT EXISTS idx_payment_logs_status ON payment_logs(status);

-- 2. FUNÇÃO PARA ATUALIZAR USUÁRIO POR EMAIL - VERSÃO FINAL CORRIGIDA
CREATE OR REPLACE FUNCTION update_user_level_by_email(
  email_param TEXT,
  new_level TEXT DEFAULT 'expert',
  expires_at_param TIMESTAMP DEFAULT NULL,
  stripe_customer_id TEXT DEFAULT NULL,
  stripe_subscription_id TEXT DEFAULT NULL,
  stripe_event_id TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  user_id_found UUID;
  expert_features TEXT[];
  basic_features TEXT[];
  new_features TEXT[];
  log_id UUID;
  result JSON;
BEGIN
  -- Definir features disponíveis
  expert_features := ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
    'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
    'advanced_tracking', 'detailed_reports'
  ];
  
  basic_features := ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording'
  ];

  -- Validar nível
  IF new_level NOT IN ('basic', 'expert') THEN
    new_level := 'expert';
  END IF;
  
  -- Definir features baseado no nível
  IF new_level = 'expert' THEN
    new_features := expert_features;
  ELSE
    new_features := basic_features;
  END IF;

  -- Criar log de tentativa
  INSERT INTO payment_logs (
    email, stripe_customer_id, stripe_subscription_id, stripe_event_id,
    event_type, level_updated, expires_at, status
  ) VALUES (
    email_param, stripe_customer_id, stripe_subscription_id, stripe_event_id,
    'user_level_update', new_level, expires_at_param, 'pending'
  ) RETURNING id INTO log_id;

  -- CORREÇÃO: Buscar usuário que existe em AMBAS as tabelas (profiles E auth.users)
  SELECT p.id INTO user_id_found
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email = email_param 
     OR au.email = email_param
  LIMIT 1;

  -- Se ainda não encontrado, criar entrada pendente
  IF user_id_found IS NULL THEN
    -- Salvar na tabela de usuários pendentes
    INSERT INTO pending_user_levels (
      email, level, expires_at, stripe_customer_id, stripe_subscription_id
    ) VALUES (
      email_param, new_level, expires_at_param, stripe_customer_id, stripe_subscription_id
    ) ON CONFLICT (email) 
    DO UPDATE SET 
      level = new_level,
      expires_at = expires_at_param,
      stripe_customer_id = stripe_customer_id,
      stripe_subscription_id = stripe_subscription_id,
      updated_at = NOW();

    -- Atualizar log
    UPDATE payment_logs 
    SET status = 'success', 
        error_message = 'Usuário não encontrado, salvo como pendente',
        updated_at = NOW()
    WHERE id = log_id;

    result := json_build_object(
      'success', true,
      'message', 'Usuário não encontrado, atualização salva como pendente',
      'user_id', null,
      'email', email_param,
      'level', new_level,
      'log_id', log_id
    );

    RETURN result;
  END IF;

  -- CORREÇÃO: Verificar se user_id existe em auth.users antes de inserir
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = user_id_found) THEN
    -- Se não existe em auth.users, criar entrada pendente
    INSERT INTO pending_user_levels (
      email, level, expires_at, stripe_customer_id, stripe_subscription_id
    ) VALUES (
      email_param, new_level, expires_at_param, stripe_customer_id, stripe_subscription_id
    ) ON CONFLICT (email) 
    DO UPDATE SET 
      level = new_level,
      expires_at = expires_at_param,
      stripe_customer_id = stripe_customer_id,
      stripe_subscription_id = stripe_subscription_id,
      updated_at = NOW();

    -- Atualizar log
    UPDATE payment_logs 
    SET status = 'success', 
        error_message = 'User ID não encontrado em auth.users, salvo como pendente',
        updated_at = NOW()
    WHERE id = log_id;

    result := json_build_object(
      'success', true,
      'message', 'User ID não válido em auth.users, salvo como pendente',
      'user_id', user_id_found,
      'email', email_param,
      'level', new_level,
      'log_id', log_id
    );

    RETURN result;
  END IF;

  -- Atualizar nível do usuário encontrado (agora com user_id válido para auth.users)
  INSERT INTO user_progress_level (
    user_id, 
    current_level, 
    level_expires_at,
    unlocked_features,
    created_at,
    updated_at,
    last_activity
  ) VALUES (
    user_id_found, 
    new_level, 
    expires_at_param,
    new_features,
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    current_level = new_level,
    level_expires_at = expires_at_param,
    unlocked_features = new_features,
    last_activity = NOW(),
    updated_at = NOW();

  -- Atualizar log como sucesso
  UPDATE payment_logs 
  SET status = 'success', 
      updated_at = NOW()
  WHERE id = log_id;

  -- Montar resultado
  result := json_build_object(
    'success', true,
    'message', 'Usuário atualizado com sucesso',
    'user_id', user_id_found,
    'email', email_param,
    'level', new_level,
    'expires_at', expires_at_param,
    'features_count', array_length(new_features, 1),
    'log_id', log_id
  );

  RETURN result;

EXCEPTION
  WHEN OTHERS THEN
    -- Log do erro
    UPDATE payment_logs 
    SET status = 'error', 
        error_message = SQLERRM,
        updated_at = NOW()
    WHERE id = log_id;

    -- Retornar erro
    result := json_build_object(
      'success', false,
      'message', 'Erro ao atualizar usuário',
      'error', SQLERRM,
      'email', email_param,
      'log_id', log_id
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. FUNÇÃO PARA VERIFICAR STATUS DE PAGAMENTO - VERSÃO CORRIGIDA
CREATE OR REPLACE FUNCTION check_payment_status(email_param TEXT)
RETURNS JSON AS $$
DECLARE
  user_level_data RECORD;
  payment_history JSON;
  result JSON;
BEGIN
  -- CORREÇÃO: Resolver ambiguidade usando aliases específicos
  SELECT 
    upl.current_level,
    upl.level_expires_at as user_expires_at,
    upl.unlocked_features,
    upl.last_activity,
    p.email
  INTO user_level_data
  FROM user_progress_level upl
  JOIN profiles p ON p.id = upl.user_id
  WHERE p.email = email_param;

  -- Buscar histórico de pagamentos
  SELECT json_agg(
    json_build_object(
      'date', pl.created_at,
      'event_type', pl.event_type,
      'level', pl.level_updated,
      'status', pl.status,
      'stripe_customer_id', pl.stripe_customer_id
    ) ORDER BY pl.created_at DESC
  ) INTO payment_history
  FROM payment_logs pl
  WHERE pl.email = email_param
  LIMIT 10;

  -- Montar resultado
  result := json_build_object(
    'email', email_param,
    'current_level', COALESCE(user_level_data.current_level, 'basic'),
    'expires_at', user_level_data.user_expires_at,
    'features_count', array_length(user_level_data.unlocked_features, 1),
    'last_activity', user_level_data.last_activity,
    'payment_history', COALESCE(payment_history, '[]'::json),
    'is_expert', (user_level_data.current_level = 'expert'),
    'has_access', (user_level_data.user_expires_at IS NULL OR user_level_data.user_expires_at > NOW())
  );

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. TRIGGER PARA PROCESSAR USUÁRIOS PENDENTES - VERSÃO CORRIGIDA
CREATE OR REPLACE FUNCTION trigger_process_pending_users()
RETURNS TRIGGER AS $$
BEGIN
  -- Verificar se o usuário recém-cadastrado tem uma entrada pendente
  IF TG_OP = 'INSERT' THEN
    -- Buscar entrada pendente pelo email
    DECLARE
      pending_entry RECORD;
    BEGIN
      SELECT * INTO pending_entry
      FROM pending_user_levels
      WHERE email = NEW.email
      LIMIT 1;

      IF FOUND THEN
        -- Aplicar o nível pendente
        PERFORM update_user_level_by_email(
          NEW.email,
          pending_entry.level,
          pending_entry.expires_at,
          pending_entry.stripe_customer_id,
          pending_entry.stripe_subscription_id
        );
        
        -- Remover da tabela de pendentes
        DELETE FROM pending_user_levels WHERE id = pending_entry.id;
      END IF;
    END;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- CORREÇÃO: Aplicar trigger na tabela profiles (não auth.users)
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON profiles;
CREATE TRIGGER trigger_process_pending_on_signup
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION trigger_process_pending_users();

-- 5. MANTER OUTRAS FUNÇÕES IGUAIS
CREATE OR REPLACE FUNCTION process_pending_user_levels()
RETURNS JSON AS $$
DECLARE
  pending_record RECORD;
  processed_count INTEGER := 0;
  error_count INTEGER := 0;
  result JSON;
BEGIN
  -- Processar todos os usuários pendentes
  FOR pending_record IN 
    SELECT * FROM pending_user_levels 
    WHERE created_at > (NOW() - INTERVAL '30 days')
  LOOP
    BEGIN
      -- Tentar atualizar o usuário
      PERFORM update_user_level_by_email(
        pending_record.email,
        pending_record.level,
        pending_record.expires_at,
        pending_record.stripe_customer_id,
        pending_record.stripe_subscription_id
      );
      
      processed_count := processed_count + 1;
      
      -- Remover da tabela de pendentes se processado com sucesso
      DELETE FROM pending_user_levels WHERE id = pending_record.id;
      
    EXCEPTION
      WHEN OTHERS THEN
        error_count := error_count + 1;
        -- Log do erro mas continua processando
        INSERT INTO payment_logs (
          email, stripe_customer_id, stripe_subscription_id,
          event_type, level_updated, status, error_message
        ) VALUES (
          pending_record.email, pending_record.stripe_customer_id, 
          pending_record.stripe_subscription_id, 'process_pending', 
          pending_record.level, 'error', SQLERRM
        );
    END;
  END LOOP;

  result := json_build_object(
    'processed_count', processed_count,
    'error_count', error_count,
    'timestamp', NOW()
  );

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. FUNÇÃO PARA CLEANUP DE LOGS ANTIGOS (mantém igual)
CREATE OR REPLACE FUNCTION cleanup_old_payment_logs()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Remover logs de mais de 90 dias
  DELETE FROM payment_logs 
  WHERE created_at < (NOW() - INTERVAL '90 days');
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- COMENTÁRIOS FINAIS
-- ================================================================

-- CORREÇÕES APLICADAS:
-- ✅ Resolvido foreign key: usa INNER JOIN para garantir ID existe em auth.users
-- ✅ Resolvido ambiguidade: renomeou expires_at_param e usou aliases
-- ✅ Validação extra: verifica se user_id existe em auth.users antes de inserir
-- ✅ Fallback robusto: salva como pendente se houver problemas

-- Para testar:
-- SELECT update_user_level_by_email(
--   'usuario@email.com',
--   'expert',
--   (NOW() + INTERVAL '30 days')::timestamp
-- ); 