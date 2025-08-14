-- ================================================================
-- DIAGNÓSTICO: RECEITAS DO BANCO vs DOCUMENTO ORIGINAL
-- Data: 2025-01-21 22:45
-- Problema: 144 receitas no banco vs ~78 no documento original
-- Objetivo: Identificar exatamente quais receitas estão duplicadas
-- ================================================================

-- 🎯 ESTRATÉGIA DE DIAGNÓSTICO:
-- 1. Listar todas as receitas únicas por título
-- 2. Contar quantas vezes cada uma aparece
-- 3. Identificar padrão de duplicação
-- 4. Preparar limpeza precisa

-- ================================================================
-- ETAPA 1: CONTAGEM ATUAL REAL
-- ================================================================

-- Total de receitas no banco
SELECT 
    '📊 SITUAÇÃO ATUAL NO BANCO' as categoria,
    COUNT(*) as total_receitas_banco,
    COUNT(DISTINCT UPPER(TRIM(title))) as titulos_unicos,
    COUNT(*) - COUNT(DISTINCT UPPER(TRIM(title))) as duplicatas_confirmadas,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT UPPER(TRIM(title))), 2) as fator_duplicacao
FROM recipes;

-- ================================================================
-- ETAPA 2: LISTA DE RECEITAS ÚNICAS DO DOCUMENTO ORIGINAL
-- ================================================================

-- Baseado no documento Bruna Braga, estas são as ~78 receitas originais:
WITH receitas_originais_documento AS (
    SELECT unnest(ARRAY[
        'Bolo de Banana de Caneca',
        'Banana Toast',
        'Gororoba de Banana', 
        'Pão de Queijo de Airfryer',
        'Tortinha de Frango de Airfryer',
        'Bolo Alagado',
        'Panqueca de Espinafre e Atum',
        'Smoothie de Frutas Vermelhas e Whey Protein',
        'Abobrinha Recheada com Frango e Creme de Ricota',
        'Aveioca',
        'Barrinha de Proteína Artesanal',
        'Beijinho Saudável',
        'Berinjela Recheada',
        'Biscoito de Banana com Passas',
        'Bolinho de Prestígio',
        'Bolo de Maçã com Canela',
        'Bolo de Laranja com Casca',
        'Caldo Verde',
        'Caldo de Abóbora',
        'Caldo de Legumes',
        'Canja de Galinha',
        'Caponata de Berinjela',
        'Chips de Batata Doce',
        'Snacks de Grão de Bico',
        'Coxinha Funcional de Frango com Creme de Queijo Cottage',
        'Crepe de Beterraba',
        'Espaguete de Abobrinha',
        'Falafel de Forno',
        'Frango Teriyaki com Legumes Assados',
        'Granola Caseira',
        'Gratinado Light de Frango',
        'Grãomelete (Omelete de Grão de Bico)',
        'Hambúrguer Caseiro',
        'Lasanha de Berinjela',
        'Lasanha de Abobrinha',
        'Mexido de Tofu',
        'Molho Pesto',
        'Mousse de Maracujá',
        'Muffin Salgado (Frango, Ovo, Tapioca, Requeijão Light)',
        'Muffin de Mirtilo (com proteína vegetal de baunilha)',
        'Nhoque de Cenoura',
        'Nhoque de Mandioquinha',
        'Nuggets de Frango Funcional',
        'Omelete de Forno',
        'Panqueca de Cacau',
        'Pão Caseiro sem Glúten',
        'Pastinha de Berinjela',
        'Patê de Frango',
        'Patê de Atum',
        'Patê de Ricota com Alho',
        'Picolé de Frutas',
        'Sorvete de Iogurte com Whey',
        'Sorbet de Morango e Banana',
        'Pizza de Clara de Ovo com Recheio de Frango Desfiado, Queijo, Tomate e Manjericão',
        'Queijo de Castanhas',
        'Quiche de Alho-Poró e Tofu',
        'Quiche Funcional',
        'Ragu de Cogumelos',
        'Ravioli de Abobrinha',
        'Risoto de Quinoa, Shitake e Limão Siciliano',
        'Salada de Atum Tropical',
        'Salada de Pepino Oriental',
        'Salada Proteica',
        'Salgado de Batata Doce e Frango',
        'Snacks de Abobrinha',
        'Sopa de Beterraba',
        'Strogonoff Saudável',
        'Strogonoff Vegano',
        'Suchá de Melancia, Gengibre e Limão',
        'Suco Verde com Kiwi',
        'Suco Verde Tradicional',
        'Suflê de Legumes',
        'Suflê Vegano',
        'Tomate Recheado',
        'Batata Recheada',
        'Torta de Liquidificador Super Rápida',
        'Waffle Funcional',
        'Yakisoba Light'
    ]) as titulo_original
)
SELECT 
    '📋 RECEITAS DO DOCUMENTO ORIGINAL' as categoria,
    COUNT(*) as total_receitas_documento
FROM receitas_originais_documento;

-- ================================================================
-- ETAPA 3: COMPARAÇÃO BANCO vs DOCUMENTO
-- ================================================================

