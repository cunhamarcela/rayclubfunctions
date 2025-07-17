-- Lista todas as funções no schema public do Supabase
SELECT 
    n.nspname as schema,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as function_arguments,
    pg_get_functiondef(p.oid) as function_definition
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public'
ORDER BY 
    p.proname; 