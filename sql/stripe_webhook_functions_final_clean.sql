-- ================================================================
-- FUNÇÕES SQL PARA STRIPE WEBHOOK - VERSÃO FINAL DEFINITIVA
-- Data: 2025-01-19
-- Fix: Remove TODAS as assinaturas específicas da função
-- ================================================================

-- PASSO 1: REMOVER TRIGGERS PRIMEIRO
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON auth.users CASCADE;
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON profiles CASCADE;

-- PASSO 2: REMOVER TODAS AS POSSÍVEIS ASSINATURAS DA FUNÇÃO
-- (Esta é a parte crítica - remover TODAS as versões possíveis)

DROP FUNCTION IF EXISTS update_user_level_by_email() CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp without time zone) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp with time zone) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp without time zone, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp with time zone, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp, text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp without time zone, text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp with time zone, text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp, text, text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp without time zone, text, text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, text, timestamp with time zone, text, text, text) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, unknown, timestamp) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, unknown, timestamp without time zone) CASCADE;
DROP FUNCTION IF EXISTS update_user_level_by_email(text, unknown, timestamp with time zone) CASCADE;

-- Remover outras funções também
DROP FUNCTION IF EXISTS check_payment_status() CASCADE;
DROP FUNCTION IF EXISTS check_payment_status(text) CASCADE;
DROP FUNCTION IF EXISTS process_pending_user_levels() CASCADE;
DROP FUNCTION IF EXISTS trigger_process_pending_users() CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_payment_logs() CASCADE;

-- PASSO 3: VERIFICAR SE TODAS FORAM REMOVIDAS
DO $$
DECLARE
    func_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO func_count
    FROM information_schema.routines 
    WHERE routine_schema = 'public' 
      AND routine_name = 'update_user_level_by_email';
    
    IF func_count > 0 THEN
        RAISE NOTICE 'AVISO: Ainda existem % versões da função update_user_level_by_email', func_count;
    ELSE
        RAISE NOTICE 'SUCESSO: Todas as versões da função foram removidas';
    END IF;
END $$;

-- PASSO 4: CRIAR TABELA DE LOGS
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

