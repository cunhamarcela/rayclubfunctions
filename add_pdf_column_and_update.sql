-- =================================================================
-- SCRIPT COMPLETO: ADICIONAR COLUNA E ATUALIZAR PDFs
-- Execute este script no SQL Editor do Supabase
-- =================================================================

-- PASSO 1: Adicionar a coluna has_pdf_materials à tabela workout_videos
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS has_pdf_materials BOOLEAN DEFAULT false;

-- PASSO 2: Atualizar os vídeos que têm materiais PDF associados
UPDATE workout_videos 
SET has_pdf_materials = true
WHERE id IN (
    -- Buscar IDs dos vídeos que têm materiais na tabela materials
    SELECT DISTINCT workout_video_id 
    FROM materials 
    WHERE workout_video_id IS NOT NULL
);

-- PASSO 3: Verificar se tudo funcionou corretamente
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

-- PASSO 4: Mostrar estatísticas finais
SELECT 
    'Total de vídeos' as tipo,
    COUNT(*) as quantidade
FROM workout_videos
WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'

UNION ALL

SELECT 
    'Vídeos com PDF' as tipo,
    COUNT(*) as quantidade
FROM workout_videos
WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'
AND has_pdf_materials = true; 