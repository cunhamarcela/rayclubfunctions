-- Verificar estrutura da tabela workout_videos
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'workout_videos'
ORDER BY 
    ordinal_position; 