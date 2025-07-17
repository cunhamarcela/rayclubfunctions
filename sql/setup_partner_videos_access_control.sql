-- ========================================
-- CONTROLE DE ACESSO AOS VÍDEOS DOS PARCEIROS - VERSÃO FINAL
-- Baseado na estrutura real das tabelas
-- ========================================

-- 1. MARCAR VÍDEOS DOS PARCEIROS COMO EXCLUSIVOS PARA EXPERT
UPDATE workout_videos 
SET requires_expert_access = true,
    updated_at = CURRENT_TIMESTAMP
WHERE instructor_name IN (
    'Treinos de Musculação',
    'Treinos de musculação', -- Variação encontrada nos dados
    'Goya Health Club',
    'Fight Fit', 
    'Bora Assessoria',
    'The Unit'
);

-- 2. ALTERNATIVAMENTE, MARCAR POR CATEGORIA (TODOS OS VÍDEOS DOS PARCEIROS)
UPDATE workout_videos 
SET requires_expert_access = true,
    updated_at = CURRENT_TIMESTAMP
WHERE category IN (
    '495f6111-00f1-4484-974f-5213a5a44ed8', -- Musculação
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1', -- Pilates
    '43eb2044-38cf-4193-848c-da46fd7e9cb4', -- Funcional
    '07754890-b092-4386-be56-bb088a2a96f1', -- Corrida
    'da178dba-ae94-425a-aaed-133af7b1bb0f'  -- Fisioterapia
);

