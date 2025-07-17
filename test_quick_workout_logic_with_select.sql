-- ============================================================================
-- TESTE RÁPIDO: DIFERENÇA ENTRE REGISTRO DE TREINO E CHECK-IN (COM SELECT)
-- ============================================================================

-- Verificar se as funções existem
SELECT 
    '🔧 VERIFICAÇÃO DE FUNÇÕES' as titulo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic')
        THEN '✅ record_workout_basic existe'
        ELSE '❌ record_workout_basic NÃO existe'
    END as func_registro,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'process_workout_for_ranking_one_per_day')
        THEN '✅ process_workout_for_ranking_one_per_day existe'
        ELSE '❌ process_workout_for_ranking_one_per_day NÃO existe'
    END as func_ranking;

-- Dados para teste (fornecidos pelo usuário)
SELECT 
    '📋 DADOS PARA TESTE' as titulo,
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid as user_id,
    'Teste' as user_name,
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid as challenge_id,
    'Desafio Ray 21' as challenge_name;

-- Verificar se o usuário participa do desafio
SELECT 
    '👥 VERIFICAÇÃO DE PARTICIPAÇÃO' as titulo,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_participants 
            WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid 
            AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
        )
        THEN '✅ Usuário participa do desafio'
        ELSE '❌ Usuário NÃO participa do desafio'
    END as status_participacao;

-- ============================================================================
-- CENÁRIOS DE TESTE
-- ============================================================================

-- TESTE 1: Treino curto (< 45min) - DEVE SER REGISTRADO MAS SEM PONTOS
SELECT '🧪 TESTE 1: Treino curto (30min) - NÃO deve pontuar' as teste_executando;

SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Teste Curto',                                   -- workout_name
    'Cardio',                                        -- workout_type
    30,                                              -- duration_minutes (< 45)
    NOW(),                                           -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- challenge_id
    'test-short-' || extract(epoch from now())::text -- workout_id
) as resultado_treino_curto;

-- Aguardar processamento
SELECT pg_sleep(2) as aguardando_processamento;

-- TESTE 2: Treino válido (>= 45min) - DEVE SER REGISTRADO E PONTUAR
SELECT '🧪 TESTE 2: Treino válido (60min) - DEVE pontuar' as teste_executando;

SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Teste Válido',                                  -- workout_name
    'CrossFit',                                      -- workout_type
    60,                                              -- duration_minutes (>= 45)
    NOW(),                                           -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- challenge_id
    'test-valid-' || extract(epoch from now())::text -- workout_id
) as resultado_treino_valido;

-- Aguardar processamento
SELECT pg_sleep(2) as aguardando_processamento_2;

-- ============================================================================
-- VERIFICAR RESULTADOS
-- ============================================================================

-- Treinos registrados nos últimos 5 minutos
SELECT '📝 TREINOS REGISTRADOS (últimos 5 min):' as secao;

SELECT 
    wr.workout_name,
    wr.duration_minutes || ' min' as duracao,
    CASE WHEN wr.challenge_id IS NOT NULL THEN 'SIM' ELSE 'NÃO' END as tem_desafio,
    wr.created_at,
    'Teste' as usuario
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.created_at > NOW() - INTERVAL '5 minutes'
AND wr.workout_name LIKE 'Teste %'
ORDER BY wr.created_at DESC;

-- Check-ins válidos nos últimos 5 minutos
SELECT '✅ CHECK-INS VÁLIDOS (últimos 5 min):' as secao;

SELECT 
    cci.workout_name,
    cci.duration_minutes || ' min' as duracao,
    cci.points || ' pontos' as pontuacao,
    cci.created_at,
    cci.user_name
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND cci.created_at > NOW() - INTERVAL '5 minutes'
AND cci.workout_name LIKE 'Teste %'
ORDER BY cci.created_at DESC;

-- Progresso atual no desafio
SELECT '🏆 PROGRESSO NO DESAFIO:' as secao;

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

-- Logs de erros recentes
SELECT '⚠️ LOGS DE ERROS (últimos 5 min):' as secao;

SELECT 
    cel.error_message,
    cel.status,
    cel.created_at
FROM check_in_error_logs cel
WHERE cel.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cel.created_at > NOW() - INTERVAL '5 minutes'
ORDER BY cel.created_at DESC;

-- ============================================================================
-- ANÁLISE DOS RESULTADOS
-- ============================================================================

SELECT '📊 ANÁLISE DOS RESULTADOS:' as secao;

WITH contadores AS (
    SELECT 
        COUNT(*) FILTER (WHERE wr.workout_name LIKE 'Teste %' AND wr.created_at > NOW() - INTERVAL '5 minutes') as treinos_registrados,
        COUNT(*) FILTER (WHERE cci.workout_name LIKE 'Teste %' AND cci.created_at > NOW() - INTERVAL '5 minutes') as checkins_validos,
        COALESCE(SUM(cci.points) FILTER (WHERE cci.workout_name LIKE 'Teste %' AND cci.created_at > NOW() - INTERVAL '5 minutes'), 0) as pontos_ganhos
    FROM workout_records wr
    FULL OUTER JOIN challenge_check_ins cci ON wr.user_id = cci.user_id
    WHERE (wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid OR cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid)
)
SELECT 
    c.treinos_registrados || ' treinos registrados' as total_treinos,
    c.checkins_validos || ' check-ins válidos' as total_checkins,
    c.pontos_ganhos || ' pontos ganhos' as total_pontos,
    CASE 
        WHEN c.treinos_registrados > c.checkins_validos 
        THEN '✅ CORRETO: Nem todo treino vira check-in'
        WHEN c.treinos_registrados = c.checkins_validos AND c.treinos_registrados > 0
        THEN '⚠️ ATENÇÃO: Todos os treinos viraram check-ins'
        ELSE '📝 SEM DADOS SUFICIENTES PARA VALIDAR'
    END as validacao_logica
FROM contadores c;

-- Validações específicas
SELECT '🔍 VALIDAÇÕES ESPECÍFICAS:' as secao;

SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Teste Curto' 
            AND wr.duration_minutes = 30
            AND wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
        )
        THEN '✅ CORRETO: Treino < 45min NÃO gerou check-in'
        ELSE '❌ ERRO: Treino < 45min GEROU check-in indevidamente'
    END as teste_duracao_minima;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Teste Válido' 
            AND cci.points = 10
            AND wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
        )
        THEN '✅ CORRETO: Treino válido GEROU check-in com 10 pontos'
        ELSE '❌ ERRO: Treino válido NÃO gerou check-in'
    END as teste_treino_valido;

SELECT '🎯 TESTE CONCLUÍDO!' as status_final; 