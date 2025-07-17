-- =============================================
-- MIGRAÇÃO DO SISTEMA DE REGISTRO DE TREINOS
-- Split System para maior resiliência e performance
-- =============================================

-- ============================
-- 1. TABELAS DE SUPORTE
-- ============================

-- Tabela de fila de processamento
CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workout_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_workout_queue_processing 
ON workout_processing_queue(processed_for_ranking, processed_for_dashboard);

CREATE INDEX IF NOT EXISTS idx_workout_queue_workout_id
ON workout_processing_queue(workout_id);

-- Se a tabela check_in_error_logs ainda não existir, criar:
CREATE TABLE IF NOT EXISTS check_in_error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    challenge_id UUID,
    workout_id UUID,
    request_data JSONB,
    response_data JSONB,
    error_message TEXT,
    error_detail TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_user
ON check_in_error_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_date
ON check_in_error_logs(created_at);

-- ============================
-- 2. FUNÇÃO DE REGISTRO BÁSICO
-- ============================

CREATE OR REPLACE FUNCTION record_workout_basic(
    _user_id UUID,
    _workout_name TEXT,
    _workout_type TEXT,
    _duration_minutes INTEGER,
    _date TIMESTAMP WITH TIME ZONE,
    _challenge_id UUID DEFAULT NULL,
    _workout_id TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    workout_record_id UUID;
    v_workout_id UUID;
BEGIN
    -- Verificar se usuário existe e está ativo (verificação recomendada)
    IF NOT EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = _user_id
        FOR SHARE
    ) THEN
        RAISE EXCEPTION 'Usuário não encontrado ou inativo';
    END IF;
    
    -- Converter workout_id para UUID ou gerar novo UUID
    BEGIN
        v_workout_id := _workout_id::UUID;
    EXCEPTION WHEN OTHERS THEN
        v_workout_id := gen_random_uuid();
    END;
    
    -- REGISTRAR O TREINO (SEMPRE)
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
        10, -- Pontos básicos
        NOW()
    ) RETURNING id INTO workout_record_id;
    
    -- Agendar processamento assíncrono
    INSERT INTO workout_processing_queue(
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard
    ) VALUES (
        workout_record_id,
        _user_id,
        _challenge_id,
        FALSE,
        FALSE
    );
    
    -- Notificar sistema de processamento assíncrono
    PERFORM pg_notify('workout_processing', json_build_object(
        'workout_id', workout_record_id,
        'user_id', _user_id,
        'challenge_id', _challenge_id
    )::text);
    
    result := jsonb_build_object(
        'success', TRUE,
        'message', 'Treino registrado com sucesso',
        'workout_id', workout_record_id,
        'processing_queued', TRUE
    );
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            request_data,
            error_message,
            status,
            created_at
        ) VALUES (
            _user_id,
            _challenge_id,
            NULL,
            jsonb_build_object(
                'workout_name', _workout_name,
                'workout_type', _workout_type,
                'duration_minutes', _duration_minutes,
                'date', _date
            ),
            SQLERRM,
            'error',
            NOW()
        );
        
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar treino: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql;

-- ============================
-- 3. FUNÇÃO DE PROCESSAMENTO DE RANKING
-- ============================

CREATE OR REPLACE FUNCTION process_workout_for_ranking(
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
    challenge_target_points INTEGER;
    check_ins_count INTEGER := 0;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout 
    FROM workout_records 
    WHERE id = _workout_record_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;
    
    -- Verificações básicas
    IF workout.challenge_id IS NULL THEN
        -- Sem desafio associado, marcar como processado e sair
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        RETURN FALSE;
    END IF;
    
    -- VERIFICAÇÕES INICIAIS
    SELECT * INTO challenge_record 
    FROM challenges 
    WHERE id = workout.challenge_id 
    FOR UPDATE SKIP LOCKED; -- Otimização para alta concorrência
    
    IF NOT FOUND THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Desafio não encontrado',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            'Desafio não encontrado: ' || workout.challenge_id,
            'error',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Obter a meta de pontos do desafio para cálculo de porcentagem
    challenge_target_points := challenge_record.points;
    
    -- Verificar se o usuário é membro do desafio
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants 
        WHERE challenge_id = workout.challenge_id 
        AND user_id = workout.user_id
    ) THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Usuário não participa deste desafio',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            'Usuário não participa deste desafio',
            'error',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar como "skipped" na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            'Duração mínima não atingida: ' || workout.duration_minutes || 'min',
            'skipped',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar se já existe check-in para esta data
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = workout.user_id 
        AND challenge_id = workout.challenge_id
        AND DATE(check_in_date) = DATE(workout.date)
    ) INTO already_has_checkin;
    
    IF already_has_checkin THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Check-in já existe para esta data',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar como "duplicate" na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            'Check-in já existe para a data: ' || workout.date,
            'duplicate',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- OBTER INFORMAÇÕES DO USUÁRIO
    SELECT 
        COALESCE(name, 'Usuário') AS name,
        photo_url
    INTO 
        user_name, user_photo_url
    FROM profiles 
    WHERE id = workout.user_id;
    
    -- CRIAR CHECK-IN PARA O DESAFIO
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
        workout.challenge_id,
        workout.user_id,
        workout.date,
        workout.workout_id,
        points_to_add,
        NOW()
    ) RETURNING id INTO check_in_id;
    
    -- ATUALIZAR PROGRESSO DO DESAFIO
    SELECT COUNT(*) INTO check_ins_count
    FROM challenge_check_ins
    WHERE challenge_id = workout.challenge_id
    AND user_id = workout.user_id;
    
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
        workout.challenge_id,
        workout.user_id,
        points_to_add,
        1,
        workout.date,
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
        last_check_in = workout.date,
        completion_percentage = ((challenge_progress.points_earned + points_to_add)::FLOAT / challenge_target_points::FLOAT) * 100.0,
        updated_at = NOW(),
        user_name = EXCLUDED.user_name,
        user_photo = EXCLUDED.user_photo;
    
    -- Marcar como processado
    UPDATE workout_processing_queue 
    SET processed_for_ranking = TRUE,
        processed_at = NOW() 
    WHERE workout_id = _workout_record_id;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            error_detail,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            SQLERRM,
            SQLSTATE || ' | ' || pg_exception_context(),
            'error',
            NOW()
        );
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================
-- 4. FUNÇÃO DE PROCESSAMENTO DE DASHBOARD
-- ============================

