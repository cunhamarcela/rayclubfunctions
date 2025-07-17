-- ======================================================================
-- SCRIPT PARA ATUALIZAR THUMBNAILS DO YOUTUBE PARA VÍDEOS DOS PARCEIROS
-- ======================================================================

-- 1. Verificar vídeos sem thumbnail
SELECT 
    'VÍDEOS SEM THUMBNAIL' as status,
    instructor_name,
    title,
    youtube_url,
    thumbnail_url
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
AND (thumbnail_url IS NULL OR thumbnail_url = '')
ORDER BY instructor_name, title;

-- 2. Extrair thumbnails para URLs do tipo youtu.be
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    SUBSTRING(youtube_url FROM 'youtu\.be/([^/?]+)') || 
    '/maxresdefault.jpg'
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
AND (thumbnail_url IS NULL OR thumbnail_url = '')
AND youtube_url LIKE '%youtu.be/%'
AND SUBSTRING(youtube_url FROM 'youtu\.be/([^/?]+)') IS NOT NULL;

-- 3. Extrair thumbnails para URLs do tipo youtube.com/watch
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    SUBSTRING(youtube_url FROM '[?&]v=([^&]+)') || 
    '/maxresdefault.jpg'
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
AND (thumbnail_url IS NULL OR thumbnail_url = '')
AND youtube_url LIKE '%youtube.com/watch%'
AND SUBSTRING(youtube_url FROM '[?&]v=([^&]+)') IS NOT NULL;

-- 4. Fallback para outras URLs do YouTube
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    SUBSTRING(youtube_url FROM 'youtube\.com/.*[?&]v=([^&]+)') || 
    '/maxresdefault.jpg'
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
AND (thumbnail_url IS NULL OR thumbnail_url = '')
AND youtube_url LIKE '%youtube.com%'
AND SUBSTRING(youtube_url FROM 'youtube\.com/.*[?&]v=([^&]+)') IS NOT NULL;

-- 5. Verificar resultado final
SELECT 
    '=== RESULTADO FINAL ===' as status,
    instructor_name,
    title,
    youtube_url,
    thumbnail_url,
    CASE 
        WHEN thumbnail_url IS NOT NULL AND thumbnail_url != '' THEN '✅ THUMBNAIL OK'
        ELSE '❌ SEM THUMBNAIL'
    END as status_thumbnail
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY instructor_name, title;

-- 6. Estatísticas finais
SELECT 
    '=== ESTATÍSTICAS FINAIS ===' as relatorio,
    COUNT(*) as total_videos_parceiros,
    COUNT(CASE WHEN thumbnail_url IS NOT NULL AND thumbnail_url != '' THEN 1 END) as videos_com_thumbnail,
    COUNT(CASE WHEN thumbnail_url IS NULL OR thumbnail_url = '' THEN 1 END) as videos_sem_thumbnail,
    ROUND(
        (COUNT(CASE WHEN thumbnail_url IS NOT NULL AND thumbnail_url != '' THEN 1 END) * 100.0 / COUNT(*)), 
        2
    ) as percentual_com_thumbnail
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 7. Instruções para o desenvolvedor
SELECT 
    '=== PRÓXIMOS PASSOS ===' as instrucoes,
    '1. Execute este script no Supabase SQL Editor' as passo_1,
    '2. Verifique se todos os vídeos têm thumbnail na seção RESULTADO FINAL' as passo_2,
    '3. Teste o app para ver se as thumbnails estão aparecendo' as passo_3,
    '4. Se algum vídeo ainda não tiver thumbnail, verifique o formato da URL' as passo_4; 