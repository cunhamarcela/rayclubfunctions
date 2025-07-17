-- DIAGNÓSTICO ESPECÍFICO - PROBLEMAS DE NAVEGAÇÃO E HOME
-- ========================================================

-- 1. VERIFICAR SE OS NOVOS VÍDEOS TÊM AS FLAGS CORRETAS
SELECT 
    title,
    instructor_name,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    youtube_url
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY created_at DESC;

-- 2. VERIFICAR VÍDEOS POPULARES (para home)
SELECT 
    'POPULARES' as tipo,
    title,
    instructor_name,
    is_popular,
    created_at
FROM workout_videos 
WHERE is_popular = true
ORDER BY created_at DESC;

-- 3. VERIFICAR VÍDEOS RECOMENDADOS (para home)
SELECT 
    'RECOMENDADOS' as tipo,
    title,
    instructor_name,
    is_recommended,
    created_at
FROM workout_videos 
WHERE is_recommended = true
ORDER BY created_at DESC;

-- 4. VERIFICAR VÍDEOS NOVOS (últimos 30 dias)
SELECT 
    'NOVOS' as tipo,
    title,
    instructor_name,
    is_new,
    created_at
FROM workout_videos 
WHERE created_at > NOW() - INTERVAL '30 days'
ORDER BY created_at DESC;

-- 5. VERIFICAR URLs DO YOUTUBE (problemas de carregamento)
SELECT 
    title,
    youtube_url,
    CASE 
        WHEN youtube_url IS NULL THEN '❌ URL NULA'
        WHEN youtube_url NOT LIKE 'https://youtu.be/%' THEN '⚠️ FORMATO INVÁLIDO'
        WHEN LENGTH(youtube_url) < 20 THEN '⚠️ URL MUITO CURTA'
        ELSE '✅ URL OK'
    END as status_url,
    thumbnail_url
FROM workout_videos 
ORDER BY created_at DESC;

-- 6. VERIFICAR ESTRUTURA DAS CATEGORIAS
SELECT 
    wc.id,
    wc.name,
    wc."workoutsCount" as contador_categoria,
    COUNT(wv.id) as videos_reais,
    CASE 
        WHEN wc."workoutsCount" != COUNT(wv.id) THEN '⚠️ CONTADOR DESATUALIZADO'
        ELSE '✅ CONTADOR OK'
    END as status_contador
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
GROUP BY wc.id, wc.name, wc."workoutsCount"
ORDER BY wc.name;

-- 7. TESTE ESPECÍFICO DE NAVEGAÇÃO - VÍDEOS POR CATEGORIA
SELECT 
    wc.name as categoria,
    wv.title,
    wv.youtube_url,
    wv.difficulty,
    wv.duration,
    wv.instructor_name,
    CASE 
        WHEN wv.youtube_url IS NULL THEN '❌ SEM URL'
        WHEN wv.youtube_url NOT LIKE 'https://youtu.be/%' THEN '⚠️ URL INVÁLIDA'
        ELSE '✅ PODE ABRIR'
    END as pode_abrir
FROM workout_videos wv
JOIN workout_categories wc ON wc.id = wv.category
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
ORDER BY wc.name, wv.order_index;

-- 8. FORÇAR ATUALIZAÇÃO DAS FLAGS (caso não estejam corretas)
-- Marcar novos vídeos de parceiros como is_new, is_popular, is_recommended
UPDATE workout_videos 
SET 
    is_new = true,
    is_popular = true,
    is_recommended = true
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
AND created_at > NOW() - INTERVAL '7 days';

-- 9. VERIFICAR RESULTADO FINAL
SELECT 
    'RESUMO FINAL' as tipo,
    COUNT(*) as total_videos,
    COUNT(CASE WHEN is_new THEN 1 END) as novos,
    COUNT(CASE WHEN is_popular THEN 1 END) as populares,
    COUNT(CASE WHEN is_recommended THEN 1 END) as recomendados,
    COUNT(CASE WHEN youtube_url IS NOT NULL THEN 1 END) as com_url,
    COUNT(CASE WHEN youtube_url LIKE 'https://youtu.be/%' THEN 1 END) as urls_validas
FROM workout_videos; 