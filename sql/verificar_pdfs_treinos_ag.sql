-- =====================================================
-- SCRIPT: VERIFICAR PDFs DOS TREINOS A-G
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Verificar se todos os treinos A-G têm PDFs corretos
-- Tanto na home quanto na tela de treinos
-- =====================================================

-- 1. VERIFICAR TODOS OS TREINOS A-G E SEUS PDFs
SELECT 
  'STATUS TREINOS A-G:' as info,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
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
  (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf,
  (SELECT STRING_AGG(m.title, ', ') FROM materials m WHERE m.video_id = wv.id AND m.type = 'pdf') as pdf_titles
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

-- 2. VERIFICAR TREINOS SEM PDF (PRECISAM DE CORREÇÃO)
SELECT 
  'TREINOS SEM PDF (PRECISAM CORREÇÃO):' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name
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
  AND (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') = 0;

-- 3. VERIFICAR PDFs ÓRFÃOS (SEM VÍDEO ASSOCIADO)
SELECT 
  'PDFs ÓRFÃOS (SEM VÍDEO):' as info,
  m.id,
  m.title,
  m.file_path,
  m.workout_video_id
FROM materials m 
WHERE m.type = 'pdf'
  AND m.file_path LIKE '%musculacao%'
  AND NOT EXISTS (
    SELECT 1 FROM workout_videos wv 
    WHERE wv.id = m.workout_video_id
  );

-- 4. VERIFICAR PATHS DOS PDFs EXISTENTES
SELECT 
  'PATHS DOS PDFs MUSCULAÇÃO:' as info,
  wv.title as video_title,
  m.title as pdf_title,
  m.file_path,
  CASE 
    WHEN m.file_path LIKE '%TREINO A%' THEN 'A'
    WHEN m.file_path LIKE '%TREINO B%' THEN 'B'
    WHEN m.file_path LIKE '%TREINO C%' THEN 'C'
    WHEN m.file_path LIKE '%TREINO D%' THEN 'D'
    WHEN m.file_path LIKE '%TREINO E%' THEN 'E'
    WHEN m.file_path LIKE '%TREINO F%' THEN 'F'
    WHEN m.file_path LIKE '%TREINO G%' THEN 'G'
    ELSE 'OUTRO'
  END as treino_letra_pdf
FROM materials m 
JOIN workout_videos wv ON m.workout_video_id = wv.id
WHERE m.type = 'pdf'
  AND m.file_path LIKE '%musculacao%'
ORDER BY 
  CASE 
    WHEN m.file_path LIKE '%TREINO A%' THEN 1
    WHEN m.file_path LIKE '%TREINO B%' THEN 2
    WHEN m.file_path LIKE '%TREINO C%' THEN 3
    WHEN m.file_path LIKE '%TREINO D%' THEN 4
    WHEN m.file_path LIKE '%TREINO E%' THEN 5
    WHEN m.file_path LIKE '%TREINO F%' THEN 6
    WHEN m.file_path LIKE '%TREINO G%' THEN 7
    ELSE 8
  END;

-- 5. RESUMO FINAL
SELECT 
  'RESUMO TREINOS A-G:' as info,
  COUNT(*) as total_treinos,
  COUNT(*) FILTER (WHERE (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') > 0) as com_pdf,
  COUNT(*) FILTER (WHERE (SELECT COUNT(*) FROM materials WHERE video_id = wv.id AND type = 'pdf') = 0) as sem_pdf
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
  AND NOT LOWER(wv.title) LIKE '%semana%';

-- 6. VERIFICAR SE HÁ DUPLICATAS EM QUALQUER TREINO
SELECT 
  'DUPLICATAS POR TREINO:' as info,
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
  COUNT(*) as total_videos,
  CASE 
    WHEN COUNT(*) > 1 THEN '⚠️ DUPLICADO'
    ELSE '✅ ÚNICO'
  END as status
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
GROUP BY 
  CASE 
    WHEN LOWER(wv.title) LIKE '%treino a%' THEN 'A'
    WHEN LOWER(wv.title) LIKE '%treino b%' THEN 'B'
    WHEN LOWER(wv.title) LIKE '%treino c%' THEN 'C'
    WHEN LOWER(wv.title) LIKE '%treino d%' THEN 'D'
    WHEN LOWER(wv.title) LIKE '%treino e%' THEN 'E'
    WHEN LOWER(wv.title) LIKE '%treino f%' THEN 'F'
    WHEN LOWER(wv.title) LIKE '%treino g%' THEN 'G'
    ELSE 'OUTRO'
  END
ORDER BY treino_letra; 