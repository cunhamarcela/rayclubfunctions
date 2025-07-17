-- Tabela de benefícios
CREATE TABLE benefits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  points_cost INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMP WITH TIME ZONE,
  quantity_available INTEGER,
  partner_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de parceiros
CREATE TABLE partners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  website_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adicionar foreign key à tabela de benefícios
ALTER TABLE benefits ADD CONSTRAINT fk_benefit_partner
  FOREIGN KEY (partner_id) REFERENCES partners(id);

-- Tabela de resgates de benefícios
CREATE TABLE benefit_redemptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_id UUID NOT NULL REFERENCES benefits(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  points_spent INTEGER NOT NULL,
  status TEXT DEFAULT 'pending', -- pending, approved, rejected, used
  code TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Segurança RLS
ALTER TABLE benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_redemptions ENABLE ROW LEVEL SECURITY;

-- Políticas para benefícios
CREATE POLICY "Benefícios ativos são visíveis para todos os usuários autenticados"
  ON benefits FOR SELECT
  TO authenticated
  USING (is_active = true AND (expires_at IS NULL OR expires_at > NOW()));

CREATE POLICY "Apenas admins podem gerenciar benefícios"
  ON benefits FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.is_admin = true
    )
  );

-- Políticas para parceiros
CREATE POLICY "Parceiros são visíveis para todos os usuários autenticados"
  ON partners FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Apenas admins podem gerenciar parceiros"
  ON partners FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.is_admin = true
    )
  );

-- Políticas para resgates
CREATE POLICY "Usuários podem ver apenas seus próprios resgates"
  ON benefit_redemptions FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Usuários podem resgatar benefícios"
  ON benefit_redemptions FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins podem ver todos os resgates"
  ON benefit_redemptions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins podem gerenciar resgates"
  ON benefit_redemptions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.is_admin = true
    )
  );

-- Trigger para atualizar o updated_at automaticamente
CREATE TRIGGER update_benefits_updated_at
BEFORE UPDATE ON benefits
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_partners_updated_at
BEFORE UPDATE ON partners
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_benefit_redemptions_updated_at
BEFORE UPDATE ON benefit_redemptions
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Trigger para decrementar a quantidade disponível quando um benefício é resgatado
CREATE OR REPLACE FUNCTION decrease_benefit_quantity()
RETURNS TRIGGER AS $$
BEGIN
  -- Verificar se o benefício tem quantidade limitada
  IF EXISTS (
    SELECT 1 FROM benefits 
    WHERE id = NEW.benefit_id AND quantity_available IS NOT NULL
  ) THEN
    -- Decrementar a quantidade disponível
    UPDATE benefits
    SET quantity_available = quantity_available - 1
    WHERE id = NEW.benefit_id AND quantity_available > 0;
    
    -- Verificar se a quantidade foi decrementada com sucesso
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Benefício esgotado';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrease_benefit_quantity_on_redemption
AFTER INSERT ON benefit_redemptions
FOR EACH ROW
EXECUTE FUNCTION decrease_benefit_quantity();

-- Índices para melhor performance
CREATE INDEX idx_benefit_is_active ON benefits(is_active);
CREATE INDEX idx_benefit_expires_at ON benefits(expires_at);
CREATE INDEX idx_benefit_redemptions_user ON benefit_redemptions(user_id);
CREATE INDEX idx_benefit_redemptions_benefit ON benefit_redemptions(benefit_id);
CREATE INDEX idx_benefit_redemptions_status ON benefit_redemptions(status); 