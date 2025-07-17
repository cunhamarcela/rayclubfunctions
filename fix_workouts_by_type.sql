-- Script para adicionar a coluna workouts_by_type à tabela user_progress
-- Criado após identificar o erro: column up.workouts_by_type does not exist

-- Verificar se a coluna já existe antes de tentar adicioná-la
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_progress' 
                   AND column_name = 'workouts_by_type') THEN
        -- Adicionar coluna workouts_by_type como JSONB
        ALTER TABLE user_progress ADD COLUMN workouts_by_type JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE 'Coluna workouts_by_type adicionada à tabela user_progress';
    ELSE
        RAISE NOTICE 'Coluna workouts_by_type já existe na tabela user_progress';
    END IF;
END $$; 