-- Script para corrigir a tabela check_in_error_logs e resolver o problema de processamento

-- 1. Adicionar a coluna workout_id faltante na tabela check_in_error_logs
DO $$
BEGIN
    -- Verificar se a coluna workout_id já existe
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'check_in_error_logs'
        AND column_name = 'workout_id'
    ) THEN
        -- Adicionar a coluna workout_id
        ALTER TABLE check_in_error_logs ADD COLUMN workout_id UUID;
        RAISE NOTICE 'Coluna workout_id adicionada com sucesso à tabela check_in_error_logs';
    ELSE
        RAISE NOTICE 'A coluna workout_id já existe na tabela check_in_error_logs';
    END IF;
END $$;

-- 2. Atualizar a função process_workout_for_ranking para lidar com registros sem desafio
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
    error_info JSONB;
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
        RETURN TRUE; -- Alterado para TRUE, pois não é um erro, apenas não tem desafio
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
    
    -- Obter a meta de pontos do desafio para cálculo de porcentagem
    challenge_target_points := COALESCE(challenge_record.points, 100);
    
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
        BEGIN
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
                SQLERRM,
                'error',
                NOW()
            );
        EXCEPTION WHEN OTHERS THEN
            -- Ignora erros ao registrar o log
            NULL;
        END;
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 3. Corrigir a função process_workout_for_dashboard para lidar com falhas
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
    BEGIN
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
    EXCEPTION WHEN OTHERS THEN
        -- Registramos o erro, mas marcamos como processado para não bloquear
        UPDATE workout_processing_queue 
        SET processed_for_dashboard = TRUE,
            processing_error = 'Erro ao atualizar user_progress: ' || SQLERRM,
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Tratar erros silenciosamente para não bloquear o processamento
        RETURN FALSE;
    END;
    
    -- Marcar como processado
    UPDATE workout_processing_queue 
    SET processed_for_dashboard = TRUE,
        processed_at = NOW() 
    WHERE workout_id = _workout_record_id;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        BEGIN
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
        EXCEPTION WHEN OTHERS THEN
            -- Ignora erros ao registrar o log
            NULL;
        END;
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 4. Tentar processar registros novamente
DO $$
DECLARE
    rec RECORD;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Iniciando processamento de registros pendentes...';
    
    -- Processar todos os registros pendentes
    FOR rec IN SELECT * FROM workout_processing_queue 
               WHERE (NOT processed_for_ranking OR NOT processed_for_dashboard)
               ORDER BY created_at
    LOOP
        BEGIN
            RAISE NOTICE 'Processando registro: %', rec.workout_id;
            
            -- Processar ranking se necessário
            IF NOT rec.processed_for_ranking THEN
                IF process_workout_for_ranking(rec.workout_id) THEN
                    RAISE NOTICE '  ✓ Ranking processado com sucesso';
                ELSE
                    RAISE NOTICE '  ✗ Falha no processamento de ranking';
                END IF;
            END IF;
            
            -- Processar dashboard se necessário
            IF NOT rec.processed_for_dashboard THEN
                IF process_workout_for_dashboard(rec.workout_id) THEN
                    RAISE NOTICE '  ✓ Dashboard processado com sucesso';
                ELSE
                    RAISE NOTICE '  ✗ Falha no processamento de dashboard';
                END IF;
            END IF;
            
            success_count := success_count + 1;
        EXCEPTION WHEN OTHERS THEN
            error_count := error_count + 1;
            RAISE NOTICE '  ✗ Erro geral: %', SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Processamento concluído: % registros processados com sucesso, % com erro', success_count, error_count;
    
    -- Verificar status final
    RAISE NOTICE 'Status final da fila:';
    RAISE NOTICE '  Registros pendentes: %', (SELECT COUNT(*) FROM workout_processing_queue WHERE NOT processed_for_ranking OR NOT processed_for_dashboard);
    RAISE NOTICE '  Registros processados: %', (SELECT COUNT(*) FROM workout_processing_queue WHERE processed_for_ranking AND processed_for_dashboard);
END $$; 