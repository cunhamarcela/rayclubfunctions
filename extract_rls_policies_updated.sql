-- Script atualizado para extrair todas as informações possíveis sobre políticas RLS
-- Execute este script no SQL Editor do Supabase

-- 1. Tentar extrair políticas pela tabela usando múltiplas abordagens
SELECT 
    *
FROM
    pg_policies
WHERE
    tablename = 'challenge_group_members'
    OR tablename LIKE '%challenge_group_members%';

-- 2. Verificar todos os esquemas possíveis onde a tabela pode estar
SELECT 
    schemaname, tablename
FROM 
    pg_tables 
WHERE 
    tablename = 'challenge_group_members'
    OR tablename LIKE '%challenge_group_members%';

-- 3. Tentar obter a definição completa da tabela incluindo RLS
SELECT
    pg_get_ruledef(r.oid, true) as table_def
FROM
    pg_class c
    JOIN pg_rewrite r ON r.ev_class = c.oid
WHERE
    c.relname = 'challenge_group_members';

-- 4. Obter a definição da política por tabela
SELECT
    n.nspname as schema_name,
    c.relname as table_name,
    pol.polname as policy_name,
    CASE pol.polpermissive WHEN 't' THEN 'PERMISSIVE' ELSE 'RESTRICTIVE' END as permissive,
    CASE pol.polroles[1] WHEN 0 THEN 'PUBLIC' ELSE pg_authid.rolname END as role,
    CASE pol.polcmd
        WHEN 'r' THEN 'SELECT'
        WHEN 'a' THEN 'INSERT'
        WHEN 'w' THEN 'UPDATE'
        WHEN 'd' THEN 'DELETE'
        WHEN '*' THEN 'ALL'
    END as command,
    pg_get_expr(pol.polqual, pol.polrelid) as using_expression,
    pg_get_expr(pol.polwithcheck, pol.polrelid) as with_check_expression
FROM
    pg_policy pol
    JOIN pg_class c ON c.oid = pol.polrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_authid ON pg_authid.oid = pol.polroles[1]
WHERE
    c.relname = 'challenge_group_members'
    OR c.relname LIKE '%challenge_group_members%';

-- 5. Consultar metadados específicos do Supabase sobre políticas RLS
-- (Supabase pode ter tabelas próprias que gerenciam políticas RLS)
SELECT 
    *
FROM 
    information_schema.tables
WHERE 
    table_name LIKE '%policy%'
    OR table_name LIKE '%rls%';

-- 6. Verificar se a tabela tem RLS habilitado
SELECT 
    c.relname as table_name,
    CASE c.relrowsecurity WHEN 't' THEN 'YES' ELSE 'NO' END as row_level_security
FROM 
    pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE 
    c.relname = 'challenge_group_members'
    AND n.nspname = 'public';

-- 7. Verificar políticas associadas à tabela usando pg_dump
DO $$
BEGIN
    RAISE NOTICE '%', (SELECT pg_catalog.pg_get_tabledef('challenge_group_members'::regclass));
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao obter definição com pg_get_tabledef: %', SQLERRM;
END $$; 