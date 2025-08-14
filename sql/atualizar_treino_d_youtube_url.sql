-- ✨ ATUALIZAÇÃO TREINO D - YouTube URL e Thumbnail
-- 📌 Data: 2025-01-21 às 23:35
-- 🎯 Objetivo: Atualizar apenas youtube_url e thumbnail_url do Treino D
-- 📄 ID: c017119f-363c-4476-af38-f92140c089e2

-- Verificar se o registro existe antes da atualização
SELECT 
    id,
    title,
    youtube_url as url_atual,
    thumbnail_url as thumbnail_atual
FROM workout_videos 
WHERE id = 'c017119f-363c-4476-af38-f92140c089e2';

-- Atualizar APENAS youtube_url e thumbnail_url
UPDATE workout_videos 
SET 
    youtube_url = 'https://youtu.be/ag4TSR2JydQ',
    thumbnail_url = 'https://img.youtube.com/vi/ag4TSR2JydQ/maxresdefault.jpg',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'c017119f-363c-4476-af38-f92140c089e2';

-- Verificar se a atualização foi aplicada
SELECT 
    id,
    title,
    youtube_url as url_nova,
    thumbnail_url as thumbnail_nova,
    updated_at
FROM workout_videos 
WHERE id = 'c017119f-363c-4476-af38-f92140c089e2';

-- ✅ Status: Script pronto para executar
-- ⚠️ IMPORTANTE: Execute apenas se o ID existir no banco de dados 