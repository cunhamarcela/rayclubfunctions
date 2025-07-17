-- Função para atualizar as posições no ranking de um desafio
CREATE OR REPLACE FUNCTION public.update_challenge_ranking(
    _challenge_id UUID
) RETURNS void AS $$
BEGIN
    -- Atualizar as posições de todos os participantes no ranking
    -- baseado na quantidade de pontos (ordem decrescente)
    WITH ranked_users AS (
        SELECT 
            id, 
            ROW_NUMBER() OVER (ORDER BY points DESC) AS new_position
        FROM 
            challenge_progress
        WHERE 
            challenge_id = _challenge_id
    )
    UPDATE challenge_progress cp
    SET position = ru.new_position
    FROM ranked_users ru
    WHERE cp.id = ru.id
    AND cp.challenge_id = _challenge_id;
    
    RAISE NOTICE 'Ranking para o desafio % atualizado com sucesso.', _challenge_id;
END;
$$ LANGUAGE plpgsql; 