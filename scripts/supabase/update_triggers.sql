-- Script para atualizar ou criar triggers no banco de dados
-- Execute este script no SQL Editor do Supabase

-- Trigger para atualizar timestamp 'updated_at' em perfis de usuário
DROP TRIGGER IF EXISTS set_profiles_updated_at ON profiles;
CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Trigger para atualizar timestamp 'updated_at' em desafios
DROP TRIGGER IF EXISTS set_challenges_updated_at ON challenges;
CREATE TRIGGER set_challenges_updated_at
BEFORE UPDATE ON challenges
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Trigger para atualizar timestamp 'updated_at' em participantes de desafios
DROP TRIGGER IF EXISTS set_challenge_participants_updated_at ON challenge_participants;
CREATE TRIGGER set_challenge_participants_updated_at
BEFORE UPDATE ON challenge_participants
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Trigger para atualizar timestamp 'updated_at' em check-ins de desafios
DROP TRIGGER IF EXISTS set_challenge_check_ins_updated_at ON challenge_check_ins;
CREATE TRIGGER set_challenge_check_ins_updated_at
BEFORE UPDATE ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Trigger para atualizar timestamp 'updated_at' em progresso de usuário
DROP TRIGGER IF EXISTS set_user_progress_updated_at ON user_progress;
CREATE TRIGGER set_user_progress_updated_at
BEFORE UPDATE ON user_progress
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Trigger para atualizar o progresso do usuário quando um check-in é registrado
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
    
    challenge_days := challenge_data.days;
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
        total_check_ins = total_check_ins + 1
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
            total_check_ins,
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
    
    -- Verificar se o desafio foi completado com base nos requisitos
    IF challenge_requirements IS NOT NULL THEN
        -- Se o requisito for baseado em dias consecutivos
        IF challenge_requirements->>'required_streak' IS NOT NULL THEN
            IF current_streak >= (challenge_requirements->>'required_streak')::integer THEN
                is_challenge_complete := true;
            END IF;
        
        -- Se o requisito for baseado em total de check-ins
        ELSIF challenge_requirements->>'required_checkins' IS NOT NULL THEN
            SELECT (total_check_ins >= (challenge_requirements->>'required_checkins')::integer) INTO is_challenge_complete
            FROM challenge_progress
            WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
        
        -- Por padrão, verificar se o usuário fez check-in em pelo menos 80% dos dias do desafio
        ELSE
            SELECT (total_check_ins >= 0.8 * challenge_days) INTO is_challenge_complete
            FROM challenge_progress
            WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id;
        END IF;
    END IF;
    
    -- Se o desafio foi completado, atualizar o status
    IF is_challenge_complete THEN
        UPDATE challenge_participants
        SET status = 'completed', is_completed = true, completed_at = NOW(), updated_at = NOW()
        WHERE user_id = NEW.user_id AND challenge_id = NEW.challenge_id AND status != 'completed';
        
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

-- Remover e recriar o trigger
DROP TRIGGER IF EXISTS tr_update_user_progress_on_checkin ON challenge_check_ins;
CREATE TRIGGER tr_update_user_progress_on_checkin
AFTER INSERT ON challenge_check_ins
FOR EACH ROW
EXECUTE FUNCTION update_user_progress_on_checkin();

-- Trigger para atualizar contagem de participantes do desafio
CREATE OR REPLACE FUNCTION update_challenge_participants_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE challenges
        SET participants = participants + 1
        WHERE id = NEW.challenge_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE challenges
        SET participants = GREATEST(participants - 1, 0)
        WHERE id = OLD.challenge_id;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Remover e recriar o trigger
DROP TRIGGER IF EXISTS tr_update_challenge_participants ON challenge_participants;
CREATE TRIGGER tr_update_challenge_participants
AFTER INSERT OR DELETE ON challenge_participants
FOR EACH ROW
EXECUTE FUNCTION update_challenge_participants_count(); 