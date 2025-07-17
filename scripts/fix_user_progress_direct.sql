-- Script simplificado para adicionar a constraint PRIMARY KEY diretamente

-- 1. Adicionar a PRIMARY KEY diretamente (mais simples e direto)
ALTER TABLE user_progress ADD PRIMARY KEY (user_id);

-- 2. Se o comando acima falhar, tentar com constraint UNIQUE
-- ALTER TABLE user_progress ADD CONSTRAINT user_progress_user_id_key UNIQUE (user_id);

-- 3. Limpar todos os erros relacionados ao constraint para permitir reprocessamento
UPDATE workout_processing_queue 
SET processing_error = NULL,
    processed_for_dashboard = FALSE  -- Forçar reprocessamento
WHERE processing_error LIKE '%unique or exclusion constraint%';

-- 4. Verificar se os erros foram limpos
SELECT COUNT(*) as errors_remaining 
FROM workout_processing_queue 
WHERE processing_error LIKE '%unique or exclusion constraint%';

-- 5. Reprocessar todos os registros pendentes para o dashboard
DO $$
DECLARE
    rec RECORD;
    count_success INTEGER := 0;
    count_error INTEGER := 0;
BEGIN
    FOR rec IN 
        SELECT workout_id FROM workout_processing_queue 
        WHERE NOT processed_for_dashboard
        ORDER BY created_at
    LOOP
        IF process_workout_for_dashboard(rec.workout_id) THEN
            count_success := count_success + 1;
        ELSE
            count_error := count_error + 1;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Processamento finalizado: % sucesso, % erro', count_success, count_error;
END$$; 