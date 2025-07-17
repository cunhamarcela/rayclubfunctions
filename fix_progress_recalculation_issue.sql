-- DIAGNÓSTICO E CORREÇÃO DO PROBLEMA DE RECÁLCULO DE PROGRESSO
-- Problema: Quando um treino é excluído, o progresso não é recalculado corretamente
-- Os pontos continuam no sistema mesmo após a exclusão

-- =====================================================
-- 1. DIAGNÓSTICO INICIAL
-- =====================================================

-- Verificar se as funções corretas estão instaladas
SELECT 
    'Funções existentes no banco' as status,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name IN (
    'delete_workout_and_refresh',
    'recalculate_challenge_progress_from_checkins',
    'update_workout_and_refresh'
) 
AND routine_schema = 'public';

-- Verificar inconsistências entre workout_records e challenge_check_ins
SELECT 
    'Inconsistências detectadas' as status,
    COUNT(*) as total_inconsistencias
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON wr.id = cci.workout_id::uuid
WHERE wr.id IS NULL;

-- =====================================================
-- 2. FUNÇÃO MELHORADA DE RECÁLCULO
-- =====================================================

CREATE OR REPLACE FUNCTION recalculate_challenge_progress_complete(
    p_user_id UUID, 
    p_challenge_id UUID
)
RETURNS JSONB AS $$
DECLARE
    total_points INTEGER := 0;
    total_check_ins INTEGER := 0;
    last_check_in_date TIMESTAMP WITH TIME ZONE;
    challenge_target_days INTEGER;
    completion_percentage NUMERIC := 0;
    user_name TEXT;
    user_photo_url TEXT;
    position_in_ranking INTEGER := 1;
    challenge_exists BOOLEAN := FALSE;
BEGIN
    -- Verificar se o desafio existe
    SELECT EXISTS(SELECT 1 FROM challenges WHERE id = p_challenge_id) INTO challenge_exists;
    
    IF NOT challenge_exists THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Desafio não encontrado'
        );
    END IF;

    -- Buscar informações do usuário
    SELECT COALESCE(name, 'Usuário'), photo_url
    INTO user_name, user_photo_url
    FROM profiles
    WHERE id = p_user_id;

    -- LIMPEZA: Remover check-ins órfãos (sem workout_record correspondente)
    DELETE FROM challenge_check_ins 
    WHERE user_id = p_user_id 
      AND challenge_id = p_challenge_id
      AND workout_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM workout_records 
          WHERE id = challenge_check_ins.workout_id::uuid
      );

    -- RECÁLCULO baseado APENAS em check-ins válidos
    SELECT 
        COALESCE(SUM(CASE 
            WHEN points IS NOT NULL AND points > 0 THEN points 
            ELSE 10 -- Valor padrão por check-in
        END), 0),
        COUNT(DISTINCT DATE(check_in_date)),
        MAX(check_in_date)
    INTO total_points, total_check_ins, last_check_in_date
    FROM challenge_check_ins
    WHERE user_id = p_user_id 
      AND challenge_id = p_challenge_id
      AND (workout_id IS NULL OR EXISTS (
          SELECT 1 FROM workout_records 
          WHERE id = challenge_check_ins.workout_id::uuid
      ));

    -- Calcular dias do desafio
    SELECT GREATEST(1, DATE_PART('day', end_date - start_date)::int + 1)
    INTO challenge_target_days
    FROM challenges
    WHERE id = p_challenge_id;

    -- Calcular porcentagem de conclusão
    completion_percentage := LEAST(100, (total_check_ins * 100.0) / COALESCE(challenge_target_days, 1));

    -- Calcular posição no ranking
    SELECT COALESCE(COUNT(*), 0) + 1
    INTO position_in_ranking
    FROM challenge_progress cp
    WHERE cp.challenge_id = p_challenge_id 
      AND (cp.points > total_points 
           OR (cp.points = total_points AND cp.last_check_in < last_check_in_date));

    -- Atualizar ou inserir em challenge_progress
    INSERT INTO challenge_progress(
        challenge_id,
        user_id,
        points,
        check_ins_count,
        total_check_ins,
        last_check_in,
        completion_percentage,
        position,
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
        position_in_ranking,
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
        position = EXCLUDED.position,
        user_name = EXCLUDED.user_name,
        user_photo_url = EXCLUDED.user_photo_url,
        updated_at = NOW();

    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Progresso recalculado com sucesso',
        'points', total_points,
        'check_ins', total_check_ins,
        'position', position_in_ranking,
        'completion_percentage', completion_percentage
    );

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao recalcular progresso: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. FUNÇÃO DE EXCLUSÃO CORRIGIDA E MELHORADA
-- =====================================================

