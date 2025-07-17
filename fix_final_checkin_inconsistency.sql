-- SCRIPT FINAL PARA CORRIGIR INCONSISTÊNCIA DE CHECK-INS
-- Problema: Múltiplos check-ins por dia quando deveria ser apenas 1 por dia

-- ========================================
-- PASSO 1: DIAGNÓSTICO INICIAL
-- ========================================
SELECT 
    'DIAGNÓSTICO INICIAL' as status,
    p.name,
    COUNT(DISTINCT wr.id) as total_treinos,
    COUNT(DISTINCT cci.id) as total_checkins,
    COUNT(DISTINCT DATE(cci.check_in_date)) as checkins_unicos_por_dia
FROM profiles p
LEFT JOIN workout_records wr ON wr.user_id = p.id
LEFT JOIN challenge_check_ins cci ON cci.user_id = p.id
WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
GROUP BY p.name
ORDER BY p.name;

-- ========================================
-- PASSO 2: REMOVER CHECK-INS DUPLICADOS
-- ========================================
WITH duplicated_checkins AS (
    SELECT 
        cci.id,
        cci.user_id,
        cci.challenge_id,
        DATE(cci.check_in_date) as check_date,
        ROW_NUMBER() OVER (
            PARTITION BY cci.user_id, cci.challenge_id, DATE(cci.check_in_date) 
            ORDER BY cci.created_at ASC
        ) as rn
    FROM challenge_check_ins cci
    JOIN profiles p ON p.id = cci.user_id
    WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
)
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id FROM duplicated_checkins WHERE rn > 1
);

-- ========================================
-- PASSO 3: RECALCULAR PROGRESSO CORRETO
-- ========================================
WITH correct_progress AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date)) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date)) * 10 as total_points, -- 10 pontos por dia
        MAX(cci.check_in_date) as last_check_in_date,
        p.name as user_name,
        p.photo_url as user_photo_url
    FROM challenge_check_ins cci
    JOIN profiles p ON p.id = cci.user_id
    WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
    GROUP BY cci.user_id, cci.challenge_id, p.name, p.photo_url
)
UPDATE challenge_progress cp
SET 
    check_ins_count = correct_progress.correct_check_ins_count,
    total_check_ins = correct_progress.correct_check_ins_count,
    points = correct_progress.total_points,
    last_check_in = correct_progress.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress.correct_check_ins_count * 100.0) / 
        GREATEST(1, DATE_PART('day', c.end_date - c.start_date)::int + 1)),
    updated_at = NOW(),
    user_name = correct_progress.user_name,
    user_photo_url = correct_progress.user_photo_url
FROM correct_progress
JOIN challenges c ON c.id = correct_progress.challenge_id
WHERE cp.user_id = correct_progress.user_id 
AND cp.challenge_id = correct_progress.challenge_id;

-- ========================================
-- PASSO 4: RECALCULAR RANKINGS
-- ========================================
WITH user_total_workouts AS (
    SELECT 
        user_id,
        COUNT(*) as total_workouts_ever
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
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id AND cp.user_id = ru.user_id;

-- ========================================
-- PASSO 5: ATUALIZAR FUNÇÃO PARA PREVENIR FUTURAS DUPLICAÇÕES
-- ========================================
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
    WHERE id = workout.challenge_id
    FOR UPDATE;

    IF NOT FOUND THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Desafio não encontrado',
            processed_at = NOW()
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Desafio não encontrado: ' || workout.challenge_id, 'error', NOW());
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

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Usuário não participa deste desafio', 'error', NOW());
        RETURN false;
    END IF;

    -- Verificar duração mínima (45 minutos)
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = NOW()
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Duração mínima não atingida: ' || workout.duration_minutes || 'min', 'skipped', NOW());
        RETURN false;
    END IF;

    -- VERIFICAÇÃO CRÍTICA: Apenas 1 check-in por dia
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
        DATE_TRUNC('day', workout.date), -- Usar apenas a data, sem hora
        CAST(workout.id as uuid),
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
            COUNT(*) as total_workouts_ever
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
    BEGIN
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, SQLERRM, 'error', NOW());
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- PASSO 6: VERIFICAR RESULTADO FINAL
-- ========================================
SELECT 
    'RESULTADO FINAL' as status,
    p.name,
    cp.challenge_id,
    cp.points,
    cp.check_ins_count,
    cp.total_check_ins,
    cp.position,
    (SELECT COUNT(*) FROM workout_records wr WHERE wr.user_id = p.id) as total_treinos,
    (SELECT COUNT(DISTINCT DATE(cci.check_in_date)) FROM challenge_check_ins cci WHERE cci.user_id = p.id AND cci.challenge_id = cp.challenge_id) as check_ins_unicos
FROM challenge_progress cp
JOIN profiles p ON p.id = cp.user_id
WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
ORDER BY cp.challenge_id, cp.position; 