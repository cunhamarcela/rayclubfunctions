-- ============================================================================
-- TESTE DA INTERFACE DO APP: record_challenge_check_in_v2 (COM SELECT)
-- ============================================================================

-- Verificar se a função usada pelo app existe
SELECT 
    '🔧 VERIFICAÇÃO DA INTERFACE DO APP' as titulo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_challenge_check_in_v2')
        THEN '✅ record_challenge_check_in_v2 existe (usada pelo app)'
        ELSE '❌ record_challenge_check_in_v2 NÃO existe'
    END as interface_app;

-- Dados para teste
SELECT 
    '📋 DADOS PARA TESTE (INTERFACE APP)' as titulo,
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid as user_id,
    'Teste' as user_name,
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid as challenge_id,
    'Desafio Ray 21' as challenge_name;

-- ============================================================================
-- TESTES SIMULANDO CALLS DO FLUTTER APP
-- ============================================================================

-- TESTE 1: Check-in rápido (treino curto) - COMUM NO APP
SELECT '🧪 TESTE 1: Check-in rápido (30min) - NÃO deve pontuar' as teste_executando;

SELECT record_challenge_check_in_v2(
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- p_challenge_id
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- p_user_id  
    'quick-checkin-1',                               -- p_workout_id
    'Check-in Rápido',                              -- p_workout_name
    'Manual',                                        -- p_workout_type
    NOW(),                                           -- p_date
    30                                               -- p_duration_minutes (< 45)
) as resultado_checkin_rapido;

-- Aguardar processamento
SELECT pg_sleep(2) as aguardando_processamento_1;

-- TESTE 2: Check-in válido (treino longo) - DEVE PONTUAR
SELECT '🧪 TESTE 2: Check-in válido (60min) - DEVE pontuar' as teste_executando;

SELECT record_challenge_check_in_v2(
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- p_challenge_id
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- p_user_id
    'valid-checkin-1',                               -- p_workout_id
    'Treino Completo',                              -- p_workout_name
    'CrossFit',                                      -- p_workout_type
    NOW(),                                           -- p_date
    60                                               -- p_duration_minutes (>= 45)
) as resultado_checkin_valido;

-- Aguardar processamento
SELECT pg_sleep(2) as aguardando_processamento_2;

-- TESTE 3: Segundo check-in no mesmo dia - NÃO deve pontuar
SELECT '🧪 TESTE 3: Segundo check-in hoje (90min) - NÃO deve pontuar' as teste_executando;

SELECT record_challenge_check_in_v2(
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- p_challenge_id
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- p_user_id
    'second-checkin-1',                              -- p_workout_id
    'Segundo Treino',                               -- p_workout_name
    'Yoga',                                          -- p_workout_type
    NOW(),                                           -- p_date (mesmo dia)
    90                                               -- p_duration_minutes (>= 45)
) as resultado_segundo_checkin;

-- Aguardar processamento final
SELECT pg_sleep(2) as aguardando_processamento_3;

-- ============================================================================
-- VERIFICAÇÃO DETALHADA DOS RESULTADOS
-- ============================================================================

-- Comparar treinos registrados vs check-ins válidos
SELECT '📊 COMPARAÇÃO: TREINOS vs CHECK-INS' as secao;

SELECT 
    'TREINOS REGISTRADOS' as tipo,
    COUNT(*) as quantidade,
    STRING_AGG(wr.workout_name || ' (' || wr.duration_minutes || 'min)', ', ') as detalhes
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.created_at > NOW() - INTERVAL '5 minutes'
AND wr.workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')

UNION ALL

SELECT 
    'CHECK-INS VÁLIDOS' as tipo,
    COUNT(*) as quantidade,
    STRING_AGG(cci.workout_name || ' (' || cci.points || ' pts)', ', ') as detalhes
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND cci.created_at > NOW() - INTERVAL '5 minutes'
AND cci.workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino');

-- Detalhamento dos treinos registrados
SELECT '📝 DETALHES DOS TREINOS REGISTRADOS:' as secao;

SELECT 
    wr.workout_name,
    wr.duration_minutes || ' min' as duracao,
    'SIM' as tem_desafio,
    wr.created_at
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.created_at > NOW() - INTERVAL '5 minutes'
AND wr.workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
ORDER BY wr.created_at DESC;

-- Detalhamento dos check-ins válidos
SELECT '✅ DETALHES DOS CHECK-INS VÁLIDOS:' as secao;

