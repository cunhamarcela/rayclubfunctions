-- ================================================================
-- VERIFICAÇÃO COMPLETA DO STATUS DO SISTEMA ROBUSTO
-- Este script verifica tudo que já foi implementado e o que falta
-- ================================================================

\echo '🔍 VERIFICAÇÃO COMPLETA DO STATUS DO SISTEMA'
\echo '============================================='

-- ================================================================
-- 1. VERIFICAÇÃO DE FUNÇÕES CRÍTICAS
-- ================================================================

\echo ''
\echo '🔧 1. STATUS DAS FUNÇÕES PRINCIPAIS'

SELECT 
    'FUNÇÕES PRINCIPAIS' as categoria,
    func_name as nome_funcao,
    CASE 
        WHEN func_exists THEN '✅ IMPLEMENTADA'
        ELSE '❌ FALTANDO'
    END as status,
    CASE 
        WHEN func_exists THEN 'Pronta para uso'
        ELSE 'Precisa ser criada'
    END as observacao
FROM (
    VALUES 
        ('record_workout_basic'),
        ('record_challenge_check_in_robust'),
        ('detect_system_anomalies'),
        ('system_health_report'),
        ('to_brt'),
        ('cleanup_old_logs'),
        ('process_pending_queue'),
        ('update_system_metrics_trigger')
) AS required_functions(func_name)
LEFT JOIN (
    SELECT proname as function_name, TRUE as func_exists
    FROM pg_proc 
    WHERE proname IN (
        'record_workout_basic',
        'record_challenge_check_in_robust', 
        'detect_system_anomalies',
        'system_health_report',
        'to_brt',
        'cleanup_old_logs',
        'process_pending_queue',
        'update_system_metrics_trigger'
    )
) existing_funcs ON existing_funcs.function_name = required_functions.func_name
ORDER BY 
    CASE WHEN func_exists THEN 1 ELSE 0 END DESC,
    func_name;

-- ================================================================
-- 2. VERIFICAÇÃO DE TABELAS E ESTRUTURAS
-- ================================================================

\echo ''
\echo '🗃️ 2. STATUS DAS TABELAS DO SISTEMA'

SELECT 
    'TABELAS SISTEMA' as categoria,
    required_tables.table_name as nome_tabela,
    CASE 
        WHEN existing_tables.table_exists THEN '✅ EXISTE'
        ELSE '❌ FALTANDO'
    END as status,
    COALESCE(existing_tables.column_count::text, '0') as total_colunas,
    CASE 
        WHEN existing_tables.table_exists AND required_tables.table_name = 'workout_records' THEN 'Tabela principal'
        WHEN existing_tables.table_exists AND required_tables.table_name = 'challenge_check_ins' THEN 'Check-ins de challenges'
        WHEN existing_tables.table_exists AND required_tables.table_name = 'check_in_error_logs' THEN 'Sistema de logs'
        WHEN existing_tables.table_exists AND required_tables.table_name = 'workout_processing_queue' THEN 'Fila de processamento'
        WHEN existing_tables.table_exists AND required_tables.table_name = 'workout_system_metrics' THEN 'Métricas do sistema'
        WHEN existing_tables.table_exists THEN 'Implementada'
        ELSE 'Precisa ser criada'
    END as observacao
FROM (
    VALUES 
        ('workout_records'),
        ('challenge_check_ins'),
        ('check_in_error_logs'),
        ('workout_processing_queue'),
        ('workout_system_metrics'),
        ('profiles')
) AS required_tables(table_name)
LEFT JOIN (
    SELECT 
        t.table_name,
        TRUE as table_exists,
        COUNT(c.column_name) as column_count
    FROM information_schema.tables t
    LEFT JOIN information_schema.columns c ON c.table_name = t.table_name
    WHERE t.table_name IN (
        'workout_records',
        'challenge_check_ins', 
        'check_in_error_logs',
        'workout_processing_queue',
        'workout_system_metrics',
        'profiles'
    )
    GROUP BY t.table_name
) existing_tables ON existing_tables.table_name = required_tables.table_name
ORDER BY 
    CASE WHEN existing_tables.table_exists THEN 1 ELSE 0 END DESC,
    required_tables.table_name;

-- ================================================================
-- 3. VERIFICAÇÃO DAS COLUNAS CRÍTICAS
-- ================================================================

\echo ''
\echo '📋 3. STATUS DAS COLUNAS CRÍTICAS'

-- Verificar colunas da tabela check_in_error_logs
SELECT 
    'COLUNAS check_in_error_logs' as categoria,
    required_column as coluna,
    CASE 
        WHEN column_exists THEN '✅ EXISTE'
        ELSE '❌ FALTANDO'
    END as status,
    COALESCE(data_type, 'N/A') as tipo
FROM (
    VALUES 
        ('error_type'),
        ('error_detail'),
        ('status'),
        ('resolved_at'),
        ('request_data'),
        ('response_data'),
        ('user_id'),
        ('challenge_id'),
        ('workout_id')
) AS required_columns(required_column)
LEFT JOIN (
    SELECT column_name, TRUE as column_exists, data_type
    FROM information_schema.columns 
    WHERE table_name = 'check_in_error_logs'
) existing_columns ON existing_columns.column_name = required_columns.required_column

