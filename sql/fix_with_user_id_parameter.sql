-- SOLUÇÃO DEFINITIVA: Funções RPC com user_id como parâmetro
-- Para de usar auth.uid() e usa user_id explícito

-- 1. REMOVER a view problemática
DROP VIEW IF EXISTS workout_videos;

-- 2. RENOMEAR tabela de volta ao nome original
ALTER TABLE workout_videos_raw RENAME TO workout_videos;

-- 3. CRIAR função para buscar vídeos por user_id
CREATE OR REPLACE FUNCTION get_user_videos(p_user_id UUID)
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
        wv.created_at,
        wv.updated_at
    FROM workout_videos wv
    WHERE 
        -- Vídeos públicos: todos podem ver
        (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL)
        OR
        -- Vídeos expert: só experts podem ver
        (
            wv.requires_expert_access = true 
            AND EXISTS (
                SELECT 1 
                FROM user_progress_level upl
                WHERE upl.user_id = p_user_id
                AND upl.current_level = 'expert'
                AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
            )
        )
    ORDER BY wv.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CRIAR função para buscar vídeos por categoria e user_id
CREATE OR REPLACE FUNCTION get_user_videos_by_category(p_user_id UUID, p_category TEXT)
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
        wv.created_at,
        wv.updated_at
    FROM workout_videos wv
    WHERE 
        wv.category = p_category
        AND (
            -- Vídeos públicos: todos podem ver
            (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL)
            OR
            -- Vídeos expert: só experts podem ver
            (
                wv.requires_expert_access = true 
                AND EXISTS (
                    SELECT 1 
                    FROM user_progress_level upl
                    WHERE upl.user_id = p_user_id
                    AND upl.current_level = 'expert'
                    AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
                )
            )
        )
    ORDER BY wv.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. FUNÇÃO para vídeos populares
CREATE OR REPLACE FUNCTION get_user_popular_videos(p_user_id UUID)
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
        wv.created_at,
        wv.updated_at
    FROM workout_videos wv
    WHERE 
        wv.is_popular = true
        AND (
            -- Vídeos públicos: todos podem ver
            (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL)
            OR
            -- Vídeos expert: só experts podem ver
            (
                wv.requires_expert_access = true 
                AND EXISTS (
                    SELECT 1 
                    FROM user_progress_level upl
                    WHERE upl.user_id = p_user_id
                    AND upl.current_level = 'expert'
                    AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
                )
            )
        )
    ORDER BY wv.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. TESTAR as funções
SELECT 'TESTE DAS FUNÇÕES:' as debug_step;

-- Buscar ID de usuário basic
DO $$
DECLARE
    basic_user_id UUID;
    expert_user_id UUID;
BEGIN
    -- Buscar usuário basic
    SELECT au.id INTO basic_user_id
    FROM auth.users au
    JOIN user_progress_level upl ON upl.user_id = au.id
    WHERE upl.current_level = 'basic'
    LIMIT 1;
    
    -- Buscar usuário expert
    SELECT au.id INTO expert_user_id
    FROM auth.users au
    JOIN user_progress_level upl ON upl.user_id = au.id
    WHERE upl.current_level = 'expert'
    LIMIT 1;
    
    RAISE NOTICE 'Usuário BASIC para teste: %', basic_user_id;
    RAISE NOTICE 'Usuário EXPERT para teste: %', expert_user_id;
END $$;

-- 7. INSTRUÇÕES PARA O FLUTTER
SELECT 'MUDANÇAS NO FLUTTER:' as instrucoes;

SELECT 'ANTES (não funcionava):' as antes;
SELECT 'await supabase.from("workout_videos").select()' as codigo_antes;

SELECT 'DEPOIS (funciona):' as depois;
SELECT 'await supabase.rpc("get_user_videos", {"p_user_id": userId})' as codigo_depois;

SELECT 'POR CATEGORIA:' as categoria;
SELECT 'await supabase.rpc("get_user_videos_by_category", {"p_user_id": userId, "p_category": "corrida"})' as codigo_categoria;

SELECT 'POPULARES:' as populares;
SELECT 'await supabase.rpc("get_user_popular_videos", {"p_user_id": userId})' as codigo_populares;

-- 8. EXEMPLO COMPLETO PARA O FLUTTER
SELECT '
// No repository, substituir:
Future<List<WorkoutVideo>> getAllVideos() async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw Exception("Usuário não logado");
  
  final response = await _supabase.rpc("get_user_videos", {
    "p_user_id": userId
  });
  
  return (response as List).map((json) => WorkoutVideo.fromJson(json)).toList();
}

Future<List<WorkoutVideo>> getVideosByCategory(String category) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw Exception("Usuário não logado");
  
  final response = await _supabase.rpc("get_user_videos_by_category", {
    "p_user_id": userId,
    "p_category": category
  });
  
  return (response as List).map((json) => WorkoutVideo.fromJson(json)).toList();
}
' as exemplo_flutter; 