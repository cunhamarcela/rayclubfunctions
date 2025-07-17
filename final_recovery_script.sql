-- ================================================================
-- SCRIPT FINAL DE RECUPERAÇÃO DE DADOS - VERSÃO PARA APLICAÇÃO
-- ================================================================
-- Execute este script inteiro de uma só vez para aplicar a recuperação
-- ================================================================

SELECT '🏥 INICIANDO RECUPERAÇÃO COMPLETA DE DADOS' as status;

-- ================================================================
-- PASSO 1: CRIAR DATASET RECUPERADO LIMPO
-- ================================================================

-- Criar tabela temporária com registros limpos combinados
CREATE TEMP TABLE challenge_check_ins_recovered AS
WITH backup_limpo AS (
    -- Extrair registros únicos do backup (mantendo o mais antigo de cada grupo)
    SELECT DISTINCT ON (user_id, challenge_id, DATE(check_in_date))
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
        updated_at,
        'backup_emergency' as origem
    FROM challenge_check_ins_backup_emergency
    ORDER BY user_id, challenge_id, DATE(check_in_date), created_at ASC
),
atuais_limpo AS (
    -- Extrair registros únicos dos dados atuais (mantendo o mais antigo de cada grupo)
    SELECT DISTINCT ON (user_id, challenge_id, DATE(check_in_date))
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
        updated_at,
        'dados_atuais' as origem
    FROM challenge_check_ins
    ORDER BY user_id, challenge_id, DATE(check_in_date), created_at ASC
),
combinado AS (
    -- Combinar ambos datasets, priorizando backup para períodos antigos
    SELECT 
        b.*
    FROM backup_limpo b
    
    UNION ALL
    
    -- Adicionar registros dos dados atuais que não existem no backup
    SELECT 
        a.*
    FROM atuais_limpo a
    WHERE NOT EXISTS (
        SELECT 1 FROM backup_limpo b 
        WHERE b.user_id = a.user_id 
        AND b.challenge_id = a.challenge_id 
        AND DATE(b.check_in_date) = DATE(a.check_in_date)
    )
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
    updated_at,
    origem
FROM combinado
ORDER BY created_at;

-- ================================================================
-- PASSO 2: VALIDAÇÕES RÁPIDAS
-- ================================================================

SELECT '✅ DATASET RECUPERADO CRIADO - VALIDANDO' as status;

-- Verificar resultado da combinação
SELECT 
    '🔍 DATASET RECUPERADO' as categoria,
    COUNT(*) as total_registros_recuperados,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    COUNT(*) FILTER (WHERE origem = 'backup_emergency') as do_backup,
    COUNT(*) FILTER (WHERE origem = 'dados_atuais') as dos_atuais
FROM challenge_check_ins_recovered;

-- Verificar se ainda há duplicatas
SELECT 
    '🚨 VERIFICAÇÃO DE DUPLICATAS' as categoria,
    COUNT(*) as registros_totais,
    COUNT(DISTINCT CONCAT(user_id::text, '-', challenge_id::text, '-', DATE(check_in_date)::text)) as registros_unicos,
    COUNT(*) - COUNT(DISTINCT CONCAT(user_id::text, '-', challenge_id::text, '-', DATE(check_in_date)::text)) as duplicatas_encontradas
FROM challenge_check_ins_recovered;

-- ================================================================
-- PASSO 3: APLICAR RECUPERAÇÃO
-- ================================================================

SELECT '🚨 INICIANDO APLICAÇÃO DA RECUPERAÇÃO' as status;

-- Backup da tabela atual antes da substituição
DROP TABLE IF EXISTS challenge_check_ins_before_recovery;
CREATE TABLE challenge_check_ins_before_recovery AS 
SELECT * FROM challenge_check_ins;

SELECT '✅ Backup da tabela atual criado' as status;

-- Limpar tabela atual
DELETE FROM challenge_check_ins;

SELECT '✅ Tabela atual limpa' as status;

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

SELECT '✅ Dados recuperados inseridos' as status;

-- ================================================================
-- PASSO 4: VERIFICAÇÃO FINAL
-- ================================================================

-- Verificar resultado final
SELECT 
    '🎉 RECUPERAÇÃO CONCLUÍDA' as status,
    COUNT(*) as registros_finais,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    COUNT(DISTINCT CONCAT(user_id::text, '-', challenge_id::text, '-', DATE(check_in_date)::text)) as registros_unicos_por_dia,
    COUNT(*) - COUNT(DISTINCT CONCAT(user_id::text, '-', challenge_id::text, '-', DATE(check_in_date)::text)) as duplicatas_restantes,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro
FROM challenge_check_ins;

-- Comparação final
SELECT 
    'ANTES (backup)' as periodo,
    COUNT(*) as registros,
    COUNT(DISTINCT user_id) as usuarios,
    MIN(created_at) as primeiro,
    MAX(created_at) as ultimo
FROM challenge_check_ins_before_recovery

UNION ALL

SELECT 
    'DEPOIS (recuperado)' as periodo,
    COUNT(*) as registros,
    COUNT(DISTINCT user_id) as usuarios,
    MIN(created_at) as primeiro,
    MAX(created_at) as ultimo
FROM challenge_check_ins;

SELECT '✅ DADOS RECUPERADOS E APLICADOS COM SUCESSO!' as resultado;
SELECT '🏆 SISTEMA LIMPO: ZERO DUPLICATAS GARANTIDO!' as final; 