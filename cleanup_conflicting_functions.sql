-- ================================================================
-- SCRIPT DE LIMPEZA DE FUNÇÕES CONFLITANTES
-- Execute ANTES do script principal para remover versões antigas
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '🧹 ===== INICIANDO LIMPEZA DE FUNÇÕES CONFLITANTES =====';
    RAISE NOTICE 'Timestamp: %', NOW();
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PARTE 1: IDENTIFICAR FUNÇÕES CONFLITANTES
-- ================================================================

DO $$
DECLARE
    func_record RECORD;
    func_count INTEGER := 0;
BEGIN
    RAISE NOTICE '🔍 1. IDENTIFICANDO FUNÇÕES CONFLITANTES';
    RAISE NOTICE '----------------------------------------';
    
    -- Listar todas as versões de record_workout_basic
    FOR func_record IN 
        SELECT proname, 
               pg_get_function_identity_arguments(oid) as args,
               oid
        FROM pg_proc 
        WHERE proname = 'record_workout_basic'
        ORDER BY proname, args
    LOOP
        func_count := func_count + 1;
        RAISE NOTICE 'Encontrada: %(%)', func_record.proname, func_record.args;
    END LOOP;
    
    RAISE NOTICE 'Total de versões encontradas: %', func_count;
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PARTE 2: REMOVER TODAS AS VERSÕES DE record_workout_basic
-- ================================================================

DO $$
DECLARE
    func_record RECORD;
    drop_statement TEXT;
    functions_dropped INTEGER := 0;
BEGIN
    RAISE NOTICE '🗑️  2. REMOVENDO TODAS AS VERSÕES DE record_workout_basic';
    RAISE NOTICE '----------------------------------------';
    
    -- Remover todas as versões existentes
    FOR func_record IN 
        SELECT proname, 
               pg_get_function_identity_arguments(oid) as args,
               oid
        FROM pg_proc 
        WHERE proname = 'record_workout_basic'
    LOOP
        drop_statement := format('DROP FUNCTION IF EXISTS %I(%s) CASCADE', 
                                func_record.proname, 
                                func_record.args);
        
        BEGIN
            EXECUTE drop_statement;
            functions_dropped := functions_dropped + 1;
            RAISE NOTICE '✅ Removida: %(%)', func_record.proname, func_record.args;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️  Erro ao remover %(%): %', func_record.proname, func_record.args, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Total de funções removidas: %', functions_dropped;
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PARTE 3: REMOVER OUTRAS FUNÇÕES CONFLITANTES
-- ================================================================

DO $$
DECLARE
    func_names TEXT[] := ARRAY[
        'record_challenge_check_in',
        'record_challenge_check_in_v2', 
        'record_challenge_check_in_robust',
        'process_workout_for_ranking',
        'process_workout_for_ranking_fixed',
        'process_workout_for_ranking_v2'
    ];
    func_name TEXT;
    func_record RECORD;
    drop_statement TEXT;
    total_dropped INTEGER := 0;
BEGIN
    RAISE NOTICE '🗑️  3. REMOVENDO OUTRAS FUNÇÕES CONFLITANTES';
    RAISE NOTICE '----------------------------------------';
    
    FOREACH func_name IN ARRAY func_names LOOP
        FOR func_record IN 
            SELECT proname, 
                   pg_get_function_identity_arguments(oid) as args,
                   oid
            FROM pg_proc 
            WHERE proname = func_name
        LOOP
            drop_statement := format('DROP FUNCTION IF EXISTS %I(%s) CASCADE', 
                                    func_record.proname, 
                                    func_record.args);
            
            BEGIN
                EXECUTE drop_statement;
                total_dropped := total_dropped + 1;
                RAISE NOTICE '✅ Removida: %(%)', func_record.proname, func_record.args;
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE '⚠️  Erro ao remover %(%): %', func_record.proname, func_record.args, SQLERRM;
            END;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Total de outras funções removidas: %', total_dropped;
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PARTE 4: REMOVER TRIGGERS CONFLITANTES
-- ================================================================

DO $$
DECLARE
    trigger_record RECORD;
    drop_statement TEXT;
    triggers_dropped INTEGER := 0;
