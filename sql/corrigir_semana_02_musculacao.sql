-- =====================================================
-- SCRIPT: CORRIGIR TREINOS "SEMANA 02" DE MUSCULAÇÃO
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Corrigir order_index dos treinos "Semana 02" que não foram detectados
-- =====================================================

-- 1. VERIFICAR TREINOS "SEMANA 02" ATUAIS
SELECT 
  'TREINOS SEMANA 02 ANTES:' as info,
  id,
  title,
  instructor_name,
  order_index,
  CASE 
    WHEN LOWER(title) LIKE '%treino a%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 'Treino A - Semana 2'
    WHEN LOWER(title) LIKE '%treino b%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 'Treino B - Semana 2'
    WHEN LOWER(title) LIKE '%treino d%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 'Treino D - Semana 2'
    ELSE 'Outro Semana 02'
  END as categoria_video
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
  AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%')
ORDER BY order_index, title;

-- 2. BACKUP DOS TREINOS SEMANA 02
CREATE TABLE IF NOT EXISTS backup_semana_02_musculacao AS
SELECT 
  id,
  title,
  order_index as old_order_index,
  NOW() as backup_created_at,
  'Backup antes de corrigir order_index Semana 02' as reason
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
  AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%');

-- 3. CORRIGIR ORDER_INDEX DOS TREINOS SEMANA 02
UPDATE workout_videos 
SET 
  order_index = CASE 
    -- Treino A - Semana 02 → order_index = 9
    WHEN LOWER(title) LIKE '%treino a%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 9
    
    -- Treino B - Semana 02 → order_index = 10
    WHEN LOWER(title) LIKE '%treino b%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 10
    
    -- Treino D - Semana 02 → order_index = 13 (após Treino D - Semana 3 que é 12)
    WHEN LOWER(title) LIKE '%treino d%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 13
    
    -- Fallback: manter order_index atual
    ELSE order_index
  END,
  updated_at = NOW()
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
  AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%');

-- 4. VERIFICAR RESULTADO APÓS CORREÇÃO
SELECT 
  'TREINOS SEMANA 02 DEPOIS:' as info,
  id,
  title,
  instructor_name,
  order_index,
  CASE 
    WHEN LOWER(title) LIKE '%treino a%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 'Treino A - Semana 2'
    WHEN LOWER(title) LIKE '%treino b%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 'Treino B - Semana 2'
    WHEN LOWER(title) LIKE '%treino d%' AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%') THEN 'Treino D - Semana 2'
    ELSE 'Outro Semana 02'
  END as categoria_video
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
  AND (LOWER(title) LIKE '%semana 02%' OR LOWER(title) LIKE '%semana 2%')
ORDER BY order_index;

-- 5. VERIFICAR ORDEM FINAL COMPLETA
SELECT 
  'ORDEM FINAL COMPLETA:' as info,
  order_index,
  title,
  CASE 
    WHEN order_index = 1 THEN '✅ Apresentação'
    WHEN order_index = 2 THEN '✅ Treino A'
    WHEN order_index = 3 THEN '✅ Treino B'
    WHEN order_index = 4 THEN '✅ Treino C'
    WHEN order_index = 5 THEN '✅ Treino D'
    WHEN order_index = 6 THEN '✅ Treino E'
    WHEN order_index = 7 THEN '✅ Treino F'
    WHEN order_index = 8 THEN '✅ Treino G'
    WHEN order_index = 9 THEN '✅ Treino A - Semana 2'
    WHEN order_index = 10 THEN '✅ Treino B - Semana 2'
    WHEN order_index = 11 THEN '✅ Treino A - Semana 3'
    WHEN order_index = 12 THEN '✅ Treino D - Semana 3'
    WHEN order_index = 13 THEN '✅ Treino D - Semana 2'
    ELSE '📋 Outro'
  END as status_posicao
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
ORDER BY order_index;

-- 6. RESUMO FINAL
SELECT 
  'RESUMO FINAL:' as info,
  COUNT(*) as total_videos_musculacao,
  COUNT(*) FILTER (WHERE order_index BETWEEN 1 AND 13) as com_order_index_correto
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%');

-- Mensagem de sucesso
SELECT '✅ Treinos Semana 02 corrigidos! Ordem final organizada.' as resultado; 