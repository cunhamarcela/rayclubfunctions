-- =====================================================
-- SCRIPT: REMOVER VÍDEO DUPLICADO DO TREINO E
-- =====================================================
-- Data: 2025-01-21
-- ID do vídeo: 984a1c75-6427-4c52-bb1e-77deeea310f1
-- Objetivo: Remover vídeo duplicado específico do Treino E
-- =====================================================

-- 1. VERIFICAR O VÍDEO ANTES DE REMOVER
SELECT 
  'VÍDEO A SER REMOVIDO:' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
  wv.category,
  wv.created_at,
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf
FROM workout_videos wv 
WHERE wv.id = '984a1c75-6427-4c52-bb1e-77deeea310f1';

-- 2. VERIFICAR SE EXISTE OUTROS VÍDEOS DE TREINO E
SELECT 
  'OUTROS VÍDEOS TREINO E:' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND wv.id != '984a1c75-6427-4c52-bb1e-77deeea310f1'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação');

-- 3. FAZER BACKUP DO VÍDEO QUE SERÁ REMOVIDO
CREATE TABLE IF NOT EXISTS backup_video_removido_treino_e AS 
SELECT 
  wv.*,
  NOW() as backup_created_at,
  'Vídeo duplicado Treino E - ID específico removido em 2025-01-21' as reason
FROM workout_videos wv 
WHERE wv.id = '984a1c75-6427-4c52-bb1e-77deeea310f1';

-- 4. FAZER BACKUP DOS MATERIAIS ASSOCIADOS (SE HOUVER)
CREATE TABLE IF NOT EXISTS backup_materials_video_removido_treino_e AS
SELECT 
  m.*,
  NOW() as backup_created_at,
  'Materiais do vídeo duplicado Treino E removido em 2025-01-21' as reason
FROM materials m
WHERE m.video_id = '984a1c75-6427-4c52-bb1e-77deeea310f1';

-- 5. VERIFICAR SE O BACKUP FOI CRIADO
SELECT 
  'BACKUP CRIADO:' as info,
  COUNT(*) as videos_backup,
  (SELECT COUNT(*) FROM backup_materials_video_removido_treino_e) as materials_backup
FROM backup_video_removido_treino_e;

-- 6. REMOVER MATERIAIS ASSOCIADOS PRIMEIRO (SE HOUVER)
DELETE FROM materials 
WHERE video_id = '984a1c75-6427-4c52-bb1e-77deeea310f1';

-- 7. REMOVER O VÍDEO
DELETE FROM workout_videos 
WHERE id = '984a1c75-6427-4c52-bb1e-77deeea310f1';

-- 8. VERIFICAR SE FOI REMOVIDO
SELECT 
  'VERIFICAÇÃO PÓS-REMOÇÃO:' as info,
  CASE 
    WHEN EXISTS (SELECT 1 FROM workout_videos WHERE id = '984a1c75-6427-4c52-bb1e-77deeea310f1') 
    THEN '❌ VÍDEO AINDA EXISTE' 
    ELSE '✅ VÍDEO REMOVIDO COM SUCESSO' 
  END as status_remocao;

-- 9. VERIFICAR TREINOS E RESTANTES
SELECT 
  'TREINOS E RESTANTES:' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf,
  wv.created_at
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
ORDER BY wv.created_at;

-- 10. ATUALIZAR CONTADOR DA CATEGORIA MUSCULAÇÃO
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'
)
WHERE id = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- 11. VERIFICAR RESULTADO FINAL
SELECT 
  'RESULTADO FINAL:' as info,
  COUNT(*) as total_treinos_e_restantes
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino e%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação');

-- Mensagem de sucesso
SELECT '✅ Vídeo duplicado do Treino E removido com sucesso! ID: 984a1c75-6427-4c52-bb1e-77deeea310f1' as resultado; 