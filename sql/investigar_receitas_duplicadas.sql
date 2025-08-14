-- ================================================================
-- INVESTIGAÇÃO: RECEITAS DUPLICADAS
-- Data: 2025-01-21 21:55
-- Objetivo: Identificar receitas duplicadas e analisar crescimento de 74 para 144
-- ================================================================

-- 1. VERIFICAR TOTAL ATUAL
SELECT 
    '📊 CONTAGEM ATUAL' as categoria,
    COUNT(*) as total_receitas_atual
FROM recipes;

-- 2. IDENTIFICAR DUPLICATAS POR TÍTULO EXATO
SELECT 
    '🔍 DUPLICATAS POR TÍTULO' as categoria,
    title,
    COUNT(*) as quantidade_duplicatas,
    string_agg(id::text, ' | ') as ids_duplicados
FROM recipes
GROUP BY title
HAVING COUNT(*) > 1
ORDER BY quantidade_duplicatas DESC;

-- 3. VERIFICAR DUPLICATAS POR TÍTULO SIMILAR (ignorando case)
SELECT 
    '🔍 DUPLICATAS SIMILAR (CASE)' as categoria,
    UPPER(title) as titulo_normalizado,
    COUNT(*) as quantidade,
    string_agg(title, ' | ') as titulos_variantes
FROM recipes
GROUP BY UPPER(title)
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 4. DUPLICATAS POR CONTEÚDO SIMILAR (título + descrição)
SELECT 
    '🔍 DUPLICATAS POR CONTEÚDO' as categoria,
    title,
    description,
    COUNT(*) as quantidade,
    string_agg(id::text, ' | ') as ids
FROM recipes
GROUP BY title, description
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 5. VERIFICAR DUPLICATAS POR INGREDIENTES (se existir)
SELECT 
    '🔍 DUPLICATAS POR INGREDIENTES' as categoria,
    title,
    ingredients,
    COUNT(*) as quantidade
FROM recipes
WHERE ingredients IS NOT NULL
GROUP BY title, ingredients
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 6. ANÁLISE DE DATAS DE CRIAÇÃO
SELECT 
    '📅 ANÁLISE POR DATA' as categoria,
    DATE(created_at) as data_criacao,
    COUNT(*) as receitas_criadas
FROM recipes
GROUP BY DATE(created_at)
ORDER BY data_criacao DESC
LIMIT 10;

-- 7. VERIFICAR SE HÁ RECEITAS COM IDs DIFERENTES MAS MESMO CONTEÚDO
SELECT 
    '🆔 CONTEÚDO IDÊNTICO, IDs DIFERENTES' as categoria,
    title,
    description,
    array_agg(id) as ids_diferentes,
    array_agg(created_at) as datas_criacao,
    COUNT(*) as quantidade
FROM recipes
GROUP BY title, description, category, calories, preparation_time_minutes
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 8. VERIFICAR RECEITAS COM AUTHOR_TYPE DUPLICADO
SELECT 
    '👤 DUPLICATAS POR AUTOR' as categoria,
    author_name,
    author_type,
    COUNT(*) as total_receitas
FROM recipes
GROUP BY author_name, author_type
ORDER BY total_receitas DESC;

-- 9. IDENTIFICAR RECEITAS POTENCIALMENTE GERADAS/IMPORTADAS EM LOTE
SELECT 
    '📦 POSSÍVEL IMPORTAÇÃO EM LOTE' as categoria,
    DATE(created_at) as data,
    EXTRACT(HOUR FROM created_at) as hora,
    COUNT(*) as receitas_mesmo_horario
FROM recipes
GROUP BY DATE(created_at), EXTRACT(HOUR FROM created_at)
HAVING COUNT(*) > 10  -- Mais de 10 receitas na mesma hora
ORDER BY receitas_mesmo_horario DESC;

-- 10. LISTAR PRIMEIRAS 20 RECEITAS POR DATA DE CRIAÇÃO
SELECT 
    '📋 LISTAGEM CRONOLÓGICA' as categoria,
    ROW_NUMBER() OVER (ORDER BY created_at) as ordem,
    title,
    author_name,
    created_at,
    id
FROM recipes
ORDER BY created_at
LIMIT 20;

-- 11. IDENTIFICAR PADRÕES DE NOMENCLATURA SUSPEITOS
SELECT 
    '🔤 PADRÕES DE NOME SUSPEITOS' as categoria,
    CASE 
        WHEN title ~ '^[A-Z][a-z]+ [0-9]+$' THEN 'Padrão: Nome + Número'
        WHEN title ~ '^Receita [0-9]+' THEN 'Padrão: Receita + Número'
        WHEN title ~ '^[A-Z][a-z]+ de [A-Z][a-z]+$' THEN 'Padrão: X de Y'
        WHEN LENGTH(title) < 10 THEN 'Título muito curto'
        WHEN LENGTH(title) > 100 THEN 'Título muito longo'
        ELSE 'Normal'
    END as padrao_titulo,
    COUNT(*) as quantidade
FROM recipes
GROUP BY 1
ORDER BY quantidade DESC;

-- 12. VERIFICAR SE HÁ RECEITAS ÓRFÃS OU COM DADOS ESTRANHOS
SELECT 
    '⚠️ DADOS SUSPEITOS' as categoria,
    title,
    CASE 
        WHEN title = '' OR title IS NULL THEN 'Título vazio'
        WHEN description = '' OR description IS NULL THEN 'Descrição vazia'
        WHEN calories = 0 OR calories IS NULL THEN 'Calorias zeradas'
        WHEN preparation_time_minutes = 0 OR preparation_time_minutes IS NULL THEN 'Tempo zerado'
        WHEN rating = 0 OR rating IS NULL THEN 'Rating zerado'
        ELSE 'OK'
    END as problema
FROM recipes
WHERE 
    title = '' OR title IS NULL OR
    description = '' OR description IS NULL OR
    calories = 0 OR calories IS NULL OR
    preparation_time_minutes = 0 OR preparation_time_minutes IS NULL OR
    rating = 0 OR rating IS NULL
LIMIT 10; 