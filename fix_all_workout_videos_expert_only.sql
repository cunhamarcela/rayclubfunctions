-- ========================================
-- FORÇAR TODOS OS VÍDEOS A EXIGIR ACESSO EXPERT
-- ========================================
-- Este script garante que TODOS os vídeos de treino sejam bloqueados para usuários basic

-- 1. Verificar estado atual dos vídeos
SELECT 
  id,
  title,
  category,
  instructor_name,
  requires_expert_access,
  is_new,
  is_popular
FROM workout_videos 
ORDER BY category, title;

-- 2. FORÇAR TODOS OS VÍDEOS A EXIGIREM ACESSO EXPERT
UPDATE workout_videos 
SET requires_expert_access = true,
    updated_at = NOW()
WHERE requires_expert_access = false;

-- 3. Verificar quantos vídeos foram atualizados
SELECT 
  'Total de vídeos configurados como Expert' as status,
  COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

-- 4. Listar todos os vídeos agora protegidos
SELECT 
  category,
  COUNT(*) as videos_protegidos
FROM workout_videos 
WHERE requires_expert_access = true
GROUP BY category
ORDER BY category;

-- 5. Criar função para verificar acesso a vídeo
CREATE OR REPLACE FUNCTION check_video_expert_access(
  user_id_param UUID,
  video_id_param TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  user_level TEXT;
  video_requires_expert BOOLEAN;
  expires_at TIMESTAMP;
BEGIN
  -- Buscar nível do usuário
  SELECT 
    current_level,
    level_expires_at
  INTO 
    user_level,
    expires_at
  FROM user_progress_level 
  WHERE user_id = user_id_param;
  
  -- Se usuário não existe, é basic
  IF user_level IS NULL THEN
    user_level := 'basic';
  END IF;
  
  -- Verificar se acesso expert expirou
  IF expires_at IS NOT NULL AND expires_at < NOW() THEN
    user_level := 'basic';
  END IF;
  
  -- Buscar se vídeo requer acesso expert
  SELECT requires_expert_access
  INTO video_requires_expert
  FROM workout_videos
  WHERE id = video_id_param;
  
  -- Se vídeo não encontrado, negar acesso
  IF video_requires_expert IS NULL THEN
    RETURN false;
  END IF;
  
  -- ⚠️ REGRA CRÍTICA: Se vídeo requer expert, usuário DEVE ser expert
  IF video_requires_expert = true THEN
    RETURN user_level = 'expert';
  END IF;
  
  -- Se vídeo não requer expert, liberar (não deveria existir mais)
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Atualizar função de verificação de acesso global
CREATE OR REPLACE FUNCTION can_user_access_video_link(
  user_id_param UUID,
  video_id_param TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Usar função específica de verificação expert
  RETURN check_video_expert_access(user_id_param, video_id_param);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Verificar se funções funcionam corretamente
-- Teste com usuário expert (substitua o UUID pelo ID real)
SELECT 
  'Teste acesso expert' as teste,
  check_video_expert_access('01d4a292-1873-4af6-948b-a55eed56d6b9', 'any-video-id') as resultado;

-- 8. Garantir RLS (Row Level Security) nos vídeos
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver vídeos, mas acesso ao conteúdo é controlado pela aplicação
DROP POLICY IF EXISTS "Usuários podem ver lista de vídeos" ON workout_videos;
CREATE POLICY "Usuários podem ver lista de vídeos" ON workout_videos
    FOR SELECT USING (true);

-- ========================================
-- VERIFICAÇÕES FINAIS
-- ========================================

-- Confirmar que todos os vídeos agora exigem expert
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ SUCESSO: Todos os vídeos protegidos'
    ELSE '❌ ERRO: Ainda há vídeos sem proteção'
  END as status_seguranca,
  COUNT(*) as videos_desprotegidos
FROM workout_videos 
WHERE requires_expert_access = false;

-- Mostrar estatísticas finais
SELECT 
  '📊 ESTATÍSTICAS FINAIS' as resumo,
  (SELECT COUNT(*) FROM workout_videos) as total_videos,
  (SELECT COUNT(*) FROM workout_videos WHERE requires_expert_access = true) as videos_protegidos,
  (SELECT COUNT(*) FROM user_progress_level WHERE current_level = 'expert') as usuarios_expert;

-- ========================================
-- LOGS PARA DEBUG
-- ========================================

-- Log de todas as alterações feitas
INSERT INTO public.app_logs (
  level,
  message,
  metadata,
  created_at
) VALUES (
  'INFO',
  'Todos os vídeos de treino foram configurados para exigir acesso Expert',
  jsonb_build_object(
    'total_videos', (SELECT COUNT(*) FROM workout_videos),
    'videos_protegidos', (SELECT COUNT(*) FROM workout_videos WHERE requires_expert_access = true),
    'action', 'force_expert_access_on_all_videos'
  ),
  NOW()
);

-- ========================================
-- RESUMO EXECUTIVO
-- ========================================

/*
✅ AÇÕES EXECUTADAS:

1. 🔒 TODOS OS VÍDEOS PROTEGIDOS
   - requires_expert_access = true para TODOS os vídeos
   - Não há mais vídeos acessíveis para usuários basic

2. 🛡️ FUNÇÕES DE VERIFICAÇÃO CRIADAS
   - check_video_expert_access() - Verificação rigorosa
   - can_user_access_video_link() - Interface para o app

3. 🔐 REGRAS DE SEGURANÇA
   - Usuário DEVE ser 'expert' para acessar qualquer vídeo
   - Acesso expert não pode estar expirado
   - Em caso de dúvida, acesso é NEGADO

4. 📊 ROW LEVEL SECURITY
   - Usuários podem ver lista de vídeos (para UI)
   - Controle de acesso ao conteúdo via aplicação

⚠️ IMPORTANTE: 
- Usuários basic agora NÃO podem reproduzir NENHUM vídeo
- Apenas usuários expert têm acesso completo
- Sistema fail-safe: erro = acesso negado
*/ 