-- ================================================================
-- LIMPEZA CONFIRMADA: REMOÇÃO DE RECEITAS DUPLICADAS
-- Data: 2025-01-21 22:05
-- Situação: CONFIRMADAS 53+ receitas duplicadas (74 originais → 144 atuais)
-- Objetivo: Voltar às ~74 receitas originais removendo duplicatas
-- ================================================================

-- 🎯 ESTRATÉGIA CONFIRMADA:
-- 1. Manter APENAS a versão mais ANTIGA de cada receita (primeira importação)
-- 2. Remover versões posteriores (importações duplicadas)
-- 3. Priorizar receitas com data 2025-05-29 11:33:34 sobre 11:33:54

-- ================================================================
-- ETAPA 1: BACKUP DE SEGURANÇA (OBRIGATÓRIO)
-- ================================================================

-- Criar backup completo antes da limpeza
CREATE TABLE recipes_backup_antes_limpeza AS
SELECT *, NOW() as backup_timestamp
FROM recipes;

-- Verificar backup criado
SELECT 
    '💾 BACKUP CRIADO' as status,
    COUNT(*) as total_recipes_backup
FROM recipes_backup_antes_limpeza;

-- ================================================================
-- ETAPA 2: IDENTIFICAR RECEITAS A MANTER (MAIS ANTIGAS)
-- ================================================================

-- Criar tabela temporária com IDs das receitas a serem MANTIDAS
-- Mantém a versão mais ANTIGA de cada grupo de duplicatas
CREATE TEMP TABLE receitas_manter_mais_antigas AS
SELECT DISTINCT ON (UPPER(TRIM(title)), TRIM(description)) 
    id,
    title,
    description,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY UPPER(TRIM(title)), TRIM(description) ORDER BY created_at ASC) as prioridade
FROM recipes
ORDER BY UPPER(TRIM(title)), TRIM(description), created_at ASC;

-- Verificar o que será mantido vs removido
SELECT 
    '📊 PREVIEW LIMPEZA' as acao,
    (SELECT COUNT(*) FROM recipes) as total_atual,
    (SELECT COUNT(*) FROM receitas_manter_mais_antigas) as total_apos_limpeza,
    (SELECT COUNT(*) FROM recipes) - (SELECT COUNT(*) FROM receitas_manter_mais_antigas) as receitas_serao_removidas;

-- ================================================================
-- ETAPA 3: LISTAR RECEITAS QUE SERÃO REMOVIDAS (PREVIEW)
-- ================================================================

-- Mostrar exemplos do que será removido
SELECT 
    '🗑️ RECEITAS QUE SERÃO REMOVIDAS (PREVIEW)' as categoria,
    r.title,
    r.created_at,
    r.id,
    'Duplicata - versão mais recente' as motivo
FROM recipes r
WHERE r.id NOT IN (SELECT id FROM receitas_manter_mais_antigas)
ORDER BY r.title, r.created_at
LIMIT 20;

-- Verificar se a lógica está correta (deve remover versões de 11:33:54)
SELECT 
    '⏰ ANÁLISE TEMPORAL' as categoria,
    DATE_TRUNC('minute', created_at) as minuto_criacao,
    COUNT(*) as receitas_neste_minuto,
    CASE 
        WHEN EXTRACT(SECOND FROM created_at) BETWEEN 30 AND 40 THEN 'Primeira importação (MANTER)'
        WHEN EXTRACT(SECOND FROM created_at) BETWEEN 50 AND 60 THEN 'Segunda importação (REMOVER)'
        ELSE 'Outras datas'
    END as acao_recomendada
FROM recipes
WHERE DATE(created_at) = '2025-05-29'
GROUP BY DATE_TRUNC('minute', created_at), EXTRACT(SECOND FROM created_at)
ORDER BY minuto_criacao;

-- ================================================================
-- ETAPA 4: EXECUTAR LIMPEZA (DESCOMENTE APÓS VERIFICAR)
-- ================================================================

-- ⚠️ EXECUTE APENAS APÓS CONFIRMAR O PREVIEW ACIMA ⚠️

-- Remover receitas duplicadas (manter apenas as mais antigas)
-- DESCOMENTE A LINHA ABAIXO PARA EXECUTAR:
/*
DELETE FROM recipes 
WHERE id NOT IN (SELECT id FROM receitas_manter_mais_antigas);
*/

-- ================================================================
-- ETAPA 5: VERIFICAÇÃO FINAL (DESCOMENTE APÓS LIMPEZA)
-- ================================================================

-- Verificar resultado da limpeza
/*
SELECT 
    '✅ LIMPEZA CONCLUÍDA' as resultado,
    COUNT(*) as total_receitas_final,
    COUNT(DISTINCT UPPER(TRIM(title))) as titulos_unicos,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT UPPER(TRIM(title))) 
        THEN '🎉 SEM DUPLICATAS!'
        ELSE '⚠️ Ainda há duplicatas'
    END as status_duplicatas
FROM recipes;
*/

-- Mostrar distribuição final por data
/*
SELECT 
    '📅 DISTRIBUIÇÃO FINAL' as categoria,
    DATE(created_at) as data_criacao,
    COUNT(*) as receitas
FROM recipes
GROUP BY DATE(created_at)
ORDER BY data_criacao;
*/

-- ================================================================
-- ETAPA 6: REINDEXAÇÃO E OTIMIZAÇÃO (OPCIONAL)
-- ================================================================

-- Após limpeza bem-sucedida, otimizar tabela
/*
REINDEX TABLE recipes;
ANALYZE recipes;
*/

-- Limpar tabela temporária
DROP TABLE IF EXISTS receitas_manter_mais_antigas;

-- ================================================================
-- ETAPA 7: VERIFICAÇÃO DE INTEGRIDADE FINAL
-- ================================================================

-- Verificar se não há dados corrompidos após limpeza
/*
SELECT 
    '🔍 INTEGRIDADE FINAL' as categoria,
    COUNT(*) as total,
    COUNT(CASE WHEN title IS NULL OR title = '' THEN 1 END) as titulos_vazios,
    COUNT(CASE WHEN description IS NULL OR description = '' THEN 1 END) as descricoes_vazias,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as sem_imagem,
    AVG(LENGTH(title)) as tamanho_medio_titulo
FROM recipes;
*/ 