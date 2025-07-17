DECLARE
    workout RECORD;
    challenge_record RECORD;
    user_name TEXT;
    user_photo_url TEXT;
    already_has_checkin_today BOOLEAN := FALSE;
    points_to_add INTEGER := 10;
    check_in_id UUID;
    challenge_target_days INTEGER;
    current_check_ins_count INTEGER := 0;
    completion NUMERIC := 0;
    workout_date_only DATE;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout
    FROM workout_records
    WHERE id = _workout_record_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;

    -- Se não tem desafio associado, não processar
    IF workout.challenge_id IS NULL THEN
        RETURN true;
    END IF;

    -- Obter informações do desafio
    SELECT * INTO challenge_record
    FROM challenges
    WHERE id = workout.challenge_id;

    IF NOT FOUND THEN
        RAISE LOG 'Desafio não encontrado para workout_id: %', _workout_record_id;
        RETURN false;
    END IF;

    -- Verificar se usuário participa do desafio
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants
        WHERE challenge_id = workout.challenge_id AND user_id = workout.user_id
    ) THEN
        RAISE LOG 'Usuário % não participa do desafio %', workout.user_id, workout.challenge_id;
        RETURN false;
    END IF;

    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        RAISE LOG 'Duração mínima não atingida (45min) para workout_id: %', _workout_record_id;
        RETURN false;
    END IF;

    -- LÓGICA CORRETA: Verificar se JÁ EXISTE CHECK-IN PARA ESTE DIA
    workout_date_only := DATE(workout.date);
    
    SELECT EXISTS (
        SELECT 1 FROM challenge_check_ins
        WHERE user_id = workout.user_id
          AND challenge_id = workout.challenge_id
          AND DATE(check_in_date) = workout_date_only
    ) INTO already_has_checkin_today;

    IF already_has_checkin_today THEN
        -- JÁ EXISTE CHECK-IN PARA HOJE - NÃO CRIAR OUTRO
        RAISE LOG 'Check-in já existe para a data % - workout_id: %', workout_date_only, _workout_record_id;
        
        -- Log informativo (não é erro, é comportamento esperado)
        BEGIN
            INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
            VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 
                    'Check-in já existe para ' || workout_date_only || ' - treino adicional ignorado', 
                    'already_checked_in', NOW())
            ON CONFLICT DO NOTHING;
        EXCEPTION WHEN OTHERS THEN
            -- Se a tabela de logs não existir, apenas ignorar
            NULL;
        END;
        
        RETURN true; -- Sucesso, mas não criou check-in
    END IF;

    -- Obter dados do usuário
    SELECT COALESCE(name, 'Usuário'), photo_url
    INTO user_name, user_photo_url
    FROM profiles
    WHERE id = workout.user_id;

    -- Calcular dias do desafio
    challenge_target_days := GREATEST(1, DATE_PART('day', challenge_record.end_date - challenge_record.start_date)::int + 1);

    -- CRIAR O ÚNICO CHECK-IN DO DIA
    INSERT INTO challenge_check_ins(
        id, challenge_id, user_id, check_in_date, workout_id,
        points, workout_name, workout_type, duration_minutes,
        user_name, user_photo_url, created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        workout.challenge_id,
        workout.user_id,
        workout_date_only, -- Usar apenas a data, sem hora
        workout.id,
        points_to_add,
        workout.workout_name,
        workout.workout_type,
        workout.duration_minutes,
        user_name,
        user_photo_url,
        NOW(),
        NOW()
    ) RETURNING id INTO check_in_id;

    -- CONTAR CHECK-INS ÚNICOS POR DIA (APÓS INSERÇÃO)
    SELECT COUNT(DISTINCT DATE(check_in_date)) INTO current_check_ins_count
    FROM challenge_check_ins
    WHERE challenge_id = workout.challenge_id AND user_id = workout.user_id;

    -- Calcular porcentagem de conclusão
    completion := LEAST(100, (current_check_ins_count * 100.0) / challenge_target_days);

    -- ATUALIZAR PROGRESSO COM CONTAGEM CORRETA
    INSERT INTO challenge_progress(
        challenge_id, user_id, points, check_ins_count, total_check_ins,
        last_check_in, completion_percentage, created_at, updated_at,
        user_name, user_photo_url
    ) VALUES (
        workout.challenge_id,
        workout.user_id,
        points_to_add,
        current_check_ins_count, -- Dias únicos com check-in
        current_check_ins_count, -- Dias únicos com check-in
        workout.date,
        completion,
        NOW(),
        NOW(),
        user_name,
        user_photo_url
    )
    ON CONFLICT (challenge_id, user_id)
    DO UPDATE SET
        points = COALESCE(challenge_progress.points, 0) + excluded.points,
        check_ins_count = current_check_ins_count, -- Usar contagem correta
        total_check_ins = current_check_ins_count,  -- Usar contagem correta
        last_check_in = excluded.last_check_in,
        completion_percentage = completion,
        updated_at = NOW(),
        user_name = excluded.user_name,
        user_photo_url = excluded.user_photo_url;

    RETURN true;

EXCEPTION WHEN OTHERS THEN
    BEGIN
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, SQLERRM, 'error', NOW())
        ON CONFLICT DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        -- Se a tabela de logs não existir, apenas fazer log
        RAISE LOG 'Erro ao processar workout_id %: %', _workout_record_id, SQLERRM;
    END;
    RETURN false;
END; 