-- Receitas que estão no banco mas NÃO estão no documento (possíveis extras/erros)
WITH receitas_originais_documento AS (
    SELECT unnest(ARRAY[
        'Bolo de Banana de Caneca', 'Banana Toast', 'Gororoba de Banana', 'Pão de Queijo de Airfryer',
        'Tortinha de Frango de Airfryer', 'Bolo Alagado', 'Panqueca de Espinafre e Atum',
        'Smoothie de Frutas Vermelhas e Whey Protein', 'Abobrinha Recheada com Frango e Creme de Ricota',
        'Aveioca', 'Barrinha de Proteína Artesanal', 'Beijinho Saudável', 'Berinjela Recheada',
        'Biscoito de Banana com Passas', 'Bolinho de Prestígio', 'Bolo de Maçã com Canela',
        'Bolo de Laranja com Casca', 'Caldo Verde', 'Caldo de Abóbora', 'Caldo de Legumes',
        'Canja de Galinha', 'Caponata de Berinjela', 'Chips de Batata Doce', 'Snacks de Grão de Bico',
        'Coxinha Funcional de Frango com Creme de Queijo Cottage', 'Crepe de Beterraba',
        'Espaguete de Abobrinha', 'Falafel de Forno', 'Frango Teriyaki com Legumes Assados',
        'Granola Caseira', 'Gratinado Light de Frango', 'Grãomelete (Omelete de Grão de Bico)',
        'Hambúrguer Caseiro', 'Lasanha de Berinjela', 'Lasanha de Abobrinha', 'Mexido de Tofu',
        'Molho Pesto', 'Mousse de Maracujá', 'Muffin Salgado (Frango, Ovo, Tapioca, Requeijão Light)',
        'Muffin de Mirtilo (com proteína vegetal de baunilha)', 'Nhoque de Cenoura', 'Nhoque de Mandioquinha',
        'Nuggets de Frango Funcional', 'Omelete de Forno', 'Panqueca de Cacau', 'Pão Caseiro sem Glúten',
        'Pastinha de Berinjela', 'Patê de Frango', 'Patê de Atum', 'Patê de Ricota com Alho',
        'Picolé de Frutas', 'Sorvete de Iogurte com Whey', 'Sorbet de Morango e Banana',
        'Pizza de Clara de Ovo com Recheio de Frango Desfiado, Queijo, Tomate e Manjericão',
        'Queijo de Castanhas', 'Quiche de Alho-Poró e Tofu', 'Quiche Funcional', 'Ragu de Cogumelos',
        'Ravioli de Abobrinha', 'Risoto de Quinoa, Shitake e Limão Siciliano', 'Salada de Atum Tropical',
        'Salada de Pepino Oriental', 'Salada Proteica', 'Salgado de Batata Doce e Frango',
        'Snacks de Abobrinha', 'Sopa de Beterraba', 'Strogonoff Saudável', 'Strogonoff Vegano',
        'Suchá de Melancia, Gengibre e Limão', 'Suco Verde com Kiwi', 'Suco Verde Tradicional',
        'Suflê de Legumes', 'Suflê Vegano', 'Tomate Recheado', 'Batata Recheada',
        'Torta de Liquidificador Super Rápida', 'Waffle Funcional', 'Yakisoba Light'
    ]) as titulo_original
)
SELECT 
    '🚨 RECEITAS EXTRAS NO BANCO (NÃO ESTÃO NO DOCUMENTO)' as categoria,
    r.title,
    COUNT(*) as vezes_no_banco
FROM recipes r
WHERE UPPER(TRIM(r.title)) NOT IN (
    SELECT UPPER(TRIM(titulo_original)) FROM receitas_originais_documento
)
GROUP BY r.title
ORDER BY COUNT(*) DESC
LIMIT 20;

-- ================================================================
-- ETAPA 4: RECEITAS COM MAIOR NÚMERO DE DUPLICATAS
-- ================================================================

-- Top 20 receitas mais duplicadas
SELECT 
    '🔥 TOP RECEITAS MAIS DUPLICADAS' as categoria,
    title,
    COUNT(*) as total_copias,
    COUNT(*) - 1 as duplicatas_extras,
    ARRAY_AGG(SUBSTRING(id::text, 1, 8)) as ids_parciais
FROM recipes
GROUP BY title
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;

-- ================================================================
-- ETAPA 5: ESTRATÉGIA DE LIMPEZA RECOMENDADA
-- ================================================================

-- Simulação da limpeza: quantas receitas sobraria se mantivéssemos apenas 1 de cada título
SELECT 
    '💡 SIMULAÇÃO LIMPEZA' as categoria,
    (SELECT COUNT(*) FROM recipes) as total_atual,
    (SELECT COUNT(DISTINCT title) FROM recipes) as total_apos_limpeza,
    (SELECT COUNT(*) FROM recipes) - (SELECT COUNT(DISTINCT title) FROM recipes) as receitas_removidas,
    ROUND(
        (SELECT COUNT(DISTINCT title) FROM recipes) * 100.0 / (SELECT COUNT(*) FROM recipes), 
        1
    ) as percentual_restante
;

-- ================================================================
-- PRÓXIMOS PASSOS RECOMENDADOS:
-- 1. Execute este diagnóstico para confirmar os números
-- 2. Execute: sql/limpeza_duplicatas_confirmada.sql (descomente as linhas de DELETE)
-- 3. Verifique se ficaram ~78 receitas
-- 4. Se necessário, execute novamente a estratégia de imagens nas receitas limpas
-- ================================================================ 