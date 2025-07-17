-- Verificar estrutura real da tabela workout_records
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_records'
ORDER BY ordinal_position;

-- Verificar se existem dados na tabela
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users
FROM workout_records;

-- Ver uma amostra dos dados
SELECT 
    id,
    user_id,
    workout_name,
    workout_type,
    date,
    -- Tentativa de diferentes nomes de coluna
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'duration_minutes') 
        THEN 'duration_minutes exists'
        ELSE 'duration_minutes missing'
    END as duration_check,
    created_at
FROM workout_records 
LIMIT 3; 