-- Índices
CREATE INDEX IF NOT EXISTS idx_payment_logs_email ON payment_logs(email);
CREATE INDEX IF NOT EXISTS idx_payment_logs_stripe_customer ON payment_logs(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_logs_event_id ON payment_logs(stripe_event_id);
CREATE INDEX IF NOT EXISTS idx_payment_logs_status ON payment_logs(status);

-- PASSO 5: CRIAR A FUNÇÃO ÚNICA E DEFINITIVA
CREATE FUNCTION stripe_update_user_level(
  email_input TEXT,
  level_input TEXT DEFAULT 'expert',
  expires_input TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  customer_id_input TEXT DEFAULT NULL,
  subscription_id_input TEXT DEFAULT NULL,
  event_id_input TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_id_var UUID;
  expert_features_var TEXT[];
  basic_features_var TEXT[];
  features_var TEXT[];
  log_id_var UUID;
  result_var JSON;
BEGIN
  -- Features disponíveis
  expert_features_var := ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
    'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
    'advanced_tracking', 'detailed_reports'
  ];
  
  basic_features_var := ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording'
  ];

  -- Validar nível
  IF level_input NOT IN ('basic', 'expert') THEN
    level_input := 'expert';
  END IF;
  
  -- Definir features
  IF level_input = 'expert' THEN
    features_var := expert_features_var;
  ELSE
    features_var := basic_features_var;
  END IF;

  -- Criar log
  INSERT INTO payment_logs (
    email, stripe_customer_id, stripe_subscription_id, stripe_event_id,
    event_type, level_updated, expires_at, status
  ) VALUES (
    email_input, customer_id_input, subscription_id_input, event_id_input,
    'user_level_update', level_input, expires_input, 'pending'
  ) RETURNING id INTO log_id_var;

  -- Buscar usuário
  SELECT p.id INTO user_id_var
  FROM profiles p
  INNER JOIN auth.users au ON au.id = p.id
  WHERE p.email = email_input 
     OR au.email = email_input
  LIMIT 1;

  -- Se não encontrado, salvar como pendente
  IF user_id_var IS NULL THEN
    INSERT INTO pending_user_levels (
      email, level, expires_at, stripe_customer_id, stripe_subscription_id
    ) VALUES (
      email_input, level_input, expires_input, customer_id_input, subscription_id_input
    ) ON CONFLICT (email) 
    DO UPDATE SET 
      level = level_input,
      expires_at = expires_input,
      stripe_customer_id = customer_id_input,
      stripe_subscription_id = subscription_id_input,
      updated_at = NOW();

    UPDATE payment_logs 
    SET status = 'success', 
        error_message = 'Usuário não encontrado, salvo como pendente',
        updated_at = NOW()
    WHERE id = log_id_var;

    result_var := json_build_object(
      'success', true,
      'message', 'Usuário não encontrado, salvo como pendente',
      'user_id', null,
      'email', email_input,
      'level', level_input,
      'log_id', log_id_var
    );

    RETURN result_var;
  END IF;

  -- Atualizar usuário
  INSERT INTO user_progress_level (
    user_id, current_level, level_expires_at, unlocked_features,
    created_at, updated_at, last_activity
  ) VALUES (
    user_id_var, level_input, expires_input, features_var,
    NOW(), NOW(), NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    current_level = level_input,
    level_expires_at = expires_input,
    unlocked_features = features_var,
    last_activity = NOW(),
    updated_at = NOW();

  -- Atualizar log
  UPDATE payment_logs 
  SET status = 'success', updated_at = NOW()
  WHERE id = log_id_var;

  -- Resultado
  result_var := json_build_object(
    'success', true,
    'message', 'Usuário atualizado com sucesso',
    'user_id', user_id_var,
    'email', email_input,
    'level', level_input,
    'expires_at', expires_input,
    'features_count', array_length(features_var, 1),
    'log_id', log_id_var
  );

  RETURN result_var;

EXCEPTION
  WHEN OTHERS THEN
    UPDATE payment_logs 
    SET status = 'error', error_message = SQLERRM, updated_at = NOW()
    WHERE id = log_id_var;

    result_var := json_build_object(
      'success', false,
      'message', 'Erro ao atualizar usuário',
      'error', SQLERRM,
      'email', email_input,
      'log_id', log_id_var
    );

    RETURN result_var;
END;
$$;

-- PASSO 6: OUTRAS FUNÇÕES AUXILIARES
CREATE FUNCTION stripe_check_payment_status(email_input TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_data_var RECORD;
  payment_history_var JSON;
  result_var JSON;
BEGIN
  SELECT 
    upl.current_level,
    upl.level_expires_at,
    upl.unlocked_features,
    upl.last_activity,
    p.email
  INTO user_data_var
  FROM user_progress_level upl
  JOIN profiles p ON p.id = upl.user_id
  WHERE p.email = email_input;

  SELECT json_agg(
    json_build_object(
      'date', pl.created_at,
      'event_type', pl.event_type,
      'level', pl.level_updated,
      'status', pl.status
    ) ORDER BY pl.created_at DESC
  ) INTO payment_history_var
  FROM payment_logs pl
  WHERE pl.email = email_input
  LIMIT 10;

  result_var := json_build_object(
    'email', email_input,
    'current_level', COALESCE(user_data_var.current_level, 'basic'),
    'expires_at', user_data_var.level_expires_at,
    'features_count', array_length(user_data_var.unlocked_features, 1),
    'last_activity', user_data_var.last_activity,
    'payment_history', COALESCE(payment_history_var, '[]'::json),
    'is_expert', (user_data_var.current_level = 'expert'),
    'has_access', (user_data_var.level_expires_at IS NULL OR user_data_var.level_expires_at > NOW())
  );

  RETURN result_var;
END;
$$;

-- PASSO 7: VERIFICAÇÃO FINAL
SELECT 'Sistema Stripe criado com sucesso!' as resultado;

-- Verificar se há apenas UMA função agora
SELECT 
  routine_name,
  COUNT(*) as versoes,
  CASE 
    WHEN COUNT(*) = 1 THEN '✅ ÚNICA VERSÃO'
    ELSE '❌ AINDA HÁ MÚLTIPLAS'
  END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('stripe_update_user_level', 'stripe_check_payment_status')
GROUP BY routine_name
ORDER BY routine_name; 