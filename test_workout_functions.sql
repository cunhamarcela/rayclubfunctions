-- Script de teste para as funções de treino
-- Teste da função record_workout_basic e process_workout_for_ranking_one_per_day

-- 1. Primeiro, vamos verificar se existe algum usuário e desafio para testar
SELECT 'Verificando usuários existentes:' as test_step;
SELECT id, name FROM profiles LIMIT 3;

SELECT 'Verificando desafios existentes:' as test_step;
SELECT id, name, start_date, end_date FROM challenges 
WHERE end_date > NOW() 
LIMIT 3;

-- 2. Verificar participantes em desafios
SELECT 'Verificando participantes em desafios:' as test_step;
SELECT cp.challenge_id, cp.user_id, c.name as challenge_name, p.name as user_name
FROM challenge_participants cp
JOIN challenges c ON c.id = cp.challenge_id
JOIN profiles p ON p.id = cp.user_id
LIMIT 5;

-- 3. Teste da função record_workout_basic
-- (usando IDs reais se existirem)
SELECT 'Testando função record_workout_basic:' as test_step;

-- Primeiro vamos pegar um usuário e desafio válidos
DO $$
DECLARE
    test_user_id UUID;
    test_challenge_id UUID;
    test_result JSONB;
BEGIN
    -- Pegar primeiro usuário que participa de algum desafio
    SELECT cp.user_id, cp.challenge_id INTO test_user_id, test_challenge_id
    FROM challenge_participants cp
    JOIN challenges c ON c.id = cp.challenge_id
    WHERE c.end_date > NOW()
    LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_challenge_id IS NOT NULL THEN
        -- Testar função record_workout_basic
        SELECT record_workout_basic(
            test_user_id,
            test_challenge_id,
            NULL, -- workout_record_id (será gerado)
            NULL, -- workout_id (será gerado)
            'Treino de Teste',
            'Musculação',
            NOW(), -- data atual
            60, -- 60 minutos
            'Teste automatizado das funções'
        ) INTO test_result;
        
        RAISE NOTICE 'Resultado do teste record_workout_basic: %', test_result;
        
        -- Verificar se foi criado o workout_record
        IF (test_result->>'success')::boolean = true THEN
            RAISE NOTICE 'Workout ID criado: %', test_result->>'workout_id';
            
            -- Verificar registros criados
            RAISE NOTICE 'Verificando workout_records criado...';
            PERFORM id FROM workout_records WHERE id = (test_result->>'workout_id')::UUID;
            IF FOUND THEN
                RAISE NOTICE 'Workout record criado com sucesso!';
            ELSE
                RAISE NOTICE 'ERRO: Workout record não foi criado!';
            END IF;
            
            -- Verificar se foi criado check-in
            RAISE NOTICE 'Verificando challenge_check_ins...';
            PERFORM id FROM challenge_check_ins 
            WHERE workout_id = (test_result->>'workout_id')::UUID;
            IF FOUND THEN
                RAISE NOTICE 'Challenge check-in criado com sucesso!';
            ELSE
                RAISE NOTICE 'Challenge check-in não foi criado (pode ser normal se já existe para hoje)';
            END IF;
            
            -- Verificar se foi atualizado o progresso
            RAISE NOTICE 'Verificando challenge_progress...';
            PERFORM id FROM challenge_progress 
            WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
            IF FOUND THEN
                RAISE NOTICE 'Challenge progress atualizado com sucesso!';
            ELSE
                RAISE NOTICE 'Challenge progress não foi encontrado';
            END IF;
        ELSE
            RAISE NOTICE 'ERRO na função: %', test_result->>'message';
        END IF;
    ELSE
        RAISE NOTICE 'AVISO: Não foi possível encontrar usuário e desafio para teste';
        RAISE NOTICE 'Certifique-se de que existem usuários cadastrados e participando de desafios ativos';
    END IF;
END $$;

-- 4. Verificar resultados finais
SELECT 'Estado final das tabelas:' as test_step;

SELECT 'Últimos workout_records:' as info;
SELECT id, user_id, workout_name, duration_minutes, date, challenge_id, created_at
FROM workout_records 
ORDER BY created_at DESC 
LIMIT 3;

SELECT 'Últimos challenge_check_ins:' as info;
SELECT id, user_id, challenge_id, check_in_date, points, workout_name, duration_minutes
FROM challenge_check_ins 
ORDER BY created_at DESC 
LIMIT 3;

SELECT 'Challenge progress atual:' as info;
SELECT user_id, challenge_id, points, check_ins_count, completion_percentage, last_check_in
FROM challenge_progress 
ORDER BY last_updated DESC 
LIMIT 3; 