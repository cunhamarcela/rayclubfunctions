-- Estrutura da tabela 'user_progress' para armazenar os dados de progresso do usuário
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_workouts INTEGER NOT NULL DEFAULT 0,
  total_points INTEGER NOT NULL DEFAULT 0,
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  workouts_by_type JSONB NOT NULL DEFAULT '{}'::JSONB,
  total_duration INTEGER NOT NULL DEFAULT 0,
  completed_challenges INTEGER NOT NULL DEFAULT 0,
  days_trained_this_month INTEGER NOT NULL DEFAULT 0,
  monthly_workouts JSONB DEFAULT '{}'::JSONB,
  weekly_workouts JSONB DEFAULT '{}'::JSONB,
  last_workout TIMESTAMP WITH TIME ZONE,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Garantir que cada usuário tenha apenas um registro de progresso
  CONSTRAINT user_progress_user_id_unique UNIQUE (user_id)
);

-- Índice para melhorar a performance de consultas por user_id
CREATE INDEX IF NOT EXISTS user_progress_user_id_idx ON user_progress(user_id);

-- Trigger para atualizar a data de última atualização quando o registro for modificado
CREATE OR REPLACE FUNCTION update_user_progress_last_updated()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_progress_last_updated_trigger
BEFORE UPDATE ON user_progress
FOR EACH ROW
EXECUTE FUNCTION update_user_progress_last_updated();

-- Trigger para manter o valor do longest_streak atualizado
CREATE OR REPLACE FUNCTION update_user_progress_longest_streak()
RETURNS TRIGGER AS $$
BEGIN
  -- Se a sequência atual é maior que a maior sequência registrada, atualizar
  IF NEW.current_streak > NEW.longest_streak THEN
    NEW.longest_streak = NEW.current_streak;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_progress_longest_streak_trigger
BEFORE UPDATE ON user_progress
FOR EACH ROW
EXECUTE FUNCTION update_user_progress_longest_streak();

-- Trigger para criar um registro de progresso quando um novo usuário for criado
CREATE OR REPLACE FUNCTION create_user_progress_on_signup()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_progress (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_user_progress_on_signup_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION create_user_progress_on_signup(); 