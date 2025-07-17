-- ========================================
-- FIX DEFINITIVO PARA EXPERT VALIDATION
-- ========================================
-- Corrigir erro: operator does not exist: uuid = text

-- 1. DROPAR E RECRIAR a função get_user_level com tipos corretos
DROP FUNCTION IF EXISTS get_user_level(uuid);
DROP FUNCTION IF EXISTS get_user_level(text);

CREATE OR REPLACE FUNCTION get_user_level(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  user_level TEXT;
  expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Buscar dados diretamente na tabela
  SELECT 
    current_level,
    level_expires_at
  INTO 
    user_level,
    expires_at
  FROM user_progress_level 
  WHERE user_id = p_user_id;
  
  -- Se não encontrou usuário, retornar 'basic'
  IF user_level IS NULL THEN
    RETURN 'basic';
  END IF;
  
  -- Verificar se ainda é válido (se tiver data de expiração)
  IF expires_at IS NOT NULL AND expires_at < NOW() THEN
    RETURN 'basic';
  END IF;
  
  -- Retornar nível atual
  RETURN user_level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. DROPAR E RECRIAR a função can_user_access_video_link com tipos corretos
DROP FUNCTION IF EXISTS can_user_access_video_link(uuid, text);
DROP FUNCTION IF EXISTS can_user_access_video_link(text, text);

CREATE OR REPLACE FUNCTION can_user_access_video_link(
  p_user_id UUID,
  p_video_id TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  user_level TEXT;
BEGIN
  -- Obter nível do usuário usando a função criada acima
  user_level := get_user_level(p_user_id);
  
  -- Se é expert, tem acesso a tudo
  IF user_level = 'expert' THEN
    RETURN TRUE;
  END IF;
  
  -- Se é basic, verificar se o vídeo está nas features liberadas
  -- (implementar lógica específica aqui se necessário)
  RETURN user_level = 'expert';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. TESTE DIRETO das funções
SELECT 
  '=== TESTE DAS FUNÇÕES ===' as titulo,
  get_user_level('01d4a292-1873-4af6-948b-a55eed56d6b9') as nivel_usuario,
  can_user_access_video_link('01d4a292-1873-4af6-948b-a55eed56d6b9', 'test-video') as pode_acessar;

-- 4. GARANTIR que o usuário específico está como expert
UPDATE user_progress_level 
SET 
  current_level = 'expert',
  level_expires_at = NULL  -- Sem expiração
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 5. VERIFICAR o resultado final
SELECT 
  '=== VERIFICAÇÃO FINAL ===' as titulo,
  user_id,
  current_level,
  level_expires_at,
  get_user_level(user_id) as nivel_pela_funcao
FROM user_progress_level 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'; 