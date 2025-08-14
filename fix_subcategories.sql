-- ========================================
-- CORREÇÃO DAS SUBCATEGORIAS DE FISIOTERAPIA
-- Data: 2025-01-21 13:41
-- Objetivo: Mover vídeos para as subcategorias corretas
-- ========================================

-- 1. PRIMEIRO: Verificar situação atual
SELECT 
    '🔍 SITUAÇÃO ATUAL:' as status,
    '' as descricao;

SELECT 
    subcategory,
    COUNT(*) as total_videos,
    STRING_AGG(title, ', ' ORDER BY title) as titulos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategory;

-- 2. IDENTIFICAR VÍDEOS QUE ESTÃO NA SUBCATEGORIA ERRADA
SELECT 
    '🚨 VÍDEOS QUE PRECISAM SER MOVIDOS:' as status,
    '' as descricao;

-- Vídeos de mobilidade na subcategoria errada
SELECT 
    'MOBILIDADE → ' || subcategory as problema,
    title,
    subcategory as categoria_atual,
    'mobilidade' as categoria_correta
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND LOWER(title) LIKE '%mobilidade%'
  AND subcategory != 'mobilidade';

-- Vídeos de teste na subcategoria errada  
SELECT 
    'TESTE → ' || subcategory as problema,
    title,
    subcategory as categoria_atual,
    'testes' as categoria_correta
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND LOWER(title) LIKE '%teste%'
  AND subcategory != 'testes';

-- 3. FAZER AS CORREÇÕES
SELECT 
    '🔧 INICIANDO CORREÇÕES...' as status,
    '' as descricao;

-- Corrigir vídeos de MOBILIDADE que estão em subcategoria errada
UPDATE workout_videos 
SET subcategory = 'mobilidade',
    updated_at = NOW()
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND LOWER(title) LIKE '%mobilidade%'
  AND subcategory != 'mobilidade';

-- Corrigir vídeos de TESTE que estão em subcategoria errada
UPDATE workout_videos 
SET subcategory = 'testes',
    updated_at = NOW()
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND LOWER(title) LIKE '%teste%'
  AND subcategory != 'testes';

-- 4. VERIFICAR RESULTADO FINAL
SELECT 
    '✅ SITUAÇÃO APÓS CORREÇÕES:' as status,
    '' as descricao;

SELECT 
    subcategory,
    COUNT(*) as total_videos,
    STRING_AGG(title, ', ' ORDER BY title) as titulos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategory;

-- 5. RESUMO DAS ALTERAÇÕES
SELECT 
    '📊 RESUMO:' as status,
    CONCAT(
        'Vídeos de mobilidade movidos: ', 
        (SELECT COUNT(*) FROM workout_videos 
         WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' 
         AND LOWER(title) LIKE '%mobilidade%' 
         AND subcategory = 'mobilidade'),
        ' | Vídeos de teste movidos: ',
        (SELECT COUNT(*) FROM workout_videos 
         WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' 
         AND LOWER(title) LIKE '%teste%' 
         AND subcategory = 'testes')
    ) as descricao; 