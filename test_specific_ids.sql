-- Teste específico com IDs fornecidos
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- Challenge ID: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- 1. Verificar se o usuário existe
SELECT 'Verificando usuário:' as step;
SELECT id, name, email FROM profiles 
WHERE id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 2. Verificar se o desafio existe e está ativo
SELECT 'Verificando desafio:' as step;
SELECT id, name, start_date, end_date, 
       CASE WHEN end_date > NOW() THEN 'ATIVO' ELSE 'INATIVO' END as status
FROM challenges 
WHERE id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 3. Verificar se o usuário participa do desafio
SELECT 'Verificando participação no desafio:' as step;
SELECT * FROM challenge_participants 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 4. Verificar check-ins existentes para hoje
SELECT 'Check-ins existentes para hoje:' as step;
SELECT id, check_in_date, points, workout_name, duration_minutes
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND DATE(check_in_date) = CURRENT_DATE;

-- 5. Estado atual do progresso
SELECT 'Progresso atual no desafio:' as step;
SELECT points, check_ins_count, total_check_ins, completion_percentage, last_check_in
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 6. TESTE DA FUNÇÃO record_workout_basic
SELECT 'TESTANDO FUNÇÃO record_workout_basic:' as step;

SELECT record_workout_basic(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
    'Treino de Teste Automatizado',                -- p_workout_name
    'Funcional',                                   -- p_workout_type
    60,                                            -- p_duration_minutes (>= 45)
    NOW(),                                         -- p_date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
    NULL,                                          -- p_workout_id (será gerado)
    'Teste das funções modificadas',               -- p_notes
    NULL                                           -- p_workout_record_id (será gerado)
) as result;

-- 7. Verificar resultados após o teste
SELECT 'RESULTADOS APÓS O TESTE:' as step;

-- Último workout_record criado
SELECT 'Último workout criado:' as info;
SELECT id, workout_name, workout_type, duration_minutes, date, challenge_id, created_at
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
ORDER BY created_at DESC 
LIMIT 1;

-- Check-ins de hoje
SELECT 'Check-ins de hoje:' as info;
SELECT id, check_in_date, points, workout_name, duration_minutes, created_at
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND DATE(check_in_date) = CURRENT_DATE
ORDER BY created_at DESC;

-- Progresso atualizado
SELECT 'Progresso após teste:' as info;
SELECT points, check_ins_count, total_check_ins, completion_percentage, 
       last_check_in, updated_at
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 8. Teste de duplicata (tentar registrar outro treino no mesmo dia)
SELECT 'TESTE DE DUPLICATA (deve falhar ou não criar check-in duplicado):' as step;

SELECT record_workout_basic(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
    'Segundo Treino do Dia',                       -- p_workout_name
    'Cardio',                                      -- p_workout_type
    50,                                            -- p_duration_minutes
    NOW(),                                         -- p_date (mesmo dia)
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
    NULL,                                          -- p_workout_id
    'Teste de duplicata - não deve criar novo check-in', -- p_notes
    NULL                                           -- p_workout_record_id
) as result_duplicata;

-- Verificar se foi criado apenas 1 check-in para hoje
SELECT 'Contagem de check-ins para hoje (deve ser 1):' as info;
SELECT COUNT(*) as checkins_hoje
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND DATE(check_in_date) = CURRENT_DATE; 