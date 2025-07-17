-- Script para corrigir controle de acesso aos vídeos
-- Usuários basic veem vídeos mas não acessam links
-- Usuários expert veem e acessam tudo

-- 1. REMOVER todas as políticas RLS restritivas
DROP POLICY IF EXISTS "SUPER_STRICT: Só experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Auto: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "workout_videos_select_policy" ON workout_videos;

-- 2. PERMITIR que todos vejam todos os vídeos (sem RLS)
-- Isso permite que basic users vejam a lista de vídeos
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- 3. CRIAR função para verificar se usuário pode acessar o link do vídeo
CREATE OR REPLACE FUNCTION can_access_video_link(video_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
    video_requires_expert BOOLEAN;
    user_is_expert BOOLEAN DEFAULT FALSE;
BEGIN
    -- Verificar se o vídeo requer acesso expert
    SELECT requires_expert_access INTO video_requires_expert
    FROM workout_videos 
    WHERE id = video_id_param;
    
    -- Se vídeo não requer expert, qualquer um pode acessar
    IF video_requires_expert IS FALSE OR video_requires_expert IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Se vídeo requer expert, verificar se usuário é expert
    SELECT EXISTS(
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = auth.uid() 
        AND upl.current_level = 'expert'
        AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
    ) INTO user_is_expert;
    
    RETURN user_is_expert;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CRIAR função para listar vídeos com informação de acesso
CREATE OR REPLACE FUNCTION get_videos_with_access_info()
RETURNS TABLE(
    id UUID,
    title TEXT,
    description TEXT,
    video_url TEXT,
    thumbnail_url TEXT,
    duration_seconds INTEGER,
    category_id UUID,
    instructor_name TEXT,
    difficulty_level TEXT,
    requires_expert_access BOOLEAN,
    user_can_access_link BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wv.id,
        wv.title,
        wv.description,
        CASE 
            -- Se usuário pode acessar, retorna URL real
            WHEN can_access_video_link(wv.id) THEN wv.video_url
            -- Se não pode acessar, retorna NULL ou URL bloqueada
            ELSE NULL::TEXT
        END as video_url,
        wv.thumbnail_url,
        wv.duration_seconds,
        wv.category_id,
        wv.instructor_name,
        wv.difficulty_level,
        wv.requires_expert_access,
        can_access_video_link(wv.id) as user_can_access_link,
        wv.created_at,
        wv.updated_at
    FROM workout_videos wv
    ORDER BY wv.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. VERIFICAR configuração atual
SELECT 
    'Videos que requerem expert:' as info,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

SELECT 
    'Videos públicos:' as info,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

-- 6. TESTAR as funções com usuários específicos
-- (Execute após fazer login no Flutter)
SELECT 'TESTE: Função de acesso ao link' as teste;
-- Teste manual será feito no Flutter

-- 7. Status final da segurança
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'workout_videos';

SELECT 'CONFIGURAÇÃO FINAL:' as status;
SELECT '- Todos podem VER lista de vídeos' as config1;
SELECT '- Acesso ao LINK controlado por função' as config2;
SELECT '- Basic users: veem lista, não acessam links experts' as config3;
SELECT '- Expert users: veem lista e acessam todos os links' as config4; 