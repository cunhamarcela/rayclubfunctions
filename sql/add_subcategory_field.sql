-- ========================================
-- ADICIONAR SUBCATEGORIAS À FISIOTERAPIA
-- Solução 1: Campo subcategory na tabela existente
-- ========================================

-- 1. Adicionar campo subcategory à tabela workout_videos
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS subcategory VARCHAR(100);

-- 2. Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_workout_videos_subcategory 
ON workout_videos(subcategory);

-- 3. Atualizar vídeos de fisioterapia com subcategorias baseado nos títulos/descrições existentes

-- Subcategoria: Testes
UPDATE workout_videos 
SET subcategory = 'testes'
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%apresentação%' OR
    LOWER(title) LIKE '%teste%' OR
    LOWER(title) LIKE '%avaliação%' OR
    LOWER(description) LIKE '%apresentação%' OR
    LOWER(description) LIKE '%introdução%'
  );

-- Subcategoria: Mobilidade  
UPDATE workout_videos 
SET subcategory = 'mobilidade'
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%mobilidade%' OR
    LOWER(description) LIKE '%mobilidade%' OR
    LOWER(description) LIKE '%amplitude%'
  );

-- Subcategoria: Fortalecimento
UPDATE workout_videos 
SET subcategory = 'fortalecimento'
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%prevenção%' OR
    LOWER(title) LIKE '%lesões%' OR
    LOWER(title) LIKE '%joelho%' OR
    LOWER(title) LIKE '%coluna%' OR
    LOWER(title) LIKE '%fortalecimento%' OR
    LOWER(description) LIKE '%prevenção%' OR
    LOWER(description) LIKE '%fortaleça%'
  );

-- 4. Verificar resultado da classificação
SELECT 
    '=== RESULTADO DA CLASSIFICAÇÃO ===' as info;

SELECT 
    subcategory,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategory;

-- 5. Ver vídeos que não foram classificados (para revisão manual)
SELECT 
    '=== VÍDEOS NÃO CLASSIFICADOS ===' as info;

SELECT 
    title,
    description,
    instructor_name
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory IS NULL;

-- 6. Estatísticas finais
SELECT 
    '=== ESTATÍSTICAS FINAIS ===' as info;

SELECT 
    'Total vídeos fisioterapia:' as metric,
    COUNT(*) as value
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f';

SELECT 
    'Vídeos classificados:' as metric,
    COUNT(*) as value
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
  AND subcategory IS NOT NULL;

SELECT 
    'Vídeos não classificados:' as metric,
    COUNT(*) as value
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
  AND subcategory IS NULL; 