-- Substitua pelo seu ID de usuário
-- Você pode obter isso executando: SELECT id FROM auth.users WHERE email = 'seu_email@example.com';
-- Substitua 'seu_email@example.com' pelo seu email

-- Definir variáveis
\set challenge_id '61eb5cae-c2a8-42c6-9c4c-e86b7ff186b5'
\set user_id 'SUBSTITUA_PELO_SEU_ID_DE_USUARIO'

-- Adicionar o usuário como participante do desafio (se ainda não for)
INSERT INTO challenge_participants (challenge_id, user_id, created_at)
SELECT :'challenge_id', :'user_id', CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 
    FROM challenge_participants 
    WHERE challenge_id = :'challenge_id' AND user_id = :'user_id'
);

-- Criar progresso inicial (se ainda não existir)
INSERT INTO challenge_progress (challenge_id, user_id, points, completion_percentage, position, created_at)
SELECT :'challenge_id', :'user_id', 0, 0, 1, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 
    FROM challenge_progress 
    WHERE challenge_id = :'challenge_id' AND user_id = :'user_id'
);

-- Verificar se foi adicionado com sucesso
SELECT 
    cp.challenge_id,
    cp.user_id,
    cp.created_at AS participant_since,
    prog.points,
    prog.completion_percentage
FROM 
    challenge_participants cp
LEFT JOIN 
    challenge_progress prog ON cp.challenge_id = prog.challenge_id AND cp.user_id = prog.user_id
WHERE 
    cp.challenge_id = :'challenge_id' AND cp.user_id = :'user_id'; 