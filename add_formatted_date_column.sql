-- Verificar e adicionar a coluna formatted_date na tabela challenge_check_ins
DO $$
BEGIN
    -- Verificar se a coluna formatted_date já existe
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'challenge_check_ins' 
        AND column_name = 'formatted_date'
    ) THEN
        -- Adicionar a coluna formatted_date
        ALTER TABLE challenge_check_ins 
        ADD COLUMN formatted_date VARCHAR(10);
        
        -- Preencher dados existentes
        UPDATE challenge_check_ins
        SET formatted_date = TO_CHAR(check_in_date::date, 'YYYY-MM-DD')
        WHERE formatted_date IS NULL;
        
        -- Criar índices
        CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_formatted_date 
        ON challenge_check_ins(formatted_date);
        
        -- Criar índice composto para validação de check-in único por dia
        CREATE UNIQUE INDEX IF NOT EXISTS idx_challenge_check_ins_unique_daily 
        ON challenge_check_ins(user_id, challenge_id, formatted_date);
        
        -- Criar gatilho para preencher automaticamente formatted_date
        CREATE OR REPLACE FUNCTION set_formatted_date()
        RETURNS TRIGGER AS $$
        BEGIN
            IF NEW.formatted_date IS NULL THEN
                NEW.formatted_date = TO_CHAR(NEW.check_in_date::date, 'YYYY-MM-DD');
            END IF;
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
        
        DROP TRIGGER IF EXISTS trigger_set_formatted_date ON challenge_check_ins;
        CREATE TRIGGER trigger_set_formatted_date
        BEFORE INSERT OR UPDATE ON challenge_check_ins
        FOR EACH ROW
        EXECUTE FUNCTION set_formatted_date();
        
        RAISE NOTICE 'Coluna formatted_date adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'Coluna formatted_date já existe na tabela challenge_check_ins.';
    END IF;
END $$; 