-- =====================================================
-- SCRIPT: CORRIGIR PDF DO TREINO G (VERSÃO FINAL)
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Verificar e adicionar PDF ao Treino G - versão final corrigida
-- =====================================================

-- 1. VERIFICAR STATUS ATUAL DO TREINO G
SELECT 
  'STATUS TREINO G ATUAL:' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  wv.instructor_name,
  wv.category,
  wv.created_at,
  (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF - PRECISA CORREÇÃO' 
  END as status_pdf
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino g%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND NOT LOWER(wv.title) LIKE '%semana%';

-- 2. VERIFICAR SE JÁ EXISTE MATERIAL PDF PARA TREINO G
SELECT 
  'MATERIAIS PDF TREINO G EXISTENTES:' as info,
  m.id,
  m.title,
  m.file_path,
  m.video_id,
  wv.title as video_title
FROM materials m
LEFT JOIN workout_videos wv ON m.video_id::text = wv.id::text
WHERE m.material_type = 'pdf' 
  AND (m.file_path LIKE '%TREINO G%' OR LOWER(m.title) LIKE '%treino g%');

-- 3. INSERIR PDF PARA TREINO G SE NÃO EXISTIR
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    video_id,
    order_index,
    is_featured,
    requires_expert_access,
    created_at,
    updated_at
)
SELECT 
    'Manual Treino G - PDF',
    'Material de apoio completo para o Treino G de musculação - programa completo de desenvolvimento muscular.',
    'pdf',
    'workout',
    'musculacao/TREINO G.pdf',
    'Treinos de Musculação',
    wv.id::uuid,
    1,
    true,
    false,
    NOW(),
    NOW()
FROM workout_videos wv
WHERE LOWER(wv.title) LIKE '%treino g%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND NOT LOWER(wv.title) LIKE '%semana%'
  AND NOT EXISTS (
    SELECT 1 FROM materials m 
    WHERE m.video_id::text = wv.id::text 
    AND m.material_type = 'pdf'
  )
LIMIT 1;

-- 4. VERIFICAR SE O PDF FOI INSERIDO
SELECT 
  'VERIFICAÇÃO PÓS-INSERÇÃO:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM materials m
      JOIN workout_videos wv ON m.video_id::text = wv.id::text
      WHERE LOWER(wv.title) LIKE '%treino g%'
        AND m.material_type = 'pdf'
        AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
    ) 
    THEN '✅ PDF INSERIDO COM SUCESSO' 
    ELSE '❌ PDF NÃO FOI INSERIDO - VERIFICAR VÍDEO' 
  END as status_insercao;

-- 5. VERIFICAR STATUS FINAL DO TREINO G
SELECT 
  'STATUS FINAL TREINO G:' as info,
  wv.id,
  wv.title,
  wv.youtube_url,
  (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') as pdf_count,
  CASE 
    WHEN (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') > 0 THEN '✅ TEM PDF' 
    ELSE '❌ SEM PDF' 
  END as status_pdf,
  (SELECT m.file_path FROM materials m WHERE m.video_id::text = wv.id::text AND m.material_type = 'pdf' LIMIT 1) as pdf_path
FROM workout_videos wv 
WHERE LOWER(wv.title) LIKE '%treino g%'
  AND (wv.category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR wv.category = 'Musculação')
  AND NOT LOWER(wv.title) LIKE '%semana%';

-- 6. VERIFICAR TODOS OS TREINOS A-G APÓS CORREÇÃO
SELECT 
  'RESUMO TREINOS A-G APÓS CORREÇÃO:' as info,
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

-- 7. VERIFICAR SE TODOS OS TREINOS A-G TÊM PDF
SELECT 
  'VERIFICAÇÃO FINAL A-G:' as info,
  COUNT(*) as total_treinos,
  COUNT(*) FILTER (WHERE (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') > 0) as com_pdf,
  COUNT(*) FILTER (WHERE (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') = 0) as sem_pdf,
  CASE 
    WHEN COUNT(*) FILTER (WHERE (SELECT COUNT(*) FROM materials WHERE video_id::text = wv.id::text AND material_type = 'pdf') = 0) = 0 
    THEN '✅ TODOS OS TREINOS TÊM PDF' 
    ELSE '⚠️ AINDA HÁ TREINOS SEM PDF' 
  END as status_geral
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

-- Mensagem de sucesso
SELECT '✅ Correção do PDF do Treino G concluída!' as resultado; 