CREATE OR REPLACE FUNCTION delete_workout_and_refresh_fixed(
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
    check_ins_removed INTEGER := 0;
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

    -- Remover challenge_check_ins relacionados ANTES de excluir o workout
    IF workout_challenge_id IS NOT NULL THEN
        WITH deleted_checkins AS (
            DELETE FROM challenge_check_ins
            WHERE workout_id = p_workout_record_id::text
              AND user_id = p_user_id
              AND challenge_id = workout_challenge_id
            RETURNING id
        )
        SELECT COUNT(*) INTO check_ins_removed FROM deleted_checkins;
        
        RAISE LOG 'Check-ins removidos para workout %: %', p_workout_record_id, check_ins_removed;
    END IF;

    -- Excluir o registro de treino
    DELETE FROM workout_records
    WHERE id = p_workout_record_id AND user_id = p_user_id;

    -- IMPORTANTE: Recalcular progresso após exclusão usando a função melhorada
    IF workout_challenge_id IS NOT NULL THEN
        DECLARE
            recalc_result JSONB;
        BEGIN
            SELECT recalculate_challenge_progress_complete(p_user_id, workout_challenge_id) 
            INTO recalc_result;
            
            RAISE LOG 'Progresso recalculado: %', recalc_result;
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
        'message', 'Treino excluído com sucesso',
        'check_ins_removed', check_ins_removed,
        'challenge_id', workout_challenge_id
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
-- 4. SUBSTITUIR A FUNÇÃO ORIGINAL
-- =====================================================

-- Criar alias para manter compatibilidade
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
BEGIN
    RETURN delete_workout_and_refresh_fixed(p_workout_record_id, p_user_id, p_challenge_id, p_workout_id);
END;
$$;

-- =====================================================
-- 5. PERMISSÕES
-- =====================================================

GRANT EXECUTE ON FUNCTION recalculate_challenge_progress_complete(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_workout_and_refresh_fixed(UUID, UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_workout_and_refresh(UUID, UUID, UUID, UUID) TO authenticated;

-- =====================================================
-- 6. SCRIPT DE LIMPEZA PARA CASOS EXISTENTES
-- =====================================================

-- Função para limpar inconsistências existentes
CREATE OR REPLACE FUNCTION fix_existing_progress_inconsistencies()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    affected_users INTEGER := 0;
    total_fixed INTEGER := 0;
    user_challenge RECORD;
BEGIN
    -- Encontrar todos os usuários com progresso inconsistente
    FOR user_challenge IN 
        SELECT DISTINCT 
            cp.user_id, 
            cp.challenge_id,
            cp.points as current_points,
            COALESCE(cci_summary.real_points, 0) as real_points
        FROM challenge_progress cp
        LEFT JOIN (
            SELECT 
                user_id,
                challenge_id,
                COUNT(DISTINCT DATE(check_in_date)) * 10 as real_points
            FROM challenge_check_ins cci
            WHERE EXISTS (
                SELECT 1 FROM workout_records wr 
                                 WHERE wr.id = cci.workout_id::uuid
            ) OR cci.workout_id IS NULL
            GROUP BY user_id, challenge_id
        ) cci_summary ON cp.user_id = cci_summary.user_id 
                      AND cp.challenge_id = cci_summary.challenge_id
        WHERE cp.points != COALESCE(cci_summary.real_points, 0)
    LOOP
        -- Recalcular progresso para cada usuário afetado
        PERFORM recalculate_challenge_progress_complete(
            user_challenge.user_id, 
            user_challenge.challenge_id
        );
        
        affected_users := affected_users + 1;
    END LOOP;
    
    total_fixed := affected_users;
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Inconsistências corrigidas',
        'users_affected', affected_users,
        'total_fixed', total_fixed
    );
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao corrigir inconsistências: ' || SQLERRM
    );
END;
$$;

GRANT EXECUTE ON FUNCTION fix_existing_progress_inconsistencies() TO authenticated;

-- =====================================================
-- 7. EXECUTAR CORREÇÃO
-- =====================================================

-- Executar a correção para todos os casos existentes
SELECT fix_existing_progress_inconsistencies();

-- Mostrar resultado
SELECT 
    'Correção aplicada' as status,
    NOW() as timestamp; 