-- 3. FUNÇÃO PARA VERIFICAR SE USUÁRIO TEM ACESSO À FEATURE WORKOUT_LIBRARY
CREATE OR REPLACE FUNCTION user_has_workout_library_access(user_id_param UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
DECLARE
    user_features TEXT[];
    user_level TEXT;
    expires_at TIMESTAMP;
BEGIN
    -- Se usuário não está autenticado, bloquear acesso
    IF user_id_param IS NULL THEN
        RETURN false;
    END IF;
    
    -- Buscar dados do usuário
    SELECT current_level, unlocked_features, level_expires_at
    INTO user_level, user_features, expires_at
    FROM user_progress_level
    WHERE user_id = user_id_param;
    
    -- IMPORTANTE: Se usuário não encontrado na tabela user_progress_level, BLOQUEAR acesso
    -- Isso garante que usuários novos/não cadastrados não vejam vídeos dos parceiros
    IF user_level IS NULL OR user_features IS NULL THEN
        RETURN false;
    END IF;
    
    -- Se o acesso expirou, não tem acesso
    IF expires_at IS NOT NULL AND expires_at < NOW() THEN
        RETURN false;
    END IF;
    
    -- Usuário deve ser 'expert' E ter a feature 'workout_library'
    IF user_level = 'expert' AND 'workout_library' = ANY(user_features) THEN
        RETURN true;
    END IF;
    
    -- Todos os outros casos: bloquear acesso
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. REMOVER POLÍTICA ATUAL (SE EXISTIR)
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos básicos são públicos" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas básicos" ON workout_videos;

-- 5. CRIAR POLÍTICAS DE ACESSO BASEADAS EM WORKOUT_LIBRARY FEATURE

-- Política principal para usuários autenticados
CREATE POLICY "Controle de acesso aos vídeos dos parceiros" ON workout_videos
    FOR SELECT USING (
        -- Vídeos que não requerem acesso expert podem ser vistos por todos
        requires_expert_access = false
        OR 
        -- Vídeos que requerem acesso expert só podem ser vistos por usuários com workout_library
        (requires_expert_access = true AND user_has_workout_library_access())
    );

-- Política específica para usuários não autenticados (apenas vídeos públicos)
CREATE POLICY "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos
    FOR SELECT USING (
        auth.uid() IS NULL AND requires_expert_access = false
    );

-- 6. FUNÇÃO PARA TESTAR ACESSO DE UM USUÁRIO ESPECÍFICO
CREATE OR REPLACE FUNCTION test_user_video_access_with_categories(
    user_id_param UUID,
    video_id_param UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    video_info RECORD;
    user_has_access BOOLEAN;
    user_data RECORD;
    result JSON;
    total_videos INTEGER;
    accessible_videos INTEGER;
BEGIN
    -- Buscar dados do usuário
    SELECT current_level, unlocked_features, level_expires_at
    INTO user_data
    FROM user_progress_level
    WHERE user_id = user_id_param;
    
    -- Verificar acesso geral
    user_has_access := user_has_workout_library_access(user_id_param);
    
    -- Contar vídeos totais e acessíveis
    SELECT COUNT(*) INTO total_videos FROM workout_videos;
    
    SELECT COUNT(*) INTO accessible_videos 
    FROM workout_videos 
    WHERE requires_expert_access = false 
       OR (requires_expert_access = true AND user_has_access);
    
    -- Se foi passado um vídeo específico, buscar detalhes
    IF video_id_param IS NOT NULL THEN
        SELECT 
            wv.id, wv.title, wv.instructor_name, wv.requires_expert_access,
            wc.name as category_name
        INTO video_info
        FROM workout_videos wv
        LEFT JOIN workout_categories wc ON wv.category = wc.id
        WHERE wv.id = video_id_param;
    END IF;
    
    -- Montar resultado
    result := json_build_object(
        'user_id', user_id_param,
        'user_level', COALESCE(user_data.current_level, 'not_found'),
        'user_features', COALESCE(user_data.unlocked_features, ARRAY[]::TEXT[]),
        'has_workout_library_access', user_has_access,
        'level_expires_at', user_data.level_expires_at,
        'total_videos', total_videos,
        'accessible_videos', accessible_videos,
        'blocked_videos', total_videos - accessible_videos,
        'specific_video', CASE 
            WHEN video_id_param IS NOT NULL AND video_info.id IS NOT NULL THEN
                json_build_object(
                    'id', video_info.id,
                    'title', video_info.title,
                    'instructor', video_info.instructor_name,
                    'category', video_info.category_name,
                    'requires_expert_access', video_info.requires_expert_access,
                    'user_can_access', NOT video_info.requires_expert_access OR user_has_access
                )
            ELSE NULL
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNÇÃO PARA OBTER ESTATÍSTICAS DE ACESSO
CREATE OR REPLACE FUNCTION get_video_access_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_videos', (SELECT COUNT(*) FROM workout_videos),
        'expert_only_videos', (SELECT COUNT(*) FROM workout_videos WHERE requires_expert_access = true),
        'public_videos', (SELECT COUNT(*) FROM workout_videos WHERE requires_expert_access = false),
        'categories_with_expert_videos', (
            SELECT json_agg(json_build_object(
                'category_id', wc.id,
                'category_name', wc.name,
                'total_videos', wc."workoutsCount",
                'expert_only_videos', (
                    SELECT COUNT(*) 
                    FROM workout_videos wv 
                    WHERE wv.category = wc.id AND wv.requires_expert_access = true
                )
            ))
            FROM workout_categories wc
        ),
        'partner_instructors', (
            SELECT json_agg(json_build_object(
                'instructor', instructor_name,
                'total_videos', COUNT(*),
                'expert_only_videos', COUNT(*) FILTER (WHERE requires_expert_access = true)
            ))
            FROM workout_videos
            WHERE instructor_name IN (
                'Treinos de Musculação', 'Treinos de musculação',
                'Goya Health Club', 'Fight Fit', 
                'Bora Assessoria', 'The Unit'
            )
            GROUP BY instructor_name
        ),
        'user_stats', (
            SELECT json_build_object(
                'total_users', COUNT(*),
                'basic_users', COUNT(*) FILTER (WHERE current_level = 'basic'),
                'expert_users', COUNT(*) FILTER (WHERE current_level = 'expert'),
                'users_with_workout_library', COUNT(*) FILTER (WHERE 'workout_library' = ANY(unlocked_features))
            )
            FROM user_progress_level
        )
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. FUNÇÃO PARA GERENCIAR ACESSO DE VÍDEOS (ADMIN)
CREATE OR REPLACE FUNCTION toggle_video_expert_access(
    video_id_param UUID,
    requires_expert BOOLEAN
)
RETURNS JSON AS $$
DECLARE
    video_title TEXT;
    affected_rows INTEGER;
BEGIN
    -- Buscar título do vídeo
    SELECT title INTO video_title FROM workout_videos WHERE id = video_id_param;
    
    IF video_title IS NULL THEN
        RETURN json_build_object('error', 'Video not found');
    END IF;
    
    -- Atualizar acesso
    UPDATE workout_videos 
    SET requires_expert_access = requires_expert,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = video_id_param;
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    RETURN json_build_object(
        'success', true,
        'video_id', video_id_param,
        'video_title', video_title,
        'requires_expert_access', requires_expert,
        'affected_rows', affected_rows
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. FUNÇÃO PARA GERENCIAR ACESSO POR INSTRUTOR (ADMIN)
CREATE OR REPLACE FUNCTION set_instructor_access_level(
    instructor_name_param TEXT,
    requires_expert BOOLEAN DEFAULT true
)
RETURNS JSON AS $$
DECLARE
    affected_rows INTEGER;
BEGIN
    UPDATE workout_videos 
    SET requires_expert_access = requires_expert,
        updated_at = CURRENT_TIMESTAMP
    WHERE instructor_name = instructor_name_param;
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    RETURN json_build_object(
        'success', true,
        'instructor_name', instructor_name_param,
        'requires_expert_access', requires_expert,
        'affected_videos', affected_rows
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. FUNÇÃO PARA TESTAR DIFERENTES CENÁRIOS DE USUÁRIOS
CREATE OR REPLACE FUNCTION test_access_scenarios()
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_videos INTEGER;
    expert_only_videos INTEGER;
    sample_basic_user UUID;
    sample_expert_user UUID;
BEGIN
    -- Contar vídeos
    SELECT COUNT(*) INTO total_videos FROM workout_videos;
    SELECT COUNT(*) INTO expert_only_videos FROM workout_videos WHERE requires_expert_access = true;
    
    -- Pegar usuários de exemplo
    SELECT user_id INTO sample_basic_user FROM user_progress_level WHERE current_level = 'basic' LIMIT 1;
    SELECT user_id INTO sample_expert_user FROM user_progress_level WHERE current_level = 'expert' LIMIT 1;
    
    result := json_build_object(
        'total_videos', total_videos,
        'expert_only_videos', expert_only_videos,
        'public_videos', total_videos - expert_only_videos,
        'test_scenarios', json_build_object(
            'user_not_authenticated', json_build_object(
                'user_id', NULL,
                'has_access', user_has_workout_library_access(NULL),
                'description', 'Usuário não logado - deve ser FALSE'
            ),
            'user_not_in_table', json_build_object(
                'user_id', 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
                'has_access', user_has_workout_library_access('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'::UUID),
                'description', 'Usuário não existe na tabela user_progress_level - deve ser FALSE'
            ),
            'basic_user_sample', json_build_object(
                'user_id', sample_basic_user,
                'has_access', CASE WHEN sample_basic_user IS NOT NULL THEN user_has_workout_library_access(sample_basic_user) ELSE NULL END,
                'description', 'Usuário basic - deve ser FALSE'
            ),
            'expert_user_sample', json_build_object(
                'user_id', sample_expert_user,
                'has_access', CASE WHEN sample_expert_user IS NOT NULL THEN user_has_workout_library_access(sample_expert_user) ELSE NULL END,
                'description', 'Usuário expert - deve ser TRUE'
            )
        )
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- VERIFICAÇÕES E COMANDOS ÚTEIS
-- ========================================

-- Verificar quantos vídeos foram marcados como expert-only:
SELECT 
    'Vídeos bloqueados para usuários basic' as info,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE requires_expert_access = true;

-- Ver estatísticas completas:
SELECT get_video_access_stats();

-- TESTAR TODOS OS CENÁRIOS DE ACESSO:
SELECT test_access_scenarios();

-- Testar acesso de um usuário específico:
-- SELECT test_user_video_access_with_categories('seu-user-id-aqui');

-- Testar acesso de um usuário a um vídeo específico:
-- SELECT test_user_video_access_with_categories('seu-user-id-aqui', 'video-id-aqui');

-- Testar usuário que não existe na tabela:
-- SELECT test_user_video_access_with_categories('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee');

/*
========================================
COMANDOS PARA GERENCIAMENTO (EXEMPLOS)
========================================

-- Liberar todos os vídeos de um instrutor:
SELECT set_instructor_access_level('Goya Health Club', false);

-- Bloquear todos os vídeos de um instrutor:
SELECT set_instructor_access_level('Fight Fit', true);

-- Liberar um vídeo específico:
SELECT toggle_video_expert_access('video-id-aqui', false);

-- Bloquear um vídeo específico:
SELECT toggle_video_expert_access('video-id-aqui', true);

-- Ver resumo dos vídeos por categoria:
SELECT 
    wc.name as categoria,
    COUNT(wv.id) as total_videos,
    COUNT(wv.id) FILTER (WHERE wv.requires_expert_access = true) as expert_only,
    COUNT(wv.id) FILTER (WHERE wv.requires_expert_access = false) as publicos
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
GROUP BY wc.id, wc.name
ORDER BY wc.name;
*/ 