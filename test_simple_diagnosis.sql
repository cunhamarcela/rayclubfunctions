-- DIAGNÓSTICO SIMPLES: Por que não está criando check-ins?

-- 1. O usuário participa do desafio?
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_participants cp
            WHERE cp.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
        ) THEN '✅ Participa do desafio'
        ELSE '❌ NÃO participa do desafio - ESTA É A CAUSA!'
    END as participacao_status;

-- 2. O desafio está ativo?
SELECT 
    c.status,
    c.start_date,
    c.end_date,
    CASE 
        WHEN c.status = 'active' AND NOW() BETWEEN c.start_date AND c.end_date 
        THEN '✅ Desafio ativo'
        ELSE '❌ Desafio inativo - ESTA PODE SER A CAUSA!'
    END as desafio_status
FROM challenges c
WHERE c.id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid;

-- 3. SOLUÇÃO: Adicionar participação se necessário
INSERT INTO challenge_participants (user_id, challenge_id, joined_at) 
VALUES (
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid, 
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, 
    NOW()
) ON CONFLICT DO NOTHING;

SELECT 'Participação adicionada (se não existia)' as acao_executada;

-- 4. Testar novamente com um treino válido
SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Teste Final Válido',                           -- workout_name
    'CrossFit',                                     -- workout_type
    60,                                             -- duration_minutes (>= 45)
    NOW(),                                          -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, -- challenge_id
    'test-final-' || extract(epoch from now())::text -- workout_id
) as novo_treino_registrado;

-- 5. Processar para ranking
WITH ultimo_treino AS (
    SELECT wr.id
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.workout_name = 'Teste Final Válido'
    AND wr.created_at > NOW() - INTERVAL '2 minutes'
    LIMIT 1
)
SELECT 
    ut.id as workout_id,
    process_workout_for_ranking_one_per_day(ut.id) as resultado_processamento
FROM ultimo_treino ut;

-- 6. Verificar se agora criou check-in
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cci.workout_name = 'Teste Final Válido'
            AND cci.points = 10
        )
        THEN '✅ SUCESSO: Check-in criado com 10 pontos!'
        ELSE '❌ FALHA: Ainda não criou check-in'
    END as resultado_final; 