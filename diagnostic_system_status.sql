-- ================================================================
-- DIAGNÓSTICO DO SISTEMA COM RESULTADOS EM SELECT
-- Este script mostra o status atual usando queries que retornam dados
-- ================================================================

\echo '🔍 DIAGNÓSTICO COMPLETO DO SISTEMA DE TREINOS'
\echo '=============================================='

-- ================================================================
-- 1. FUNÇÕES CRÍTICAS DO SISTEMA
-- ================================================================

\echo ''
\echo '📋 1. VERIFICAÇÃO DE FUNÇÕES CRÍTICAS'

SELECT 
    'FUNÇÕES CRÍTICAS' as categoria,
    proname as funcao,
    pg_get_function_identity_arguments(oid) as argumentos,
    CASE 
        WHEN proname = 'record_workout_basic' THEN '🎯 Principal'
        WHEN proname = 'detect_system_anomalies' THEN '🚨 Monitoramento'
        WHEN proname = 'system_health_report' THEN '📊 Relatórios'
        ELSE '🔧 Auxiliar'
    END as tipo,
    '✅ OK' as status
FROM pg_proc 
WHERE proname IN (
    'record_workout_basic', 
    'detect_system_anomalies', 
    'system_health_report',
    'to_brt',
    'cleanup_old_logs',
    'process_pending_queue'
)
ORDER BY proname;

-- ================================================================
-- 2. ESTRUTURAS DE DADOS E TABELAS
-- ================================================================

\echo ''
\echo '🗃️ 2. VERIFICAÇÃO DE TABELAS E ESTRUTURAS'

SELECT 
    'TABELAS' as categoria,
    table_name as nome,
    CASE 
        WHEN table_name = 'workout_records' THEN '💪 Principal'
        WHEN table_name = 'challenge_check_ins' THEN '🏆 Check-ins'
        WHEN table_name = 'check_in_error_logs' THEN '📝 Logs'
        WHEN table_name = 'workout_processing_queue' THEN '⚡ Fila'
        WHEN table_name = 'workout_system_metrics' THEN '📊 Métricas'
        ELSE '📋 Auxiliar'
    END as tipo,
    CASE 
        WHEN table_type = 'BASE TABLE' THEN '✅ Tabela'
        WHEN table_type = 'VIEW' THEN '👀 View'
        ELSE table_type
    END as status
FROM information_schema.tables 
WHERE table_name IN (
    'workout_records',
    'challenge_check_ins', 
    'check_in_error_logs',
    'workout_processing_queue',
    'workout_system_metrics'
)
ORDER BY table_name;

-- ================================================================
-- 3. CONSTRAINTS E PROTEÇÕES
-- ================================================================

\echo ''
\echo '🛡️ 3. VERIFICAÇÃO DE CONSTRAINTS E PROTEÇÕES'

SELECT 
    'CONSTRAINTS' as categoria,
    table_name as tabela,
    constraint_name as nome,
    constraint_type as tipo,
    CASE 
        WHEN constraint_name LIKE '%unique%' THEN '🔒 Anti-Duplicata'
        WHEN constraint_name LIKE '%foreign%' THEN '🔗 Integridade'
        WHEN constraint_name LIKE '%primary%' THEN '🔑 Chave Primária'
        ELSE '🛡️ Proteção'
    END as funcao,
    '✅ Ativa' as status
FROM information_schema.table_constraints 
WHERE table_name IN ('workout_records', 'challenge_check_ins', 'check_in_error_logs')
ORDER BY table_name, constraint_type;

-- ================================================================
-- 4. ÍNDICES DE PERFORMANCE
-- ================================================================

\echo ''
\echo '⚡ 4. VERIFICAÇÃO DE ÍNDICES DE PERFORMANCE'

SELECT 
    'ÍNDICES' as categoria,
    schemaname as schema,
    tablename as tabela,
    indexname as nome,
    CASE 
        WHEN indexname LIKE '%user%' THEN '👤 Por Usuário'
        WHEN indexname LIKE '%date%' THEN '📅 Por Data'
        WHEN indexname LIKE '%error%' THEN '🚨 Para Logs'
        ELSE '🔍 Busca Geral'
    END as funcao,
    '✅ Ativo' as status
