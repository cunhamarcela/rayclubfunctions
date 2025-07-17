-- Script para adicionar a coluna image_urls à tabela workout_records no Supabase
-- Verifica se a coluna já existe antes de tentar adicioná-la

DO $$
BEGIN
    -- Verificar se a coluna image_urls já existe na tabela workout_records
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'workout_records'
        AND column_name = 'image_urls'
    ) THEN
        -- Adicionar a coluna image_urls como um array de texto
        EXECUTE 'ALTER TABLE workout_records ADD COLUMN image_urls TEXT[] DEFAULT ''{}''';
        RAISE NOTICE 'Coluna image_urls adicionada com sucesso à tabela workout_records';
    ELSE
        RAISE NOTICE 'A coluna image_urls já existe na tabela workout_records';
    END IF;
END $$; 