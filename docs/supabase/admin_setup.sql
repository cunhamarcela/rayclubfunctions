-- 1. Adicionar coluna is_admin à tabela de usuários
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 2. Criar índice para otimizar consultas de verificação de admin
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON "users" (id, is_admin);

-- 3. Criar função para verificar se um usuário é administrador
CREATE OR REPLACE FUNCTION is_admin(user_id UUID) 
RETURNS BOOLEAN AS $$
DECLARE
  admin_status BOOLEAN;
BEGIN
  SELECT is_admin INTO admin_status FROM "users" WHERE id = user_id;
  RETURN COALESCE(admin_status, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Políticas RLS para gerenciamento de benefícios por administradores

-- Política para visualizar todos os benefícios (inclusive de outros usuários)
CREATE POLICY admin_benefits_view_policy ON "benefits"
FOR SELECT
USING (
  is_admin(auth.uid())
);

-- Política para editar benefícios
CREATE POLICY admin_benefits_update_policy ON "benefits"
FOR UPDATE
USING (
  is_admin(auth.uid())
);

-- Política para visualizar todos os benefícios resgatados (de todos os usuários)
CREATE POLICY admin_redeemed_benefits_view_policy ON "redeemed_benefits"
FOR SELECT
USING (
  is_admin(auth.uid())
);

-- Política para editar benefícios resgatados (extensão de validade)
CREATE POLICY admin_redeemed_benefits_update_policy ON "redeemed_benefits"
FOR UPDATE
USING (
  is_admin(auth.uid())
);

-- 5. Função para definir um usuário como administrador (usar no Console do Supabase)
CREATE OR REPLACE FUNCTION set_user_as_admin(target_user_id UUID, admin_status BOOLEAN)
RETURNS VOID AS $$
BEGIN
  -- Verificar se o usuário atual é admin
  IF NOT is_admin(auth.uid()) THEN
    RAISE EXCEPTION 'Apenas administradores podem definir status de admin';
  END IF;

  -- Atualizar status de admin do usuário alvo
  UPDATE "users" SET is_admin = admin_status WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Migração para definir o primeiro administrador
-- IMPORTANTE: Executar este comando manualmente substituindo 'SEU_EMAIL_AQUI' pelo email do admin
UPDATE "users" SET is_admin = TRUE WHERE email = 'SEU_EMAIL_AQUI' AND id = auth.uid(); 