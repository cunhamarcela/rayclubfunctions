-- CORREÇÃO FINAL - PROBLEMAS DE NAVEGAÇÃO DOS VÍDEOS
-- ===================================================

-- 1. PADRONIZAR TODAS AS URLs DO YOUTUBE
-- Garantir que todas estejam no formato https://youtu.be/VIDEO_ID
UPDATE workout_videos 
SET youtube_url = CASE 
    WHEN youtube_url LIKE 'https://www.youtube.com/watch?v=%' THEN 
        'https://youtu.be/' || SUBSTRING(youtube_url FROM 'v=([^&]+)')
    WHEN youtube_url LIKE 'https://youtube.com/watch?v=%' THEN 
        'https://youtu.be/' || SUBSTRING(youtube_url FROM 'v=([^&]+)')
    WHEN youtube_url LIKE 'www.youtube.com/watch?v=%' THEN 
        'https://youtu.be/' || SUBSTRING(youtube_url FROM 'v=([^&]+)')
    WHEN youtube_url LIKE 'youtube.com/watch?v=%' THEN 
        'https://youtu.be/' || SUBSTRING(youtube_url FROM 'v=([^&]+)')
    ELSE youtube_url
END
WHERE youtube_url IS NOT NULL
AND youtube_url NOT LIKE 'https://youtu.be/%';

-- 2. MARCAR TODOS OS NOVOS VÍDEOS DE PARCEIROS COM AS FLAGS CORRETAS
UPDATE workout_videos 
SET 
    is_new = true,
    is_popular = true,
    is_recommended = true
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 3. ATUALIZAR THUMBNAILS BASEADAS NAS URLs DO YOUTUBE
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    SUBSTRING(youtube_url FROM 'https://youtu\.be/(.+)') || 
    '/maxresdefault.jpg'
WHERE youtube_url LIKE 'https://youtu.be/%'
AND (thumbnail_url IS NULL OR thumbnail_url = '');

-- 4. GARANTIR QUE duration_minutes ESTÁ PREENCHIDO
UPDATE workout_videos 
SET duration_minutes = 
    CASE 
        WHEN duration = '51 seg' THEN 1
        WHEN duration = '8 min' THEN 8
        WHEN duration = '10 min' THEN 10
        WHEN duration = '12 min' THEN 12
        WHEN duration = '15 min' THEN 15
        WHEN duration = '25 min' THEN 25
        WHEN duration = '30 min' THEN 30
        WHEN duration = '40 min' THEN 40
        WHEN duration = '45 min' THEN 45
        WHEN duration = '55 min' THEN 55
        WHEN duration ~ '^[0-9]+ min$' THEN 
            CAST(REGEXP_REPLACE(duration, ' min$', '') AS INTEGER)
        WHEN duration ~ '^[0-9]+ seg$' THEN 1
        ELSE 30 -- valor padrão
    END
WHERE duration_minutes IS NULL OR duration_minutes = 0;

-- 5. ATUALIZAR CONTADORES DAS CATEGORIAS
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = workout_categories.id
);

-- 6. VERIFICAR RESULTADO - VÍDEOS POR CATEGORIA
SELECT 
    wc.name as categoria,
    COUNT(wv.id) as total_videos,
    COUNT(CASE WHEN wv.is_popular THEN 1 END) as populares,
    COUNT(CASE WHEN wv.is_recommended THEN 1 END) as recomendados,
    COUNT(CASE WHEN wv.is_new THEN 1 END) as novos,
    COUNT(CASE WHEN wv.youtube_url LIKE 'https://youtu.be/%' THEN 1 END) as urls_corretas
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
GROUP BY wc.id, wc.name
ORDER BY wc.name;

-- 7. VERIFICAR URLS PROBLEMÁTICAS
SELECT 
    title,
    instructor_name,
    youtube_url,
    CASE 
        WHEN youtube_url IS NULL THEN '❌ URL NULA'
        WHEN youtube_url NOT LIKE 'https://youtu.be/%' THEN '⚠️ FORMATO INVÁLIDO'
        WHEN LENGTH(youtube_url) < 20 THEN '⚠️ URL MUITO CURTA'
        ELSE '✅ URL OK'
    END as status_url
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY instructor_name, title;

-- 8. RESUMO FINAL PARA VERIFICAÇÃO
SELECT 
    'TOTAL VÍDEOS' as tipo,
    COUNT(*) as quantidade
FROM workout_videos

UNION ALL

SELECT 
    'VÍDEOS POPULARES' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE is_popular = true

UNION ALL

SELECT 
    'VÍDEOS RECOMENDADOS' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE is_recommended = true

UNION ALL

SELECT 
    'VÍDEOS NOVOS' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE is_new = true

UNION ALL

SELECT 
    'URLs VÁLIDAS' as tipo,
    COUNT(*) as quantidade
FROM workout_videos 
WHERE youtube_url LIKE 'https://youtu.be/%'

ORDER BY tipo; 