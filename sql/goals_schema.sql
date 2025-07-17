-- Tabela para as metas de usuário
CREATE TABLE user_goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL, -- 'weight', 'workout', 'steps', 'nutrition', 'custom'
  target DECIMAL NOT NULL,
  progress DECIMAL NOT NULL DEFAULT 0,
  unit TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Índices para a tabela de metas
CREATE INDEX user_goals_user_id_idx ON user_goals (user_id);
CREATE INDEX user_goals_type_idx ON user_goals (type);
CREATE INDEX user_goals_completed_idx ON user_goals (user_id, completed_at);

-- Políticas de segurança para metas
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar suas próprias metas"
ON user_goals FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar suas próprias metas"
ON user_goals FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias metas"
ON user_goals FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir suas próprias metas"
ON user_goals FOR DELETE
USING (auth.uid() = user_id);

-- Tabela para registros de consumo de água
CREATE TABLE water_intake (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  current_glasses INTEGER NOT NULL DEFAULT 0,
  daily_goal INTEGER NOT NULL DEFAULT 8,
  glass_size INTEGER NOT NULL DEFAULT 250,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  
  -- Garantir um registro único por usuário/dia
  UNIQUE (user_id, date)
);

-- Índices para consumo de água
CREATE INDEX water_intake_user_id_idx ON water_intake (user_id);
CREATE INDEX water_intake_date_idx ON water_intake (date);

-- Políticas de segurança para consumo de água
ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar seus próprios registros de água"
ON water_intake FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seus próprios registros de água"
ON water_intake FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios registros de água"
ON water_intake FOR UPDATE
USING (auth.uid() = user_id);

-- Tabela para estatísticas de treino dos usuários
CREATE TABLE workout_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_workouts INTEGER NOT NULL DEFAULT 0,
  month_workouts INTEGER NOT NULL DEFAULT 0,
  week_workouts INTEGER NOT NULL DEFAULT 0,
  best_streak INTEGER NOT NULL DEFAULT 0,
  current_streak INTEGER NOT NULL DEFAULT 0,
  frequency_percentage DECIMAL NOT NULL DEFAULT 0,
  total_minutes INTEGER NOT NULL DEFAULT 0,
  month_workout_days INTEGER NOT NULL DEFAULT 0,
  week_workout_days INTEGER NOT NULL DEFAULT 0,
  last_updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Políticas de segurança para estatísticas de treino
ALTER TABLE workout_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar suas próprias estatísticas"
ON workout_stats FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias estatísticas"
ON workout_stats FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir suas próprias estatísticas"
ON workout_stats FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Tabela para desafios
CREATE TABLE challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  image_url TEXT,
  reward_description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Índices para desafios
CREATE INDEX challenges_active_dates_idx ON challenges (is_active, start_date, end_date);

-- Tabela para participação em desafios
CREATE TABLE challenge_participations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  current_progress DECIMAL NOT NULL DEFAULT 0,
  rank INTEGER,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completion_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  
  -- Garantir participação única por usuário/desafio
  UNIQUE (user_id, challenge_id)
);

-- Índices para participação em desafios
CREATE INDEX challenge_participations_user_id_idx ON challenge_participations (user_id);
CREATE INDEX challenge_participations_challenge_id_idx ON challenge_participations (challenge_id);
CREATE INDEX challenge_participations_completed_idx ON challenge_participations (user_id, is_completed);

-- Políticas de segurança para participação em desafios
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar suas próprias participações"
ON challenge_participations FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir suas próprias participações"
ON challenge_participations FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias participações"
ON challenge_participations FOR UPDATE
USING (auth.uid() = user_id);

-- Tabela para benefícios disponíveis
CREATE TABLE benefits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  code_prefix TEXT NOT NULL,
  logo_url TEXT,
  expiration_days INTEGER NOT NULL DEFAULT 30,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela para benefícios resgatados
