-- Script de diagnóstico para investigar problemas com os vídeos de treino não aparecendo no app
-- Diagnóstico dos vídeos inseridos

-- ============================================================================
-- PARTE 1: VERIFICAR SE OS VÍDEOS ESTÃO NA TABELA
-- ============================================================================

-- 1. Verificar estrutura da tabela workout_videos
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
ORDER BY ordinal_position;

-- 2. Contar total de vídeos na tabela
SELECT COUNT(*) as total_videos FROM workout_videos;

-- 3. Verificar se os novos vídeos foram inseridos
SELECT 
    id,
    title,
    duration,
    difficulty,
    youtube_url,
    thumbnail_url,
    category,
    instructor_name,
    is_new,
    is_popular,
    is_recommended,
    created_at
FROM workout_videos 
WHERE youtube_url IN (
    'https://youtu.be/4rOQ2wbHnVU',
    'https://youtu.be/9DuQ5lBul3k', 
    'https://youtu.be/t172SCu4QU0'
)
ORDER BY created_at DESC;

-- 4. Verificar todas as categorias disponíveis
SELECT DISTINCT category FROM workout_videos WHERE category IS NOT NULL;

-- ============================================================================
-- PARTE 2: VERIFICAR TABELA DE CATEGORIAS
-- ============================================================================

-- 5. Verificar categorias de treino
SELECT 
    id,
    name,
    description,
    "workoutsCount",
    image_url,
    created_at
FROM workout_categories 
ORDER BY name;

-- 6. Verificar se as categorias dos novos vídeos existem
SELECT wc.id, wc.name, COUNT(wv.id) as videos_count
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
GROUP BY wc.id, wc.name
ORDER BY wc.name;

-- ============================================================================
-- PARTE 3: DIAGNÓSTICO DE PROBLEMAS POTENCIAIS
-- ============================================================================

-- 7. Verificar se há vídeos com categoria NULL ou inválida
SELECT 
    id,
    title,
    category,
    youtube_url
FROM workout_videos 
WHERE category IS NULL 
   OR category NOT IN (SELECT id FROM workout_categories);

-- 8. Verificar se há problemas com campos obrigatórios
SELECT 
    id,
    title,
    CASE 
        WHEN title IS NULL OR title = '' THEN 'TÍTULO VAZIO'
        WHEN duration IS NULL OR duration = '' THEN 'DURAÇÃO VAZIA'
        WHEN difficulty IS NULL OR difficulty = '' THEN 'DIFICULDADE VAZIA'
        WHEN category IS NULL OR category = '' THEN 'CATEGORIA VAZIA'
        ELSE 'OK'
    END as status,
    youtube_url
FROM workout_videos
WHERE title IS NULL OR title = '' 
   OR duration IS NULL OR duration = ''
   OR difficulty IS NULL OR difficulty = ''
   OR category IS NULL OR category = '';

-- 9. Verificar mapeamento de campo (possível problema)
-- O app pode estar esperando campos diferentes
SELECT 
    id,
    title,
    duration,
    difficulty,
    youtube_url as "youtubeUrl",  -- Note a diferença: youtube_url vs youtubeUrl
    thumbnail_url as "thumbnailUrl",
    category,
    instructor_name as "instructorName",
    description,
    order_index as "orderIndex",
    is_new as "isNew",
    is_popular as "isPopular", 
    is_recommended as "isRecommended",
    created_at as "createdAt",
    updated_at as "updatedAt"
FROM workout_videos 
LIMIT 5;

-- 10. Verificar se os UUIDs das categorias estão corretos
-- Verificar categoria Musculação especificamente
SELECT * FROM workout_categories WHERE LOWER(name) LIKE '%muscula%';

-- Verificar categoria Pilates
SELECT * FROM workout_categories WHERE LOWER(name) LIKE '%pilates%';

-- Verificar categoria Funcional
SELECT * FROM workout_categories WHERE LOWER(name) LIKE '%funcional%';

-- ============================================================================
-- PARTE 4: TESTE DE QUERY ESPECÍFICA QUE O APP USA
-- ============================================================================

-- 11. Simular query que o app faz - buscar por categoria específica
-- Esta é a query que o WorkoutVideosRepository.getVideosByCategory() faz
SELECT *
FROM workout_videos
WHERE category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'  -- ID da categoria Musculação
ORDER BY order_index ASC, created_at DESC;

-- 12. Verificar se existe algum RLS (Row Level Security) bloqueando
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- ============================================================================
-- PARTE 5: CORREÇÕES SUGERIDAS
-- ============================================================================

-- 13. Se os vídeos estão inseridos mas não aparecem, pode ser problema de mapeamento
-- Vamos verificar se precisa atualizar o campo duration_minutes
UPDATE workout_videos 
SET duration_minutes = 
    CASE 
        WHEN duration = '45 min' THEN 45
        WHEN duration = '55 min' THEN 55
        WHEN duration = '40 min' THEN 40
        ELSE 
            CASE 
                WHEN duration ~ '^[0-9]+ min$' THEN 
                    CAST(REGEXP_REPLACE(duration, ' min$', '') AS INTEGER)
                ELSE NULL
            END
    END
WHERE duration_minutes IS NULL 
  AND duration IS NOT NULL;

-- 14. Verificar resultado final
SELECT 
    COUNT(*) as total_videos,
    COUNT(CASE WHEN is_recommended = true THEN 1 END) as recommended_videos,
    COUNT(CASE WHEN is_popular = true THEN 1 END) as popular_videos,
    COUNT(CASE WHEN is_new = true THEN 1 END) as new_videos
FROM workout_videos;

-- ============================================================================
-- PARTE 6: QUERY DE TESTE FINAL
-- ============================================================================

-- 15. Query final para testar se tudo está funcionando
SELECT 
    wv.id,
    wv.title,
    wv.duration,
    wv.difficulty,
    wv.youtube_url,
    wv.category,
    wc.name as category_name,
    wv.instructor_name,
    wv.is_recommended,
    wv.is_popular,
    wv.is_new
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id
WHERE wv.youtube_url IN (
    'https://youtu.be/4rOQ2wbHnVU',
    'https://youtu.be/9DuQ5lBul3k', 
    'https://youtu.be/t172SCu4QU0'
)
ORDER BY wc.name, wv.order_index; 