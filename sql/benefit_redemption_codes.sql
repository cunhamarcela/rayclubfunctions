-- Tabela para armazenar códigos de resgate de benefícios
CREATE TABLE IF NOT EXISTS benefit_redemption_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  benefit_id UUID NOT NULL REFERENCES benefits(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  used_at TIMESTAMP WITH TIME ZONE,
  is_used BOOLEAN NOT NULL DEFAULT false,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() + interval '1 day'),
  
  -- Metadados opcionais
  device_info JSONB,
  ip_address TEXT,
  location_data JSONB
);

-- Índices para consultas comuns
CREATE INDEX IF NOT EXISTS idx_benefit_redemption_codes_code ON benefit_redemption_codes(code);
CREATE INDEX IF NOT EXISTS idx_benefit_redemption_codes_user ON benefit_redemption_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_benefit_redemption_codes_benefit ON benefit_redemption_codes(benefit_id);
CREATE INDEX IF NOT EXISTS idx_benefit_redemption_codes_is_used ON benefit_redemption_codes(is_used);

-- Política de segurança: apenas o usuário pode ver seus próprios códigos
CREATE POLICY "Users can view their own redemption codes"
ON benefit_redemption_codes
FOR SELECT
USING (auth.uid() = user_id);

-- Política de segurança: apenas o usuário pode inserir códigos para si mesmo
CREATE POLICY "Users can insert their own redemption codes"
ON benefit_redemption_codes
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Política de segurança: apenas o usuário pode atualizar seus próprios códigos
CREATE POLICY "Users can update their own redemption codes"
ON benefit_redemption_codes
FOR UPDATE
USING (auth.uid() = user_id);

-- Habilitar RLS
ALTER TABLE benefit_redemption_codes ENABLE ROW LEVEL SECURITY;

-- Função para limpar códigos de resgate expirados
CREATE OR REPLACE FUNCTION clean_expired_redemption_codes()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Marcar códigos expirados como usados
  UPDATE benefit_redemption_codes
  SET is_used = true,
      used_at = now()
  WHERE is_used = false
    AND expires_at < now();
END;
$$;

-- Trigger para limpar códigos expirados diariamente (deve ser configurado como job)
COMMENT ON FUNCTION clean_expired_redemption_codes() IS 'Esta função deve ser agendada para execução diária'; 