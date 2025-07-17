-- Criação da tabela workout_records
CREATE TABLE IF NOT EXISTS workout_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  workout_id UUID REFERENCES workouts(id),
  workout_name TEXT NOT NULL,
  workout_type TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER NOT NULL,
  is_completed BOOLEAN DEFAULT true,
  notes TEXT,
  image_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add completion_status column
ALTER TABLE workout_records ADD COLUMN completion_status TEXT DEFAULT 'completed';

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_workout_records_user_id 
  ON workout_records(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_records_date 
  ON workout_records(date);
CREATE INDEX IF NOT EXISTS idx_workout_records_workout_id 
  ON workout_records(workout_id);

-- Habilitar RLS
ALTER TABLE workout_records ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem ver seus próprios registros"
  ON workout_records FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Usuários podem criar seus próprios registros"
  ON workout_records FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Usuários podem atualizar seus próprios registros"
  ON workout_records FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Usuários podem excluir seus próprios registros"
  ON workout_records FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Trigger para garantir que a data de criação seja sempre preenchida
CREATE OR REPLACE FUNCTION set_workout_record_created_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.created_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_workout_record_created_at ON workout_records;
CREATE TRIGGER trigger_set_workout_record_created_at
BEFORE INSERT ON workout_records
FOR EACH ROW
EXECUTE FUNCTION set_workout_record_created_at(); 