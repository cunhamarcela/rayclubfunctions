-- ATUALIZAR FUNÇÕES PRINCIPAIS PARA LÓGICA CORRETA
-- 1 CHECK-IN POR DIA, INDEPENDENTEMENTE DE QUANTOS TREINOS

-- ========================================
-- 1. ATUALIZAR FUNÇÃO PRINCIPAL
-- ========================================

-- Substituir a função process_workout_for_ranking_fixed pela versão correta
CREATE OR REPLACE FUNCTION process_workout_for_ranking_fixed(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
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
    -- Verificar se já foi processado
    IF EXISTS (
        SELECT 1 FROM workout_processing_queue 
        WHERE workout_id = _workout_record_id 
        AND processed_for_ranking = true
    ) THEN
        RETURN true;
    END IF;

    -- Obter informações do treino
    SELECT * INTO workout
    FROM workout_records
    WHERE id = _workout_record_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;

    -- Se não tem desafio associado, marcar como processado
    IF workout.challenge_id IS NULL THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true, processed_at = NOW()
        WHERE workout_id = _workout_record_id;
        RETURN true;
    END IF;

    -- Obter informações do desafio
    SELECT * INTO challenge_record
    FROM challenges
    WHERE id = workout.challenge_id;

    IF NOT FOUND THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Desafio não encontrado',
            processed_at = NOW()
        WHERE workout_id = _workout_record_id;
        RETURN false;
    END IF;

    -- Verificar se usuário participa do desafio
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants
        WHERE challenge_id = workout.challenge_id AND user_id = workout.user_id
    ) THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Usuário não participa deste desafio',
            processed_at = NOW()
        WHERE workout_id = _workout_record_id;
        RETURN false;
    END IF;

    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = NOW()
        WHERE workout_id = _workout_record_id;
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
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Check-in já existe para esta data',
            processed_at = NOW()
        WHERE workout_id = _workout_record_id;
        
        -- Log informativo (não é erro, é comportamento esperado)
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 
                'Check-in já existe para ' || workout_date_only || ' - treino adicional ignorado', 
                'already_checked_in', NOW())
        ON CONFLICT DO NOTHING;
        
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
        user_name, user_photo_url, created_at
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

    -- Marcar como processado
    UPDATE workout_processing_queue
    SET processed_for_ranking = true, processed_at = NOW()
    WHERE workout_id = _workout_record_id;

    -- ATUALIZAR RANKINGS COM CRITÉRIO CORRETO DE DESEMPATE
    WITH user_total_workouts AS (
        SELECT 
            user_id,
            COUNT(*) as total_workouts_ever -- TOTAL de treinos do usuário (todos os tempos)
        FROM workout_records
        GROUP BY user_id
    ),
    ranked_users AS (
        SELECT
            cp.user_id,
            cp.challenge_id,
            DENSE_RANK() OVER (
                ORDER BY 
                    cp.points DESC,                                    -- 1º: Pontos (dias com check-in)
                    COALESCE(utw.total_workouts_ever, 0) DESC,         -- 2º: TOTAL de treinos do usuário
                    cp.last_check_in ASC NULLS LAST                    -- 3º: Data do último check-in
            ) AS new_position
        FROM challenge_progress cp
        LEFT JOIN user_total_workouts utw ON utw.user_id = cp.user_id
        WHERE cp.challenge_id = workout.challenge_id
    )
    UPDATE challenge_progress cp
    SET position = ru.new_position
    FROM ranked_users ru
    WHERE cp.challenge_id = ru.challenge_id AND cp.user_id = ru.user_id;

    RETURN true;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
    VALUES (workout.user_id, workout.challenge_id, _workout_record_id, SQLERRM, 'error', NOW())
    ON CONFLICT DO NOTHING;
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 2. FUNÇÃO PARA VERIFICAR E CORRIGIR DADOS
-- ========================================

CREATE OR REPLACE FUNCTION fix_challenge_data_integrity()
RETURNS TEXT AS $$
DECLARE
    duplicates_removed INTEGER := 0;
    progress_updated INTEGER := 0;
BEGIN
    -- 1. Remover check-ins duplicados por dia
    WITH daily_checkins AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY user_id, challenge_id, DATE(check_in_date) 
                ORDER BY created_at ASC -- Manter o primeiro do dia
            ) as rn
        FROM challenge_check_ins
    )
    DELETE FROM challenge_check_ins 
    WHERE id IN (
        SELECT id FROM daily_checkins WHERE rn > 1
    );
    
    GET DIAGNOSTICS duplicates_removed = ROW_COUNT;

    -- 2. Recalcular challenge_progress baseado em DIAS únicos
    WITH correct_daily_counts AS (
        SELECT 
            cci.challenge_id,
            cci.user_id,
            COUNT(DISTINCT DATE(cci.check_in_date)) as unique_days,
            COUNT(DISTINCT DATE(cci.check_in_date)) * 10 as total_points,
            MAX(cci.check_in_date) as last_check_in,
            COALESCE(p.name, 'Usuário') as user_name,
            p.photo_url as user_photo_url
        FROM challenge_check_ins cci
        LEFT JOIN profiles p ON p.id = cci.user_id
        GROUP BY cci.challenge_id, cci.user_id, p.name, p.photo_url
    )
    UPDATE challenge_progress cp
    SET 
        points = cdc.total_points,
        check_ins_count = cdc.unique_days,
        total_check_ins = cdc.unique_days,
        last_check_in = cdc.last_check_in,
        user_name = cdc.user_name,
        user_photo_url = cdc.user_photo_url,
        completion_percentage = LEAST(100, 
            (cdc.unique_days * 100.0) / GREATEST(1, 
                DATE_PART('day', c.end_date - c.start_date)::int + 1
            )
        ),
        updated_at = NOW()
    FROM correct_daily_counts cdc
    JOIN challenges c ON c.id = cdc.challenge_id
    WHERE cp.challenge_id = cdc.challenge_id 
      AND cp.user_id = cdc.user_id;
    
    GET DIAGNOSTICS progress_updated = ROW_COUNT;

    -- 3. Recalcular rankings com critério correto
    WITH user_total_workouts AS (
        SELECT 
            user_id,
            COUNT(*) as total_workouts_ever
        FROM workout_records
        GROUP BY user_id
    ),
    all_rankings AS (
        SELECT DISTINCT cp.challenge_id
        FROM challenge_progress cp
    )
    UPDATE challenge_progress cp
    SET position = (
        SELECT DENSE_RANK() OVER (
            ORDER BY 
                cp2.points DESC,
                COALESCE(utw.total_workouts_ever, 0) DESC,
                cp2.last_check_in ASC NULLS LAST
        )
        FROM challenge_progress cp2
        LEFT JOIN user_total_workouts utw ON utw.user_id = cp2.user_id
        WHERE cp2.challenge_id = cp.challenge_id
          AND cp2.user_id = cp.user_id
    );

    RETURN FORMAT('Correção concluída: %s check-ins duplicados removidos, %s registros de progresso atualizados', 
                  duplicates_removed, progress_updated);
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 3. EXECUTAR CORREÇÃO
-- ========================================

SELECT fix_challenge_data_integrity(); 