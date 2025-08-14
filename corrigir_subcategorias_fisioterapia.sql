-- 🔍 VERIFICAR SITUAÇÃO ATUAL
SELECT 
    title,
    subcategory as categoria_atual,
    CASE 
        WHEN LOWER(title) LIKE '%mobilidade%' THEN 'mobilidade'
        WHEN LOWER(title) LIKE '%teste%' THEN 'testes'
        ELSE subcategory
    END as categoria_correta
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (LOWER(title) LIKE '%mobilidade%' OR LOWER(title) LIKE '%teste%')
ORDER BY title;

-- 🔧 CORRIGIR VÍDEOS DE MOBILIDADE
UPDATE workout_videos 
SET subcategory = 'mobilidade'
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND LOWER(title) LIKE '%mobilidade%'
  AND subcategory != 'mobilidade';

-- 🔧 CORRIGIR VÍDEOS DE TESTE  
UPDATE workout_videos 
SET subcategory = 'testes'
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND LOWER(title) LIKE '%teste%'
  AND subcategory != 'testes';

-- ✅ VERIFICAR RESULTADO
SELECT 
    title,
    subcategory,
    '✅ Corrigido' as status
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (LOWER(title) LIKE '%mobilidade%' OR LOWER(title) LIKE '%teste%')
ORDER BY subcategory, title; 