-- Script para corrigir e garantir o funcionamento correto do trigger que atualiza o progresso nos desafios
-- Este script recria a função e o trigger conforme a especificação técnica correta

-- Primeiro, remover o trigger existente para evitar conflitos
DROP TRIGGER IF EXISTS trg_update_progress_on_check_in ON public.challenge_check_ins;

-- Criar a função atualizada que processa o check-in e atualiza o progresso
CREATE OR REPLACE FUNCTION update_challenge_progress_on_check_in()
RETURNS TRIGGER AS $$
DECLARE
  total_points INTEGER;
  v_check_ins_count INTEGER;
  consecutive_count INTEGER;
  v_last_check_in TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Calcular pontos totais e contagem de check-ins
  SELECT 
    COALESCE(SUM(points), 0), 
    COUNT(*),
    MAX(check_in_date)
  INTO 
    total_points,
    v_check_ins_count,
    v_last_check_in
  FROM challenge_check_ins
  WHERE challenge_id = NEW.challenge_id AND user_id = NEW.user_id;
  
  -- Calcular dias consecutivos
  SELECT COALESCE(
    (SELECT consecutive_days + 1 
     FROM challenge_progress 
     WHERE challenge_id = NEW.challenge_id AND user_id = NEW.user_id
     AND (NEW.check_in_date::date - last_check_in::date) = 1),
    1)
  INTO consecutive_count;
  
  -- Inserir ou atualizar progresso
  INSERT INTO challenge_progress (
    challenge_id, user_id, points, check_ins_count, 
    last_check_in, consecutive_days, user_name, user_photo_url, last_updated
  ) VALUES (
    NEW.challenge_id, NEW.user_id, total_points, v_check_ins_count, 
    NEW.check_in_date, consecutive_count, NEW.user_name, NEW.user_photo_url, now()
  )
  ON CONFLICT (challenge_id, user_id) DO UPDATE SET
    points = total_points,
    check_ins_count = v_check_ins_count,
    last_check_in = NEW.check_in_date,
    consecutive_days = consecutive_count,
    user_name = NEW.user_name,
    user_photo_url = COALESCE(NEW.user_photo_url, challenge_progress.user_photo_url),
    last_updated = now();
  
  -- Atualizar posições no ranking
  WITH ranked AS (
    SELECT 
      id, 
      ROW_NUMBER() OVER (PARTITION BY challenge_id ORDER BY points DESC) as new_position
    FROM challenge_progress
    WHERE challenge_id = NEW.challenge_id
  )
  UPDATE challenge_progress cp
  SET position = r.new_position
  FROM ranked r
  WHERE cp.id = r.id AND cp.challenge_id = NEW.challenge_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar o trigger que vai executar a função
CREATE TRIGGER trg_update_progress_on_check_in
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_challenge_progress_on_check_in();

-- Criar ou atualizar a função RPC para atualizar o ranking
CREATE OR REPLACE FUNCTION public.update_challenge_ranking(
    _challenge_id UUID
) RETURNS void AS $$
BEGIN
    -- Atualizar as posições de todos os participantes no ranking
    -- baseado na quantidade de pontos (ordem decrescente)
    WITH ranked_users AS (
        SELECT 
            id, 
            ROW_NUMBER() OVER (ORDER BY points DESC) AS new_position
        FROM 
            challenge_progress
        WHERE 
            challenge_id = _challenge_id
    )
    UPDATE challenge_progress cp
    SET position = ru.new_position
    FROM ranked_users ru
    WHERE cp.id = ru.id
    AND cp.challenge_id = _challenge_id;
    
    RAISE NOTICE 'Ranking para o desafio % atualizado com sucesso.', _challenge_id;
END;
$$ LANGUAGE plpgsql; 