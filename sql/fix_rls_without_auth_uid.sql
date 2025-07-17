-- ========================================
-- SISTEMA RLS SEM DEPENDÊNCIA DE auth.uid()
-- ========================================

-- 1. REMOVER POLÍTICAS QUE DEPENDEM DE auth.uid()
DROP POLICY IF EXISTS "Apenas experts podem ver vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Controle de acesso aos vídeos dos parceiros" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;

-- 2. TEMPORARIAMENTE DESABILITAR RLS PARA TESTAR
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- 3. CRIAR FUNÇÃO QUE VERIFICA SE UM USER_ID ESPECÍFICO É EXPERT
CREATE OR REPLACE FUNCTION check_if_user_is_expert(check_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_level TEXT;
    expires_at TIMESTAMP;
BEGIN
    -- Se não tem user_id, não é expert
    IF check_user_id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Buscar nível do usuário
    SELECT current_level, level_expires_at
    INTO user_level, expires_at
    FROM user_progress_level
    WHERE user_id = check_user_id;
    
    -- Se não encontrou, não é expert
    IF user_level IS NULL THEN
        RETURN false;
    END IF;
    
    -- Se expirou, não é expert
    IF expires_at IS NOT NULL AND expires_at < NOW() THEN
        RETURN false;
    END IF;
    
    -- Retorna true apenas se for expert
    RETURN user_level = 'expert';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. FUNÇÃO PARA O FLUTTER USAR
CREATE OR REPLACE FUNCTION get_videos_for_user(user_id_param UUID)
RETURNS TABLE(
    id UUID,
    title VARCHAR,
    duration VARCHAR,
    duration_minutes INTEGER,
    difficulty VARCHAR,
    youtube_url TEXT,
    thumbnail_url TEXT,
    category VARCHAR,
    instructor_name VARCHAR,
    description TEXT,
    order_index INTEGER,
    is_new BOOLEAN,
    is_popular BOOLEAN,
    is_recommended BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    -- Se o usuário é expert, retorna todos os vídeos
    IF check_if_user_is_expert(user_id_param) THEN
        RETURN QUERY 
        SELECT 
            wv.id, wv.title, wv.duration, wv.duration_minutes, wv.difficulty,
            wv.youtube_url, wv.thumbnail_url, wv.category, wv.instructor_name,
            wv.description, wv.order_index, wv.is_new, wv.is_popular, 
            wv.is_recommended, wv.created_at, wv.updated_at
        FROM workout_videos wv
        ORDER BY wv.order_index, wv.created_at DESC;
    ELSE
        -- Se não é expert, retorna lista vazia
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TESTAR COM USUÁRIOS REAIS DA TABELA
-- Pegar um usuário expert para testar
WITH expert_user AS (
    SELECT user_id, current_level
    FROM user_progress_level 
    WHERE current_level = 'expert' 
    LIMIT 1
)
SELECT 
    'TESTE COM USUÁRIO EXPERT' as teste,
    eu.user_id,
    eu.current_level,
    check_if_user_is_expert(eu.user_id) as funcao_retorna_expert,
    (SELECT COUNT(*) FROM get_videos_for_user(eu.user_id)) as videos_que_ve
FROM expert_user eu;

-- Pegar um usuário basic para testar  
WITH basic_user AS (
    SELECT user_id, current_level
    FROM user_progress_level 
    WHERE current_level = 'basic' 
    LIMIT 1
)
SELECT 
    'TESTE COM USUÁRIO BASIC' as teste,
    bu.user_id,
    bu.current_level,
    check_if_user_is_expert(bu.user_id) as funcao_retorna_expert,
    (SELECT COUNT(*) FROM get_videos_for_user(bu.user_id)) as videos_que_ve
FROM basic_user bu;

-- 6. MOSTRAR USER_IDS PARA TESTE MANUAL
SELECT 
    'USUÁRIOS EXPERT (copie um ID para testar):' as info,
    user_id
FROM user_progress_level 
WHERE current_level = 'expert' 
LIMIT 5;

SELECT 
    'USUÁRIOS BASIC (copie um ID para testar):' as info,
    user_id
FROM user_progress_level 
WHERE current_level = 'basic' 
LIMIT 5; 