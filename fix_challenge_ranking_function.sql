-- PATCH: Corrigir bug 3 - Nova lógica de pontuação para desafios que respeita duração mínima de treino

-- Função corrigida para sincronizar treinos com desafios
CREATE OR REPLACE FUNCTION public.sync_workout_to_challenges()
RETURNS TRIGGER AS $$
DECLARE
    challenge_record RECORD;
    user_in_challenge BOOLEAN;
    workout_date DATE := DATE(NEW.date);
    already_has_valid_workout BOOLEAN := FALSE;
BEGIN
    -- Verificar se o treino tem duração suficiente (>= 45 minutos)
    IF NEW.duration_minutes < 45 THEN
        -- Registrar que o treino não tem duração suficiente e pular sincronização
        RAISE NOTICE 'Treino com duração insuficiente (% minutos). Mínimo requerido: 45 minutos.', NEW.duration_minutes;
        RETURN NEW;
    END IF;
    
    -- Verificar se o usuário já tem um treino válido para esta data em qualquer desafio
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = NEW.user_id 
        AND DATE(check_in_date) = workout_date
    ) INTO already_has_valid_workout;
    
    -- Se já tem um treino válido para hoje, não adicionar novos check-ins
    IF already_has_valid_workout THEN
        RAISE NOTICE 'Usuário já tem um treino válido registrado para %, ignorando novo check-in.', workout_date;
        RETURN NEW;
    END IF;
    
    -- Para cada desafio ativo que o usuário participa
    FOR challenge_record IN
        SELECT c.id, c.title, c.start_date, c.end_date, c.points, cp.user_id
        FROM challenges c
        JOIN challenge_participants cp ON c.id = cp.challenge_id
        WHERE cp.user_id = NEW.user_id
        AND c.active = TRUE
        AND c.start_date <= NEW.date
        AND c.end_date >= NEW.date
    LOOP
        -- Verificar se treino está dentro do período do desafio
        IF NEW.date >= challenge_record.start_date AND NEW.date <= challenge_record.end_date THEN
            -- Registrar o check-in para este desafio com 1 ponto fixo
            INSERT INTO challenge_check_ins (
                user_id,
                challenge_id,
                check_in_date,
                points,
                workout_id,
                workout_name,
                workout_type,
                duration_minutes,
                created_at
            ) VALUES (
                NEW.user_id,
                challenge_record.id,
                NEW.date,
                1, -- SEMPRE 1 ponto por dia, independente do tipo de treino
                NEW.id,
                NEW.workout_name,
                NEW.workout_type,
                NEW.duration_minutes,
                NOW()
            );
            
            RAISE NOTICE 'Check-in registrado para desafio % (%)', challenge_record.id, challenge_record.title;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Atualizar o trigger para usar a função corrigida
DROP TRIGGER IF EXISTS trg_sync_workout_to_challenges ON workout_records;

CREATE TRIGGER trg_sync_workout_to_challenges
AFTER INSERT ON workout_records
FOR EACH ROW
EXECUTE FUNCTION sync_workout_to_challenges();

-- Versão corrigida da função para atualizar o ranking do desafio
-- Esta função corrige quaisquer problemas de sintaxe e estrutura
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