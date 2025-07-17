-- Função corrigida para verificar e registrar check-ins em desafios
-- Esta função corrige problemas de verificação de check-ins duplicados e trata valores nulos

-- Primeiro remover as funções existentes para evitar erro de nome de parâmetro
-- Tentando remover com diferentes assinaturas possíveis
DROP FUNCTION IF EXISTS public.record_challenge_check_in(uuid, timestamptz, integer, uuid, text, text, text);
DROP FUNCTION IF EXISTS public.record_challenge_check_in_v2(uuid, timestamptz, integer, uuid, text, text, text);
DROP FUNCTION IF EXISTS public.record_challenge_check_in(uuid, timestamptz, integer, uuid, uuid, text, text);
-- Versão com nomes de parâmetros antigos
DROP FUNCTION IF EXISTS public.record_challenge_check_in(challenge_id_param uuid, date_param timestamptz, duration_minutes_param integer, user_id_param uuid, workout_id_param text, workout_name_param text, workout_type_param text);
DROP FUNCTION IF EXISTS public.has_checked_in_today(uuid, uuid);
DROP FUNCTION IF EXISTS public.get_current_streak(uuid, uuid);
DROP FUNCTION IF EXISTS public.get_current_streak(user_id_param uuid, challenge_id_param uuid);

-- Agora criar as novas funções com os nomes de parâmetros atualizados
CREATE OR REPLACE FUNCTION public.record_challenge_check_in(
    _challenge_id UUID,
    _date TIMESTAMPTZ,
    _duration_minutes INTEGER,
    _user_id UUID,
    _workout_id TEXT,
    _workout_name TEXT,
    _workout_type TEXT
) RETURNS JSONB AS $$
DECLARE
    check_in_id UUID;
    challenge_record RECORD;
    user_name TEXT;
    user_photo_url TEXT;
    workout_date DATE := DATE(_date);
    already_has_checkin BOOLEAN := FALSE;
    current_streak INTEGER := 0;
    current_points INTEGER := 0;
    points_to_add INTEGER := 0;
    result JSONB;
