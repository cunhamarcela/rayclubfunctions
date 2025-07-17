-- ============================================================================
-- CORREÇÃO: Adicionar usuário ao desafio + Testar novamente
-- ============================================================================

SELECT '🔧 CORRIGINDO: Adicionando usuário ao desafio' as etapa;

-- 1. Adicionar participação no desafio
INSERT INTO challenge_participants (user_id, challenge_id, joined_at) 
VALUES (
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid, 
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, 
    NOW()
) ON CONFLICT DO NOTHING;

-- 2. Confirmar que a participação foi adicionada
SELECT 
    'Participação confirmada!' as status,
    cp.joined_at as data_inscricao
FROM challenge_participants cp
WHERE cp.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid;

SELECT '🧪 TESTANDO: Criando novo treino válido' as etapa;

-- 3. Criar um novo treino válido para testar
SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Teste Pós-Correção',                           -- workout_name
    'CrossFit',                                     -- workout_type
    60,                                             -- duration_minutes (>= 45)
    NOW(),                                          -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, -- challenge_id
    'test-pos-correcao-' || extract(epoch from now())::text -- workout_id
) as treino_criado;

-- Aguardar um momento
SELECT pg_sleep(1) as aguardando;

SELECT '⚡ PROCESSANDO: Executando função de ranking' as etapa;

-- 4. Processar o treino para ranking
WITH ultimo_treino AS (
    SELECT wr.id
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.workout_name = 'Teste Pós-Correção'
    AND wr.created_at > NOW() - INTERVAL '2 minutes'
    LIMIT 1
)
SELECT 
    'Processando treino ID: ' || ut.id as info,
    process_workout_for_ranking_one_per_day(ut.id) as resultado_processamento
FROM ultimo_treino ut;

-- 5. Verificar se todas as condições agora passam
SELECT '🔍 VERIFICAÇÃO: Todas as condições após correção' as etapa;

WITH treino_teste AS (
    SELECT wr.*
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.workout_name = 'Teste Pós-Correção'
    AND wr.created_at > NOW() - INTERVAL '5 minutes'
    LIMIT 1
)
SELECT 
    CASE 
        WHEN tt.duration_minutes >= 45 THEN '✅ Duração OK (' || tt.duration_minutes || 'min)'
        ELSE '❌ Duração insuficiente (' || tt.duration_minutes || 'min)'
    END as condicao_duracao,
    
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_participants cp 
            WHERE cp.user_id = tt.user_id 
            AND cp.challenge_id = tt.challenge_id
        ) THEN '✅ Participa do desafio'
        ELSE '❌ NÃO participa do desafio'
    END as condicao_participacao,
    
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenges c 
            WHERE c.id = tt.challenge_id 
            AND c.status = 'active'
            AND NOW() BETWEEN c.start_date AND c.end_date
        ) THEN '✅ Desafio ativo'
        ELSE '❌ Desafio inativo'
    END as condicao_desafio,
    
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = tt.user_id 
            AND cci.challenge_id = tt.challenge_id 
            AND DATE(cci.check_in_date) = DATE(tt.created_at)
            AND cci.workout_name != 'Teste Pós-Correção'  -- Ignorar o próprio
        ) THEN '✅ Sem check-in duplicado'
        ELSE '❌ Já existe check-in hoje'
    END as condicao_duplicata
    
FROM treino_teste tt;

-- 6. Verificar se o check-in foi criado
SELECT '✅ RESULTADO: Check-in foi criado?' as etapa;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cci.workout_name = 'Teste Pós-Correção'
            AND cci.points = 10
        )
        THEN '🎉 SUCESSO: Check-in criado com 10 pontos!'
        ELSE '❌ FALHA: Ainda não criou check-in'
    END as resultado_final;

-- 7. Mostrar todos os check-ins criados
SELECT '📊 TODOS OS CHECK-INS CRIADOS HOJE:' as etapa;

SELECT 
    cci.workout_name,
    cci.duration_minutes || ' min' as duracao,
    cci.points || ' pontos' as pontuacao,
    cci.created_at
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND DATE(cci.check_in_date) = CURRENT_DATE
ORDER BY cci.created_at DESC;

-- 8. Contadores finais
SELECT '🎯 CONTADORES FINAIS:' as etapa;

WITH contadores AS (
    SELECT 
        COUNT(*) FILTER (WHERE wr.created_at > NOW() - INTERVAL '1 hour') as treinos_registrados,
        COUNT(*) FILTER (WHERE cci.created_at > NOW() - INTERVAL '1 hour') as checkins_validos
    FROM workout_records wr
    FULL OUTER JOIN challenge_check_ins cci ON wr.user_id = cci.user_id
    WHERE (wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid OR cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid)
)
SELECT 
    c.treinos_registrados || ' treinos registrados (última hora)' as total_treinos,
    c.checkins_validos || ' check-ins válidos (última hora)' as total_checkins,
    CASE 
        WHEN c.checkins_validos > 0 
        THEN '🎉 SUCESSO: Sistema funcionando corretamente!'
        ELSE '❌ Ainda há problemas'
    END as status_sistema
FROM contadores c;

SELECT '🎉 TESTE COMPLETO CONCLUÍDO!' as final; 