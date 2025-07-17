-- Modificar a função record_challenge_check_in para adicionar notificação de atualização do dashboard
CREATE OR REPLACE FUNCTION record_challenge_check_in(
    _user_id UUID,
    _challenge_id UUID,
    _workout_id VARCHAR,
    _workout_name VARCHAR,
    _workout_type VARCHAR,
    _duration_minutes INTEGER,
    _date TIMESTAMPTZ,
    _points INTEGER DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    check_in_id UUID;
    challenge_record RECORD;
    user_name TEXT;
    user_photo_url TEXT;
    workout_date DATE := DATE(_date);
    already_has_checkin BOOLEAN := FALSE;
    current_streak INTEGER := 0;
    current_points INTEGER := 0;
    points_to_add INTEGER := COALESCE(_points, 10);
    result JSONB;
    workout_record_id UUID;
    is_valid_for_challenge BOOLEAN := _duration_minutes >= 45;
    check_ins_count INTEGER := 0;
    
    -- Nova variável para armazenar UUID
    v_workout_id UUID;
    
    -- Novas variáveis para cálculo de porcentagem
    challenge_target_points INTEGER;
    updated_completion_percentage DOUBLE PRECISION := 0.0;
    
    -- Variáveis para dashboard
    dashboard_workouts INTEGER := 0;
    dashboard_points INTEGER := 0;
    workouts_by_type JSONB;
    last_workout_date DATE;
BEGIN
    -- Iniciar transação explícita para garantir consistência
    BEGIN
        -- Converter workout_id para UUID ou gerar novo UUID
        BEGIN
            v_workout_id := _workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;

        -- 1. VERIFICAÇÕES INICIAIS COM BLOQUEIO PARA EVITAR CONDIÇÕES DE CORRIDA
        -- Verificar se o desafio existe e bloquear para atualização
        SELECT * INTO challenge_record 
        FROM challenges 
        WHERE id = _challenge_id 
        FOR UPDATE;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Desafio não encontrado';
        END IF;
        
        -- Obter a meta de pontos do desafio para cálculo de porcentagem
        challenge_target_points := challenge_record.points;

        -- Verificar se o usuário é membro do desafio
        IF NOT EXISTS (
            SELECT 1 FROM challenge_participants 
            WHERE challenge_id = _challenge_id 
            AND user_id = _user_id
            FOR UPDATE
        ) THEN
            RAISE EXCEPTION 'Usuário não participa deste desafio';
        END IF;

        -- Verificar se já existe um check-in para esta data (com bloqueio)
        SELECT EXISTS (
            SELECT 1 
            FROM challenge_check_ins 
            WHERE user_id = _user_id 
            AND challenge_id = _challenge_id
            AND DATE(check_in_date) = workout_date
            FOR UPDATE
        ) INTO already_has_checkin;

        -- 2. OBTER INFORMAÇÕES DO USUÁRIO (COM BLOQUEIO)
        SELECT 
            COALESCE(name, 'Usuário') AS name,
            photo_url
        INTO 
            user_name, user_photo_url
        FROM profiles 
        WHERE id = _user_id
        FOR UPDATE;

        -- 3. REGISTRAR O TREINO (SEMPRE, INDEPENDENTE DO CHECK-IN)
        INSERT INTO workout_records(
            user_id,
            challenge_id,
            workout_id,
            workout_name,
            workout_type,
            date,
            duration_minutes,
            points,
            created_at
        ) VALUES (
            _user_id,
            _challenge_id,
            v_workout_id,
            _workout_name,
            _workout_type,
            _date,
            _duration_minutes,
            points_to_add,
            NOW()
        ) RETURNING id INTO workout_record_id;

        -- 4. VERIFICAR SE JÁ TEM CHECK-IN
        IF already_has_checkin THEN
            -- Retornar mensagem de erro, mas não fazer rollback já que o workout foi registrado
            result := jsonb_build_object(
                'success', FALSE,
                'message', 'Você já registrou um check-in para este desafio hoje',
                'is_already_checked_in', TRUE,
                'points_earned', 0,
                'streak', 0
            );
            RETURN result;
        END IF;

        -- 5. CRIAR CHECK-IN PARA O DESAFIO
        INSERT INTO challenge_check_ins(
            id,
            challenge_id,
            user_id,
            check_in_date,
            workout_id,
            points_earned,
            created_at
        ) VALUES (
            gen_random_uuid(),
            _challenge_id,
            _user_id,
            _date,
            v_workout_id,
            points_to_add,
            NOW()
        ) RETURNING id INTO check_in_id;

        -- 6. ATUALIZAR PROGRESSO DO DESAFIO
        -- Contar total de check-ins para este usuário neste desafio
        SELECT COUNT(*) INTO check_ins_count
        FROM challenge_check_ins
        WHERE challenge_id = _challenge_id
        AND user_id = _user_id;
        
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
            _challenge_id,
            _user_id,
            points_to_add, -- Adicionar pontos do check-in atual
            1, -- Primeiro check-in
            _date,
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
            last_check_in = _date,
            completion_percentage = ((challenge_progress.points_earned + points_to_add)::FLOAT / challenge_target_points::FLOAT) * 100.0,
            updated_at = NOW(),
            user_name = EXCLUDED.user_name,
            user_photo = EXCLUDED.user_photo;
        
        -- 7. ATUALIZAR PROGRESSO GERAL DO USUÁRIO
        -- Obter total de pontos em desafios, para facilitar o dashboard
        INSERT INTO user_progress(
            user_id,
            challenge_points,
            challenges_joined_count,
            challenges_completed_count,
            updated_at
        ) VALUES (
            _user_id,
            points_to_add,
            1,
            0,
            NOW()
        ) 
        ON CONFLICT (user_id) 
        DO UPDATE SET
            challenge_points = user_progress.challenge_points + points_to_add,
            challenges_joined_count = user_progress.challenges_joined_count,
            challenges_completed_count = user_progress.challenges_completed_count,
            updated_at = NOW();
        
        -- 8. Preparar resposta de sucesso
        result := jsonb_build_object(
            'success', TRUE,
            'message', 'Check-in registrado com sucesso',
            'challenge_id', _challenge_id,
            'check_in_id', check_in_id,
            'workout_id', v_workout_id,
            'points_earned', points_to_add,
            'check_ins_count', check_ins_count,
            'is_already_checked_in', FALSE
        );
        
        -- Emitir notificação de evento para dashboard update
        PERFORM pg_notify('dashboard_updates', json_build_object(
            'user_id', _user_id,
            'action', 'workout_recorded',
            'workout_id', v_workout_id,
            'points', points_to_add
        )::text);
        
        RETURN result;
    EXCEPTION
        WHEN OTHERS THEN
            -- Em caso de erro, fazer rollback e retornar mensagem de erro
            RAISE NOTICE 'Erro ao registrar check-in: %', SQLERRM;
            result := jsonb_build_object(
                'success', FALSE,
                'message', 'Erro ao registrar check-in: ' || SQLERRM,
                'is_already_checked_in', FALSE,
                'points_earned', 0,
                'streak', 0
            );
            RETURN result;
    END;
END;
$$ LANGUAGE plpgsql; 