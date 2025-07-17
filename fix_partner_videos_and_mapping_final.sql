-- =====================================================================
-- SCRIPT FINAL: CORREÇÃO COMPLETA DOS VÍDEOS DOS PARCEIROS E MAPEAMENTO
-- =====================================================================

-- 1. CORRIGIR IDs INCORRETOS DE CATEGORIAS
-- Substituir o ID incorreto d2d2a9b8-d861-47c7-9d26-283539beda24 pelo correto
UPDATE workout_videos 
SET category = '495f6111-00f1-4484-974f-5213a5a44ed8'
WHERE category = 'd2d2a9b8-d861-47c7-9d26-283539beda24';

-- 2. VERIFICAR ESTRUTURA DAS TABELAS PRIMEIRO
SELECT 'ESTRUTURA workout_categories' as tabela, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_categories' 
ORDER BY ordinal_position;

SELECT 'ESTRUTURA workout_videos' as tabela, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
ORDER BY ordinal_position;

-- 3. ATUALIZAR CONTAGEM DE VÍDEOS (usando nome correto workoutsCount)
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = workout_categories.id::varchar
)
WHERE name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia');

-- 4. ATUALIZAR THUMBNAILS AUTOMÁTICAS DOS VÍDEOS
-- Para URLs youtu.be
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    SUBSTRING(youtube_url FROM 'youtu\.be/([^/?]+)') || 
    '/maxresdefault.jpg'
WHERE thumbnail_url IS NULL 
AND youtube_url LIKE '%youtu.be/%'
AND SUBSTRING(youtube_url FROM 'youtu\.be/([^/?]+)') IS NOT NULL;

-- Para URLs youtube.com/watch
UPDATE workout_videos 
SET thumbnail_url = 'https://img.youtube.com/vi/' || 
    SUBSTRING(youtube_url FROM '[?&]v=([^&]+)') || 
    '/maxresdefault.jpg'
WHERE thumbnail_url IS NULL 
AND youtube_url LIKE '%youtube.com/watch%'
AND SUBSTRING(youtube_url FROM '[?&]v=([^&]+)') IS NOT NULL;

-- 5. MARCAR VÍDEOS COMO POPULARES E NOVOS (na tabela workout_videos)
UPDATE workout_videos 
SET is_popular = true 
WHERE is_recommended = true;

UPDATE workout_videos 
SET is_new = true 
WHERE created_at > NOW() - INTERVAL '30 days';

-- 6. VERIFICAÇÃO FINAL - DADOS CORRETOS
SELECT 
    '=== CATEGORIAS COM VÍDEOS ===' as secao,
    wc.id,
    wc.name,
    wc.description,
    wc."workoutsCount" as contador_videos,
    COUNT(wv.id) as videos_reais
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id::varchar
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
GROUP BY wc.id, wc.name, wc.description, wc."workoutsCount"
ORDER BY wc.name;

-- 7. LISTAR VÍDEOS PARA VERIFICAÇÃO
SELECT 
    '=== VÍDEOS POR CATEGORIA ===' as secao,
    wc.name as categoria,
    wv.title as titulo,
    wv.instructor_name as instrutor,
    wv.difficulty as dificuldade,
    wv.duration,
    CASE 
        WHEN wv.youtube_url IS NOT NULL THEN 'YouTube OK'
        ELSE 'Sem vídeo'
    END as status_video,
    CASE 
        WHEN wv.thumbnail_url IS NOT NULL THEN 'Thumb OK'
        ELSE 'Sem thumb'
    END as status_thumb
FROM workout_categories wc
JOIN workout_videos wv ON wv.category = wc.id::varchar
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
ORDER BY wc.name, wv.order_index;

-- 8. VERIFICAR SE HÁ VÍDEOS COM CATEGORIAS INVÁLIDAS
SELECT 
    '=== VÍDEOS COM CATEGORIAS INVÁLIDAS ===' as secao,
    wv.category as categoria_id,
    wv.title,
    wv.instructor_name
FROM workout_videos wv
LEFT JOIN workout_categories wc ON wv.category = wc.id::varchar
WHERE wc.id IS NULL;

-- 9. RELATÓRIO FINAL DE SUCESSO
SELECT 
    '=== RELATÓRIO FINAL ===' as status,
    COUNT(*) as total_videos_parceiros,
    COUNT(DISTINCT wv.category) as categorias_com_videos,
    COUNT(CASE WHEN wv.youtube_url IS NOT NULL THEN 1 END) as videos_com_youtube,
    COUNT(CASE WHEN wv.thumbnail_url IS NOT NULL THEN 1 END) as videos_com_thumbnail
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id::varchar
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia');

-- 10. INSTRUÇÕES PARA VERIFICAÇÃO NO FLUTTER
SELECT '=== PRÓXIMOS PASSOS ===' as instrucoes,
'1. Execute este script no Supabase' as passo_1,
'2. Verifique estrutura das tabelas na saída acima' as passo_2,
'3. Teste navegação: Home > Ver todos > Categoria > Vídeo' as passo_3,
'4. Teste navegação: Treinos > Categoria > Vídeo' as passo_4,
'5. Verifique se todos os vídeos carregam e tocam' as passo_5; 