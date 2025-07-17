-- ============================================================================
-- TESTE DA LÓGICA CENTRAL: record_workout_basic + process_workout_for_ranking
-- ============================================================================

-- Verificar se as funções centrais existem
SELECT 
    '🔧 VERIFICAÇÃO DAS FUNÇÕES CENTRAIS' as titulo,
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

-- Dados para teste
SELECT 
    '📋 DADOS PARA TESTE' as titulo,
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid as user_id,
    'Teste' as user_name,
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid as challenge_id,
    'Desafio Ray 21' as challenge_name;

-- ============================================================================
-- TESTE 1: TREINO CURTO (< 45min) - DUAS ETAPAS SEPARADAS
-- ============================================================================

SELECT '🧪 TESTE 1: Treino curto (30min) - ETAPA 1: Registrar treino' as teste_executando;

-- ETAPA 1: Registrar o treino (SEMPRE registra)
SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Teste Curto Separado',                         -- workout_name
    'Cardio',                                        -- workout_type
    30,                                              -- duration_minutes (< 45)
    NOW(),                                           -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- challenge_id
    'test-short-sep-' || extract(epoch from now())::text -- workout_id
) as resultado_registro_treino_curto;

-- Verificar se o treino foi registrado
SELECT '📝 VERIFICAÇÃO: Treino curto foi registrado?' as verificacao;

SELECT 
    wr.id,
    wr.workout_name,
    wr.duration_minutes || ' min' as duracao,
    'Registrado em workout_records' as status
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.workout_name = 'Teste Curto Separado'
AND wr.created_at > NOW() - INTERVAL '2 minutes';

-- ETAPA 2: Processar para ranking (deve FALHAR nas validações)
SELECT '🧪 TESTE 1: Treino curto (30min) - ETAPA 2: Processar para ranking' as teste_executando;

-- Pegar o ID do treino registrado para processar
WITH workout_id AS (
    SELECT wr.id
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.workout_name = 'Teste Curto Separado'
    AND wr.created_at > NOW() - INTERVAL '2 minutes'
    LIMIT 1
)
SELECT 
    w.id as workout_record_id,
    process_workout_for_ranking_one_per_day(w.id) as resultado_processamento
FROM workout_id w;

-- Verificar se NÃO gerou check-in
SELECT '❌ VERIFICAÇÃO: Treino curto NÃO deve gerar check-in' as verificacao;

SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cci.workout_name = 'Teste Curto Separado'
        )
        THEN '✅ CORRETO: Treino curto NÃO gerou check-in'
        ELSE '❌ ERRO: Treino curto GEROU check-in indevidamente'
    END as resultado_validacao;

-- ============================================================================
-- TESTE 2: TREINO VÁLIDO (>= 45min) - DUAS ETAPAS SEPARADAS
-- ============================================================================

SELECT '🧪 TESTE 2: Treino válido (60min) - ETAPA 1: Registrar treino' as teste_executando;

-- ETAPA 1: Registrar o treino (SEMPRE registra)
SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Teste Válido Separado',                        -- workout_name
    'CrossFit',                                      -- workout_type
    60,                                              -- duration_minutes (>= 45)
    NOW(),                                           -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- challenge_id
    'test-valid-sep-' || extract(epoch from now())::text -- workout_id
) as resultado_registro_treino_valido;

-- Verificar se o treino foi registrado
SELECT '📝 VERIFICAÇÃO: Treino válido foi registrado?' as verificacao;

SELECT 
    wr.id,
    wr.workout_name,
    wr.duration_minutes || ' min' as duracao,
    'Registrado em workout_records' as status
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.workout_name = 'Teste Válido Separado'
AND wr.created_at > NOW() - INTERVAL '2 minutes';

-- ETAPA 2: Processar para ranking (deve PASSAR nas validações)
SELECT '🧪 TESTE 2: Treino válido (60min) - ETAPA 2: Processar para ranking' as teste_executando;

-- Pegar o ID do treino registrado para processar
WITH workout_id AS (
    SELECT wr.id
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.workout_name = 'Teste Válido Separado'
    AND wr.created_at > NOW() - INTERVAL '2 minutes'
    LIMIT 1
)
SELECT 
    w.id as workout_record_id,
    process_workout_for_ranking_one_per_day(w.id) as resultado_processamento
FROM workout_id w;