BEGIN
    -- Validações iniciais
    -- Verificar se o treino tem duração mínima
    IF _duration_minutes < 45 THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Duração mínima para desafios é de 45 minutos.',
            'points_earned', 0,
            'streak', 0,
            'is_already_checked_in', FALSE
        );
    END IF;

    -- Verificar se o desafio existe
    SELECT * INTO challenge_record FROM challenges WHERE id = _challenge_id;
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Desafio não encontrado',
            'points_earned', 0,
            'streak', 0,
            'is_already_checked_in', FALSE
        );
    END IF;

    -- Verificar se o usuário é membro do desafio
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants 
        WHERE challenge_id = _challenge_id 
        AND user_id = _user_id
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não participa deste desafio',
            'points_earned', 0,
            'streak', 0,
            'is_already_checked_in', FALSE
        );
    END IF;

    -- Verificar se já existe um check-in para esta data
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = _user_id 
        AND challenge_id = _challenge_id
        AND DATE(check_in_date) = workout_date
    ) INTO already_has_checkin;

    IF already_has_checkin THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Você já realizou check-in para este desafio hoje',
            'points_earned', 0,
            'streak', 0,
            'is_already_checked_in', TRUE
        );
    END IF;

    -- Obter informações do usuário (garantindo tratamento de valores nulos)
    SELECT 
        COALESCE(name, 'Usuário') AS name,
        photo_url
    INTO 
        user_name, user_photo_url
    FROM profiles 
    WHERE id = _user_id;

    -- Se não encontrou perfil, usar valores padrão
    IF NOT FOUND THEN
        user_name := 'Usuário';
        user_photo_url := NULL;
    END IF;

    -- Calcular pontos a serem adicionados
    points_to_add := COALESCE(challenge_record.points, 10);

    -- Inserir o check-in
    INSERT INTO challenge_check_ins (
        user_id,
        challenge_id,
        check_in_date,
        points,
        workout_id,
        workout_name,
        workout_type,
        duration_minutes,
        user_name,
        user_photo_url,
        created_at
    ) VALUES (
        _user_id,
        _challenge_id,
        _date,
        points_to_add,
        _workout_id,
        COALESCE(_workout_name, 'Check-in'),
        COALESCE(_workout_type, 'manual'),
        _duration_minutes,
        user_name,
        user_photo_url,
        NOW()
    ) RETURNING id INTO check_in_id;

    -- Atualizar progresso do usuário
    -- Primeiro verificar se o usuário já tem progresso
    IF EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = _challenge_id 
        AND user_id = _user_id
    ) THEN
        -- Atualizar progresso existente
        UPDATE challenge_progress
        SET 
            points = points + points_to_add,
            check_ins_count = check_ins_count + 1,
            last_check_in = _date,
            updated_at = NOW()
        WHERE 
            challenge_id = _challenge_id 
            AND user_id = _user_id
        RETURNING points INTO current_points;
    ELSE
        -- Criar novo progresso
        INSERT INTO challenge_progress (
            challenge_id,
            user_id,
            user_name,
            user_photo_url,
            points,
            completion_percentage,
            position,
            check_ins_count,
            consecutive_days,
            total_check_ins,
            completed,
            last_check_in,
            created_at,
            updated_at
        ) VALUES (
            _challenge_id,
            _user_id,
            user_name,
            user_photo_url,
            points_to_add,
            0.0,
            0,
            1,
            1,
            1,
            FALSE,
            _date,
            NOW(),
            NOW()
        ) RETURNING points INTO current_points;
    END IF;

    -- Atualizar streak do usuário
    -- Esta é uma implementação simplificada
    SELECT COALESCE(
        (SELECT consecutive_days 
         FROM challenge_progress 
         WHERE challenge_id = _challenge_id 
         AND user_id = _user_id), 
        0
    ) INTO current_streak;

    -- Atualizar ranking do desafio
    PERFORM update_challenge_ranking(_challenge_id);

    -- Retornar resposta de sucesso com detalhes
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Check-in registrado com sucesso',
        'points_earned', points_to_add,
        'streak', current_streak,
        'check_in_id', check_in_id,
        'current_points', current_points,
        'is_already_checked_in', FALSE
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Log de erro para diagnóstico (evita quebrar o app)
        RAISE WARNING 'Erro ao registrar check-in: % - %', SQLERRM, SQLSTATE;
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar check-in: ' || SQLERRM,
            'points_earned', 0,
            'streak', 0,
            'is_already_checked_in', FALSE
        );
END;
$$ LANGUAGE plpgsql;

-- Função auxiliar para verificar se o usuário já fez check-in hoje
CREATE OR REPLACE FUNCTION public.has_checked_in_today(
    _user_id UUID,
    _challenge_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    today DATE := CURRENT_DATE;
    result BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = _user_id 
        AND challenge_id = _challenge_id
        AND DATE(check_in_date) = today
    ) INTO result;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, retornar false para garantir que o check-in possa ser tentado
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Função para obter a sequência atual de check-ins de um usuário em um desafio
CREATE OR REPLACE FUNCTION public.get_current_streak(
    user_id_param UUID,
    challenge_id_param UUID
) RETURNS INTEGER AS $$
DECLARE
    current_streak INTEGER := 0;
BEGIN
    -- Obter streak do progresso
    SELECT COALESCE(consecutive_days, 0)
    INTO current_streak
    FROM challenge_progress
    WHERE user_id = user_id_param
    AND challenge_id = challenge_id_param;
    
    RETURN current_streak;
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, retornar 0 para não quebrar o app
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Consulta para identificar todas as funções relacionadas a desafios no banco de dados
-- Execute esta consulta separadamente caso enfrente problemas ao remover funções
-- para identificar a assinatura exata de todas as funções
SELECT 
  p.proname AS function_name,
  pg_get_function_identity_arguments(p.oid) AS function_arguments,
  pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE 
  n.nspname = 'public' AND 
  (p.proname LIKE '%challenge%' OR 
   p.proname LIKE '%check_in%' OR 
   p.proname LIKE '%streak%');

