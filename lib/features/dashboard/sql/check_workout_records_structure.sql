-- Query para verificar a estrutura da tabela workout_records
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_records'
ORDER BY ordinal_position;

-- Verificar se a tabela existe
SELECT 
    table_name,
    table_schema
FROM information_schema.tables 
WHERE table_name = 'workout_records';

-- Verificar dados de exemplo
SELECT 
    id,
    user_id,
    workout_name,
    workout_type,
    date,
    -- Testar diferentes nomes de coluna
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'duration_minutes') THEN 'duration_minutes exists'
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'durationMinutes') THEN 'durationMinutes exists'
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'duration') THEN 'duration exists'
        ELSE 'no duration column found'
    END as duration_column_check
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
LIMIT 1; 