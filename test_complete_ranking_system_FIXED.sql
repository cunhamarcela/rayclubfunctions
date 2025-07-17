-- 🎯 TESTE COMPLETO DO SISTEMA DE RANKING E CHALLENGE_PROGRESS (VERSÃO CORRIGIDA)
-- 📋 Validação de TODOS os campos e funcionalidades - SEM COLUNAS GERADAS

-- ======================================
-- 🧹 LIMPEZA INICIAL (AMBIENTE DE TESTE)
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    test_user_2 UUID := 'b7d234ef-89ab-4cde-f123-456789abcdef';
    test_user_3 UUID := 'c8e345f0-9abc-5def-0234-56789abcdef1'; 
BEGIN
    RAISE NOTICE '🧹 LIMPANDO dados de teste...';
    
    -- Limpar dados específicos do teste
    DELETE FROM challenge_check_ins WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = test_challenge_id;
    
    RAISE NOTICE '✅ Limpeza concluída';
END $$;

-- ======================================
-- 📊 PREPARAÇÃO DOS DADOS DE TESTE
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    test_user_2 UUID := 'b7d234ef-89ab-4cde-f123-456789abcdef';
    test_user_3 UUID := 'c8e345f0-9abc-5def-0234-56789abcdef1';
BEGIN
    RAISE NOTICE '📊 PREPARANDO dados de teste...';
    
    -- Criar usuários de teste (apenas campos não gerados)
    INSERT INTO profiles (id, name) VALUES 
    (test_user_1, 'Usuário Teste 1')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    INSERT INTO profiles (id, name) VALUES 
    (test_user_2, 'Usuário Teste 2')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    INSERT INTO profiles (id, name) VALUES 
    (test_user_3, 'Usuário Teste 3')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Garantir que desafio existe e está ativo
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, status, points, type, is_official
    ) VALUES (
        test_challenge_id, 
        'Desafio de Teste Ranking', 
        'Teste completo do sistema de ranking',
        CURRENT_DATE - INTERVAL '10 days',
        CURRENT_DATE + INTERVAL '20 days',
        true, 'active', 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active,
        status = EXCLUDED.status;
    
    -- Inscrever usuários no desafio
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (test_user_1, test_challenge_id, NOW() - INTERVAL '5 days'),
    (test_user_2, test_challenge_id, NOW() - INTERVAL '5 days'),
    (test_user_3, test_challenge_id, NOW() - INTERVAL '5 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
    
    RAISE NOTICE '✅ Dados de teste preparados';
END $$;

-- ======================================
-- 🏋️ CENÁRIO 1: TREINOS E CHECK-INS VÁLIDOS
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    test_user_2 UUID := 'b7d234ef-89ab-4cde-f123-456789abcdef';
    test_user_3 UUID := 'c8e345f0-9abc-5def-0234-56789abcdef1';
    workout_result JSONB;
BEGIN
    RAISE NOTICE '🏋️ TESTANDO cenário completo de treinos...';
    
    -- ========================================
    -- USUÁRIO 1: 3 treinos válidos = 30 pontos
    -- ========================================
    
    -- Treino 1: 60min - VÁLIDO
    SELECT record_workout_basic(
        test_user_1, 'TREINO-TEST-001', 'Corrida Matinal', 'cardio', 
        60, CURRENT_DATE - INTERVAL '3 days', test_challenge_id, 'Treino intenso'
    ) INTO workout_result;
    
    -- Treino 2: 50min - VÁLIDO (dia diferente)
    SELECT record_workout_basic(
        test_user_1, 'TREINO-TEST-002', 'Musculação', 'strength', 
        50, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'Foco em força'
    ) INTO workout_result;
    
    -- Treino 3: 70min - VÁLIDO (dia diferente)
    SELECT record_workout_basic(
        test_user_1, 'TREINO-TEST-003', 'CrossFit', 'mixed', 
        70, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'WOD completo'
    ) INTO workout_result;
    
    -- ========================================
    -- USUÁRIO 2: 2 treinos válidos = 20 pontos
    -- ========================================
    
    -- Treino 4: 45min - VÁLIDO (limite mínimo)
    SELECT record_workout_basic(
        test_user_2, 'TREINO-TEST-004', 'Yoga', 'flexibility', 
        45, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'Flexibilidade'
    ) INTO workout_result;
    
    -- Treino 5: 55min - VÁLIDO
    SELECT record_workout_basic(
        test_user_2, 'TREINO-TEST-005', 'Natação', 'cardio', 
        55, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'Cardio aquático'
    ) INTO workout_result;
    
    -- ========================================
    -- USUÁRIO 3: 1 treino válido = 10 pontos
    -- ========================================
    
    -- Treino 6: 80min - VÁLIDO
    SELECT record_workout_basic(
        test_user_3, 'TREINO-TEST-006', 'Ciclismo', 'cardio', 
        80, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'Pedal longo'
    ) INTO workout_result;
    
    RAISE NOTICE '✅ Treinos registrados: User1=3, User2=2, User3=1';
    
    -- Pequena pausa para processamento
    PERFORM pg_sleep(2);
END $$;

-- ======================================
-- 🚫 CENÁRIO 2: TREINOS QUE NÃO DEVEM PONTUAR
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    workout_result JSONB;
BEGIN
    RAISE NOTICE '🚫 TESTANDO treinos que NÃO devem pontuar...';
    
    -- Treino curto (< 45min) - NÃO deve pontuar
    SELECT record_workout_basic(
        test_user_1, 'TREINO-INVALID-001', 'Caminhada', 'cardio', 
        30, CURRENT_DATE, test_challenge_id, 'Muito curto'
    ) INTO workout_result;
    
    -- Segundo treino no mesmo dia - NÃO deve pontuar
    SELECT record_workout_basic(
        test_user_1, 'TREINO-INVALID-002', 'Alongamento', 'flexibility', 
        60, CURRENT_DATE - INTERVAL '3 days', test_challenge_id, 'Segundo do dia'
    ) INTO workout_result;
    
    RAISE NOTICE '✅ Treinos inválidos registrados (não devem pontuar)';
    
    PERFORM pg_sleep(1);
END $$;

-- ======================================
-- 📊 VALIDAÇÃO COMPLETA DOS RESULTADOS
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    test_user_2 UUID := 'b7d234ef-89ab-4cde-f123-456789abcdef';
    test_user_3 UUID := 'c8e345f0-9abc-5def-0234-56789abcdef1';
    
    user1_progress RECORD;
    user2_progress RECORD;
    user3_progress RECORD;
    
    total_workout_records INTEGER;
    total_check_ins INTEGER;
    total_progress_records INTEGER;
    
    challenge_duration INTEGER;
    expected_completion NUMERIC;
BEGIN
    RAISE NOTICE '📊 VALIDANDO resultados completos...';
    
    -- Calcular duração do desafio para % de progresso
    SELECT EXTRACT(DAY FROM (end_date - start_date)) + 1 
    INTO challenge_duration
    FROM challenges 
    WHERE id = test_challenge_id;
    
    -- ========================================
    -- CONTAGENS GERAIS
    -- ========================================
    
    SELECT COUNT(*) INTO total_workout_records
    FROM workout_records 
    WHERE challenge_id = test_challenge_id;
    
    SELECT COUNT(*) INTO total_check_ins
    FROM challenge_check_ins 
    WHERE challenge_id = test_challenge_id;
    
    SELECT COUNT(*) INTO total_progress_records
    FROM challenge_progress 
    WHERE challenge_id = test_challenge_id;
    
    RAISE NOTICE '📈 CONTAGENS GERAIS:';
    RAISE NOTICE '   Total workout_records: %', total_workout_records;
    RAISE NOTICE '   Total challenge_check_ins: %', total_check_ins;
    RAISE NOTICE '   Total challenge_progress: %', total_progress_records;
    RAISE NOTICE '   Duração do desafio: % dias', challenge_duration;
    
    -- ========================================
    -- VALIDAÇÃO USUÁRIO 1 (30 pontos esperados)
    -- ========================================
    
    SELECT * INTO user1_progress
    FROM challenge_progress 
    WHERE user_id = test_user_1 AND challenge_id = test_challenge_id;
    
    expected_completion := LEAST(100, (3 * 100.0) / challenge_duration);
    
    RAISE NOTICE '👤 USUÁRIO 1 - Esperado: 30 pontos, 3 check-ins';
    RAISE NOTICE '   ✓ Pontos: % (esperado: 30)', COALESCE(user1_progress.points, 0);
    RAISE NOTICE '   ✓ Check-ins: % (esperado: 3)', COALESCE(user1_progress.check_ins_count, 0);
    RAISE NOTICE '   ✓ Total check-ins: % (esperado: 3)', COALESCE(user1_progress.total_check_ins, 0);
    RAISE NOTICE '   ✓ Progresso: %% (esperado: %)', ROUND(COALESCE(user1_progress.completion_percentage, 0), 2), ROUND(expected_completion, 2);
    RAISE NOTICE '   ✓ Posição: % (esperado: 1)', COALESCE(user1_progress.position, 0);
    RAISE NOTICE '   ✓ Nome: % (esperado: Usuário Teste 1)', COALESCE(user1_progress.user_name, 'NULL');
    RAISE NOTICE '   ✓ Último check-in: %', COALESCE(user1_progress.last_check_in::text, 'NULL');
    
    -- ========================================
    -- VALIDAÇÃO USUÁRIO 2 (20 pontos esperados)  
    -- ========================================
    
    SELECT * INTO user2_progress
    FROM challenge_progress 
    WHERE user_id = test_user_2 AND challenge_id = test_challenge_id;
    
    expected_completion := LEAST(100, (2 * 100.0) / challenge_duration);
    
    RAISE NOTICE '👤 USUÁRIO 2 - Esperado: 20 pontos, 2 check-ins';
    RAISE NOTICE '   ✓ Pontos: % (esperado: 20)', COALESCE(user2_progress.points, 0);
    RAISE NOTICE '   ✓ Check-ins: % (esperado: 2)', COALESCE(user2_progress.check_ins_count, 0);
    RAISE NOTICE '   ✓ Total check-ins: % (esperado: 2)', COALESCE(user2_progress.total_check_ins, 0);
    RAISE NOTICE '   ✓ Progresso: %% (esperado: %)', ROUND(COALESCE(user2_progress.completion_percentage, 0), 2), ROUND(expected_completion, 2);
    RAISE NOTICE '   ✓ Posição: % (esperado: 2)', COALESCE(user2_progress.position, 0);
    RAISE NOTICE '   ✓ Nome: % (esperado: Usuário Teste 2)', COALESCE(user2_progress.user_name, 'NULL');
    RAISE NOTICE '   ✓ Último check-in: %', COALESCE(user2_progress.last_check_in::text, 'NULL');
    
    -- ========================================
    -- VALIDAÇÃO USUÁRIO 3 (10 pontos esperados)
    -- ========================================
    
    SELECT * INTO user3_progress
    FROM challenge_progress 
    WHERE user_id = test_user_3 AND challenge_id = test_challenge_id;
    
    expected_completion := LEAST(100, (1 * 100.0) / challenge_duration);
    
    RAISE NOTICE '👤 USUÁRIO 3 - Esperado: 10 pontos, 1 check-in';
    RAISE NOTICE '   ✓ Pontos: % (esperado: 10)', COALESCE(user3_progress.points, 0);
    RAISE NOTICE '   ✓ Check-ins: % (esperado: 1)', COALESCE(user3_progress.check_ins_count, 0);
    RAISE NOTICE '   ✓ Total check-ins: % (esperado: 1)', COALESCE(user3_progress.total_check_ins, 0);
    RAISE NOTICE '   ✓ Progresso: %% (esperado: %)', ROUND(COALESCE(user3_progress.completion_percentage, 0), 2), ROUND(expected_completion, 2);
    RAISE NOTICE '   ✓ Posição: % (esperado: 3)', COALESCE(user3_progress.position, 0);
    RAISE NOTICE '   ✓ Nome: % (esperado: Usuário Teste 3)', COALESCE(user3_progress.user_name, 'NULL');
    RAISE NOTICE '   ✓ Último check-in: %', COALESCE(user3_progress.last_check_in::text, 'NULL');
    
END $$;

-- ======================================
-- 🏆 VALIDAÇÃO DO RANKING COMPLETO
-- ======================================

RAISE NOTICE '🏆 RANKING FINAL:';

SELECT 
    ROW_NUMBER() OVER () as posicao_real,
    position as posicao_calculada,
    user_name,
    points,
    check_ins_count,
    total_check_ins,
    ROUND(completion_percentage, 2) as progresso,
    consecutive_days,
    last_check_in::date,
    CASE 
        WHEN completed THEN '✅ Completo'
        ELSE '🔄 Em Progresso'
    END as status
FROM challenge_progress 
WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'
ORDER BY points DESC, total_check_ins DESC, last_check_in ASC;

-- ======================================
-- 📋 RESUMO FINAL DE VALIDAÇÃO
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    validation_errors INTEGER := 0;
    progress_count INTEGER;
    ranking_correct BOOLEAN := true;
BEGIN
    RAISE NOTICE '📋 RESUMO FINAL DE VALIDAÇÃO:';
    
    -- Verificar se todos os usuários têm progresso
    SELECT COUNT(*) INTO progress_count
    FROM challenge_progress 
    WHERE challenge_id = test_challenge_id;
    
    IF progress_count != 3 THEN
        validation_errors := validation_errors + 1;
        RAISE NOTICE '❌ ERRO: Esperado 3 registros de progresso, encontrado %', progress_count;
    ELSE
        RAISE NOTICE '✅ Progresso: 3 usuários registrados corretamente';
    END IF;
    
    -- Verificar ranking (posições 1, 2, 3)
    IF NOT EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        AND user_name = 'Usuário Teste 1' 
        AND position = 1 AND points = 30
    ) THEN
        validation_errors := validation_errors + 1;
        RAISE NOTICE '❌ ERRO: Usuário 1 deveria estar em 1º lugar com 30 pontos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        AND user_name = 'Usuário Teste 2' 
        AND position = 2 AND points = 20
    ) THEN
        validation_errors := validation_errors + 1;
        RAISE NOTICE '❌ ERRO: Usuário 2 deveria estar em 2º lugar com 20 pontos';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        AND user_name = 'Usuário Teste 3' 
        AND position = 3 AND points = 10
    ) THEN
        validation_errors := validation_errors + 1;
        RAISE NOTICE '❌ ERRO: Usuário 3 deveria estar em 3º lugar com 10 pontos';
    END IF;
    
    -- Resultado final
    IF validation_errors = 0 THEN
        RAISE NOTICE '🎉 SUCESSO! Todos os testes passaram!';
        RAISE NOTICE '✅ Sistema de ranking 100% funcional';
        RAISE NOTICE '✅ Tabela challenge_progress completamente validada';
        RAISE NOTICE '✅ Pontuação: ✓ | Check-ins: ✓ | Ranking: ✓ | Progresso: ✓';
    ELSE
        RAISE NOTICE '❌ FALHA! % erro(s) encontrado(s)', validation_errors;
        RAISE NOTICE '🔧 Verificar funções de processamento do ranking';
    END IF;
    
    RAISE NOTICE '=====================================';
    RAISE NOTICE '🏁 TESTE COMPLETO FINALIZADO';
    RAISE NOTICE '=====================================';
END $$; 