-- Remover funções existentes
DROP FUNCTION IF EXISTS get_current_streak(UUID, UUID);
DROP FUNCTION IF EXISTS update_challenge_streaks();
DROP FUNCTION IF EXISTS calculate_streak_bonus(INTEGER);
DROP FUNCTION IF EXISTS apply_streak_bonus();

-- Remover triggers existentes se necessário
DROP TRIGGER IF EXISTS update_streak_on_checkin ON challenge_check_ins;
DROP TRIGGER IF EXISTS apply_streak_bonus_on_checkin ON challenge_check_ins;

-- Função para calcular o streak atual de check-ins consecutivos
CREATE OR REPLACE FUNCTION get_current_streak(p_user_id UUID, p_challenge_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  streak INTEGER := 0;
  last_date DATE := NULL;
  current_date DATE := CURRENT_DATE;
  r RECORD;
BEGIN
  -- Obter check-ins ordenados por data
  FOR r IN 
    SELECT DISTINCT check_in_date::date as check_date
    FROM challenge_check_ins
    WHERE user_id = p_user_id AND challenge_id = p_challenge_id
    ORDER BY check_date DESC
  LOOP
    -- Se for o primeiro registro, inicializar last_date
    IF last_date IS NULL THEN
      last_date := r.check_date;
      streak := 1;
    -- Se a diferença entre datas for exatamente 1 dia, incrementar streak
    ELSIF last_date - r.check_date = 1 THEN
      streak := streak + 1;
      last_date := r.check_date;
    -- Se encontrar um gap, interromper contagem
    ELSE
      EXIT;
    END IF;
  END LOOP;
  
  -- Verificar se o último check-in foi no dia atual ou ontem
  -- Se não foi em nenhum desses dias, reset do streak
  IF last_date IS NOT NULL AND 
     (current_date - last_date) > 1 THEN
    streak := 0;
  END IF;
  
  RETURN streak;
END;
$$;

-- Função para atualizar o campo consecutive_days na tabela challenge_progress
CREATE OR REPLACE FUNCTION update_challenge_streaks()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_streak INTEGER;
BEGIN
  -- Calcular streak atual
  SELECT get_current_streak(NEW.user_id, NEW.challenge_id) INTO v_streak;
  
  -- Atualizar valor de consecutive_days
  UPDATE challenge_progress
  SET consecutive_days = v_streak
  WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
  
  RETURN NEW;
END;
$$;

-- Aplicar o trigger a cada novo check-in
CREATE TRIGGER update_streak_on_checkin
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_challenge_streaks(); 