-- Aguardar processamento
SELECT pg_sleep(1) as aguardando_processamento;

-- Verificar se GEROU check-in
SELECT '✅ VERIFICAÇÃO: Treino válido DEVE gerar check-in' as verificacao;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cci.workout_name = 'Teste Válido Separado'
            AND cci.points = 10
        )
        THEN '✅ CORRETO: Treino válido GEROU check-in com 10 pontos'
        ELSE '❌ ERRO: Treino válido NÃO gerou check-in'
    END as resultado_validacao;

-- ============================================================================
-- ANÁLISE DETALHADA DOS RESULTADOS
-- ============================================================================

SELECT '📊 ANÁLISE DETALHADA DOS RESULTADOS' as secao;

-- Todos os treinos registrados (independente de check-in)
SELECT '📝 TODOS OS TREINOS REGISTRADOS:' as subsecao;

SELECT 
    wr.workout_name,
    wr.duration_minutes || ' min' as duracao,
    'SIM' as tem_desafio,
    wr.created_at,
    'SEMPRE REGISTRADO' as observacao
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.workout_name IN ('Teste Curto Separado', 'Teste Válido Separado')
AND wr.created_at > NOW() - INTERVAL '10 minutes'
ORDER BY wr.created_at DESC;

-- Apenas os check-ins válidos (que passaram nas validações)
SELECT '✅ APENAS CHECK-INS VÁLIDOS:' as subsecao;

SELECT 
    cci.workout_name,
    cci.duration_minutes || ' min' as duracao,
    cci.points || ' pontos' as pontuacao,
    cci.created_at,
    'PASSOU NAS VALIDAÇÕES' as observacao
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND cci.workout_name IN ('Teste Curto Separado', 'Teste Válido Separado')
AND cci.created_at > NOW() - INTERVAL '10 minutes'
ORDER BY cci.created_at DESC;

-- Logs de erro (treinos que falharam nas validações)
SELECT '⚠️ LOGS DE VALIDAÇÃO:' as subsecao;

SELECT 
    cel.error_message,
    cel.status,
    cel.created_at,
    'FALHOU NAS VALIDAÇÕES' as observacao
FROM check_in_error_logs cel
WHERE cel.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cel.created_at > NOW() - INTERVAL '10 minutes'
ORDER BY cel.created_at DESC;

-- ============================================================================
-- VALIDAÇÃO FINAL DA LÓGICA SEPARADA
-- ============================================================================

SELECT '🎯 VALIDAÇÃO DA LÓGICA SEPARADA' as secao;

WITH contadores AS (
    SELECT 
        COUNT(*) FILTER (WHERE wr.workout_name IN ('Teste Curto Separado', 'Teste Válido Separado')) as treinos_registrados,
        COUNT(*) FILTER (WHERE cci.workout_name IN ('Teste Curto Separado', 'Teste Válido Separado')) as checkins_validos
    FROM workout_records wr
    FULL OUTER JOIN challenge_check_ins cci ON wr.user_id = cci.user_id
    WHERE (wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid OR cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid)
    AND (wr.created_at > NOW() - INTERVAL '10 minutes' OR cci.created_at > NOW() - INTERVAL '10 minutes')
)
SELECT 
    c.treinos_registrados || ' treinos registrados (record_workout_basic)' as etapa_1,
    c.checkins_validos || ' check-ins válidos (process_workout_for_ranking)' as etapa_2,
    CASE 
        WHEN c.treinos_registrados = 2 AND c.checkins_validos = 1
        THEN '✅ PERFEITO: 2 treinos registrados, 1 check-in válido'
        ELSE '❌ ERRO: Comportamento inesperado'
    END as resultado_final
FROM contadores c;

SELECT '🎯 TESTE DAS FUNÇÕES CENTRAIS CONCLUÍDO!' as status_final;

-- Resumo da lógica
SELECT '📋 RESUMO DA LÓGICA CENTRAL:' as resumo;

SELECT 
    'record_workout_basic()' as funcao,
    'SEMPRE registra o treino' as comportamento,
    'workout_records' as tabela_afetada,
    'Histórico completo' as finalidade

UNION ALL

SELECT 
    'process_workout_for_ranking_one_per_day()' as funcao,
    'SÓ cria check-in se passar validações' as comportamento,
    'challenge_check_ins + challenge_progress' as tabela_afetada,
    'Pontuação e ranking' as finalidade; 