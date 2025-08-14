-- ================================================================
-- LIMPEZA AGRESSIVA: APENAS POR TÍTULO
-- Data: 2025-01-21 23:05
-- Problema: Script anterior manteve duplicatas com descrições diferentes
-- Solução: Remover duplicatas baseado APENAS no título
-- ================================================================

-- 🎯 ESTRATÉGIA AGRESSIVA:
-- 1. Manter apenas 1 receita por título (ignorando descrição)
-- 2. Priorizar receitas mais antigas (created_at ASC)
-- 3. Remover todas as outras cópias

-- ================================================================
-- ETAPA 1: BACKUP ADICIONAL (caso precise reverter)
-- ================================================================

-- Backup do estado atual (antes da limpeza agressiva)
CREATE TABLE IF NOT EXISTS recipes_backup_antes_agressiva AS
SELECT *, NOW() as backup_timestamp
FROM recipes;

-- ================================================================
-- ETAPA 2: DIAGNÓSTICO ATUAL
-- ================================================================

-- Mostrar situação atual
SELECT 
    '📊 SITUAÇÃO ANTES DA LIMPEZA AGRESSIVA' as status,
    COUNT(*) as total_receitas,
    COUNT(DISTINCT UPPER(TRIM(title))) as titulos_unicos,
    COUNT(*) - COUNT(DISTINCT UPPER(TRIM(title))) as duplicatas_restantes
FROM recipes;

-- Mostrar exemplos de duplicatas restantes
SELECT 
    '🔍 EXEMPLOS DE DUPLICATAS RESTANTES' as categoria,
    UPPER(TRIM(title)) as titulo_normalizado,
    COUNT(*) as copias,
    STRING_AGG(SUBSTRING(id::text, 1, 8), ', ') as ids_parciais
FROM recipes
GROUP BY UPPER(TRIM(title))
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 10;

-- ================================================================
-- ETAPA 3: LIMPEZA AGRESSIVA (APENAS POR TÍTULO)
-- ================================================================

-- Remover duplicatas mantendo apenas a receita mais ANTIGA de cada título
WITH receitas_manter_unicas AS (
    SELECT DISTINCT ON (UPPER(TRIM(title))) 
        id,
        title,
        created_at
    FROM recipes
    ORDER BY UPPER(TRIM(title)), created_at ASC
)
DELETE FROM recipes 
WHERE id NOT IN (SELECT id FROM receitas_manter_unicas);

-- ================================================================
-- ETAPA 4: VERIFICAÇÃO FINAL
-- ================================================================

-- Verificar resultado da limpeza agressiva
SELECT 
    '✅ LIMPEZA AGRESSIVA CONCLUÍDA' as resultado,
    COUNT(*) as total_receitas_final,
    COUNT(DISTINCT UPPER(TRIM(title))) as titulos_unicos_final,
    COUNT(*) - COUNT(DISTINCT UPPER(TRIM(title))) as duplicatas_restantes,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem,
    ROUND(
        COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*), 
        1
    ) as percentual_com_imagem,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT UPPER(TRIM(title))) 
        THEN '🎉 ZERO DUPLICATAS!'
        ELSE '⚠️ Ainda há duplicatas (erro no script)'
    END as status_duplicatas
FROM recipes;

-- Mostrar distribuição final por data
SELECT 
    '📅 DISTRIBUIÇÃO FINAL POR DATA' as categoria,
    DATE(created_at) as data_criacao,
    COUNT(*) as receitas
FROM recipes
GROUP BY DATE(created_at)
ORDER BY data_criacao;

-- Verificar se sobrou alguma duplicata (não deveria haver)
SELECT 
    '🚨 DUPLICATAS RESTANTES (NÃO DEVERIA HAVER)' as categoria,
    UPPER(TRIM(title)) as titulo,
    COUNT(*) as copias
FROM recipes
GROUP BY UPPER(TRIM(title))
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ================================================================
-- ETAPA 5: COMPARAÇÃO COM DOCUMENTO ORIGINAL
-- ================================================================

-- Lista das 78 receitas do documento original
WITH receitas_documento AS (
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
    '📋 COMPARAÇÃO COM DOCUMENTO' as categoria,
    (SELECT COUNT(*) FROM recipes) as receitas_no_banco,
    (SELECT COUNT(*) FROM receitas_documento) as receitas_no_documento,
    (SELECT COUNT(*) FROM recipes) - (SELECT COUNT(*) FROM receitas_documento) as diferenca
;

-- ================================================================
-- INFORMAÇÕES DE BACKUP
-- ================================================================

SELECT 
    '💾 BACKUPS DISPONÍVEIS' as status,
    'recipes_backup_limpeza' as backup_1,
    (SELECT COUNT(*) FROM recipes_backup_limpeza) as total_backup_1,
    'recipes_backup_antes_agressiva' as backup_2,
    (SELECT COUNT(*) FROM recipes_backup_antes_agressiva) as total_backup_2;

-- ================================================================
-- 🎯 RESULTADO ESPERADO:
-- - Total receitas: ~80 (títulos únicos)
-- - Zero duplicatas
-- - 100% com imagens
-- - Sistema limpo e eficiente!
-- ================================================================ 