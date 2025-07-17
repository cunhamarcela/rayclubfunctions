-- Atualização da tabela de perfis para a Fase 3
-- Adicionar campo is_admin para controle de permissões

-- Adicionar is_admin se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'is_admin'
    ) THEN
        ALTER TABLE profiles ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT false;
    END IF;
END $$;

-- Atualizar alguns usuários como administradores para testes
-- Substitua 'your-admin-user-id-here' pelo ID real do usuário que deve ser admin
UPDATE profiles
SET is_admin = true
WHERE id IN ('01d4a292-1873-4af6-948b-a55eed56d6b9')
AND NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE is_admin = true
    LIMIT 1
);

-- Criar índice para consultas rápidas por administradores
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON profiles(is_admin);

-- Comentário para documentação
COMMENT ON COLUMN profiles.is_admin IS 'Indica se o usuário tem permissões de administrador no sistema';

-- Remover política existente se houver
DROP POLICY IF EXISTS "Admins can update admin status" ON profiles;

-- Adicionar política para que apenas administradores possam atualizar perfis
CREATE POLICY "Admins can update profiles" 
ON profiles
FOR UPDATE 
USING (
    -- Usuário pode atualizar seu próprio perfil
    (auth.uid() = id) 
    OR (
        -- Ou usuário é um administrador
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.is_admin = true
        )
    )
);

-- Adicionar política de leitura para todos
DROP POLICY IF EXISTS "Anyone can read profiles" ON profiles;
CREATE POLICY "Anyone can read profiles" 
ON profiles
FOR SELECT
USING (true);

-- Garantir que RLS esteja ativado
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY; 