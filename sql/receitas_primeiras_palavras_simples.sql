-- ================================================================
-- LISTAGEM SIMPLES: 74 RECEITAS - FOCO PRIMEIRAS PALAVRAS
-- Data: 2025-01-21 20:50
-- Objetivo: Lista direta e clara das receitas organizadas por primeiras palavras
-- ================================================================

-- 🔤 LISTA ORDENADA POR PRIMEIRAS PALAVRAS
-- ================================================================
SELECT 
    ROW_NUMBER() OVER (ORDER BY SPLIT_PART(title, ' ', 1), title) as "#",
    SPLIT_PART(title, ' ', 1) as "1ª Palavra",
    SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2) as "2 Primeiras Palavras",
    title as "Título Completo",
    category as "Categoria",
    author_name as "Autor",
    
    -- Indicadores visuais
    CASE WHEN is_featured THEN '⭐' ELSE '' END as "Destaque",
    CASE WHEN content_type = 'video' THEN '🎬' ELSE '📝' END as "Tipo",
    
    preparation_time_minutes || ' min' as "Tempo",
    calories || ' cal' as "Calorias"
    
FROM recipes 
ORDER BY SPLIT_PART(title, ' ', 1), title;

-- ================================================================
-- 📊 RANKING DAS PRIMEIRAS PALAVRAS MAIS USADAS
-- ================================================================
SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as "Posição",
    SPLIT_PART(title, ' ', 1) as "Primeira Palavra",
    COUNT(*) as "Quantidade",
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM recipes)), 1) || '%' as "% do Total",
    
    -- Lista de receitas com essa primeira palavra
    string_agg(
        CASE 
            WHEN LENGTH(title) > 35 THEN LEFT(title, 32) || '...'
            ELSE title 
        END, 
        ' • ' 
        ORDER BY title
    ) as "Receitas"
    
FROM recipes 
GROUP BY SPLIT_PART(title, ' ', 1)
ORDER BY COUNT(*) DESC, SPLIT_PART(title, ' ', 1);

-- ================================================================
-- 🎯 BUSCA RÁPIDA POR PRIMEIRA PALAVRA (ALFABÉTICA)
-- ================================================================
SELECT 
    SPLIT_PART(title, ' ', 1) as "Primeira Palavra",
    COUNT(*) as "Qtd",
    string_agg(title, ' | ' ORDER BY title) as "Receitas Completas"
FROM recipes 
GROUP BY SPLIT_PART(title, ' ', 1)
ORDER BY SPLIT_PART(title, ' ', 1);

-- ================================================================
-- 📈 CONTAGEM FINAL
-- ================================================================
SELECT 
    COUNT(*) as "Total de Receitas",
    COUNT(DISTINCT SPLIT_PART(title, ' ', 1)) as "Primeiras Palavras Únicas",
    ROUND(AVG(preparation_time_minutes), 1) as "Tempo Médio (min)",
    ROUND(AVG(calories)) as "Calorias Médias"
FROM recipes; 