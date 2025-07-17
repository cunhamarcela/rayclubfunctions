-- =================================================================
-- SCRIPT PARA ATUALIZAR has_pdf_materials DOS VÍDEOS COM PDF
-- Execute no Supabase SQL Editor
-- =================================================================

-- Atualizar os vídeos que têm materiais PDF associados
UPDATE workout_videos 
SET has_pdf_materials = true
WHERE id IN (
    -- Buscar IDs dos vídeos que têm materiais na tabela materials
    SELECT DISTINCT workout_video_id 
    FROM materials 
    WHERE workout_video_id IS NOT NULL
);

-- Verificar se a atualização funcionou
SELECT 
    wv.id,
    wv.title,
    wv.has_pdf_materials,
    COUNT(m.id) as pdf_count
FROM workout_videos wv
LEFT JOIN materials m ON wv.id = m.workout_video_id
WHERE wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8'
AND wv.title ILIKE '%treino%'
GROUP BY wv.id, wv.title, wv.has_pdf_materials
ORDER BY wv.title; 