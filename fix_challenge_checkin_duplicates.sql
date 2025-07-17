-- Script para corrigir problemas de duplicação de check-ins e contabilização incorreta
-- no sistema de desafios

-- 1. FUNÇÃO CORRIGIDA: process_workout_for_ranking_fixed
CREATE OR REPLACE FUNCTION process_workout_for_ranking_fixed(
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
    challenge_target_days INTEGER;
    current_check_ins_count INTEGER := 0;
    completion NUMERIC := 0;
    existing_workout_id UUID;
BEGIN
    -- Verificar se já foi processado para evitar duplicação
    IF EXISTS (
        SELECT 1 FROM workout_processing_queue 
        WHERE workout_id = _workout_record_id 
        AND processed_for_ranking = true
    ) THEN
        RETURN true; -- Já processado
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
        SET processed_for_ranking = true, processed_at = to_brt(now())
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
            processed_at = to_brt(now())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Desafio não encontrado: ' || workout.challenge_id, 'error', to_brt(now()));
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
            processed_at = to_brt(now())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Usuário não participa deste desafio', 'error', to_brt(now()));
        RETURN false;
    END IF;

    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = to_brt(now())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Duração mínima não atingida: ' || workout.duration_minutes || 'min', 'skipped', to_brt(now()));
        RETURN false;
    END IF;

    -- VERIFICAÇÃO MELHORADA: Check-in duplicado por data E workout_id
    SELECT EXISTS (
        SELECT 1 FROM challenge_check_ins
        WHERE user_id = workout.user_id
          AND challenge_id = workout.challenge_id
          AND (
              -- Mesmo dia
              DATE(to_brt(check_in_date)) = DATE(to_brt(workout.date))
              OR
              -- Mesmo workout_id (evita duplicação por re-processamento)
              workout_id = workout.id
          )
    ) INTO already_has_checkin;

    IF already_has_checkin THEN
        -- Verificar se é o mesmo workout_id para evitar log desnecessário
        SELECT workout_id INTO existing_workout_id
        FROM challenge_check_ins
        WHERE user_id = workout.user_id
          AND challenge_id = workout.challenge_id
          AND workout_id = workout.id
        LIMIT 1;

        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = CASE 
                WHEN existing_workout_id = workout.id THEN 'Check-in já processado para este treino'
                ELSE 'Check-in já existe para esta data'
            END,
            processed_at = to_brt(now())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 
                CASE 
                    WHEN existing_workout_id = workout.id THEN 'Check-in já processado para este treino'
                    ELSE 'Check-in já existe para a data: ' || workout.date
                END, 'duplicate', to_brt(now()));
        RETURN false;
    END IF;

    -- Obter dados do usuário
    SELECT COALESCE(name, 'Usuário'), photo_url
    INTO user_name, user_photo_url
    FROM profiles
    WHERE id = workout.user_id;

    -- Calcular dias do desafio
    challenge_target_days := GREATEST(1, DATE_PART('day', challenge_record.end_date - challenge_record.start_date)::int + 1);

    -- INSERIR CHECK-IN (com proteção adicional)
    BEGIN
        INSERT INTO challenge_check_ins(
            id, challenge_id, user_id, check_in_date, workout_id,
            points, workout_name, workout_type, duration_minutes,
            user_name, user_photo_url, created_at
        ) VALUES (
            gen_random_uuid(),
            workout.challenge_id,
            workout.user_id,
            DATE_TRUNC('day', to_brt(workout.date)),
            workout.id, -- Usar workout.id em vez de cast
            points_to_add,
            workout.workout_name,
            workout.workout_type,
            workout.duration_minutes,
            user_name,
            user_photo_url,
            to_brt(now())
        ) RETURNING id INTO check_in_id;
    EXCEPTION WHEN unique_violation THEN
        -- Se houver violação de unique constraint, considerar como já processado
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Check-in duplicado detectado por constraint',
            processed_at = to_brt(now())
        WHERE workout_id = _workout_record_id;
        RETURN false;
    END;

    -- CONTAR CHECK-INS ATUAIS (APÓS INSERÇÃO)
    SELECT COUNT(*) INTO current_check_ins_count
    FROM challenge_check_ins
    WHERE challenge_id = workout.challenge_id AND user_id = workout.user_id;

    -- Calcular porcentagem de conclusão
    completion := LEAST(100, (current_check_ins_count * 100.0) / challenge_target_days);

    -- ATUALIZAR/INSERIR PROGRESSO (CORRIGIDO)
    INSERT INTO challenge_progress(
        challenge_id, user_id, points, check_ins_count, total_check_ins,
        last_check_in, completion_percentage, created_at, updated_at,
        user_name, user_photo_url
    ) VALUES (
        workout.challenge_id,
        workout.user_id,
        points_to_add,
        current_check_ins_count, -- ✅ USAR CONTAGEM REAL
        current_check_ins_count, -- ✅ USAR CONTAGEM REAL
        workout.date,
        completion,
        to_brt(now()),
        to_brt(now()),
        user_name,
        user_photo_url
    )
    ON CONFLICT (challenge_id, user_id)
    DO UPDATE SET
        points = COALESCE(challenge_progress.points, 0) + excluded.points,
        check_ins_count = current_check_ins_count, -- ✅ USAR CONTAGEM REAL
        total_check_ins = current_check_ins_count,  -- ✅ USAR CONTAGEM REAL
        last_check_in = excluded.last_check_in,
        completion_percentage = completion, -- ✅ USAR VALOR CALCULADO
        updated_at = to_brt(now()),
        user_name = excluded.user_name,
        user_photo_url = excluded.user_photo_url;

    -- Marcar como processado
    UPDATE workout_processing_queue
    SET processed_for_ranking = true, processed_at = to_brt(now())
    WHERE workout_id = _workout_record_id;

    -- ATUALIZAR RANKINGS
    WITH user_workouts AS (
        SELECT user_id, challenge_id, COUNT(*) as workout_count
        FROM workout_records
        WHERE challenge_id = workout.challenge_id
        GROUP BY user_id, challenge_id
    ),
    ranked_users AS (
        SELECT
            cp.user_id,
            cp.challenge_id,
            DENSE_RANK() OVER (
                ORDER BY cp.points DESC, COALESCE(uw.workout_count, 0) DESC, cp.last_check_in ASC NULLS LAST
            ) AS new_position
        FROM challenge_progress cp
        LEFT JOIN user_workouts uw
            ON uw.user_id = cp.user_id AND uw.challenge_id = cp.challenge_id
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
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, SQLERRM, 'error', to_brt(now()));
    EXCEPTION WHEN OTHERS THEN 
        NULL;
    END;
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- 2. FUNÇÃO PARA LIMPAR DUPLICATAS EXISTENTES
CREATE OR REPLACE FUNCTION cleanup_duplicate_checkins()
RETURNS TEXT AS $$
DECLARE
    duplicates_count INTEGER := 0;
    progress_fixed INTEGER := 0;
