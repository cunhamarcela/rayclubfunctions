-- Adicionar usuário como expert com acesso permanente
INSERT INTO user_progress_level (
  user_id,
  current_level,
  unlocked_features,
  level_expires_at,
  created_at,
  updated_at
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
  NULL, -- NULL = acesso permanente (não expira)
  NOW(),
  NOW()
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
  level_expires_at = NULL, -- NULL = acesso permanente
  updated_at = NOW();

-- Verificar se foi criado corretamente
SELECT * FROM user_progress_level 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'; 