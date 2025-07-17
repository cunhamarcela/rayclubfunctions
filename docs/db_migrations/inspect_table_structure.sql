-- Script para diagnosticar a estrutura atual da tabela workouts

-- 1. Verificar se a tabela workouts existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'workouts'
    ) THEN
        RAISE NOTICE 'A tabela workouts existe.';
    ELSE
        RAISE NOTICE 'A tabela workouts NÃO existe!';
        RETURN;
    END IF;
END $$;

-- 2. Listar todas as colunas da tabela workouts
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'workouts'
ORDER BY ordinal_position;

-- 3. Contar quantos registros existem na tabela
SELECT count(*) as total_workouts FROM workouts;

-- 4. Mostrar um exemplo de registro (se houver algum)
SELECT * FROM workouts LIMIT 1; 