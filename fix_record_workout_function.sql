-- Script para corrigir a função de registro de treino - VERSÃO BLINDADA CONTRA DUPLICAÇÃO

-- REMOVER TODAS AS VERSÕES EXISTENTES DA FUNÇÃO
DROP FUNCTION IF EXISTS record_workout_basic(uuid, text, text, integer, timestamp with time zone, uuid, text, text, uuid);
DROP FUNCTION IF EXISTS record_workout_basic(uuid, text, text, integer, timestamp with time zone, uuid, uuid, text, uuid);
DROP FUNCTION IF EXISTS record_workout_basic CASCADE;

-- 1. FUNÇÃO BLINDADA: record_workout_basic (proteção máxima contra duplicação)
CREATE OR REPLACE FUNCTION record_workout_basic(
    p_user_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_challenge_id UUID DEFAULT NULL,
    p_workout_id TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_workout_record_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_id UUID;
    existing_record UUID;
    v_workout_id UUID;
    duplicate_count INTEGER;
BEGIN
    -- Converter p_workout_id de TEXT para UUID (se não for vazio)
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            -- Se não conseguir converter, gerar um novo UUID
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := NULL;
    END IF;

    -- PROTEÇÃO 1: Verificar duplicação EXATA (mesmo treino, mesmo dia, mesma duração)
    SELECT id INTO existing_record
    FROM workout_records
    WHERE user_id = p_user_id
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND duration_minutes = p_duration_minutes
      AND DATE(to_brt(date)) = DATE(to_brt(p_date))
      AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '')
      AND COALESCE(notes, '') = COALESCE(p_notes, '')
    LIMIT 1;

    IF FOUND THEN
        RETURN jsonb_build_object(
            'success', true,
            'workout_id', existing_record,
            'message', 'Treino idêntico já existe - retornando registro existente'
        );
    END IF;

    -- PROTEÇÃO 2: Verificar se já existe treino muito similar no mesmo período (últimos 5 minutos)
    SELECT COUNT(*) INTO duplicate_count
    FROM workout_records
    WHERE user_id = p_user_id
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND duration_minutes = p_duration_minutes
      AND to_brt(date) BETWEEN (to_brt(p_date) - INTERVAL '5 minutes') AND (to_brt(p_date) + INTERVAL '5 minutes')
      AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '');

    IF duplicate_count > 0 THEN
        -- Buscar o registro mais recente similar
        SELECT id INTO existing_record
        FROM workout_records
        WHERE user_id = p_user_id
          AND workout_name = p_workout_name
          AND workout_type = p_workout_type
          AND duration_minutes = p_duration_minutes
          AND to_brt(date) BETWEEN (to_brt(p_date) - INTERVAL '5 minutes') AND (to_brt(p_date) + INTERVAL '5 minutes')
          AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '')
        ORDER BY date DESC
        LIMIT 1;

        RETURN jsonb_build_object(
            'success', true,
            'workout_id', existing_record,
            'message', 'Treino similar registrado recentemente - retornando registro existente'
        );
    END IF;

    -- PROTEÇÃO 3: Verificar se p_workout_record_id já existe (update vs insert)
    IF p_workout_record_id IS NOT NULL THEN
        SELECT id INTO existing_record
        FROM workout_records
        WHERE id = p_workout_record_id;
        
        IF FOUND THEN
            -- Atualizar registro existente ao invés de criar novo
            UPDATE workout_records
            SET workout_name = p_workout_name,
                workout_type = p_workout_type,
                duration_minutes = p_duration_minutes,
                date = to_brt(p_date),
                challenge_id = p_challenge_id,
                notes = p_notes,
                workout_id = v_workout_id
            WHERE id = p_workout_record_id;
            
            v_id := p_workout_record_id;
            
            -- Processar para ranking
            BEGIN
                PERFORM process_workout_for_ranking_fixed(v_id);
            EXCEPTION WHEN OTHERS THEN
                INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
                VALUES (p_user_id, p_challenge_id, v_id, SQLERRM, 'ranking_fail', to_brt(NOW()));
            END;
            
            RETURN jsonb_build_object(
                'success', true,
                'workout_id', v_id,
                'message', 'Treino atualizado com sucesso'
            );
        END IF;
    END IF;

    -- INSERIR NOVO REGISTRO (apenas se passou por todas as proteções)
    INSERT INTO workout_records (
        id,
        user_id,
        workout_id,
        workout_name,
        workout_type,
        date,
        duration_minutes,
        challenge_id,
        notes
    ) VALUES (
        COALESCE(p_workout_record_id, gen_random_uuid()),
        p_user_id,
        v_workout_id,
        p_workout_name,
        p_workout_type,
        to_brt(p_date),
        p_duration_minutes,
        p_challenge_id,
        p_notes
    ) RETURNING id INTO v_id;

    -- USAR A FUNÇÃO CORRIGIDA (como estava funcionando antes)
    BEGIN
        PERFORM process_workout_for_ranking_fixed(v_id);
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (p_user_id, p_challenge_id, v_id, SQLERRM, 'ranking_fail', to_brt(NOW()));
    END;

    RETURN jsonb_build_object(
        'success', true,
        'workout_id', v_id,
        'message', 'Treino registrado com sucesso'
    );

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'error', SQLERRM,
        'code', SQLSTATE
    );
END;
$$ LANGUAGE plpgsql;

-- Verificar se a função foi criada corretamente
SELECT 
    'record_workout_basic' as function_name,
    EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic' AND prokind = 'f') as exists,
    'Função BLINDADA contra duplicação criada' as status;

-- Verificar quantas versões da função existem
SELECT 
    proname as function_name,
    pg_get_function_identity_arguments(oid) as arguments,
    'Verificação de versões' as status
FROM pg_proc 
WHERE proname = 'record_workout_basic'; 