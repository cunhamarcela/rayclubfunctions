-- ================================================================
-- PASSO 1: CRIAR DATASET RECUPERADO LIMPO
-- ================================================================
-- Execute este script primeiro para criar a tabela recuperada
-- ================================================================

SELECT '🏥 INICIANDO CRIAÇÃO DO DATASET RECUPERADO' as status;

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

-- Verificar resultado da criação
SELECT 
    '✅ DATASET RECUPERADO CRIADO' as status,
    COUNT(*) as total_registros_recuperados,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    COUNT(DISTINCT DATE(check_in_date)) as dias_unicos,
    COUNT(*) FILTER (WHERE origem = 'backup_emergency') as do_backup,
    COUNT(*) FILTER (WHERE origem = 'dados_atuais') as dos_atuais,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro
FROM challenge_check_ins_recovered;

SELECT '🏁 DATASET RECUPERADO CRIADO COM SUCESSO!' as resultado; 