FROM pg_indexes 
WHERE tablename IN ('workout_records', 'challenge_check_ins', 'check_in_error_logs')
ORDER BY tablename, indexname;

-- ================================================================
-- 5. DETECÇÃO DE DUPLICATAS (ÚLTIMAS 24H)
-- ================================================================

\echo ''
\echo '🔍 5. DETECÇÃO DE DUPLICATAS NAS ÚLTIMAS 24H'

-- Duplicatas em workout_records
SELECT 
    'DUPLICATAS WORKOUT' as categoria,
    user_id,
    workout_name,
    workout_type,
    DATE(date) as data_treino,
    COUNT(*) as total_duplicatas,
    ARRAY_AGG(id ORDER BY created_at) as ids_registros,
    '❌ Duplicata Detectada' as status
FROM workout_records 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY user_id, workout_name, workout_type, DATE(date)
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- Duplicatas em challenge_check_ins
SELECT 
    'DUPLICATAS CHECK-IN' as categoria,
    user_id,
    challenge_id,
    DATE(check_in_date) as data_checkin,
    COUNT(*) as total_duplicatas,
    ARRAY_AGG(id ORDER BY created_at) as ids_registros,
    '❌ Duplicata Detectada' as status
FROM challenge_check_ins 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY user_id, challenge_id, DATE(check_in_date)
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ================================================================
-- 6. ANÁLISE DE ERROS RECENTES
-- ================================================================

\echo ''
\echo '🚨 6. ANÁLISE DE ERROS DAS ÚLTIMAS 24H'

SELECT 
    'ERROS SISTEMA' as categoria,
    error_type as tipo_erro,
    status as status_erro,
    COUNT(*) as total_ocorrencias,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    MAX(created_at) as ultimo_erro,
    CASE 
        WHEN COUNT(*) > 100 THEN '🔴 Crítico'
        WHEN COUNT(*) > 20 THEN '🟡 Alto'
        WHEN COUNT(*) > 5 THEN '🟠 Médio'
        ELSE '🟢 Baixo'
    END as severidade
FROM check_in_error_logs 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY error_type, status
ORDER BY COUNT(*) DESC;

-- ================================================================
-- 7. STATUS DA FILA DE PROCESSAMENTO
-- ================================================================

\echo ''
\echo '📋 7. STATUS DA FILA DE PROCESSAMENTO'

SELECT 
    'FILA PROCESSAMENTO' as categoria,
    CASE 
        WHEN processed_for_ranking = FALSE AND processed_for_dashboard = FALSE THEN 'Pendente Completo'
        WHEN processed_for_ranking = FALSE THEN 'Pendente Ranking'
        WHEN processed_for_dashboard = FALSE THEN 'Pendente Dashboard'
        ELSE 'Processado'
    END as status_processamento,
    COUNT(*) as total_itens,
    COUNT(*) FILTER (WHERE processing_error IS NOT NULL) as com_erro,
    AVG(EXTRACT(EPOCH FROM (NOW() - created_at))/60)::INTEGER as tempo_medio_minutos,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Vazio'
        WHEN COUNT(*) < 10 THEN '🟢 Normal'
        WHEN COUNT(*) < 50 THEN '🟡 Moderado'
        ELSE '🔴 Crítico'
    END as nivel_alerta
FROM workout_processing_queue 
GROUP BY processed_for_ranking, processed_for_dashboard
ORDER BY COUNT(*) DESC;

-- ================================================================
-- 8. MÉTRICAS DE PERFORMANCE (ÚLTIMAS 24H)
-- ================================================================

\echo ''
\echo '📊 8. MÉTRICAS DE PERFORMANCE DAS ÚLTIMAS 24H'

SELECT 
    'MÉTRICAS WORKOUT' as categoria,
    DATE(created_at) as data,
    COUNT(*) as total_workouts,
    COUNT(DISTINCT user_id) as usuarios_ativos,
    COUNT(*) FILTER (WHERE challenge_id IS NOT NULL) as com_challenge,
    ROUND(AVG(duration_minutes), 1) as duracao_media_min,
    COUNT(*) FILTER (WHERE duration_minutes >= 45) as treinos_validos,
    CASE 
        WHEN COUNT(*) > 500 THEN '🟢 Alto Volume'
        WHEN COUNT(*) > 100 THEN '🟡 Volume Normal'
        ELSE '🔴 Volume Baixo'
    END as nivel_atividade
