-- Script para inserir o Desafio Ray 21
-- Data início: 26/05/2024 00:00 (horário de Brasília)
-- Data fim: 15/06/2024 23:59:59 (horário de Brasília)
-- Pontos por check-in: 10

-- Verificar se o desafio já existe para evitar duplicatas
DO $$
BEGIN
    -- Verificar se já existe um desafio com este título
    IF NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Desafio Ray 21') THEN
        -- Inserir o desafio na tabela challenges
        INSERT INTO challenges (
            title,
            description,
            image_url,
            start_date,
            end_date,
            type,
            points,
            requirements,
            participants,
            active,
            creator_id,
            is_official,
            created_at,
            updated_at
        ) VALUES (
            'Desafio Ray 21',
            'Participe do Desafio Ray 21! Faça check-ins diários e ganhe pontos. Cada check-in vale 10 pontos. O desafio vai de 26 de maio a 15 de junho de 2024.',
            NULL, -- Pode ser atualizado depois com a URL da imagem
            '2024-05-26 03:00:00+00'::timestamp with time zone, -- 26/05/2024 00:00 horário de Brasília (UTC-3)
            '2024-06-15 02:59:59+00'::timestamp with time zone, -- 15/06/2024 23:59:59 horário de Brasília (UTC-3)
            'daily',
            10, -- 10 pontos por check-in
            jsonb_build_object(
                'points_per_checkin', 10,
                'min_duration_minutes', 45,
                'description', 'Desafio de check-ins diários',
                'rules', ARRAY[
                    'Faça check-ins diários para ganhar pontos',
                    'Cada check-in vale 10 pontos',
                    'Duração mínima de treino: 45 minutos',
                    'Período: 26/05/2024 a 15/06/2024'
                ]
            ),
            0, -- Inicialmente 0 participantes
            true,
            NULL, -- creator_id pode ser NULL para desafios oficiais
            true, -- is_official = true
            NOW(),
            NOW()
        );
        
        RAISE NOTICE 'Desafio Ray 21 criado com sucesso!';
    ELSE
        -- Se já existe, atualizar as informações
        UPDATE challenges SET
            description = 'Participe do Desafio Ray 21! Faça check-ins diários e ganhe pontos. Cada check-in vale 10 pontos. O desafio vai de 26 de maio a 15 de junho de 2024.',
            start_date = '2024-05-26 03:00:00+00'::timestamp with time zone,
            end_date = '2024-06-15 02:59:59+00'::timestamp with time zone,
            points = 10,
            requirements = jsonb_build_object(
                'points_per_checkin', 10,
                'min_duration_minutes', 45,
                'description', 'Desafio de check-ins diários',
                'rules', ARRAY[
                    'Faça check-ins diários para ganhar pontos',
                    'Cada check-in vale 10 pontos',
                    'Duração mínima de treino: 45 minutos',
                    'Período: 26/05/2024 a 15/06/2024'
                ]
            ),
            is_official = true,
            active = true,
            updated_at = NOW()
        WHERE title = 'Desafio Ray 21';
        
        RAISE NOTICE 'Desafio Ray 21 atualizado com sucesso!';
    END IF;
END
$$;

-- Verificar se o desafio foi inserido/atualizado corretamente
SELECT 
    id,
    title,
    description,
    start_date AT TIME ZONE 'America/Sao_Paulo' AS start_date_brasilia,
    end_date AT TIME ZONE 'America/Sao_Paulo' AS end_date_brasilia,
    points,
    requirements,
    is_official,
    active,
    created_at,
    updated_at
FROM challenges 
WHERE title = 'Desafio Ray 21';

-- Comentários sobre o script:
-- 1. O horário de início é 26/05/2024 00:00 no horário de Brasília (UTC-3)
-- 2. O horário de fim é 15/06/2024 23:59:59 no horário de Brasília (UTC-3)
-- 3. Cada check-in vale 10 pontos
-- 4. O desafio é marcado como oficial (is_official = true)
-- 5. Duração mínima de treino configurada para 45 minutos nos requirements
-- 6. Usa verificação condicional para evitar duplicatas
-- 7. Se o desafio já existe, apenas atualiza as informações 