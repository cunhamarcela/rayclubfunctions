-- ================================================================
-- SCRIPT: REMOÇÃO SEGURA DE RECEITAS DUPLICADAS
-- Data: 2025-01-21 21:57
-- Objetivo: Remover duplicatas mantendo apenas a versão mais recente
-- ================================================================

-- ⚠️ IMPORTANTE: Execute este script APENAS após confirmar que há duplicatas
-- ⚠️ Faça backup antes de executar!

-- ================================================================
-- ETAPA 1: IDENTIFICAR DUPLICATAS PARA REMOÇÃO
-- ================================================================

-- Criar tabela temporária com IDs das receitas a serem mantidas
-- (mantém a mais recente de cada grupo de duplicatas)
CREATE TEMP TABLE receitas_para_manter AS
SELECT DISTINCT ON (title, description) 
    id,
    title,
    created_at
FROM recipes
ORDER BY title, description, created_at DESC;

-- ================================================================
-- ETAPA 2: VERIFICAR O QUE SERÁ REMOVIDO (SEGURANÇA)
-- ================================================================

-- Mostrar quantas receitas serão removidas
SELECT 
    '⚠️ PREVIEW REMOÇÃO' as acao,
    (SELECT COUNT(*) FROM recipes) as total_atual,
    (SELECT COUNT(*) FROM receitas_para_manter) as total_apos_limpeza,
    (SELECT COUNT(*) FROM recipes) - (SELECT COUNT(*) FROM receitas_para_manter) as receitas_serao_removidas;

-- Listar receitas que serão removidas (preview)
SELECT 
    '🗑️ RECEITAS QUE SERÃO REMOVIDAS' as categoria,
    r.title,
    r.created_at,
    r.id
FROM recipes r
WHERE r.id NOT IN (SELECT id FROM receitas_para_manter)
ORDER BY r.title, r.created_at
LIMIT 20;

-- ================================================================
-- ETAPA 3: REMOÇÃO SEGURA (DESCOMENTE APENAS SE CONFIRMAR)
-- ================================================================

-- ⚠️ DESCOMENTE AS LINHAS ABAIXO APENAS APÓS VERIFICAR O PREVIEW ⚠️

/*
-- Primeiro, remover dependências se existirem (ex: favoritos)
DELETE FROM recipe_favorites 
WHERE recipe_id NOT IN (SELECT id FROM receitas_para_manter);

-- Remover as receitas duplicadas
DELETE FROM recipes 
WHERE id NOT IN (SELECT id FROM receitas_para_manter);

-- Verificar resultado final
SELECT 
    '✅ LIMPEZA CONCLUÍDA' as resultado,
    COUNT(*) as total_receitas_final
FROM recipes;
*/

-- ================================================================
-- ETAPA 4: SCRIPT ALTERNATIVO - REMOÇÃO POR TÍTULO EXATO
-- ================================================================

-- Se preferir remover apenas duplicatas com título idêntico:
/*
WITH duplicatas AS (
    SELECT title, MIN(id) as id_manter
    FROM recipes
    GROUP BY title
    HAVING COUNT(*) > 1
),
ids_para_remover AS (
    SELECT r.id
    FROM recipes r
    INNER JOIN duplicatas d ON r.title = d.title
    WHERE r.id != d.id_manter
)
-- Visualizar o que seria removido:
SELECT 
    '📋 DUPLICATAS POR TÍTULO' as categoria,
    r.title,
    r.id,
    r.created_at
FROM recipes r
INNER JOIN ids_para_remover ipr ON r.id = ipr.id
ORDER BY r.title, r.created_at;

-- Para executar a remoção, descomente:
-- DELETE FROM recipes WHERE id IN (SELECT id FROM ids_para_remover);
*/

-- ================================================================
-- ETAPA 5: VERIFICAÇÃO FINAL E REINDEXAÇÃO
-- ================================================================

-- Após a limpeza, verificar integridade
SELECT 
    '🔍 VERIFICAÇÃO FINAL' as categoria,
    COUNT(*) as total_receitas,
    COUNT(DISTINCT title) as titulos_unicos,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT title) 
        THEN '✅ Sem duplicatas'
        ELSE '⚠️ Ainda há possíveis duplicatas'
    END as status_duplicatas
FROM recipes;

-- Recriar índices se necessário (descomente se executar a limpeza)
/*
REINDEX TABLE recipes;
ANALYZE recipes;
*/

-- ================================================================
-- ETAPA 6: BACKUP DOS DADOS REMOVIDOS (OPCIONAL)
-- ================================================================

-- Se quiser manter backup das receitas removidas:
/*
CREATE TABLE recipes_backup_duplicatas AS
SELECT r.*, NOW() as backup_date
FROM recipes r
WHERE r.id NOT IN (SELECT id FROM receitas_para_manter);
*/

-- Limpar tabela temporária
DROP TABLE IF EXISTS receitas_para_manter; 