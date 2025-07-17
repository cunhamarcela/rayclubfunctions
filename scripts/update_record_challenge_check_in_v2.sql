-- Script para modificar a função record_challenge_check_in_v2 para garantir processamento correto

-- 1. Extrair o código atual para referência
SELECT prosrc FROM pg_proc WHERE proname = 'record_challenge_check_in_v2' LIMIT 1;

-- 2. Atualizar a função record_challenge_check_in_v2 com lógica melhorada
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
    workout_record_id UUID;
    active_challenge UUID := _challenge_id;
    result JSONB;
BEGIN
    -- IMPORTANTE: Se não foi fornecido um challenge_id, tentar encontrar um desafio ativo
    IF active_challenge IS NULL THEN
        -- Encontrar um desafio ativo para este usuário na data do treino
        SELECT 
            c.id INTO active_challenge
        FROM 
            challenges c
        JOIN 
            challenge_participants cp ON c.id = cp.challenge_id AND cp.user_id = _user_id
        WHERE 
            c.status = 'active' AND
            (_date BETWEEN c.start_date AND COALESCE(c.end_date, NOW() + INTERVAL '1 year'))
        LIMIT 1;

        -- Se encontrou um desafio ativo, usar para o registro
        -- Se não encontrou, continuará com NULL (sem desafio)
    END IF;

    -- 1. Registrar o treino básico (sempre registra, independente da duração)
    INSERT INTO workout_records(
        id,
        workout_id,
        workout_name,
        workout_type,
        user_id,
        challenge_id,
        date,
        duration_minutes,
        created_at
    ) VALUES (
        gen_random_uuid(),
        _workout_id,
        _workout_name,
        _workout_type,
        _user_id,
        active_challenge,  -- Pode ser o fornecido, um encontrado automaticamente, ou NULL
        _date,
        _duration_minutes,
        NOW()
    ) RETURNING id INTO workout_record_id;

    -- 2. Adicionar à fila de processamento para dashboard e ranking
    INSERT INTO workout_processing_queue(
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard,
        created_at
    ) VALUES (
        workout_record_id,
        _user_id,
        active_challenge,
        FALSE,
        FALSE,
        NOW()
    );

    -- 3. Processar imediatamente para o dashboard (sem verificação de duração)
    PERFORM process_workout_for_dashboard(workout_record_id);

    -- 4. Construir resposta de sucesso
    result := jsonb_build_object(
        'success', true,
        'message', 'Treino registrado com sucesso',
        'workout_id', workout_record_id
    );
    
    -- Adicionar informação sobre desafio
    IF active_challenge IS NOT NULL THEN
        result := result || jsonb_build_object(
            'challenge_id', active_challenge,
            'scheduled_for_ranking', true
        );
    ELSE
        result := result || jsonb_build_object(
            'scheduled_for_ranking', false,
            'reason', 'Nenhum desafio ativo encontrado'
        );
    END IF;

    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro e retornar resposta de erro
        BEGIN
            INSERT INTO check_in_error_logs(
                user_id,
                challenge_id,
                workout_id,
                error_message,
                status,
                created_at
            ) VALUES (
                _user_id,
                active_challenge,
                workout_record_id,
                'Erro ao registrar treino: ' || SQLERRM,
                'error',
                NOW()
            );
        EXCEPTION WHEN OTHERS THEN
            -- Falha silenciosa no log
            NULL;
        END;
        
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$ LANGUAGE plpgsql; 