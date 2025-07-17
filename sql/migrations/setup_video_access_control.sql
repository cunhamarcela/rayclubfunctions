-- ========================================
-- CONTROLE DE ACESSO AOS VÍDEOS DOS PARCEIROS VIA SUPABASE RLS
-- ========================================

-- 1. Primeiro, vamos adicionar uma coluna para marcar vídeos que são exclusivos para usuários Expert
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS requires_expert_access BOOLEAN DEFAULT false;

-- 2. Marcar vídeos dos parceiros como exclusivos para Expert
UPDATE workout_videos 
SET requires_expert_access = true 
WHERE instructor_name IN (
    'Treinos de Musculação', 
    'Goya Health Club', 
    'Fight Fit', 
    'Bora Assessoria', 
    'The Unit'
) OR category IN (
    'bodybuilding',  -- Musculação
    'pilates',       -- Pilates  
    'functional',    -- Funcional
    'running',       -- Corrida
    'physiotherapy'  -- Fisioterapia
);

-- 3. Criar função para verificar se usuário é Expert
CREATE OR REPLACE FUNCTION is_user_expert(user_id_param UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
DECLARE
    user_level TEXT;
    expires_at TIMESTAMP;
BEGIN
    -- Buscar nível do usuário
    SELECT current_level, level_expires_at
    INTO user_level, expires_at
    FROM user_progress_level
    WHERE user_id = user_id_param;
    
    -- Se não encontrou, usuário é basic
    IF user_level IS NULL THEN
        RETURN false;
    END IF;
    
    -- Se é expert e não expirou, retorna true
    IF user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW()) THEN
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Remover política atual que permite todos verem todos os vídeos
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;

-- 5. Criar nova política que controla acesso baseado no nível do usuário
CREATE POLICY "Vídeos básicos são públicos" ON workout_videos
    FOR SELECT USING (
        -- Vídeos que não requerem acesso expert podem ser vistos por todos
        requires_expert_access = false
        OR 
        -- Vídeos que requerem acesso expert só podem ser vistos por usuários expert
        (requires_expert_access = true AND is_user_expert())
    );

-- 6. Política para usuários não autenticados (veem apenas vídeos básicos)
CREATE POLICY "Usuários não autenticados veem apenas básicos" ON workout_videos
    FOR SELECT USING (
        auth.uid() IS NULL AND requires_expert_access = false
    );

-- 7. Função para marcar/desmarcar vídeos como exclusivos para Expert
CREATE OR REPLACE FUNCTION toggle_video_expert_access(
    video_id_param UUID,
    requires_expert BOOLEAN
)
RETURNS VOID AS $$
BEGIN
    UPDATE workout_videos 
    SET requires_expert_access = requires_expert,
        updated_at = NOW()
    WHERE id = video_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Função para marcar vídeos de um instrutor como exclusivos
CREATE OR REPLACE FUNCTION set_instructor_videos_expert_only(
    instructor_name_param TEXT,
    requires_expert BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
DECLARE
    affected_count INTEGER;
BEGIN
    UPDATE workout_videos 
    SET requires_expert_access = requires_expert,
        updated_at = NOW()
    WHERE instructor_name = instructor_name_param;
    
    GET DIAGNOSTICS affected_count = ROW_COUNT;
    RETURN affected_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Função para marcar vídeos de uma categoria como exclusivos
CREATE OR REPLACE FUNCTION set_category_videos_expert_only(
    category_param TEXT,
    requires_expert BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
DECLARE
    affected_count INTEGER;
BEGIN
    UPDATE workout_videos 
    SET requires_expert_access = requires_expert,
        updated_at = NOW()
    WHERE category = category_param;
    
    GET DIAGNOSTICS affected_count = ROW_COUNT;
    RETURN affected_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. View para administradores verificarem o controle de acesso
CREATE OR REPLACE VIEW video_access_control_summary AS
SELECT 
    category,
    instructor_name,
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_only_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = false) as public_videos
FROM workout_videos
GROUP BY category, instructor_name
ORDER BY category, instructor_name;

-- 11. Função para testar acesso de um usuário específico
CREATE OR REPLACE FUNCTION test_user_video_access(
    user_id_param UUID,
    video_id_param UUID
)
RETURNS JSON AS $$
DECLARE
    video_info RECORD;
    user_is_expert BOOLEAN;
    has_access BOOLEAN;
    result JSON;
BEGIN
    -- Buscar informações do vídeo
    SELECT title, instructor_name, category, requires_expert_access
    INTO video_info
    FROM workout_videos 
    WHERE id = video_id_param;
    
    IF video_info IS NULL THEN
        RETURN json_build_object(
            'error', 'Video not found',
            'video_id', video_id_param
        );
    END IF;
    
    -- Verificar se usuário é expert
    user_is_expert := is_user_expert(user_id_param);
    
    -- Determinar se tem acesso
    has_access := NOT video_info.requires_expert_access OR user_is_expert;
    
    -- Montar resultado
    result := json_build_object(
        'video_id', video_id_param,
        'video_title', video_info.title,
        'instructor', video_info.instructor_name,
        'category', video_info.category,
        'requires_expert_access', video_info.requires_expert_access,
        'user_is_expert', user_is_expert,
        'has_access', has_access,
        'access_reason', CASE 
            WHEN NOT video_info.requires_expert_access THEN 'Public video'
            WHEN user_is_expert THEN 'User is expert'
            ELSE 'Access denied - requires expert level'
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- COMANDOS ÚTEIS PARA GERENCIAMENTO
-- ========================================

/*
-- Verificar quantos vídeos estão bloqueados:
SELECT 
    requires_expert_access,
    COUNT(*) as quantidade
FROM workout_videos 
GROUP BY requires_expert_access;

-- Liberar todos os vídeos de um instrutor:
SELECT set_instructor_videos_expert_only('Nome do Instrutor', false);

-- Bloquear todos os vídeos de uma categoria:
SELECT set_category_videos_expert_only('pilates', true);

-- Testar acesso de um usuário específico:
SELECT test_user_video_access('user-id-aqui', 'video-id-aqui');

-- Ver resumo do controle de acesso:
SELECT * FROM video_access_control_summary;

-- Verificar todos os vídeos bloqueados:
SELECT title, instructor_name, category 
FROM workout_videos 
WHERE requires_expert_access = true;
*/ 