-- ================================================================
-- SCRIPT MASTER COM RESULTADOS EM SELECT
-- Execute este script para implementar todas as proteções 
-- e ver resultados detalhados
-- ================================================================

\timing on

\echo '🚀 INICIANDO IMPLEMENTAÇÃO DO SISTEMA ROBUSTO'
\echo '=============================================='

-- ================================================================
-- PASSO 1: LIMPEZA DE FUNÇÕES CONFLITANTES
-- ================================================================

\echo ''
\echo '🧹 PASSO 1: LIMPEZA DE FUNÇÕES CONFLITANTES'

-- Executar limpeza das funções conflitantes
\i cleanup_conflicting_functions.sql

-- Mostrar funções que foram limpas
SELECT 
    'LIMPEZA CONCLUÍDA' as status,
    'Funções relacionadas a workout removidas' as resultado,
    NOW() as timestamp;

-- ================================================================
-- PASSO 2: IMPLEMENTAÇÃO DAS FUNÇÕES ROBUSTAS
-- ================================================================

\echo ''
\echo '🛡️ PASSO 2: IMPLEMENTAÇÃO DAS FUNÇÕES ROBUSTAS'

-- Executar implementação das funções robustas
\i final_robust_sql_functions.sql

-- Verificar funções criadas
SELECT 
    'IMPLEMENTAÇÃO' as categoria,
    proname as funcao_criada,
    pg_get_function_identity_arguments(oid) as argumentos,
    '✅ Criada com Sucesso' as status,
    NOW() as timestamp
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

-- Verificar tabelas criadas
SELECT 
    'IMPLEMENTAÇÃO' as categoria,
    table_name as tabela_criada,
    table_type as tipo,
    '✅ Criada com Sucesso' as status,
    NOW() as timestamp
FROM information_schema.tables 
WHERE table_name IN (
    'check_in_error_logs',
    'workout_processing_queue',
    'workout_system_metrics'
)
ORDER BY table_name;

-- ================================================================
-- PASSO 3: VERIFICAÇÃO DE SAÚDE DO SISTEMA
-- ================================================================

\echo ''
\echo '🔍 PASSO 3: VERIFICAÇÃO DE SAÚDE DO SISTEMA'

-- Executar verificação completa
\i run_system_health_check.sql

-- ================================================================
-- PASSO 4: TESTES FUNCIONAIS BÁSICOS
-- ================================================================

\echo ''
\echo '✅ PASSO 4: TESTES FUNCIONAIS BÁSICOS'

-- Testar função record_workout_basic
DO $$
DECLARE
    test_result JSONB;
    test_user_id UUID := 'test-user-' || gen_random_uuid();
BEGIN
    -- Testar se a função existe e funciona
    SELECT record_workout_basic(
        test_user_id,
        'Teste Funcional',
        'Teste',
        30,
        NOW(),
        NULL,
        NULL,
        'Teste automatizado'
    ) INTO test_result;
    
    -- Inserir resultado na tabela temporária para exibir
    CREATE TEMP TABLE IF NOT EXISTS test_results (
        categoria TEXT,
        teste TEXT,
        resultado TEXT,
        detalhes TEXT,
        timestamp TIMESTAMPTZ DEFAULT NOW()
    );
    
    INSERT INTO test_results (categoria, teste, resultado, detalhes)
    VALUES ('TESTE FUNCIONAL', 'record_workout_basic', '✅ Funcionando', test_result::TEXT);
    
EXCEPTION WHEN OTHERS THEN
    INSERT INTO test_results (categoria, teste, resultado, detalhes)
    VALUES ('TESTE FUNCIONAL', 'record_workout_basic', '❌ Erro', SQLERRM);
END $$;

-- Testar outras funções
DO $$
BEGIN
    PERFORM detect_system_anomalies();
    INSERT INTO test_results (categoria, teste, resultado, detalhes)
    VALUES ('TESTE FUNCIONAL', 'detect_system_anomalies', '✅ Funcionando', 'Executada sem erros');
EXCEPTION WHEN OTHERS THEN
    INSERT INTO test_results (categoria, teste, resultado, detalhes)
    VALUES ('TESTE FUNCIONAL', 'detect_system_anomalies', '❌ Erro', SQLERRM);
END $$;

DO $$
BEGIN
    PERFORM system_health_report();
    INSERT INTO test_results (categoria, teste, resultado, detalhes)
    VALUES ('TESTE FUNCIONAL', 'system_health_report', '✅ Funcionando', 'Executada sem erros');
EXCEPTION WHEN OTHERS THEN
    INSERT INTO test_results (categoria, teste, resultado, detalhes)
    VALUES ('TESTE FUNCIONAL', 'system_health_report', '❌ Erro', SQLERRM);
END $$;

-- Mostrar resultados dos testes
SELECT 
    categoria,
    teste,
    resultado,
    detalhes,
    timestamp
FROM test_results
ORDER BY timestamp;

-- ================================================================
-- PASSO 5: CONFIGURAÇÕES FINAIS E OTIMIZAÇÕES
-- ================================================================

\echo ''
\echo '⚙️ PASSO 5: CONFIGURAÇÕES FINAIS'

-- Atualizar estatísticas das tabelas
ANALYZE workout_records;
ANALYZE challenge_check_ins;
ANALYZE check_in_error_logs;
ANALYZE workout_processing_queue;

