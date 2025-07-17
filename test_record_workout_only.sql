-- ============================================================================
-- TESTE SIMPLES: record_workout_basic (SEM DEPENDÊNCIA DE OUTRAS FUNÇÕES)
-- ============================================================================

-- Verificar se record_workout_basic existe
SELECT 
    '🔧 VERIFICAÇÃO DA FUNÇÃO PRINCIPAL' as titulo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic')
        THEN '✅ record_workout_basic existe'
        ELSE '❌ record_workout_basic NÃO existe'
    END as status_funcao;

-- Dados para teste
SELECT 
    '📋 DADOS PARA TESTE' as titulo,
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid as user_id,
    'Teste' as user_name,
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid as challenge_id,
    'Desafio Ray 21' as challenge_name;

-- ============================================================================
-- TESTE 1: TREINO CURTO (30min) - DEVE SER REGISTRADO
-- ============================================================================

SELECT '🧪 TESTE 1: Registrando treino curto (30min)' as teste_executando;

SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Treino Curto Teste',                           -- workout_name
    'Cardio',                                        -- workout_type
    30,                                              -- duration_minutes (< 45)
    NOW(),                                           -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- challenge_id
    'test-curto-' || extract(epoch from now())::text -- workout_id
) as resultado_treino_curto;

-- ============================================================================
-- TESTE 2: TREINO VÁLIDO (60min) - DEVE SER REGISTRADO  
-- ============================================================================

SELECT '🧪 TESTE 2: Registrando treino válido (60min)' as teste_executando;

SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Treino Válido Teste',                          -- workout_name
    'CrossFit',                                      -- workout_type
    60,                                              -- duration_minutes (>= 45)
    NOW(),                                           -- date
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid,  -- challenge_id
    'test-valido-' || extract(epoch from now())::text -- workout_id
) as resultado_treino_valido;

-- ============================================================================
-- TESTE 3: TREINO SEM DESAFIO - DEVE SER REGISTRADO
-- ============================================================================

SELECT '🧪 TESTE 3: Registrando treino sem desafio (45min)' as teste_executando;

SELECT record_workout_basic(
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid,  -- user_id
    'Treino Sem Desafio',                           -- workout_name
    'Musculação',                                    -- workout_type
    45,                                              -- duration_minutes
    NOW(),                                           -- date
    NULL,                                            -- challenge_id (SEM DESAFIO)
    'test-sem-desafio-' || extract(epoch from now())::text -- workout_id
) as resultado_treino_sem_desafio;

-- Aguardar um momento para processamento
SELECT pg_sleep(1) as aguardando;

-- ============================================================================
-- VERIFICAR SE TODOS OS TREINOS FORAM REGISTRADOS
-- ============================================================================

SELECT '📊 VERIFICAÇÃO: TODOS OS TREINOS FORAM REGISTRADOS?' as titulo;

SELECT 
    wr.workout_name,
    wr.duration_minutes || ' min' as duracao,
    CASE 
        WHEN wr.challenge_id IS NOT NULL THEN 'SIM' 
        ELSE 'NÃO' 
    END as tem_desafio,
    wr.created_at,
    '✅ REGISTRADO' as status
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.workout_name IN ('Treino Curto Teste', 'Treino Válido Teste', 'Treino Sem Desafio')
AND wr.created_at > NOW() - INTERVAL '5 minutes'
ORDER BY wr.created_at DESC;

-- ============================================================================
-- VALIDAÇÃO PRINCIPAL: TODOS OS TREINOS DEVEM SER REGISTRADOS
-- ============================================================================

SELECT '🎯 VALIDAÇÃO PRINCIPAL' as titulo;

WITH contadores AS (
    SELECT COUNT(*) as total_treinos_registrados
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.workout_name IN ('Treino Curto Teste', 'Treino Válido Teste', 'Treino Sem Desafio')
    AND wr.created_at > NOW() - INTERVAL '5 minutes'
)
SELECT 
    c.total_treinos_registrados || ' treinos registrados de 3 testados' as resultado,
    CASE 
        WHEN c.total_treinos_registrados = 3
        THEN '✅ CORRETO: record_workout_basic registra TODOS os treinos'
        WHEN c.total_treinos_registrados > 0
        THEN '⚠️ PARCIAL: Alguns treinos foram registrados'
        ELSE '❌ ERRO: Nenhum treino foi registrado'
    END as validacao
FROM contadores c;

-- ============================================================================
-- VERIFICAR SE HOUVE PROCESSAMENTO AUTOMÁTICO PARA CHECK-INS
-- ============================================================================

SELECT '🔍 VERIFICAÇÃO: HOUVE PROCESSAMENTO AUTOMÁTICO?' as titulo;

-- Verificar se algum dos treinos gerou check-ins automaticamente
SELECT 
    'CHECK-INS GERADOS AUTOMATICAMENTE' as tipo,
    COUNT(*) as quantidade
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.workout_name IN ('Treino Curto Teste', 'Treino Válido Teste')
AND cci.created_at > NOW() - INTERVAL '5 minutes'

UNION ALL

-- Verificar se foram adicionados à fila de processamento
SELECT 
    'TREINOS NA FILA DE PROCESSAMENTO' as tipo,
    COUNT(*) as quantidade
FROM workout_processing_queue wpq
JOIN workout_records wr ON wr.id = wpq.workout_id
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.workout_name IN ('Treino Curto Teste', 'Treino Válido Teste')
AND wr.created_at > NOW() - INTERVAL '5 minutes';

-- ============================================================================
-- RESUMO FINAL
-- ============================================================================

SELECT '📋 RESUMO DO TESTE DE record_workout_basic' as titulo;

SELECT 
    'Função record_workout_basic()' as funcao_testada,
    'Registra TODOS os treinos independente de validações' as comportamento_esperado,
    'workout_records' as tabela_afetada,
    CASE 
        WHEN (SELECT COUNT(*) FROM workout_records wr
              WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
              AND wr.workout_name IN ('Treino Curto Teste', 'Treino Válido Teste', 'Treino Sem Desafio')
              AND wr.created_at > NOW() - INTERVAL '5 minutes') = 3
        THEN '✅ FUNCIONANDO CORRETAMENTE'
        ELSE '❌ COMPORTAMENTO INESPERADO'
    END as resultado_teste;

SELECT '🎯 TESTE DE record_workout_basic CONCLUÍDO!' as status_final; 