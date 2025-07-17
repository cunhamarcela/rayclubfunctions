-- Script para corrigir o relacionamento entre workout_records e profiles
-- Execute no Console SQL do Supabase

-- 1. Verificar se todas as foreign keys estão corretas
-- Primeiro, verificar se todos os user_id em workout_records existem em profiles
DO $$
DECLARE
    orphaned_count INTEGER;
BEGIN
    -- Contar registros órfãos (user_id que não existem em profiles)
    SELECT COUNT(*) INTO orphaned_count
    FROM workout_records wr
    WHERE NOT EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = wr.user_id
    );
    
    IF orphaned_count > 0 THEN
        RAISE NOTICE 'Encontrados % registros órfãos em workout_records', orphaned_count;
        
        -- Remover registros órfãos (opcional - comente se não quiser remover)
        -- DELETE FROM workout_records 
        -- WHERE NOT EXISTS (
        --     SELECT 1 FROM profiles p WHERE p.id = workout_records.user_id
        -- );
    ELSE
        RAISE NOTICE 'Todos os registros de workout_records têm user_id válido em profiles';
    END IF;
END $$;

-- 2. Verificar se a tabela profiles tem chave primária correta
-- Garantir que profiles.id seja primary key (deve ser auth.users.id)
DO $$
BEGIN
    -- Verificar se profiles.id já é primary key
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'profiles' 
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
        -- Se não for, adicionar primary key
        ALTER TABLE profiles ADD PRIMARY KEY (id);
        RAISE NOTICE 'Primary key adicionada à tabela profiles';
    END IF;
END $$;

-- 3. Criar uma foreign key virtual através de uma VIEW que facilita os JOINs
-- Isso permitirá que o Supabase reconheça a relação automaticamente
CREATE OR REPLACE VIEW workout_records_with_profiles AS
SELECT 
    wr.*,
    p.name as profile_name,
    p.photo_url as profile_photo_url,
    p.email as profile_email
FROM workout_records wr
LEFT JOIN profiles p ON p.id = wr.user_id;

-- 4. Habilitar RLS na view se necessário
-- ALTER VIEW workout_records_with_profiles ENABLE ROW LEVEL SECURITY;

-- 5. Verificar se agora conseguimos fazer a query problemática
-- Esta query deveria funcionar após as correções acima
DO $$
DECLARE
    test_result RECORD;
    error_message TEXT;
BEGIN
    -- Tentar fazer uma query de teste similar à que estava falhando
    BEGIN
        SELECT COUNT(*) as total_records 
        INTO test_result
        FROM workout_records wr
        LEFT JOIN profiles p ON p.id = wr.user_id
        LIMIT 1;
        
        RAISE NOTICE 'Query de teste executada com sucesso: % registros encontrados', test_result.total_records;
    EXCEPTION 
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            RAISE NOTICE 'Erro na query de teste: %', error_message;
    END;
END $$;

