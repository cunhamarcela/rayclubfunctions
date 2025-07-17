DECLARE
    v_workout_record_id UUID;
    v_workout_id UUID;
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
    
    -- Gerar workout_id se necessário
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := gen_random_uuid();
    END IF;
    
    -- Usar workout_record_id fornecido ou gerar novo
    v_workout_record_id := COALESCE(p_workout_record_id, gen_random_uuid());
    
    -- Inserir registro de treino (ajustando nomes das colunas)
    INSERT INTO workout_records(
        id,
        user_id,
        challenge_id,
        workout_id,
        workout_name,
        workout_type,
        date,
        duration_minutes,
        notes,
        is_completed,
        completion_status,
        points,
        created_at,
        updated_at
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
        TRUE, -- Assumindo que treino registrado está completo
        'completed',
        0, -- Pontos serão calculados pela função de ranking
        NOW(),
        NOW()
    );
    
    -- Processar para ranking e atualizar challenge_progress
    BEGIN
        PERFORM process_workout_for_ranking_one_per_day(v_workout_record_id);
    EXCEPTION WHEN OTHERS THEN
        RAISE LOG 'Falha ao processar ranking: %', SQLERRM;
        -- Não falhar a operação principal mesmo se o processamento falhar
    END;
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino registrado com sucesso',
        'workout_id', v_workout_record_id,
        'internal_workout_id', v_workout_id
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar treino: ' || SQLERRM,
            'error_code', SQLSTATE
        );
END; 