CREATE TABLE redeemed_benefits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  benefit_id UUID NOT NULL REFERENCES benefits(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active', -- 'active', 'used', 'expired'
  expiration_date TIMESTAMP WITH TIME ZONE NOT NULL,
  redeemed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  used_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Índices para benefícios resgatados
CREATE INDEX redeemed_benefits_user_id_idx ON redeemed_benefits (user_id);
CREATE INDEX redeemed_benefits_benefit_id_idx ON redeemed_benefits (benefit_id);
CREATE INDEX redeemed_benefits_status_idx ON redeemed_benefits (status);
CREATE INDEX redeemed_benefits_expiration_idx ON redeemed_benefits (user_id, status, expiration_date);

-- Políticas de segurança para benefícios resgatados
ALTER TABLE redeemed_benefits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar seus próprios benefícios"
ON redeemed_benefits FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir seus próprios benefícios"
ON redeemed_benefits FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios benefícios"
ON redeemed_benefits FOR UPDATE
USING (auth.uid() = user_id);

-- Função para calcular estatísticas de treino
CREATE OR REPLACE FUNCTION calculate_workout_stats(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_now TIMESTAMP WITH TIME ZONE := NOW();
  v_month_start TIMESTAMP WITH TIME ZONE := DATE_TRUNC('month', v_now);
  v_week_start TIMESTAMP WITH TIME ZONE := DATE_TRUNC('week', v_now);
  v_total_workouts INTEGER;
  v_month_workouts INTEGER;
  v_week_workouts INTEGER;
  v_total_minutes INTEGER;
  v_current_streak INTEGER := 0;
  v_best_streak INTEGER := 0;
  v_temp_streak INTEGER := 0;
  v_prev_date DATE := NULL;
  v_workout_date DATE;
  v_frequency DECIMAL;
  v_month_workout_days INTEGER;
  v_week_workout_days INTEGER;
BEGIN
  -- Contar treinos
  SELECT COUNT(*) INTO v_total_workouts 
  FROM workout_records 
  WHERE user_id = p_user_id;
  
  -- Treinos do mês atual
  SELECT COUNT(*) INTO v_month_workouts 
  FROM workout_records 
  WHERE user_id = p_user_id 
  AND workout_date >= v_month_start;
  
  -- Treinos da semana atual
  SELECT COUNT(*) INTO v_week_workouts 
  FROM workout_records 
  WHERE user_id = p_user_id 
  AND workout_date >= v_week_start;
  
  -- Total de minutos
  SELECT COALESCE(SUM(duration_minutes), 0) INTO v_total_minutes 
  FROM workout_records 
  WHERE user_id = p_user_id;
  
  -- Dias distintos com treino no mês
  SELECT COUNT(DISTINCT DATE(workout_date)) INTO v_month_workout_days
  FROM workout_records 
  WHERE user_id = p_user_id 
  AND workout_date >= v_month_start;
  
  -- Dias distintos com treino na semana
  SELECT COUNT(DISTINCT DATE(workout_date)) INTO v_week_workout_days
  FROM workout_records 
  WHERE user_id = p_user_id 
  AND workout_date >= v_week_start;
  
  -- Calcular sequência atual e melhor sequência
  FOR v_workout_date IN 
    SELECT DISTINCT DATE(workout_date) 
    FROM workout_records 
    WHERE user_id = p_user_id 
    ORDER BY DATE(workout_date) DESC
  LOOP
    IF v_prev_date IS NULL THEN
      v_temp_streak := 1;
      v_prev_date := v_workout_date;
    ELSIF v_prev_date - v_workout_date = 1 THEN
      v_temp_streak := v_temp_streak + 1;
      v_prev_date := v_workout_date;
    ELSE
      v_prev_date := v_workout_date;
      v_temp_streak := 1;
    END IF;
    
    -- Atualizar sequência atual (apenas para a primeira iteração)
    IF v_current_streak = 0 THEN
      -- Verificar se o último treino foi ontem ou hoje
      IF v_workout_date = CURRENT_DATE OR v_workout_date = CURRENT_DATE - 1 THEN
        v_current_streak := v_temp_streak;
      END IF;
    END IF;
    
    -- Atualizar melhor sequência
    IF v_temp_streak > v_best_streak THEN
      v_best_streak := v_temp_streak;
    END IF;
  END LOOP;
  
  -- Calcular frequência (com base em meta de 20 treinos/mês)
  v_frequency := CASE 
    WHEN v_month_workouts >= 20 THEN 100.0
    ELSE (v_month_workouts::decimal / 20.0) * 100.0
  END;
  
  -- Inserir ou atualizar as estatísticas
  INSERT INTO workout_stats (
    user_id, 
    total_workouts, 
    month_workouts, 
    week_workouts, 
    best_streak, 
    current_streak, 
    frequency_percentage, 
    total_minutes,
    month_workout_days,
    week_workout_days,
    last_updated_at
  ) VALUES (
    p_user_id, 
    v_total_workouts, 
    v_month_workouts, 
    v_week_workouts, 
    v_best_streak, 
    v_current_streak, 
    v_frequency, 
    v_total_minutes,
    v_month_workout_days,
    v_week_workout_days,
    v_now
  ) ON CONFLICT (user_id) DO UPDATE SET
    total_workouts = v_total_workouts,
    month_workouts = v_month_workouts,
    week_workouts = v_week_workouts,
    best_streak = v_best_streak,
    current_streak = v_current_streak,
    frequency_percentage = v_frequency,
    total_minutes = v_total_minutes,
    month_workout_days = v_month_workout_days,
    week_workout_days = v_week_workout_days,
    last_updated_at = v_now;
END;
$$ LANGUAGE plpgsql;

-- Gatilho para atualizar estatísticas quando um treino for inserido ou atualizado
CREATE OR REPLACE FUNCTION update_workout_stats_trigger()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM calculate_workout_stats(NEW.user_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER workout_records_stats_trigger
AFTER INSERT OR UPDATE OR DELETE ON workout_records
FOR EACH ROW EXECUTE PROCEDURE update_workout_stats_trigger();

-- Função para atualizar status de benefícios expirados
CREATE OR REPLACE FUNCTION update_expired_benefits()
RETURNS void AS $$
BEGIN
  UPDATE redeemed_benefits
  SET 
    status = 'expired',
    updated_at = NOW()
  WHERE 
    status = 'active' AND 
    expiration_date < NOW();
END;
$$ LANGUAGE plpgsql;

-- Criar um job para executar diariamente
SELECT cron.schedule(
  'update-expired-benefits',
  '0 0 * * *',  -- Executar à meia-noite todos os dias
  $$SELECT update_expired_benefits()$$
); 