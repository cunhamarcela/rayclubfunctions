-- Supabase Schema Extraction Script
-- Este script extrairá informações detalhadas sobre o esquema do seu banco de dados Supabase
-- Copie e cole este script no Editor SQL do Supabase para executá-lo

-- 1. Lista de tabelas com contagem de registros
WITH table_counts AS (
    SELECT
        schemaname,
        relname AS table_name,
        n_live_tup AS row_count
    FROM
        pg_stat_user_tables
    WHERE
        schemaname = 'public'
    ORDER BY
        n_live_tup DESC
)
SELECT
    table_name,
    row_count,
    obj_description(
        (SELECT
            c.oid
        FROM
            pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE
            c.relname = table_counts.table_name
            AND n.nspname = 'public'),
        'pg_class'
    ) AS table_description
FROM
    table_counts;

-- 2. Informações detalhadas sobre colunas de cada tabela
SELECT
    t.table_name,
    c.column_name,
    c.data_type,
    c.character_maximum_length,
    c.is_nullable,
    c.column_default,
    pg_catalog.col_description(
        format('%I.%I', c.table_schema, c.table_name)::regclass::oid, 
        c.ordinal_position
    ) AS column_description
FROM
    information_schema.tables t
    JOIN information_schema.columns c ON t.table_name = c.table_name AND t.table_schema = c.table_schema
WHERE
    t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY
    t.table_name,
    c.ordinal_position;

-- 3. Chaves primárias
SELECT
    tc.table_schema, 
    tc.table_name, 
    kc.column_name
FROM
    information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kc ON kc.constraint_name = tc.constraint_name AND kc.constraint_schema = tc.constraint_schema
WHERE
    tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY
    tc.table_schema,
    tc.table_name;

-- 4. Chaves estrangeiras
SELECT
    tc.table_schema, 
    tc.table_name, 
    kc.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM
    information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kc ON tc.constraint_name = kc.constraint_name AND tc.constraint_schema = kc.constraint_schema
    JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name AND ccu.constraint_schema = tc.constraint_schema
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY
    tc.table_schema,
    tc.table_name;

-- 5. Índices
SELECT
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    indexname;

-- 6. Triggers
SELECT
    event_object_table AS table_name,
    trigger_name,
    action_timing AS timing,
    event_manipulation AS event,
    action_statement AS definition
FROM
    information_schema.triggers
WHERE
    trigger_schema = 'public'
ORDER BY
    event_object_table,
    trigger_name;

-- 7. Funções
SELECT
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_definition
FROM
    pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE
    n.nspname = 'public'
ORDER BY
    p.proname;

-- 8. Visualizações (Views)
SELECT
    table_name AS view_name,
    view_definition
FROM
    information_schema.views
WHERE
    table_schema = 'public'
ORDER BY
    table_name;

-- 9. Políticas RLS (Row Level Security)
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM
    pg_policies
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    policyname;

-- 10. Extensions
SELECT
    name,
    default_version,
    installed_version,
    comment
FROM
    pg_available_extensions
WHERE
    installed_version IS NOT NULL
ORDER BY
    name;

-- 11. Funções de Storage
-- (Esta parte é específica do Supabase e não possui uma consulta SQL padrão)
-- Confira as funções definidas no Supabase Dashboard > Storage > Configurações

-- 12. Buckects de Storage
SELECT 
    name,
    owner,
    created_at,
    updated_at,
    public
FROM 
    storage.buckets
ORDER BY 
    name;

-- 13. Colunas de tipo JSON/JSONB com exemplos
SELECT
    table_name,
    column_name,
    data_type,
    col_description(
        format('%I.%I', table_schema, table_name)::regclass::oid,
        ordinal_position
    ) AS column_description
FROM
    information_schema.columns
WHERE
    table_schema = 'public'
    AND data_type IN ('json', 'jsonb')
ORDER BY
    table_name,
    column_name;

-- 14. Tipos personalizados (ENUMS e outros tipos compostos)
SELECT
    t.typname AS type_name,
    CASE
        WHEN t.typtype = 'e' THEN 'ENUM'
        WHEN t.typtype = 'c' THEN 'COMPOSITE'
        ELSE t.typtype::text
    END AS type_type,
    CASE
        WHEN t.typtype = 'e' THEN
            (SELECT array_agg(e.enumlabel)
             FROM pg_enum e
             WHERE e.enumtypid = t.oid)::text
        ELSE NULL
    END AS enum_values,
    obj_description(t.oid, 'pg_type') AS type_description
FROM
    pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
WHERE
    n.nspname = 'public'
    AND (t.typtype = 'e' OR t.typtype = 'c')
    AND NOT EXISTS (
        SELECT 1 FROM pg_class c
        WHERE c.oid = t.typrelid AND c.relkind = 'c'
    )
ORDER BY
    t.typname;

-- 15. Estatísticas - Top 10 tabelas por tamanho
SELECT
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) AS total_size,
    pg_size_pretty(pg_relation_size(quote_ident(table_name))) AS table_size,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name)) - pg_relation_size(quote_ident(table_name))) AS index_size
FROM
    information_schema.tables
WHERE
    table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY
    pg_total_relation_size(quote_ident(table_name)) DESC
LIMIT 10; 