FROM workout_records 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY DATE(created_at)
ORDER BY data DESC;

-- ================================================================
-- 9. RESUMO EXECUTIVO DO SISTEMA
-- ================================================================

\echo ''
\echo '📋 9. RESUMO EXECUTIVO DO SISTEMA'

WITH system_summary AS (
    SELECT 
        (SELECT COUNT(*) FROM pg_proc WHERE proname IN ('record_workout_basic', 'detect_system_anomalies', 'system_health_report')) as funcoes_criticas,
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('check_in_error_logs', 'workout_processing_queue')) as tabelas_monitoramento,
        (SELECT COUNT(*) FROM (
            SELECT user_id, workout_name, workout_type, DATE(date)
            FROM workout_records 
            WHERE created_at > NOW() - INTERVAL '24 hours'
            GROUP BY user_id, workout_name, workout_type, DATE(date)
            HAVING COUNT(*) > 1
        ) dup) as duplicatas_24h,
        (SELECT COUNT(*) FROM check_in_error_logs WHERE created_at > NOW() - INTERVAL '1 hour' AND status = 'error') as erros_1h,
        (SELECT COUNT(*) FROM workout_processing_queue WHERE processed_for_ranking = FALSE OR processed_for_dashboard = FALSE) as fila_pendente
)
SELECT 
    'RESUMO SISTEMA' as categoria,
    'Funções Críticas' as componente,
    funcoes_criticas as valor,
    CASE WHEN funcoes_criticas >= 3 THEN '✅ OK' ELSE '❌ Incompleto' END as status
FROM system_summary

UNION ALL

SELECT 
    'RESUMO SISTEMA',
    'Tabelas Monitoramento',
    tabelas_monitoramento,
    CASE WHEN tabelas_monitoramento >= 2 THEN '✅ OK' ELSE '❌ Incompleto' END
FROM system_summary

UNION ALL

SELECT 
    'RESUMO SISTEMA',
    'Duplicatas (24h)',
    duplicatas_24h,
    CASE WHEN duplicatas_24h = 0 THEN '✅ Zero' ELSE '❌ Detectadas' END
FROM system_summary

UNION ALL

SELECT 
    'RESUMO SISTEMA',
    'Erros (1h)',
    erros_1h,
    CASE WHEN erros_1h < 5 THEN '✅ Baixo' WHEN erros_1h < 20 THEN '🟡 Moderado' ELSE '❌ Alto' END
FROM system_summary

UNION ALL

SELECT 
    'RESUMO SISTEMA',
    'Fila Pendente',
    fila_pendente,
    CASE WHEN fila_pendente < 10 THEN '✅ Normal' WHEN fila_pendente < 50 THEN '🟡 Moderado' ELSE '❌ Crítico' END
FROM system_summary;

-- ================================================================
-- 10. COMANDOS ÚTEIS PARA MONITORAMENTO
-- ================================================================

\echo ''
\echo '🔧 10. COMANDOS ÚTEIS PARA MONITORAMENTO DIÁRIO'

SELECT 
    'COMANDOS ÚTEIS' as categoria,
    comando,
    descricao,
    frequencia_uso
FROM (
    VALUES 
        ('SELECT * FROM detect_system_anomalies();', 'Detectar anomalias do sistema', 'Diário'),
        ('SELECT * FROM system_health_report();', 'Relatório completo de saúde', 'Diário'),
        ('SELECT process_pending_queue();', 'Processar fila pendente', 'Conforme necessário'),
        ('SELECT cleanup_old_logs(30);', 'Limpar logs antigos (30 dias)', 'Semanal'),
        ('\i diagnostic_system_status.sql', 'Diagnóstico completo (este script)', 'Diário/Conforme necessário')
) as commands(comando, descricao, frequencia_uso);

\echo ''
\echo '✅ DIAGNÓSTICO CONCLUÍDO!'
\echo 'Analise os resultados acima para identificar possíveis problemas.' 