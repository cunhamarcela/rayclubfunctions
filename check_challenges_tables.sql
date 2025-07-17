-- Verificar tabelas relacionadas a desafios e suas estruturas

-- Tabela challenges
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'challenges'
ORDER BY ordinal_position;

-- Tabela challenge_participants
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'challenge_participants'
ORDER BY ordinal_position;

-- Tabela challenge_progress
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'challenge_progress'
ORDER BY ordinal_position;

-- Verificar se a tabela challenge_progress tem todos os campos necessários
DO $$
DECLARE
  column_exists BOOLEAN;
BEGIN
    -- Verificar se o campo completion_percentage existe
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'challenge_progress' AND column_name = 'completion_percentage'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        ALTER TABLE challenge_progress ADD COLUMN completion_percentage NUMERIC DEFAULT 0;
    END IF;
    
    -- Verificar se o campo position existe
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'challenge_progress' AND column_name = 'position'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        ALTER TABLE challenge_progress ADD COLUMN position INTEGER DEFAULT 1;
    END IF;
    
    -- Verificar se o campo check_ins_count existe
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        ALTER TABLE challenge_progress ADD COLUMN check_ins_count INTEGER DEFAULT 0;
    END IF;
END
$$ LANGUAGE plpgsql; 