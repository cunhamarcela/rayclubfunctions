-- ALTERNATIVA MAIS SEGURA: View paralela
-- Mantém tabela original + cria view filtrada
-- Flutter pode escolher qual usar dependendo da necessidade

-- 1. MANTER tabela original intacta
-- workout_videos (tabela original - para admin/inserções)

-- 2. CRIAR view filtrada paralela
CREATE OR REPLACE VIEW workout_videos_user AS
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
            WHERE upl.user_id = auth.uid() 
            AND upl.current_level = 'expert'
            AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
        )
    );

-- 3. OPÇÕES PARA O FLUTTER:

-- OPÇÃO A: Mudança mínima no repository
-- Apenas trocar 'workout_videos' por 'workout_videos_user' nas consultas SELECT

-- OPÇÃO B: Função wrapper que decide automaticamente
CREATE OR REPLACE FUNCTION get_user_videos()
RETURNS SETOF workout_videos_user AS $$
BEGIN
    RETURN QUERY SELECT * FROM workout_videos_user ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- OPÇÃO C: Manter tudo como está e usar RPC calls
CREATE OR REPLACE FUNCTION get_videos_by_category(category_param TEXT)
RETURNS SETOF workout_videos_user AS $$
BEGIN
    RETURN QUERY 
    SELECT * FROM workout_videos_user 
    WHERE category = category_param 
    ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. EXEMPLO DE USO NO FLUTTER:

-- ATUAL (não filtrado):
-- await supabase.from('workout_videos').select()

-- NOVA OPÇÃO A (view):
-- await supabase.from('workout_videos_user').select()

-- NOVA OPÇÃO B (função):
-- await supabase.rpc('get_user_videos')

-- NOVA OPÇÃO C (função por categoria):
-- await supabase.rpc('get_videos_by_category', {'category_param': 'corrida'})

-- 5. TESTE
SELECT 'TESTE COMPARATIVO:' as debug_step;

SELECT 
    'Tabela original (admin):' as fonte,
    COUNT(*) as total
FROM workout_videos;

SELECT 
    'View usuário (filtrada):' as fonte,
    COUNT(*) as total
FROM workout_videos_user;

-- 6. RESUMO DAS OPÇÕES
SELECT 'RESUMO DAS OPÇÕES:' as opcoes;
SELECT 'OPÇÃO 1: Substituir tabela por view (mais simples, mas perde INSERT/UPDATE)' as opcao1;
SELECT 'OPÇÃO 2: View paralela (mais flexível, pequena mudança no Flutter)' as opcao2;
SELECT 'OPÇÃO 3: Função RPC (compatibilidade total, chamadas diferentes)' as opcao3; 