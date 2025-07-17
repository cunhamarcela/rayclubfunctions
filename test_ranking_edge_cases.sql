-- 🎯 TESTE DE CASOS EXTREMOS E EMPATES NO RANKING
-- 📋 Validação de cenários complexos do sistema de ranking

-- ======================================
-- 🧹 LIMPEZA E PREPARAÇÃO PARA TESTES DE EMPATE
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'd8f032b4-1234-5678-9abc-def123456789';
    test_user_A UUID := 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
    test_user_B UUID := 'b2c3d4e5-f6a7-8901-2345-678901bcdef0';
    test_user_C UUID := 'c3d4e5f6-a7b8-9012-3456-789012cdef12';
    test_user_D UUID := 'd4e5f6a7-b8c9-0123-4567-890123def345';
BEGIN
    RAISE NOTICE '🧹 LIMPANDO dados de teste de empate...';
    
    -- Limpar dados específicos do teste
    DELETE FROM challenge_check_ins WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = test_challenge_id;
    
    RAISE NOTICE '✅ Limpeza concluída';
END $$;

-- ======================================
-- 📊 PREPARAÇÃO PARA TESTES DE EMPATE
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'd8f032b4-1234-5678-9abc-def123456789';
    test_user_A UUID := 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
    test_user_B UUID := 'b2c3d4e5-f6a7-8901-2345-678901bcdef0';
    test_user_C UUID := 'c3d4e5f6-a7b8-9012-3456-789012cdef12';
    test_user_D UUID := 'd4e5f6a7-b8c9-0123-4567-890123def345';