CREATE OR REPLACE FUNCTION process_workout_for_dashboard(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    workout RECORD;
    points_to_add INTEGER := 10;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout 
    FROM workout_records 
    WHERE id = _workout_record_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;
    
    -- ATUALIZAR PROGRESSO GERAL DO USUÁRIO (reutilizando código existente)
    INSERT INTO user_progress(
        user_id,
        challenge_points,
        challenges_joined_count,
        challenges_completed_count,
        updated_at
    ) VALUES (
        workout.user_id,
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
    
    -- Marcar como processado
    UPDATE workout_processing_queue 
    SET processed_for_dashboard = TRUE,
        processed_at = NOW() 
    WHERE workout_id = _workout_record_id;
    
    -- Emitir notificação para atualizar UI
    PERFORM pg_notify('dashboard_updates', json_build_object(
        'user_id', workout.user_id,
        'action', 'workout_processed',
        'workout_id', workout.id,
        'points', points_to_add
    )::text);
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            'Erro ao processar dashboard: ' || SQLERRM,
            'error',
            NOW()
        );
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================
-- 5. FUNÇÃO WRAPPER PARA COMPATIBILIDADE
-- ============================

-- Fazer backup da função original primeiro
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2_backup(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text
)
RETURNS jsonb AS $$
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

-- Criar nova função wrapper
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text
)
RETURNS jsonb AS $$
DECLARE
    result JSONB;
    workout_record_id UUID;
BEGIN
    -- Chamar função de registro básico
    result := record_workout_basic(
        _user_id,
        _workout_name,
        _workout_type,
        _duration_minutes,
        _date,
        _challenge_id,
        _workout_id
    );
    
    -- Se registrou com sucesso, processa imediatamente para compatibilidade
    IF (result->>'success')::BOOLEAN THEN
        workout_record_id := (result->>'workout_id')::UUID;
        
        -- Processar para ranking e dashboard de forma síncrona
        -- para manter a compatibilidade com o comportamento atual
        PERFORM process_workout_for_ranking(workout_record_id);
        PERFORM process_workout_for_dashboard(workout_record_id);
        
        -- Atualizar resultado para refletir processamento completo
        result := jsonb_build_object(
            'success', TRUE,
            'message', 'Check-in registrado com sucesso',
            'challenge_id', _challenge_id,
            'workout_id', _workout_id,
            'points_earned', 10,
            'is_already_checked_in', FALSE
        );
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            request_data,
            error_message,
            status,
            created_at
        ) VALUES (
            _user_id,
            _challenge_id,
            NULL,
            jsonb_build_object(
                'workout_name', _workout_name,
                'workout_type', _workout_type,
                'duration_minutes', _duration_minutes,
                'date', _date
            ),
            'Erro wrapper: ' || SQLERRM,
            'error',
            NOW()
        );
        
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar check-in: ' || SQLERRM,
            'is_already_checked_in', FALSE,
            'points_earned', 0,
            'streak', 0
        );
END;
$$ LANGUAGE plpgsql;

-- ============================
-- 6. FUNÇÃO DE DIAGNÓSTICO E RECUPERAÇÃO
-- ============================

