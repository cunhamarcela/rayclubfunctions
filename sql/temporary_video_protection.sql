-- ========================================
-- PROTEÇÃO TEMPORÁRIA DE VÍDEOS DE TREINO
-- ========================================
-- Este script bloqueia temporariamente o acesso a TODOS os vídeos de treino
-- para TODOS os usuários de forma segura e reversível.

-- ========================================
-- 1. TABELA DE CONFIGURAÇÃO GLOBAL
-- ========================================

-- Criar tabela para controlar o estado de bloqueio global
CREATE TABLE IF NOT EXISTS global_video_protection (
  id INTEGER PRIMARY KEY DEFAULT 1,
  is_enabled BOOLEAN DEFAULT FALSE,
  enabled_at TIMESTAMP,
  enabled_by TEXT,
  reason TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Garantir que só existe um registro
INSERT INTO global_video_protection (id, is_enabled, reason) 
VALUES (1, FALSE, 'Sistema de proteção temporária criado')
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- 2. BACKUP DA FUNÇÃO ORIGINAL
-- ========================================

-- Fazer backup da função original can_user_access_video_link se existir
DO $$
BEGIN
  -- Verificar se a função existe
  IF EXISTS (
    SELECT 1 FROM pg_proc p 
    JOIN pg_namespace n ON p.pronamespace = n.oid 
    WHERE n.nspname = 'public' AND p.proname = 'can_user_access_video_link'
  ) THEN
    -- Criar backup da função original
    EXECUTE format('
      CREATE OR REPLACE FUNCTION can_user_access_video_link_backup(%s)
      RETURNS %s AS $body$%s$body$ LANGUAGE %s',
      (SELECT pg_get_function_arguments(oid) FROM pg_proc WHERE proname = 'can_user_access_video_link'),
      (SELECT pg_get_function_result(oid) FROM pg_proc WHERE proname = 'can_user_access_video_link'),
      (SELECT pg_get_functiondef(oid) FROM pg_proc WHERE proname = 'can_user_access_video_link'),
      (SELECT l.lanname FROM pg_proc p JOIN pg_language l ON p.prolang = l.oid WHERE p.proname = 'can_user_access_video_link')
    );
    
    RAISE NOTICE 'Backup da função original criado como can_user_access_video_link_backup';
  ELSE
    RAISE NOTICE 'Função can_user_access_video_link não existe ainda, criando versão básica';
  END IF;
END $$;

-- ========================================
-- 3. FUNÇÃO TEMPORÁRIA COM PROTEÇÃO
-- ========================================

-- Substituir/criar a função com proteção temporal
CREATE OR REPLACE FUNCTION can_user_access_video_link(
  p_user_id UUID,
  p_video_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  protection_enabled BOOLEAN;
  user_level TEXT;
  is_expert BOOLEAN DEFAULT FALSE;
BEGIN
  -- Verificar se a proteção global está ativa
  SELECT is_enabled INTO protection_enabled 
  FROM global_video_protection 
  WHERE id = 1;
  
  -- Se proteção está ativa, negar acesso a TODOS os vídeos
  IF protection_enabled = TRUE THEN
    RETURN FALSE;
  END IF;
  
  -- Se proteção não está ativa, usar lógica normal
  
  -- Verificar nível do usuário
  SELECT current_level INTO user_level
  FROM user_progress_level 
  WHERE user_id = p_user_id;
  
  -- Se usuário não tem registro, criar como básico
  IF user_level IS NULL THEN
    INSERT INTO user_progress_level (
      user_id, 
      current_level, 
      unlocked_features
    ) VALUES (
      p_user_id, 
      'basic', 
      ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording']
    )
    ON CONFLICT (user_id) DO NOTHING;
    
    user_level := 'basic';
  END IF;
  
  -- Verificar se usuário é expert
  is_expert := (user_level = 'expert');
  
  -- Por padrão, permitir acesso a vídeos básicos
  -- Verificar se o vídeo requer acesso expert
  IF EXISTS (
    SELECT 1 FROM workout_videos 
    WHERE id = p_video_id 
    AND requires_expert_access = TRUE
  ) THEN
    -- Vídeo requer acesso expert
    RETURN is_expert;
  ELSE
    -- Vídeo básico - todos podem acessar
    RETURN TRUE;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Em caso de erro, negar acesso por segurança
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 4. FUNÇÕES DE CONTROLE
-- ========================================

-- Função para ativar proteção temporária
CREATE OR REPLACE FUNCTION enable_video_protection(
  reason_text TEXT DEFAULT 'Manutenção temporária'
)
RETURNS TEXT AS $$
BEGIN
  UPDATE global_video_protection 
  SET 
    is_enabled = TRUE,
    enabled_at = NOW(),
    enabled_by = current_user,
    reason = reason_text,
    updated_at = NOW()
  WHERE id = 1;
  
  RETURN 'Proteção de vídeos ATIVADA. Todos os vídeos estão bloqueados temporariamente.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para desativar proteção temporária
CREATE OR REPLACE FUNCTION disable_video_protection()
RETURNS TEXT AS $$
BEGIN
  UPDATE global_video_protection 
  SET 
    is_enabled = FALSE,
    updated_at = NOW()
  WHERE id = 1;
  
  RETURN 'Proteção de vídeos DESATIVADA. Acesso normal restaurado.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar status atual
CREATE OR REPLACE FUNCTION check_video_protection_status()
RETURNS TABLE(
  protection_active BOOLEAN,
  enabled_since TIMESTAMP,
  enabled_by TEXT,
  reason TEXT,
  total_videos INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    gvp.is_enabled,
    gvp.enabled_at,
    gvp.enabled_by,
    gvp.reason,
    (SELECT COUNT(*)::INTEGER FROM workout_videos)
  FROM global_video_protection gvp
  WHERE gvp.id = 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 5. INSTRUÇÕES DE USO
-- ========================================

/*

COMO USAR:

1. ATIVAR PROTEÇÃO (bloquear todos os vídeos):
   SELECT enable_video_protection('Manutenção programada');

2. DESATIVAR PROTEÇÃO (voltar ao normal):
   SELECT disable_video_protection();

3. VERIFICAR STATUS ATUAL:
   SELECT * FROM check_video_protection_status();

4. REVERTER COMPLETAMENTE (se necessário):
   -- Restaurar função original se existia backup
   DROP FUNCTION IF EXISTS can_user_access_video_link(UUID, UUID);
   ALTER FUNCTION can_user_access_video_link_backup(UUID, UUID) RENAME TO can_user_access_video_link;
   
   -- Ou simplesmente desativar proteção
   SELECT disable_video_protection();

NOTAS IMPORTANTES:
- Quando ativada, a proteção bloqueia TODOS os vídeos para TODOS os usuários
- A proteção é global e instantânea
- Não modifica dados existentes, apenas controla o acesso
- Fácil de reverter sem perda de dados
- Mantém log de quando foi ativada e por quem

*/

-- ========================================
-- 6. VERIFICAÇÃO INICIAL
-- ========================================

-- Mostrar status atual
SELECT 'Status atual da proteção de vídeos:' as info;
SELECT * FROM check_video_protection_status();

-- Mostrar total de vídeos no sistema
SELECT 
  'Total de vídeos no sistema:' as info,
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE requires_expert_access = TRUE) as expert_videos,
  COUNT(*) FILTER (WHERE requires_expert_access = FALSE OR requires_expert_access IS NULL) as basic_videos
FROM workout_videos;

RAISE NOTICE 'Sistema de proteção temporária de vídeos instalado com sucesso!';
RAISE NOTICE 'Use SELECT enable_video_protection() para ativar o bloqueio.';
RAISE NOTICE 'Use SELECT disable_video_protection() para desativar o bloqueio.'; 