SELECT 
    cci.workout_name,
    cci.duration_minutes || ' min' as duracao,
    cci.points || ' pontos' as pontuacao,
    cci.created_at
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND cci.created_at > NOW() - INTERVAL '5 minutes'
AND cci.workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
ORDER BY cci.created_at DESC;

-- Progresso atualizado no desafio
SELECT '🏆 PROGRESSO ATUALIZADO NO DESAFIO:' as secao;

SELECT 
    cp.user_name,
    cp.points || ' pontos' as pontos_totais,
    cp.check_ins_count || ' check-ins' as check_ins_validos,
    ROUND(cp.completion_percentage, 2) || '%' as percentual_conclusao,
    cp.position || 'º lugar' as posicao_ranking,
    cp.updated_at as ultima_atualizacao
FROM challenge_progress cp
WHERE cp.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid;

-- Logs de erros para os testes
SELECT '⚠️ LOGS DOS TESTES:' as secao;

SELECT 
    cel.error_message,
    cel.status,
    cel.created_at
FROM check_in_error_logs cel
WHERE cel.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cel.created_at > NOW() - INTERVAL '5 minutes'
ORDER BY cel.created_at DESC;

-- ============================================================================
-- VALIDAÇÃO FINAL DA LÓGICA
-- ============================================================================

SELECT '🎯 VALIDAÇÃO FINAL DA LÓGICA:' as secao;

WITH contadores AS (
    SELECT 
        COUNT(*) as total_treinos
    FROM workout_records 
    WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND created_at > NOW() - INTERVAL '5 minutes'
    AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
),
checkins AS (
    SELECT 
        COUNT(*) as total_checkins,
        COALESCE(SUM(points), 0) as total_pontos
    FROM challenge_check_ins 
    WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
    AND created_at > NOW() - INTERVAL '5 minutes'
    AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
)
SELECT 
    c.total_treinos || ' treinos registrados' as treinos,
    ch.total_checkins || ' check-ins válidos' as checkins,
    ch.total_pontos || ' pontos ganhos' as pontos,
    CASE 
        WHEN c.total_treinos > ch.total_checkins 
        THEN '✅ CORRETO: Nem todo treino registrado vira check-in com pontos'
        WHEN c.total_treinos = ch.total_checkins AND c.total_treinos > 0
        THEN '❌ ERRO: Todos os treinos viraram check-ins'
        ELSE '📝 SEM DADOS PARA VALIDAR'
    END as resultado_validacao
FROM contadores c, checkins ch;

-- Resumo esperado vs obtido
SELECT '📋 RESUMO ESPERADO vs OBTIDO:' as secao;

SELECT 
    'Check-in Rápido (30min)' as cenario,
    'Registrado SEM pontos' as esperado,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM workout_records 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND workout_name = 'Check-in Rápido'
            AND created_at > NOW() - INTERVAL '5 minutes'
        ) AND NOT EXISTS (
            SELECT 1 FROM challenge_check_ins 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND workout_name = 'Check-in Rápido'
            AND created_at > NOW() - INTERVAL '5 minutes'
        )
        THEN '✅ Registrado SEM pontos'
        ELSE '❌ Comportamento inesperado'
    END as obtido

UNION ALL

SELECT 
    'Treino Completo (60min)' as cenario,
    'Registrado COM 10 pontos' as esperado,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM workout_records 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND workout_name = 'Treino Completo'
            AND created_at > NOW() - INTERVAL '5 minutes'
        ) AND EXISTS (
            SELECT 1 FROM challenge_check_ins 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND workout_name = 'Treino Completo'
            AND points = 10
            AND created_at > NOW() - INTERVAL '5 minutes'
        )
        THEN '✅ Registrado COM 10 pontos'
        ELSE '❌ Comportamento inesperado'
    END as obtido

UNION ALL

SELECT 
    'Segundo Treino (90min)' as cenario,
    'Registrado SEM pontos (já fez check-in hoje)' as esperado,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM workout_records 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND workout_name = 'Segundo Treino'
            AND created_at > NOW() - INTERVAL '5 minutes'
        ) AND NOT EXISTS (
            SELECT 1 FROM challenge_check_ins 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND workout_name = 'Segundo Treino'
            AND created_at > NOW() - INTERVAL '5 minutes'
        )
        THEN '✅ Registrado SEM pontos (duplicata)'
        ELSE '❌ Comportamento inesperado'
    END as obtido;

SELECT '🎯 TESTE DA INTERFACE DO APP CONCLUÍDO!' as status_final; 