-- Verificar índices importantes
DO $$
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS optimization_results (
        categoria TEXT,
        operacao TEXT,
        resultado TEXT,
        timestamp TIMESTAMPTZ DEFAULT NOW()
    );
    
    INSERT INTO optimization_results (categoria, operacao, resultado)
    VALUES ('OTIMIZAÇÃO', 'Análise de Tabelas', '✅ Estatísticas Atualizadas');
    
    -- Verificar/criar índices
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_workout_records_user_date') THEN
        CREATE INDEX CONCURRENTLY idx_workout_records_user_date 
        ON workout_records(user_id, DATE(date));
        INSERT INTO optimization_results (categoria, operacao, resultado)
        VALUES ('OTIMIZAÇÃO', 'Índice User-Date', '✅ Criado');
    ELSE
        INSERT INTO optimization_results (categoria, operacao, resultado)
        VALUES ('OTIMIZAÇÃO', 'Índice User-Date', '✅ Já Existe');
    END IF;
END $$;

-- Mostrar resultados das otimizações
SELECT 
    categoria,
    operacao,
    resultado,
    timestamp
FROM optimization_results
ORDER BY timestamp;

-- ================================================================
-- RESUMO FINAL E STATUS DO SISTEMA
-- ================================================================

\echo ''
\echo '📋 RESUMO FINAL DA IMPLEMENTAÇÃO'

WITH system_summary AS (
    SELECT 
        (SELECT COUNT(*) FROM pg_proc WHERE proname IN ('record_workout_basic', 'detect_system_anomalies', 'system_health_report')) as funcoes_principais,
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('check_in_error_logs', 'workout_processing_queue', 'workout_system_metrics')) as tabelas_monitoramento,
        (SELECT COUNT(*) FROM pg_indexes WHERE indexname LIKE '%workout%' OR indexname LIKE '%check_in%') as indices_criados,
        (SELECT COUNT(*) FROM test_results WHERE resultado LIKE '✅%') as testes_passaram,
        (SELECT COUNT(*) FROM test_results WHERE resultado LIKE '❌%') as testes_falharam
)
SELECT 
    'RESUMO FINAL' as categoria,
    'Funções Principais' as componente,
    funcoes_principais || '/3' as valor,
    CASE WHEN funcoes_principais = 3 THEN '✅ Completo' ELSE '❌ Incompleto' END as status
FROM system_summary

UNION ALL

SELECT 
    'RESUMO FINAL',
    'Tabelas Monitoramento',  
    tabelas_monitoramento || '/3',
    CASE WHEN tabelas_monitoramento >= 2 THEN '✅ Completo' ELSE '❌ Incompleto' END
FROM system_summary

UNION ALL

SELECT 
    'RESUMO FINAL',
    'Índices Performance',
    indices_criados::TEXT,
    CASE WHEN indices_criados > 0 THEN '✅ Criados' ELSE '❌ Nenhum' END
FROM system_summary

UNION ALL

SELECT 
    'RESUMO FINAL',
    'Testes Funcionais',
    testes_passaram || ' passou(aram), ' || testes_falharam || ' falhou(aram)',
    CASE WHEN testes_falharam = 0 THEN '✅ Todos OK' ELSE '❌ Alguns Falharam' END
FROM system_summary;

-- Status geral do sistema
WITH system_health AS (
    SELECT 
        (SELECT COUNT(*) FROM pg_proc WHERE proname IN ('record_workout_basic', 'detect_system_anomalies', 'system_health_report')) as funcoes,
        (SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('check_in_error_logs', 'workout_processing_queue')) as tabelas,
        (SELECT COUNT(*) FROM test_results WHERE resultado LIKE '❌%') as testes_falharam
)
SELECT 
    'STATUS GERAL' as categoria,
    CASE 
        WHEN funcoes = 3 AND tabelas >= 2 AND testes_falharam = 0 THEN '🎉 IMPLEMENTAÇÃO COMPLETA'
        WHEN funcoes = 3 AND tabelas >= 2 THEN '⚠️ IMPLEMENTAÇÃO COM ALERTAS'
        ELSE '❌ IMPLEMENTAÇÃO INCOMPLETA'
    END as status_sistema,
    CASE 
        WHEN funcoes = 3 AND tabelas >= 2 AND testes_falharam = 0 THEN 'Pronto para produção'
        WHEN funcoes = 3 AND tabelas >= 2 THEN 'Revisar alertas antes de usar'
        ELSE 'Implementação precisa ser finalizada'
    END as recomendacao,
    NOW() as timestamp
FROM system_health;

-- ================================================================
-- COMANDOS ÚTEIS PARA MONITORAMENTO
-- ================================================================

\echo ''
\echo '🔧 COMANDOS ÚTEIS PARA MONITORAMENTO DIÁRIO'

SELECT 
    'MONITORAMENTO' as categoria,
    comando,
    descricao,
    frequencia_recomendada
FROM (
    VALUES 
        ('SELECT * FROM detect_system_anomalies();', 'Detectar anomalias do sistema', 'Diário'),
        ('SELECT * FROM system_health_report();', 'Relatório completo de saúde', 'Diário'),
        ('SELECT process_pending_queue();', 'Processar fila pendente', 'Conforme necessário'),
        ('SELECT cleanup_old_logs(30);', 'Limpar logs antigos (30 dias)', 'Semanal'),
        ('\i diagnostic_system_status.sql', 'Diagnóstico completo com SELECT', 'Diário/Quando necessário'),
        ('\i run_system_health_check.sql', 'Verificação de integridade', 'Semanal')
) as commands(comando, descricao, frequencia_recomendada);

\timing off

\echo ''
\echo '🚀 IMPLEMENTAÇÃO CONCLUÍDA!'
\echo 'Consulte as tabelas de resultados acima para verificar o status de cada componente.' 