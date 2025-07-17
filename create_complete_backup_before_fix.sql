-- ================================================================
-- BACKUP COMPLETO ANTES DA CORREÇÃO
-- ================================================================
-- Este script cria um backup completo de todas as tabelas relacionadas 
-- ao sistema de treinos e ranking ANTES de executar qualquer correção
-- ================================================================

SELECT '💾 INICIANDO BACKUP COMPLETO DO SISTEMA' as status;

-- ================================================================
-- PARTE 1: CRIAR SCHEMA DE BACKUP COM TIMESTAMP
-- ================================================================

-- Criar schema de backup com timestamp
DO $$
DECLARE
    backup_schema_name TEXT;
    backup_timestamp TEXT;
BEGIN
    -- Gerar timestamp para o backup
    backup_timestamp := to_char(NOW(), 'YYYY_MM_DD_HH24_MI_SS');
    backup_schema_name := 'backup_' || backup_timestamp;
    
    -- Criar schema de backup
    EXECUTE 'CREATE SCHEMA IF NOT EXISTS ' || backup_schema_name;
    
    -- Armazenar o nome do schema para uso posterior
    CREATE TEMP TABLE IF NOT EXISTS backup_info (
        schema_name TEXT,
        created_at TIMESTAMP DEFAULT NOW()
    );
    
    INSERT INTO backup_info (schema_name) VALUES (backup_schema_name);
    
    RAISE NOTICE '✅ Schema de backup criado: %', backup_schema_name;
END $$;

-- ================================================================
-- PARTE 2: BACKUP DAS TABELAS PRINCIPAIS COM DADOS
-- ================================================================

SELECT '📋 FAZENDO BACKUP DAS TABELAS PRINCIPAIS' as secao;

DO $$
DECLARE
    backup_schema TEXT;
    table_record RECORD;
    backup_query TEXT;
    row_count INTEGER;
    total_backed_up INTEGER := 0;
BEGIN
    -- Obter nome do schema de backup
    SELECT schema_name INTO backup_schema FROM backup_info ORDER BY created_at DESC LIMIT 1;
    
    -- Backup da tabela workout_records
    backup_query := 'CREATE TABLE ' || backup_schema || '.workout_records AS SELECT * FROM workout_records';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ workout_records: % registros salvos', row_count;
    
    -- Backup da tabela challenge_check_ins
    backup_query := 'CREATE TABLE ' || backup_schema || '.challenge_check_ins AS SELECT * FROM challenge_check_ins';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ challenge_check_ins: % registros salvos', row_count;
    
    -- Backup da tabela challenge_progress
    backup_query := 'CREATE TABLE ' || backup_schema || '.challenge_progress AS SELECT * FROM challenge_progress';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ challenge_progress: % registros salvos', row_count;
    
    -- Backup da tabela challenges
    backup_query := 'CREATE TABLE ' || backup_schema || '.challenges AS SELECT * FROM challenges';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ challenges: % registros salvos', row_count;
    
    -- Backup da tabela workout_processing_queue
    backup_query := 'CREATE TABLE ' || backup_schema || '.workout_processing_queue AS SELECT * FROM workout_processing_queue';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ workout_processing_queue: % registros salvos', row_count;
    
    -- Backup da tabela check_in_error_logs
    backup_query := 'CREATE TABLE ' || backup_schema || '.check_in_error_logs AS SELECT * FROM check_in_error_logs';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ check_in_error_logs: % registros salvos', row_count;
    
    -- Backup da tabela profiles (apenas dados necessários)
    backup_query := 'CREATE TABLE ' || backup_schema || '.profiles AS SELECT id, name, email, created_at FROM profiles';
    EXECUTE backup_query;
    GET DIAGNOSTICS row_count = ROW_COUNT;
    total_backed_up := total_backed_up + row_count;
    RAISE NOTICE '✅ profiles (dados relevantes): % registros salvos', row_count;
    
    RAISE NOTICE '📊 TOTAL DE REGISTROS NO BACKUP: %', total_backed_up;
END $$;

-- ================================================================
-- PARTE 3: BACKUP DAS FUNÇÕES EXISTENTES
-- ================================================================

SELECT '🔧 FAZENDO BACKUP DAS FUNÇÕES EXISTENTES' as secao;

DO $$
DECLARE
    backup_schema TEXT;
    func_record RECORD;
    func_definition TEXT;
    functions_backed_up INTEGER := 0;
