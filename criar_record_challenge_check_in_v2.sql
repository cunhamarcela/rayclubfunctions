-- Script para criar uma nova função record_challenge_check_in_v2 que não causa loop infinito na atualização de ranking

-- 1. Criação da função V2 que não depende de triggers e faz as atualizações necessárias manualmente
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
  challenge_id_param UUID,
  date_param TIMESTAMP WITH TIME ZONE,
  duration_minutes_param INTEGER,
  user_id_param UUID,
  workout_id_param TEXT,
  workout_name_param TEXT,
  workout_type_param TEXT
)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
  check_in_id UUID;
  challenge_points INTEGER;
  points_awarded INTEGER := 0;
  streak_count INTEGER := 0;
  last_check_in TIMESTAMP;
  streak_bonus INTEGER := 0;
  is_already_checked_in BOOLEAN := FALSE;
  current_streak INTEGER := 0;
  total_check_ins INTEGER := 0;
  user_name TEXT;
  user_photo_url TEXT;
BEGIN
  -- Log para debug
  RAISE NOTICE 'Iniciando função record_challenge_check_in_v2 para usuário % e desafio %', user_id_param, challenge_id_param;

  -- 1. Verificar se o usuário já fez check-in hoje
  IF EXISTS (
    SELECT 1 FROM challenge_check_ins 
    WHERE challenge_id = challenge_id_param 
    AND user_id = user_id_param 
    AND DATE(check_in_date) = DATE(date_param)
  ) THEN
    is_already_checked_in := TRUE;
    RAISE NOTICE 'Usuário já fez check-in hoje';
    RETURN jsonb_build_object(
      'success', FALSE,
      'message', 'Você já registrou um check-in para este desafio hoje',
      'is_already_checked_in', TRUE,
      'points_earned', 0,
      'streak', 0
    );
  END IF;

  -- 2. Obter os pontos do desafio
  SELECT points INTO challenge_points
  FROM challenges
  WHERE id = challenge_id_param;
  
  -- 3. Calcular bônus por streak (sequência de dias)
  -- Tenta obter o último check-in e os dias consecutivos
  SELECT cp.last_check_in, cp.consecutive_days 
  INTO last_check_in, current_streak
  FROM challenge_progress cp
  WHERE cp.challenge_id = challenge_id_param 
  AND cp.user_id = user_id_param;
  
  -- Se tiver um check-in anterior, verifica se foi ontem
  IF last_check_in IS NOT NULL THEN
    IF DATE(last_check_in) = DATE(date_param - INTERVAL '1 day') THEN
      -- Check-in de ontem, aumenta streak
      current_streak := current_streak + 1;
      RAISE NOTICE 'Streak aumentado para %', current_streak;
    ELSIF DATE(last_check_in) < DATE(date_param - INTERVAL '1 day') THEN
      -- Check-in de antes de ontem, reinicia streak
      current_streak := 1;
      RAISE NOTICE 'Streak reiniciado para 1';
    END IF;
  ELSE
    -- Primeiro check-in
    current_streak := 1;
    RAISE NOTICE 'Primeiro check-in, streak = 1';
  END IF;
  
  -- 4. Calcular bônus baseado no streak atual
  IF current_streak >= 30 THEN
    streak_bonus := 5;
  ELSIF current_streak >= 15 THEN
    streak_bonus := 3;
  ELSIF current_streak >= 7 THEN
    streak_bonus := 2;
  ELSIF current_streak >= 3 THEN
    streak_bonus := 1;
  END IF;
  
  -- 5. Definir pontos totais
  points_awarded := COALESCE(challenge_points, 10) + streak_bonus;
  RAISE NOTICE 'Pontos totais: % (base: % + bônus: %)', points_awarded, COALESCE(challenge_points, 10), streak_bonus;

  -- 6. Obter informações do usuário para o ranking
  SELECT p.name, p.photo_url 
  INTO user_name, user_photo_url
  FROM profiles p
  WHERE p.id = user_id_param;

  -- 7. Inserir o check-in 
  -- NOTA: Não é mais necessário desabilitar triggers, pois eles foram removidos
  INSERT INTO challenge_check_ins (
    challenge_id, 
    user_id, 
    workout_id, 
    workout_name, 
    workout_type, 
    check_in_date, 
    duration_minutes
  )
  VALUES (
    challenge_id_param,
    user_id_param,
    workout_id_param,
    workout_name_param,
    workout_type_param,
    date_param,
    duration_minutes_param
  )
  RETURNING id INTO check_in_id;
  
  RAISE NOTICE 'Check-in inserido com ID: %', check_in_id;

  -- 8. Atualizar o progresso do desafio
  IF EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = challenge_id_param AND user_id = user_id_param) THEN
    -- Obter contagem atual
    SELECT COALESCE(check_ins_count, 0) 
    INTO total_check_ins
    FROM challenge_progress
    WHERE challenge_id = challenge_id_param AND user_id = user_id_param;
    
    total_check_ins := total_check_ins + 1;
    
    -- Atualizar progresso existente
    UPDATE challenge_progress
    SET 
      points = points + points_awarded,
      consecutive_days = current_streak,
      last_check_in = date_param,
      check_ins_count = total_check_ins,
      updated_at = NOW()
    WHERE 
      challenge_id = challenge_id_param AND 
      user_id = user_id_param;
      
    RAISE NOTICE 'Progresso atualizado para o usuário, novo total de checkins: %', total_check_ins;
  ELSE
    -- Criar novo progresso
    INSERT INTO challenge_progress (
      challenge_id,
      user_id,
      user_name,
      user_photo_url,
      points,
      consecutive_days,
      last_check_in,
      check_ins_count,
      created_at,
      updated_at
    ) VALUES (
      challenge_id_param,
      user_id_param,
      user_name,
      user_photo_url,
      points_awarded,
      current_streak,
      date_param,
      1,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE 'Novo progresso criado para o usuário';
  END IF;

  -- 9. Verificar se usuário já está como participante
  IF NOT EXISTS (SELECT 1 FROM challenge_participants WHERE challenge_id = challenge_id_param AND user_id = user_id_param) THEN
    -- Adicionar usuário como participante
    INSERT INTO challenge_participants (
      challenge_id,
      user_id,
      joined_at,
      created_at,
      updated_at
    ) VALUES (
      challenge_id_param,
      user_id_param,
      NOW(),
      NOW(),
      NOW()
    );
    
    RAISE NOTICE 'Usuário adicionado como participante do desafio';
  END IF;

  -- 10. Atualizar contagem de participantes no desafio
  UPDATE challenges
  SET participants_count = (
    SELECT COUNT(DISTINCT user_id) 
    FROM challenge_participants 
    WHERE challenge_id = challenge_id_param
  )
  WHERE id = challenge_id_param;
  
  RAISE NOTICE 'Contagem de participantes atualizada';

  -- 11. Atualizar user_progress (sem usar trigger)
  IF EXISTS (SELECT 1 FROM user_progress WHERE user_id = user_id_param) THEN
    UPDATE user_progress
    SET 
      points = points + points_awarded,
      total_check_ins = total_check_ins + 1,
      updated_at = NOW()
    WHERE 
      user_id = user_id_param;
      
    RAISE NOTICE 'User progress atualizado';
  ELSE
    INSERT INTO user_progress (
      user_id,
      points,
      total_check_ins,
      created_at,
      updated_at
    ) VALUES (
      user_id_param,
      points_awarded,
      1,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE 'Novo user progress criado';
  END IF;

  -- 12. Atualizar ranking do desafio (sem loop)
  -- Calculamos as posições baseadas nos pontos
  WITH ranked_users AS (
    SELECT 
      id, 
      ROW_NUMBER() OVER (ORDER BY points DESC) AS new_position
    FROM 
      challenge_progress
    WHERE 
      challenge_id = challenge_id_param
  )
  UPDATE challenge_progress cp
  SET position = ru.new_position
  FROM ranked_users ru
  WHERE cp.id = ru.id
  AND cp.challenge_id = challenge_id_param;
  
  RAISE NOTICE 'Ranking atualizado';

  -- 13. Retornar o resultado
  RETURN jsonb_build_object(
    'success', TRUE,
    'message', 'Check-in registrado com sucesso',
    'check_in_id', check_in_id,
    'points_earned', points_awarded,
    'streak', current_streak,
    'is_already_checked_in', FALSE
  );
EXCEPTION 
  WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao registrar check-in: %', SQLERRM;
    RETURN jsonb_build_object(
      'success', FALSE,
      'message', 'Erro ao registrar check-in: ' || SQLERRM,
      'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- IMPORTANTE: Não é mais necessário desabilitar triggers, pois eles foram removidos
-- Os comandos abaixo estavam presentes no script original mas não são mais necessários:
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER tr_update_user_progress_on_checkin;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER update_progress_after_checkin;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER trg_update_progress_on_check_in;

-- Documentação da arquitetura atual:
COMMENT ON TABLE challenge_check_ins IS 'Registros de check-in em desafios. A atualização do progresso é feita diretamente pela função record_challenge_check_in.';
COMMENT ON TABLE challenge_progress IS 'Progresso dos usuários em desafios. Esta tabela é atualizada diretamente pela função record_challenge_check_in.';
COMMENT ON FUNCTION record_challenge_check_in_v2(UUID, TIMESTAMP WITH TIME ZONE, INTEGER, UUID, TEXT, TEXT, TEXT) IS 
'Função para registrar check-ins em desafios que faz todo o processamento necessário sem depender de triggers externos.';

-- Fim do script 