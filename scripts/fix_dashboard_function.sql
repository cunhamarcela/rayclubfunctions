-- Script para corrigir a função process_workout_for_dashboard usando o nome correto das colunas

-- Corrigir a função process_workout_for_dashboard
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
    -- Usando as colunas corretas encontradas na tabela user_progress
    BEGIN
        INSERT INTO user_progress(
            user_id,
            points,                -- Corrigido: era 'challenge_points'
            workouts,              -- Nova coluna
            challenges_completed,  -- Corrigido: era 'challenges_completed_count'
            updated_at
        ) VALUES (
            workout.user_id,
            points_to_add,
            1,                     -- Iniciar com 1 treino
            0,                     -- Iniciar com 0 desafios completados
            NOW()
        ) 
        ON CONFLICT (user_id) 
        DO UPDATE SET
            points = user_progress.points + points_to_add,
            workouts = COALESCE(user_progress.workouts, 0) + 1,
            updated_at = NOW();
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao atualizar user_progress: %', SQLERRM;
        
        -- Registrar o erro mas marcar como processado para não bloquear
        UPDATE workout_processing_queue 
        SET processed_for_dashboard = TRUE,
            processing_error = 'Erro ao atualizar user_progress: ' || SQLERRM,
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
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

-- Tentar reprocessar os registros com a nova função
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
                  OR processing_error LIKE '%user_progress%'
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
    
    -- Resumo final dos registros
    RAISE NOTICE 'Status final:';
    RAISE NOTICE '  Registros pendentes para dashboard: %', 
        (SELECT COUNT(*) FROM workout_processing_queue WHERE NOT processed_for_dashboard);
    RAISE NOTICE '  Registros processados corretamente: %', 
        (SELECT COUNT(*) FROM workout_processing_queue WHERE processed_for_dashboard AND processing_error IS NULL);
    RAISE NOTICE '  Registros com erros: %', 
        (SELECT COUNT(*) FROM workout_processing_queue WHERE processing_error IS NOT NULL);
END $$; 