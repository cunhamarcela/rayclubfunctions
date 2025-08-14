-- =====================================================
-- SCRIPT: CORRIGIR DUPLICATAS DO TREINO E
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Remover vídeos de "Treino E" duplicados que não têm PDF
-- Manter apenas os vídeos que têm PDFs associados
-- =====================================================

-- 1. IDENTIFICAR TODOS OS VÍDEOS DE TREINO E
SELECT 
  'VÍDEOS TREINO E ENCONTRADOS:' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
  wv.category,
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf,
  wv.created_at
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
ORDER BY 
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') DESC,
  wv.created_at;

-- 2. BACKUP DOS VÍDEOS QUE SERÃO REMOVIDOS
CREATE TABLE IF NOT EXISTS backup_treino_e_removed AS 
SELECT 
  wv.*,
  NOW() as backup_created_at,
  'Duplicata sem PDF - removida em 2025-01-21' as reason
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') = 0;

-- 3. MOSTRAR VÍDEOS QUE SERÃO REMOVIDOS
SELECT 
  'VÍDEOS QUE SERÃO REMOVIDOS (SEM PDF):' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
  wv.created_at
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') = 0;

-- 4. MOSTRAR VÍDEOS QUE SERÃO MANTIDOS
SELECT 
  'VÍDEOS QUE SERÃO MANTIDOS (COM PDF):' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  wv.created_at
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0;

-- 5. REMOVER DUPLICATAS SEM PDF
DELETE FROM workout_videos 
WHERE id IN (
  SELECT wv.id
  FROM workout_videos wv 
  WHERE LOWER(wv.title) LIKE '%treino e%'
    AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
    AND (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') = 0
);

-- 6. VERIFICAR TODOS OS TREINOS A-G APÓS A LIMPEZA
SELECT 
  'TREINOS A-G FINAIS:' as info,
  wv.title,
  wv.youtube_url,
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf
FROM workout_videos wv 
WHERE (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND (
    LOWER(wv.title) LIKE '%treino a%' OR
    LOWER(wv.title) LIKE '%treino b%' OR
    LOWER(wv.title) LIKE '%treino c%' OR
    LOWER(wv.title) LIKE '%treino d%' OR
    LOWER(wv.title) LIKE '%treino e%' OR
    LOWER(wv.title) LIKE '%treino f%' OR
    LOWER(wv.title) LIKE '%treino g%'
  )
  AND NOT LOWER(wv.title) LIKE '%semana%'
ORDER BY 
  CASE 
    WHEN LOWER(wv.title) LIKE '%treino a%' THEN 1
    WHEN LOWER(wv.title) LIKE '%treino b%' THEN 2
    WHEN LOWER(wv.title) LIKE '%treino c%' THEN 3
    WHEN LOWER(wv.title) LIKE '%treino d%' THEN 4
    WHEN LOWER(wv.title) LIKE '%treino e%' THEN 5
    WHEN LOWER(wv.title) LIKE '%treino f%' THEN 6
    WHEN LOWER(wv.title) LIKE '%treino g%' THEN 7
    ELSE 8
  END;

-- 7. ATUALIZAR CONTADOR DA CATEGORIA MUSCULAÇÃO
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'
)
WHERE id = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- 8. VERIFICAR RESULTADO FINAL
SELECT 
  COUNT(*) as total_videos_treino_e_remaining
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação');

-- Mensagem de sucesso
SELECT '✅ Duplicatas do Treino E removidas com sucesso! Mantidos apenas os vídeos com PDF.' as resultado; 