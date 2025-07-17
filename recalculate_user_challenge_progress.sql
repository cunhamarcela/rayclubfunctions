-- Função para recalcular o progresso de um usuário em um desafio
-- Isso será útil para forçar atualizações quando houver inconsistências

-- Primeiro remover a função se ela já existir
DROP FUNCTION IF EXISTS recalculate_user_challenge_progress;

-- Criar a função atualizada
CREATE OR REPLACE FUNCTION recalculate_user_challenge_progress(
  user_id_param TEXT,
  challenge_id_param TEXT
) 
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  challenge_record RECORD;
  check_ins_count INTEGER;
  total_points INTEGER := 0;
  streak_count INTEGER := 0;
  last_check_in_date DATE := NULL;
  progress_exists BOOLEAN;
  position_in_ranking INTEGER := 0;
BEGIN
  -- Verificar se o desafio existe
  SELECT * INTO challenge_record 
  FROM challenges 
  WHERE id = challenge_id_param;
  
  IF challenge_record IS NULL THEN
    RAISE EXCEPTION 'Desafio não encontrado';
  END IF;
  
  -- Verificar se já existe registro de progresso
  SELECT EXISTS(
    SELECT 1 
    FROM challenge_progress 
    WHERE user_id = user_id_param AND challenge_id = challenge_id_param
  ) INTO progress_exists;
  
  -- Contar check-ins para este usuário neste desafio
  SELECT COUNT(*) INTO check_ins_count
  FROM challenge_check_ins
  WHERE user_id = user_id_param 
    AND challenge_id = challenge_id_param
    AND status = 'confirmed';
  
  -- Calcular pontos (cada check-in vale 10 pontos)
  total_points := check_ins_count * 10;
  
  -- Calcular streak atual
  WITH check_in_dates AS (
    SELECT DISTINCT DATE(check_in_date) AS check_date
    FROM challenge_check_ins
    WHERE user_id = user_id_param 
      AND challenge_id = challenge_id_param
      AND status = 'confirmed'
    ORDER BY check_date DESC
  ),
  date_with_gaps AS (
    SELECT 
      check_date,
      LAG(check_date, 1) OVER (ORDER BY check_date DESC) - check_date AS day_diff
    FROM check_in_dates
  ),
  streak_group AS (
    SELECT 
      check_date,
      SUM(CASE WHEN day_diff = -1 OR day_diff IS NULL THEN 0 ELSE 1 END) 
        OVER (ORDER BY check_date DESC) AS grp
    FROM date_with_gaps
  )
  SELECT 
    COUNT(*) INTO streak_count
  FROM streak_group
  WHERE grp = 0;
  
  -- Obter a data do último check-in
  SELECT MAX(DATE(check_in_date)) INTO last_check_in_date
  FROM challenge_check_ins
  WHERE user_id = user_id_param 
    AND challenge_id = challenge_id_param
    AND status = 'confirmed';
  
  -- Calcular a posição no ranking
  WITH user_points AS (
    SELECT 
      user_id,
      SUM(CASE WHEN status = 'confirmed' THEN 10 ELSE 0 END) AS points
    FROM challenge_check_ins
    WHERE challenge_id = challenge_id_param
    GROUP BY user_id
    ORDER BY points DESC
  )
  SELECT 
    row_number() OVER () INTO position_in_ranking
  FROM user_points
  WHERE user_id = user_id_param;
  
  -- Se não houver progresso, criar um novo registro
  IF NOT progress_exists THEN
    INSERT INTO challenge_progress (
      id,
      user_id,
      challenge_id,
      points,
      check_ins,
      streak,
      last_check_in,
      position,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid()::text,
      user_id_param,
      challenge_id_param,
      total_points,
      check_ins_count,
      streak_count,
      last_check_in_date,
      position_in_ranking,
      NOW(),
      NOW()
    );
  -- Senão, atualizar o registro existente
  ELSE
    UPDATE challenge_progress
    SET 
      points = total_points,
      check_ins = check_ins_count,
      streak = streak_count,
      last_check_in = last_check_in_date,
      position = position_in_ranking,
      updated_at = NOW()
    WHERE 
      user_id = user_id_param AND 
      challenge_id = challenge_id_param;
  END IF;
  
  RETURN TRUE;
END;
$$; 