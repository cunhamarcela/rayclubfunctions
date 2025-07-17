-- Função simplificada de registro de treino
-- Elimina a necessidade da workout_processing_queue
-- Faz tudo de uma vez: workout_records + challenge_check_ins + challenge_progress

CREATE OR REPLACE FUNCTION record_workout_simplified(
    p_user_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_challenge_id UUID DEFAULT NULL,
    p_workout_id TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT '',
    p_workout_record_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_workout_record_id UUID;
    v_workout_id UUID;
    v_points_earned INTEGER := 10; -- Pontos padrão por treino
    v_existing_checkin_today BOOLEAN := FALSE;
    v_challenge_exists BOOLEAN := FALSE;
    v_user_in_challenge BOOLEAN := FALSE;
    v_current_points INTEGER := 0;
    v_current_checkins INTEGER := 0;
BEGIN
    -- Validações básicas
    IF p_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'user_id é obrigatório',
            'error_code', 'MISSING_USER_ID'
        );
    END IF;
    
    -- Verificar se usuário existe
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_user_id) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não encontrado',
            'error_code', 'USER_NOT_FOUND'
        );
    END IF;
    
    -- Gerar IDs se necessário
    v_workout_record_id := COALESCE(p_workout_record_id, gen_random_uuid());
    
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := gen_random_uuid();
    END IF;
    
    -- 1. INSERIR WORKOUT_RECORD
    INSERT INTO workout_records(
        id,
        user_id,
        challenge_id,
        workout_id,
        workout_name,
        workout_type,
        workout_date,
        duration_minutes,
        notes,
        created_at
    ) VALUES (
        v_workout_record_id,
        p_user_id,
        p_challenge_id,
        v_workout_id,
        p_workout_name,
        p_workout_type,
        p_date,
        p_duration_minutes,
        p_notes,
        NOW()
    );
    
    -- 2. PROCESSAR CHALLENGE (se especificado)
    IF p_challenge_id IS NOT NULL THEN
        -- Verificar se challenge existe e está ativo
        SELECT EXISTS(
            SELECT 1 FROM challenges 
            WHERE id = p_challenge_id AND active = true
        ) INTO v_challenge_exists;
        
        IF v_challenge_exists THEN
            -- Verificar se usuário está inscrito no challenge
            SELECT EXISTS(
                SELECT 1 FROM challenge_participants 
                WHERE user_id = p_user_id AND challenge_id = p_challenge_id
            ) INTO v_user_in_challenge;
            
            -- Inscrever automaticamente se não estiver
            IF NOT v_user_in_challenge THEN
                INSERT INTO challenge_participants (user_id, challenge_id, joined_at)
                VALUES (p_user_id, p_challenge_id, NOW())
                ON CONFLICT (user_id, challenge_id) DO NOTHING;
                
                v_user_in_challenge := TRUE;
            END IF;
            
            IF v_user_in_challenge THEN
                -- Verificar se já tem check-in hoje para este challenge
                SELECT EXISTS(
                    SELECT 1 FROM challenge_check_ins 
                    WHERE user_id = p_user_id 
                    AND challenge_id = p_challenge_id
                    AND DATE(checked_in_at) = DATE(p_date)
                ) INTO v_existing_checkin_today;
                
                -- Só criar check-in se não tiver um hoje
                IF NOT v_existing_checkin_today THEN
                    -- 3. INSERIR CHALLENGE_CHECK_IN
                    INSERT INTO challenge_check_ins(
                        id,
                        user_id,
                        challenge_id,
                        workout_record_id,
                        points_earned,
                        checked_in_at,
                        created_at
                    ) VALUES (
                        gen_random_uuid(),
                        p_user_id,
                        p_challenge_id,
                        v_workout_record_id,
                        v_points_earned,
                        p_date,
                        NOW()
                    );
                    
                    -- 4. ATUALIZAR/INSERIR CHALLENGE_PROGRESS
                    -- Buscar progresso atual
                    SELECT 
                        COALESCE(total_points, 0),
                        COALESCE(check_ins_count, 0)
                    INTO v_current_points, v_current_checkins
                    FROM challenge_progress 
                    WHERE user_id = p_user_id AND challenge_id = p_challenge_id;
                    
                    -- Inserir ou atualizar progresso
                    INSERT INTO challenge_progress (
                        user_id,
                        challenge_id,
                        total_points,
                        check_ins_count,
                        last_check_in,
                        progress_percentage,
                        updated_at
                    ) VALUES (
                        p_user_id,
                        p_challenge_id,
                        v_current_points + v_points_earned,
                        v_current_checkins + 1,
                        p_date,
                        ((v_current_checkins + 1) * 100.0 / 30), -- assumindo 30 dias
                        NOW()
                    )
                    ON CONFLICT (user_id, challenge_id) 
                    DO UPDATE SET
                        total_points = challenge_progress.total_points + v_points_earned,
                        check_ins_count = challenge_progress.check_ins_count + 1,
                        last_check_in = p_date,
                        progress_percentage = ((challenge_progress.check_ins_count + 1) * 100.0 / 30),
                        updated_at = NOW();
                        
                    -- 5. RECALCULAR RANKINGS
                    WITH ranked_users AS (
                        SELECT 
                            user_id,
                            ROW_NUMBER() OVER (
                                ORDER BY total_points DESC, 
                                check_ins_count DESC, 
                                last_check_in DESC
                            ) as new_rank
                        FROM challenge_progress 
                        WHERE challenge_id = p_challenge_id
                    )
                    UPDATE challenge_progress 
                    SET 
                        current_rank = ranked_users.new_rank,
                        updated_at = NOW()
                    FROM ranked_users 
                    WHERE challenge_progress.user_id = ranked_users.user_id 
                    AND challenge_progress.challenge_id = p_challenge_id;
                    
                END IF;
            END IF;
        END IF;
    END IF;
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino registrado com sucesso',
        'workout_record_id', v_workout_record_id,
        'workout_id', v_workout_id,
        'points_earned', CASE WHEN v_existing_checkin_today THEN 0 ELSE v_points_earned END,
        'check_in_created', NOT v_existing_checkin_today AND p_challenge_id IS NOT NULL
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar treino: ' || SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql;

-- Teste da função simplificada
SELECT 'Função simplificada criada! Testando...' as status;

DO $$
DECLARE
    result JSONB;
BEGIN
    -- Testar com seu usuário real
    SELECT record_workout_simplified(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,  -- p_user_id
        'Treino Simplificado Teste',                    -- p_workout_name
        'cardio',                                       -- p_workout_type
        45,                                            -- p_duration_minutes
        NOW(),                                         -- p_date
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, -- p_challenge_id
        'SIMP-' || gen_random_uuid()::text,            -- p_workout_id
        'Teste da função simplificada',                -- p_notes
        gen_random_uuid()                              -- p_workout_record_id
    ) INTO result;
    
    RAISE NOTICE 'RESULTADO FUNÇÃO SIMPLIFICADA: %', result;
END
$$;

-- Verificar resultado
SELECT 'Verificando resultado do teste:' as status;

-- Workout records
SELECT 'Últimos workout records:' as tipo;
SELECT 
    id, workout_name, duration_minutes, workout_date, created_at
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY created_at DESC 
LIMIT 3;

-- Check-ins
SELECT 'Últimos check-ins:' as tipo;
SELECT 
    id, points_earned, checked_in_at, created_at
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY created_at DESC 
LIMIT 3;

-- Progresso atualizado
SELECT 'Progresso atual:' as tipo;
SELECT 
    total_points, 
    check_ins_count, 
    current_rank, 
    progress_percentage,
    last_check_in,
    updated_at
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 