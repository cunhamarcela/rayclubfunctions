-- ================================================================
-- VERIFICAÇÃO DE BACKUPS E HISTÓRICO NO SUPABASE
-- ================================================================
-- Este script investiga possíveis backups, logs e histórico de dados
-- para entender se treinos foram realmente perdidos ou apenas mal referenciados
-- ================================================================

SELECT '🔍 VERIFICANDO BACKUPS E HISTÓRICO NO SUPABASE' as status;

-- ================================================================
-- PARTE 1: VERIFICAR BACKUPS EXISTENTES
-- ================================================================

SELECT '💾 VERIFICANDO BACKUPS EXISTENTES' as secao;

-- 1.1 Listar TODAS as tabelas para identificar possíveis backups
SELECT 
    '📋 TODAS AS TABELAS NO BANCO' as categoria,
    schemaname,
    tablename,
    tableowner,
    (SELECT pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))) as tamanho,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = tablename) as colunas
FROM pg_tables 
WHERE schemaname IN ('public', 'backup', 'archive', 'history')
   OR tablename ILIKE '%backup%' 
   OR tablename ILIKE '%archive%'
   OR tablename ILIKE '%history%'
   OR tablename ILIKE '%audit%'
   OR tablename ILIKE '%log%'
ORDER BY schemaname, tablename;

-- 1.2 Verificar views que podem conter dados históricos
SELECT 
    '👁️ VIEWS EXISTENTES' as categoria,
    schemaname,
    viewname,
    viewowner
FROM pg_views 
WHERE schemaname = 'public'
   OR viewname ILIKE '%backup%' 
   OR viewname ILIKE '%history%'
   OR viewname ILIKE '%workout%'
   OR viewname ILIKE '%challenge%'
ORDER BY schemaname, viewname;

-- ================================================================
-- PARTE 2: INVESTIGAR POSSÍVEIS DADOS PERDIDOS
-- ================================================================

SELECT '🔍 INVESTIGANDO POSSÍVEIS DADOS PERDIDOS' as secao;

