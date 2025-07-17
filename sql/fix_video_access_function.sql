-- ========================================
-- CORREÇÃO DA FUNÇÃO DE ACESSO AOS VÍDEOS
-- ========================================
-- Esta função implementa corretamente a verificação de acesso aos vídeos
-- considerando o campo requires_expert_access e o nível do usuário

-- ========================================
-- 1. IMPLEMENTAR FUNÇÃO CORRETA
-- ========================================

-- Função principal para verificar acesso aos vídeos
CREATE OR REPLACE FUNCTION can_user_access_video_link(
  p_user_id UUID,
  p_video_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP;
  video_requires_expert BOOLEAN;
  video_exists BOOLEAN;
BEGIN
  -- Verificar se o vídeo existe
  SELECT 
    EXISTS(SELECT 1 FROM workout_videos WHERE id = p_video_id),
    COALESCE(requires_expert_access, FALSE)
  INTO 
    video_exists,
    video_requires_expert
  FROM workout_videos 
  WHERE id = p_video_id;
  
  -- Se vídeo não existe, negar acesso
  IF NOT video_exists THEN
    RETURN FALSE;
  END IF;
  
  -- Se vídeo não requer acesso expert, liberado para todos
  IF video_requires_expert = FALSE THEN
    RETURN TRUE;
  END IF;
  
  -- Vídeo requer acesso expert - verificar nível do usuário
  SELECT 
    current_level,
    level_expires_at
  INTO 
    user_level,
    expires_at
  FROM user_progress_level 
  WHERE user_id = p_user_id;
  
  -- Se usuário não tem registro, é basic
  IF user_level IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Se usuário é expert e não expirou, permitir acesso
  IF user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW()) THEN
    RETURN TRUE;
  END IF;
  
  -- Caso contrário, negar acesso
  RETURN FALSE;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Em caso de erro, negar acesso por segurança
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 2. FUNÇÃO AUXILIAR PARA OBTER NÍVEL DO USUÁRIO
-- ========================================

-- Função para obter nível atual do usuário (usada pelo Flutter)
CREATE OR REPLACE FUNCTION get_user_level(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP;
BEGIN
  SELECT 
    current_level,
    level_expires_at
  INTO 
    user_level,
    expires_at
  FROM user_progress_level 
  WHERE user_id = p_user_id;
  
  -- Se usuário não existe, retornar basic
  IF user_level IS NULL THEN
    RETURN 'basic';
  END IF;
  
  -- Se acesso expirou, retornar basic
  IF expires_at IS NOT NULL AND expires_at <= NOW() THEN
    RETURN 'basic';
  END IF;
  
  RETURN user_level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 3. VERIFICAR IMPLEMENTAÇÃO
-- ========================================

-- Testar a função com os vídeos que você mencionou
DO $$
DECLARE
  test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9';
  test_video_ids UUID[] := ARRAY[
    '0414f81b-7eb7-46bf-ac03-4f342ac5172d', -- O que eu faria diferente
    '44475402-4549-4118-b76e-61f803f96745', -- Superiores + Cardio (1)
    'b080dca6-a806-4bd4-afdd-8627edd5380e', -- Superiores + Cardio (2)
    '52b46af0-2981-44ba-b288-1f66031f4016', -- Treino A - Semana 02
    '6a93a70b-1a0f-4d95-8244-58a57f54fbcf'  -- Treino B - Semana 02
  ];
  video_id UUID;
  can_access BOOLEAN;
  user_level TEXT;
BEGIN
  -- Verificar nível do usuário
  user_level := get_user_level(test_user_id);
  RAISE NOTICE 'Usuário % tem nível: %', test_user_id, user_level;
  
  -- Testar acesso a cada vídeo
  FOREACH video_id IN ARRAY test_video_ids
  LOOP
    can_access := can_user_access_video_link(test_user_id, video_id);
    RAISE NOTICE 'Vídeo %: Acesso = %', video_id, can_access;
  END LOOP;
END $$;

-- ========================================
-- 4. VERIFICAR VÍDEOS POR STATUS
-- ========================================

-- Mostrar vídeos que requerem expert vs básicos
SELECT 
  'RESUMO POR TIPO DE ACESSO:' as info,
  CASE 
    WHEN requires_expert_access = TRUE THEN 'EXPERT ONLY'
    ELSE 'BÁSICO'
  END as tipo_acesso,
  COUNT(*) as total_videos
FROM workout_videos 
GROUP BY requires_expert_access
ORDER BY requires_expert_access;

-- Mostrar vídeos específicos que foram marcados como expert
SELECT 
  'VÍDEOS EXPERT ESPECÍFICOS:' as info,
  id,
  title,
  instructor_name,
  requires_expert_access
FROM workout_videos 
WHERE id IN (
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d',
  '44475402-4549-4118-b76e-61f803f96745',
  'b080dca6-a806-4bd4-afdd-8627edd5380e',
  '52b46af0-2981-44ba-b288-1f66031f4016',
  '6a93a70b-1a0f-4d95-8244-58a57f54fbcf',
  '314ded3a-5868-4b92-9aee-8cf0d5be5dd8',
  'd0abfbf5-90f8-4291-a4da-84f1724efba0',
  '9756f2b7-cbad-477d-b612-8a5429b89b1a',
  '69053e39-93ac-4d74-8d1b-ee6168ce5886',
  '54a34c38-0c2c-41a9-a648-51905780e50e'
)
ORDER BY instructor_name, title;

-- ========================================
-- 5. TESTE FINAL
-- ========================================

-- Função para testar acesso de um usuário específico
CREATE OR REPLACE FUNCTION test_user_video_access(
  test_user_id UUID,
  test_video_id UUID
)
RETURNS TABLE(
  user_level TEXT,
  video_title TEXT,
  requires_expert BOOLEAN,
  can_access BOOLEAN,
  explanation TEXT
) AS $$
DECLARE
  level TEXT;
  title TEXT;
  requires_expert BOOLEAN;
  access BOOLEAN;
  explanation TEXT;
BEGIN
  -- Obter dados
  level := get_user_level(test_user_id);
  
  SELECT 
    v.title,
    COALESCE(v.requires_expert_access, FALSE)
  INTO 
    title,
    requires_expert
  FROM workout_videos v
  WHERE v.id = test_video_id;
  
  access := can_user_access_video_link(test_user_id, test_video_id);
  
  -- Gerar explicação
  IF requires_expert = FALSE THEN
    explanation := 'Vídeo básico - todos podem acessar';
  ELSIF level = 'expert' THEN
    explanation := 'Vídeo expert + usuário expert = ACESSO PERMITIDO';
  ELSE
    explanation := 'Vídeo expert + usuário basic = ACESSO NEGADO';
  END IF;
  
  RETURN QUERY SELECT level, title, requires_expert, access, explanation;
END;
$$ LANGUAGE plpgsql;

RAISE NOTICE '✅ Função can_user_access_video_link corrigida!';
RAISE NOTICE '📱 Agora usuários expert devem conseguir acessar vídeos restritos';
RAISE NOTICE '👤 Usuários basic só verão vídeos básicos'; 