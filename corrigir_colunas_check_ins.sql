-- Script para corrigir inconsistência entre nomes de colunas em user_progress e challenge_progress
-- Resolve o erro de coluna inexistente que ocorre no registro de check-ins de desafios

-- 1. Primeiro vamos verificar se a coluna total_check_ins existe em user_progress
-- Se não existir, vamos criá-la
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'total_check_ins'
    ) THEN
        ALTER TABLE user_progress ADD COLUMN total_check_ins INTEGER DEFAULT 0;
        
        -- Opcionalmente, podemos preencher com dados existentes se houver uma fonte confiável
        -- Por exemplo, contar os check-ins existentes para cada usuário
        UPDATE user_progress up
        SET total_check_ins = COALESCE(
            (SELECT COUNT(*) 
             FROM challenge_check_ins cci 
             WHERE cci.user_id = up.user_id),
            0
        );
    END IF;
END $$;

-- 2. Agora vamos corrigir a função update_user_progress_on_checkin
-- para garantir que ela sempre funcione, independente de qual coluna existe
CREATE OR REPLACE FUNCTION update_user_progress_on_checkin()
RETURNS TRIGGER AS $$
DECLARE
    challenge_data record;
    points_earned integer := 10; -- Pontos padrão por check-in
    challenge_days integer;
    current_streak integer;
    is_challenge_complete boolean := false;
    challenge_requirements jsonb;
BEGIN
    -- Obter dados do desafio
    SELECT c.*, 
           DATE_PART('day', c.end_date::timestamp - c.start_date::timestamp) + 1 AS days,
           c.requirements AS reqs
    INTO challenge_data
    FROM challenges c
    WHERE c.id = NEW.challenge_id;
    
    challenge_days := COALESCE(challenge_data.days, 30);
    challenge_requirements := challenge_data.reqs;
    
    -- Calcular o streak atual
    current_streak := get_current_streak(NEW.user_id, NEW.challenge_id);
    
    -- Verificar se há requisitos específicos de pontos no desafio
    IF challenge_requirements IS NOT NULL AND challenge_requirements->>'points_per_checkin' IS NOT NULL THEN
        points_earned := (challenge_requirements->>'points_per_checkin')::integer;
    END IF;
    
    -- Atualizar progresso do desafio
    UPDATE challenge_progress
    SET 
        last_check_in = NEW.check_in_date,
        consecutive_days = current_streak,
        points = points + points_earned,
        check_ins_count = check_ins_count + 1
    WHERE 
        user_id = NEW.user_id AND 
        challenge_id = NEW.challenge_id;
    
    -- Se não encontrar um registro, criar um novo
    IF NOT FOUND THEN
        INSERT INTO challenge_progress (
            user_id, 
            challenge_id, 
            last_check_in, 
            consecutive_days, 
            points, 
            check_ins_count,
            created_at,
            updated_at
        )
        VALUES (
            NEW.user_id, 
            NEW.challenge_id, 
            NEW.check_in_date, 
            current_streak, 
            points_earned, 
            1,
            NOW(),
            NOW()
        );
    END IF;
    
    -- Atualizar progresso geral do usuário
    -- Verificamos se a coluna total_check_ins existe
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'total_check_ins'
    ) THEN
        UPDATE user_progress
        SET 
            points = points + points_earned,
            total_check_ins = total_check_ins + 1,
            updated_at = NOW()
        WHERE 
            user_id = NEW.user_id;
            
        -- Se não encontrar um registro, criar um novo
        IF NOT FOUND THEN
            INSERT INTO user_progress (
                user_id,
                points,
                total_check_ins,
                created_at,
                updated_at
            )
            VALUES (
                NEW.user_id,
                points_earned,
                1,
                NOW(),
                NOW()
            );
        END IF;
    ELSE
        -- Caso a coluna não exista por alguma razão, apenas atualizar os pontos
        UPDATE user_progress
        SET 
            points = points + points_earned,
            updated_at = NOW()
        WHERE 
            user_id = NEW.user_id;
            
        -- Se não encontrar um registro, criar um novo
        IF NOT FOUND THEN
            INSERT INTO user_progress (
                user_id,
                points,
                created_at,
                updated_at
            )
            VALUES (
                NEW.user_id,
                points_earned,
                NOW(),
                NOW()
            );
        END IF;
    END IF;
    
    -- Verificar se o desafio foi completado com base nos requisitos
    IF challenge_requirements IS NOT NULL THEN
        -- Se o requisito for baseado em dias consecutivos
        IF challenge_requirements->>'required_streak' IS NOT NULL THEN
            IF current_streak >= (challenge_requirements->>'required_streak')::integer THEN
                is_challenge_complete := true;
            END IF;
        
        -- Se o requisito for baseado em total de check-ins
        ELSIF challenge_requirements->>'required_checkins' IS NOT NULL THEN
            SELECT (check_ins_count >= (challenge_requirements->>'required_checkins')::integer) INTO is_challenge_complete
            FROM challenge_progress
            WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
        
        -- Por padrão, verificar se o usuário fez check-in em pelo menos 80% dos dias do desafio
        ELSE
            SELECT (check_ins_count >= 0.8 * challenge_days) INTO is_challenge_complete
            FROM challenge_progress
            WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
        END IF;
    END IF;
    
    -- Se o desafio foi completado, atualizar o status do participante
    IF is_challenge_complete THEN
        -- Atualizamos o status na tabela challenge_participants
        UPDATE challenge_participants
        SET status = 'completed', is_completed = true, completed_at = NOW(), updated_at = NOW()
        WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
        
        -- Se o status foi alterado, incrementar o contador de desafios concluídos do usuário
        IF FOUND THEN
            UPDATE user_progress
            SET challenges_completed = challenges_completed + 1
            WHERE user_id = NEW.user_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Atualizar o trigger para usar a função corrigida
