-- Primeiro, verificar se a coluna formatted_date existe na tabela challenge_check_ins
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'challenge_check_ins' 
        AND column_name = 'formatted_date'
    ) THEN
        -- Adicionar a coluna formatted_date se não existir
        ALTER TABLE challenge_check_ins ADD COLUMN formatted_date VARCHAR(10);
        
        -- Preencher dados existentes
        UPDATE challenge_check_ins
        SET formatted_date = TO_CHAR(check_in_date::date, 'YYYY-MM-DD')
        WHERE formatted_date IS NULL;
        
        -- Criar índice para melhorar consultas
        CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_formatted_date 
        ON challenge_check_ins(formatted_date);
        
        RAISE NOTICE 'Coluna formatted_date adicionada à tabela challenge_check_ins';
    ELSE
        RAISE NOTICE 'Coluna formatted_date já existe na tabela challenge_check_ins';
    END IF;
END $$;

-- Agora, verificar se a função has_check_in_on_date já existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'has_check_in_on_date'
    ) THEN
        -- Criar a função has_check_in_on_date se não existir
        EXECUTE '
        CREATE OR REPLACE FUNCTION public.has_check_in_on_date(
            _user_id UUID,
            _challenge_id UUID,
            _check_date VARCHAR
        ) RETURNS BOOLEAN AS $$
        DECLARE
          check_exists BOOLEAN;
        BEGIN
          SELECT EXISTS (
            SELECT 1 
            FROM challenge_check_ins 
            WHERE user_id = _user_id 
              AND challenge_id = _challenge_id 
              AND formatted_date = _check_date
          ) INTO check_exists;
          
          RETURN check_exists;
        END;
        $$ LANGUAGE plpgsql;
        ';
        
        RAISE NOTICE 'Função has_check_in_on_date criada com sucesso';
    ELSE
        RAISE NOTICE 'Função has_check_in_on_date já existe';
    END IF;
END $$;

-- Verificar se a função record_challenge_check_in aceita os parâmetros corretos
SELECT 
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as function_arguments
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public'
    AND p.proname = 'record_challenge_check_in'; 