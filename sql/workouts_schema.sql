-- Tabela de treinos
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  type TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  difficulty TEXT NOT NULL,
  equipment JSONB,
  sections JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  creator_id UUID REFERENCES auth.users(id)
);

-- Tabela de categorias de treinos
CREATE TABLE workout_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  image_url TEXT,
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de histórico de treinos
CREATE TABLE workout_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  workout_id UUID REFERENCES workouts(id),
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  duration_minutes INTEGER,
  notes TEXT,
  rating INTEGER
);

-- Segurança RLS
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_history ENABLE ROW LEVEL SECURITY;

-- Políticas para treinos (públicos para leitura, restritos para escrita)
CREATE POLICY "Treinos são visíveis para todos os usuários autenticados"
  ON workouts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Apenas admins podem criar/editar treinos"
  ON workouts FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.is_admin = true
    )
  );

-- Políticas para categorias (visíveis para todos, apenas admins podem gerenciar)
CREATE POLICY "Categorias são visíveis para todos os usuários autenticados"
  ON workout_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Apenas admins podem gerenciar categorias"
  ON workout_categories FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.is_admin = true
    )
  );

-- Políticas para histórico (apenas o próprio usuário)
CREATE POLICY "Usuários podem ver apenas seu próprio histórico"
  ON workout_history FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Usuários podem inserir apenas seu próprio histórico"
  ON workout_history FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Usuários podem atualizar apenas seu próprio histórico"
  ON workout_history FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

-- Trigger para atualizar o updated_at automaticamente
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_workouts_updated_at
BEFORE UPDATE ON workouts
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Índices para melhor performance
CREATE INDEX idx_workout_type ON workouts(type);
CREATE INDEX idx_workout_difficulty ON workouts(difficulty);
CREATE INDEX idx_workout_history_user ON workout_history(user_id);
CREATE INDEX idx_workout_history_workout ON workout_history(workout_id); 