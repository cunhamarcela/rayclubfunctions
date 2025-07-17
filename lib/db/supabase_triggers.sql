-- Triggers para o banco de dados Supabase do Ray Club App
-- Este arquivo contém os triggers necessários para:
-- 1. Atualização automática de rankings
-- 2. Integridade de dados entre tabelas relacionadas
-- 3. Cálculo de progresso em desafios

-- Trigger para atualizar a data de modificação automaticamente
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de atualização de timestamps em todas as tabelas principais
CREATE TRIGGER update_user_profiles_modtime
BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_challenges_modtime
BEFORE UPDATE ON challenges
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_benefits_modtime
BEFORE UPDATE ON benefits
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Trigger para calcular pontuação e posição no ranking quando um check-in é registrado
CREATE OR REPLACE FUNCTION update_challenge_ranking() 
RETURNS TRIGGER AS $$
DECLARE
  challenge_record RECORD;
  total_points INTEGER;
BEGIN
  -- Obter informações do desafio
  SELECT * INTO challenge_record FROM challenges WHERE id = NEW.challenge_id;
  
  -- Calcular pontos: check-ins * pontos por check-in + bonus de streak
  SELECT COUNT(*) * challenge_record.points_per_checkin INTO total_points
  FROM challenge_check_ins 
  WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
  
  -- Verificar se já existe um registro de progresso
  IF EXISTS (SELECT 1 FROM challenge_progress WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id) THEN
    -- Atualizar o progresso existente
    UPDATE challenge_progress
    SET 
      points = total_points,
      checkins_count = checkins_count + 1,
      last_checkin_at = NOW(),
      updated_at = NOW()
    WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
  ELSE
    -- Inserir novo registro de progresso
    INSERT INTO challenge_progress(
      user_id, 
      challenge_id, 
      points, 
      checkins_count, 
      last_checkin_at,
      created_at,
      updated_at
    )
    VALUES(
      NEW.user_id, 
      NEW.challenge_id, 
      total_points, 
      1, 
      NOW(),
      NOW(),
      NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de ranking a cada novo check-in
CREATE TRIGGER trigger_update_challenge_ranking
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_challenge_ranking();

-- Trigger para atualizar a contagem de participantes em um desafio
CREATE OR REPLACE FUNCTION update_challenge_participants_count() 
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar contagem de participantes no desafio
  UPDATE challenges
  SET participants_count = (
    SELECT COUNT(DISTINCT user_id) 
    FROM challenge_participants 
    WHERE challenge_id = NEW.challenge_id
  )
  WHERE id = NEW.challenge_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de contagem de participantes
CREATE TRIGGER trigger_update_challenge_participants
AFTER INSERT OR DELETE ON challenge_participants
FOR EACH ROW
EXECUTE FUNCTION update_challenge_participants_count();

-- Trigger para atualizar pontos do usuário quando completa um desafio
CREATE OR REPLACE FUNCTION update_user_points_on_challenge_completion() 
RETURNS TRIGGER AS $$
DECLARE
  challenge_record RECORD;
BEGIN
  -- Verificar se o status foi alterado para 'completed'
  IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status <> 'completed') THEN
    -- Obter informações do desafio
    SELECT * INTO challenge_record FROM challenges WHERE id = NEW.challenge_id;
    
    -- Adicionar pontos de conclusão ao perfil do usuário
    UPDATE user_profiles
    SET 
      points = points + challenge_record.completion_points,
      challenges_completed = challenges_completed + 1,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de pontos por conclusão de desafio
CREATE TRIGGER trigger_update_user_points_challenge
AFTER UPDATE ON challenge_progress
FOR EACH ROW
EXECUTE FUNCTION update_user_points_on_challenge_completion();

-- Trigger para atualizar contagem de cupons resgatados
CREATE OR REPLACE FUNCTION update_benefit_redeemed_count() 
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar contagem de resgates no benefício
  UPDATE benefits
  SET redeemed_count = redeemed_count + 1
  WHERE id = NEW.benefit_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de contagem de resgates
CREATE TRIGGER trigger_update_benefit_redeemed_count
AFTER INSERT ON redeemed_benefits
FOR EACH ROW
EXECUTE FUNCTION update_benefit_redeemed_count();

-- Trigger para verificar expiração de benefícios
CREATE OR REPLACE FUNCTION check_benefit_expiration() 
RETURNS TRIGGER AS $$
BEGIN
  -- Verificar se o benefício está expirado
  IF NEW.expiration_date < NOW() THEN
    NEW.status = 'expired';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de verificação de expiração
CREATE TRIGGER trigger_check_benefit_expiration
BEFORE INSERT OR UPDATE ON redeemed_benefits
FOR EACH ROW
EXECUTE FUNCTION check_benefit_expiration();

-- Trigger para incrementar streak quando usuário faz check-in diário
CREATE OR REPLACE FUNCTION update_user_streak() 
RETURNS TRIGGER AS $$
DECLARE
  last_activity_date DATE;
  current_date DATE := CURRENT_DATE;
BEGIN
  -- Obter a data da última atividade do usuário
  SELECT MAX(created_at)::DATE INTO last_activity_date
  FROM user_activities
  WHERE user_id = NEW.user_id AND created_at < CURRENT_DATE;

  -- Se última atividade foi ontem, incrementar streak
  IF last_activity_date = (current_date - INTERVAL '1 day')::DATE THEN
    UPDATE user_profiles
    SET 
      streak = streak + 1,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  -- Se não houve atividade ontem (mas há atividade hoje), resetar streak para 1
  ELSIF last_activity_date < (current_date - INTERVAL '1 day')::DATE OR last_activity_date IS NULL THEN
    UPDATE user_profiles
    SET 
      streak = 1,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger de streak
CREATE TRIGGER trigger_update_user_streak
AFTER INSERT ON user_activities
FOR EACH ROW
EXECUTE FUNCTION update_user_streak(); 