-- Tabela para armazenar informações de refeições
CREATE TABLE IF NOT EXISTS meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  calories INTEGER,
  protein DECIMAL(10, 2),
  carbs DECIMAL(10, 2),
  fat DECIMAL(10, 2),
  meal_time TIMESTAMP WITH TIME ZONE NOT NULL,
  meal_type TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  is_favorite BOOLEAN DEFAULT FALSE,
  tags TEXT[],
  metadata JSONB DEFAULT '{}'::JSONB
);

-- Índices para melhorar a performance de consultas comuns
CREATE INDEX IF NOT EXISTS meals_user_id_idx ON meals(user_id);
CREATE INDEX IF NOT EXISTS meals_meal_time_idx ON meals(meal_time);
CREATE INDEX IF NOT EXISTS meals_meal_type_idx ON meals(meal_type);
CREATE INDEX IF NOT EXISTS meals_tags_idx ON meals USING GIN(tags);

-- Trigger para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_meals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_meals_updated_at ON meals;
CREATE TRIGGER trigger_meals_updated_at
BEFORE UPDATE ON meals
FOR EACH ROW
EXECUTE FUNCTION update_meals_updated_at();

-- Políticas de segurança em nível de linha (RLS)
-- Habilitar RLS na tabela
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários comuns
-- Os usuários só podem ver e modificar suas próprias refeições
CREATE POLICY meals_select_policy ON meals
  FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY meals_insert_policy ON meals
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY meals_update_policy ON meals
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY meals_delete_policy ON meals
  FOR DELETE
  USING (user_id = auth.uid());

-- Políticas para administradores (via claims)
-- Administradores podem ver todas as refeições
CREATE POLICY meals_admin_select_policy ON meals
  FOR SELECT
  USING (
    (SELECT is_admin FROM users WHERE id = auth.uid())
  );

-- Adicionar função para buscar refeições por período
CREATE OR REPLACE FUNCTION get_meals_by_date_range(
  user_id_param UUID,
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE
)
RETURNS SETOF meals AS $$
DECLARE
  is_admin_user BOOLEAN;
BEGIN
  -- Verificar se o usuário é admin
  SELECT is_admin INTO is_admin_user FROM users WHERE id = auth.uid();
  
  -- Validar que o usuário tem permissão (é o próprio usuário ou é admin)
  IF user_id_param = auth.uid() OR is_admin_user = TRUE THEN
    RETURN QUERY
    SELECT *
    FROM meals
    WHERE user_id = user_id_param
      AND meal_time >= start_date
      AND meal_time <= end_date
    ORDER BY meal_time ASC;
  ELSE
    -- Se não for o próprio usuário ou admin, não retornar nenhum dado
    RAISE EXCEPTION 'Acesso não autorizado';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 