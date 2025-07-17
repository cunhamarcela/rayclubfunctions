-- Script para investigar e corrigir os registros pendentes na fila de processamento

-- 1. Examinar detalhes dos registros pendentes
SELECT 
    q.id,
    q.workout_id,
    q.user_id,
    q.challenge_id,
    q.processed_for_ranking,
    q.processed_for_dashboard,
    q.processing_error,
    q.created_at,
    q.processed_at,
    w.workout_name,
    w.workout_type,
    w.duration_minutes,
    w.date
FROM 
    workout_processing_queue q
JOIN 
    workout_records w ON q.workout_id = w.id
WHERE 
    NOT (q.processed_for_ranking AND q.processed_for_dashboard)
ORDER BY 
    q.created_at;

-- 2. Verificar se os registros possuem desafios associados
SELECT 
    q.id,
    q.workout_id,
    q.challenge_id,
    CASE WHEN c.id IS NULL THEN 'DESAFIO NÃO ENCONTRADO' ELSE 'OK' END as challenge_status,
    CASE WHEN cp.user_id IS NULL THEN 'USUÁRIO NÃO PARTICIPA' ELSE 'OK' END as participant_status
FROM 
    workout_processing_queue q
LEFT JOIN 
    challenges c ON q.challenge_id = c.id
LEFT JOIN 
    challenge_participants cp ON q.challenge_id = cp.challenge_id AND q.user_id = cp.user_id
WHERE 
    NOT (q.processed_for_ranking AND q.processed_for_dashboard);

-- 3. Verificar se existem check-ins duplicados para as mesmas datas
SELECT 
    q.id,
    q.workout_id,
    q.challenge_id,
    q.user_id,
    w.date,
    COUNT(ci.id) as existing_checkins
FROM 
    workout_processing_queue q
JOIN 
    workout_records w ON q.workout_id = w.id
LEFT JOIN
    challenge_check_ins ci ON 
        ci.challenge_id = q.challenge_id AND 
        ci.user_id = q.user_id AND 
        DATE(ci.check_in_date) = DATE(w.date)
WHERE 
    NOT (q.processed_for_ranking AND q.processed_for_dashboard)
GROUP BY
    q.id, q.workout_id, q.challenge_id, q.user_id, w.date
HAVING
    COUNT(ci.id) > 0;

-- 4. Verificar se os treinos têm duração suficiente
SELECT 
    q.id,
    q.workout_id,
    w.duration_minutes,
    CASE WHEN w.duration_minutes < 45 THEN 'DURAÇÃO INSUFICIENTE' ELSE 'OK' END as duration_status
FROM 
    workout_processing_queue q
JOIN 
    workout_records w ON q.workout_id = w.id
WHERE 
    NOT (q.processed_for_ranking AND q.processed_for_dashboard);

-- 5. Tentar processamento individual com tratamento de erro detalhado
DO $$
DECLARE
    rec RECORD;
    error_message TEXT;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Iniciando processamento detalhado dos registros pendentes...';
    
    FOR rec IN SELECT * FROM workout_processing_queue 
               WHERE (NOT processed_for_ranking OR NOT processed_for_dashboard)
               ORDER BY created_at
    LOOP
        BEGIN
            -- Processar para ranking se necessário e registrar erro detalhado
            IF NOT rec.processed_for_ranking THEN
                RAISE NOTICE 'Processando ranking para workout_id: %', rec.workout_id;
                BEGIN
                    PERFORM process_workout_for_ranking(rec.workout_id);
                    RAISE NOTICE '  ✓ Ranking processado com sucesso';
                EXCEPTION WHEN OTHERS THEN
                    error_message := SQLERRM;
                    RAISE NOTICE '  ✗ Erro ao processar ranking: %', error_message;
                    
                    -- Registrar erro detalhado
                    INSERT INTO check_in_error_logs(
                        user_id, challenge_id, workout_id, error_message, status, created_at
                    ) VALUES (
                        rec.user_id, rec.challenge_id, rec.workout_id, 
                        'Erro ao processar ranking: ' || error_message,
                        'processing_error', NOW()
                    );
                END;
            END IF;
            
            -- Processar para dashboard se necessário e registrar erro detalhado
            IF NOT rec.processed_for_dashboard THEN
                RAISE NOTICE 'Processando dashboard para workout_id: %', rec.workout_id;
                BEGIN
                    PERFORM process_workout_for_dashboard(rec.workout_id);
                    RAISE NOTICE '  ✓ Dashboard processado com sucesso';
                EXCEPTION WHEN OTHERS THEN
                    error_message := SQLERRM;
                    RAISE NOTICE '  ✗ Erro ao processar dashboard: %', error_message;
                    
                    -- Registrar erro detalhado
                    INSERT INTO check_in_error_logs(
                        user_id, challenge_id, workout_id, error_message, status, created_at
                    ) VALUES (
                        rec.user_id, rec.challenge_id, rec.workout_id, 
                        'Erro ao processar dashboard: ' || error_message,
                        'processing_error', NOW()
                    );
                END;
            END IF;
            
            -- Verificar se o processamento foi concluído com sucesso
            IF (
                (rec.processed_for_ranking OR (NOT rec.processed_for_ranking AND process_workout_for_ranking(rec.workout_id))) AND 
                (rec.processed_for_dashboard OR (NOT rec.processed_for_dashboard AND process_workout_for_dashboard(rec.workout_id)))
            ) THEN
                success_count := success_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            error_count := error_count + 1;
            error_message := SQLERRM;
            RAISE NOTICE 'Erro geral ao processar workout_id %: %', rec.workout_id, error_message;
            
            -- Registrar erro geral
            UPDATE workout_processing_queue 
            SET processing_error = error_message
            WHERE workout_id = rec.workout_id;
            
            -- Adicionar log de erro
            INSERT INTO check_in_error_logs(
                user_id, challenge_id, workout_id, error_message, status, created_at
            ) VALUES (
                rec.user_id, rec.challenge_id, rec.workout_id, 
                'Erro geral: ' || error_message,
                'processing_error', NOW()
            );
        END;
    END LOOP;
    
    RAISE NOTICE 'Processamento detalhado concluído: % registros processados com sucesso, % com erro', success_count, error_count;
    
    -- Opcional: Forçar processamento completo (use com cautela)
    -- UPDATE workout_processing_queue 
    -- SET processed_for_ranking = TRUE, processed_for_dashboard = TRUE,
    --     processed_at = NOW(), processing_error = 'Forçado via script de debug'
    -- WHERE NOT (processed_for_ranking AND processed_for_dashboard);
END $$;

-- 6. Verificar novamente o status da fila após o processamento
SELECT 
    COUNT(*) as total_records,
    SUM(CASE WHEN processed_for_ranking AND processed_for_dashboard THEN 1 ELSE 0 END) as fully_processed,
    SUM(CASE WHEN NOT processed_for_ranking OR NOT processed_for_dashboard THEN 1 ELSE 0 END) as pending_processing
FROM 
    workout_processing_queue
WHERE 
    created_at > NOW() - INTERVAL '7 days';

-- 7. Buscar erros registrados no log
SELECT * FROM check_in_error_logs 
WHERE created_at > NOW() - INTERVAL '1 day'
ORDER BY created_at DESC; 