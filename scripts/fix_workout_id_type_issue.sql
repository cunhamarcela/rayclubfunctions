-- Script para corrigir problemas de inconsistência de tipo em workout_id

-- 1. Verificar definição das tabelas relacionadas
SELECT
    table_name,
    column_name,
    data_type,
    udt_name
FROM
    information_schema.columns
WHERE
    table_schema = 'public'
    AND (
        (table_name = 'workout_records' AND (column_name = 'id' OR column_name = 'workout_id'))
        OR (table_name = 'workout_processing_queue' AND column_name = 'workout_id')
        OR (table_name = 'challenge_check_ins' AND column_name = 'workout_id')
    )
ORDER BY
    table_name, column_name;

-- 2. Examinar a função process_workout_for_ranking
SELECT
    prosrc
FROM
    pg_proc
WHERE
    proname = 'process_workout_for_ranking'
LIMIT 1;

-- 3. Corrigir a função process_workout_for_ranking para lidar corretamente com workout_id
CREATE OR REPLACE FUNCTION process_workout_for_ranking(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    workout RECORD;
    challenge_record RECORD;
    user_name TEXT;
    user_photo_url TEXT;
    already_has_checkin BOOLEAN := FALSE;
    points_to_add INTEGER := 10;
    check_in_id UUID;
    challenge_target_points INTEGER;
    check_ins_count INTEGER := 0;
    error_info JSONB;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout 
    FROM workout_records 
    WHERE id = _workout_record_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;
    
    -- Verificações básicas
    IF workout.challenge_id IS NULL THEN
        -- Sem desafio associado, marcar como processado e sair
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        RETURN TRUE;
    END IF;
    
    -- VERIFICAÇÕES INICIAIS
    SELECT * INTO challenge_record 
    FROM challenges 
    WHERE id = workout.challenge_id 
    FOR UPDATE SKIP LOCKED;
    
    IF NOT FOUND THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Desafio não encontrado',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        INSERT INTO check_in_error_logs(
            user_id, challenge_id, workout_id, error_message, status, created_at
        ) VALUES (
            workout.user_id, workout.challenge_id, _workout_record_id, 
            'Desafio não encontrado: ' || workout.challenge_id,
            'error', NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar se o usuário é membro do desafio
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants 
        WHERE challenge_id = workout.challenge_id 
        AND user_id = workout.user_id
    ) THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Usuário não participa deste desafio',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        INSERT INTO check_in_error_logs(
            user_id, challenge_id, workout_id, error_message, status, created_at
        ) VALUES (
            workout.user_id, workout.challenge_id, _workout_record_id, 
            'Usuário não participa deste desafio',
            'error', NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        INSERT INTO check_in_error_logs(
            user_id, challenge_id, workout_id, error_message, status, created_at
        ) VALUES (
            workout.user_id, workout.challenge_id, _workout_record_id, 
            'Duração mínima não atingida: ' || workout.duration_minutes || 'min',
            'skipped', NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar se já existe check-in para esta data
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = workout.user_id 
        AND challenge_id = workout.challenge_id
        AND DATE(check_in_date) = DATE(workout.date)
    ) INTO already_has_checkin;
    
    IF already_has_checkin THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Check-in já existe para esta data',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        INSERT INTO check_in_error_logs(
            user_id, challenge_id, workout_id, error_message, status, created_at
        ) VALUES (
            workout.user_id, workout.challenge_id, _workout_record_id, 
            'Check-in já existe para a data: ' || workout.date,
            'duplicate', NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- OBTER INFORMAÇÕES DO USUÁRIO
    SELECT 
        COALESCE(name, 'Usuário') AS name,
        photo_url
    INTO 
        user_name, user_photo_url
    FROM profiles 
    WHERE id = workout.user_id;
    
    -- Obter a meta de pontos do desafio para cálculo de porcentagem
    challenge_target_points := COALESCE(challenge_record.points, 100);
    
    -- CRIAR CHECK-IN PARA O DESAFIO
    -- IMPORTANTE: Corrigido aqui para usar workout.workout_id (TEXT) ao invés de workout_id (UUID)
    INSERT INTO challenge_check_ins(
        id,
        challenge_id,
        user_id,
        check_in_date,
        workout_id,  -- Este campo é TEXT na tabela challenge_check_ins
        points_earned,
        created_at
    ) VALUES (
        gen_random_uuid(),
        workout.challenge_id,
        workout.user_id,
        workout.date,
        workout.workout_id,  -- Usamos workout.workout_id (TEXT) e não _workout_record_id (UUID)
        points_to_add,
        NOW()
    ) RETURNING id INTO check_in_id;
    
    -- ATUALIZAR PROGRESSO DO DESAFIO
    SELECT COUNT(*) INTO check_ins_count
    FROM challenge_check_ins
    WHERE challenge_id = workout.challenge_id
    AND user_id = workout.user_id;
    
    -- Atualizar ou criar registro de progresso
    INSERT INTO challenge_progress(
        challenge_id,
        user_id,
        points_earned,
        check_ins_count,
        last_check_in,
        completion_percentage,
        created_at,
        updated_at,
        user_name,
        user_photo
    ) VALUES (
        workout.challenge_id,
        workout.user_id,
        points_to_add,
        1,
        workout.date,
        (points_to_add::FLOAT / challenge_target_points::FLOAT) * 100.0,
        NOW(),
        NOW(),
        user_name,
        user_photo_url
    )
    ON CONFLICT (challenge_id, user_id) 
    DO UPDATE SET
        points_earned = challenge_progress.points_earned + points_to_add,
        check_ins_count = challenge_progress.check_ins_count + 1,
        last_check_in = workout.date,
        completion_percentage = ((challenge_progress.points_earned + points_to_add)::FLOAT / challenge_target_points::FLOAT) * 100.0,
        updated_at = NOW(),
        user_name = EXCLUDED.user_name,
        user_photo = EXCLUDED.user_photo;
    
    -- Marcar como processado
    UPDATE workout_processing_queue 
    SET processed_for_ranking = TRUE,
        processed_at = NOW() 
    WHERE workout_id = _workout_record_id;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        BEGIN
            INSERT INTO check_in_error_logs(
                user_id, challenge_id, workout_id, error_message, status, created_at
            ) VALUES (
                workout.user_id, workout.challenge_id, _workout_record_id, 
                SQLERRM, 'error', NOW()
            );
        EXCEPTION WHEN OTHERS THEN
            -- Ignora erros ao registrar o log
            NULL;
        END;
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql; 