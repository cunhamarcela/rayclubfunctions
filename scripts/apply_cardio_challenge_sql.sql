-- Ray Club — Script para aplicar todas as funções do desafio de cardio
-- Executa em ordem: tabela de participantes -> funções -> ranking

-- 1. Criar tabela de participantes e funções básicas
\i sql/cardio_challenge_participants.sql

-- 2. Criar função de ranking
\i sql/get_cardio_ranking.sql

-- 3. Verificar se as funções foram criadas
SELECT 
  routine_name, 
  routine_type,
  specific_name
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('join_cardio_challenge', 'leave_cardio_challenge', 'get_cardio_participation', 'get_cardio_ranking')
ORDER BY routine_name;

-- 4. Verificar se a tabela foi criada
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'cardio_challenge_participants'
ORDER BY ordinal_position;
