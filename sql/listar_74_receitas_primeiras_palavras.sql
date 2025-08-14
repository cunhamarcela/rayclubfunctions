-- ================================================================
-- SCRIPT SQL: LISTAR TODAS AS 74 RECEITAS - FOCO PRIMEIRAS PALAVRAS
-- Data: 2025-01-21 20:45
-- Objetivo: Análise completa das receitas com destaque para primeiras palavras
-- ================================================================

-- 📊 PARTE 1: CONTAGEM TOTAL E VERIFICAÇÃO
-- ================================================================
SELECT 
    '🔢 CONTAGEM TOTAL DE RECEITAS' as secao,
    COUNT(*) as total_receitas,
    COUNT(CASE WHEN is_featured = true THEN 1 END) as receitas_destaque,
    COUNT(CASE WHEN content_type = 'video' THEN 1 END) as receitas_video,
    COUNT(CASE WHEN content_type = 'text' THEN 1 END) as receitas_texto,
    COUNT(CASE WHEN author_type = 'nutritionist' THEN 1 END) as receitas_nutricionista,
    COUNT(CASE WHEN author_type = 'ray' THEN 1 END) as receitas_ray
FROM recipes;

-- ================================================================
-- 📝 PARTE 2: LISTA COMPLETA COM PRIMEIRAS PALAVRAS
-- ================================================================
SELECT 
    '📋 LISTA COMPLETA DAS RECEITAS' as secao,
    'Receita #' || ROW_NUMBER() OVER (ORDER BY title) as numero,
    title as titulo_completo,
    
    -- 🎯 EXTRAÇÃO DAS PRIMEIRAS PALAVRAS (diferentes análises)
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2) as duas_primeiras_palavras,
    CASE 
        WHEN SPLIT_PART(title, ' ', 3) != '' THEN 
            SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2) || ' ' || SPLIT_PART(title, ' ', 3)
        ELSE 
            SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2)
    END as tres_primeiras_palavras,
    
    -- 📊 INFORMAÇÕES ADICIONAIS
    category as categoria,
    author_name as autor,
    author_type as tipo_autor,
    content_type as tipo_conteudo,
    preparation_time_minutes as tempo_preparo_min,
    difficulty as dificuldade,
    calories as calorias,
    servings as porcoes,
    rating as avaliacao,
    is_featured as destaque,
    
    -- 🏷️ TAGS E FILTROS
    CASE 
        WHEN tags IS NOT NULL AND array_length(tags, 1) > 0 THEN array_to_string(tags, ', ')
        ELSE 'Sem tags'
    END as tags_texto,
    
    -- 📅 DATAS
    DATE(created_at) as data_criacao,
    DATE(updated_at) as data_atualizacao

FROM recipes 
ORDER BY title;

-- ================================================================
-- 🔍 PARTE 3: ANÁLISE DAS PRIMEIRAS PALAVRAS (FREQUÊNCIA)
-- ================================================================
SELECT 
    '🔍 ANÁLISE FREQUÊNCIA PRIMEIRAS PALAVRAS' as secao,
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    COUNT(*) as frequencia,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM recipes)), 2) as porcentagem,
    string_agg(
        CASE WHEN LENGTH(title) > 50 
             THEN LEFT(title, 47) || '...' 
             ELSE title 
        END, 
        ' | ' ORDER BY title
    ) as exemplos_receitas
FROM recipes 
GROUP BY SPLIT_PART(title, ' ', 1)
HAVING COUNT(*) >= 1
ORDER BY frequencia DESC, primeira_palavra;

-- ================================================================
-- 📂 PARTE 4: ANÁLISE POR CATEGORIA COM PRIMEIRAS PALAVRAS
-- ================================================================
SELECT 
    '📂 ANÁLISE POR CATEGORIA' as secao,
    category as categoria,
    COUNT(*) as total_receitas,
    string_agg(
        DISTINCT SPLIT_PART(title, ' ', 1), 
        ', ' ORDER BY SPLIT_PART(title, ' ', 1)
    ) as primeiras_palavras_unicas,
    string_agg(
        CASE WHEN LENGTH(title) > 40 
             THEN LEFT(title, 37) || '...' 
             ELSE title 
        END, 
        ' | ' ORDER BY title
    ) as titulos_resumidos
FROM recipes 
GROUP BY category
ORDER BY total_receitas DESC, category;

-- ================================================================
-- 👨‍🍳 PARTE 5: ANÁLISE POR AUTOR COM PRIMEIRAS PALAVRAS
-- ================================================================
SELECT 
    '👨‍🍳 ANÁLISE POR AUTOR' as secao,
    author_name as autor,
    author_type as tipo_autor,
    COUNT(*) as total_receitas,
    string_agg(
        DISTINCT SPLIT_PART(title, ' ', 1), 
        ', ' ORDER BY SPLIT_PART(title, ' ', 1)
    ) as primeiras_palavras_unicas,
    AVG(preparation_time_minutes) as tempo_medio_preparo,
    AVG(calories) as calorias_medias,
    AVG(rating) as avaliacao_media
FROM recipes 
GROUP BY author_name, author_type
ORDER BY total_receitas DESC, autor;

-- ================================================================
-- ⭐ PARTE 6: RECEITAS DESTACADAS COM FOCO EM PRIMEIRAS PALAVRAS
-- ================================================================
SELECT 
    '⭐ RECEITAS EM DESTAQUE' as secao,
    title as titulo_completo,
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2) as duas_primeiras_palavras,
    category as categoria,
    author_name as autor,
    rating as avaliacao,
    preparation_time_minutes as tempo_preparo,
    calories as calorias
FROM recipes 
WHERE is_featured = true
ORDER BY rating DESC, title;

-- ================================================================
-- 🎬 PARTE 7: RECEITAS EM VÍDEO COM PRIMEIRAS PALAVRAS
-- ================================================================
SELECT 
    '🎬 RECEITAS EM VÍDEO' as secao,
    title as titulo_completo,
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    video_url as url_video,
    video_duration as duracao_video_seg,
    category as categoria,
    author_name as autor
FROM recipes 
WHERE content_type = 'video'
ORDER BY video_duration DESC, title;

-- ================================================================
-- 📊 PARTE 8: RESUMO ESTATÍSTICO FINAL
-- ================================================================
SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL' as secao,
    'Total de receitas' as metrica,
    COUNT(*)::text as valor
FROM recipes

UNION ALL

SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL',
    'Palavras iniciais únicas',
    COUNT(DISTINCT SPLIT_PART(title, ' ', 1))::text
FROM recipes

UNION ALL

SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL',
    'Categorias diferentes',
    COUNT(DISTINCT category)::text
FROM recipes

UNION ALL

SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL',
    'Autores diferentes',
    COUNT(DISTINCT author_name)::text
FROM recipes

UNION ALL

SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL',
    'Tempo médio de preparo (min)',
    ROUND(AVG(preparation_time_minutes), 2)::text
FROM recipes

UNION ALL

SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL',
    'Calorias médias',
    ROUND(AVG(calories), 0)::text
FROM recipes

UNION ALL

SELECT 
    '📊 RESUMO ESTATÍSTICO FINAL',
    'Avaliação média',
    ROUND(AVG(rating), 2)::text
FROM recipes

ORDER BY metrica;

-- ================================================================
-- 🏁 SCRIPT FINALIZADO
-- ================================================================
SELECT 
    '🏁 ANÁLISE CONCLUÍDA!' as status,
    'Script executado com sucesso - Todas as 74 receitas analisadas' as mensagem,
    NOW()::timestamp as data_execucao; 