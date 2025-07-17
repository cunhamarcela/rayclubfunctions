-- ============================================================================
-- TESTE DA INTERFACE DO APP: record_challenge_check_in_v2
-- ============================================================================

-- Verificar se a função usada pelo app existe
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_challenge_check_in_v2')
        THEN '✅ Função record_challenge_check_in_v2 existe (usada pelo app)'
        ELSE '❌ Função record_challenge_check_in_v2 NÃO existe'
    END as interface_app;

-- ============================================================================
-- TESTE SIMULANDO CALLS DO FLUTTER APP
-- ============================================================================

DO $$
DECLARE
    v_user_id UUID;
    v_challenge_id UUID;
    v_result JSONB;
    v_today DATE := CURRENT_DATE;
BEGIN
    -- Usar usuário e desafio existentes
    SELECT id INTO v_user_id FROM profiles LIMIT 1;
    SELECT id INTO v_challenge_id FROM challenges WHERE end_date > NOW() LIMIT 1;
    
    IF v_user_id IS NULL OR v_challenge_id IS NULL THEN
        RAISE NOTICE '❌ Dados de teste insuficientes (usuário ou desafio)';
        RETURN;
    END IF;
    
    RAISE NOTICE '🧪 SIMULANDO CALLS DO APP FLUTTER';
    RAISE NOTICE 'Usuário: %, Desafio: %', v_user_id, v_challenge_id;
    RAISE NOTICE '---';
    
    -- TESTE 1: Check-in rápido (treino curto) - COMUM NO APP
    RAISE NOTICE '🧪 TESTE 1: Check-in rápido (30min) - NÃO deve pontuar';
    
    SELECT record_challenge_check_in_v2(
        v_challenge_id,      -- p_challenge_id
        v_user_id,           -- p_user_id  
        'quick-checkin-1',   -- p_workout_id
        'Check-in Rápido',   -- p_workout_name
        'Manual',            -- p_workout_type
        NOW(),               -- p_date
        30                   -- p_duration_minutes (< 45)
    ) INTO v_result;
    
    RAISE NOTICE 'Resultado: %', v_result;
    RAISE NOTICE 'Sucesso: %, Pontos: %', 
        (v_result->>'success')::boolean,
        COALESCE((v_result->>'points_earned')::integer, 0);
    
    -- TESTE 2: Check-in válido (treino longo) - DEVE PONTUAR
    RAISE NOTICE '---';
    RAISE NOTICE '🧪 TESTE 2: Check-in válido (60min) - DEVE pontuar';
    
    SELECT record_challenge_check_in_v2(
        v_challenge_id,      -- p_challenge_id
        v_user_id,           -- p_user_id
        'valid-checkin-1',   -- p_workout_id
        'Treino Completo',   -- p_workout_name
        'CrossFit',          -- p_workout_type
        NOW(),               -- p_date
        60                   -- p_duration_minutes (>= 45)
    ) INTO v_result;
    
    RAISE NOTICE 'Resultado: %', v_result;
    RAISE NOTICE 'Sucesso: %, Pontos: %', 
        (v_result->>'success')::boolean,
        COALESCE((v_result->>'points_earned')::integer, 0);
    
    -- TESTE 3: Segundo check-in no mesmo dia - NÃO deve pontuar
    RAISE NOTICE '---';
    RAISE NOTICE '🧪 TESTE 3: Segundo check-in hoje (90min) - NÃO deve pontuar';
    
    SELECT record_challenge_check_in_v2(
        v_challenge_id,      -- p_challenge_id
        v_user_id,           -- p_user_id
        'second-checkin-1',  -- p_workout_id
        'Segundo Treino',    -- p_workout_name
        'Yoga',              -- p_workout_type
        NOW(),               -- p_date (mesmo dia)
        90                   -- p_duration_minutes (>= 45)
    ) INTO v_result;
    
    RAISE NOTICE 'Resultado: %', v_result;
    RAISE NOTICE 'Sucesso: %, Já fez check-in: %', 
        (v_result->>'success')::boolean,
        COALESCE((v_result->>'is_already_checked_in')::boolean, false);
    
    -- Aguardar processamento
    PERFORM pg_sleep(1);
    
    -- RELATÓRIO FINAL
    RAISE NOTICE '---';
    RAISE NOTICE '📊 RELATÓRIO FINAL:';
    RAISE NOTICE 'Total de treinos registrados hoje: %', (
        SELECT COUNT(*) FROM workout_records 
        WHERE user_id = v_user_id 
        AND DATE(created_at AT TIME ZONE 'America/Sao_Paulo') = v_today
        AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
    );
    
    RAISE NOTICE 'Total de check-ins válidos hoje: %', (
        SELECT COUNT(*) FROM challenge_check_ins 
        WHERE user_id = v_user_id 
        AND challenge_id = v_challenge_id
        AND DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') = v_today
        AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
    );
    
    RAISE NOTICE 'Total de pontos ganhos hoje: %', (
        COALESCE((
            SELECT SUM(points) FROM challenge_check_ins 
            WHERE user_id = v_user_id 
            AND challenge_id = v_challenge_id
            AND DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') = v_today
            AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
        ), 0)
    );
    
END $$;

-- ============================================================================
-- VERIFICAÇÃO DETALHADA DOS RESULTADOS
-- ============================================================================

-- Comparar treinos registrados vs check-ins válidos
WITH dados_teste AS (
    SELECT 
        'TREINOS REGISTRADOS' as tipo,
        COUNT(*) as quantidade,
        STRING_AGG(wr.workout_name || ' (' || wr.duration_minutes || 'min)', ', ') as detalhes
    FROM workout_records wr
    WHERE wr.created_at > NOW() - INTERVAL '5 minutes'
    AND wr.workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
    
    UNION ALL
    
    SELECT 
        'CHECK-INS VÁLIDOS' as tipo,
        COUNT(*) as quantidade,
        STRING_AGG(cci.workout_name || ' (' || cci.points || ' pts)', ', ') as detalhes
    FROM challenge_check_ins cci
    WHERE cci.created_at > NOW() - INTERVAL '5 minutes'
    AND cci.workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
)
SELECT * FROM dados_teste;

-- Logs de erros para os testes
SELECT 
    '⚠️ LOGS DOS TESTES:' as titulo,
    cel.error_message,
    cel.status
FROM check_in_error_logs cel
WHERE cel.created_at > NOW() - INTERVAL '5 minutes'
ORDER BY cel.created_at DESC;

-- Resumo da lógica validada
SELECT 
    '🎯 VALIDAÇÃO DA LÓGICA:' as titulo,
    CASE 
        WHEN (
            SELECT COUNT(*) FROM workout_records 
            WHERE created_at > NOW() - INTERVAL '5 minutes'
            AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
        ) > (
            SELECT COUNT(*) FROM challenge_check_ins 
            WHERE created_at > NOW() - INTERVAL '5 minutes'
            AND workout_name IN ('Check-in Rápido', 'Treino Completo', 'Segundo Treino')
        )
        THEN '✅ CORRETO: Nem todo treino registrado vira check-in com pontos'
        ELSE '❌ ERRO: Todos os treinos viraram check-ins'
    END as resultado; 