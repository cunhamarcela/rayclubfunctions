-- Verificar a estrutura atual da tabela water_intake
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'water_intake';

-- Verificar se já existe a coluna glass_size
DO $$
DECLARE
  column_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'water_intake' AND column_name = 'glass_size'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        -- Adicionar coluna glass_size à tabela water_intake
        ALTER TABLE water_intake ADD COLUMN glass_size INTEGER DEFAULT 250;
    END IF;
END
$$ LANGUAGE plpgsql; 