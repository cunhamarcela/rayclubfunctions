-- Script para corrigir consistência do ranking dos desafios
-- Mantém consistência com as funções existentes no código

-- PASSO 1: Verificar se a coluna position existe
DO $$
DECLARE
  column_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'challenge_progress' AND column_name = 'position'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        ALTER TABLE challenge_progress ADD COLUMN position INTEGER DEFAULT 1;
        RAISE NOTICE '✅ Coluna position adicionada à tabela challenge_progress';
    ELSE
        RAISE NOTICE '✅ Coluna position já existe na tabela challenge_progress';
    END IF;
END $$;

-- PASSO 2: Corrigir a função process_workout_for_ranking_fixed
-- Remover função existente e recriar com lógica correta
DROP FUNCTION IF EXISTS process_workout_for_ranking_fixed(uuid);

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
        SET processed_for_ranking = true, processed_at = to_brt(NOW())
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
            processed_at = to_brt(NOW())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Desafio não encontrado: ' || workout.challenge_id, 'error', to_brt(NOW()));
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
            processed_at = to_brt(NOW())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Usuário não participa deste desafio', 'error', to_brt(NOW()));
        RETURN false;
    END IF;

    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = to_brt(NOW())
        WHERE workout_id = _workout_record_id;

        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 'Duração mínima não atingida: ' || workout.duration_minutes || 'min', 'skipped', to_brt(NOW()));
        RETURN false;
    END IF;

    -- LÓGICA CORRETA: Verificar se JÁ EXISTE CHECK-IN PARA ESTE DIA
    workout_date_only := DATE(to_brt(workout.date));
    
    SELECT EXISTS (
        SELECT 1 FROM challenge_check_ins
        WHERE user_id = workout.user_id
          AND challenge_id = workout.challenge_id
          AND DATE(to_brt(check_in_date)) = workout_date_only
    ) INTO already_has_checkin_today;

    IF already_has_checkin_today THEN
        -- JÁ EXISTE CHECK-IN PARA HOJE - NÃO CRIAR OUTRO
        UPDATE workout_processing_queue
        SET processed_for_ranking = true,
            processing_error = 'Check-in já existe para esta data',
            processed_at = to_brt(NOW())
        WHERE workout_id = _workout_record_id;
        
        -- Log informativo (não é erro, é comportamento esperado)
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, 
                'Check-in já existe para ' || workout_date_only || ' - treino adicional ignorado', 
                'already_checked_in', to_brt(NOW()))
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
        DATE_TRUNC('day', to_brt(workout.date)), -- Usar apenas a data, sem hora
        CAST(workout.id as uuid),
        points_to_add,
        workout.workout_name,
        workout.workout_type,
        workout.duration_minutes,
        user_name,
        user_photo_url,
        to_brt(NOW())
    ) RETURNING id INTO check_in_id;

    -- CONTAR CHECK-INS ÚNICOS POR DIA (APÓS INSERÇÃO)
    SELECT COUNT(DISTINCT DATE(to_brt(check_in_date))) INTO current_check_ins_count
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
        to_brt(NOW()),
        to_brt(NOW()),
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
        updated_at = to_brt(NOW()),
        user_name = excluded.user_name,
        user_photo_url = excluded.user_photo_url;

    -- Marcar como processado
    UPDATE workout_processing_queue
    SET processed_for_ranking = true, processed_at = to_brt(NOW())
    WHERE workout_id = _workout_record_id;

    -- ATUALIZAR RANKINGS COM CRITÉRIO CORRETO DE DESEMPATE
    -- Usar TOTAL de treinos do usuário (todos os tempos) como tie-breaker
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
    BEGIN
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (workout.user_id, workout.challenge_id, _workout_record_id, SQLERRM, 'error', to_brt(NOW()));
    EXCEPTION WHEN OTHERS THEN 
        NULL;
    END;
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- PASSO 3: Função para recalcular todos os rankings
CREATE OR REPLACE FUNCTION recalculate_all_challenge_rankings()
RETURNS TEXT AS $$
DECLARE
    challenge_rec RECORD;
    rankings_updated INTEGER := 0;
BEGIN
    -- Recalcular ranking para cada desafio ativo
    FOR challenge_rec IN 
        SELECT DISTINCT challenge_id 
        FROM challenge_progress 
        WHERE challenge_id IS NOT NULL
    LOOP
        -- Recalcular ranking para este desafio
        WITH user_total_workouts AS (
            SELECT 
                user_id,
                COUNT(*) as total_workouts_ever -- TOTAL de treinos do usuário
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
            WHERE cp.challenge_id = challenge_rec.challenge_id
        )
        UPDATE challenge_progress cp
        SET position = ru.new_position,
            updated_at = to_brt(NOW())
        FROM ranked_users ru
        WHERE cp.challenge_id = ru.challenge_id 
          AND cp.user_id = ru.user_id
          AND cp.challenge_id = challenge_rec.challenge_id;
        
        rankings_updated := rankings_updated + 1;
    END LOOP;

    RETURN FORMAT('Rankings recalculados para %s desafios com critério correto de desempate', rankings_updated);
END;
$$ LANGUAGE plpgsql;

-- PASSO 4: Função para corrigir dados existentes
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
                PARTITION BY user_id, challenge_id, DATE(to_brt(check_in_date)) 
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
            COUNT(DISTINCT DATE(to_brt(cci.check_in_date))) as unique_days,
            COUNT(DISTINCT DATE(to_brt(cci.check_in_date))) * 10 as total_points,
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
        updated_at = to_brt(NOW())
    FROM correct_daily_counts cdc
    JOIN challenges c ON c.id = cdc.challenge_id
    WHERE cp.challenge_id = cdc.challenge_id 
      AND cp.user_id = cdc.user_id;
    
    GET DIAGNOSTICS progress_updated = ROW_COUNT;

    RETURN FORMAT('Correção concluída: %s check-ins duplicados removidos, %s registros de progresso atualizados', 
                  duplicates_removed, progress_updated);
END;
$$ LANGUAGE plpgsql;

-- PASSO 5: Executar correções
SELECT fix_challenge_data_integrity();

-- PASSO 6: Recalcular todos os rankings
SELECT recalculate_all_challenge_rankings();

-- PASSO 7: Criar índice para otimização
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'challenge_progress_position_idx'
    ) THEN
        CREATE INDEX challenge_progress_position_idx 
        ON challenge_progress(challenge_id, position);
        RAISE NOTICE '✅ Índice criado para otimização';
    ELSE
        RAISE NOTICE '✅ Índice já existe';
    END IF;
END $$;

-- PASSO 8: Verificação final
SELECT 
    'Ranking Final Verificado' as status,
    COUNT(*) as total_usuarios,
    COUNT(DISTINCT challenge_id) as total_desafios,
    MIN(position) as menor_posicao,
    MAX(position) as maior_posicao
FROM challenge_progress;

RAISE NOTICE '';
RAISE NOTICE '🎯 ===== RANKING CONSISTENCY FIXED =====';
RAISE NOTICE '✅ Função process_workout_for_ranking_fixed corrigida';
RAISE NOTICE '✅ Lógica: 1 check-in por dia por usuário por desafio';
RAISE NOTICE '✅ Critérios de ranking:';
RAISE NOTICE '   1. Pontos (dias com check-in) - decrescente';
RAISE NOTICE '   2. Total de treinos do usuário - decrescente';
RAISE NOTICE '   3. Data do último check-in - crescente';
RAISE NOTICE '✅ Dados existentes corrigidos';
RAISE NOTICE '✅ Rankings recalculados';
RAISE NOTICE '=====================================';
RAISE NOTICE ''; 