BEGIN
    -- Remover check-ins duplicados (manter o mais recente)
    WITH duplicates AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY user_id, challenge_id, DATE(check_in_date) 
                ORDER BY created_at DESC
            ) as rn
        FROM challenge_check_ins
    )
    DELETE FROM challenge_check_ins 
    WHERE id IN (
        SELECT id FROM duplicates WHERE rn > 1
    );
    
    GET DIAGNOSTICS duplicates_count = ROW_COUNT;

    -- Recalcular challenge_progress baseado nos check-ins reais
    WITH correct_counts AS (
        SELECT 
            cci.challenge_id,
            cci.user_id,
            COUNT(*) as real_check_ins,
            COUNT(*) * 10 as real_points,
            MAX(cci.check_in_date) as last_check_in,
            COALESCE(p.name, 'Usuário') as user_name,
            p.photo_url as user_photo_url
        FROM challenge_check_ins cci
        LEFT JOIN profiles p ON p.id = cci.user_id
        GROUP BY cci.challenge_id, cci.user_id, p.name, p.photo_url
    )
    UPDATE challenge_progress cp
    SET 
        points = cc.real_points,
        check_ins_count = cc.real_check_ins,
        total_check_ins = cc.real_check_ins,
        last_check_in = cc.last_check_in,
        user_name = cc.user_name,
        user_photo_url = cc.user_photo_url,
        updated_at = to_brt(now())
    FROM correct_counts cc
    WHERE cp.challenge_id = cc.challenge_id 
      AND cp.user_id = cc.user_id;
    
    GET DIAGNOSTICS progress_fixed = ROW_COUNT;

    -- Recalcular completion_percentage
    UPDATE challenge_progress cp
    SET completion_percentage = LEAST(100, 
        (cp.check_ins_count * 100.0) / GREATEST(1, 
            DATE_PART('day', c.end_date - c.start_date)::int + 1
        )
    )
    FROM challenges c
    WHERE cp.challenge_id = c.id;

    RETURN FORMAT('Limpeza concluída: %s check-ins duplicados removidos, %s registros de progresso corrigidos', 
                  duplicates_count, progress_fixed);
END;
$$ LANGUAGE plpgsql;

-- 3. EXECUTAR LIMPEZA
SELECT cleanup_duplicate_checkins();

-- 4. ADICIONAR CONSTRAINT PARA PREVENIR DUPLICATAS FUTURAS (CORRIGIDO)
DO $$
BEGIN
    -- Verificar se existe constraint única para workout_id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_user_challenge_workout_checkin'
    ) THEN
        ALTER TABLE challenge_check_ins 
        ADD CONSTRAINT unique_user_challenge_workout_checkin 
        UNIQUE (user_id, challenge_id, workout_id);
        RAISE NOTICE 'Constraint unique_user_challenge_workout_checkin adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Constraint unique_user_challenge_workout_checkin já existe';
    END IF;
    
    -- Adicionar índice para melhorar performance de consultas por data
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_challenge_checkins_user_challenge_date'
    ) THEN
        CREATE INDEX idx_challenge_checkins_user_challenge_date 
        ON challenge_check_ins (user_id, challenge_id, DATE(check_in_date));
        RAISE NOTICE 'Índice idx_challenge_checkins_user_challenge_date criado com sucesso';
    ELSE
        RAISE NOTICE 'Índice idx_challenge_checkins_user_challenge_date já existe';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao criar constraints/índices: %', SQLERRM;
END $$;

-- 5. VERIFICAÇÃO FINAL
SELECT 
    'Check-ins por usuário/desafio' as tipo,
    challenge_id,
    user_id,
    COUNT(*) as quantidade
FROM challenge_check_ins
GROUP BY challenge_id, user_id
HAVING COUNT(*) > 1
ORDER BY quantidade DESC
LIMIT 10; 