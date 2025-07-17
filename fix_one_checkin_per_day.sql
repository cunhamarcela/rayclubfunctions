-- CORREÇÃO CRÍTICA: APENAS 1 CHECK-IN POR DIA POR USUÁRIO
-- Independentemente de quantos treinos válidos (45+ min) foram feitos

-- ========================================
-- PASSO 1: VERIFICAR SITUAÇÃO ATUAL
-- ========================================

-- Ver quantos check-ins por dia existem (problema atual)
SELECT 
    user_id,
    challenge_id,
    DATE(check_in_date) as data,
    COUNT(*) as check_ins_no_dia,
    STRING_AGG(workout_name, ', ') as treinos
FROM challenge_check_ins
GROUP BY user_id, challenge_id, DATE(check_in_date)
HAVING COUNT(*) > 1
ORDER BY check_ins_no_dia DESC
LIMIT 10;

-- ========================================
-- PASSO 2: IMPLEMENTAR LÓGICA CORRETA
-- ========================================

-- FUNÇÃO CORRIGIDA: process_workout_for_ranking_one_per_day
CREATE OR REPLACE FUNCTION process_workout_for_ranking_one_per_day(
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

    RETURN true;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
    VALUES (workout.user_id, workout.challenge_id, _workout_record_id, SQLERRM, 'error', NOW())
    ON CONFLICT DO NOTHING;
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- PASSO 3: LIMPAR DADOS EXISTENTES
-- ========================================

-- Remover check-ins duplicados por dia (manter apenas 1 por dia)
WITH daily_checkins AS (
    SELECT 
        id,
        user_id,
        challenge_id,
        DATE(check_in_date) as check_date,
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

-- ========================================
-- PASSO 4: RECALCULAR TUDO CORRETAMENTE
-- ========================================

-- Recalcular challenge_progress baseado em DIAS únicos
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

-- ========================================
-- PASSO 5: VERIFICAR RESULTADO
-- ========================================

-- Verificar se ainda há múltiplos check-ins por dia
SELECT 
    'Check-ins múltiplos por dia' as problema,
    COUNT(*) as quantidade
FROM (
    SELECT user_id, challenge_id, DATE(check_in_date)
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date)
    HAVING COUNT(*) > 1
) duplicates;

-- Ver estatísticas corretas
SELECT 
    cp.user_name,
    cp.check_ins_count as dias_com_checkin,
    COUNT(cci.id) as total_checkins_registrados,
    COUNT(DISTINCT DATE(cci.check_in_date)) as dias_unicos_verificacao
FROM challenge_progress cp
JOIN challenge_check_ins cci ON cp.challenge_id = cci.challenge_id AND cp.user_id = cci.user_id
GROUP BY cp.challenge_id, cp.user_id, cp.user_name, cp.check_ins_count
HAVING COUNT(cci.id) != COUNT(DISTINCT DATE(cci.check_in_date))
ORDER BY total_checkins_registrados DESC
LIMIT 10;

-- SCRIPT FINAL: GARANTIR APENAS 1 CHECK-IN POR USUÁRIO POR DIA
-- Remove todas as duplicatas baseado no user_id (não no name)

-- 1. DELETAR DUPLICATAS BASEADO NO USER_ID
WITH checkins_to_keep AS (
    SELECT 
        cci.id,
        ROW_NUMBER() OVER (
            PARTITION BY cci.user_id, DATE(cci.check_in_date) 
            ORDER BY cci.created_at ASC
        ) as rn
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
DELETE FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND id NOT IN (
    SELECT id FROM checkins_to_keep WHERE rn = 1
);

-- 2. RECALCULAR PROGRESSO
WITH correct_progress AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date)) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date)) * 10 as total_points,
        MAX(cci.check_in_date) as last_check_in_date
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    GROUP BY cci.user_id, cci.challenge_id
)
UPDATE challenge_progress cp
SET 
    check_ins_count = correct_progress.correct_check_ins_count,
    total_check_ins = correct_progress.correct_check_ins_count,
    points = correct_progress.total_points,
    last_check_in = correct_progress.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress.correct_check_ins_count * 100.0) / 20),
    updated_at = NOW()
FROM correct_progress
WHERE cp.user_id = correct_progress.user_id 
AND cp.challenge_id = correct_progress.challenge_id;

-- 3. RECALCULAR RANKING
WITH ranked_users AS (
    SELECT
        cp.user_id,
        cp.challenge_id,
        DENSE_RANK() OVER (
            ORDER BY cp.points DESC, cp.last_check_in ASC NULLS LAST
        ) AS new_position
    FROM challenge_progress cp
    WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id 
AND cp.user_id = ru.user_id;

-- 4. VERIFICAR RESULTADO
SELECT 
    'VERIFICAÇÃO FINAL' as status,
    cci.user_id,
    COALESCE(p.name, 'Usuário') as nome,
    DATE(cci.check_in_date) as data,
    COUNT(*) as quantidade_checkins
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY cci.user_id, p.name, DATE(cci.check_in_date)
ORDER BY cci.user_id, DATE(cci.check_in_date);

-- 5. RESULTADO FINAL DO RANKING
SELECT 
    'RANKING FINAL' as status,
    cp.position,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.position; 