DROP TRIGGER IF EXISTS tr_update_user_progress_on_checkin ON challenge_check_ins;
CREATE TRIGGER tr_update_user_progress_on_checkin
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_user_progress_on_checkin();

-- 4. Adicionar uma função RPC para registrar check-in com segurança
-- A função usa exatamente os nomes de parâmetros que o Flutter espera, como descrito em ChallengeRpcParams
CREATE OR REPLACE FUNCTION record_challenge_check_in(
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
BEGIN
  -- 1. Verificar se o usuário já fez check-in hoje
  IF EXISTS (
    SELECT 1 FROM challenge_check_ins 
    WHERE challenge_id = challenge_id_param 
    AND user_id = user_id_param 
    AND DATE(check_in_date) = DATE(date_param)
  ) THEN
    is_already_checked_in := TRUE;
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
    ELSIF DATE(last_check_in) < DATE(date_param - INTERVAL '1 day') THEN
      -- Check-in de antes de ontem, reinicia streak
      current_streak := 1;
    END IF;
  ELSE
    -- Primeiro check-in
    current_streak := 1;
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

  -- 6. Inserir o check-in
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

  -- 7. Atualizar o progresso do desafio
  IF EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = challenge_id_param AND user_id = user_id_param) THEN
    -- Atualizar progresso existente
    UPDATE challenge_progress
    SET 
      points = points + points_awarded,
      consecutive_days = current_streak,
      last_check_in = date_param,
      check_ins_count = check_ins_count + 1,
      updated_at = NOW()
    WHERE 
      challenge_id = challenge_id_param AND 
      user_id = user_id_param;
  ELSE
    -- Criar novo progresso
    INSERT INTO challenge_progress (
      challenge_id,
      user_id,
      points,
      consecutive_days,
      last_check_in,
      check_ins_count,
      created_at,
      updated_at
    ) VALUES (
      challenge_id_param,
      user_id_param,
      points_awarded,
      current_streak,
      date_param,
      1,
      NOW(),
      NOW()
    );
  END IF;

  -- 8. Retornar o resultado completo
  RETURN jsonb_build_object(
    'success', TRUE,
    'check_in_id', check_in_id,
    'message', 'Check-in registrado com sucesso',
    'points_earned', points_awarded,
    'streak', current_streak,
    'is_already_checked_in', FALSE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 