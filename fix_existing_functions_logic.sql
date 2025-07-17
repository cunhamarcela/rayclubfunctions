-- CORREÇÃO DA LÓGICA DAS FUNÇÕES EXISTENTES
-- Mantém os mesmos nomes que já estão sendo usados no código
-- Apenas corrige a lógica para funcionar com challenge_check_ins

-- =====================================================
-- 1. CORRIGIR recalculate_challenge_progress EXISTENTE
-- =====================================================

CREATE OR REPLACE FUNCTION recalculate_challenge_progress(
    p_user_id UUID, 
    p_challenge_id UUID
)
RETURNS VOID AS $$
DECLARE
    total_points INTEGER := 0;
    total_check_ins INTEGER := 0;
    last_check_in_date TIMESTAMP WITH TIME ZONE;
    challenge_target_days INTEGER;
    completion_percentage NUMERIC := 0;
    user_name TEXT;
    user_photo_url TEXT;
BEGIN
    -- Buscar informações do usuário
    SELECT COALESCE(name, 'Usuário'), photo_url
    INTO user_name, user_photo_url
    FROM profiles
    WHERE id = p_user_id;

    -- CORRIGIDO: Usar challenge_check_ins como fonte da verdade
    -- ao invés de workout_records que pode estar inconsistente
    SELECT 
        COALESCE(SUM(points), 0),
        COUNT(DISTINCT DATE(check_in_date)),
        MAX(check_in_date)
    INTO total_points, total_check_ins, last_check_in_date
    FROM challenge_check_ins
    WHERE user_id = p_user_id 
      AND challenge_id = p_challenge_id;

    -- Calcular dias do desafio
    SELECT GREATEST(1, DATE_PART('day', end_date - start_date)::int + 1)
    INTO challenge_target_days
    FROM challenges
    WHERE id = p_challenge_id;

    -- Calcular porcentagem de conclusão
    completion_percentage := LEAST(100, (total_check_ins * 100.0) / COALESCE(challenge_target_days, 1));

    -- Atualizar ou inserir em challenge_progress
    INSERT INTO challenge_progress(
        challenge_id,
        user_id,
        points,
        check_ins_count,
        total_check_ins,
        last_check_in,
        completion_percentage,
        user_name,
        user_photo_url,
        created_at,
        updated_at
    ) VALUES (
        p_challenge_id,
        p_user_id,
        total_points,
        total_check_ins,
        total_check_ins,
        last_check_in_date,
        completion_percentage,
        user_name,
        user_photo_url,
        NOW(),
        NOW()
    )
    ON CONFLICT (challenge_id, user_id) 
    DO UPDATE SET
        points = EXCLUDED.points,
        check_ins_count = EXCLUDED.check_ins_count,
        total_check_ins = EXCLUDED.total_check_ins,
        last_check_in = EXCLUDED.last_check_in,
        completion_percentage = EXCLUDED.completion_percentage,
        user_name = EXCLUDED.user_name,
        user_photo_url = EXCLUDED.user_photo_url,
        updated_at = NOW();

    RAISE LOG 'Challenge progress recalculado: user=%, challenge=%, points=%, check_ins=%', 
              p_user_id, p_challenge_id, total_points, total_check_ins;

EXCEPTION WHEN OTHERS THEN
    RAISE LOG 'Erro ao recalcular challenge progress: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. CORRIGIR update_workout_and_refresh EXISTENTE
-- =====================================================