-- 6. Criar uma função helper para queries com perfil
CREATE OR REPLACE FUNCTION get_workout_records_with_user_info(
    p_challenge_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    workout_name TEXT,
    workout_type TEXT,
    date TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    notes TEXT,
    image_urls TEXT[],
    challenge_id UUID,
    user_name TEXT,
    user_photo_url TEXT,
    user_email TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wr.id,
        wr.user_id,
        wr.workout_name,
        wr.workout_type,
        wr.date,
        wr.duration_minutes,
        wr.notes,
        wr.image_urls,
        wr.challenge_id,
        COALESCE(p.name, 'Usuário ' || wr.user_id::text) as user_name,
        p.photo_url as user_photo_url,
        p.email as user_email
    FROM workout_records wr
    LEFT JOIN profiles p ON p.id = wr.user_id
    WHERE 
        -- Se estamos buscando treinos de um usuário específico, incluir TODOS os treinos (com ou sem challenge_id)
        -- Se estamos buscando por desafio, incluir apenas treinos COM o challenge_id específico
        CASE 
            WHEN p_user_id IS NOT NULL THEN
                -- Para usuário específico: mostrar todos os treinos (com ou sem desafio)
                wr.user_id = p_user_id
            WHEN p_challenge_id IS NOT NULL THEN  
                -- Para desafio específico: apenas treinos desse desafio
                wr.challenge_id = p_challenge_id
            ELSE
                -- Busca geral: todos os treinos
                TRUE
        END
    ORDER BY wr.date DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- 7. Dar permissões para a função
GRANT EXECUTE ON FUNCTION get_workout_records_with_user_info TO authenticated;

-- ========================================================================
-- NOVO: CORREÇÃO PARA WORKOUT_PROCESSING_QUEUE
-- ========================================================================

-- 8. Verificar e corrigir a tabela workout_processing_queue
-- Garantir que a tabela existe e tem a estrutura correta
CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workout_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- 9. Verificar registros órfãos na fila de processamento
DO $$
DECLARE
    orphaned_queue_count INTEGER;
BEGIN
    -- Contar registros na fila que referenciam workout_records inexistentes
    SELECT COUNT(*) INTO orphaned_queue_count
    FROM workout_processing_queue wq
    WHERE NOT EXISTS (
        SELECT 1 FROM workout_records wr WHERE wr.id = wq.workout_id
    );
    
    IF orphaned_queue_count > 0 THEN
        RAISE NOTICE 'Encontrados % registros órfãos em workout_processing_queue', orphaned_queue_count;
        
        -- Remover registros órfãos
        DELETE FROM workout_processing_queue 
        WHERE NOT EXISTS (
            SELECT 1 FROM workout_records wr WHERE wr.id = workout_processing_queue.workout_id
        );
        
        RAISE NOTICE 'Registros órfãos removidos da workout_processing_queue';
    ELSE
        RAISE NOTICE 'Todos os registros de workout_processing_queue são válidos';
    END IF;
END $$;

-- 10. Função para buscar workout_records com informações de processamento
CREATE OR REPLACE FUNCTION get_workout_records_with_processing_status(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    workout_id UUID,
    workout_name TEXT,
    workout_type TEXT,
    date TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    is_completed BOOLEAN,
    completion_status TEXT,
    notes TEXT,
    image_urls TEXT[],
    created_at TIMESTAMP WITH TIME ZONE,
    challenge_id UUID,
    -- Campos de processamento
    processing_id UUID,
    processed_for_ranking BOOLEAN,
    processed_for_dashboard BOOLEAN,
    processing_error TEXT,
    processing_created_at TIMESTAMP WITH TIME ZONE,
    processing_processed_at TIMESTAMP WITH TIME ZONE
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wr.id,
        wr.user_id,
        wr.workout_id,
        wr.workout_name,
        wr.workout_type,
        wr.date,
        wr.duration_minutes,
        wr.is_completed,
        wr.completion_status,
        wr.notes,
        wr.image_urls,
        wr.created_at,
        wr.challenge_id,
        -- Campos de processamento (podem ser NULL se não existir)
        wq.id as processing_id,
        wq.processed_for_ranking,
        wq.processed_for_dashboard,
        wq.processing_error,
        wq.created_at as processing_created_at,
        wq.processed_at as processing_processed_at
    FROM workout_records wr
    LEFT JOIN workout_processing_queue wq ON wq.workout_id = wr.id
    WHERE wr.user_id = p_user_id
    ORDER BY wr.date DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- 11. Dar permissões para a nova função
GRANT EXECUTE ON FUNCTION get_workout_records_with_processing_status TO authenticated;

-- 12. Criar índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_workout_processing_queue_workout_id
ON workout_processing_queue(workout_id);

CREATE INDEX IF NOT EXISTS idx_workout_processing_queue_user_id
ON workout_processing_queue(user_id);

CREATE INDEX IF NOT EXISTS idx_workout_processing_queue_processing_status
ON workout_processing_queue(processed_for_ranking, processed_for_dashboard);

-- Mensagem final
DO $$
BEGIN
    RAISE NOTICE '=== CORREÇÃO CONCLUÍDA ===';
    RAISE NOTICE 'Agora você pode usar:';
    RAISE NOTICE '1. A view workout_records_with_profiles para queries diretas';
    RAISE NOTICE '2. A função get_workout_records_with_user_info() para queries programáticas';
    RAISE NOTICE '3. A função get_workout_records_with_processing_status() para dados com status de processamento';
    RAISE NOTICE '4. JOINs explícitos: LEFT JOIN profiles p ON p.id = workout_records.user_id';
    RAISE NOTICE '5. JOINs explícitos: LEFT JOIN workout_processing_queue q ON q.workout_id = workout_records.id';
END $$; 