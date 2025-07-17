-- Atualização da tabela de FAQs para a Fase 3
-- Adicionar novos campos para gerenciamento administrativo

-- Adicionar is_active se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'faqs' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE faqs ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;
    END IF;
END $$;

-- Adicionar updated_by se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'faqs' AND column_name = 'updated_by'
    ) THEN
        ALTER TABLE faqs ADD COLUMN updated_by UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- Adicionar last_updated se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'faqs' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE faqs ADD COLUMN last_updated TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Criar índice para busca por categoria e status
CREATE INDEX IF NOT EXISTS idx_faqs_category_active ON faqs(category, is_active);

-- Atualizar políticas de segurança

-- Definir quem pode ler FAQs (todos)
DROP POLICY IF EXISTS "Anyone can read faqs" ON faqs;
CREATE POLICY "Anyone can read faqs" 
ON faqs FOR SELECT USING (true);

-- Definir quem pode criar FAQs (apenas admins)
DROP POLICY IF EXISTS "Only admins can insert faqs" ON faqs;
CREATE POLICY "Only admins can insert faqs" 
ON faqs FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_admin = true
    )
);

-- Definir quem pode atualizar FAQs (apenas admins)
DROP POLICY IF EXISTS "Only admins can update faqs" ON faqs;
CREATE POLICY "Only admins can update faqs" 
ON faqs FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_admin = true
    )
);

-- Definir quem pode excluir FAQs (apenas admins)
DROP POLICY IF EXISTS "Only admins can delete faqs" ON faqs;
CREATE POLICY "Only admins can delete faqs" 
ON faqs FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.is_admin = true
    )
);

-- Trigger para atualizar last_updated ao modificar uma FAQ
CREATE OR REPLACE FUNCTION update_faqs_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = now();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_faqs_last_updated ON faqs;
CREATE TRIGGER trigger_update_faqs_last_updated
BEFORE UPDATE ON faqs
FOR EACH ROW
EXECUTE FUNCTION update_faqs_last_updated();

-- Garantir que RLS esteja ativado
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY; 