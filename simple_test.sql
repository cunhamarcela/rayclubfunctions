-- Teste simples das funções modificadas
-- Execute este script no seu ambiente de banco de dados

-- 1. Verificar se as funções existem
SELECT 'Verificando se as funções existem:' as test_info;

SELECT proname as function_name, pronargs as num_args
FROM pg_proc 
WHERE proname IN ('record_workout_basic', 'process_workout_for_ranking_one_per_day');

-- 2. Exemplo de como testar a função record_workout_basic
-- SUBSTITUA os UUIDs pelos valores reais do seu banco
/*
SELECT record_workout_basic(
    'seu-user-id-aqui'::UUID,      -- user_id
    'seu-challenge-id-aqui'::UUID, -- challenge_id  
    NULL,                          -- workout_record_id (será gerado)
    NULL,                          -- workout_id (será gerado)
    'Treino de Teste',             -- workout_name
    'Cardio',                      -- workout_type
    NOW(),                         -- date
    50,                            -- duration_minutes (>= 45)
    'Teste da função'              -- notes
);
*/

-- 3. Para testar, primeiro encontre IDs válidos:
SELECT 'IDs disponíveis para teste:' as test_info;

SELECT 'Usuários:' as type, id, name FROM profiles LIMIT 3
UNION ALL
SELECT 'Desafios:' as type, id, name FROM challenges WHERE end_date > NOW() LIMIT 3;

-- 4. Verificar participantes
SELECT 'Participantes em desafios ativos:' as test_info;
SELECT 
    p.name as user_name,
    c.name as challenge_name,
    cp.user_id,
    cp.challenge_id
FROM challenge_participants cp
JOIN profiles p ON p.id = cp.user_id  
JOIN challenges c ON c.id = cp.challenge_id
WHERE c.end_date > NOW()
LIMIT 5;

-- 5. Estado atual das tabelas (antes do teste)
SELECT 'Estado atual - workout_records:' as info;
SELECT COUNT(*) as total_workouts FROM workout_records;

SELECT 'Estado atual - challenge_check_ins:' as info;
SELECT COUNT(*) as total_checkins FROM challenge_check_ins;

SELECT 'Estado atual - challenge_progress:' as info;
SELECT COUNT(*) as total_progress FROM challenge_progress; 