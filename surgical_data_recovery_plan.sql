-- ================================================================
-- RECUPERAÇÃO CIRÚRGICA DOS DADOS DE CHECK-INS
-- ================================================================
-- Este script combina inteligentemente:
-- 1. Registros limpos do backup_emergency
-- 2. Registros limpos dos dados atuais
-- 3. Remove todas as duplicatas
-- 4. Preserva máximo de dados legítimos
-- ================================================================

SELECT '🏥 INICIANDO RECUPERAÇÃO CIRÚRGICA DOS DADOS' as status;

-- ================================================================
-- PARTE 1: ANÁLISE DETALHADA ANTES DA RECUPERAÇÃO
-- ================================================================

SELECT '📊 ANÁLISE PRÉ-RECUPERAÇÃO' as secao;

-- 1.1 Verificar registros únicos no backup_emergency
WITH registros_limpos_backup AS (
    SELECT 
        user_id,
        challenge_id,
        DATE(check_in_date) as data_checkin,
        MIN(created_at) as created_at_original,
        COUNT(*) as total_duplicatas
    FROM challenge_check_ins_backup_emergency
    GROUP BY user_id, challenge_id, DATE(check_in_date)
)
SELECT 
    '🔍 BACKUP EMERGENCY LIMPO' as categoria,
    COUNT(*) as registros_unicos,
    SUM(total_duplicatas - 1) as duplicatas_removidas,
    MIN(created_at_original) as primeiro_registro,
    MAX(created_at_original) as ultimo_registro
FROM registros_limpos_backup;

-- 1.2 Verificar registros únicos nos dados atuais
WITH registros_limpos_atuais AS (
    SELECT 
        user_id,
        challenge_id,
        DATE(check_in_date) as data_checkin,
        MIN(created_at) as created_at_original,
        COUNT(*) as total_duplicatas
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date)
)
SELECT 
    '🔍 DADOS ATUAIS LIMPOS' as categoria,
    COUNT(*) as registros_unicos,
    SUM(total_duplicatas - 1) as duplicatas_removidas,
    MIN(created_at_original) as primeiro_registro,
    MAX(created_at_original) as ultimo_registro
FROM registros_limpos_atuais;

-- 1.3 Verificar sobreposição entre datasets
WITH backup_limpo AS (
    SELECT 
        user_id,
        challenge_id,
        DATE(check_in_date) as data_checkin,
        MIN(created_at) as created_at_original
    FROM challenge_check_ins_backup_emergency
    GROUP BY user_id, challenge_id, DATE(check_in_date)
),
atuais_limpo AS (
    SELECT 
        user_id,
        challenge_id,
        DATE(check_in_date) as data_checkin,
        MIN(created_at) as created_at_original
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date)
)
SELECT 
    '🔗 ANÁLISE DE SOBREPOSIÇÃO' as categoria,
    (SELECT COUNT(*) FROM backup_limpo) as registros_backup,
    (SELECT COUNT(*) FROM atuais_limpo) as registros_atuais,
    COUNT(*) as registros_comuns,
    (SELECT COUNT(*) FROM backup_limpo) + (SELECT COUNT(*) FROM atuais_limpo) - COUNT(*) as registros_unicos_total
FROM backup_limpo b
INNER JOIN atuais_limpo a ON (
    b.user_id = a.user_id 
    AND b.challenge_id = a.challenge_id 
    AND b.data_checkin = a.data_checkin
);

-- ================================================================
-- PARTE 2: CRIAR DATASET COMBINADO LIMPO
-- ================================================================

SELECT '🔬 CRIANDO DATASET COMBINADO LIMPO' as secao;

-- 2.1 Criar tabela temporária com registros limpos combinados
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
        notes,
        date,
        calories_burned,
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
        notes,
        date,
        calories_burned,
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
    notes,
    date,
    calories_burned,
    origem
FROM combinado
ORDER BY created_at;

-- 2.2 Verificar resultado da combinação
SELECT 
    '✅ DATASET RECUPERADO' as categoria,
    COUNT(*) as total_registros_recuperados,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    COUNT(DISTINCT DATE(check_in_date)) as dias_unicos,
    COUNT(*) FILTER (WHERE origem = 'backup_emergency') as do_backup,
    COUNT(*) FILTER (WHERE origem = 'dados_atuais') as dos_atuais,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro
FROM challenge_check_ins_recovered;

-- 2.3 Verificar distribuição temporal dos dados recuperados
SELECT 
    '📅 DISTRIBUIÇÃO TEMPORAL RECUPERADA' as categoria,
    DATE(check_in_date) as data,
    COUNT(*) as check_ins_recuperados,
    COUNT(DISTINCT user_id) as usuarios_ativos,
    COUNT(*) FILTER (WHERE origem = 'backup_emergency') as do_backup,
    COUNT(*) FILTER (WHERE origem = 'dados_atuais') as dos_atuais
FROM challenge_check_ins_recovered
WHERE check_in_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(check_in_date)
ORDER BY data DESC
LIMIT 15;

-- ================================================================
-- PARTE 3: VALIDAÇÃO DO DATASET RECUPERADO
-- ================================================================

SELECT '🔍 VALIDAÇÃO DO DATASET RECUPERADO' as secao;

