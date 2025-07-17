-- Script para corrigir problemas de nome de coluna e função process_workout_for_dashboard

-- 1. Verificar a estrutura real da tabela user_progress
SELECT 
    column_name, 
    data_type
FROM 
    information_schema.columns
WHERE 
    table_schema = 'public' 
    AND table_name = 'user_progress'
ORDER BY 
    ordinal_position;

-- 2. Corrigir a função process_workout_for_dashboard
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
    
    -- ATUALIZAR PROGRESSO GERAL DO USUÁRIO
    -- Verificando estrutura da tabela e ajustando os nomes das colunas
    BEGIN
        -- Tentar com o nome de coluna 'challenge_points'
        INSERT INTO user_progress(
            user_id,
            challenge_points,  -- Nome que estava na função original
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
        BEGIN
            -- Tentar com o nome alternativo 'points'
            INSERT INTO user_progress(
                user_id,
                points,  -- Nome alternativo
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
                points = user_progress.points + points_to_add,
                challenges_joined_count = user_progress.challenges_joined_count,
                challenges_completed_count = user_progress.challenges_completed_count,
                updated_at = NOW();
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Erro ao atualizar user_progress: %', SQLERRM;
            
            -- Marcar como processado mesmo com erro para não bloquear o fluxo
            UPDATE workout_processing_queue 
            SET processed_for_dashboard = TRUE,
                processing_error = 'Erro ao atualizar user_progress: ' || SQLERRM,
                processed_at = NOW() 
            WHERE workout_id = _workout_record_id;
            
            RETURN FALSE;
        END;
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

-- 3. Tentar reprocessar os registros com a nova função
DO $$
DECLARE
    rec RECORD;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Iniciando processamento de registros para dashboard...';
    
    -- Processar todos os registros que tiveram erro no dashboard
    FOR rec IN SELECT * FROM workout_processing_queue 
               WHERE processing_error LIKE '%challenge_points%'
               ORDER BY created_at
    LOOP
        BEGIN
            RAISE NOTICE 'Processando registro: %', rec.workout_id;
            
            -- Processar dashboard novamente
            IF process_workout_for_dashboard(rec.workout_id) THEN
                RAISE NOTICE '  ✓ Dashboard processado com sucesso';
                success_count := success_count + 1;
            ELSE
                RAISE NOTICE '  ✗ Falha no processamento de dashboard';
                error_count := error_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            error_count := error_count + 1;
            RAISE NOTICE '  ✗ Erro geral: %', SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Processamento concluído: % registros processados com sucesso, % com erro', success_count, error_count;
END $$;

-- 4. Verificar o problema dos challenge_id NULL
SELECT 
    count(*) as total_workouts,
    sum(CASE WHEN challenge_id IS NULL THEN 1 ELSE 0 END) as without_challenge,
    sum(CASE WHEN challenge_id IS NOT NULL THEN 1 ELSE 0 END) as with_challenge
FROM 
    workout_records
WHERE 
    created_at > NOW() - INTERVAL '7 days'; 