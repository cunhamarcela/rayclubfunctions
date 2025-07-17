-- Script para verificar o esquema da tabela user_progress
-- Este script vai identificar se a coluna se chama total_check_ins ou check_ins_count

-- 1. Verificar as colunas da tabela user_progress
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM 
    information_schema.columns 
WHERE 
    table_name = 'user_progress'
ORDER BY 
    ordinal_position;

-- 2. Verificar todas as referências a user_progress nas funções
SELECT 
    proname AS function_name,
    prosrc AS function_source
FROM 
    pg_proc 
WHERE 
    prosrc LIKE '%user_progress%'
ORDER BY 
    proname; 