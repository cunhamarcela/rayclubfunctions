-- ========================================
-- TESTE E DIAGNÓSTICO DE ACESSO AOS VÍDEOS
-- ========================================
-- Script para diagnosticar por que usuários expert estão sendo bloqueados

-- ========================================
-- 1. VERIFICAR STATUS DO USUÁRIO
-- ========================================

-- Verificar se usuário está como expert
SELECT 
  'STATUS DO USUÁRIO:' as info,
  user_id,
  current_level,
  level_expires_at,
  CASE 
    WHEN level_expires_at IS NULL THEN 'PERMANENTE'
    WHEN level_expires_at > NOW() THEN 'VÁLIDO ATÉ ' || level_expires_at
    ELSE 'EXPIRADO'
  END as status_acesso,
  array_length(unlocked_features, 1) as total_features,
  unlocked_features
FROM user_progress_level
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- ========================================
-- 2. TESTE DA FUNÇÃO get_user_level
-- ========================================

SELECT 
  'TESTE get_user_level:' as info,
  get_user_level('01d4a292-1873-4af6-948b-a55eed56d6b9') as nivel_retornado;

-- ========================================
-- 3. VERIFICAR VÍDEOS ESPECÍFICOS
-- ========================================

-- Verificar os vídeos que deveriam estar restritos
SELECT 
  'VÍDEOS QUE DEVERIAM SER EXPERT:' as info,
  id,
  title,
  instructor_name,
  requires_expert_access,
  CASE 
    WHEN requires_expert_access = TRUE THEN '🔒 EXPERT ONLY'
    ELSE '👤 BÁSICO'
  END as status_video
FROM workout_videos 
WHERE id IN (
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d', -- O que eu faria diferente
  '44475402-4549-4118-b76e-61f803f96745', -- Superiores + Cardio (1)
  'b080dca6-a806-4bd4-afdd-8627edd5380e', -- Superiores + Cardio (2)
  '52b46af0-2981-44ba-b288-1f66031f4016', -- Treino A - Semana 02
  '6a93a70b-1a0f-4d95-8244-58a57f54fbcf', -- Treino B - Semana 02
  '314ded3a-5868-4b92-9aee-8cf0d5be5dd8', -- Treino F
  'd0abfbf5-90f8-4291-a4da-84f1724efba0', -- Treino A
  '9756f2b7-cbad-477d-b612-8a5429b89b1a', -- Treino B
  '69053e39-93ac-4d74-8d1b-ee6168ce5886', -- Treino C
  '54a34c38-0c2c-41a9-a648-51905780e50e'  -- Treino D - Semana 02
)
ORDER BY instructor_name, title;

-- ========================================
-- 4. TESTE DA FUNÇÃO can_user_access_video_link
-- ========================================

-- Testar acesso a cada vídeo específico
SELECT 
  'TESTE DE ACESSO POR VÍDEO:' as info,
  t.user_level,
  t.video_title,
  t.requires_expert,
  t.can_access,
  t.explanation
FROM test_user_video_access(
  '01d4a292-1873-4af6-948b-a55eed56d6b9',
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d' -- O que eu faria diferente
) t

UNION ALL

SELECT 
  'TESTE DE ACESSO POR VÍDEO:' as info,
  t.user_level,
  t.video_title,
  t.requires_expert,
  t.can_access,
  t.explanation
FROM test_user_video_access(
  '01d4a292-1873-4af6-948b-a55eed56d6b9',
  '44475402-4549-4118-b76e-61f803f96745' -- Superiores + Cardio
) t

UNION ALL

SELECT 
  'TESTE DE ACESSO POR VÍDEO:' as info,
  t.user_level,
  t.video_title,
  t.requires_expert,
  t.can_access,
  t.explanation
FROM test_user_video_access(
  '01d4a292-1873-4af6-948b-a55eed56d6b9',
  '52b46af0-2981-44ba-b288-1f66031f4016' -- Treino A - Semana 02
) t;

-- ========================================
-- 5. TESTE DIRETO DA FUNÇÃO
-- ========================================

-- Teste direto para debug
DO $$
DECLARE
  test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9';
  test_video_id UUID := '0414f81b-7eb7-46bf-ac03-4f342ac5172d';
  user_level TEXT;
  video_title TEXT;
  requires_expert BOOLEAN;
  can_access BOOLEAN;
BEGIN
  -- Obter dados do usuário
  user_level := get_user_level(test_user_id);
  
  -- Obter dados do vídeo
  SELECT title, requires_expert_access 
  INTO video_title, requires_expert
  FROM workout_videos 
  WHERE id = test_video_id;
  
  -- Testar acesso
  can_access := can_user_access_video_link(test_user_id, test_video_id);
  
  -- Log detalhado
  RAISE NOTICE '========================================';
  RAISE NOTICE 'DIAGNÓSTICO DETALHADO:';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Usuário ID: %', test_user_id;
  RAISE NOTICE 'Nível do usuário: %', user_level;
  RAISE NOTICE 'Vídeo ID: %', test_video_id;
  RAISE NOTICE 'Título do vídeo: %', video_title;
  RAISE NOTICE 'Requer expert: %', requires_expert;
  RAISE NOTICE 'Pode acessar: %', can_access;
  RAISE NOTICE '========================================';
  
  IF user_level = 'expert' AND requires_expert = TRUE AND can_access = FALSE THEN
    RAISE NOTICE '❌ PROBLEMA: Usuário expert sendo bloqueado!';
  ELSIF user_level = 'expert' AND requires_expert = TRUE AND can_access = TRUE THEN
    RAISE NOTICE '✅ OK: Usuário expert tem acesso como esperado';
  ELSIF user_level = 'basic' AND requires_expert = TRUE AND can_access = FALSE THEN
    RAISE NOTICE '✅ OK: Usuário basic bloqueado como esperado';
  ELSE
    RAISE NOTICE '⚠️ Situação inesperada';
  END IF;
END $$;

-- ========================================
-- 6. VERIFICAR SE USUÁRIO TEM REGISTRO
-- ========================================

-- Verificar se usuário tem registro na tabela user_progress_level
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM user_progress_level 
      WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
    ) THEN 'USUÁRIO TEM REGISTRO'
    ELSE 'USUÁRIO SEM REGISTRO - SERÁ TRATADO COMO BASIC'
  END as status_registro;

-- ========================================
-- 7. SOLUÇÃO TEMPORÁRIA SE NECESSÁRIO
-- ========================================

-- Se usuário não estiver como expert, promover agora
INSERT INTO user_progress_level (
  user_id,
  current_level,
  unlocked_features,
  level_expires_at,
  created_at,
  updated_at,
  last_activity
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
  NULL, -- Acesso permanente
  NOW(),
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
  level_expires_at = NULL,
  updated_at = NOW(),
  last_activity = NOW();

-- Verificar após correção
SELECT 
  'APÓS CORREÇÃO:' as info,
  current_level,
  level_expires_at,
  get_user_level(user_id) as nivel_funcao
FROM user_progress_level
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

RAISE NOTICE '🔧 Diagnóstico completo! Verifique os resultados acima';
RAISE NOTICE '📱 Se usuário era basic, agora foi promovido para expert';
RAISE NOTICE '🔄 Faça hot restart do app para aplicar mudanças'; 