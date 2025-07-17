-- Atualização da tabela de tutoriais para a Fase 3
-- Adicionar novos campos para gerenciamento administrativo

-- Adicionar is_active se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tutorials' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE tutorials ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;
    END IF;
END $$;

-- Adicionar is_featured se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tutorials' AND column_name = 'is_featured'
    ) THEN
        ALTER TABLE tutorials ADD COLUMN is_featured BOOLEAN NOT NULL DEFAULT false;
    END IF;
END $$;

-- Adicionar updated_by se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tutorials' AND column_name = 'updated_by'
    ) THEN
        ALTER TABLE tutorials ADD COLUMN updated_by UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- Adicionar last_updated se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tutorials' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE tutorials ADD COLUMN last_updated TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Adicionar related_content se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tutorials' AND column_name = 'related_content'
    ) THEN
        ALTER TABLE tutorials ADD COLUMN related_content JSONB DEFAULT '{}';
    END IF;
END $$;

-- Criar índice para busca por categoria e featured
CREATE INDEX IF NOT EXISTS idx_tutorials_category_featured ON tutorials(category, is_featured);

-- Atualizar políticas de segurança

-- Definir quem pode ler tutoriais (todos)
DROP POLICY IF EXISTS "Anyone can read tutorials" ON tutorials;
CREATE POLICY "Anyone can read tutorials" 
ON tutorials FOR SELECT USING (true);

-- Definir quem pode criar tutoriais (apenas admins)
DROP POLICY IF EXISTS "Only admins can insert tutorials" ON tutorials;
CREATE POLICY "Only admins can insert tutorials" 
ON tutorials FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_admin = true
    )
);

-- Definir quem pode atualizar tutoriais (apenas admins)
DROP POLICY IF EXISTS "Only admins can update tutorials" ON tutorials;
CREATE POLICY "Only admins can update tutorials" 
ON tutorials FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_admin = true
    )
);

-- Definir quem pode excluir tutoriais (apenas admins)
DROP POLICY IF EXISTS "Only admins can delete tutorials" ON tutorials;
CREATE POLICY "Only admins can delete tutorials" 
ON tutorials FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_admin = true
    )
);

-- Trigger para atualizar last_updated ao modificar um tutorial
CREATE OR REPLACE FUNCTION update_tutorials_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = now();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_tutorials_last_updated ON tutorials;
CREATE TRIGGER trigger_update_tutorials_last_updated
BEFORE UPDATE ON tutorials
FOR EACH ROW
EXECUTE FUNCTION update_tutorials_last_updated();

-- Garantir que RLS esteja ativado
ALTER TABLE tutorials ENABLE ROW LEVEL SECURITY; 