-- 🔧 CORREÇÃO: Função get_workout_records_with_user_info para incluir treinos sem challenge_id
-- Para executar no Supabase remoto

-- Corrigir a função para incluir treinos sem challenge_id quando buscando treinos de usuário específico
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

-- Teste da função corrigida
SELECT '🔍 TESTE: Buscando treinos do usuário específico (deve incluir todos os treinos)' as etapa;

-- Buscar treinos de um usuário específico (substitua pelo seu user_id real)
-- Isso deve retornar TODOS os treinos do usuário, incluindo os sem challenge_id
SELECT 
    id,
    workout_name,
    workout_type,
    challenge_id,
    date
FROM get_workout_records_with_user_info(
    p_challenge_id := NULL,
    p_user_id := '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,  -- Seu user_id
    p_limit := 50
);

-- Verificar status da correção
SELECT '✅ CORREÇÃO APLICADA: A função agora inclui treinos sem challenge_id para buscas por usuário específico' as status; 