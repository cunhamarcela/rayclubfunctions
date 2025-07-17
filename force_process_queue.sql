-- Script para processar manualmente a workout_processing_queue
-- Forçar processamento dos itens pendentes

-- Primeiro, verificar itens não processados
SELECT 'Itens não processados na queue:' as status;
SELECT 
    wpq.id,
    wpq.workout_id,
    wpq.user_id,
    wpq.challenge_id,
    wpq.processed_for_ranking,
    wpq.created_at,
    wr.workout_name,
    wr.duration_minutes
FROM workout_processing_queue wpq
LEFT JOIN workout_records wr ON wpq.workout_id = wr.id
WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND wpq.processed_for_ranking = false
ORDER BY wpq.created_at DESC;

-- Tentar processar manualmente cada item da queue
DO $$
DECLARE
    queue_item RECORD;
    process_result text;
    error_msg text;
BEGIN
    -- Processar todos os itens não processados para este usuário
    FOR queue_item IN 
        SELECT 
            wpq.id,
            wpq.workout_id,
            wpq.user_id,
            wpq.challenge_id,
            wr.workout_name,
            wr.duration_minutes,
            wr.notes,
            wr.workout_date,
            wr.workout_type
        FROM workout_processing_queue wpq
        LEFT JOIN workout_records wr ON wpq.workout_id = wr.id
        WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
        AND wpq.processed_for_ranking = false
        ORDER BY wpq.created_at DESC
    LOOP
        BEGIN
            RAISE NOTICE 'Processando item da queue: %, workout: %', 
                queue_item.id, queue_item.workout_name;
                
            -- Tentar chamar a função de processamento
            SELECT process_workout_for_ranking_one_per_day(
                queue_item.workout_id
            ) INTO process_result;
            
            RAISE NOTICE 'Resultado do processamento: %', process_result;
            
            -- Marcar como processado se deu certo
            UPDATE workout_processing_queue 
            SET 
                processed_for_ranking = true,
                processed_at = NOW()
            WHERE id = queue_item.id;
            
        EXCEPTION WHEN OTHERS THEN
            error_msg := SQLERRM;
            RAISE NOTICE 'ERRO ao processar item %: %', queue_item.id, error_msg;
            
            -- Registrar o erro na queue
            UPDATE workout_processing_queue 
            SET 
                error_message = error_msg,
                processed_at = NOW()
            WHERE id = queue_item.id;
        END;
    END LOOP;
END
$$;

-- Verificar se os itens foram processados
SELECT 'Status após processamento manual:' as status;
SELECT 
    wpq.id,
    wpq.workout_id,
    wpq.processed_for_ranking,
    wpq.processed_at,
    wpq.error_message,
    wr.workout_name
FROM workout_processing_queue wpq
LEFT JOIN workout_records wr ON wpq.workout_id = wr.id
WHERE wpq.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY wpq.created_at DESC
LIMIT 5;

-- Verificar se foram criados novos check-ins
SELECT 'Check-ins após processamento:' as status;
SELECT 
    cci.id,
    cci.user_id,
    cci.challenge_id,
    cci.workout_record_id,
    cci.points_earned,
    cci.checked_in_at,
    wr.workout_name
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON cci.workout_record_id = wr.id
WHERE cci.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cci.checked_in_at DESC;

-- Verificar progresso atualizado
SELECT 'Progresso final após processamento:' as status;
SELECT 
    cp.user_id,
    cp.challenge_id,
    cp.total_points,
    cp.check_ins_count,
    cp.current_rank,
    cp.progress_percentage,
    cp.last_check_in
FROM challenge_progress cp
WHERE cp.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Comparação final
SELECT 'COMPARAÇÃO FINAL:' as titulo;
SELECT 
    'ANTES' as momento,
    40 as pontos,
    4 as checkins,
    86 as posicao
UNION ALL
SELECT 
    'DEPOIS' as momento,
    cp.total_points as pontos,
    cp.check_ins_count as checkins,
    cp.current_rank as posicao
FROM challenge_progress cp
WHERE cp.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 