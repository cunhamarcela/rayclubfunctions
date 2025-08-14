-- =====================================================
-- SCRIPT: ORGANIZAR ORDER_INDEX DOS VÍDEOS DE MUSCULAÇÃO
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Definir order_index específica para vídeos de musculação
-- Ordem: Apresentação(1), Treino A(2), B(3), C(4), D(5), E(6), F(7), G(8), Treino A-Semana 2(9)...
-- =====================================================

-- 1. VERIFICAR VÍDEOS DE MUSCULAÇÃO ATUAIS
SELECT 
  'VÍDEOS MUSCULAÇÃO ANTES:' as info,
  id,
  title,
  instructor_name,
  order_index,
  CASE 
    WHEN LOWER(title) LIKE '%apresenta%' THEN 'Apresentação'
    WHEN LOWER(title) LIKE '%treino a%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino A'
    WHEN LOWER(title) LIKE '%treino b%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino B'
    WHEN LOWER(title) LIKE '%treino c%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino C'
    WHEN LOWER(title) LIKE '%treino d%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino D'
    WHEN LOWER(title) LIKE '%treino e%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino E'
    WHEN LOWER(title) LIKE '%treino f%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino F'
    WHEN LOWER(title) LIKE '%treino g%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino G'
    WHEN LOWER(title) LIKE '%treino a%' AND LOWER(title) LIKE '%semana 2%' THEN 'Treino A - Semana 2'
    WHEN LOWER(title) LIKE '%treino b%' AND LOWER(title) LIKE '%semana 2%' THEN 'Treino B - Semana 2'
    WHEN LOWER(title) LIKE '%treino a%' AND LOWER(title) LIKE '%semana 3%' THEN 'Treino A - Semana 3'
    WHEN LOWER(title) LIKE '%treino d%' AND LOWER(title) LIKE '%semana 3%' THEN 'Treino D - Semana 3'
    ELSE 'Outro'
  END as categoria_video
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
ORDER BY order_index, title;

-- 2. BACKUP DOS VALORES ATUAIS
CREATE TABLE IF NOT EXISTS backup_order_index_musculacao AS
SELECT 
  id,
  title,
  order_index as old_order_index,
  NOW() as backup_created_at,
  'Backup antes de reorganizar order_index musculação' as reason
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%');

-- 3. ATUALIZAR ORDER_INDEX DOS VÍDEOS DE MUSCULAÇÃO
UPDATE workout_videos 
SET 
  order_index = CASE 
    -- 1. Apresentação
    WHEN LOWER(title) LIKE '%apresenta%' THEN 1
    
    -- 2-8. Treinos principais A-G
    WHEN LOWER(title) LIKE '%treino a%' AND NOT LOWER(title) LIKE '%semana%' THEN 2
    WHEN LOWER(title) LIKE '%treino b%' AND NOT LOWER(title) LIKE '%semana%' THEN 3
    WHEN LOWER(title) LIKE '%treino c%' AND NOT LOWER(title) LIKE '%semana%' THEN 4
    WHEN LOWER(title) LIKE '%treino d%' AND NOT LOWER(title) LIKE '%semana%' THEN 5
    WHEN LOWER(title) LIKE '%treino e%' AND NOT LOWER(title) LIKE '%semana%' THEN 6
    WHEN LOWER(title) LIKE '%treino f%' AND NOT LOWER(title) LIKE '%semana%' THEN 7
    WHEN LOWER(title) LIKE '%treino g%' AND NOT LOWER(title) LIKE '%semana%' THEN 8
    
    -- 9-10. Treinos Semana 2
    WHEN LOWER(title) LIKE '%treino a%' AND LOWER(title) LIKE '%semana 2%' THEN 9
    WHEN LOWER(title) LIKE '%treino b%' AND LOWER(title) LIKE '%semana 2%' THEN 10
    
    -- 11-12. Treinos Semana 3
    WHEN LOWER(title) LIKE '%treino a%' AND LOWER(title) LIKE '%semana 3%' THEN 11
    WHEN LOWER(title) LIKE '%treino d%' AND LOWER(title) LIKE '%semana 3%' THEN 12
    
    -- 13+. Outros treinos por semana (se houver)
    WHEN LOWER(title) LIKE '%treino%' AND LOWER(title) LIKE '%semana 4%' THEN 13
    WHEN LOWER(title) LIKE '%treino%' AND LOWER(title) LIKE '%semana 5%' THEN 14
    WHEN LOWER(title) LIKE '%treino%' AND LOWER(title) LIKE '%semana 6%' THEN 15
    
    -- Fallback: manter order_index atual se não se encaixar em nenhuma categoria
    ELSE order_index
  END,
  updated_at = NOW()
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%');

-- 4. VERIFICAR RESULTADO APÓS ATUALIZAÇÃO
SELECT 
  'VÍDEOS MUSCULAÇÃO DEPOIS:' as info,
  id,
  title,
  instructor_name,
  order_index,
  CASE 
    WHEN LOWER(title) LIKE '%apresenta%' THEN 'Apresentação'
    WHEN LOWER(title) LIKE '%treino a%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino A'
    WHEN LOWER(title) LIKE '%treino b%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino B'
    WHEN LOWER(title) LIKE '%treino c%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino C'
    WHEN LOWER(title) LIKE '%treino d%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino D'
    WHEN LOWER(title) LIKE '%treino e%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino E'
    WHEN LOWER(title) LIKE '%treino f%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino F'
    WHEN LOWER(title) LIKE '%treino g%' AND NOT LOWER(title) LIKE '%semana%' THEN 'Treino G'
    WHEN LOWER(title) LIKE '%treino a%' AND LOWER(title) LIKE '%semana 2%' THEN 'Treino A - Semana 2'
    WHEN LOWER(title) LIKE '%treino b%' AND LOWER(title) LIKE '%semana 2%' THEN 'Treino B - Semana 2'
    WHEN LOWER(title) LIKE '%treino a%' AND LOWER(title) LIKE '%semana 3%' THEN 'Treino A - Semana 3'
    WHEN LOWER(title) LIKE '%treino d%' AND LOWER(title) LIKE '%semana 3%' THEN 'Treino D - Semana 3'
    ELSE 'Outro'
  END as categoria_video
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
ORDER BY order_index;

-- 5. RESUMO DAS ALTERAÇÕES
SELECT 
  'RESUMO DAS ALTERAÇÕES:' as info,
  COUNT(*) as total_videos_atualizados,
  MIN(order_index) as menor_index,
  MAX(order_index) as maior_index
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%');

-- 6. VERIFICAR SE A ORDEM ESTÁ CORRETA
SELECT 
  'VERIFICAÇÃO FINAL DA ORDEM:' as info,
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
    ELSE '📋 Outro'
  END as status_posicao
FROM workout_videos 
WHERE (category = '495f6111-00f1-4484-974f-5213a5a44ed8' OR category = 'Musculação')
  AND (instructor_name = 'Treinos de Musculação' OR LOWER(instructor_name) LIKE '%musculação%')
ORDER BY order_index;

-- Mensagem de sucesso
SELECT '✅ Order_index dos vídeos de musculação reorganizada com sucesso!' as resultado; 