-- 3.1 Verificar se ainda existem duplicatas
WITH duplicatas_verificacao AS (
    SELECT 
        user_id,
        challenge_id,
        DATE(check_in_date) as data_checkin,
        COUNT(*) as total_checkins
    FROM challenge_check_ins_recovered
    GROUP BY user_id, challenge_id, DATE(check_in_date)
    HAVING COUNT(*) > 1
)
SELECT 
    '🚨 VERIFICAÇÃO DE DUPLICATAS' as categoria,
    COUNT(*) as grupos_ainda_duplicados,
    COALESCE(SUM(total_checkins - 1), 0) as duplicatas_restantes
FROM duplicatas_verificacao;

-- 3.2 Comparar com datasets originais
SELECT 
    '📊 COMPARAÇÃO FINAL' as categoria,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency) as backup_original,
    (SELECT COUNT(*) FROM challenge_check_ins) as dados_originais,
    (SELECT COUNT(*) FROM challenge_check_ins_recovered) as dados_recuperados,
    ROUND(
        (SELECT COUNT(*) FROM challenge_check_ins_recovered) * 100.0 / 
        GREATEST(
            (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency), 
            (SELECT COUNT(*) FROM challenge_check_ins)
        ), 
        2
    ) as percentual_recuperacao;

-- 3.3 Verificar integridade referencial
SELECT 
    '🔗 INTEGRIDADE REFERENCIAL' as categoria,
    COUNT(*) FILTER (WHERE 
        NOT EXISTS (SELECT 1 FROM challenges c WHERE c.id = ccr.challenge_id)
    ) as challenges_inexistentes,
    COUNT(*) FILTER (WHERE 
        NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = ccr.user_id)
    ) as usuarios_inexistentes,
    COUNT(*) as total_verificado
FROM challenge_check_ins_recovered ccr;

-- ================================================================
-- PARTE 4: PREPARAR SCRIPT DE APLICAÇÃO
-- ================================================================

SELECT '📜 PREPARANDO SCRIPT DE APLICAÇÃO' as secao;

-- 4.1 Contar impacto da aplicação
SELECT 
    '⚠️ IMPACTO DA APLICAÇÃO' as categoria,
    (SELECT COUNT(*) FROM challenge_check_ins) as registros_atuais,
    (SELECT COUNT(*) FROM challenge_check_ins_recovered) as registros_pos_recuperacao,
    (SELECT COUNT(*) FROM challenge_check_ins_recovered) - (SELECT COUNT(*) FROM challenge_check_ins) as diferenca_liquida,
    CASE 
        WHEN (SELECT COUNT(*) FROM challenge_check_ins_recovered) > (SELECT COUNT(*) FROM challenge_check_ins) 
        THEN 'GANHO DE DADOS ✅'
        WHEN (SELECT COUNT(*) FROM challenge_check_ins_recovered) < (SELECT COUNT(*) FROM challenge_check_ins) 
        THEN 'PERDA DE DADOS ❌'
        ELSE 'SEM MUDANÇA ⚖️'
    END as tipo_impacto;

-- ================================================================
-- PARTE 5: RESUMO EXECUTIVO DA RECUPERAÇÃO
-- ================================================================

SELECT '📋 RESUMO EXECUTIVO DA RECUPERAÇÃO' as titulo;

-- 5.1 Métricas de recuperação
SELECT '📊 MÉTRICAS DE RECUPERAÇÃO:' as categoria;

SELECT 
    'REGISTROS TOTAIS RECUPERADOS' as metrica,
    (SELECT COUNT(*) FROM challenge_check_ins_recovered) as valor;

SELECT 
    'DUPLICATAS ELIMINADAS' as metrica,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency) + 
    (SELECT COUNT(*) FROM challenge_check_ins) - 
    (SELECT COUNT(*) FROM challenge_check_ins_recovered) as valor;

SELECT 
    'PERÍODO COBERTO' as metrica,
    (SELECT MAX(DATE(check_in_date)) - MIN(DATE(check_in_date)) + 1 FROM challenge_check_ins_recovered)::text || ' dias' as valor;

SELECT 
    'USUÁRIOS PRESERVADOS' as metrica,
    (SELECT COUNT(DISTINCT user_id) FROM challenge_check_ins_recovered) as valor;

-- 5.2 Próximos passos
SELECT '🎯 PRÓXIMOS PASSOS:' as categoria;
SELECT '1. ✅ Revisar relatório de recuperação acima' as passo;
SELECT '2. ✅ Confirmar aplicação do dataset recuperado' as passo;
SELECT '3. ✅ Executar script de aplicação (será gerado após confirmação)' as passo;
SELECT '4. ✅ Recalcular rankings e progresso' as passo;
SELECT '5. ✅ Validar funcionamento do sistema' as passo;

-- ================================================================
-- AVISO FINAL
-- ================================================================

SELECT '🚨 IMPORTANTE' as categoria;
SELECT 'Dataset recuperado criado na tabela temporária: challenge_check_ins_recovered' as info;
SELECT 'Execute a validação acima antes de aplicar as mudanças!' as aviso;
SELECT 'Este processo é IRREVERSÍVEL sem backup!' as alerta;

SELECT '🏁 ANÁLISE DE RECUPERAÇÃO CONCLUÍDA' as status; 