-- 2.1 Verificar se há lacunas significativas nos IDs sequenciais
SELECT 
    '🔢 ANÁLISE DE LACUNAS NOS IDs' as categoria,
    'workout_records' as tabela,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro,
    COUNT(*) as total_registros,
    (SELECT COUNT(*) FROM workout_records WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as registros_ultimos_30_dias
FROM workout_records;

SELECT 
    '🔢 ANÁLISE DE LACUNAS NOS IDs' as categoria,
    'challenge_check_ins' as tabela,
    MIN(created_at) as primeiro_registro,
    MAX(created_at) as ultimo_registro,
    COUNT(*) as total_registros,
    (SELECT COUNT(*) FROM challenge_check_ins WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as registros_ultimos_30_dias
FROM challenge_check_ins;

-- 2.2 Verificar distribuição temporal para identificar períodos com poucos dados
WITH daily_counts AS (
    SELECT 
        DATE(created_at) as data,
        COUNT(*) as workout_records_count,
        COUNT(DISTINCT user_id) as usuarios_ativos
    FROM workout_records
    WHERE created_at >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY DATE(created_at)
),
expected_range AS (
    SELECT generate_series(
        CURRENT_DATE - INTERVAL '90 days',
        CURRENT_DATE,
        INTERVAL '1 day'
    )::date as data
)
SELECT 
    '📅 ANÁLISE TEMPORAL - WORKOUT RECORDS' as categoria,
    er.data,
    COALESCE(dc.workout_records_count, 0) as treinos_do_dia,
    COALESCE(dc.usuarios_ativos, 0) as usuarios_ativos,
    CASE 
        WHEN dc.workout_records_count IS NULL THEN 'DIA SEM DADOS ⚠️'
        WHEN dc.workout_records_count < 5 THEN 'POUCOS DADOS ⚠️'
        ELSE 'NORMAL ✅'
    END as status
FROM expected_range er
LEFT JOIN daily_counts dc ON er.data = dc.data
WHERE er.data >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY er.data DESC;

-- ================================================================
-- PARTE 3: VERIFICAR LOGS DO SISTEMA
-- ================================================================

SELECT '📝 VERIFICANDO LOGS DO SISTEMA' as secao;

-- 3.1 Verificar se existe tabela de audit/log geral
DO $$
DECLARE
    table_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name IN ('audit_log', 'system_log', 'activity_log')
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '✅ Tabelas de log encontradas';
    ELSE
        RAISE NOTICE 'ℹ️ Nenhuma tabela de log geral encontrada';
    END IF;
END $$;

-- 3.2 Verificar logs de erro mais antigos para entender histórico
SELECT 
    '📊 HISTÓRICO DE ERROS' as categoria,
    DATE(created_at) as data,
    status,
    COUNT(*) as total_erros,
    COUNT(DISTINCT user_id) as usuarios_afetados
FROM check_in_error_logs
WHERE created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE(created_at), status
ORDER BY data DESC, total_erros DESC
LIMIT 20;

-- ================================================================
-- PARTE 4: VERIFICAR POSSÍVEIS SOFT DELETES
-- ================================================================

SELECT '🗑️ VERIFICANDO POSSÍVEIS SOFT DELETES' as secao;

-- 4.1 Verificar se existem colunas de soft delete
SELECT 
    '🔍 COLUNAS DE SOFT DELETE' as categoria,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('workout_records', 'challenge_check_ins', 'challenge_progress')
  AND (column_name ILIKE '%deleted%' 
       OR column_name ILIKE '%removed%' 
       OR column_name ILIKE '%active%'
       OR column_name ILIKE '%status%')
ORDER BY table_name, column_name;

-- 4.2 Se existe soft delete, verificar registros "deletados"
DO $$
DECLARE
    rec RECORD;
    query_text TEXT;
BEGIN
    -- Verificar workout_records
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'deleted_at') THEN
        SELECT COUNT(*) FROM workout_records WHERE deleted_at IS NOT NULL;
        RAISE NOTICE 'workout_records com deleted_at: %', FOUND;
    END IF;
    
    -- Verificar challenge_check_ins
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_check_ins' AND column_name = 'deleted_at') THEN
        SELECT COUNT(*) FROM challenge_check_ins WHERE deleted_at IS NOT NULL;
        RAISE NOTICE 'challenge_check_ins com deleted_at: %', FOUND;
    END IF;
END $$;

-- ================================================================
-- PARTE 5: COMPARAR WORKOUT_RECORDS vs CHALLENGE_CHECK_INS
-- ================================================================

SELECT '🔗 COMPARANDO WORKOUT_RECORDS vs CHALLENGE_CHECK_INS' as secao;

-- 5.1 Verificar workout_records que deveriam ter check-ins mas não têm
WITH workout_com_challenge AS (
    SELECT 
        wr.*,
        CASE 
            WHEN wr.challenge_id IS NOT NULL THEN 'TEM CHALLENGE'
            ELSE 'SEM CHALLENGE'
        END as tem_challenge,
        cci.id as checkin_id
    FROM workout_records wr
    LEFT JOIN challenge_check_ins cci ON (
        cci.user_id = wr.user_id 
        AND cci.challenge_id = wr.challenge_id
        AND DATE(cci.check_in_date) = DATE(wr.date)
    )
    WHERE wr.created_at >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT 
    '⚠️ WORKOUT RECORDS SEM CHECK-IN CORRESPONDENTE' as problema,
    tem_challenge,
    COUNT(*) as total_workout_records,
    COUNT(*) FILTER (WHERE checkin_id IS NULL) as sem_checkin,
    COUNT(*) FILTER (WHERE checkin_id IS NOT NULL) as com_checkin,
    ROUND(
        COUNT(*) FILTER (WHERE checkin_id IS NULL) * 100.0 / COUNT(*), 
        2
    ) as percentual_sem_checkin
FROM workout_com_challenge
GROUP BY tem_challenge;

-- 5.2 Verificar check-ins órfãos (sem workout_record correspondente)
SELECT 
    '⚠️ CHECK-INS SEM WORKOUT_RECORD CORRESPONDENTE' as problema,
    COUNT(*) as total_checkins_orfaos,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    MIN(created_at) as mais_antigo,
    MAX(created_at) as mais_recente
FROM challenge_check_ins cci
WHERE NOT EXISTS (
    SELECT 1 FROM workout_records wr 
    WHERE wr.user_id = cci.user_id 
    AND wr.challenge_id = cci.challenge_id
    AND DATE(wr.date) = DATE(cci.check_in_date)
);

-- ================================================================
-- PARTE 6: VERIFICAR OPERAÇÕES RECENTES DE MANUTENÇÃO
-- ================================================================

SELECT '🔧 VERIFICANDO OPERAÇÕES DE MANUTENÇÃO RECENTES' as secao;

-- 6.1 Verificar se há logs de operações de correção anteriores
SELECT 
    '📋 LOGS DE CORREÇÕES ANTERIORES' as categoria,
    error_message,
    status,
    COUNT(*) as ocorrencias,
    MIN(created_at) as primeiro,
    MAX(created_at) as ultimo
FROM check_in_error_logs
WHERE error_message ILIKE '%correção%' 
   OR error_message ILIKE '%fix%'
   OR error_message ILIKE '%backup%'
   OR error_message ILIKE '%limpeza%'
   OR error_message ILIKE '%cleanup%'
   OR status IN ('cleanup_success', 'system_fix_completed')
GROUP BY error_message, status
ORDER BY ultimo DESC;

-- 6.2 Verificar se há padrões temporais suspeitos (possíveis limpezas)
WITH daily_changes AS (
    SELECT 
        DATE(created_at) as data,
        COUNT(*) as checkins_criados,
        LAG(COUNT(*)) OVER (ORDER BY DATE(created_at)) as checkins_dia_anterior
    FROM challenge_check_ins
    WHERE created_at >= CURRENT_DATE - INTERVAL '60 days'
    GROUP BY DATE(created_at)
)
SELECT 
    '📊 MUDANÇAS DRÁSTICAS NOS CHECK-INS' as categoria,
    data,
    checkins_criados,
    checkins_dia_anterior,
    checkins_criados - COALESCE(checkins_dia_anterior, 0) as diferenca,
    CASE 
        WHEN checkins_dia_anterior > 0 THEN 
            ROUND((checkins_criados - checkins_dia_anterior) * 100.0 / checkins_dia_anterior, 1)
        ELSE NULL
    END as percentual_mudanca
FROM daily_changes
WHERE ABS(checkins_criados - COALESCE(checkins_dia_anterior, 0)) > 50
   OR (checkins_dia_anterior > 0 AND ABS(checkins_criados - checkins_dia_anterior) * 100.0 / checkins_dia_anterior > 50)
ORDER BY data DESC;

-- ================================================================
-- PARTE 7: VERIFICAR INTEGRIDADE DE DADOS ESPECÍFICOS
-- ================================================================

SELECT '🔍 VERIFICANDO INTEGRIDADE DE DADOS ESPECÍFICOS' as secao;

-- 7.1 Verificar se há workout_records com timestamps suspeitos
SELECT 
    '⏰ WORKOUT RECORDS COM TIMESTAMPS SUSPEITOS' as categoria,
    DATE(created_at) as data_criacao,
    DATE(date) as data_treino,
    COUNT(*) as quantidade,
    COUNT(*) FILTER (WHERE date > created_at + INTERVAL '1 day') as treinos_futuro,
    COUNT(*) FILTER (WHERE created_at - date > INTERVAL '30 days') as criados_muito_depois
FROM workout_records
WHERE created_at >= CURRENT_DATE - INTERVAL '60 days'
GROUP BY DATE(created_at), DATE(date)
HAVING COUNT(*) FILTER (WHERE date > created_at + INTERVAL '1 day') > 0
    OR COUNT(*) FILTER (WHERE created_at - date > INTERVAL '30 days') > 0
ORDER BY data_criacao DESC
LIMIT 10;

-- 7.2 Verificar workout_records com challenge_id null mas que poderiam ter
SELECT 
    '🎯 WORKOUT RECORDS QUE PODERIAM TER CHALLENGE_ID' as categoria,
    DATE(wr.created_at) as data,
    COUNT(*) as workout_sem_challenge,
    COUNT(DISTINCT wr.user_id) as usuarios_diferentes,
    (SELECT COUNT(*) FROM challenges c WHERE c.active = true 
     AND wr.created_at BETWEEN c.start_date AND c.end_date) as challenges_ativos_na_epoca
FROM workout_records wr
WHERE wr.challenge_id IS NULL
  AND wr.created_at >= CURRENT_DATE - INTERVAL '30 days'
  AND EXISTS (
      SELECT 1 FROM challenges c 
      WHERE c.active = true 
      AND wr.created_at BETWEEN c.start_date AND c.end_date
  )
GROUP BY DATE(wr.created_at)
ORDER BY data DESC
LIMIT 10;

-- ================================================================
-- PARTE 8: RESUMO EXECUTIVO DA INVESTIGAÇÃO
-- ================================================================

SELECT '📋 RESUMO EXECUTIVO DA INVESTIGAÇÃO DE BACKUPS' as titulo;

-- 8.1 Contar possíveis dados perdidos
SELECT 
    '📊 POSSÍVEIS DADOS PERDIDOS' as categoria,
    (SELECT COUNT(*) FROM workout_records WHERE challenge_id IS NULL) as workout_sem_challenge,
    (SELECT COUNT(*) FROM challenge_check_ins cci 
     WHERE NOT EXISTS (
         SELECT 1 FROM workout_records wr 
         WHERE wr.user_id = cci.user_id 
         AND wr.challenge_id = cci.challenge_id
         AND DATE(wr.date) = DATE(cci.check_in_date)
     )) as checkins_orfaos;

-- 8.2 Recomendações finais
SELECT '💡 RECOMENDAÇÕES BASEADAS NA INVESTIGAÇÃO:' as categoria;
SELECT '1. ✅ Verificar se workout_records órfãos podem ser associados a challenges' as recomendacao;
SELECT '2. ✅ Investigar check-ins órfãos - podem indicar dados perdidos' as recomendacao;
SELECT '3. ✅ Criar backup COMPLETO antes de qualquer correção' as recomendacao;
SELECT '4. ✅ Verificar logs de operações anteriores para entender histórico' as recomendacao;

SELECT '🏁 INVESTIGAÇÃO DE BACKUPS CONCLUÍDA' as status; 