-- =====================================================================================
-- SCRIPT: PREVENÇÃO DE CHECK-INS PRÉ-DESAFIO
-- Descrição: Cria validações para impedir check-ins antes do início oficial do desafio
-- Data: 2025-01-XX
-- Objetivo: Evitar que o problema se repita
-- =====================================================================================

-- FUNÇÃO DE VALIDAÇÃO: Verifica se o check-in é válido
CREATE OR REPLACE FUNCTION validate_challenge_checkin()
RETURNS TRIGGER AS $$
DECLARE
    challenge_start_date TIMESTAMP WITH TIME ZONE;
    challenge_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Buscar datas do desafio
    SELECT start_date, end_date
    INTO challenge_start_date, challenge_end_date
    FROM challenges 
    WHERE id = NEW.challenge_id;
    
    -- Verificar se o desafio existe
    IF challenge_start_date IS NULL THEN
        RAISE EXCEPTION 'Desafio não encontrado: %', NEW.challenge_id;
    END IF;
    
    -- VALIDAÇÃO 1: Check-in não pode ser antes do início do desafio
    IF NEW.check_in_date < challenge_start_date THEN
        RAISE EXCEPTION 'CHECK-IN INVÁLIDO: Data do check-in (%) é anterior ao início do desafio (%)', 
            NEW.check_in_date, challenge_start_date;
    END IF;
    
    -- VALIDAÇÃO 2: Check-in não pode ser após o fim do desafio
    IF challenge_end_date IS NOT NULL AND NEW.check_in_date > challenge_end_date THEN
        RAISE EXCEPTION 'CHECK-IN INVÁLIDO: Data do check-in (%) é posterior ao fim do desafio (%)', 
            NEW.check_in_date, challenge_end_date;
    END IF;
    
    -- VALIDAÇÃO 3: Check-in não pode ser no futuro (mais de 1 dia)
    IF NEW.check_in_date > (NOW() + INTERVAL '1 day') THEN
        RAISE EXCEPTION 'CHECK-IN INVÁLIDO: Data do check-in (%) não pode ser no futuro', 
            NEW.check_in_date;
    END IF;
    
    -- Log da validação (opcional)
    RAISE NOTICE 'CHECK-IN VÁLIDO: Usuário % no desafio % em %', 
        NEW.user_id, NEW.challenge_id, NEW.check_in_date;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Aplica validação antes de inserir check-ins
DROP TRIGGER IF EXISTS trigger_validate_challenge_checkin ON challenge_check_ins;
CREATE TRIGGER trigger_validate_challenge_checkin
    BEFORE INSERT OR UPDATE ON challenge_check_ins
    FOR EACH ROW
    EXECUTE FUNCTION validate_challenge_checkin();

-- =====================================================================================
-- FUNÇÃO DE VALIDAÇÃO PARA TREINOS/CHECK-INS RETROATIVOS
-- =====================================================================================

-- FUNÇÃO: Validar treinos retroativos
CREATE OR REPLACE FUNCTION validate_workout_checkin_timing()
RETURNS TRIGGER AS $$
DECLARE
    days_between INTEGER;
    max_retroactive_days INTEGER := 3; -- Máximo 3 dias retroativos permitidos
BEGIN
    -- Calcular diferença em dias entre data do treino e criação
    days_between := EXTRACT(DAY FROM (NOW() - NEW.workout_date));
    
    -- VALIDAÇÃO: Treino não pode ser muito antigo
    IF days_between > max_retroactive_days THEN
        RAISE EXCEPTION 'TREINO RETROATIVO INVÁLIDO: Treino de % está % dias no passado (máximo permitido: %)', 
            NEW.workout_date, days_between, max_retroactive_days;
    END IF;
    
    -- VALIDAÇÃO: Treino não pode ser no futuro
    IF NEW.workout_date > NOW() THEN
        RAISE EXCEPTION 'TREINO INVÁLIDO: Data do treino (%) não pode ser no futuro', 
            NEW.workout_date;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Aplica validação em treinos (se aplicável)
-- DROP TRIGGER IF EXISTS trigger_validate_workout_timing ON workout_records;
-- CREATE TRIGGER trigger_validate_workout_timing
--     BEFORE INSERT OR UPDATE ON workout_records
--     FOR EACH ROW
--     EXECUTE FUNCTION validate_workout_checkin_timing();

-- =====================================================================================
-- FUNÇÃO UTILITÁRIA: Limpar check-ins inválidos de qualquer desafio
-- =====================================================================================

CREATE OR REPLACE FUNCTION clean_invalid_checkins(target_challenge_id UUID DEFAULT NULL)
RETURNS TABLE (
    challenge_id UUID,
    invalid_checkins_removed INTEGER,
    users_affected INTEGER,
    points_removed INTEGER
) AS $$
DECLARE
    challenge_record RECORD;
BEGIN
    -- Se não especificado, limpar todos os desafios
    FOR challenge_record IN 
        SELECT c.id, c.start_date, c.end_date, c.name
        FROM challenges c
        WHERE (target_challenge_id IS NULL OR c.id = target_challenge_id)
        AND c.start_date IS NOT NULL
    LOOP
        -- Contar check-ins inválidos
        SELECT 
            challenge_record.id,
            COUNT(*)::INTEGER,
            COUNT(DISTINCT cci.user_id)::INTEGER,
            COALESCE(SUM(cci.points), 0)::INTEGER
        INTO 
            challenge_id, 
            invalid_checkins_removed, 
            users_affected, 
            points_removed
        FROM challenge_check_ins cci
        WHERE cci.challenge_id = challenge_record.id
        AND (
            cci.check_in_date < challenge_record.start_date
            OR (challenge_record.end_date IS NOT NULL AND cci.check_in_date > challenge_record.end_date)
        );
        
        -- Se há check-ins inválidos, remove-los
        IF invalid_checkins_removed > 0 THEN
            -- Backup antes de remover
            INSERT INTO challenge_check_ins_backup_pre_challenge
            SELECT cci.*, NOW(), 'automated_cleanup'
            FROM challenge_check_ins cci
            WHERE cci.challenge_id = challenge_record.id
            AND (
                cci.check_in_date < challenge_record.start_date
                OR (challenge_record.end_date IS NOT NULL AND cci.check_in_date > challenge_record.end_date)
            );
            
            -- Remover check-ins inválidos
            DELETE FROM challenge_check_ins cci
            WHERE cci.challenge_id = challenge_record.id
            AND (
                cci.check_in_date < challenge_record.start_date
                OR (challenge_record.end_date IS NOT NULL AND cci.check_in_date > challenge_record.end_date)
            );
            
            RAISE NOTICE 'Desafio "%" (ID: %): Removidos % check-ins inválidos de % usuários',
                challenge_record.name, challenge_record.id, invalid_checkins_removed, users_affected;
        END IF;
        
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- CONSULTAS DE TESTE E VERIFICAÇÃO
-- =====================================================================================

-- Testar as validações (descomente para testar)
-- Tentativa de inserir check-in inválido (deve falhar):
/*
INSERT INTO challenge_check_ins (user_id, challenge_id, check_in_date, points)
VALUES (
    '01d4a292-1873-4af6-948b-a55eed56d6b9',
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82',
    '2025-05-25 21:00:00-03',  -- Data anterior ao início
    10
);
*/

-- Verificar se os triggers foram criados
SELECT 
    schemaname,
    tablename,
    triggername,
    tgenabled
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE triggername LIKE '%validate%challenge%'; 