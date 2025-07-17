-- ========================================
-- SISTEMA DE ACESSO E NÍVEIS DE USUÁRIO
-- ========================================
-- Este sistema permite gerenciar diferentes níveis de acesso no app
-- sem qualquer referência a pagamentos ou sistemas externos

-- 1. Tabela principal para armazenar níveis e progresso dos usuários
CREATE TABLE IF NOT EXISTS user_progress_level (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  current_level TEXT NOT NULL DEFAULT 'basic' CHECK (current_level IN ('basic', 'pro', 'expert')),
  level_expires_at TIMESTAMP,
  unlocked_features TEXT[] DEFAULT ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_activity TIMESTAMP DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_progress_level_user_id ON user_progress_level(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_level_current_level ON user_progress_level(current_level);
CREATE INDEX IF NOT EXISTS idx_user_progress_level_expires_at ON user_progress_level(level_expires_at);

-- 2. Função principal para verificar nível de acesso completo
CREATE OR REPLACE FUNCTION check_user_access_level(
  user_id_param UUID
)
RETURNS JSON AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP;
  features TEXT[];
  result JSON;
BEGIN
  -- Buscar dados do usuário
  SELECT 
    current_level,
    level_expires_at,
    unlocked_features
  INTO 
    user_level,
    expires_at,
    features
  FROM user_progress_level 
  WHERE user_id = user_id_param;
  
  -- Se usuário não existe, criar com nível básico
  IF user_level IS NULL THEN
    INSERT INTO user_progress_level (user_id, current_level, unlocked_features)
    VALUES (user_id_param, 'basic', ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'])
    ON CONFLICT (user_id) DO NOTHING;
    
    user_level := 'basic';
    features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
  END IF;
  
  -- Verificar se acesso está expirado
  IF expires_at IS NOT NULL AND expires_at <= NOW() THEN
    -- Rebaixar para básico se expirado
    UPDATE user_progress_level 
    SET 
      current_level = 'basic',
      level_expires_at = NULL,
      unlocked_features = ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'],
      updated_at = NOW()
    WHERE user_id = user_id_param;
    
    user_level := 'basic';
    features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
    expires_at := NULL;
  END IF;
  
  -- Montar resultado
  result := json_build_object(
    'user_id', user_id_param,
    'has_extended_access', user_level != 'basic',
    'access_level', user_level,
    'valid_until', expires_at,
    'last_verified', NOW(),
    'available_features', features
  );
  
  -- Atualizar última atividade
  UPDATE user_progress_level 
  SET last_activity = NOW()
  WHERE user_id = user_id_param;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Função para verificar acesso a feature específica
CREATE OR REPLACE FUNCTION check_feature_access(
  user_id_param UUID,
  feature_key_param TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  user_features TEXT[];
  has_access BOOLEAN := FALSE;
BEGIN
  -- Buscar features do usuário
  SELECT unlocked_features
  INTO user_features
  FROM user_progress_level 
  WHERE user_id = user_id_param
    AND (level_expires_at IS NULL OR level_expires_at > NOW());
  
  -- Se usuário não encontrado ou acesso expirado, features básicas apenas
  IF user_features IS NULL THEN
    user_features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
  END IF;
  
  -- Verificar se a feature está na lista
  has_access := feature_key_param = ANY(user_features);
  
  RETURN has_access;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Função para atualizar nível do usuário manualmente
CREATE OR REPLACE FUNCTION update_user_level(
  user_id_param UUID,
  new_level TEXT,
  expires_at TIMESTAMP DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  new_features TEXT[];
BEGIN
  -- Definir features baseado no nível
  CASE new_level
    WHEN 'expert' THEN
      new_features := ARRAY[
        'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
        'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
        'advanced_tracking', 'detailed_reports'
      ];
    WHEN 'pro' THEN
      new_features := ARRAY[
        'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
        'enhanced_dashboard', 'nutrition_guide', 'advanced_tracking'
      ];
    ELSE -- basic
      new_features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
  END CASE;
  
  -- Atualizar ou inserir
  INSERT INTO user_progress_level (
    user_id, 
    current_level, 
    level_expires_at,
    unlocked_features,
    updated_at
  ) VALUES (
    user_id_param, 
    new_level, 
    expires_at,
    new_features,
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    current_level = new_level,
    level_expires_at = expires_at,
    unlocked_features = new_features,
    last_activity = NOW(),
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Função para revalidar acesso
CREATE OR REPLACE FUNCTION refresh_user_level(
  user_id_param UUID
)
RETURNS JSON AS $$
DECLARE
  current_data JSON;
BEGIN
  -- Retorna os dados atuais do usuário
  SELECT check_user_access_level(user_id_param) INTO current_data;
  
  RETURN current_data;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Função para tracking de tentativas de acesso (analytics)
CREATE OR REPLACE FUNCTION track_user_progress(
  user_id_param UUID,
  feature_key_param TEXT,
  timestamp_param TIMESTAMP
)
RETURNS VOID AS $$
BEGIN
  -- Inserir log de tentativa (para analytics futuras)
  INSERT INTO user_access_logs (
    user_id,
    feature_key,
    accessed_at,
    has_access
  ) VALUES (
    user_id_param,
    feature_key_param,
    timestamp_param,
    check_feature_access(user_id_param, feature_key_param)
  )
  ON CONFLICT DO NOTHING;
  
EXCEPTION
  WHEN undefined_table THEN
    -- Tabela de logs não existe ainda, ignorar
    NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Tabela de logs de acesso (opcional, para analytics)
CREATE TABLE IF NOT EXISTS user_access_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  feature_key TEXT NOT NULL,
  accessed_at TIMESTAMP NOT NULL,
  has_access BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_access_logs_user_id ON user_access_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_access_logs_feature_key ON user_access_logs(feature_key);
CREATE INDEX IF NOT EXISTS idx_user_access_logs_accessed_at ON user_access_logs(accessed_at);

-- 8. Configurar RLS (Row Level Security)
ALTER TABLE user_progress_level ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_access_logs ENABLE ROW LEVEL SECURITY;

-- Política para user_progress_level - usuários só veem seus próprios dados
CREATE POLICY "Users can view own progress level" ON user_progress_level
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own progress level" ON user_progress_level
  FOR UPDATE USING (auth.uid() = user_id);

-- Política para user_access_logs - usuários só veem seus próprios logs
CREATE POLICY "Users can view own access logs" ON user_access_logs
  FOR SELECT USING (auth.uid() = user_id);

-- ========================================
-- CONCLUÍDO
-- ========================================
-- O sistema está configurado e pronto para uso.
-- 
-- Exemplo de uso no Flutter:
-- - Para verificar acesso: check_feature_access(user_id, 'enhanced_dashboard')
-- - Para dados completos: check_user_access_level(user_id)
-- - Para atualizar nível: update_user_level(user_id, 'expert', '2024-12-31 23:59:59') 