BEGIN
    RAISE NOTICE '📊 PREPARANDO dados para teste de empate...';
    
    -- Criar usuários de teste
    INSERT INTO profiles (id, name, photo_url) VALUES 
    (test_user_A, 'Usuário A (Empate)', 'https://example.com/photoA.jpg'),
    (test_user_B, 'Usuário B (Empate)', 'https://example.com/photoB.jpg'),
    (test_user_C, 'Usuário C (Empate)', 'https://example.com/photoC.jpg'),
    (test_user_D, 'Usuário D (Menos Treinos)', 'https://example.com/photoD.jpg')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, photo_url = EXCLUDED.photo_url;
    
    -- Criar desafio para teste de empate
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, status, points, type, is_official
    ) VALUES (
        test_challenge_id, 
        'Desafio Teste Empate', 
        'Teste de critérios de desempate no ranking',
        CURRENT_DATE - INTERVAL '15 days',
        CURRENT_DATE + INTERVAL '15 days',
        true, 'active', 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active,
        status = EXCLUDED.status;
    
    -- Inscrever usuários no desafio
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (test_user_A, test_challenge_id, NOW() - INTERVAL '10 days'),
    (test_user_B, test_challenge_id, NOW() - INTERVAL '10 days'),
    (test_user_C, test_challenge_id, NOW() - INTERVAL '10 days'),
    (test_user_D, test_challenge_id, NOW() - INTERVAL '10 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
    
    RAISE NOTICE '✅ Dados de teste de empate preparados';
END $$;

-- ======================================
-- 🥇 CENÁRIO DE EMPATE: MESMO NÚMERO DE PONTOS
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'd8f032b4-1234-5678-9abc-def123456789';
    test_user_A UUID := 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
    test_user_B UUID := 'b2c3d4e5-f6a7-8901-2345-678901bcdef0';
    test_user_C UUID := 'c3d4e5f6-a7b8-9012-3456-789012cdef12';
    test_user_D UUID := 'd4e5f6a7-b8c9-0123-4567-890123def345';
BEGIN
    RAISE NOTICE '🥇 TESTANDO cenário de empate no ranking...';
    
    -- ========================================
    -- USUÁRIO A: 2 check-ins (20 pontos) + 5 treinos totais
    -- ========================================
    
    -- Treinos válidos que pontuam
    PERFORM record_workout_basic(
        test_user_A, 'TREINO-A-001', 'Corrida', 'cardio', 
        60, CURRENT_DATE - INTERVAL '5 days', test_challenge_id, 'Check-in 1'
    );
    
    PERFORM record_workout_basic(
        test_user_A, 'TREINO-A-002', 'Musculação', 'strength', 
        50, CURRENT_DATE - INTERVAL '3 days', test_challenge_id, 'Check-in 2'
    );
    
    -- Treinos extras que NÃO pontuam (mas contam para desempate)
    PERFORM record_workout_basic(
        test_user_A, 'TREINO-A-003', 'Caminhada', 'cardio', 
        30, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'Muito curto'
    );
    
    PERFORM record_workout_basic(
        test_user_A, 'TREINO-A-004', 'Yoga', 'flexibility', 
        35, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'Muito curto'
    );
    
    PERFORM record_workout_basic(
        test_user_A, 'TREINO-A-005', 'Pilates', 'strength', 
        40, CURRENT_DATE, test_challenge_id, 'Muito curto'
    );
    
    -- ========================================
    -- USUÁRIO B: 2 check-ins (20 pontos) + 3 treinos totais
    -- ========================================
    
    -- Treinos válidos que pontuam
    PERFORM record_workout_basic(
        test_user_B, 'TREINO-B-001', 'Natação', 'cardio', 
        55, CURRENT_DATE - INTERVAL '4 days', test_challenge_id, 'Check-in 1'
    );
    
    PERFORM record_workout_basic(
        test_user_B, 'TREINO-B-002', 'CrossFit', 'mixed', 
        65, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'Check-in 2'
    );
    
    -- Treino extra que NÃO pontua
    PERFORM record_workout_basic(
        test_user_B, 'TREINO-B-003', 'Alongamento', 'flexibility', 
        25, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'Muito curto'
    );
    
    -- ========================================
    -- USUÁRIO C: 2 check-ins (20 pontos) + 2 treinos totais
    -- ========================================
    
    -- Treinos válidos que pontuam
    PERFORM record_workout_basic(
        test_user_C, 'TREINO-C-001', 'Bicicleta', 'cardio', 
        70, CURRENT_DATE - INTERVAL '6 days', test_challenge_id, 'Check-in 1'
    );
    
    PERFORM record_workout_basic(
        test_user_C, 'TREINO-C-002', 'Funcional', 'mixed', 
        45, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'Check-in 2'
    );
    
    -- ========================================
    -- USUÁRIO D: 1 check-in (10 pontos) + 1 treino total
    -- ========================================
    
    PERFORM record_workout_basic(
        test_user_D, 'TREINO-D-001', 'Corrida', 'cardio', 
        90, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'Único check-in'
    );
    
    RAISE NOTICE '✅ Cenário de empate criado:';
    RAISE NOTICE '   - Usuário A: 20 pontos, 5 treinos totais';
    RAISE NOTICE '   - Usuário B: 20 pontos, 3 treinos totais';
    RAISE NOTICE '   - Usuário C: 20 pontos, 2 treinos totais';
    RAISE NOTICE '   - Usuário D: 10 pontos, 1 treino total';
    
    PERFORM pg_sleep(2);
END $$;

-- ======================================
-- 📊 VALIDAÇÃO DO CRITÉRIO DE DESEMPATE
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'd8f032b4-1234-5678-9abc-def123456789';
    userA_rank INTEGER;
    userB_rank INTEGER;
    userC_rank INTEGER;
    userD_rank INTEGER;
    
    userA_workouts INTEGER;
    userB_workouts INTEGER;
    userC_workouts INTEGER;
    userD_workouts INTEGER;
BEGIN
    RAISE NOTICE '📊 VALIDANDO critério de desempate...';
    
    -- Obter posições no ranking
    SELECT position INTO userA_rank
    FROM challenge_progress 
    WHERE challenge_id = test_challenge_id 
    AND user_name = 'Usuário A (Empate)';
    
    SELECT position INTO userB_rank
    FROM challenge_progress 
    WHERE challenge_id = test_challenge_id 
    AND user_name = 'Usuário B (Empate)';
    
    SELECT position INTO userC_rank
    FROM challenge_progress 
    WHERE challenge_id = test_challenge_id 
    AND user_name = 'Usuário C (Empate)';
    
    SELECT position INTO userD_rank
    FROM challenge_progress 
    WHERE challenge_id = test_challenge_id 
    AND user_name = 'Usuário D (Menos Treinos)';
    
    -- Contar treinos totais de cada usuário
    SELECT COUNT(*) INTO userA_workouts
    FROM workout_records 
    WHERE user_id = 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
    
    SELECT COUNT(*) INTO userB_workouts
    FROM workout_records 
    WHERE user_id = 'b2c3d4e5-f6a7-8901-2345-678901bcdef0';
    
    SELECT COUNT(*) INTO userC_workouts
    FROM workout_records 
    WHERE user_id = 'c3d4e5f6-a7b8-9012-3456-789012cdef12';
    
    SELECT COUNT(*) INTO userD_workouts
    FROM workout_records 
    WHERE user_id = 'd4e5f6a7-b8c9-0123-4567-890123def345';
    
    RAISE NOTICE '🏆 RANKING COM CRITÉRIO DE DESEMPATE:';
    RAISE NOTICE '   1º lugar: Usuário A - Posição % (5 treinos totais)', COALESCE(userA_rank, 0);
    RAISE NOTICE '   2º lugar: Usuário B - Posição % (3 treinos totais)', COALESCE(userB_rank, 0);
    RAISE NOTICE '   3º lugar: Usuário C - Posição % (2 treinos totais)', COALESCE(userC_rank, 0);
    RAISE NOTICE '   4º lugar: Usuário D - Posição % (1 treino total)', COALESCE(userD_rank, 0);
    
    -- Validar se o desempate está correto
    IF userA_rank = 1 AND userB_rank = 2 AND userC_rank = 3 AND userD_rank = 4 THEN
        RAISE NOTICE '✅ DESEMPATE CORRETO: Ranking baseado no total de treinos!';
    ELSE
        RAISE NOTICE '❌ ERRO NO DESEMPATE: Ranking não segue critério esperado!';
    END IF;
END $$;

-- ======================================
-- 📋 RANKING COMPLETO COM TODOS OS DETALHES
-- ======================================

RAISE NOTICE '📋 RANKING DETALHADO:';

SELECT 
    position as posicao,
    user_name as nome,
    points as pontos,
    check_ins_count as check_ins,
    total_check_ins as total_check_ins,
    (SELECT COUNT(*) FROM workout_records wr 
     WHERE wr.user_id = cp.user_id) as treinos_totais_sistema,
    ROUND(completion_percentage, 2) as progresso_pct,
    last_check_in::date as ultimo_check_in,
    created_at::date as criado_em
FROM challenge_progress cp
WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789'
ORDER BY position ASC;

-- ======================================
-- 🔍 TESTE DE CASOS EXTREMOS
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'd8f032b4-1234-5678-9abc-def123456789';
    edge_case_results TEXT := '';
BEGIN
    RAISE NOTICE '🔍 TESTANDO casos extremos...';
    
    -- Caso 1: Verificar se total_check_ins está correto
    IF EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        AND check_ins_count != total_check_ins
    ) THEN
        edge_case_results := edge_case_results || '❌ INCONSISTÊNCIA: check_ins_count != total_check_ins; ';
    ELSE
        edge_case_results := edge_case_results || '✅ Consistência check_ins OK; ';
    END IF;
    
    -- Caso 2: Verificar se todos têm user_name preenchido
    IF EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        AND (user_name IS NULL OR user_name = '')
    ) THEN
        edge_case_results := edge_case_results || '❌ ERRO: user_name vazio; ';
    ELSE
        edge_case_results := edge_case_results || '✅ user_name preenchido; ';
    END IF;
    
    -- Caso 3: Verificar se completion_percentage é calculado corretamente
    IF EXISTS (
        SELECT 1 FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        AND completion_percentage < 0 OR completion_percentage > 100
    ) THEN
        edge_case_results := edge_case_results || '❌ ERRO: completion_percentage inválido; ';
    ELSE
        edge_case_results := edge_case_results || '✅ completion_percentage válido; ';
    END IF;
    
    -- Caso 4: Verificar se posições são únicas e sequenciais
    IF EXISTS (
        SELECT position, COUNT(*) 
        FROM challenge_progress 
        WHERE challenge_id = test_challenge_id 
        GROUP BY position 
        HAVING COUNT(*) > 1
    ) THEN
        edge_case_results := edge_case_results || '❌ ERRO: Posições duplicadas; ';
    ELSE
        edge_case_results := edge_case_results || '✅ Posições únicas; ';
    END IF;
    
    RAISE NOTICE '🔍 RESULTADOS DOS CASOS EXTREMOS:';
    RAISE NOTICE '%', edge_case_results;
    
    RAISE NOTICE '=====================================';
    RAISE NOTICE '🏁 TESTE DE EMPATE E CASOS EXTREMOS FINALIZADO';
    RAISE NOTICE '=====================================';
END $$; 