BEGIN
    -- Obter nome do schema de backup
    SELECT schema_name INTO backup_schema FROM backup_info ORDER BY created_at DESC LIMIT 1;
    
    -- Criar tabela para armazenar definições das funções
    EXECUTE 'CREATE TABLE ' || backup_schema || '.function_definitions (
        function_name TEXT,
        function_arguments TEXT,
        function_definition TEXT,
        backed_up_at TIMESTAMP DEFAULT NOW()
    )';
    
    -- Backup de todas as funções relacionadas ao sistema
    FOR func_record IN 
        SELECT 
            proname as function_name,
            pg_get_function_arguments(oid) as function_arguments,
            pg_get_functiondef(oid) as function_definition
        FROM pg_proc 
        WHERE proname ILIKE '%workout%' 
           OR proname ILIKE '%check%' 
           OR proname ILIKE '%ranking%'
           OR proname ILIKE '%challenge%'
    LOOP
        EXECUTE 'INSERT INTO ' || backup_schema || '.function_definitions 
                (function_name, function_arguments, function_definition) 
                VALUES ($1, $2, $3)'
        USING func_record.function_name, func_record.function_arguments, func_record.function_definition;
        
        functions_backed_up := functions_backed_up + 1;
    END LOOP;
    
    RAISE NOTICE '✅ FUNÇÕES SALVAS NO BACKUP: %', functions_backed_up;
END $$;

-- ================================================================
-- PARTE 4: CRIAR SCRIPTS DE RESTAURAÇÃO
-- ================================================================

SELECT '📜 CRIANDO SCRIPTS DE RESTAURAÇÃO' as secao;

DO $$
DECLARE
    backup_schema TEXT;
    restore_script TEXT;
BEGIN
    -- Obter nome do schema de backup
    SELECT schema_name INTO backup_schema FROM backup_info ORDER BY created_at DESC LIMIT 1;
    
    -- Criar tabela com scripts de restauração
    EXECUTE 'CREATE TABLE ' || backup_schema || '.restore_scripts (
        script_name TEXT,
        script_content TEXT,
        created_at TIMESTAMP DEFAULT NOW()
    )';
    
    -- Script 1: Restaurar tabelas principais
    restore_script := '
-- SCRIPT DE RESTAURAÇÃO - TABELAS PRINCIPAIS
-- Execute este script para restaurar as tabelas do backup

-- 1. Limpar tabelas atuais (CUIDADO!)
TRUNCATE workout_records, challenge_check_ins, challenge_progress, workout_processing_queue, check_in_error_logs CASCADE;

-- 2. Restaurar dados do backup
INSERT INTO workout_records SELECT * FROM ' || backup_schema || '.workout_records;
INSERT INTO challenge_check_ins SELECT * FROM ' || backup_schema || '.challenge_check_ins;
INSERT INTO challenge_progress SELECT * FROM ' || backup_schema || '.challenge_progress;
INSERT INTO workout_processing_queue SELECT * FROM ' || backup_schema || '.workout_processing_queue;
INSERT INTO check_in_error_logs SELECT * FROM ' || backup_schema || '.check_in_error_logs;

SELECT ''✅ DADOS RESTAURADOS COM SUCESSO DO BACKUP: ' || backup_schema || ''' as status;
    ';
    
    EXECUTE 'INSERT INTO ' || backup_schema || '.restore_scripts (script_name, script_content) VALUES ($1, $2)'
    USING 'restore_main_tables.sql', restore_script;
    
    -- Script 2: Restaurar funções
    restore_script := '
-- SCRIPT DE RESTAURAÇÃO - FUNÇÕES
-- Execute este script para restaurar as funções do backup

DO $$
DECLARE
    func_record RECORD;
BEGIN
    FOR func_record IN 
        SELECT function_definition 
        FROM ' || backup_schema || '.function_definitions
    LOOP
        BEGIN
            EXECUTE func_record.function_definition;
            RAISE NOTICE ''✅ Função restaurada com sucesso'';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE ''⚠️ Erro ao restaurar função: %'', SQLERRM;
        END;
    END LOOP;
END $$;

SELECT ''✅ FUNÇÕES RESTAURADAS COM SUCESSO DO BACKUP: ' || backup_schema || ''' as status;
    ';
    
    EXECUTE 'INSERT INTO ' || backup_schema || '.restore_scripts (script_name, script_content) VALUES ($1, $2)'
    USING 'restore_functions.sql', restore_script;
    
    RAISE NOTICE '✅ Scripts de restauração criados no schema: %', backup_schema;
END $$;

-- ================================================================
-- PARTE 5: VERIFICAR INTEGRIDADE DO BACKUP
-- ================================================================

SELECT '🔍 VERIFICANDO INTEGRIDADE DO BACKUP' as secao;

DO $$
DECLARE
    backup_schema TEXT;
    original_count INTEGER;
    backup_count INTEGER;
    table_name TEXT;
    verification_passed BOOLEAN := TRUE;
