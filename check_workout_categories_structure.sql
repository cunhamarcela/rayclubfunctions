-- Verificar estrutura da tabela workout_categories
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'workout_categories'
ORDER BY 
    ordinal_position;

-- Verificar se existem dados na tabela
SELECT COUNT(*) as total_categories FROM workout_categories;

-- Ver alguns registros de exemplo
SELECT * FROM workout_categories LIMIT 5; 