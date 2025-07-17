-- Script simplificado para listar as políticas RLS atuais
-- Execute esta consulta no SQL Editor do Supabase

-- Método 1: Visualizar políticas RLS da tabela desejada
SELECT * FROM pg_policies WHERE tablename = 'challenge_group_members';

-- Método 2: Se a consulta acima não retornar resultados, experimente:
SELECT 
    polname AS policy_name,
    relname AS table_name,
    CASE polcmd
        WHEN 'r' THEN 'SELECT'
        WHEN 'a' THEN 'INSERT'
        WHEN 'w' THEN 'UPDATE'
        WHEN 'd' THEN 'DELETE'
        WHEN '*' THEN 'ALL'
    END AS operation,
    pg_get_expr(polqual, polrelid) AS using_expression,
    pg_get_expr(polwithcheck, polrelid) AS with_check_expression
FROM pg_policy
JOIN pg_class ON pg_class.oid = pg_policy.polrelid
WHERE relname = 'challenge_group_members';

-- Método 3: Mostrar todas as políticas do banco de dados
-- (use se os métodos acima falharem)
SELECT * FROM pg_policies; 