-- ================================================================
-- TESTE PREVIEW: ANÁLISE DAS DUPLICATAS (SOMENTE LEITURA)
-- Data: 2025-01-21 22:20
-- Objetivo: Ver o que será removido SEM fazer alterações
-- ================================================================

-- 🎯 ANÁLISE SEGURA (NÃO MODIFICA NADA):

-- 1. Quantas receitas temos atualmente?
SELECT 
    '📊 SITUAÇÃO ATUAL' as categoria,
    COUNT(*) as total_receitas,
    COUNT(DISTINCT UPPER(TRIM(title))) as titulos_unicos,
    COUNT(*) - COUNT(DISTINCT UPPER(TRIM(title))) as duplicatas_estimadas
FROM recipes;

-- 2. Análise temporal das criações
SELECT 
    '⏰ ANÁLISE POR HORÁRIO' as categoria,
    DATE_TRUNC('minute', created_at) as minuto_criacao,
    COUNT(*) as receitas_criadas,
    MIN(created_at) as primeira_criacao,
    MAX(created_at) as ultima_criacao
FROM recipes
WHERE DATE(created_at) = '2025-05-29'
GROUP BY DATE_TRUNC('minute', created_at)
ORDER BY minuto_criacao;

-- 3. Exemplos específicos de duplicatas
SELECT 
    '🔍 EXEMPLOS DE DUPLICATAS' as categoria,
    title,
    created_at,
    id,
    ROW_NUMBER() OVER (PARTITION BY UPPER(TRIM(title)) ORDER BY created_at ASC) as ordem_criacao
FROM recipes
WHERE UPPER(TRIM(title)) IN (
    SELECT UPPER(TRIM(title))
    FROM recipes
    GROUP BY UPPER(TRIM(title))
    HAVING COUNT(*) > 1
)
ORDER BY UPPER(TRIM(title)), created_at
LIMIT 20;

-- 4. Simulação do que seria mantido (versões mais antigas)
WITH receitas_manter AS (
    SELECT DISTINCT ON (UPPER(TRIM(title)), TRIM(description)) 
        id,
        title,
        description,
        created_at
    FROM recipes
    ORDER BY UPPER(TRIM(title)), TRIM(description), created_at ASC
)
SELECT 
    '🎯 SIMULAÇÃO RESULTADO FINAL' as categoria,
    (SELECT COUNT(*) FROM recipes) as total_antes,
    COUNT(*) as total_depois,
    (SELECT COUNT(*) FROM recipes) - COUNT(*) as total_removidas
FROM receitas_manter;

-- 5. Preview de receitas que SERIAM removidas
WITH receitas_manter AS (
    SELECT DISTINCT ON (UPPER(TRIM(title)), TRIM(description)) 
        id
    FROM recipes
    ORDER BY UPPER(TRIM(title)), TRIM(description), created_at ASC
)
SELECT 
    '🗑️ PREVIEW: SERIAM REMOVIDAS' as categoria,
    r.title,
    r.created_at,
    SUBSTRING(r.id::text, 1, 8) as id_parcial
FROM recipes r
WHERE r.id NOT IN (SELECT id FROM receitas_manter)
ORDER BY r.title, r.created_at
LIMIT 15;

-- 6. Verificação de segurança
SELECT 
    '⚠️ VERIFICAÇÃO DE SEGURANÇA' as categoria,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM recipes 
            WHERE title IS NULL OR title = '' OR description IS NULL
        ) THEN '🚨 HÁ DADOS NULOS - REVISAR!'
        ELSE '✅ Dados parecem consistentes'
    END as status_dados;

-- ================================================================
-- 📋 PRÓXIMOS PASSOS:
-- 1. Analise os resultados acima
-- 2. Se estiver tudo OK, execute: sql/limpeza_duplicatas_confirmada.sql
-- 3. Descomente as linhas de DELETE apenas se o preview estiver correto
-- ================================================================ 