BEGIN
    -- Obter nome do schema de backup
    SELECT schema_name INTO backup_schema FROM backup_info ORDER BY created_at DESC LIMIT 1;
    
    -- Verificar cada tabela
    FOR table_name IN SELECT unnest(ARRAY['workout_records', 'challenge_check_ins', 'challenge_progress', 'challenges', 'workout_processing_queue', 'check_in_error_logs'])
    LOOP
        -- Contar registros na tabela original
        EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO original_count;
        
        -- Contar registros na tabela de backup
        EXECUTE 'SELECT COUNT(*) FROM ' || backup_schema || '.' || table_name INTO backup_count;
        
        IF original_count = backup_count THEN
            RAISE NOTICE '✅ %: % registros (OK)', table_name, backup_count;
        ELSE
            RAISE NOTICE '❌ %: ORIGINAL=% vs BACKUP=% (ERRO)', table_name, original_count, backup_count;
            verification_passed := FALSE;
        END IF;
    END LOOP;
    
    IF verification_passed THEN
        RAISE NOTICE '✅ VERIFICAÇÃO DE INTEGRIDADE: PASSOU EM TODOS OS TESTES';
    ELSE
        RAISE NOTICE '❌ VERIFICAÇÃO DE INTEGRIDADE: FALHOU EM ALGUNS TESTES';
    END IF;
END $$;

-- ================================================================
-- PARTE 6: CRIAR LOG DO BACKUP
-- ================================================================

SELECT '📋 CRIANDO LOG DO BACKUP' as secao;

DO $$
DECLARE
    backup_schema TEXT;
    backup_summary TEXT;
BEGIN
    -- Obter nome do schema de backup
    SELECT schema_name INTO backup_schema FROM backup_info ORDER BY created_at DESC LIMIT 1;
    
    -- Criar tabela de log do backup
    EXECUTE 'CREATE TABLE ' || backup_schema || '.backup_log (
        backup_date TIMESTAMP DEFAULT NOW(),
        backup_schema TEXT,
        total_workout_records INTEGER,
        total_check_ins INTEGER,
        total_progress_records INTEGER,
        total_challenges INTEGER,
        total_functions INTEGER,
        backup_size_mb NUMERIC,
        backup_status TEXT
    )';
    
    -- Inserir informações do backup
    EXECUTE 'INSERT INTO ' || backup_schema || '.backup_log 
            (backup_schema, total_workout_records, total_check_ins, total_progress_records, total_challenges, total_functions, backup_status)
            VALUES ($1, 
                   (SELECT COUNT(*) FROM ' || backup_schema || '.workout_records),
                   (SELECT COUNT(*) FROM ' || backup_schema || '.challenge_check_ins),
                   (SELECT COUNT(*) FROM ' || backup_schema || '.challenge_progress),
                   (SELECT COUNT(*) FROM ' || backup_schema || '.challenges),
                   (SELECT COUNT(*) FROM ' || backup_schema || '.function_definitions),
                   $2)'
    USING backup_schema, 'COMPLETO';
    
    RAISE NOTICE '📋 Log do backup criado com sucesso';
END $$;

-- ================================================================
-- PARTE 7: INSTRUÇÕES FINAIS
-- ================================================================

SELECT '📋 INSTRUÇÕES PARA USO DO BACKUP' as titulo;

DO $$
DECLARE
    backup_schema TEXT;
BEGIN
    SELECT schema_name INTO backup_schema FROM backup_info ORDER BY created_at DESC LIMIT 1;
    
    RAISE NOTICE '';
    RAISE NOTICE '=================== BACKUP CONCLUÍDO ===================';
    RAISE NOTICE 'Schema do backup: %', backup_schema;
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PARA RESTAURAR DADOS:';
    RAISE NOTICE '1. Execute: SELECT script_content FROM %.restore_scripts WHERE script_name = ''restore_main_tables.sql'';', backup_schema;
    RAISE NOTICE '2. Copie e execute o script retornado';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PARA RESTAURAR FUNÇÕES:';
    RAISE NOTICE '1. Execute: SELECT script_content FROM %.restore_scripts WHERE script_name = ''restore_functions.sql'';', backup_schema;
    RAISE NOTICE '2. Copie e execute o script retornado';
    RAISE NOTICE '';
    RAISE NOTICE '📊 PARA VER ESTATÍSTICAS DO BACKUP:';
    RAISE NOTICE 'Execute: SELECT * FROM %.backup_log;', backup_schema;
    RAISE NOTICE '';
    RAISE NOTICE '🗑️ PARA REMOVER O BACKUP (após confirmar que tudo está OK):';
    RAISE NOTICE 'Execute: DROP SCHEMA % CASCADE;', backup_schema;
    RAISE NOTICE '======================================================';
END $$;

-- Limpar tabela temporária
DROP TABLE IF EXISTS backup_info;

SELECT '✅ BACKUP COMPLETO FINALIZADO COM SUCESSO!' as status; 