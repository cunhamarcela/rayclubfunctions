-- ================================================================
-- PASSO 2: VALIDAR E APLICAR DATASET RECUPERADO
-- ================================================================
-- Execute este script APÓS o step1_create_recovered_table.sql
-- ================================================================

-- Verificar se a tabela recuperada existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = 'challenge_check_ins_recovered'
        ) THEN '✅ Tabela recuperada encontrada'
        ELSE '❌ ERRO: Tabela recuperada não encontrada!'
    END as verificacao_tabela;

-- ================================================================
-- VALIDAÇÕES FINAIS
-- ================================================================

-- 🔍 Verificar resultado da combinação
SELECT 
    '🔍 DATASET RECUPERADO' as categoria,
    COUNT(*) as total_registros_recuperados,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    COUNT(*) FILTER (WHERE origem = 'backup_emergency') as do_backup,
    COUNT(*) FILTER (WHERE origem = 'dados_atuais') as dos_atuais,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro
FROM challenge_check_ins_recovered;

-- 🚨 Verificar se ainda há duplicatas
SELECT 
    '🚨 VERIFICAÇÃO DE DUPLICATAS NO DATASET RECUPERADO' as categoria,
    COUNT(*) as registros_totais,
    COUNT(DISTINCT user_id, challenge_id, DATE(check_in_date)) as registros_unicos,
    COUNT(*) - COUNT(DISTINCT user_id, challenge_id, DATE(check_in_date)) as duplicatas_encontradas
FROM challenge_check_ins_recovered;

-- 🔍 Verificar distribuição por origem
SELECT 
    origem,
    COUNT(*) as quantidade,
    COUNT(DISTINCT user_id) as usuarios,
    MIN(created_at) as primeiro,
    MAX(created_at) as ultimo
FROM challenge_check_ins_recovered
GROUP BY origem
ORDER BY origem;

-- ================================================================
-- APLICAR RECUPERAÇÃO (DESCOMENTE PARA EXECUTAR)
-- ================================================================

-- ⚠️  ATENÇÃO: Descomente as linhas abaixo APENAS após validar os resultados acima

/*
-- Backup da tabela atual antes da substituição
DROP TABLE IF EXISTS challenge_check_ins_before_recovery;
CREATE TABLE challenge_check_ins_before_recovery AS 
SELECT * FROM challenge_check_ins;

-- Limpar tabela atual
DELETE FROM challenge_check_ins;

-- Inserir dados recuperados (sem a coluna origem)
INSERT INTO challenge_check_ins (
    id,
    user_id,
    challenge_id,
    check_in_date,
    workout_id,
    workout_name,
    workout_type,
    duration_minutes,
    points,
    created_at,
    updated_at
)
SELECT 
    id,
    user_id,
    challenge_id,
    check_in_date,
    workout_id,
    workout_name,
    workout_type,
    duration_minutes,
    points,
    created_at,
    updated_at
FROM challenge_check_ins_recovered
ORDER BY created_at;

-- Verificar resultado final
SELECT 
    '🎉 RECUPERAÇÃO CONCLUÍDA' as status,
    COUNT(*) as registros_finais,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro
FROM challenge_check_ins;

SELECT '✅ DADOS RECUPERADOS E APLICADOS COM SUCESSO!' as resultado;
*/

SELECT '⚠️  REMOVA OS COMENTÁRIOS ACIMA PARA APLICAR A RECUPERAÇÃO' as instrucoes; 