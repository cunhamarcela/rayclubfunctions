-- ========================================
-- SOLUÇÃO 3: SISTEMA DE TAGS/METADATA
-- Mais flexível e escalável para futuras categorizações
-- ========================================

-- 1. Adicionar campo tags à tabela workout_videos (PostgreSQL ARRAY)
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

-- 2. Criar índices para tags (GIN para arrays e JSONB)
CREATE INDEX IF NOT EXISTS idx_workout_videos_tags 
ON workout_videos USING GIN (tags);

CREATE INDEX IF NOT EXISTS idx_workout_videos_metadata 
ON workout_videos USING GIN (metadata);

-- 3. Atualizar vídeos de fisioterapia com tags de subcategoria

-- Tags para Testes
UPDATE workout_videos 
SET tags = array_append_distinct(tags, 'subcategoria:testes'),
    metadata = metadata || '{"subcategoria": "testes", "tipo": "avaliacao"}'::jsonb
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%apresentação%' OR
    LOWER(title) LIKE '%teste%' OR
    LOWER(title) LIKE '%avaliação%' OR
    LOWER(description) LIKE '%apresentação%' OR
    LOWER(description) LIKE '%introdução%'
  );

-- Tags para Mobilidade
UPDATE workout_videos 
SET tags = array_append_distinct(tags, 'subcategoria:mobilidade'),
    metadata = metadata || '{"subcategoria": "mobilidade", "tipo": "exercicio"}'::jsonb
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%mobilidade%' OR
    LOWER(description) LIKE '%mobilidade%' OR
    LOWER(description) LIKE '%amplitude%'
  );

-- Tags para Fortalecimento  
UPDATE workout_videos 
SET tags = array_append_distinct(tags, 'subcategoria:fortalecimento'),
    metadata = metadata || '{"subcategoria": "fortalecimento", "tipo": "preventivo"}'::jsonb
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%prevenção%' OR
    LOWER(title) LIKE '%lesões%' OR
    LOWER(title) LIKE '%joelho%' OR
    LOWER(title) LIKE '%coluna%' OR
    LOWER(title) LIKE '%fortalecimento%' OR
    LOWER(description) LIKE '%prevenção%' OR
    LOWER(description) LIKE '%fortaleça%'
  );

-- 4. Adicionar tags gerais de fisioterapia
UPDATE workout_videos 
SET tags = array_append_distinct(tags, 'categoria:fisioterapia'),
    tags = array_append_distinct(tags, 'instrutor:the-unit')
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f';

-- 5. Criar função para buscar vídeos por tag
CREATE OR REPLACE FUNCTION get_videos_by_tag(tag_name TEXT)
RETURNS TABLE(
    video_id UUID,
    title TEXT,
    duration TEXT,
    difficulty TEXT,
    youtube_url TEXT,
    instructor_name TEXT,
    tags_array TEXT[],
    metadata_json JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wv.id,
        wv.title,
        wv.duration,
        wv.difficulty,
        wv.youtube_url,
        wv.instructor_name,
        wv.tags,
        wv.metadata
    FROM workout_videos wv
    WHERE tag_name = ANY(wv.tags)
    ORDER BY wv.order_index, wv.created_at;
END;
$$ LANGUAGE plpgsql;

-- 6. Criar função para buscar vídeos por subcategoria usando metadata
CREATE OR REPLACE FUNCTION get_videos_by_subcategory_meta(subcategory_name TEXT)
RETURNS TABLE(
    video_id UUID,
    title TEXT,
    duration TEXT,
    difficulty TEXT,
    youtube_url TEXT,
    instructor_name TEXT,
    subcategoria TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wv.id,
        wv.title,
        wv.duration,
        wv.difficulty,
        wv.youtube_url,
        wv.instructor_name,
        (wv.metadata->>'subcategoria')::TEXT
    FROM workout_videos wv
    WHERE wv.metadata->>'subcategoria' = subcategory_name
    ORDER BY wv.order_index, wv.created_at;
END;
$$ LANGUAGE plpgsql;

-- 7. Função auxiliar para adicionar tag sem duplicar
CREATE OR REPLACE FUNCTION array_append_distinct(arr TEXT[], new_element TEXT)
RETURNS TEXT[] AS $$
BEGIN
    IF new_element = ANY(arr) THEN
        RETURN arr;
    ELSE
        RETURN array_append(arr, new_element);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. Verificar resultado da migração
SELECT 
    '=== VÍDEOS COM TAGS DE SUBCATEGORIA ===' as info;

SELECT 
    title,
    tags,
    metadata->>'subcategoria' as subcategoria,
    metadata->>'tipo' as tipo
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND tags && ARRAY['subcategoria:testes', 'subcategoria:mobilidade', 'subcategoria:fortalecimento']
ORDER BY metadata->>'subcategoria', title;

-- 9. Estatísticas por subcategoria usando tags
SELECT 
    '=== ESTATÍSTICAS POR SUBCATEGORIA (TAGS) ===' as info;

SELECT 
    metadata->>'subcategoria' as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ') as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND metadata->>'subcategoria' IS NOT NULL
GROUP BY metadata->>'subcategoria'
ORDER BY metadata->>'subcategoria';

-- 10. Busca por tags específicas (exemplos)
SELECT 
    '=== TESTE: BUSCAR POR TAG ===' as info;

-- Buscar vídeos de testes
SELECT title, tags 
FROM workout_videos 
WHERE 'subcategoria:testes' = ANY(tags);

-- Buscar vídeos de mobilidade
SELECT title, tags 
FROM workout_videos 
WHERE 'subcategoria:mobilidade' = ANY(tags);

-- 11. Vídeos não classificados
SELECT 
    '=== VÍDEOS NÃO CLASSIFICADOS ===' as info;

SELECT 
    title,
    description,
    tags,
    metadata
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND NOT (tags && ARRAY['subcategoria:testes', 'subcategoria:mobilidade', 'subcategoria:fortalecimento']);

-- 12. Criar view para facilitar consultas de subcategorias
CREATE OR REPLACE VIEW fisioterapia_subcategorias AS
SELECT 
    wv.id,
    wv.title,
    wv.duration,
    wv.difficulty,
    wv.youtube_url,
    wv.instructor_name,
    wv.description,
    wv.metadata->>'subcategoria' as subcategoria,
    wv.metadata->>'tipo' as tipo_exercicio,
    wv.tags,
    wv.order_index,
    wv.created_at,
    CASE 
        WHEN wv.metadata->>'subcategoria' = 'testes' THEN 1
        WHEN wv.metadata->>'subcategoria' = 'mobilidade' THEN 2
        WHEN wv.metadata->>'subcategoria' = 'fortalecimento' THEN 3
        ELSE 4
    END as subcategoria_order
FROM workout_videos wv
WHERE wv.category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND wv.metadata->>'subcategoria' IS NOT NULL
ORDER BY subcategoria_order, wv.order_index, wv.created_at; 