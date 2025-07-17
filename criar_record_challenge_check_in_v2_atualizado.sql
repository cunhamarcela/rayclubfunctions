-- Script aprimorado para criar uma função record_challenge_check_in_v2 robusta
-- Resolve o problema do loop infinito e garante atualizações completas de todos os campos do dashboard

-- 1. Criação da função V2 aprimorada que gerencia transações e concorrência
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
  user_level INTEGER := 1;
  challenges_completed INTEGER := 0;
  user_status TEXT := 'active';
  error_message TEXT;
  error_detail TEXT;
  error_context TEXT;
BEGIN
  -- Iniciar transação explicitamente para permitir rollback em caso de falha
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
    -- Tenta obter o último check-in e os dias consecutivos com bloqueio para evitar race conditions
    SELECT cp.last_check_in, cp.consecutive_days 
    INTO last_check_in, current_streak
    FROM challenge_progress cp
    WHERE cp.challenge_id = challenge_id_param 
    AND cp.user_id = user_id_param
    FOR UPDATE; -- Bloquear registro para evitar race conditions
    
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

    -- 6. Obter informações do usuário para o ranking e dashboard
    SELECT p.name, p.photo_url, COALESCE(p.level, 1) as lvl
    INTO user_name, user_photo_url, user_level
    FROM profiles p
    WHERE p.id = user_id_param
    FOR UPDATE; -- Bloquear registro para evitar race conditions

    -- 7. Inserir o check-in com trigger desativado para não causar loop
    INSERT INTO challenge_check_ins (
      challenge_id, 
      user_id, 
      workout_id, 
      workout_name, 
      workout_type, 
      check_in_date, 
      duration_minutes,
      created_at,
      updated_at
    )
    VALUES (
      challenge_id_param,
      user_id_param,
      workout_id_param,
      workout_name_param,
      workout_type_param,
      date_param,
      duration_minutes_param,
      NOW(),
      NOW()
    )
    RETURNING id INTO check_in_id;
    
    RAISE NOTICE 'Check-in inserido com ID: %', check_in_id;

    -- 8. Atualizar o progresso do desafio
    IF EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = challenge_id_param AND user_id = user_id_param FOR UPDATE) THEN
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
        updated_at = NOW(),
        user_name = COALESCE(user_name, 'Usuário'),  -- Garantir que sempre teremos um nome
        user_photo_url = user_photo_url              -- Atualizar foto do usuário se houver alteração
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
        updated_at,
        status
      ) VALUES (
        challenge_id_param,
        user_id_param,
        COALESCE(user_name, 'Usuário'),
        user_photo_url,
        points_awarded,
        current_streak,
        date_param,
        1,
        NOW(),
        NOW(),
        'active'
      );
      
      RAISE NOTICE 'Novo progresso criado para o usuário';
    END IF;

    -- 9. Verificar se usuário já está como participante
    IF NOT EXISTS (SELECT 1 FROM challenge_participants WHERE challenge_id = challenge_id_param AND user_id = user_id_param FOR UPDATE) THEN
      -- Adicionar usuário como participante
      INSERT INTO challenge_participants (
        challenge_id,
        user_id,
        joined_at,
        created_at,
        updated_at,
        status
      ) VALUES (
        challenge_id_param,
        user_id_param,
        NOW(),
        NOW(),
        NOW(),
        'active'
      );
      
      RAISE NOTICE 'Usuário adicionado como participante do desafio';
    END IF;

    -- 10. Atualizar contagem de participantes no desafio
    UPDATE challenges
    SET 
      participants_count = (
        SELECT COUNT(DISTINCT user_id) 
        FROM challenge_participants 
        WHERE challenge_id = challenge_id_param
      ),
      updated_at = NOW()
    WHERE id = challenge_id_param;
    
    RAISE NOTICE 'Contagem de participantes atualizada';

    -- 11. Obter número de desafios completados para o dashboard
    SELECT COALESCE(challenges_completed, 0)
    INTO challenges_completed
    FROM user_progress
    WHERE user_id = user_id_param;

    -- 12. Atualizar user_progress (sem usar trigger) com todos os campos do dashboard
    IF EXISTS (SELECT 1 FROM user_progress WHERE user_id = user_id_param FOR UPDATE) THEN
      -- Obter a contagem atual de check-ins do usuário
      SELECT COALESCE(total_check_ins, 0)
      INTO total_check_ins
      FROM user_progress  
      WHERE user_id = user_id_param;
      
      -- Incrementar a contagem
      total_check_ins := total_check_ins + 1;
      
      -- Calcular nível baseado no total de pontos (regra simplificada: a cada 100 pontos, sobe 1 nível)
      user_level := GREATEST(1, FLOOR((SELECT COALESCE(points, 0) FROM user_progress WHERE user_id = user_id_param) / 100) + 1);

      UPDATE user_progress
      SET 
        points = points + points_awarded,
        total_check_ins = total_check_ins,
        consecutive_days = current_streak,  -- Manter streak consistente em todas as tabelas
        updated_at = NOW(),
        level = user_level,                 -- Atualizar nível do usuário
        last_check_in = date_param          -- Registrar último check-in
      WHERE 
        user_id = user_id_param;
        
      RAISE NOTICE 'User progress atualizado. Nível atual: %, Total check-ins: %, Desafios completados: %', 
        user_level, total_check_ins, challenges_completed;
    ELSE
      INSERT INTO user_progress (
        user_id,
        points,
        total_check_ins,
        consecutive_days,
        challenges_completed,
        created_at,
        updated_at,
        level,
        status,
        last_check_in
      ) VALUES (
        user_id_param,
        points_awarded,
        1,
        current_streak,
        0,  -- Iniciar com zero desafios completados
        NOW(),
        NOW(),
        1,  -- Iniciar no nível 1
        'active',
        date_param
      );
      
      RAISE NOTICE 'Novo user progress criado';
    END IF;

    -- 13. Atualizar ranking do desafio (sem loop)
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
    
    RAISE NOTICE 'Ranking do desafio atualizado';

    -- 14. Verificar se o usuário completou o desafio
    -- Esta lógica depende das regras do seu negócio
    DECLARE
      challenge_duration INTEGER;
      completion_threshold FLOAT := 0.8; -- 80% dos dias do desafio
      days_since_start INTEGER;
      check_ins_required INTEGER;
      is_challenge_complete BOOLEAN := FALSE;
    BEGIN
      -- Obter duração do desafio em dias
      SELECT 
        EXTRACT(DAY FROM (end_date - start_date)) + 1
      INTO challenge_duration
      FROM challenges
      WHERE id = challenge_id_param;
      
      -- Calcular dias decorridos desde o início
      SELECT 
        EXTRACT(DAY FROM (CURRENT_DATE - start_date)) + 1
      INTO days_since_start
      FROM challenges
      WHERE id = challenge_id_param;
      
      -- Calcular check-ins mínimos para conclusão
      check_ins_required := GREATEST(1, FLOOR(challenge_duration * completion_threshold));
      
      -- Verificar se atingiu o requisito
      IF total_check_ins >= check_ins_required THEN
        is_challenge_complete := TRUE;
        
        -- Atualizar status de conclusão
        UPDATE challenge_participants
        SET 
          status = 'completed',
          is_completed = TRUE,
          completed_at = NOW(),
          updated_at = NOW()
        WHERE 
          challenge_id = challenge_id_param AND 
          user_id = user_id_param;
          
        -- Incrementar contador de desafios completados no perfil do usuário
        UPDATE user_progress
        SET 
          challenges_completed = challenges_completed + 1,
          updated_at = NOW()
        WHERE 
          user_id = user_id_param;
          
        RAISE NOTICE 'Usuário completou o desafio!';
      END IF;
    END;

    -- 15. Retornar o resultado completo
    RETURN jsonb_build_object(
      'success', TRUE,
      'check_in_id', check_in_id,
      'message', 'Check-in registrado com sucesso',
      'points_earned', points_awarded,
      'streak', current_streak,
      'is_already_checked_in', FALSE,
      'level', user_level,
      'total_check_ins', total_check_ins,
      'challenges_completed', challenges_completed
    );
    
  -- Tratamento de exceções em caso de erro
  EXCEPTION WHEN OTHERS THEN
    -- Capturar detalhes do erro
    GET STACKED DIAGNOSTICS 
      error_message = MESSAGE_TEXT,
      error_detail = PG_EXCEPTION_DETAIL,
      error_context = PG_EXCEPTION_CONTEXT;
      
    -- Registrar erro para diagnóstico
    INSERT INTO challenge_check_in_errors (
      user_id,
      challenge_id,
      error_message,
      error_detail,
      error_context,
      created_at
    ) VALUES (
      user_id_param,
      challenge_id_param,
      error_message,
      error_detail,
      error_context,
      NOW()
    );
    
    -- Rollback da transação
    RAISE NOTICE 'Erro durante o check-in: %. Realizando rollback.', error_message;
    
    -- Retornar mensagem de erro
    RETURN jsonb_build_object(
      'success', FALSE,
      'message', 'Erro ao processar check-in: ' || error_message,
      'error_code', SQLSTATE,
      'points_earned', 0
    );
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Criar função record_challenge_check_in_v1 como wrapper para v2 (fase de transição)
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
BEGIN
  RAISE WARNING 'DEPRECATED: A função record_challenge_check_in está obsoleta. Use record_challenge_check_in_v2';
  RETURN record_challenge_check_in_v2(
    challenge_id_param,
    date_param,
    duration_minutes_param,
    user_id_param,
    workout_id_param,
    workout_name_param,
    workout_type_param
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Criação da tabela de log de erros para diagnóstico
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'challenge_check_in_errors') THEN
    CREATE TABLE challenge_check_in_errors (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      user_id UUID NOT NULL,
      challenge_id UUID NOT NULL,
      error_message TEXT NOT NULL,
      error_detail TEXT,
      error_context TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    
    -- Índice para busca rápida
    CREATE INDEX challenge_check_in_errors_user_id_idx ON challenge_check_in_errors(user_id);
    CREATE INDEX challenge_check_in_errors_challenge_id_idx ON challenge_check_in_errors(challenge_id);
    CREATE INDEX challenge_check_in_errors_created_at_idx ON challenge_check_in_errors(created_at);
    
    RAISE NOTICE 'Tabela challenge_check_in_errors criada com sucesso';
  ELSE
    RAISE NOTICE 'Tabela challenge_check_in_errors já existe';
  END IF;
END$$;

-- 4. Desativar os triggers problemáticos que estão causando o loop infinito
-- Execute estas linhas separadamente na console SQL do Supabase
/*
ALTER TABLE challenge_check_ins DISABLE TRIGGER trigger_update_challenge_ranking;
ALTER TABLE challenge_check_ins DISABLE TRIGGER tr_update_user_progress_on_checkin;
ALTER TABLE challenge_check_ins DISABLE TRIGGER update_progress_after_checkin;
ALTER TABLE challenge_check_ins DISABLE TRIGGER trigger_set_formatted_date;
ALTER TABLE challenge_check_ins DISABLE TRIGGER update_streak_on_checkin;
ALTER TABLE challenge_check_ins DISABLE TRIGGER trg_update_progress_on_check_in;
ALTER TABLE challenge_check_ins DISABLE TRIGGER trg_check_daily_check_in;
ALTER TABLE challenge_check_ins DISABLE TRIGGER update_challenge_check_ins_timestamp;
ALTER TABLE challenge_check_ins DISABLE TRIGGER update_profile_stats_on_checkin_trigger;
*/

-- 5. Verificar outros triggers em tabelas relacionadas (auditoria)
-- Execute este comando para listar todos os triggers ativos nas tabelas relacionadas
/*
SELECT 
    tgname AS trigger_name,
    relname AS table_name,
    pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
WHERE 
    c.relname IN ('challenge_progress', 'user_progress', 'workout_records')
    AND NOT t.tgisinternal
ORDER BY relname, tgname;
*/

-- 6. Teste da função - Executar na console SQL do Supabase para verificar se funciona corretamente
/*
SELECT * FROM record_challenge_check_in_v2(
  '550e8400-e29b-41d4-a716-446655440000', -- ID do desafio (substitua por um ID real)
  NOW(),                                   -- Data atual
  30,                                      -- Duração em minutos
  '7c9e6679-7425-40de-944b-e07fc1f90ae7', -- ID do usuário (substitua por um ID real)
  'workout-123',                           -- ID do treino
  'Corrida',                               -- Nome do treino
  'cardio'                                 -- Tipo do treino
);
*/ 