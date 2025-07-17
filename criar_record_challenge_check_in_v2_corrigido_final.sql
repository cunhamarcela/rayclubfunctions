-- Função corrigida record_challenge_check_in_v2 (versão final)
-- Remove referências à coluna "status" na tabela challenge_progress
-- Usa check_in_error_logs ao invés de check_in_logs

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
  user_level INTEGER := 1;
  user_name TEXT;
  user_photo_url TEXT;
  duplicate_check_in BOOLEAN := FALSE;
  challenge_name TEXT;
  log_id UUID;
  total_check_ins INTEGER;
BEGIN
  -- Início da transação
  BEGIN
    -- 1. Verificar se já existe check-in do usuário para este desafio nesta data
    SELECT EXISTS (
      SELECT 1 FROM challenge_check_ins 
      WHERE 
        challenge_id = challenge_id_param AND 
        user_id = user_id_param AND 
        DATE(check_in_date) = DATE(date_param)
    ) INTO duplicate_check_in;
    
    -- Se já existe check-in para esta data, retornar erro
    IF duplicate_check_in THEN
      RETURN jsonb_build_object(
        'success', false,
        'message', 'Você já realizou check-in para este desafio hoje',
        'error_code', 'DUPLICATE_CHECK_IN',
        'points_earned', 0
      );
    END IF;
    
    -- 2. Obter informações do desafio
    SELECT title, points INTO challenge_name, challenge_points
    FROM challenges
    WHERE id = challenge_id_param
    FOR UPDATE;
    
    -- 3. Verificar se desafio foi encontrado
    IF challenge_name IS NULL THEN
      RETURN jsonb_build_object(
        'success', false,
        'message', 'Desafio não encontrado',
        'error_code', 'CHALLENGE_NOT_FOUND',
        'points_earned', 0
      );
    END IF;
    
    -- 4. Obter informações do usuário
    SELECT name, photo_url INTO user_name, user_photo_url
    FROM profiles
    WHERE id = user_id_param
    FOR UPDATE;
    
    -- 5. Obter level do usuário da tabela profiles ou user_progress
    -- Tentar obter de user_progress
    SELECT COALESCE(level, 1) INTO user_level
    FROM user_progress
    WHERE user_id = user_id_param
    FOR UPDATE;
    
    -- Se não encontrou level, inicializar com 1
    IF user_level IS NULL THEN
      user_level := 1;
    END IF;
    
    -- 6. Verificar o progresso atual do usuário
    DECLARE
      current_progress RECORD;
    BEGIN
      SELECT 
        consecutive_days,
        last_check_in,
        COALESCE(total_check_ins, 0) AS total_check_ins
      INTO current_progress
      FROM challenge_progress
      WHERE 
        challenge_id = challenge_id_param AND 
        user_id = user_id_param
      FOR UPDATE;
      
      -- Inicializar valores se não existir progresso
      IF current_progress.consecutive_days IS NULL THEN
        streak_count := 1;
        total_check_ins := 1;
      ELSE
        -- Atualização de streak baseada na data do último check-in
        IF current_progress.last_check_in IS NULL THEN
          streak_count := 1;
        -- Se o último check-in foi ontem, incrementar o streak
        ELSIF DATE(current_progress.last_check_in) = DATE(date_param - INTERVAL '1 day') THEN
          streak_count := current_progress.consecutive_days + 1;
        -- Se o último check-in foi em data anterior, resetar streak
        ELSIF DATE(current_progress.last_check_in) < DATE(date_param - INTERVAL '1 day') THEN
          streak_count := 1;
        -- Se já fez check-in hoje (não deveria chegar aqui devido à verificação anterior)
        ELSIF DATE(current_progress.last_check_in) = DATE(date_param) THEN
          streak_count := current_progress.consecutive_days;
        -- Em outros casos, manter o streak atual
        ELSE
          streak_count := current_progress.consecutive_days;
        END IF;
        
        total_check_ins := current_progress.total_check_ins + 1;
      END IF;
    END;
    
    -- 7. Calcular pontos baseado no streak
    DECLARE
      streak_bonus INTEGER := 0;
    BEGIN
      -- Bônus baseado no streak
      IF streak_count >= 30 THEN
        streak_bonus := 5;
      ELSIF streak_count >= 15 THEN
        streak_bonus := 3;
      ELSIF streak_count >= 7 THEN
        streak_bonus := 2;
      ELSIF streak_count >= 3 THEN
        streak_bonus := 1;
      END IF;
      
      -- Pontos totais
      points_awarded := challenge_points + streak_bonus;
    END;
    
    -- 8. Inserir o check-in na tabela
    INSERT INTO challenge_check_ins (
      challenge_id,
      user_id,
      check_in_date,
      duration_minutes,
      workout_id,
      workout_name,
      workout_type
    ) VALUES (
      challenge_id_param,
      user_id_param,
      date_param,
      duration_minutes_param,
      workout_id_param,
      workout_name_param,
      workout_type_param
    )
    RETURNING id INTO check_in_id;
    
    -- 9. Atualizar ou criar o registro de progresso
    DECLARE
      progress_exists BOOLEAN;
    BEGIN
      SELECT EXISTS (
        SELECT 1 FROM challenge_progress
        WHERE challenge_id = challenge_id_param AND user_id = user_id_param
      ) INTO progress_exists;
      
      IF progress_exists THEN
        -- Atualizar progresso existente
        UPDATE challenge_progress
        SET 
          points = points + points_awarded,
          total_check_ins = total_check_ins,
          consecutive_days = streak_count,
          last_check_in = date_param,
          updated_at = NOW(),
          user_name = user_name,
          user_photo_url = user_photo_url
        WHERE 
          challenge_id = challenge_id_param AND 
          user_id = user_id_param;
      ELSE
        -- Criar novo registro de progresso
        INSERT INTO challenge_progress (
          challenge_id,
          user_id,
          points,
          total_check_ins,
          consecutive_days,
          last_check_in,
          user_name,
          user_photo_url
        ) VALUES (
          challenge_id_param,
          user_id_param,
          points_awarded,
          1,
          1,
          date_param,
          user_name,
          user_photo_url
        );
      END IF;
    END;
    
    -- 10. Atualizar participants se necessário
    DECLARE
      is_participant BOOLEAN;
    BEGIN
      SELECT EXISTS (
        SELECT 1 FROM challenge_participants
        WHERE challenge_id = challenge_id_param AND user_id = user_id_param
      ) INTO is_participant;
      
      IF NOT is_participant THEN
        INSERT INTO challenge_participants (
          challenge_id,
          user_id,
          joined_at
        ) VALUES (
          challenge_id_param,
          user_id_param,
          NOW()
        );
      END IF;
    END;
    
    -- 11. Atualizar user_progress
    DECLARE
      user_progress_exists BOOLEAN;
    BEGIN
      SELECT EXISTS (
        SELECT 1 FROM user_progress
        WHERE user_id = user_id_param
      ) INTO user_progress_exists;
      
      IF user_progress_exists THEN
        UPDATE user_progress
        SET 
          total_points = total_points + points_awarded,
          total_check_ins = total_check_ins + 1,
          updated_at = NOW(),
          level = CASE 
            WHEN (total_points + points_awarded) / 100 > level THEN (total_points + points_awarded) / 100
            ELSE level
          END
        WHERE user_id = user_id_param;
      ELSE
        INSERT INTO user_progress (
          user_id,
          total_points,
          total_check_ins,
          total_challenges,
          streak_days,
          level
        ) VALUES (
          user_id_param,
          points_awarded,
          1,
          1,
          1,
          GREATEST(1, points_awarded / 100)
        );
      END IF;
    END;
    
    -- 12. Atualizar ranking (recalcular posições)
    -- Recalcular posições no ranking
    WITH ranked_participants AS (
      SELECT
        id,
        ROW_NUMBER() OVER (
          PARTITION BY challenge_id 
          ORDER BY points DESC, last_check_in ASC
        ) AS new_position
      FROM challenge_progress
      WHERE challenge_id = challenge_id_param
    )
    UPDATE challenge_progress cp
    SET position = rp.new_position
    FROM ranked_participants rp
    WHERE cp.id = rp.id;
    
    -- 13. Preparar resultado de retorno
    result := jsonb_build_object(
      'success', true,
      'message', 'Check-in registrado com sucesso',
      'data', jsonb_build_object(
        'check_in_id', check_in_id,
        'streak', streak_count,
        'points_earned', points_awarded
      )
    );
    
    -- Retornar resultado de sucesso
    RETURN result;
  
  -- Tratamento de exceções
  EXCEPTION WHEN OTHERS THEN
    -- Registrar o erro em log
    INSERT INTO check_in_error_logs (
      user_id,
      challenge_id,
      error_message,
      error_detail,
      error_context
    ) VALUES (
      user_id_param,
      challenge_id_param,
      SQLERRM,
      SQLSTATE,
      'Erro na função record_challenge_check_in_v2'
    ) RETURNING id INTO log_id;
    
    -- Retornar mensagem de erro
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Erro ao processar check-in: ' || SQLERRM,
      'error_code', SQLSTATE,
      'points_earned', 0
    );
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentar a função anterior como deprecated mas mantê-la disponível temporariamente
COMMENT ON FUNCTION record_challenge_check_in IS 'DEPRECATED: Use record_challenge_check_in_v2 instead. Esta função será removida em versão futura.';

-- Criar alias para check_ins_count se necessário
DO $$
BEGIN
  -- Verificar se total_check_ins existe mas check_ins_count não existe
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'challenge_progress' 
    AND column_name = 'total_check_ins'
  ) AND NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'challenge_progress' 
    AND column_name = 'check_ins_count'
  ) THEN
    -- Criar view para compatibilidade com código mais antigo
    EXECUTE 'ALTER TABLE challenge_progress ADD COLUMN IF NOT EXISTS check_ins_count INTEGER GENERATED ALWAYS AS (total_check_ins) STORED';
  END IF;
  
  -- Caso contrário, se só check_ins_count existe
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'challenge_progress' 
    AND column_name = 'total_check_ins'
  ) AND EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'challenge_progress' 
    AND column_name = 'check_ins_count'
  ) THEN
    -- Criar alias para total_check_ins
    EXECUTE 'ALTER TABLE challenge_progress ADD COLUMN IF NOT EXISTS total_check_ins INTEGER GENERATED ALWAYS AS (check_ins_count) STORED';
  END IF;
END $$; 