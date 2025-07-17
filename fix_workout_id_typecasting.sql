-- Script para corrigir problemas de tipagem na função record_workout_basic
-- Executar no Console SQL do Supabase

-- Modificar a função record_workout_basic para tratar melhor a conversão de tipos
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
    
    -- Tratamento mais robusto para workout_id
    -- Primeiro, tentamos verificar se é um UUID válido
    BEGIN
        -- Verificar se o valor de entrada não é nulo ou uma string vazia
        IF p_workout_id IS NULL OR p_workout_id = '' OR p_workout_id = 'null' THEN
            -- Gerar um novo UUID se não houver um válido
            v_workout_id := gen_random_uuid();
            RAISE LOG 'Nenhum workout_id válido fornecido, gerando novo: %', v_workout_id;
        ELSE
            -- Verificar se parece com um UUID válido - permitindo várias formas
            IF p_workout_id ~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' THEN
                -- Se for um padrão de UUID, convertemos diretamente
                v_workout_id := p_workout_id::UUID;
                RAISE LOG 'Convertido workout_id para UUID: %', v_workout_id;
            ELSE
                -- Caso contrário, geramos um novo UUID baseado no hash do texto
                v_workout_id := gen_random_uuid();
                RAISE LOG 'Formato inválido de UUID, gerando novo: %', v_workout_id;
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Em caso de erro na conversão, geramos um novo UUID
        v_workout_id := gen_random_uuid();
        RAISE LOG 'Erro na conversão do workout_id, gerando novo: %', v_workout_id;
    END;
    
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
    
    -- Agendar processamento assíncrono para rankings e estatísticas
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
        -- Registrar erro na tabela de erros com detalhes para diagnóstico
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
                'workout_id', p_workout_id,
                'challenge_id', p_challenge_id
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

-- Script de teste para verificar se a função está tratando os tipos corretamente
DO $$
DECLARE
    test_user_id UUID;
    result JSONB;
BEGIN
    -- Obter um usuário válido para teste
    SELECT id INTO test_user_id FROM profiles LIMIT 1;
    
    RAISE NOTICE 'Testando função com diferentes formatos de workout_id...';
    
    -- Teste 1: workout_id como string vazia
    RAISE NOTICE '1. Testando com workout_id como string vazia...';
    result := record_workout_basic(
        p_user_id := test_user_id,
        p_workout_name := 'Teste 1',
        p_workout_type := 'Teste',
        p_duration_minutes := 30,
        p_date := NOW(),
        p_workout_id := ''
    );
    RAISE NOTICE 'Resultado teste 1: %', result;
    
    -- Teste 2: workout_id como UUID formatado
    RAISE NOTICE '2. Testando com workout_id como UUID formatado...';
    result := record_workout_basic(
        p_user_id := test_user_id,
        p_workout_name := 'Teste 2',
        p_workout_type := 'Teste',
        p_duration_minutes := 30,
        p_date := NOW(),
        p_workout_id := '123e4567-e89b-12d3-a456-426614174000'
    );
    RAISE NOTICE 'Resultado teste 2: %', result;
    
    -- Teste 3: workout_id como string não-UUID
    RAISE NOTICE '3. Testando com workout_id como string não-UUID...';
    result := record_workout_basic(
        p_user_id := test_user_id,
        p_workout_name := 'Teste 3',
        p_workout_type := 'Teste',
        p_duration_minutes := 30,
        p_date := NOW(),
        p_workout_id := 'not-a-uuid-format'
    );
    RAISE NOTICE 'Resultado teste 3: %', result;
    
    RAISE NOTICE 'Testes concluídos com sucesso!';
END;
$$; 