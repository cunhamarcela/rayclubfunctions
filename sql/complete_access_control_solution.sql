-- SOLUÇÃO COMPLETA: Todos veem vídeos, mas só experts acessam links
-- Backend: Função para verificar acesso
-- Frontend: Controle de UI e cliques

-- 1. LIMPAR tudo que fizemos antes
DROP VIEW IF EXISTS workout_videos;
DROP VIEW IF EXISTS workout_videos_filtered;
DROP VIEW IF EXISTS workout_videos_user;

-- Se tabela foi renomeada, voltar ao nome original
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_videos_raw') THEN
        ALTER TABLE workout_videos_raw RENAME TO workout_videos;
    END IF;
END $$;

-- Remover todas as políticas RLS
DROP POLICY IF EXISTS "workout_videos_expert_only" ON workout_videos;
DROP POLICY IF EXISTS "Auto: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Debug: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "SUPER_STRICT: Só experts veem vídeos" ON workout_videos;

-- Desabilitar RLS (todos podem VER)
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- Remover funções RPC antigas
DROP FUNCTION IF EXISTS get_user_videos(UUID);
DROP FUNCTION IF EXISTS get_user_videos_by_category(UUID, TEXT);
DROP FUNCTION IF EXISTS get_user_popular_videos(UUID);
DROP FUNCTION IF EXISTS can_access_video_link(UUID);

-- 2. CRIAR função para verificar se usuário pode ACESSAR o link do vídeo
CREATE OR REPLACE FUNCTION can_user_access_video_link(
    p_user_id UUID,
    p_video_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    video_requires_expert BOOLEAN;
    user_is_expert BOOLEAN DEFAULT FALSE;
BEGIN
    -- Verificar se o vídeo requer acesso expert
    SELECT requires_expert_access INTO video_requires_expert
    FROM workout_videos 
    WHERE id = p_video_id;
    
    -- Se vídeo não requer expert, qualquer um pode acessar
    IF video_requires_expert IS FALSE OR video_requires_expert IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Se vídeo requer expert, verificar se usuário é expert
    SELECT EXISTS(
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = p_user_id
        AND upl.current_level = 'expert'
        AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
    ) INTO user_is_expert;
    
    RETURN user_is_expert;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. CRIAR função para obter nível do usuário
CREATE OR REPLACE FUNCTION get_user_level(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    user_level TEXT;
BEGIN
    SELECT current_level INTO user_level
    FROM user_progress_level
    WHERE user_id = p_user_id;
    
    RETURN COALESCE(user_level, 'basic');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CRIAR função que retorna vídeos COM informação de acesso
CREATE OR REPLACE FUNCTION get_videos_with_access_info(p_user_id UUID)
RETURNS TABLE(
    id UUID,
    title TEXT,
    duration TEXT,
    duration_minutes INTEGER,
    difficulty TEXT,
    youtube_url TEXT,
    thumbnail_url TEXT,
    category TEXT,
    instructor_name TEXT,
    description TEXT,
    order_index INTEGER,
    is_new BOOLEAN,
    is_popular BOOLEAN,
    is_recommended BOOLEAN,
    requires_expert_access BOOLEAN,
    user_can_access BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wv.id,
        wv.title,
        wv.duration,
        wv.duration_minutes,
        wv.difficulty,
        wv.youtube_url,
        wv.thumbnail_url,
        wv.category,
        wv.instructor_name,
        wv.description,
        wv.order_index,
        wv.is_new,
        wv.is_popular,
        wv.is_recommended,
        wv.requires_expert_access,
        can_user_access_video_link(p_user_id, wv.id) as user_can_access,
        wv.created_at,
        wv.updated_at
    FROM workout_videos wv
    ORDER BY wv.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TESTAR as funções
SELECT 'TESTE DAS FUNÇÕES:' as debug_step;

-- Buscar usuários para teste
SELECT 
    'USUÁRIO BASIC:' as tipo,
    au.id,
    au.email,
    upl.current_level
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'basic'
LIMIT 1;

SELECT 
    'USUÁRIO EXPERT:' as tipo,
    au.id,
    au.email,
    upl.current_level
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'expert'
LIMIT 1;

-- 6. VERIFICAR status final
SELECT 'STATUS FINAL:' as status;
SELECT '✅ Todos podem VER todos os vídeos' as comportamento1;
SELECT '✅ RLS desabilitado - sem filtragem' as comportamento2;
SELECT '✅ Função can_user_access_video_link() controla acesso' as comportamento3;
SELECT '✅ Flutter vai controlar UI baseado no nível do usuário' as comportamento4;

-- 7. CONTAGEM FINAL
SELECT 
    'Total de vídeos visíveis para TODOS:' as info,
    COUNT(*) as total
FROM workout_videos;

SELECT 
    'Vídeos que requerem expert:' as info,
    COUNT(*) as total
FROM workout_videos
WHERE requires_expert_access = true; 