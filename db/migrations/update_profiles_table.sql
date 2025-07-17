-- Adicionar campos de metas e estatísticas à tabela profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS daily_water_goal INTEGER DEFAULT 8;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS daily_workout_goal INTEGER DEFAULT 1;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS weekly_workout_goal INTEGER DEFAULT 5;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS weight_goal DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS height DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS current_weight DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS preferred_workout_types TEXT[] DEFAULT '{}';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS stats JSONB DEFAULT '{
  "total_workouts": 0,
  "total_challenges": 0,
  "total_checkins": 0,
  "longest_streak": 0,
  "points_earned": 0,
  "completed_challenges": 0,
  "water_intake_average": 0
}';

-- Função para atualizar estatísticas do perfil quando um treino é registrado
CREATE OR REPLACE FUNCTION update_profile_stats_on_workout()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_stats JSONB;
BEGIN
  -- Obter estatísticas atuais
  SELECT stats INTO v_stats FROM profiles WHERE id = NEW.user_id;
  
  -- Atualizar contagem de treinos
  v_stats = jsonb_set(
    v_stats, 
    '{total_workouts}', 
    to_jsonb(COALESCE((v_stats->>'total_workouts')::int, 0) + 1)
  );
  
  -- Atualizar perfil
  UPDATE profiles
  SET stats = v_stats
  WHERE id = NEW.user_id;
  
  RETURN NEW;
END;
$$;

-- Trigger para atualizar estatísticas do perfil quando um treino é registrado
CREATE TRIGGER update_profile_stats_on_workout_trigger
AFTER INSERT ON user_workouts
FOR EACH ROW
EXECUTE FUNCTION update_profile_stats_on_workout();

-- Função para atualizar estatísticas do perfil quando um check-in de desafio é registrado
CREATE OR REPLACE FUNCTION update_profile_stats_on_checkin()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_stats JSONB;
  v_longest_streak INTEGER;
BEGIN
  -- Obter estatísticas atuais
  SELECT stats INTO v_stats FROM profiles WHERE id = NEW.user_id;
  
  -- Atualizar contagem de check-ins
  v_stats = jsonb_set(
    v_stats, 
    '{total_checkins}', 
    to_jsonb(COALESCE((v_stats->>'total_checkins')::int, 0) + 1)
  );
  
  -- Obter maior streak e atualizar se necessário
  SELECT consecutive_days INTO v_longest_streak 
  FROM challenge_progress 
  WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
  
  IF v_longest_streak > COALESCE((v_stats->>'longest_streak')::int, 0) THEN
    v_stats = jsonb_set(
      v_stats, 
      '{longest_streak}', 
      to_jsonb(v_longest_streak)
    );
  END IF;
  
  -- Atualizar pontos conquistados
  v_stats = jsonb_set(
    v_stats, 
    '{points_earned}', 
    to_jsonb(COALESCE((v_stats->>'points_earned')::int, 0) + NEW.points)
  );
  
  -- Atualizar perfil
  UPDATE profiles
  SET stats = v_stats
  WHERE id = NEW.user_id;
  
  RETURN NEW;
END;
$$;

-- Trigger para atualizar estatísticas do perfil quando um check-in de desafio é registrado
CREATE TRIGGER update_profile_stats_on_checkin_trigger
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_profile_stats_on_checkin();

-- Função para atualizar a média de consumo de água
CREATE OR REPLACE FUNCTION update_profile_water_intake_average()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_stats JSONB;
  v_avg DECIMAL;
BEGIN
  -- Calcular média dos últimos 7 dias
  SELECT COALESCE(AVG(cups), 0) INTO v_avg
  FROM water_intake
  WHERE user_id = NEW.user_id
  AND date >= (CURRENT_DATE - INTERVAL '7 days');
  
  -- Obter estatísticas atuais
  SELECT stats INTO v_stats FROM profiles WHERE id = NEW.user_id;
  
  -- Atualizar média de consumo de água
  v_stats = jsonb_set(
    v_stats, 
    '{water_intake_average}', 
    to_jsonb(v_avg)
  );
  
  -- Atualizar perfil
  UPDATE profiles
  SET stats = v_stats
  WHERE id = NEW.user_id;
  
  RETURN NEW;
END;
$$;

-- Trigger para atualizar estatísticas do perfil quando o consumo de água é registrado
CREATE TRIGGER update_profile_water_intake_trigger
AFTER INSERT OR UPDATE ON water_intake
FOR EACH ROW
EXECUTE FUNCTION update_profile_water_intake_average(); 