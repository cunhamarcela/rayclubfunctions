-- =====================================================
-- SCRIPT: ATUALIZAR THUMBNAILS YOUTUBE - PÃO DE QUEIJO E BANANA TOAST
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Atualizar imagens para usar thumbnails do YouTube
-- Receitas: "Pão de Queijo Fit" e "Banana Toast Saudável"
-- =====================================================

-- VERIFICAR RECEITAS ANTES DA ATUALIZAÇÃO
SELECT 
    '🔍 ANTES DA ATUALIZAÇÃO' as status,
    title,
    video_id,
    image_url,
    content_type,
    author_name
FROM recipes 
WHERE content_type = 'video' 
  AND (title ILIKE '%pão%queijo%fit%' OR title ILIKE '%banana%toast%');

-- =====================================================
-- ATUALIZAR AS IMAGENS PARA THUMBNAILS DO YOUTUBE
-- =====================================================

-- 🍞 ATUALIZAR: Pão de Queijo Fit
UPDATE recipes 
SET 
    image_url = 'https://img.youtube.com/vi/' || video_id || '/maxresdefault.jpg',
    updated_at = NOW()
WHERE content_type = 'video' 
  AND title ILIKE '%pão%queijo%fit%'
  AND video_id IS NOT NULL;

-- 🍌 ATUALIZAR: Banana Toast Saudável  
UPDATE recipes 
SET 
    image_url = 'https://img.youtube.com/vi/' || video_id || '/maxresdefault.jpg',
    updated_at = NOW()
WHERE content_type = 'video' 
  AND title ILIKE '%banana%toast%'
  AND video_id IS NOT NULL;

-- =====================================================
-- VERIFICAR RECEITAS APÓS A ATUALIZAÇÃO
-- =====================================================

SELECT 
    '✅ APÓS A ATUALIZAÇÃO' as status,
    title,
    video_id,
    image_url,
    content_type,
    author_name,
    CASE 
        WHEN image_url LIKE 'https://img.youtube.com/vi/%/maxresdefault.jpg' THEN '✅ YouTube Thumbnail'
        ELSE '⚠️ Outra fonte'
    END as tipo_imagem
FROM recipes 
WHERE content_type = 'video' 
  AND (title ILIKE '%pão%queijo%fit%' OR title ILIKE '%banana%toast%')
ORDER BY title;

-- =====================================================
-- VERIFICAR TODAS AS RECEITAS EM VÍDEO COM THUMBNAILS YOUTUBE
-- =====================================================

SELECT 
    '📊 RESUMO GERAL - VÍDEOS COM THUMBNAILS YOUTUBE' as categoria,
    title,
    video_id,
    CASE 
        WHEN image_url LIKE 'https://img.youtube.com/vi/%/maxresdefault.jpg' THEN '✅ YouTube'
        ELSE '⚠️ Outro'
    END as fonte_imagem,
    author_name,
    category
FROM recipes 
WHERE content_type = 'video' 
  AND author_type = 'nutritionist'
ORDER BY 
    CASE WHEN image_url LIKE 'https://img.youtube.com/vi/%/maxresdefault.jpg' THEN 1 ELSE 2 END,
    title;

-- CONTAR TOTAL DE VÍDEOS COM THUMBNAILS CORRETAS
SELECT 
    '📈 ESTATÍSTICAS' as info,
    COUNT(*) as total_videos,
    SUM(CASE WHEN image_url LIKE 'https://img.youtube.com/vi/%/maxresdefault.jpg' THEN 1 ELSE 0 END) as com_thumbnail_youtube,
    SUM(CASE WHEN image_url NOT LIKE 'https://img.youtube.com/vi/%/maxresdefault.jpg' THEN 1 ELSE 0 END) as outras_fontes
FROM recipes 
WHERE content_type = 'video' AND author_type = 'nutritionist'; 