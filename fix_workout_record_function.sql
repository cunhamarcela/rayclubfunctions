-- Script para corrigir problemas de tipagem e permissões no sistema de treinos
-- Executar no Console SQL do Supabase

-- 1. Corrigir a função record_workout_basic para lidar corretamente com tipos UUID
CREATE OR REPLACE FUNCTION record_workout_basic(
    p_user_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_challenge_id UUID DEFAULT NULL,
    p_workout_id TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT '',
    p_workout_record_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    workout_record_id UUID;
    v_workout_id UUID;
BEGIN
    -- Log para diagnóstico
    RAISE LOG 'record_workout_basic: Iniciando com user_id=%, challenge_id=%, workout_id=%', 
        p_user_id, p_challenge_id, p_workout_id;

    -- Verificar se usuário existe e está ativo
    IF NOT EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = p_user_id
        FOR SHARE
    ) THEN
        RAISE EXCEPTION 'Usuário não encontrado ou inativo';
    END IF;
    
    -- Converter workout_id para UUID com tratamento adequado
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            -- Tentar converter para UUID explicitamente
            v_workout_id := p_workout_id::UUID;
            RAISE LOG 'Conversão de workout_id bem-sucedida: %', v_workout_id;
        EXCEPTION WHEN OTHERS THEN
            -- Em caso de erro, gerar novo UUID e registrar
            RAISE LOG 'Erro ao converter workout_id: %. Gerando novo.', SQLERRM;
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        -- Se não fornecido, gerar novo UUID
        v_workout_id := gen_random_uuid();
    END IF;
    
    -- Usar ID existente ou criar novo
    IF p_workout_record_id IS NOT NULL THEN
        workout_record_id := p_workout_record_id;
        
        -- Atualizar registro existente
        UPDATE workout_records SET
            challenge_id = p_challenge_id,
            workout_id = v_workout_id,
            workout_name = p_workout_name,
            workout_type = p_workout_type,
            date = p_date,
            duration_minutes = p_duration_minutes,
            notes = p_notes,
            updated_at = NOW()
        WHERE id = workout_record_id;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Registro de treino não encontrado para atualização: %', workout_record_id;
        END IF;
    ELSE
        -- REGISTRAR NOVO TREINO
        INSERT INTO workout_records(
            user_id,
            challenge_id,
            workout_id,
            workout_name,
            workout_type,
            date,
            duration_minutes,
            notes,
            points,
            created_at
        ) VALUES (
            p_user_id,
            p_challenge_id,
            v_workout_id,
            p_workout_name,
            p_workout_type,
            p_date,
            p_duration_minutes,
            p_notes,
            10, -- Pontos básicos
            NOW()
        ) RETURNING id INTO workout_record_id;
    END IF;
    
    -- Agendar processamento assíncrono
    INSERT INTO workout_processing_queue(
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard
    ) VALUES (
        workout_record_id,
        p_user_id,
        p_challenge_id,
        FALSE,
        FALSE
    ) ON CONFLICT (workout_id) DO UPDATE SET
        processed_for_ranking = FALSE,
        processed_for_dashboard = FALSE,
        processing_error = NULL,
        processed_at = NULL,
        updated_at = NOW();
    
    -- Notificar sistema de processamento assíncrono
    PERFORM pg_notify('workout_processing', json_build_object(
        'workout_id', workout_record_id,
        'user_id', p_user_id,
        'challenge_id', p_challenge_id
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
            stack_trace,
            status,
            created_at
        ) VALUES (
            p_user_id,
            p_challenge_id,
            p_workout_record_id,
            jsonb_build_object(
                'workout_name', p_workout_name,
                'workout_type', p_workout_type,
                'duration_minutes', p_duration_minutes,
                'date', p_date,
                'workout_id', p_workout_id
            ),
            SQLERRM,
            pg_exception_context(),
            'error',
            NOW()
        );
        
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar treino: ' || SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql;

-- 2. Adicionar política RLS para permitir upload de imagens
-- Verificar se a política já existe
DO $$
BEGIN
    -- Remover política antiga, se existir (para garantir atualização)
    BEGIN
        DROP POLICY IF EXISTS "Allow workout image uploads for authenticated users" ON storage.objects;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Política não existe ou erro ao remover: %', SQLERRM;
    END;
    
    -- Criar política para upload de imagens
    CREATE POLICY "Allow workout image uploads for authenticated users"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'workout-images' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
    
    -- Política alternativa para usar com metadata de 'owner'
    CREATE POLICY "Allow uploads with owner metadata"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'workout-images' AND
        (
            -- Se o metadata.owner estiver definido, verificar
            (metadata->>'owner')::UUID = auth.uid()
            OR
            -- OU se o nome do arquivo incluir o ID do usuário
            auth.uid()::text = (storage.foldername(name))[1]
        )
    );

    RAISE NOTICE 'Políticas de upload adicionadas com sucesso';
END;
$$; 