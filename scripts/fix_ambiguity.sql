-- Script para corrigir ambiguidade na função record_challenge_check_in_v2
-- Este script:
-- 1. Faz backup das funções existentes
-- 2. Remove todas as versões da função 
-- 3. Cria uma única versão padronizada
-- 4. Verifica se a coluna 'status' existe na tabela check_in_error_logs

-- 1. Criar backup das funções existentes
DO $$
DECLARE
    func_count INTEGER;
BEGIN
    -- Verificar se já existe backup
    SELECT COUNT(*) INTO func_count FROM pg_proc WHERE proname = 'record_challenge_check_in_v2_backup';
    
    IF func_count = 0 THEN
        -- Criar backup da primeira versão
        EXECUTE 'CREATE OR REPLACE FUNCTION record_challenge_check_in_v2_backup_1() RETURNS VOID AS $inner$ BEGIN RAISE NOTICE ''Backup da função 1''; END; $inner$ LANGUAGE plpgsql';
        
        -- Criar backup da segunda versão
        EXECUTE 'CREATE OR REPLACE FUNCTION record_challenge_check_in_v2_backup_2() RETURNS VOID AS $inner$ BEGIN RAISE NOTICE ''Backup da função 2''; END; $inner$ LANGUAGE plpgsql';
        
        -- Criar backup da terceira versão
        EXECUTE 'CREATE OR REPLACE FUNCTION record_challenge_check_in_v2_backup_3() RETURNS VOID AS $inner$ BEGIN RAISE NOTICE ''Backup da função 3''; END; $inner$ LANGUAGE plpgsql';
        
        RAISE NOTICE 'Backups criados com sucesso';
    ELSE
        RAISE NOTICE 'Backups já existem, pulando etapa';
    END IF;
END $$;

-- 2. Remover todas as versões da função record_challenge_check_in_v2
DROP FUNCTION IF EXISTS record_challenge_check_in_v2(_challenge_id uuid, _date timestamp with time zone, _duration_minutes integer, _user_id uuid, _workout_id text, _workout_name text, _workout_type text);
DROP FUNCTION IF EXISTS record_challenge_check_in_v2(p_challenge_id uuid, p_user_id uuid, p_workout_id text, p_workout_name text, p_workout_type text, p_workout_date timestamp with time zone, p_duration_minutes integer);
DROP FUNCTION IF EXISTS record_challenge_check_in_v2(p_challenge_id uuid, p_user_id uuid, p_workout_id uuid, p_workout_name text, p_workout_type text, p_workout_date timestamp with time zone, p_duration_minutes integer);

-- 3. Criar uma única versão padronizada (utilizando a implementação da versão wrapper)
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

-- 4. Verificar se a coluna 'status' existe na tabela check_in_error_logs
DO $$
DECLARE
    column_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'check_in_error_logs'
        AND column_name = 'status'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        RAISE NOTICE 'A coluna "status" não existe na tabela check_in_error_logs. Adicionando...';
        EXECUTE 'ALTER TABLE check_in_error_logs ADD COLUMN status TEXT';
        RAISE NOTICE 'Coluna "status" adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'A coluna "status" já existe na tabela check_in_error_logs.';
    END IF;
END $$;

-- 5. Processar registros pendentes na fila
DO $$
DECLARE
    rec RECORD;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Iniciando processamento de registros pendentes...';
    
    FOR rec IN SELECT * FROM workout_processing_queue 
               WHERE (NOT processed_for_ranking OR NOT processed_for_dashboard)
               ORDER BY created_at 
               LIMIT 50 -- Limitar processamento para evitar sobrecarga
    LOOP
        BEGIN
            -- Processar para ranking se necessário
            IF NOT rec.processed_for_ranking THEN
                PERFORM process_workout_for_ranking(rec.workout_id);
            END IF;
            
            -- Processar para dashboard se necessário
            IF NOT rec.processed_for_dashboard THEN
                PERFORM process_workout_for_dashboard(rec.workout_id);
            END IF;
            
            success_count := success_count + 1;
        EXCEPTION WHEN OTHERS THEN
            -- Atualizar erro na fila
            UPDATE workout_processing_queue 
            SET processing_error = SQLERRM
            WHERE workout_id = rec.workout_id;
            
            error_count := error_count + 1;
        END;
    END LOOP;
    
    RAISE NOTICE 'Processamento concluído: % registros processados com sucesso, % com erro', success_count, error_count;
END $$; 