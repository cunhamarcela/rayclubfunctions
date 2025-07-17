-- Script para associar automaticamente treinos aos desafios ativos na data do treino

-- 1. Analisar treinos sem desafio
SELECT 
    COUNT(*) as total_without_challenge
FROM 
    workout_records
WHERE 
    challenge_id IS NULL;

-- 2. Atualizar treinos sem desafio (associando-os aos desafios ativos)
DO $$
DECLARE
    rec RECORD;
    active_challenge UUID;
    updated_count INTEGER := 0;
    skipped_count INTEGER := 0;
BEGIN
    -- Para cada treino sem desafio
    FOR rec IN 
        SELECT 
            id, user_id, date, duration_minutes 
        FROM 
            workout_records 
        WHERE 
            challenge_id IS NULL
        ORDER BY 
            date DESC
    LOOP
        -- Encontrar um desafio ativo para este usuário na data do treino
        SELECT 
            c.id INTO active_challenge
        FROM 
            challenges c
        JOIN 
            challenge_participants cp ON c.id = cp.challenge_id AND cp.user_id = rec.user_id
        WHERE 
            c.status = 'active' AND
            (rec.date BETWEEN c.start_date AND COALESCE(c.end_date, NOW() + INTERVAL '1 year'))
        LIMIT 1;
        
        -- Se encontrou um desafio ativo
        IF active_challenge IS NOT NULL THEN
            -- Atualizar o treino com o challenge_id
            UPDATE workout_records
            SET challenge_id = active_challenge
            WHERE id = rec.id;
            
            -- Verificar se o treino já está na fila de processamento
            IF NOT EXISTS (SELECT 1 FROM workout_processing_queue WHERE workout_id = rec.id) THEN
                -- Adicionar à fila de processamento
                INSERT INTO workout_processing_queue(
                    workout_id, user_id, challenge_id, processed_for_ranking, processed_for_dashboard
                ) VALUES (
                    rec.id, rec.user_id, active_challenge, FALSE, TRUE
                );
            ELSE
                -- Atualizar o challenge_id na fila existente
                UPDATE workout_processing_queue
                SET challenge_id = active_challenge,
                    processed_for_ranking = FALSE  -- Para forçar o reprocessamento
                WHERE workout_id = rec.id;
            END IF;
            
            updated_count := updated_count + 1;
        ELSE
            skipped_count := skipped_count + 1;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Atualização concluída: % treinos associados a desafios, % treinos sem desafio ativo', updated_count, skipped_count;
END $$;

-- 3. Processar os treinos associados para ranking
DO $$
DECLARE
    rec RECORD;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    -- Processar apenas os treinos que foram associados a desafios mas ainda não processados para ranking
    FOR rec IN 
        SELECT * FROM workout_processing_queue 
        WHERE challenge_id IS NOT NULL 
          AND NOT processed_for_ranking
        ORDER BY created_at
    LOOP
        BEGIN
            -- Processar para ranking
            IF process_workout_for_ranking(rec.workout_id) THEN
                success_count := success_count + 1;
            ELSE
                error_count := error_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            error_count := error_count + 1;
        END;
    END LOOP;

    RAISE NOTICE 'Processamento para ranking: % com sucesso, % com erro', success_count, error_count;
END $$;

-- 4. Verificar resultados após associação
SELECT 
    COUNT(*) as treinos_com_desafio
FROM 
    workout_records
WHERE 
    challenge_id IS NOT NULL;

-- 5. Verificar novos check-ins criados para o ranking
SELECT 
    COUNT(*) as novos_checkins
FROM 
    challenge_check_ins
WHERE 
    created_at > NOW() - INTERVAL '1 hour';

-- 6. Verificar atualizações no challenge_progress
SELECT 
    COUNT(*) as atualizacoes_ranking
FROM 
    challenge_progress
WHERE 
    updated_at > NOW() - INTERVAL '1 hour'; 