CREATE OR REPLACE FUNCTION update_workout_and_refresh(
    p_workout_record_id UUID,
    p_user_id UUID,
    p_challenge_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_notes TEXT DEFAULT '',
    p_workout_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    old_workout RECORD;
    old_challenge_id UUID;
    workout_date_only DATE;
BEGIN
    -- Verificar se o usuário é o dono do registro
    IF NOT EXISTS (
        SELECT 1 FROM workout_records 
        WHERE id = p_workout_record_id AND user_id = p_user_id
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Não é possível editar treino que não pertence ao usuário',
            'error_code', 'unauthorized'
        );
    END IF;
    
    -- Obter dados do treino antes da atualização
    SELECT * INTO old_workout
    FROM workout_records
    WHERE id = p_workout_record_id;
    
    old_challenge_id := old_workout.challenge_id;
    
    -- Atualizar o registro de treino
    UPDATE workout_records SET
        challenge_id = p_challenge_id,
        workout_id = COALESCE(p_workout_id, workout_id),
        workout_name = p_workout_name,
        workout_type = p_workout_type,
        date = p_date,
        duration_minutes = p_duration_minutes,
        notes = p_notes,
        updated_at = NOW()
    WHERE id = p_workout_record_id;
    
    -- CORRIGIDO: Atualizar challenge_check_ins correspondente
    IF p_challenge_id IS NOT NULL THEN
        UPDATE challenge_check_ins SET
            workout_name = p_workout_name,
            workout_type = p_workout_type,
            duration_minutes = p_duration_minutes,
            updated_at = NOW()
        WHERE workout_id = p_workout_record_id
          AND user_id = p_user_id
          AND challenge_id = p_challenge_id;
          
        -- Recalcular progresso do desafio atual
        BEGIN
            PERFORM recalculate_challenge_progress(p_user_id, p_challenge_id);
        EXCEPTION WHEN OTHERS THEN
            RAISE LOG 'Erro ao recalcular progresso do desafio atual: %', SQLERRM;
        END;
    END IF;
    
    -- Se o desafio mudou, recalcular progresso do desafio anterior também
    IF old_challenge_id IS NOT NULL AND old_challenge_id != p_challenge_id THEN
        BEGIN
            PERFORM recalculate_challenge_progress(p_user_id, old_challenge_id);
        EXCEPTION WHEN OTHERS THEN
            RAISE LOG 'Erro ao recalcular progresso do desafio anterior: %', SQLERRM;
        END;
    END IF;
    
    -- Atualizar dashboard
    BEGIN
        PERFORM refresh_dashboard_data(p_user_id);
    EXCEPTION WHEN OTHERS THEN
        RAISE LOG 'Erro ao atualizar dashboard: %', SQLERRM;
    END;
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino atualizado com sucesso',
        'workout_record_id', p_workout_record_id
    );
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao atualizar treino: ' || SQLERRM,
        'error_code', SQLSTATE
    );
END;
$$;

-- =====================================================
-- 3. CORRIGIR delete_workout_and_refresh EXISTENTE
-- =====================================================

CREATE OR REPLACE FUNCTION delete_workout_and_refresh(
    p_workout_record_id UUID,
    p_user_id UUID,
    p_challenge_id UUID,
    p_workout_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    workout_challenge_id UUID;
BEGIN
    -- Verificar se o registro existe e pertence ao usuário
    SELECT challenge_id INTO workout_challenge_id
    FROM workout_records 
    WHERE id = p_workout_record_id AND user_id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Registro não encontrado ou não pertence ao usuário',
            'error_code', 'not_found'
        );
    END IF;

    -- CORRIGIDO: Excluir challenge_check_ins relacionados ANTES de excluir o workout
    IF workout_challenge_id IS NOT NULL THEN
        DELETE FROM challenge_check_ins
        WHERE workout_id = p_workout_record_id
          AND user_id = p_user_id
          AND challenge_id = workout_challenge_id;
          
        RAISE LOG 'Check-ins removidos para workout: %', p_workout_record_id;
    END IF;

    -- Excluir o registro de treino
    DELETE FROM workout_records
    WHERE id = p_workout_record_id AND user_id = p_user_id;

    -- CORRIGIDO: Recalcular progresso do desafio após exclusão
    IF workout_challenge_id IS NOT NULL THEN
        BEGIN
            PERFORM recalculate_challenge_progress(p_user_id, workout_challenge_id);
        EXCEPTION WHEN OTHERS THEN
            RAISE LOG 'Erro ao recalcular progresso após exclusão: %', SQLERRM;
        END;
    END IF;

    -- Atualizar dashboard
    BEGIN
        PERFORM refresh_dashboard_data(p_user_id);
    EXCEPTION WHEN OTHERS THEN
        RAISE LOG 'Erro ao atualizar dashboard: %', SQLERRM;
    END;

    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino excluído com sucesso'
    );
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao excluir treino: ' || SQLERRM,
        'error_code', SQLSTATE
    );
END;
$$;

-- =====================================================
-- 4. PERMISSÕES (mantém as mesmas já existentes)
-- =====================================================

GRANT EXECUTE ON FUNCTION recalculate_challenge_progress(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_workout_and_refresh(UUID, UUID, UUID, TEXT, TEXT, INTEGER, TIMESTAMP WITH TIME ZONE, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_workout_and_refresh(UUID, UUID, UUID, UUID) TO authenticated;

-- =====================================================
-- 5. COMENTÁRIOS ATUALIZADOS
-- =====================================================

COMMENT ON FUNCTION recalculate_challenge_progress IS 'Recalcula o progresso do usuário em um desafio baseado em challenge_check_ins (fonte da verdade)';
COMMENT ON FUNCTION update_workout_and_refresh IS 'Atualiza treino e sincroniza challenge_check_ins e challenge_progress';
COMMENT ON FUNCTION delete_workout_and_refresh IS 'Exclui treino, remove check-ins relacionados e recalcula progresso'; 