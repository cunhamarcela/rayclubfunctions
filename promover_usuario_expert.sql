-- ========================================
-- PROMOVER USUÁRIO PARA EXPERT PERMANENTE
-- ========================================
-- Script simplificado para garantir acesso expert completo

-- 1. Definir todas as features expert
CREATE OR REPLACE FUNCTION get_expert_features()
RETURNS TEXT[] AS $$
BEGIN
  RETURN ARRAY[
    'basic_workouts',
    'profile', 
    'basic_challenges',
    'workout_recording',
    'enhanced_dashboard',
    'nutrition_guide',
    'workout_library',
    'advanced_tracking',
    'detailed_reports'
  ];
END;
$$ LANGUAGE plpgsql;

-- 2. Função para garantir acesso expert
CREATE OR REPLACE FUNCTION ensure_expert_access(user_id_param UUID)
RETURNS VOID AS $$
DECLARE
  expert_features TEXT[];
BEGIN
  expert_features := get_expert_features();
  
  INSERT INTO user_progress_level (
    user_id,
    current_level,
    unlocked_features,
    level_expires_at,
    created_at,
    updated_at,
    last_activity
  ) VALUES (
    user_id_param,
    'expert',
    expert_features,
    NULL, -- NULL = acesso permanente
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    current_level = 'expert',
    unlocked_features = expert_features,
    level_expires_at = NULL,
    updated_at = NOW(),
    last_activity = NOW();
    
  RAISE NOTICE 'Usuário % configurado como expert permanente', user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Promover usuário atual para expert
SELECT ensure_expert_access('01d4a292-1873-4af6-948b-a55eed56d6b9');

-- 4. Verificar se foi aplicado
SELECT 
  user_id,
  current_level,
  level_expires_at,
  array_length(unlocked_features, 1) as total_features,
  unlocked_features
FROM user_progress_level
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 5. Função para verificar acesso (atualizada)
CREATE OR REPLACE FUNCTION check_user_access_level(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP;
  features TEXT[];
  result JSON;
  expert_features TEXT[];
BEGIN
  expert_features := get_expert_features();
  
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
    INSERT INTO user_progress_level (
      user_id, 
      current_level, 
      unlocked_features,
      created_at,
      updated_at,
      last_activity
    ) VALUES (
      user_id_param, 
      'basic', 
      ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'],
      NOW(),
      NOW(),
      NOW()
    );
    
    user_level := 'basic';
    features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
  END IF;
  
  -- Se for expert, garantir que tem TODAS as features
  IF user_level = 'expert' THEN
    features := expert_features;
    
    UPDATE user_progress_level 
    SET unlocked_features = expert_features,
        last_activity = NOW()
    WHERE user_id = user_id_param;
  END IF;
  
  result := json_build_object(
    'user_id', user_id_param,
    'has_extended_access', user_level = 'expert',
    'access_level', user_level,
    'valid_until', expires_at,
    'last_verified', NOW(),
    'available_features', features
  );
  
  UPDATE user_progress_level 
  SET last_activity = NOW()
  WHERE user_id = user_id_param;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Teste final
SELECT check_user_access_level('01d4a292-1873-4af6-948b-a55eed56d6b9'); 