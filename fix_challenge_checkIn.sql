-- Script para corrigir a função RPC record_challenge_check_in
-- Este script substitui a comparação ILIKE com timestamps por uma comparação correta de datas
-- e adiciona suporte para nome e avatar do usuário no ranking
-- Também adiciona suporte para dados de treino registrados pelo botão "Registrar Treino" da home
CREATE OR REPLACE FUNCTION public.record_challenge_check_in(
    _user_id UUID,
    _challenge_id UUID,
    _workout_id VARCHAR,
    _workout_name VARCHAR,
    _workout_type VARCHAR,
    _duration_minutes INTEGER,
    _check_in_date VARCHAR,
    _user_name VARCHAR DEFAULT 'Participante',
    _user_photo_url VARCHAR DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
  _points_awarded INTEGER := 0;
  _challenge_points INTEGER := 0;
  _current_date DATE := CURRENT_DATE;
  _check_in_date_only DATE := TO_DATE(_check_in_date, 'YYYY-MM-DD');
  _success BOOLEAN := TRUE;
  _message VARCHAR := 'Check-in registrado com sucesso';
  _streak_bonus_points INTEGER := 0;
  _streak_count INTEGER := 0;
BEGIN
  -- Verificar se o usuário já fez check-in nesse desafio hoje
  -- Convertemos ambos os timestamps para DATE para comparação correta
  IF EXISTS (
    SELECT 1 FROM challenge_check_ins 
    WHERE user_id = _user_id 
      AND challenge_id = _challenge_id 
      AND formatted_date = _check_in_date
  ) THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'points_awarded', 0,
      'message', 'Você já fez check-in neste desafio hoje'
    );
  END IF;
  
  -- Obter os pontos do desafio
  SELECT points INTO _challenge_points
  FROM challenges
  WHERE id = _challenge_id;
  
  -- Se não encontrou os pontos, usar um valor padrão
  IF _challenge_points IS NULL THEN
    _challenge_points := 10; -- Valor padrão
  END IF;
  
  -- Atribuir pontos básicos pelo check-in
  _points_awarded := _challenge_points;
  
  -- Verificar se há streak (sequência de dias consecutivos)
  -- Essa lógica pode ser adaptada conforme necessário
  SELECT COUNT(*) INTO _streak_count
  FROM (
    SELECT DISTINCT formatted_date
    FROM challenge_check_ins
    WHERE 
      user_id = _user_id 
      AND challenge_id = _challenge_id
      AND check_in_date::DATE >= CURRENT_DATE - INTERVAL '30 days'
    ORDER BY formatted_date DESC
  ) AS consecutive_days;
  
  -- Bônus para streak (a cada 7 dias)
  IF (_streak_count + 1) % 7 = 0 THEN
    _streak_bonus_points := _challenge_points * 2;
    _points_awarded := _points_awarded + _streak_bonus_points;
    _message := 'Check-in registrado com sucesso! Bônus de sequência: +' || _streak_bonus_points || ' pontos!';
  END IF;
  
  -- Inserir o registro de check-in com formatted_date
  INSERT INTO challenge_check_ins (
    user_id,
    challenge_id,
    workout_id,
    workout_name,
    workout_type,
    duration_minutes,
    check_in_date,
    formatted_date,
    points,
    user_name,
    user_photo_url
  ) VALUES (
    _user_id,
    _challenge_id,
    _workout_id,
    _workout_name,
    _workout_type,
    _duration_minutes,
    TO_TIMESTAMP(_check_in_date, 'YYYY-MM-DD'),
    _check_in_date,
    _points_awarded,
    _user_name,
    _user_photo_url
  );
  
  -- Atualizar o progresso do usuário no desafio
  -- Verificar se já existe um registro de progresso
  IF EXISTS (
    SELECT 1 FROM challenge_progress
    WHERE user_id = _user_id AND challenge_id = _challenge_id
  ) THEN
    -- Atualizar o progresso existente
    UPDATE challenge_progress
    SET 
      points = points + _points_awarded,
      last_check_in = TO_TIMESTAMP(_check_in_date, 'YYYY-MM-DD'),
      updated_at = NOW(),
      user_name = _user_name,  -- Atualizar nome do usuário
      user_photo_url = COALESCE(_user_photo_url, user_photo_url),  -- Manter URL existente se novo for NULL
      check_ins_count = check_ins_count + 1  -- Incrementar o contador de check-ins
    WHERE 
      user_id = _user_id AND challenge_id = _challenge_id;
  ELSE
    -- Criar novo registro de progresso
    INSERT INTO challenge_progress (
      user_id,
      challenge_id,
      user_name,
      user_photo_url,
      points,
      completion_percentage,
      last_check_in,
      position,
      created_at,
      updated_at,
      check_ins_count
    ) VALUES (
      _user_id,
      _challenge_id,
      _user_name,
      _user_photo_url,
      _points_awarded,
      0.05, -- Porcentagem inicial de conclusão
      TO_TIMESTAMP(_check_in_date, 'YYYY-MM-DD'),
      0, -- Posição inicial (será atualizada posteriormente)
      NOW(),
      NOW(),
      1 -- Inicialmente, o check-in é o primeiro check-in
    );
  END IF;
  
  -- Chamar a função para recalcular o ranking
  PERFORM update_challenge_ranking(_challenge_id);
  
  RETURN jsonb_build_object(
    'success', _success,
    'points_awarded', _points_awarded,
    'message', _message
  );
