-- Verificar a estrutura atual da tabela profiles
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles';

-- Verificar se já existe a coluna onboarding_seen
DO $$
DECLARE 
  column_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'profiles' AND column_name = 'onboarding_seen'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        -- Adicionar coluna onboarding_seen à tabela profiles
        ALTER TABLE profiles ADD COLUMN onboarding_seen BOOLEAN DEFAULT false;
    END IF;
END
$$ LANGUAGE plpgsql; 