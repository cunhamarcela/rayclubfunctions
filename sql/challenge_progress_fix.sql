-- Correção para a tabela challenge_progress
-- Adiciona as colunas created_at e updated_at que estão faltando

-- Adicionar coluna created_at à tabela challenge_progress
ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Adicionar a coluna updated_at à tabela challenge_progress
ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Inicializar ambas as colunas com a data e hora atual para registros existentes
UPDATE challenge_progress
SET created_at = NOW(), updated_at = NOW()
WHERE created_at IS NULL;

-- Adicionar um trigger para atualizar automaticamente o updated_at quando um registro for modificado
CREATE OR REPLACE FUNCTION update_challenge_progress_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_challenge_progress_updated_at ON challenge_progress;

CREATE TRIGGER set_challenge_progress_updated_at
BEFORE UPDATE ON challenge_progress
FOR EACH ROW
EXECUTE FUNCTION update_challenge_progress_updated_at(); 