UNION ALL

-- Verificar colunas da tabela workout_processing_queue  
SELECT 
    'COLUNAS workout_processing_queue' as categoria,
    required_column as coluna,
    CASE 
        WHEN column_exists THEN '✅ EXISTE'
        ELSE '❌ FALTANDO'
    END as status,
    COALESCE(data_type, 'N/A') as tipo
FROM (
    VALUES 
        ('processed_for_ranking'),
        ('processed_for_dashboard'),
        ('retry_count'),
        ('max_retries'),
        ('next_retry_at'),
        ('processing_error')
) AS required_columns(required_column)
LEFT JOIN (
    SELECT column_name, TRUE as column_exists, data_type
    FROM information_schema.columns 
    WHERE table_name = 'workout_processing_queue'
) existing_columns ON existing_columns.column_name = required_columns.required_column
ORDER BY categoria, coluna;

-- ================================================================
-- 4. VERIFICAÇÃO DE ÍNDICES DE PERFORMANCE
-- ================================================================

\echo ''
\echo '⚡ 4. STATUS DOS ÍNDICES DE PERFORMANCE'

SELECT 
    'ÍNDICES SISTEMA' as categoria,
    index_name as nome_indice,
    CASE 
        WHEN index_exists THEN '✅ CRIADO'
        ELSE '❌ FALTANDO'
    END as status,
    COALESCE(table_name, 'N/A') as tabela,
    CASE 
        WHEN index_name LIKE '%user%' THEN 'Performance por usuário'
        WHEN index_name LIKE '%date%' THEN 'Performance por data'
        WHEN index_name LIKE '%error%' THEN 'Performance logs'
        WHEN index_name LIKE '%pending%' THEN 'Performance fila'
        WHEN index_name LIKE '%unique%' THEN 'Proteção duplicatas'
        ELSE 'Performance geral'
    END as finalidade
FROM (
    VALUES 
        ('idx_checkin_error_logs_user_date'),
        ('idx_checkin_error_logs_status'),
        ('idx_checkin_error_logs_error_type'),
        ('idx_workout_queue_pending'),
        ('idx_workout_metrics_name_date'),
        ('idx_unique_user_challenge_date_brt'),
        ('idx_workout_records_user_date')
) AS required_indexes(index_name)
LEFT JOIN (
    SELECT indexname, TRUE as index_exists, tablename as table_name
    FROM pg_indexes 
    WHERE indexname IN (
        'idx_checkin_error_logs_user_date',
        'idx_checkin_error_logs_status',
        'idx_checkin_error_logs_error_type',
        'idx_workout_queue_pending',
        'idx_workout_metrics_name_date',
        'idx_unique_user_challenge_date_brt',
        'idx_workout_records_user_date'
    )
) existing_indexes ON existing_indexes.indexname = required_indexes.index_name
ORDER BY 
    CASE WHEN index_exists THEN 1 ELSE 0 END DESC,
    index_name;

-- ================================================================
-- 5. VERIFICAÇÃO DE TRIGGERS E CONSTRAINTS
-- ================================================================

\echo ''
\echo '🛡️ 5. STATUS DE TRIGGERS E PROTEÇÕES'

-- Verificar triggers
SELECT 
    'TRIGGERS' as categoria,
    trigger_name,
    '✅ ATIVO' as status,
    event_object_table as tabela,
    'Trigger funcionando' as observacao
FROM information_schema.triggers 
WHERE trigger_name LIKE '%workout%' OR trigger_name LIKE '%metric%'

UNION ALL

-- Verificar constraints importantes
SELECT 
    'CONSTRAINTS' as categoria,
    constraint_name,
    '✅ ATIVA' as status,
    table_name as tabela,
    constraint_type as observacao
FROM information_schema.table_constraints 
WHERE table_name IN ('workout_records', 'challenge_check_ins', 'check_in_error_logs')
AND constraint_type IN ('UNIQUE', 'PRIMARY KEY', 'FOREIGN KEY')
ORDER BY 1, 2;

-- ================================================================
-- 6. TESTE FUNCIONAL BÁSICO
-- ================================================================

\echo ''
\echo '🧪 6. TESTES FUNCIONAIS BÁSICOS'

-- Testar função to_brt
SELECT 
    'TESTE FUNCIONAL' as categoria,
    'to_brt' as funcao,
    CASE 
        WHEN to_brt(NOW()) IS NOT NULL THEN '✅ FUNCIONANDO'
        ELSE '❌ ERRO'
    END as status,
    'Conversão timezone' as finalidade
WHERE EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'to_brt')

UNION ALL

-- Testar existência das outras funções principais
SELECT 
    'TESTE FUNCIONAL' as categoria,
    proname as funcao,
    '✅ DISPONÍVEL' as status,
    'Função implementada' as finalidade
FROM pg_proc 
WHERE proname IN ('detect_system_anomalies', 'system_health_report', 'record_workout_basic')

UNION ALL

