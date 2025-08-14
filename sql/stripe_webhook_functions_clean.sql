-- ================================================================
-- FUNÇÕES SQL PARA STRIPE WEBHOOK - VERSÃO LIMPA DEFINITIVA
-- Data: 2025-01-19
-- Fix: Remove TODAS as versões da função para acabar com ambiguidade
-- ================================================================

-- PASSO 1: REMOVER TODOS OS TRIGGERS
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON auth.users CASCADE;
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON profiles CASCADE;

-- PASSO 2: REMOVER TODAS AS FUNÇÕES (TODAS AS VERSÕES POSSÍVEIS)
DROP FUNCTION IF EXISTS update_user_level_by_email CASCADE;
DROP FUNCTION IF EXISTS check_payment_status CASCADE;
DROP FUNCTION IF EXISTS process_pending_user_levels CASCADE;
DROP FUNCTION IF EXISTS trigger_process_pending_users CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_payment_logs CASCADE;

-- PASSO 3: CRIAR TABELA DE LOGS (SE NÃO EXISTIR)
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

-- PASSO 4: FUNÇÃO PRINCIPAL - ÚNICA VERSÃO
CREATE FUNCTION update_user_level_by_email(
  p_email TEXT,
  p_new_level TEXT DEFAULT 'expert',
  p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  p_stripe_customer_id TEXT DEFAULT NULL,
  p_stripe_subscription_id TEXT DEFAULT NULL,
  p_stripe_event_id TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_expert_features TEXT[];
  v_basic_features TEXT[];
  v_new_features TEXT[];
  v_log_id UUID;
  v_result JSON;
BEGIN
  -- Definir features disponíveis
  v_expert_features := ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
    'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
    'advanced_tracking', 'detailed_reports'
  ];
  
  v_basic_features := ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording'
  ];

  -- Validar nível
  IF p_new_level NOT IN ('basic', 'expert') THEN
    p_new_level := 'expert';
  END IF;
  
  -- Definir features baseado no nível
  IF p_new_level = 'expert' THEN
    v_new_features := v_expert_features;
  ELSE
    v_new_features := v_basic_features;
  END IF;

  -- Criar log de tentativa
  INSERT INTO payment_logs (
    email, stripe_customer_id, stripe_subscription_id, stripe_event_id,
    event_type, level_updated, expires_at, status
  ) VALUES (
    p_email, p_stripe_customer_id, p_stripe_subscription_id, p_stripe_event_id,
    'user_level_update', p_new_level, p_expires_at, 'pending'
  ) RETURNING id INTO v_log_id;

  -- Buscar usuário que existe em AMBAS as tabelas
  SELECT p.id INTO v_user_id
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email = p_email 
     OR au.email = p_email
  LIMIT 1;

  -- Se não encontrado, criar entrada pendente
  IF v_user_id IS NULL THEN
    -- Salvar na tabela de usuários pendentes
    INSERT INTO pending_user_levels (
      email, level, expires_at, stripe_customer_id, stripe_subscription_id
    ) VALUES (
      p_email, p_new_level, p_expires_at, p_stripe_customer_id, p_stripe_subscription_id
    ) ON CONFLICT (email) 
    DO UPDATE SET 
      level = p_new_level,
      expires_at = p_expires_at,
      stripe_customer_id = p_stripe_customer_id,
      stripe_subscription_id = p_stripe_subscription_id,
      updated_at = NOW();

    -- Atualizar log
    UPDATE payment_logs 
    SET status = 'success', 
        error_message = 'Usuário não encontrado, salvo como pendente',
        updated_at = NOW()
    WHERE id = v_log_id;

    v_result := json_build_object(
      'success', true,
      'message', 'Usuário não encontrado, atualização salva como pendente',
      'user_id', null,
      'email', p_email,
      'level', p_new_level,
      'log_id', v_log_id
    );

    RETURN v_result;
  END IF;

  -- Atualizar nível do usuário encontrado
  INSERT INTO user_progress_level (
    user_id, 
    current_level, 
    level_expires_at,
    unlocked_features,
    created_at,
    updated_at,
    last_activity
  ) VALUES (
    v_user_id, 
    p_new_level, 
    p_expires_at,
    v_new_features,
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    current_level = p_new_level,
    level_expires_at = p_expires_at,
    unlocked_features = v_new_features,
    last_activity = NOW(),
    updated_at = NOW();

  -- Atualizar log como sucesso
  UPDATE payment_logs 
  SET status = 'success', 
      updated_at = NOW()
  WHERE id = v_log_id;

  -- Montar resultado
  v_result := json_build_object(
    'success', true,
    'message', 'Usuário atualizado com sucesso',
    'user_id', v_user_id,
    'email', p_email,
    'level', p_new_level,
    'expires_at', p_expires_at,
    'features_count', array_length(v_new_features, 1),
    'log_id', v_log_id
  );

  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    -- Log do erro
    UPDATE payment_logs 
    SET status = 'error', 
        error_message = SQLERRM,
        updated_at = NOW()
    WHERE id = v_log_id;

    -- Retornar erro
    v_result := json_build_object(
      'success', false,
      'message', 'Erro ao atualizar usuário',
      'error', SQLERRM,
      'email', p_email,
      'log_id', v_log_id
    );

    RETURN v_result;
END;
$$;

-- PASSO 5: FUNÇÃO PARA VERIFICAR STATUS
CREATE FUNCTION check_payment_status(p_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_level_data RECORD;
  v_payment_history JSON;
  v_result JSON;
BEGIN
  -- Buscar dados do usuário
  SELECT 
    upl.current_level,
    upl.level_expires_at,
    upl.unlocked_features,
    upl.last_activity,
    p.email
  INTO v_user_level_data
  FROM user_progress_level upl
  JOIN profiles p ON p.id = upl.user_id
  WHERE p.email = p_email;

  -- Buscar histórico de pagamentos
  SELECT json_agg(
    json_build_object(
      'date', pl.created_at,
      'event_type', pl.event_type,
      'level', pl.level_updated,
      'status', pl.status,
      'stripe_customer_id', pl.stripe_customer_id
    ) ORDER BY pl.created_at DESC
  ) INTO v_payment_history
  FROM payment_logs pl
  WHERE pl.email = p_email
  LIMIT 10;

  -- Montar resultado
  v_result := json_build_object(
    'email', p_email,
    'current_level', COALESCE(v_user_level_data.current_level, 'basic'),
    'expires_at', v_user_level_data.level_expires_at,
    'features_count', array_length(v_user_level_data.unlocked_features, 1),
    'last_activity', v_user_level_data.last_activity,
    'payment_history', COALESCE(v_payment_history, '[]'::json),
    'is_expert', (v_user_level_data.current_level = 'expert'),
    'has_access', (v_user_level_data.level_expires_at IS NULL OR v_user_level_data.level_expires_at > NOW())
  );

  RETURN v_result;
END;
$$;

-- PASSO 6: FUNÇÃO PARA PROCESSAR PENDENTES
CREATE FUNCTION process_pending_user_levels()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pending_record RECORD;
  v_processed_count INTEGER := 0;
  v_error_count INTEGER := 0;
  v_result JSON;
BEGIN
  -- Processar todos os usuários pendentes
  FOR v_pending_record IN 
    SELECT * FROM pending_user_levels 
    WHERE created_at > (NOW() - INTERVAL '30 days')
  LOOP
    BEGIN
      -- Tentar atualizar o usuário
      PERFORM update_user_level_by_email(
        v_pending_record.email,
        v_pending_record.level,
        v_pending_record.expires_at,
        v_pending_record.stripe_customer_id,
        v_pending_record.stripe_subscription_id
      );
      
      v_processed_count := v_processed_count + 1;
      DELETE FROM pending_user_levels WHERE id = v_pending_record.id;
      
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        INSERT INTO payment_logs (
          email, stripe_customer_id, stripe_subscription_id,
          event_type, level_updated, status, error_message
        ) VALUES (
          v_pending_record.email, v_pending_record.stripe_customer_id, 
          v_pending_record.stripe_subscription_id, 'process_pending', 
          v_pending_record.level, 'error', SQLERRM
        );
    END;
  END LOOP;

  v_result := json_build_object(
    'processed_count', v_processed_count,
    'error_count', v_error_count,
    'timestamp', NOW()
  );

  RETURN v_result;
END;
$$;

-- PASSO 7: FUNÇÃO DO TRIGGER
CREATE FUNCTION trigger_process_pending_users()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pending_entry RECORD;
BEGIN
  IF TG_OP = 'INSERT' THEN
    SELECT * INTO v_pending_entry
    FROM pending_user_levels
    WHERE email = NEW.email
    LIMIT 1;

    IF FOUND THEN
      PERFORM update_user_level_by_email(
        NEW.email,
        v_pending_entry.level,
        v_pending_entry.expires_at,
        v_pending_entry.stripe_customer_id,
        v_pending_entry.stripe_subscription_id
      );
      
      DELETE FROM pending_user_levels WHERE id = v_pending_entry.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- PASSO 8: CRIAR TRIGGER
CREATE TRIGGER trigger_process_pending_on_signup
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION trigger_process_pending_users();

-- PASSO 9: FUNÇÃO CLEANUP
CREATE FUNCTION cleanup_old_payment_logs()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  DELETE FROM payment_logs 
  WHERE created_at < (NOW() - INTERVAL '90 days');
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  
  RETURN v_deleted_count;
END;
$$;

-- ================================================================
-- VERIFICAÇÃO FINAL
-- ================================================================

SELECT 'Sistema Stripe criado com sucesso!' as resultado;

-- Verificar se há apenas UMA versão de cada função
SELECT 
  routine_name,
  COUNT(*) as versoes
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'update_user_level_by_email',
    'check_payment_status',
    'process_pending_user_levels',
    'trigger_process_pending_users',
    'cleanup_old_payment_logs'
  )
GROUP BY routine_name
ORDER BY routine_name; 