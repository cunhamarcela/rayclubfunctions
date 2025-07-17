-- Script para corrigir duplicatas e otimizar os vídeos de treino
-- Baseado no diagnóstico realizado

-- ============================================================================
-- PARTE 1: REMOVER DUPLICATAS
-- ============================================================================

-- 1. Verificar duplicatas por YouTube URL
SELECT 
    youtube_url,
    COUNT(*) as total,
    ARRAY_AGG(id ORDER BY created_at ASC) as ids,
    ARRAY_AGG(title ORDER BY created_at ASC) as titles
FROM workout_videos 
WHERE youtube_url IS NOT NULL
GROUP BY youtube_url
HAVING COUNT(*) > 1;

-- 2. Remover o vídeo duplicado mais antigo (manter o mais recente)
-- Remover o "Técnica" antigo, manter o "FightFit - Técnica" mais novo
DELETE FROM workout_videos 
WHERE id = '8c215470-40de-4b72-849a-2729f31c3157';

-- ============================================================================
-- PARTE 2: VERIFICAR E CORRIGIR CAMPOS ESSENCIAIS
-- ============================================================================

-- 3. Atualizar duration_minutes para todos os vídeos
UPDATE workout_videos 
SET duration_minutes = 
    CASE 
        WHEN duration = '45 min' THEN 45
        WHEN duration = '55 min' THEN 55  
        WHEN duration = '40 min' THEN 40
        WHEN duration ~ '^[0-9]+ min$' THEN 
            CAST(REGEXP_REPLACE(duration, ' min$', '') AS INTEGER)
        ELSE 30 -- valor padrão
    END
WHERE duration_minutes IS NULL;

-- 4. Garantir que thumbnail_url está preenchida
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    REGEXP_REPLACE(youtube_url, 'https://youtu\.be/', '') || 
    '/maxresdefault.jpg'
WHERE thumbnail_url IS NULL 
  AND youtube_url IS NOT NULL
  AND youtube_url LIKE 'https://youtu.be/%';

-- ============================================================================
-- PARTE 3: VERIFICAR CATEGORIAS E ATUALIZAR CONTADORES
-- ============================================================================

-- 5. Verificar se todas as categorias usadas existem
SELECT DISTINCT 
    wv.category,
    wc.name as category_name
FROM workout_videos wv
LEFT JOIN workout_categories wc ON wv.category = wc.id
ORDER BY wc.name;

-- 6. Atualizar contador de vídeos nas categorias
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = workout_categories.id
);

-- ============================================================================
-- PARTE 4: VERIFICAÇÃO FINAL
-- ============================================================================

-- 7. Contagem final
SELECT 
    'TOTAL' as tipo,
    COUNT(*) as quantidade
FROM workout_videos

UNION ALL

SELECT 
    'RECOMENDADOS' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE is_recommended = true

UNION ALL

SELECT 
    'POPULARES' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE is_popular = true

UNION ALL

SELECT 
    'NOVOS' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE is_new = true;

-- 8. Verificar vídeos por categoria
SELECT 
    wc.name as categoria,
    COUNT(wv.id) as total_videos,
    COUNT(CASE WHEN wv.is_recommended THEN 1 END) as recomendados,
    COUNT(CASE WHEN wv.is_popular THEN 1 END) as populares,
    COUNT(CASE WHEN wv.is_new THEN 1 END) as novos
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
GROUP BY wc.id, wc.name
ORDER BY wc.name;

-- 9. Listar todos os vídeos organizados
SELECT 
    wc.name as categoria,
    wv.title,
    wv.duration,
    wv.difficulty,
    wv.instructor_name,
    wv.is_recommended,
    wv.is_popular,
    wv.is_new,
    wv.created_at
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id
ORDER BY wc.name, wv.order_index, wv.created_at DESC; 