BEGIN
    RAISE NOTICE '🗑️  4. REMOVENDO TRIGGERS CONFLITANTES';
    RAISE NOTICE '----------------------------------------';
    
    -- Remover triggers que podem estar causando conflitos
    FOR trigger_record IN 
        SELECT trigger_schema as schemaname, 
               event_object_table as tablename, 
               trigger_name as triggername
        FROM information_schema.triggers 
        WHERE trigger_name LIKE '%workout%' 
           OR trigger_name LIKE '%check_in%'
           OR trigger_name LIKE '%ranking%'
        ORDER BY event_object_table, trigger_name
    LOOP
        drop_statement := format('DROP TRIGGER IF EXISTS %I ON %I.%I CASCADE', 
                                trigger_record.triggername,
                                trigger_record.schemaname,
                                trigger_record.tablename);
        
        BEGIN
            EXECUTE drop_statement;
            triggers_dropped := triggers_dropped + 1;
            RAISE NOTICE '✅ Trigger removido: % em %.%', 
                trigger_record.triggername,
                trigger_record.schemaname,
                trigger_record.tablename;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️  Erro ao remover trigger %: %', trigger_record.triggername, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Total de triggers removidos: %', triggers_dropped;
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PARTE 5: LIMPAR CONSTRAINTS CONFLITANTES
-- ================================================================

DO $$
DECLARE
    constraint_record RECORD;
    drop_statement TEXT;
    constraints_dropped INTEGER := 0;
BEGIN
    RAISE NOTICE '🗑️  5. REMOVENDO CONSTRAINTS CONFLITANTES';
    RAISE NOTICE '----------------------------------------';
    
    -- Remover constraints que podem estar causando conflitos
    FOR constraint_record IN 
        SELECT table_name, constraint_name
        FROM information_schema.table_constraints 
        WHERE constraint_name LIKE '%workout%' 
           OR constraint_name LIKE '%check_in%'
           OR constraint_name LIKE '%unique_user%'
        ORDER BY table_name, constraint_name
    LOOP
        drop_statement := format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I CASCADE', 
                                constraint_record.table_name,
                                constraint_record.constraint_name);
        
        BEGIN
            EXECUTE drop_statement;
            constraints_dropped := constraints_dropped + 1;
            RAISE NOTICE '✅ Constraint removida: % da tabela %', 
                constraint_record.constraint_name,
                constraint_record.table_name;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️  Erro ao remover constraint %: %', constraint_record.constraint_name, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Total de constraints removidas: %', constraints_dropped;
    RAISE NOTICE '';
END $$;

-- ================================================================
-- PARTE 6: VERIFICAÇÃO FINAL
-- ================================================================

DO $$
DECLARE
    remaining_functions INTEGER;
    func_record RECORD;
BEGIN
    RAISE NOTICE '✅ 6. VERIFICAÇÃO FINAL';
    RAISE NOTICE '----------------------------------------';
    
    -- Verificar se ainda há funções conflitantes
    SELECT COUNT(*) INTO remaining_functions
    FROM pg_proc 
    WHERE proname IN ('record_workout_basic', 'record_challenge_check_in', 'process_workout_for_ranking');
    
    IF remaining_functions = 0 THEN
        RAISE NOTICE '✅ Limpeza concluída com sucesso!';
        RAISE NOTICE 'Nenhuma função conflitante restante.';
        RAISE NOTICE '';
        RAISE NOTICE '🚀 PRÓXIMO PASSO:';
        RAISE NOTICE 'Execute agora: \\i final_robust_sql_functions.sql';
    ELSE
        RAISE NOTICE '⚠️  Ainda restam % funções conflitantes', remaining_functions;
        RAISE NOTICE 'Pode ser necessário remover manualmente.';
        
        -- Listar funções restantes
        RAISE NOTICE '';
        RAISE NOTICE 'Funções restantes:';
        FOR func_record IN 
            SELECT proname, pg_get_function_identity_arguments(oid) as args
            FROM pg_proc 
            WHERE proname IN ('record_workout_basic', 'record_challenge_check_in', 'process_workout_for_ranking')
        LOOP
            RAISE NOTICE '- %(%)', func_record.proname, func_record.args;
        END LOOP;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '===== LIMPEZA CONCLUÍDA =====';
    RAISE NOTICE 'Timestamp: %', NOW();
END $$; 