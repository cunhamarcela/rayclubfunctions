-- Atualiza a tabela profiles para incluir novos campos
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS bio TEXT,
  ADD COLUMN IF NOT EXISTS phone TEXT,
  ADD COLUMN IF NOT EXISTS gender TEXT,
  ADD COLUMN IF NOT EXISTS birth_date TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS instagram TEXT;

-- Adiciona comentários aos novos campos para documentação
COMMENT ON COLUMN profiles.bio IS 'Biografia ou descrição do usuário';
COMMENT ON COLUMN profiles.phone IS 'Número de telefone do usuário';
COMMENT ON COLUMN profiles.gender IS 'Gênero do usuário';
COMMENT ON COLUMN profiles.birth_date IS 'Data de nascimento do usuário';
COMMENT ON COLUMN profiles.instagram IS 'Usuário do Instagram';

-- Atualiza a política de segurança RLS para permitir que o usuário atualize seus próprios dados
CREATE POLICY IF NOT EXISTS "Usuários podem atualizar seus próprios perfis"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Atualiza a trigger de criação de perfil para incluir os novos campos
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    email, 
    name, 
    created_at, 
    updated_at, 
    completed_workouts, 
    streak, 
    points, 
    favorite_workout_ids,
    bio,
    phone,
    gender,
    birth_date,
    instagram
  ) VALUES (
    NEW.id, 
    NEW.email, 
    NEW.raw_user_meta_data->>'full_name', 
    NEW.created_at, 
    NEW.created_at, 
    0, 
    0, 
    0, 
    '{}',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 