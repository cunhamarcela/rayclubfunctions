-- =====================================================
-- SCRIPT: ASSOCIAR PDF DO TREINO G AO VÍDEO
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Associar o PDF existente do Treino G ao vídeo correto
-- PDF ID: 16360b20-7c74-42ec-aa9c-d0e759808153
-- Vídeo ID: 427b5e22-f43f-41be-a6ed-1c0311bf3c02
-- =====================================================

-- 1. VERIFICAR SITUAÇÃO ATUAL
SELECT 
  'SITUAÇÃO ANTES DA CORREÇÃO:' as info,
  'VÍDEO' as tipo,
  wv.id,
  wv.title,
  (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') as pdf_associados
FROM workout_videos wv 
WHERE wv.id = '427b5e22-f43f-41be-a6ed-1c0311bf3c02'

UNION ALL

SELECT 
  'SITUAÇÃO ANTES DA CORREÇÃO:' as info,
  'PDF' as tipo,
  m.id,
  m.title,
  CASE WHEN m.video_id IS NULL THEN 0 ELSE 1 END as tem_video_associado
FROM materials m
WHERE m.id = '16360b20-7c74-42ec-aa9c-d0e759808153';

-- 2. FAZER BACKUP DO MATERIAL ANTES DA ALTERAÇÃO
CREATE TABLE IF NOT EXISTS backup_material_treino_g AS
SELECT 
  m.*,
  NOW() as backup_created_at,
  'Backup antes de associar ao vídeo Treino G' as reason
FROM materials m
WHERE m.id = '16360b20-7c74-42ec-aa9c-d0e759808153';

-- 3. ASSOCIAR O PDF AO VÍDEO DO TREINO G
UPDATE materials 
SET 
  video_id = '427b5e22-f43f-41be-a6ed-1c0311bf3c02'::uuid,
  updated_at = NOW()
WHERE id = '16360b20-7c74-42ec-aa9c-d0e759808153';

-- 4. VERIFICAR SE A ASSOCIAÇÃO FOI FEITA
SELECT 
  'VERIFICAÇÃO PÓS-ASSOCIAÇÃO:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM materials m
      WHERE m.id = '16360b20-7c74-42ec-aa9c-d0e759808153'
      AND m.video_id = '427b5e22-f43f-41be-a6ed-1c0311bf3c02'::uuid
    ) 
    THEN '✅ PDF ASSOCIADO COM SUCESSO AO VÍDEO' 
    ELSE '❌ FALHA NA ASSOCIAÇÃO' 
  END as status_associacao;

-- 5. VERIFICAR STATUS FINAL DO TREINO G
SELECT 
  'STATUS FINAL TREINO G:' as info,
  wv.id as video_id,
  wv.title as video_title,
  (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf,
  (SELECT m.title FROM materials m WHERE m.video_id::text = wv.id::text AND m.material_type = 'pdf' LIMIT 1) as pdf_title,
  (SELECT m.file_path FROM materials m WHERE m.video_id::text = wv.id::text AND m.material_type = 'pdf' LIMIT 1) as pdf_path
FROM workout_videos wv 
WHERE wv.id = '427b5e22-f43f-41be-a6ed-1c0311bf3c02';

-- 6. VERIFICAR DETALHES DO MATERIAL ASSOCIADO
SELECT 
  'DETALHES DO PDF ASSOCIADO:' as info,
  m.id as material_id,
  m.title,
  m.file_path,
  m.video_id,
  wv.title as video_title,
  m.created_at,
  m.updated_at
FROM materials m
JOIN workout_videos wv ON m.video_id::text = wv.id::text
WHERE m.id = '16360b20-7c74-42ec-aa9c-d0e759808153';

-- 7. RESUMO FINAL DE TODOS OS TREINOS A-G
SELECT 
  'RESUMO FINAL A-G:' as info,
  wv.title,
  CASE 
    WHEN LOWER(wv.title) LIKE '%treino a%' THEN 'A'
    WHEN LOWER(wv.title) LIKE '%treino b%' THEN 'B'
    WHEN LOWER(wv.title) LIKE '%treino c%' THEN 'C'
    WHEN LOWER(wv.title) LIKE '%treino d%' THEN 'D'
    WHEN LOWER(wv.title) LIKE '%treino e%' THEN 'E'
    WHEN LOWER(wv.title) LIKE '%treino f%' THEN 'F'
    WHEN LOWER(wv.title) LIKE '%treino g%' THEN 'G'
    ELSE 'OUTRO'
  END as treino_letra,
  (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') > 0 THEN '✅ TEM PDF' 
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

-- Mensagem de sucesso
SELECT '✅ PDF do Treino G associado ao vídeo com sucesso!' as resultado; 