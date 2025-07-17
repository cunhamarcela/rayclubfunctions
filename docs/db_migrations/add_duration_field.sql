-- Migração para adicionar campo de duração aos treinos

-- 1. Verificar se a coluna duration_minutes já existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'workouts' AND column_name = 'duration_minutes'
    ) THEN
        -- Adicionar coluna duration_minutes se não existir
        ALTER TABLE workouts ADD COLUMN duration_minutes INTEGER;
        
        -- Criar índice para melhorar performance de filtros por duração
        CREATE INDEX IF NOT EXISTS workouts_duration_idx ON workouts(duration_minutes);
        
        RAISE NOTICE 'Coluna duration_minutes adicionada com sucesso.';
    ELSE
        RAISE NOTICE 'Coluna duration_minutes já existe na tabela workouts.';
    END IF;
END $$;

-- 2. Verificar o tipo da coluna duration para determinar a abordagem correta
DO $$
DECLARE
    column_type TEXT;
BEGIN
    -- Obter o tipo da coluna duration
    SELECT data_type INTO column_type
    FROM information_schema.columns
    WHERE table_name = 'workouts' AND column_name = 'duration';
    
    RAISE NOTICE 'Tipo da coluna duration: %', column_type;
    
    -- Verificar se é um tipo numérico
    IF column_type IN ('integer', 'bigint', 'smallint') THEN
        -- Se for numérico, copiar diretamente
        UPDATE workouts
        SET duration_minutes = duration
        WHERE (duration_minutes IS NULL OR duration_minutes = 0) AND duration IS NOT NULL;
        
        RAISE NOTICE 'Valores numéricos copiados diretamente da coluna duration.';
    -- Se for texto
    ELSIF column_type IN ('text', 'character varying', 'varchar') THEN
        -- Tentar extrair números de strings
        BEGIN
            UPDATE workouts
            SET duration_minutes = CASE 
                WHEN duration::TEXT ~ '^[0-9]+$' THEN duration::TEXT::INTEGER
                WHEN duration::TEXT ~ '^[0-9]+ min' THEN SUBSTRING(duration::TEXT FROM '^([0-9]+)')::INTEGER
                ELSE 30 -- valor padrão para casos em que não conseguimos extrair
            END
            WHERE (duration_minutes IS NULL OR duration_minutes = 0) AND duration IS NOT NULL;
            
            RAISE NOTICE 'Valores extraídos com sucesso da coluna duration de texto.';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Erro ao processar valores de texto: %', SQLERRM;
            -- Em caso de erro, usar abordagem mais simples
            UPDATE workouts
            SET duration_minutes = 30
            WHERE duration_minutes IS NULL OR duration_minutes = 0;
        END;
    -- Para qualquer outro tipo
    ELSE
        RAISE NOTICE 'Tipo de coluna não reconhecido. Usando valores padrão.';
        UPDATE workouts
        SET duration_minutes = 30
        WHERE duration_minutes IS NULL OR duration_minutes = 0;
    END IF;
END $$;

-- 3. Definir valor padrão para registros que ainda estão sem duração
UPDATE workouts
SET duration_minutes = 30
WHERE duration_minutes IS NULL OR duration_minutes = 0;

-- 4. Atualizar a duração em formato string para corresponder ao duration_minutes
-- Só feito para valores NULL, já que parece que duration é um inteiro
UPDATE workouts
SET duration = duration_minutes
WHERE duration IS NULL;

-- 5. Usar a coluna category existente
DO $$
BEGIN
    RAISE NOTICE 'A coluna category já existe e será usada para categorização de treinos.';
END $$; 