-- Verificar se há dados de teste/erro recentes
SELECT 
    'TESTE DADOS' as categoria,
    'check_in_error_logs' as funcao,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ REGISTROS (' || COUNT(*) || ')'
        ELSE '⚠️ SEM DADOS'
    END as status,
    'Logs de sistema' as finalidade
FROM check_in_error_logs 
WHERE created_at > NOW() - INTERVAL '24 hours'
AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'check_in_error_logs')

ORDER BY categoria, funcao;

-- ================================================================
-- 7. RESUMO EXECUTIVO
-- ================================================================

\echo ''
\echo '📊 7. RESUMO EXECUTIVO DO SISTEMA'

WITH system_metrics AS (
    SELECT 
        -- Contar funções implementadas
        (SELECT COUNT(*) FROM pg_proc 
         WHERE proname IN ('record_workout_basic', 'detect_system_anomalies', 'system_health_report', 'to_brt')) as funcoes_criadas,
        
        -- Contar tabelas existentes
        (SELECT COUNT(*) FROM information_schema.tables 
         WHERE table_name IN ('check_in_error_logs', 'workout_processing_queue', 'workout_system_metrics')) as tabelas_criadas,
         
        -- Contar índices criados
        (SELECT COUNT(*) FROM pg_indexes 
         WHERE indexname LIKE 'idx_%' 
         AND tablename IN ('check_in_error_logs', 'workout_processing_queue', 'workout_records')) as indices_criados,
         
        -- Contar colunas críticas existentes
        (SELECT COUNT(*) FROM information_schema.columns 
         WHERE table_name = 'check_in_error_logs' 
         AND column_name IN ('error_type', 'error_detail', 'status', 'resolved_at')) as colunas_logs,
         
        (SELECT COUNT(*) FROM information_schema.columns 
         WHERE table_name = 'workout_processing_queue' 
         AND column_name IN ('processed_for_dashboard', 'retry_count', 'max_retries')) as colunas_queue
)
SELECT 
    'RESUMO GERAL' as categoria,
    componente,
    atual || '/' || esperado as progresso,
    CASE 
        WHEN atual = esperado THEN '✅ COMPLETO'
        WHEN atual >= (esperado * 0.8) THEN '🟡 QUASE PRONTO'
        WHEN atual > 0 THEN '🟠 EM PROGRESSO' 
        ELSE '❌ NÃO INICIADO'
    END as status
FROM (
    SELECT 'Funções Principais' as componente, funcoes_criadas as atual, 4 as esperado FROM system_metrics
    UNION ALL
    SELECT 'Tabelas Sistema' as componente, tabelas_criadas as atual, 3 as esperado FROM system_metrics  
    UNION ALL
    SELECT 'Índices Performance' as componente, indices_criados as atual, 6 as esperado FROM system_metrics
    UNION ALL
    SELECT 'Colunas Logs' as componente, colunas_logs as atual, 4 as esperado FROM system_metrics
    UNION ALL
    SELECT 'Colunas Queue' as componente, colunas_queue as atual, 3 as esperado FROM system_metrics
) progress_data
ORDER BY 
    CASE 
        WHEN progress_data.atual = progress_data.esperado THEN 1
        WHEN progress_data.atual >= (progress_data.esperado * 0.8) THEN 2  
        WHEN progress_data.atual > 0 THEN 3
        ELSE 4
    END;

-- ================================================================
-- 8. RECOMENDAÇÕES DE PRÓXIMOS PASSOS
-- ================================================================

\echo ''
\echo '🎯 8. PRÓXIMOS PASSOS RECOMENDADOS'

-- Identificar o que precisa ser feito
WITH missing_components AS (
    SELECT 
        'FALTANDO' as tipo,
        'Função: ' || func_name as componente,
        'Execute: \\i final_robust_sql_functions.sql' as acao_recomendada
    FROM (
        VALUES ('record_workout_basic'), ('detect_system_anomalies'), ('system_health_report'), ('to_brt')
    ) AS required_functions(func_name)
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = required_functions.func_name
    )
    
    UNION ALL
    
    SELECT 
        'FALTANDO' as tipo,
        'Tabela: ' || table_name as componente,
        'Execute: \\i fix_table_structure.sql' as acao_recomendada
    FROM (
        VALUES ('check_in_error_logs'), ('workout_processing_queue'), ('workout_system_metrics')
    ) AS required_tables(table_name)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.tables WHERE table_name = required_tables.table_name
    )
    
    UNION ALL
    
    SELECT 
        'RECOMENDADO' as tipo,
        'Verificação completa' as componente,
        'Execute: \\i diagnostic_system_status.sql' as acao_recomendada
        
    UNION ALL
    
    SELECT 
        'RECOMENDADO' as tipo,
        'Implementação completa' as componente,
        'Execute: \\i execute_with_results.sql' as acao_recomendada
)
SELECT 
    tipo,
    componente,
    acao_recomendada
FROM missing_components
ORDER BY 
    CASE WHEN tipo = 'FALTANDO' THEN 1 ELSE 2 END,
    componente;

\echo ''
\echo '✅ VERIFICAÇÃO COMPLETA CONCLUÍDA!'
\echo 'Analise os resultados acima para identificar próximos passos.' 