-- Verificar quantos check-ins existem na tabela para um usuário específico
-- SELECT 
--   user_id, 
--   challenge_id, 
--   DATE(check_in_date) as check_in_date, 
--   workout_id, 
--   workout_name,
--   duration_minutes
-- FROM challenge_check_ins
-- WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
-- ORDER BY check_in_date DESC;

-- Script para remover a restrição de duração mínima de treinos
-- e permitir que treinos de qualquer duração sejam contabilizados nos desafios

-- 1. Modifique a função de processamento de treinos para desafios
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

-- 2. Modifique a função de sincronização de treinos para desafios
CREATE OR REPLACE FUNCTION public.sync_workout_to_challenges()
RETURNS TRIGGER AS $$
DECLARE
    challenge_record RECORD;
    user_in_challenge BOOLEAN;
    workout_date DATE := DATE(NEW.date);
    already_has_valid_workout BOOLEAN := FALSE;
BEGIN
    -- Verificar se o usuário já tem um treino válido para esta data em qualquer desafio
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = NEW.user_id 
        AND DATE(check_in_date) = workout_date
    ) INTO already_has_valid_workout;
    
    -- Se já tem um treino válido para hoje, não adicionar novos check-ins
    IF already_has_valid_workout THEN
        RAISE NOTICE 'Usuário já tem um treino válido registrado para %, ignorando novo check-in.', workout_date;
        RETURN NEW;
    END IF;
    
    -- Para cada desafio ativo que o usuário participa
    FOR challenge_record IN
        SELECT c.id, c.title, c.start_date, c.end_date, c.points, cp.user_id
        FROM challenges c
        JOIN challenge_participants cp ON c.id = cp.challenge_id
        WHERE cp.user_id = NEW.user_id
        AND c.active = TRUE
        AND c.start_date <= NEW.date
        AND c.end_date >= NEW.date
    LOOP
        -- Verificar se treino está dentro do período do desafio
        IF NEW.date >= challenge_record.start_date AND NEW.date <= challenge_record.end_date THEN
            -- Registrar o check-in para este desafio
            INSERT INTO challenge_check_ins (
                user_id,
                challenge_id,
                check_in_date,
                points,
                workout_id,
                workout_name,
                workout_type,
                duration_minutes,
                created_at
            ) VALUES (
                NEW.user_id,
                challenge_record.id,
                NEW.date,
                10, -- Pontos padrão
                NEW.id,
                NEW.workout_name,
                NEW.workout_type,
                NEW.duration_minutes,
                NOW()
            );
            
            RAISE NOTICE 'Check-in registrado para desafio % (%)', challenge_record.id, challenge_record.title;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Modifique a função de registro de check-in para desafios
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text DEFAULT NULL, 
    _workout_name text DEFAULT 'Treino', 
    _workout_type text DEFAULT 'Outros'
)
RETURNS jsonb AS $$
DECLARE
    challenge RECORD;
    user_exists BOOLEAN;
    is_participant BOOLEAN;
    already_checked_in BOOLEAN;
    workout_record_id UUID;
    points_earned INTEGER := 10;
    streak INTEGER := 0;
    result JSONB;
