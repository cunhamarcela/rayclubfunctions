-- ================================================================
-- DIAGNÓSTICO COMPLETO: STATUS DAS IMAGENS DAS RECEITAS
-- Data: 2025-01-21 21:45
-- Objetivo: Verificar situação atual e identificar problemas
-- ================================================================

-- 1. ESTATÍSTICAS GERAIS
SELECT 
    '📊 ESTATÍSTICAS GERAIS' as categoria,
    COUNT(*) as total_receitas,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as sem_imagem,
    ROUND(
        (COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*)), 
        2
    ) as percentual_com_imagem
FROM recipes;

-- 2. RECEITAS SEM IMAGEM
SELECT 
    '❌ RECEITAS SEM IMAGEM' as categoria,
    COUNT(*) as quantidade
FROM recipes 
WHERE image_url IS NULL OR image_url = '';

-- 3. LISTAR RECEITAS SEM IMAGEM (primeiras 10)
SELECT 
    '📋 LISTA SEM IMAGEM' as categoria,
    title,
    description,
    category,
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    SPLIT_PART(title, ' ', 2) as segunda_palavra
FROM recipes 
WHERE image_url IS NULL OR image_url = ''
ORDER BY created_at DESC
LIMIT 10;

-- 4. ANÁLISE DE PRIMEIRAS PALAVRAS SEM IMAGEM
SELECT 
    '🔍 PALAVRAS SEM COBERTURA' as categoria,
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    COUNT(*) as quantidade_receitas
FROM recipes 
WHERE image_url IS NULL OR image_url = ''
GROUP BY SPLIT_PART(title, ' ', 1)
ORDER BY quantidade_receitas DESC;

-- 5. VERIFICAR URLS INVÁLIDAS OU QUEBRADAS
SELECT 
    '⚠️ URLS SUSPEITAS' as categoria,
    title,
    image_url
FROM recipes 
WHERE image_url IS NOT NULL 
  AND image_url != ''
  AND (
    LENGTH(image_url) < 20 OR  -- URLs muito curtas
    image_url NOT LIKE 'https://%' OR  -- Não HTTPS
    image_url LIKE '%error%' OR  -- URLs com erro
    image_url LIKE '%404%'  -- URLs 404
  )
LIMIT 10;

-- 6. RECEITAS COM MESMA IMAGEM (possível problema de genericidade)
SELECT 
    '🔄 IMAGENS DUPLICADAS' as categoria,
    image_url,
    COUNT(*) as receitas_usando,
    string_agg(title, ' | ') as receitas
FROM recipes 
WHERE image_url IS NOT NULL AND image_url != ''
GROUP BY image_url
HAVING COUNT(*) > 3  -- Mesma imagem usada em mais de 3 receitas
ORDER BY receitas_usando DESC;

-- 7. CATEGORIAS DE RECEITAS E SUAS COBERTURAS
SELECT 
    '📂 COBERTURA POR CATEGORIA' as categoria,
    category,
    COUNT(*) as total,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem,
    ROUND(
        (COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*)), 
        2
    ) as percentual_cobertura
FROM recipes
GROUP BY category
ORDER BY percentual_cobertura ASC;

-- 8. RECEITAS MAIS POPULARES SEM IMAGEM (por rating)
SELECT 
    '⭐ POPULARES SEM IMAGEM' as categoria,
    title,
    rating,
    category,
    description
FROM recipes 
WHERE (image_url IS NULL OR image_url = '')
  AND rating >= 4.0
ORDER BY rating DESC
LIMIT 5; 