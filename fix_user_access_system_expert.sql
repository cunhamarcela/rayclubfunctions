-- ========================================
-- CORREÇÃO DO SISTEMA PARA USAR BASIC/EXPERT
-- ========================================

-- 1. Primeiro, fazer backup dos dados atuais
CREATE TABLE IF NOT EXISTS user_progress_level_backup AS 
SELECT * FROM user_progress_level;

-- 2. Atualizar a constraint para aceitar 'expert'
ALTER TABLE user_progress_level 
DROP CONSTRAINT IF EXISTS user_progress_level_current_level_check;

ALTER TABLE user_progress_level 
ADD CONSTRAINT user_progress_level_current_level_check 
CHECK (current_level IN ('basic', 'expert', 'premium'));

-- 3. Migrar usuários premium para expert
UPDATE user_progress_level 
SET current_level = 'expert',
    updated_at = NOW()
WHERE current_level = 'premium';

-- 4. Atualizar features para o padrão correto
UPDATE user_progress_level 
SET unlocked_features = ARRAY[
    'basic_workouts', 
    'profile', 
    'basic_challenges', 
    'workout_recording'
]
WHERE current_level = 'basic';

UPDATE user_progress_level 
SET unlocked_features = ARRAY[
    'basic_workouts', 
    'profile', 
    'basic_challenges', 
    'workout_recording',
    'enhanced_dashboard', 
    'nutrition_guide', 
    'workout_library', 
    'advanced_tracking', 
    'detailed_reports'
]
WHERE current_level = 'expert';

-- 5. Remover 'premium' da constraint
ALTER TABLE user_progress_level 
DROP CONSTRAINT IF EXISTS user_progress_level_current_level_check;

ALTER TABLE user_progress_level 
ADD CONSTRAINT user_progress_level_current_level_check 
CHECK (current_level IN ('basic', 'expert'));

-- 6. Recriar a função check_user_access_level com a nomenclatura correta
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
    INSERT INTO user_progress_level (
      user_id, 
      current_level, 
      unlocked_features
    ) VALUES (
      user_id_param, 
      'basic', 
      ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording']
    )
    ON CONFLICT (user_id) DO NOTHING;
    
    user_level := 'basic';
    features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
  END IF;
  
  -- Verificar se o acesso ainda é válido
  IF expires_at IS NOT NULL AND expires_at < NOW() THEN
    -- Acesso premium expirado, voltar para básico
    UPDATE user_progress_level 
    SET current_level = 'basic',
        unlocked_features = ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'],
        level_expires_at = NULL,
        updated_at = NOW()
    WHERE user_id = user_id_param;
    
    user_level := 'basic';
    features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
    expires_at := NULL;
  END IF;
  
  -- Se for expert, garantir que tem todas as features
  IF user_level = 'expert' THEN
    features := ARRAY[
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
  END IF;
  
  -- Montar resultado
  result := json_build_object(
    'user_id', user_id_param,
    'has_extended_access', user_level = 'expert',
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

-- 7. Atualizar a função update_user_level
CREATE OR REPLACE FUNCTION update_user_level(
  user_id_param UUID,
  new_level TEXT DEFAULT 'expert',
  expires_at TIMESTAMP DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  new_features TEXT[];
BEGIN
  -- Validar nível
  IF new_level NOT IN ('basic', 'expert') THEN
    new_level := 'expert';
  END IF;
  
  -- Definir features baseado no nível
  CASE new_level
    WHEN 'expert' THEN
      new_features := ARRAY[
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
    ELSE -- basic
      new_features := ARRAY[
        'basic_workouts', 
        'profile', 
        'basic_challenges', 
        'workout_recording'
      ];
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

-- 8. Criar a tabela pending_user_levels se não existir
CREATE TABLE IF NOT EXISTS pending_user_levels (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  level TEXT NOT NULL CHECK (level IN ('basic', 'expert')),
  expires_at TIMESTAMP WITH TIME ZONE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Criar índice se não existir
CREATE INDEX IF NOT EXISTS idx_pending_user_levels_email ON pending_user_levels(email);

-- 10. Criar trigger para aplicar nível pendente ao criar conta
CREATE OR REPLACE FUNCTION apply_pending_level_on_signup()
RETURNS TRIGGER AS $$
DECLARE
  pending_record RECORD;
BEGIN
  -- Buscar nível pendente para o email do novo usuário
  SELECT * INTO pending_record
  FROM pending_user_levels
  WHERE email = NEW.email
  ORDER BY updated_at DESC
  LIMIT 1;
  
  IF pending_record IS NOT NULL THEN
    -- Aplicar o nível diretamente
    INSERT INTO user_progress_level (
      user_id,
      current_level,
      level_expires_at,
      unlocked_features,
      created_at,
      updated_at
    )
    SELECT 
      NEW.id,
      pending_record.level,
      pending_record.expires_at,
      CASE 
        WHEN pending_record.level = 'expert' THEN
          ARRAY[
            'basic_workouts',
            'profile',
            'basic_challenges',
            'workout_recording',
            'enhanced_dashboard',
            'nutrition_guide',
            'workout_library',
            'advanced_tracking',
            'detailed_reports'
          ]
        ELSE
          ARRAY[
            'basic_workouts',
            'profile',
            'basic_challenges',
            'workout_recording'
          ]
      END,
      NOW(),
      NOW()
    ON CONFLICT (user_id) DO NOTHING;
    
    -- Marcar como aplicado
    UPDATE pending_user_levels
    SET metadata = metadata || jsonb_build_object(
      'applied_at', NOW(),
      'applied_to_user_id', NEW.id
    )
    WHERE id = pending_record.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar o trigger
DROP TRIGGER IF EXISTS on_auth_user_created_apply_level ON auth.users;
CREATE TRIGGER on_auth_user_created_apply_level
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION apply_pending_level_on_signup();

-- 11. Habilitar RLS
ALTER TABLE pending_user_levels ENABLE ROW LEVEL SECURITY;

-- Políticas para pending_user_levels
CREATE POLICY "Apenas sistema pode gerenciar níveis pendentes"
  ON pending_user_levels FOR ALL
  USING (auth.role() = 'service_role');

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================

-- Verificar se tudo está correto
SELECT 
  current_level,
  COUNT(*) as total_users,
  array_agg(DISTINCT unlocked_features) as features_by_level
FROM user_progress_level
GROUP BY current_level;

-- Verificar se há níveis pendentes
SELECT * FROM pending_user_levels ORDER BY created_at DESC LIMIT 10; 