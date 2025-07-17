-- Funções utilitárias para diagnóstico do Supabase
-- Execute este script no SQL Editor do Supabase antes de usar o diagnóstico

-- 1. Função para verificar se outra função existe
CREATE OR REPLACE FUNCTION public.function_exists(function_name_param text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = function_name_param
        AND n.nspname = 'public'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Função para criar a função function_exists (meta-função)
CREATE OR REPLACE FUNCTION public.create_function_exists()
RETURNS void AS $$
BEGIN
    EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.function_exists(function_name_param text)
        RETURNS boolean AS $inner$
        BEGIN
            RETURN EXISTS (
                SELECT 1
                FROM pg_proc p
                JOIN pg_namespace n ON p.pronamespace = n.oid
                WHERE p.proname = function_name_param
                AND n.nspname = 'public'
            );
        END;
        $inner$ LANGUAGE plpgsql SECURITY DEFINER;
    $func$;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Função para obter colunas de uma tabela
CREATE OR REPLACE FUNCTION public.get_table_columns(table_name_param text)
RETURNS json AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'column_name', column_name,
                'data_type', data_type,
                'is_nullable', is_nullable
            )
        )
        FROM information_schema.columns
        WHERE table_name = table_name_param
        AND table_schema = 'public'
        ORDER BY ordinal_position
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Função para criar a função get_table_columns (meta-função)
CREATE OR REPLACE FUNCTION public.create_get_table_columns()
RETURNS void AS $$
BEGIN
    EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.get_table_columns(table_name_param text)
        RETURNS json AS $inner$
        BEGIN
            RETURN (
                SELECT json_agg(
                    json_build_object(
                        'column_name', column_name,
                        'data_type', data_type,
                        'is_nullable', is_nullable
                    )
                )
                FROM information_schema.columns
                WHERE table_name = table_name_param
                AND table_schema = 'public'
                ORDER BY ordinal_position
            );
        END;
        $inner$ LANGUAGE plpgsql SECURITY DEFINER;
    $func$;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Função para obter triggers de uma tabela
CREATE OR REPLACE FUNCTION public.get_table_triggers(table_name_param text)
RETURNS json AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'trigger_name', trigger_name,
                'event_manipulation', event_manipulation,
                'action_statement', action_statement
            )
        )
        FROM information_schema.triggers
        WHERE event_object_table = table_name_param
        AND event_object_schema = 'public'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Função para criar a função get_table_triggers (meta-função)
CREATE OR REPLACE FUNCTION public.create_get_table_triggers()
RETURNS void AS $$
BEGIN
    EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.get_table_triggers(table_name_param text)
        RETURNS json AS $inner$
        BEGIN
            RETURN (
                SELECT json_agg(
                    json_build_object(
                        'trigger_name', trigger_name,
                        'event_manipulation', event_manipulation,
                        'action_statement', action_statement
                    )
                )
                FROM information_schema.triggers
                WHERE event_object_table = table_name_param
                AND event_object_schema = 'public'
            );
        END;
        $inner$ LANGUAGE plpgsql SECURITY DEFINER;
    $func$;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Função para obter definição de uma função
CREATE OR REPLACE FUNCTION public.get_function_definition(function_name_param text)
RETURNS text AS $$
DECLARE
    function_oid oid;
    definition text;
BEGIN
    SELECT p.oid INTO function_oid
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname = function_name_param
    AND n.nspname = 'public';
    
    IF function_oid IS NULL THEN
        RETURN 'Função não encontrada';
    END IF;
    
    SELECT pg_get_functiondef(function_oid) INTO definition;
    RETURN definition;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Função para criar a função get_function_definition (meta-função)
CREATE OR REPLACE FUNCTION public.create_get_function_definition()
RETURNS void AS $$
BEGIN
    EXECUTE $func$
        CREATE OR REPLACE FUNCTION public.get_function_definition(function_name_param text)
        RETURNS text AS $inner$
        DECLARE
            function_oid oid;
            definition text;
        BEGIN
            SELECT p.oid INTO function_oid
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = function_name_param
            AND n.nspname = 'public';
            
            IF function_oid IS NULL THEN
                RETURN 'Função não encontrada';
            END IF;
            
            SELECT pg_get_functiondef(function_oid) INTO definition;
            RETURN definition;
        END;
        $inner$ LANGUAGE plpgsql SECURITY DEFINER;
    $func$;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Função para verificar se existem problemas comuns em funções específicas
CREATE OR REPLACE FUNCTION public.diagnosticar_funcoes_problematicas()
RETURNS json AS $$
DECLARE
    diagnostico json;
BEGIN
    WITH funcoes_analisadas AS (
        SELECT
            p.proname as nome_funcao,
            pg_get_functiondef(p.oid) as definicao,
            CASE 
                WHEN p.proname = 'record_challenge_check_in_v2' AND 
                     pg_get_functiondef(p.oid) NOT LIKE '%process_workout_for_ranking%' 
                THEN 'Faltando chamada para process_workout_for_ranking'
                WHEN p.proname = 'record_challenge_check_in_v2' AND 
                     pg_get_functiondef(p.oid) NOT LIKE '%process_workout_for_dashboard%' 
                THEN 'Faltando chamada para process_workout_for_dashboard'
                WHEN p.proname = 'process_workout_for_dashboard' AND
                     pg_get_functiondef(p.oid) LIKE '%RETURN FALSE%' AND
                     pg_get_functiondef(p.oid) NOT LIKE '%RETURN TRUE%'
                THEN 'A função sempre retorna FALSE'
                WHEN p.proname = 'process_workout_for_ranking' AND
                     pg_get_functiondef(p.oid) LIKE '%RETURN FALSE%' AND
                     pg_get_functiondef(p.oid) NOT LIKE '%RETURN TRUE%'
                THEN 'A função sempre retorna FALSE'
                ELSE 'Nenhum problema conhecido identificado'
            END as problema_identificado
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname IN (
            'record_challenge_check_in_v2',
            'process_workout_for_dashboard',
            'process_workout_for_ranking',
            'get_dashboard_data'
        )
    )
    SELECT json_agg(json_build_object(
        'nome_funcao', nome_funcao,
        'problema_identificado', problema_identificado
    )) INTO diagnostico
    FROM funcoes_analisadas;
    
    RETURN diagnostico;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Função para verificar relacionamentos entre tabelas importantes
CREATE OR REPLACE FUNCTION public.verificar_relacionamentos_tabelas()
RETURNS json AS $$
DECLARE
    resultado json;
BEGIN
    WITH relacionamentos AS (
        SELECT 
            tc.table_name as tabela_origem, 
            kcu.column_name as coluna_origem,
            ccu.table_name AS tabela_destino,
            ccu.column_name AS coluna_destino
        FROM 
            information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
        WHERE 
            tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema = 'public'
            AND (
                tc.table_name IN ('workout_records', 'challenge_check_ins', 'challenge_progress', 'user_progress')
                OR ccu.table_name IN ('workout_records', 'challenge_check_ins', 'challenge_progress', 'user_progress')
            )
    )
    SELECT json_agg(json_build_object(
        'tabela_origem', tabela_origem,
        'coluna_origem', coluna_origem,
        'tabela_destino', tabela_destino,
        'coluna_destino', coluna_destino
    )) INTO resultado
    FROM relacionamentos;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 