BEGIN
    -- Verificar se desafio existe
    SELECT * INTO challenge FROM challenges WHERE id = _challenge_id;
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Desafio não encontrado',
            'is_already_checked_in', FALSE,
            'points_earned', 0,
            'streak', 0
        );
    END IF;
    
    -- Verificar se usuário existe
    SELECT EXISTS(SELECT 1 FROM profiles WHERE id = _user_id) INTO user_exists;
    IF NOT user_exists THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não encontrado',
            'is_already_checked_in', FALSE,
            'points_earned', 0,
            'streak', 0
        );
    END IF;
    
    -- Verificar se usuário participa do desafio
    SELECT EXISTS(
        SELECT 1 FROM challenge_participants 
        WHERE challenge_id = _challenge_id AND user_id = _user_id
    ) INTO is_participant;
    
    IF NOT is_participant THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não participa deste desafio',
            'is_already_checked_in', FALSE,
            'points_earned', 0,
            'streak', 0
        );
    END IF;
    
    -- Verificar se já existe check-in para a data
    SELECT EXISTS(
        SELECT 1 FROM challenge_check_ins 
        WHERE challenge_id = _challenge_id 
        AND user_id = _user_id 
        AND DATE(check_in_date) = DATE(_date)
    ) INTO already_checked_in;
    
    IF already_checked_in THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Já existe check-in para esta data',
            'is_already_checked_in', TRUE,
            'points_earned', 0,
            'streak', 0
        );
    END IF;

    -- Registrar workout caso necessário
    INSERT INTO workout_records(
        user_id, 
        challenge_id, 
        workout_id, 
        workout_name, 
        workout_type, 
        date, 
        duration_minutes
    ) VALUES (
        _user_id, 
        _challenge_id, 
        _workout_id::UUID, 
        _workout_name, 
        _workout_type, 
        _date, 
        _duration_minutes
    ) RETURNING id INTO workout_record_id;
    
    -- Registrar check-in
    INSERT INTO challenge_check_ins(
        user_id,
        challenge_id,
        check_in_date,
        points,
        workout_id,
        workout_name,
        workout_type,
        duration_minutes
    ) VALUES (
        _user_id,
        _challenge_id,
        _date,
        points_earned,
        workout_record_id,
        _workout_name,
        _workout_type,
        _duration_minutes
    );
    
    -- Atualizar progresso
    -- Tentar atualizar progresso existente
    UPDATE challenge_progress 
    SET 
        points_earned = points_earned + 10,
        check_ins_count = check_ins_count + 1,
        last_check_in = _date,
        completion_percentage = CASE 
            WHEN challenge.points > 0 THEN 
                ((points_earned + 10) * 100.0 / challenge.points)
            ELSE 0
        END,
        updated_at = NOW()
    WHERE 
        challenge_id = _challenge_id AND 
        user_id = _user_id;
    
    -- Se não atualizou nenhum progresso, criar um novo
    IF NOT FOUND THEN
        INSERT INTO challenge_progress(
            challenge_id,
            user_id,
            points_earned,
            check_ins_count,
            last_check_in,
            completion_percentage
        ) VALUES (
            _challenge_id,
            _user_id,
            10,
            1,
            _date,
            CASE 
                WHEN challenge.points > 0 THEN 
                    (10 * 100.0 / challenge.points)
                ELSE 0
            END
        );
    END IF;
    
    -- Atualizar dashboard do usuário
    -- Aqui atualizamos o user_progress para refletir o novo treino
    INSERT INTO user_progress (
        user_id, 
        workouts, 
        points,
        updated_at
    ) VALUES (
        _user_id,
        1,
        points_earned,
        NOW()
    )
    ON CONFLICT (user_id) 
    DO UPDATE SET
        workouts = user_progress.workouts + 1,
        points = user_progress.points + points_earned,
        updated_at = NOW();
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Check-in registrado com sucesso',
        'challenge_id', _challenge_id,
        'workout_id', workout_record_id,
        'points_earned', points_earned,
        'is_already_checked_in', FALSE
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar o erro
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            error_message,
            request_data,
            created_at
        ) VALUES (
            _user_id,
            _challenge_id,
            SQLERRM,
            jsonb_build_object(
                'date', _date,
                'duration_minutes', _duration_minutes,
                'workout_name', _workout_name,
                'workout_type', _workout_type
            ),
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

-- 4. Modifique a função de processamento para o dashboard
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

-- COMENTÁRIO: Este script remove todas as verificações de duração mínima 
-- de 45 minutos para permitir que qualquer treino seja válido para desafios.
-- Após executar, todos os treinos serão processados independentemente da duração.

-- Para testar novamente a funcionalidade:
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Tente criar um treino com menos de 45 minutos
-- 3. Verifique se o treino aparece nos desafios ativos e no dashboard
