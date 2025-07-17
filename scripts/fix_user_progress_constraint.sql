-- Script para corrigir o erro "there is no unique or exclusion constraint matching the ON CONFLICT specification"

-- 1. Verificar se já existe alguma constraint na tabela user_progress
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM 
    pg_constraint
WHERE 
    conrelid = 'user_progress'::regclass;

-- 2. Verificar índices existentes
SELECT 
    indexname,
    indexdef
FROM 
    pg_indexes
WHERE 
    tablename = 'user_progress';

-- 3. Adicionar a constraint UNIQUE na coluna user_id
DO $$
BEGIN
    -- Verificar se já existe constraint
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conrelid = 'user_progress'::regclass 
        AND contype = 'p'  -- 'p' para PRIMARY KEY
    ) THEN
        -- Adicionar PRIMARY KEY em user_id
        ALTER TABLE user_progress ADD PRIMARY KEY (user_id);
        RAISE NOTICE 'PRIMARY KEY adicionada na coluna user_id da tabela user_progress';
    ELSE
        RAISE NOTICE 'A tabela user_progress já possui uma PRIMARY KEY';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao adicionar PRIMARY KEY: %', SQLERRM;
        
        -- Tentar adicionar UNIQUE constraint como alternativa
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint 
            WHERE conrelid = 'user_progress'::regclass 
            AND contype = 'u'  -- 'u' para UNIQUE
            AND conkey @> array[
                (SELECT attnum FROM pg_attribute WHERE attrelid = 'user_progress'::regclass AND attname = 'user_id')
            ]::smallint[]
        ) THEN
            ALTER TABLE user_progress ADD CONSTRAINT user_progress_user_id_key UNIQUE (user_id);
            RAISE NOTICE 'UNIQUE constraint adicionada na coluna user_id da tabela user_progress';
        ELSE
            RAISE NOTICE 'A tabela user_progress já possui uma UNIQUE constraint na coluna user_id';
        END IF;
END $$;

-- 4. Reprocessar os registros que tiveram erro
DO $$
DECLARE
    rec RECORD;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Iniciando reprocessamento para dashboard...';
    
    -- Processar todos os registros que tiveram erro no dashboard
    FOR rec IN SELECT * FROM workout_processing_queue 
               WHERE processing_error LIKE '%ON CONFLICT%'
               ORDER BY created_at
    LOOP
        BEGIN
            RAISE NOTICE 'Processando registro: %', rec.workout_id;
            
            -- Limpar o erro
            UPDATE workout_processing_queue 
            SET processing_error = NULL
            WHERE workout_id = rec.workout_id;
            
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
    
    RAISE NOTICE 'Reprocessamento concluído: % registros processados com sucesso, % com erro', success_count, error_count;
END $$;

-- 5. Verificar se ainda existem erros
SELECT 
    processing_error, 
    COUNT(*) 
FROM 
    workout_processing_queue 
WHERE 
    processing_error IS NOT NULL
GROUP BY 
    processing_error; 