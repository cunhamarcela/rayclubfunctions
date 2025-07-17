-- Debug do acesso do usuário
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9

-- 1. Verificar dados na tabela user_progress_level
SELECT 
  user_id,
  current_level,
  level_expires_at,
  unlocked_features,
  last_activity,
  created_at,
  updated_at
FROM user_progress_level
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 2. Testar a função check_user_access_level
SELECT check_user_access_level('01d4a292-1873-4af6-948b-a55eed56d6b9');

-- 3. Verificar se há níveis pendentes
SELECT * FROM pending_user_levels 
WHERE email IN (
  SELECT email FROM auth.users 
  WHERE id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
);

-- 4. Verificar email do usuário
SELECT id, email, created_at 
FROM auth.users 
WHERE id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 5. Verificar se a feature 'enhanced_dashboard' está nas features do usuário
SELECT 
  user_id,
  current_level,
  'enhanced_dashboard' = ANY(unlocked_features) as has_dashboard_access,
  unlocked_features
FROM user_progress_level
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 6. Se o usuário não existir na tabela, criar como expert para teste
INSERT INTO user_progress_level (
  user_id,
  current_level,
  unlocked_features,
  level_expires_at
) VALUES (
  '01d4a292-1873-4af6-948b-a55eed56d6b9',
  'expert',
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
  ],
  NOW() + INTERVAL '30 days'
)
ON CONFLICT (user_id) 
DO UPDATE SET 
  current_level = 'expert',
  unlocked_features = ARRAY[
    'basic_workouts',
    'profile', 
    'basic_challenges',
    'workout_recording',
    'enhanced_dashboard',
    'nutrition_guide',
    'workout_library',
    'advanced_tracking',
    'detailed_reports'
  ],
  level_expires_at = NOW() + INTERVAL '30 days',
  updated_at = NOW();

-- 7. Verificar novamente após inserção/atualização
SELECT check_user_access_level('01d4a292-1873-4af6-948b-a55eed56d6b9'); 