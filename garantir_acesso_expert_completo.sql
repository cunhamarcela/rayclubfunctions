-- ========================================
-- GARANTIR ACESSO COMPLETO PARA USUÁRIOS EXPERT
-- ========================================
-- Este script garante que usuários com nível 'expert' tenham acesso
-- completo e permanente a todas as features do app

-- 1. Verificar estrutura atual da tabela
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'user_progress_level' 
ORDER BY ordinal_position;

-- 2. Verificar constraint atual
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%user_progress_level%';

-- 3. Atualizar constraint para aceitar 'expert' se necessário
ALTER TABLE user_progress_level 
DROP CONSTRAINT IF EXISTS user_progress_level_current_level_check;

ALTER TABLE user_progress_level 
ADD CONSTRAINT user_progress_level_current_level_check 
CHECK (current_level IN ('basic', 'expert'));

-- 4. Definir todas as features disponíveis no sistema
-- Features básicas (disponíveis para todos)
-- Features expert (disponíveis apenas para usuários expert)
CREATE OR REPLACE FUNCTION get_expert_features()
RETURNS TEXT[] AS $$
BEGIN
  RETURN ARRAY[
    -- Features básicas
    'basic_workouts',
    'profile', 
    'basic_challenges',
    'workout_recording',
    
    -- Features expert
    'enhanced_dashboard',    -- Dashboard normal
    'nutrition_guide',       -- Receitas da nutricionista e vídeos
    'workout_library',       -- Vídeos dos parceiros e categorias avançadas
    'advanced_tracking',     -- Tracking avançado e metas
    'detailed_reports'       -- Benefícios e relatórios detalhados
  ];
END;
$$ LANGUAGE plpgsql;

-- 5. Função para garantir que usuário expert tenha todas as features
CREATE OR REPLACE FUNCTION ensure_expert_access(user_id_param UUID)
RETURNS VOID AS $$
DECLARE
  expert_features TEXT[];
BEGIN
  -- Obter todas as features expert
  expert_features := get_expert_features();
  
  -- Inserir ou atualizar usuário como expert com acesso permanente
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
    NULL, -- NULL = acesso permanente (nunca expira)
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    current_level = 'expert',
    unlocked_features = expert_features,
    level_expires_at = NULL, -- Garantir que seja permanente
    updated_at = NOW(),
    last_activity = NOW();
    
  RAISE NOTICE 'Usuário % configurado como expert com acesso permanente', user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Atualizar função check_user_access_level para garantir features expert
CREATE OR REPLACE FUNCTION check_user_access_level(
  user_id_param UUID
)
RETURNS JSON AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP;
  features TEXT[];
  result JSON;
  expert_features TEXT[];
BEGIN
  -- Obter features expert
  expert_features := get_expert_features();
  
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
    )
    ON CONFLICT (user_id) DO NOTHING;
    
    user_level := 'basic';
    features := ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'];
  END IF;
  
  -- Verificar se o acesso ainda é válido
  IF expires_at IS NOT NULL AND expires_at < NOW() THEN
    -- Acesso expert expirado, voltar para básico
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
  
  -- Se for expert, garantir que tem TODAS as features
  IF user_level = 'expert' THEN
    features := expert_features;
    
    -- Atualizar no banco para garantir consistência
    UPDATE user_progress_level 
    SET unlocked_features = expert_features,
        last_activity = NOW()
    WHERE user_id = user_id_param;
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

-- 7. Função para promover usuário para expert permanente
CREATE OR REPLACE FUNCTION promote_to_expert_permanent(
  user_id_param UUID
)
RETURNS JSON AS $$
BEGIN
  -- Garantir acesso expert
  PERFORM ensure_expert_access(user_id_param);
  
  -- Retornar status atualizado
  RETURN check_user_access_level(user_id_param);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Aplicar acesso expert para o usuário atual
SELECT ensure_expert_access('01d4a292-1873-4af6-948b-a55eed56d6b9');

-- 9. Verificar se foi aplicado corretamente
SELECT 
  user_id,
  current_level,
  level_expires_at,
  array_length(unlocked_features, 1) as total_features,
  unlocked_features,
  created_at,
  updated_at
FROM user_progress_level
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 10. Testar a função de verificação
SELECT check_user_access_level('01d4a292-1873-4af6-948b-a55eed56d6b9');

-- 11. Verificar acesso a features específicas
SELECT 
  'enhanced_dashboard' as feature,
  check_feature_access('01d4a292-1873-4af6-948b-a55eed56d6b9', 'enhanced_dashboard') as has_access
UNION ALL
SELECT 
  'nutrition_guide' as feature,
  check_feature_access('01d4a292-1873-4af6-948b-a55eed56d6b9', 'nutrition_guide') as has_access
UNION ALL
SELECT 
  'workout_library' as feature,
  check_feature_access('01d4a292-1873-4af6-948b-a55eed56d6b9', 'workout_library') as has_access
UNION ALL
SELECT 
  'detailed_reports' as feature,
  check_feature_access('01d4a292-1873-4af6-948b-a55eed56d6b9', 'detailed_reports') as has_access;

-- 12. Criar função para verificar se usuário é expert
CREATE OR REPLACE FUNCTION is_user_expert(user_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP;
BEGIN
  SELECT current_level, level_expires_at
  INTO user_level, expires_at
  FROM user_progress_level
  WHERE user_id = user_id_param;
  
  -- Retorna true se for expert e não expirado
  RETURN user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 13. Teste final
SELECT 
  'Usuário é expert?' as pergunta,
  is_user_expert('01d4a292-1873-4af6-948b-a55eed56d6b9') as resposta;

-- ========================================
-- RESUMO DAS GARANTIAS IMPLEMENTADAS
-- ========================================

/*
✅ GARANTIAS PARA USUÁRIOS EXPERT:

1. 🔒 ACESSO PERMANENTE
   - level_expires_at = NULL (nunca expira)
   - Não pode ser rebaixado automaticamente

2. 🎯 TODAS AS FEATURES DESBLOQUEADAS
   - basic_workouts (treinos básicos)
   - profile (perfil)
   - basic_challenges (desafios)
   - workout_recording (registro de treinos)
   - enhanced_dashboard (dashboard normal)
   - nutrition_guide (nutrição completa)
   - workout_library (vídeos parceiros + categorias avançadas)
   - advanced_tracking (tracking avançado)
   - detailed_reports (benefícios)

3. 🛡️ VERIFICAÇÃO AUTOMÁTICA
   - check_user_access_level sempre retorna todas as features para expert
   - Atualização automática se features estiverem desatualizadas
   - Função ensure_expert_access para garantir consistência

4. 🔧 FUNÇÕES DE MANUTENÇÃO
   - promote_to_expert_permanent() - Promove usuário para expert permanente
   - is_user_expert() - Verifica se usuário é expert válido
   - get_expert_features() - Lista todas as features disponíveis

5. 📊 MONITORAMENTO
   - last_activity atualizada a cada verificação
   - Logs de acesso para debug
   - Verificação de consistência automática
*/ 