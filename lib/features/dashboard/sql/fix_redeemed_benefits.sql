-- Criar a tabela redeemed_benefits se não existir
CREATE TABLE IF NOT EXISTS redeemed_benefits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  benefit_id UUID NOT NULL REFERENCES benefits(id),
  title TEXT,
  description TEXT,
  code TEXT,
  status TEXT DEFAULT 'active',
  redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expiration_date TIMESTAMP WITH TIME ZONE,
  used_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  redemption_code TEXT
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_redeemed_benefits_user_id ON redeemed_benefits(user_id);
CREATE INDEX IF NOT EXISTS idx_redeemed_benefits_benefit_id ON redeemed_benefits(benefit_id);
CREATE INDEX IF NOT EXISTS idx_redeemed_benefits_status ON redeemed_benefits(status);

-- Configurar RLS
ALTER TABLE redeemed_benefits ENABLE ROW LEVEL SECURITY;

-- Política para usuários verem apenas seus próprios benefícios
DROP POLICY IF EXISTS redeemed_benefits_select_policy ON redeemed_benefits;
CREATE POLICY redeemed_benefits_select_policy
  ON redeemed_benefits
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política para usuários criarem apenas seus próprios benefícios
DROP POLICY IF EXISTS redeemed_benefits_insert_policy ON redeemed_benefits;
CREATE POLICY redeemed_benefits_insert_policy
  ON redeemed_benefits
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política para usuários atualizarem apenas seus próprios benefícios
DROP POLICY IF EXISTS redeemed_benefits_update_policy ON redeemed_benefits;
CREATE POLICY redeemed_benefits_update_policy
  ON redeemed_benefits
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Função para sincronização de benefit_redemption_codes para redeemed_benefits
CREATE OR REPLACE FUNCTION sync_benefit_redemption_to_redeemed_benefits()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO redeemed_benefits (
    id, user_id, benefit_id, code, status, 
    redeemed_at, expiration_date, created_at, redemption_code
  )
  VALUES (
    NEW.id, NEW.user_id, NEW.benefit_id, NEW.code, 
    CASE WHEN NEW.is_used THEN 'used' ELSE 'active' END,
    NEW.created_at, NEW.expires_at, NEW.created_at, NEW.code
  )
  ON CONFLICT (id) DO UPDATE SET
    status = CASE WHEN NEW.is_used THEN 'used' ELSE 'active' END,
    used_at = NEW.used_at,
    updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar o trigger usando a função definida acima
DROP TRIGGER IF EXISTS sync_redemption_codes_trigger ON benefit_redemption_codes;
CREATE TRIGGER sync_redemption_codes_trigger
  AFTER INSERT OR UPDATE ON benefit_redemption_codes
  FOR EACH ROW
  EXECUTE FUNCTION sync_benefit_redemption_to_redeemed_benefits();

-- Inicializar com dados existentes (se houver)
INSERT INTO redeemed_benefits (
  id, user_id, benefit_id, code, status, 
  redeemed_at, expiration_date, created_at, redemption_code
)
SELECT 
  id, user_id, benefit_id, code,
  CASE WHEN is_used THEN 'used' ELSE 'active' END,
  created_at, expires_at, created_at, code
FROM 
  benefit_redemption_codes
ON CONFLICT (id) DO NOTHING;
