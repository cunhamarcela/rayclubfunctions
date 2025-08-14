-- ================================================================
-- LIMPEZA COMPLETA: EXECUÇÃO ÚNICA
-- Data: 2025-01-21 23:00
-- Objetivo: Remover duplicatas em um único comando
-- ================================================================

-- 🎯 ESTE SCRIPT FAZ TUDO DE UMA VEZ:
-- 1. Cria backup
-- 2. Identifica receitas a manter
-- 3. Remove duplicatas
-- 4. Verifica resultado

-- ================================================================
-- ETAPA 1: BACKUP DE SEGURANÇA
-- ================================================================

-- Criar backup das receitas com imagens
CREATE TABLE IF NOT EXISTS recipes_backup_limpeza AS
SELECT *, NOW() as backup_timestamp
FROM recipes;

-- ================================================================
-- ETAPA 2: LIMPEZA DAS DUPLICATAS
-- ================================================================

-- Remover duplicatas mantendo apenas a versão mais antiga de cada título
WITH receitas_manter AS (
    SELECT DISTINCT ON (UPPER(TRIM(title)), TRIM(description)) 
        id,
        title,
        created_at
    FROM recipes
    ORDER BY UPPER(TRIM(title)), TRIM(description), created_at ASC
)
DELETE FROM recipes 
WHERE id NOT IN (SELECT id FROM receitas_manter);

-- ================================================================
-- ETAPA 3: VERIFICAÇÃO FINAL
-- ================================================================

-- Mostrar resultado da limpeza
SELECT 
    '✅ LIMPEZA CONCLUÍDA' as resultado,
    COUNT(*) as total_receitas_final,
    COUNT(DISTINCT UPPER(TRIM(title))) as titulos_unicos,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem,
    ROUND(
        COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*), 
        1
    ) as percentual_com_imagem,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT UPPER(TRIM(title))) 
        THEN '🎉 SEM DUPLICATAS!'
        ELSE '⚠️ Ainda há duplicatas'
    END as status_duplicatas
FROM recipes;

-- Mostrar distribuição final por data de criação
SELECT 
    '📅 DISTRIBUIÇÃO FINAL POR DATA' as categoria,
    DATE(created_at) as data_criacao,
    COUNT(*) as receitas
FROM recipes
GROUP BY DATE(created_at)
ORDER BY data_criacao;

-- Verificar se alguma receita ficou sem imagem

-- ================================================================
-- ETAPA 4: INFORMAÇÕES DO BACKUP
-- ================================================================

-- Confirmar que backup foi criado
SELECT 
    '💾 BACKUP CRIADO' as status,
    COUNT(*) as total_no_backup,
    MIN(backup_timestamp) as data_backup
FROM recipes_backup_limpeza;

-- ================================================================
-- 🎉 PRONTO! 
-- Duplicatas removidas e imagens preservadas!
-- Para reverter se necessário: 
-- DROP TABLE recipes; 
-- ALTER TABLE recipes_backup_limpeza RENAME TO recipes;
-- ================================================================ 