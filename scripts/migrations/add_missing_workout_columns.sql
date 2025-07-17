-- Script para adicionar colunas faltantes à tabela workout_records no Supabase
-- Verifica se cada coluna já existe antes de tentar adicioná-la

DO $$
BEGIN
    -- 1. Verificar e adicionar a coluna image_urls
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

    -- 2. Verificar e adicionar a coluna updated_at
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'workout_records'
        AND column_name = 'updated_at'
    ) THEN
        -- Adicionar a coluna updated_at
        EXECUTE 'ALTER TABLE workout_records ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()';
        RAISE NOTICE 'Coluna updated_at adicionada com sucesso à tabela workout_records';
        
        -- Criar trigger para atualizar automaticamente o updated_at
        CREATE OR REPLACE FUNCTION update_workout_records_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;

        DROP TRIGGER IF EXISTS trigger_update_workout_records_updated_at ON workout_records;
        CREATE TRIGGER trigger_update_workout_records_updated_at
        BEFORE UPDATE ON workout_records
        FOR EACH ROW
        EXECUTE FUNCTION update_workout_records_updated_at();
        
        RAISE NOTICE 'Trigger para atualização automática de updated_at criado com sucesso';
    ELSE
        RAISE NOTICE 'A coluna updated_at já existe na tabela workout_records';
    END IF;
    
    -- 3. Verificar e adicionar a coluna completion_status (caso ainda não exista)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'workout_records'
        AND column_name = 'completion_status'
    ) THEN
        -- Adicionar a coluna completion_status
        EXECUTE 'ALTER TABLE workout_records ADD COLUMN completion_status TEXT DEFAULT ''completed''';
        RAISE NOTICE 'Coluna completion_status adicionada com sucesso à tabela workout_records';
    ELSE
        RAISE NOTICE 'A coluna completion_status já existe na tabela workout_records';
    END IF;
END $$; 