-- ========================================
-- VERIFICAR SUBCATEGORIAS DE FISIOTERAPIA
-- Verificação rápida do estado atual
-- ========================================

-- Verificar todas as subcategorias existentes na fisioterapia
SELECT 
    COALESCE(subcategory, '(sem subcategoria)') as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategoria;

-- Verificar especificamente vídeos com subcategory = 'estabilidade'
SELECT 
    '=== VÍDEOS NA SUBCATEGORIA ESTABILIDADE ===' as info;

SELECT 
    id,
    title,
    subcategory,
    youtube_url,
    created_at
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'estabilidade'
ORDER BY title;

-- Verificar se ainda há vídeos com 'fortalecimento'
SELECT 
    '=== VÍDEOS COM FORTALECIMENTO (devem ser atualizados) ===' as info;

SELECT 
    id,
    title,
    subcategory,
    youtube_url
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'fortalecimento'; 