CREATE OR REPLACE FUNCTION diagnose_and_recover_workout_records(
    days_back INTEGER DEFAULT 7
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    missing_count INTEGER := 0;
    recovered_count INTEGER := 0;
    failed_count INTEGER := 0;
    error_records RECORD;
    workout_id UUID;
BEGIN
    -- 1. Identificar treinos que falharam no processamento de ranking
    FOR error_records IN 
        SELECT 
            q.workout_id, 
            q.user_id, 
            q.challenge_id,
            q.processing_error,
            COALESCE(w.date, NOW()) as workout_date,
            COALESCE(w.workout_name, 'Unknown') as workout_name
        FROM workout_processing_queue q
        LEFT JOIN workout_records w ON q.workout_id = w.id
        WHERE 
            (q.processed_for_ranking = FALSE OR q.processed_for_dashboard = FALSE)
            AND q.created_at > NOW() - (days_back || ' days')::INTERVAL
    LOOP
        -- 2. Tentar reprocessar cada registro
        BEGIN
            IF NOT error_records.processed_for_ranking THEN
                PERFORM process_workout_for_ranking(error_records.workout_id);
            END IF;
            
            IF NOT error_records.processed_for_dashboard THEN
                PERFORM process_workout_for_dashboard(error_records.workout_id);
            END IF;
            
            recovered_count := recovered_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                failed_count := failed_count + 1;
                
                -- Registrar tentativa de recuperação falha
                INSERT INTO check_in_error_logs(
                    user_id,
                    challenge_id,
                    workout_id,
                    error_message,
                    status,
                    created_at
                ) VALUES (
                    error_records.user_id,
                    error_records.challenge_id,
                    error_records.workout_id,
                    'Falha na recuperação automática: ' || SQLERRM,
                    'recovery_failed',
                    NOW()
                );
        END;
    END LOOP;
    
    -- 3. Verificar treinos registrados mas sem entrada na fila de processamento
    FOR workout_id IN 
        SELECT w.id 
        FROM workout_records w
        LEFT JOIN workout_processing_queue q ON w.id = q.workout_id
        WHERE 
            q.workout_id IS NULL
            AND w.created_at > NOW() - (days_back || ' days')::INTERVAL
    LOOP
        missing_count := missing_count + 1;
        
        -- Criar entrada na fila de processamento
        INSERT INTO workout_processing_queue(
            workout_id,
            user_id,
            challenge_id,
            processed_for_ranking,
            processed_for_dashboard
        )
        SELECT 
            id, 
            user_id, 
            challenge_id,
            FALSE,
            FALSE
        FROM workout_records 
        WHERE id = workout_id;
    END LOOP;
    
    -- 4. Preparar relatório
    result := jsonb_build_object(
        'period', days_back || ' days',
        'recovered_count', recovered_count,
        'missing_count', missing_count,
        'failed_count', failed_count,
        'timestamp', NOW()
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================
-- 7. FUNÇÃO DE PROCESSAMENTO EM LOTES (opcional)
-- ============================

CREATE OR REPLACE FUNCTION process_pending_workouts(batch_size INTEGER DEFAULT 50)
RETURNS INTEGER AS $$
DECLARE
    processed_count INTEGER := 0;
    workout_id UUID;
BEGIN
    -- Processar ranking
    FOR workout_id IN 
        SELECT workout_id FROM workout_processing_queue 
        WHERE processed_for_ranking = FALSE 
        ORDER BY created_at 
        LIMIT batch_size
        FOR UPDATE SKIP LOCKED
    LOOP
        PERFORM process_workout_for_ranking(workout_id);
        processed_count := processed_count + 1;
    END LOOP;
    
    -- Processar dashboard
    FOR workout_id IN 
        SELECT workout_id FROM workout_processing_queue 
        WHERE processed_for_dashboard = FALSE 
        ORDER BY created_at 
        LIMIT batch_size
        FOR UPDATE SKIP LOCKED
    LOOP
        PERFORM process_workout_for_dashboard(workout_id);
    END LOOP;
    
    RETURN processed_count;
END;
$$ LANGUAGE plpgsql;

-- ============================
-- 8. CONFIGURAÇÃO DE AGENDAMENTO (opcional)
-- ============================

-- Tabela para controle de tarefas periódicas
CREATE TABLE IF NOT EXISTS system_scheduled_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_name TEXT NOT NULL,
    last_run TIMESTAMP WITH TIME ZONE,
    next_run TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'pending',
    result JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Função para executar tarefas periódicas
CREATE OR REPLACE FUNCTION run_scheduled_maintenance()
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    recovery_result JSONB;
    task_id UUID;
BEGIN
    -- Inserir registro de tarefa
    INSERT INTO system_scheduled_tasks(
        task_name,
        next_run,
        status
    ) VALUES (
        'workout_maintenance',
        NOW() + INTERVAL '1 day',
        'running'
    ) RETURNING id INTO task_id;
    
    -- Executar diagnóstico e recuperação
    recovery_result := diagnose_and_recover_workout_records(7);
    
    -- Limpar processamento antigo
    DELETE FROM workout_processing_queue
    WHERE 
        processed_for_ranking = TRUE 
        AND processed_for_dashboard = TRUE
        AND processed_at < NOW() - INTERVAL '30 days';
    
    -- Atualizar status da tarefa
    UPDATE system_scheduled_tasks SET
        status = 'completed',
        last_run = NOW(),
        result = recovery_result
    WHERE id = task_id;
    
    result := jsonb_build_object(
        'task_id', task_id,
        'recovery', recovery_result,
        'status', 'completed'
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql; 