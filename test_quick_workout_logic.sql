-- ============================================================================
-- TESTE RÁPIDO: DIFERENÇA ENTRE REGISTRO DE TREINO E CHECK-IN
-- ============================================================================

-- Verificar se as funções existem
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic')
        THEN '✅ Função record_workout_basic existe'
        ELSE '❌ Função record_workout_basic NÃO existe'
    END as func_registro,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'process_workout_for_ranking')
        THEN '✅ Função process_workout_for_ranking existe'
        ELSE '❌ Função process_workout_for_ranking NÃO existe'
    END as func_ranking;

-- Teste com um usuário existente (usar o primeiro usuário encontrado)
WITH usuario_teste AS (
    SELECT id, name FROM profiles LIMIT 1
),
desafio_teste AS (
    SELECT id, title FROM challenges 
    WHERE end_date > NOW() 
    LIMIT 1
)
SELECT 
    u.id as user_id,
    u.name as user_name,
    d.id as challenge_id,
    d.title as challenge_name
FROM usuario_teste u, desafio_teste d;

-- ============================================================================
-- CENÁRIO TESTE SIMPLES
-- ============================================================================

DO $$
DECLARE
    v_user_id UUID;
    v_challenge_id UUID;
    v_result JSONB;
BEGIN
    -- Pegar primeiro usuário e desafio
    SELECT id INTO v_user_id FROM profiles LIMIT 1;
    SELECT id INTO v_challenge_id FROM challenges WHERE end_date > NOW() LIMIT 1;
    
    IF v_user_id IS NULL THEN
        RAISE NOTICE '❌ Nenhum usuário encontrado para teste';
        RETURN;
    END IF;
    
    IF v_challenge_id IS NULL THEN
        RAISE NOTICE '❌ Nenhum desafio ativo encontrado para teste';
        RETURN;
    END IF;
    
    RAISE NOTICE '🧪 Testando com usuário: % e desafio: %', v_user_id, v_challenge_id;
    
    -- TESTE 1: Treino curto (< 45min)
    RAISE NOTICE '--- TESTE 1: Treino curto (30min) ---';
    
    SELECT record_workout_basic(
        v_user_id,
        'Teste Curto',
        'Cardio',
        30, -- < 45min
        NOW(),
        v_challenge_id,
        'test-short-' || extract(epoch from now())::text
    ) INTO v_result;
    
    RAISE NOTICE 'Resultado treino curto: %', v_result;
    
    -- TESTE 2: Treino válido (>= 45min)
    RAISE NOTICE '--- TESTE 2: Treino válido (60min) ---';
    
    SELECT record_workout_basic(
        v_user_id,
        'Teste Válido',
        'CrossFit',
        60, -- >= 45min
        NOW(),
        v_challenge_id,
        'test-valid-' || extract(epoch from now())::text
    ) INTO v_result;
    
    RAISE NOTICE 'Resultado treino válido: %', v_result;
    
    -- Aguardar processamento
    PERFORM pg_sleep(1);
    
    -- Verificar resultados
    RAISE NOTICE '--- RESULTADOS ---';
    RAISE NOTICE 'Treinos registrados: %', (
        SELECT COUNT(*) FROM workout_records 
        WHERE user_id = v_user_id 
        AND workout_name LIKE 'Teste %'
        AND created_at > NOW() - INTERVAL '5 minutes'
    );
    
    RAISE NOTICE 'Check-ins criados: %', (
        SELECT COUNT(*) FROM challenge_check_ins 
        WHERE user_id = v_user_id 
        AND workout_name LIKE 'Teste %'
        AND created_at > NOW() - INTERVAL '5 minutes'
    );
    
    RAISE NOTICE 'Pontos ganhos: %', (
        COALESCE((
            SELECT SUM(points) FROM challenge_check_ins 
            WHERE user_id = v_user_id 
            AND workout_name LIKE 'Teste %'
            AND created_at > NOW() - INTERVAL '5 minutes'
        ), 0)
    );
    
END $$;

-- ============================================================================
-- CONSULTAS DE VERIFICAÇÃO RÁPIDA
-- ============================================================================

-- Últimos treinos registrados
SELECT '📝 ÚLTIMOS TREINOS REGISTRADOS:' as titulo;

SELECT 
    wr.workout_name,
    wr.duration_minutes,
    CASE WHEN wr.challenge_id IS NOT NULL THEN 'SIM' ELSE 'NÃO' END as tem_desafio,
    wr.created_at,
    p.name as usuario
FROM workout_records wr
JOIN profiles p ON p.id = wr.user_id
WHERE wr.created_at > NOW() - INTERVAL '10 minutes'
ORDER BY wr.created_at DESC
LIMIT 10;

-- Últimos check-ins válidos
SELECT '✅ ÚLTIMOS CHECK-INS VÁLIDOS:' as titulo;

SELECT 
    cci.workout_name,
    cci.duration_minutes,
    cci.points,
    cci.created_at,
    cci.user_name
FROM challenge_check_ins cci
WHERE cci.created_at > NOW() - INTERVAL '10 minutes'
ORDER BY cci.created_at DESC
LIMIT 10;

-- Logs de erros recentes
SELECT '⚠️ LOGS DE ERROS RECENTES:' as titulo;

SELECT 
    cel.error_message,
    cel.status,
    cel.created_at
FROM check_in_error_logs cel
WHERE cel.created_at > NOW() - INTERVAL '10 minutes'
ORDER BY cel.created_at DESC
LIMIT 10; 