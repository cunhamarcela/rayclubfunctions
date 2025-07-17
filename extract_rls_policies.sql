-- Script para extrair informações sobre políticas RLS da tabela challenge_group_members
-- Execute este script no SQL Editor do Supabase

-- 1. Extrair todas as políticas RLS para a tabela challenge_group_members
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd AS operation,
    qual AS expression,
    with_check AS with_check_expression
FROM
    pg_policies
WHERE
    tablename = 'challenge_group_members';

-- 2. Exibir a definição da tabela challenge_group_members
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'challenge_group_members'
ORDER BY 
    ordinal_position;

-- 3. Verificar se há funções personalizadas usadas nas políticas
-- (isso pode ajudar a identificar recursões)
SELECT 
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_definition
FROM 
    pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public'
    AND pg_get_functiondef(p.oid) LIKE '%challenge_group_members%'; 