END;
$$ LANGUAGE plpgsql;

-- Função SQL para corrigir o trigger de check-in em desafios
-- Soluciona problema onde o código tenta acessar "total_check_ins" que não existe

-- 1. Verificar se a coluna check_ins_count existe e criar se necessário
ALTER TABLE challenge_progress ADD COLUMN IF NOT EXISTS check_ins_count INT DEFAULT 0;

-- 2. Criar ou substituir a função que atualiza o progresso no check-in
CREATE OR REPLACE FUNCTION update_challenge_progress_on_checkin()
RETURNS TRIGGER AS $$
DECLARE
    consecutive_days_count INTEGER;
    last_check_in_date DATE;
    total_check_ins_count INTEGER;
    streak_bonus INTEGER;
BEGIN
    -- Obter o último check-in
    SELECT 
        consecutive_days,
        CAST(last_check_in AS DATE),
        check_ins_count  -- Usando check_ins_count em vez de total_check_ins
    INTO 
        consecutive_days_count,
        last_check_in_date,
        total_check_ins_count
    FROM 
        challenge_progress
    WHERE 
        challenge_id = NEW.challenge_id AND 
        user_id = NEW.user_id;
    
    -- Se nunca houve check-in anterior, inicializar valores
    IF last_check_in_date IS NULL THEN
        consecutive_days_count := 1;
        total_check_ins_count := 1;
    ELSE
        -- Verificar se o último check-in foi ontem
        IF last_check_in_date = CURRENT_DATE - INTERVAL '1 day' THEN
            consecutive_days_count := consecutive_days_count + 1;
        -- Se for outro dia (sem ser hoje que já verificamos antes)
        ELSIF last_check_in_date < CURRENT_DATE - INTERVAL '1 day' THEN
            consecutive_days_count := 1; -- Reinicia streak
        END IF;
        
        total_check_ins_count := total_check_ins_count + 1;
    END IF;
    
    -- Calcular bônus de streak
    IF consecutive_days_count >= 30 THEN
        streak_bonus := 5;
    ELSIF consecutive_days_count >= 15 THEN
        streak_bonus := 3;
    ELSIF consecutive_days_count >= 7 THEN
        streak_bonus := 2;
    ELSIF consecutive_days_count >= 3 THEN
        streak_bonus := 1;
    ELSE
        streak_bonus := 0;
    END IF;
    
    -- Obter pontos base do desafio
    DECLARE
        base_points INTEGER;
    BEGIN
        SELECT points INTO base_points
        FROM challenges
        WHERE id = NEW.challenge_id;
        
        -- Atualizar progresso
        UPDATE challenge_progress
        SET 
            check_ins_count = total_check_ins_count,  -- Usando check_ins_count em vez de total_check_ins
            consecutive_days = consecutive_days_count,
            last_check_in = NEW.created_at,
            points = points + base_points + streak_bonus,
            updated_at = NOW()
        WHERE 
            challenge_id = NEW.challenge_id AND 
            user_id = NEW.user_id;
    END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Remover o trigger existente antes de recriar para evitar duplicação
DROP TRIGGER IF EXISTS update_progress_after_checkin ON challenge_check_ins;

-- 4. Recriar o trigger com a função atualizada
CREATE TRIGGER update_progress_after_checkin
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_challenge_progress_on_checkin();

-- 5. Adicionar uma função RPC para check-in em desafios
CREATE OR REPLACE FUNCTION record_challenge_check_in(
  challenge_id_param UUID,
  user_id_param UUID,
  workout_id_param UUID DEFAULT NULL,
  workout_name_param TEXT DEFAULT NULL,
  workout_type_param TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  check_date DATE;
  existing_check_id UUID;
  new_check_id UUID;
  result JSONB;
BEGIN
  -- Definir a data do check-in como o dia atual
  check_date := CURRENT_DATE;
  
  -- Verificar se já existe um check-in para o usuário no desafio nesta data
  SELECT id INTO existing_check_id
  FROM challenge_check_ins
  WHERE 
    challenge_id = challenge_id_param AND
    user_id = user_id_param AND
    get_date(check_in_date) = check_date;
    
  IF existing_check_id IS NOT NULL THEN
    -- Já existe um check-in para hoje
    result := jsonb_build_object(
      'success', false,
      'message', 'Você já fez check-in hoje neste desafio',
      'is_already_checked_in', true
    );
  ELSE
    -- Inserir novo check-in
    INSERT INTO challenge_check_ins(
      challenge_id,
      user_id,
      check_in_date,
      workout_id,
      workout_name,
      workout_type,
      created_at
    )
    VALUES(
      challenge_id_param,
      user_id_param,
      NOW(),
      workout_id_param,
      workout_name_param,
      workout_type_param,
      NOW()
    )
    RETURNING id INTO new_check_id;
    
    result := jsonb_build_object(
      'success', true,
      'message', 'Check-in registrado com sucesso!',
      'check_in_id', new_check_id
    );
  END IF;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql; 