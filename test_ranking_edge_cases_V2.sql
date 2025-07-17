-- 🎯 TESTE DE CASOS EXTREMOS E EMPATES NO RANKING (VERSÃO 2.0)
-- 📋 Validação de cenários complexos usando SELECT

-- ======================================
-- 🧹 LIMPEZA INICIAL
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'd8f032b4-1234-5678-9abc-def123456789';
    test_user_A UUID := 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
    test_user_B UUID := 'b2c3d4e5-f6a7-8901-2345-678901bcdef0';
    test_user_C UUID := 'c3d4e5f6-a7b8-9012-3456-789012cdef12';
    test_user_D UUID := 'd4e5f6a7-b8c9-0123-4567-890123def345';
BEGIN
    -- Limpar dados específicos do teste
    DELETE FROM challenge_check_ins WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = test_challenge_id;
END $$;

SELECT '🧹 LIMPEZA DE EMPATE CONCLUÍDA' as status;

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
    -- Criar usuários de teste
    INSERT INTO profiles (id, name) VALUES 
    (test_user_A, 'Usuário A (Empate)'),
    (test_user_B, 'Usuário B (Empate)'),
    (test_user_C, 'Usuário C (Empate)'),
    (test_user_D, 'Usuário D (Menos Treinos)')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Criar desafio para teste de empate
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        test_challenge_id, 
        'Desafio Teste Empate', 
        'Teste de critérios de desempate no ranking',
        CURRENT_DATE - INTERVAL '15 days',
        CURRENT_DATE + INTERVAL '15 days',
        true, 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active;
    
    -- Inscrever usuários no desafio
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (test_user_A, test_challenge_id, NOW() - INTERVAL '10 days'),
    (test_user_B, test_challenge_id, NOW() - INTERVAL '10 days'),
    (test_user_C, test_challenge_id, NOW() - INTERVAL '10 days'),
    (test_user_D, test_challenge_id, NOW() - INTERVAL '10 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
END $$;

SELECT '📊 DADOS DE TESTE DE EMPATE PREPARADOS' as status;

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
    -- USUÁRIO A: 2 check-ins (20 pontos) + 5 treinos totais
    PERFORM record_workout_basic(test_user_A, 'Corrida', 'cardio', 60, CURRENT_DATE - INTERVAL '5 days', test_challenge_id, 'TREINO-A-001', 'Check-in 1', gen_random_uuid());
    PERFORM record_workout_basic(test_user_A, 'Musculação', 'strength', 50, CURRENT_DATE - INTERVAL '3 days', test_challenge_id, 'TREINO-A-002', 'Check-in 2', gen_random_uuid());
    PERFORM record_workout_basic(test_user_A, 'Caminhada', 'cardio', 30, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'TREINO-A-003', 'Muito curto', gen_random_uuid());
    PERFORM record_workout_basic(test_user_A, 'Yoga', 'flexibility', 35, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'TREINO-A-004', 'Muito curto', gen_random_uuid());
    PERFORM record_workout_basic(test_user_A, 'Pilates', 'strength', 40, CURRENT_DATE, test_challenge_id, 'TREINO-A-005', 'Muito curto', gen_random_uuid());
    
    -- USUÁRIO B: 2 check-ins (20 pontos) + 3 treinos totais
    PERFORM record_workout_basic(test_user_B, 'Natação', 'cardio', 55, CURRENT_DATE - INTERVAL '4 days', test_challenge_id, 'TREINO-B-001', 'Check-in 1', gen_random_uuid());
    PERFORM record_workout_basic(test_user_B, 'CrossFit', 'mixed', 65, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'TREINO-B-002', 'Check-in 2', gen_random_uuid());
    PERFORM record_workout_basic(test_user_B, 'Alongamento', 'flexibility', 25, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'TREINO-B-003', 'Muito curto', gen_random_uuid());
    
    -- USUÁRIO C: 2 check-ins (20 pontos) + 2 treinos totais
    PERFORM record_workout_basic(test_user_C, 'Bicicleta', 'cardio', 70, CURRENT_DATE - INTERVAL '6 days', test_challenge_id, 'TREINO-C-001', 'Check-in 1', gen_random_uuid());
    PERFORM record_workout_basic(test_user_C, 'Funcional', 'mixed', 45, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'TREINO-C-002', 'Check-in 2', gen_random_uuid());
    
    -- USUÁRIO D: 1 check-in (10 pontos) + 1 treino total
    PERFORM record_workout_basic(test_user_D, 'Corrida', 'cardio', 90, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'TREINO-D-001', 'Único check-in', gen_random_uuid());
    
    PERFORM pg_sleep(2);
END $$;

SELECT '🥇 CENÁRIO DE EMPATE CRIADO: A=20pts/5treinos, B=20pts/3treinos, C=20pts/2treinos, D=10pts/1treino' as status;

-- ======================================
-- 📊 CONTAGEM DE TREINOS POR USUÁRIO
-- ======================================

SELECT '📊 CONTAGEM DE TREINOS POR USUÁRIO:' as titulo;

SELECT 
    CASE 
        WHEN user_id = 'a1b2c3d4-e5f6-7890-1234-567890abcdef' THEN 'Usuário A (Empate)'
        WHEN user_id = 'b2c3d4e5-f6a7-8901-2345-678901bcdef0' THEN 'Usuário B (Empate)'
        WHEN user_id = 'c3d4e5f6-a7b8-9012-3456-789012cdef12' THEN 'Usuário C (Empate)'
        WHEN user_id = 'd4e5f6a7-b8c9-0123-4567-890123def345' THEN 'Usuário D (Menos Treinos)'
        ELSE 'Outro'
    END as usuario,
    COUNT(*) as total_treinos_registrados,
    COUNT(CASE WHEN duration_minutes >= 45 THEN 1 END) as treinos_validos_esperados
FROM workout_records 
WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789'
GROUP BY user_id
ORDER BY total_treinos_registrados DESC;

-- ======================================
-- 📊 VALIDAÇÃO DO CRITÉRIO DE DESEMPATE
-- ======================================

SELECT '📊 VALIDAÇÃO DO CRITÉRIO DE DESEMPATE:' as titulo;

WITH expected_tie_results AS (
    SELECT 
        'a1b2c3d4-e5f6-7890-1234-567890abcdef'::uuid as user_id,
        'Usuário A (Empate)' as expected_name,
        20 as expected_points,
        2 as expected_checkins,
        1 as expected_position,
        5 as expected_total_workouts
    UNION ALL
    SELECT 
        'b2c3d4e5-f6a7-8901-2345-678901bcdef0'::uuid,
        'Usuário B (Empate)',
        20,
        2,
        2,
        3
    UNION ALL
    SELECT 
        'c3d4e5f6-a7b8-9012-3456-789012cdef12'::uuid,
        'Usuário C (Empate)',
        20,
        2,
        3,
        2
    UNION ALL
    SELECT 
        'd4e5f6a7-b8c9-0123-4567-890123def345'::uuid,
        'Usuário D (Menos Treinos)',
        10,
        1,
        4,
        1
),
actual_tie_results AS (
    SELECT 
        cp.user_id,
        cp.user_name,
        cp.points,
        cp.check_ins_count,
        cp.position,
        (SELECT COUNT(*) FROM workout_records wr WHERE wr.user_id = cp.user_id) as total_workouts_ever
    FROM challenge_progress cp
    WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789'
)
SELECT 
    etr.expected_name as usuario,
    etr.expected_points as pontos_esperados,
    COALESCE(atr.points, 0) as pontos_atual,
    CASE WHEN COALESCE(atr.points, 0) = etr.expected_points THEN '✅' ELSE '❌' END as pontos_ok,
    etr.expected_position as posicao_esperada,
    COALESCE(atr.position, 0) as posicao_atual,
    CASE WHEN COALESCE(atr.position, 0) = etr.expected_position THEN '✅' ELSE '❌' END as ranking_ok,
    etr.expected_total_workouts as treinos_esperados,
    COALESCE(atr.total_workouts_ever, 0) as treinos_sistema,
    CASE WHEN COALESCE(atr.total_workouts_ever, 0) = etr.expected_total_workouts THEN '✅' ELSE '❌' END as treinos_ok
FROM expected_tie_results etr
LEFT JOIN actual_tie_results atr ON atr.user_id = etr.user_id
ORDER BY etr.expected_position;

-- ======================================
-- 🏆 RANKING DETALHADO COM CRITÉRIO DE DESEMPATE
-- ======================================

SELECT '🏆 RANKING DETALHADO COM CRITÉRIO DE DESEMPATE:' as titulo;

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
    created_at::date as criado_em,
    CASE 
        WHEN position = 1 AND points = 20 AND user_name LIKE '%A%' THEN '🥇 1º (desempate por + treinos)'
        WHEN position = 2 AND points = 20 AND user_name LIKE '%B%' THEN '🥈 2º (desempate por + treinos)'
        WHEN position = 3 AND points = 20 AND user_name LIKE '%C%' THEN '🥉 3º (desempate por + treinos)'
        WHEN position = 4 AND points = 10 THEN '4º (menos pontos)'
        ELSE 'Posição inesperada'
    END as criterio_ranking
FROM challenge_progress cp
WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789'
ORDER BY position ASC;

-- ======================================
-- 🔍 TESTE DE CASOS EXTREMOS
-- ======================================

SELECT '🔍 TESTE DE CASOS EXTREMOS:' as titulo;

WITH edge_case_validations AS (
    SELECT 
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND check_ins_count != total_check_ins
            ) 
            THEN '✅ Consistência check_ins OK'
            ELSE '❌ INCONSISTÊNCIA: check_ins_count != total_check_ins'
        END as check_consistency,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND (user_name IS NULL OR user_name = '')
            ) 
            THEN '✅ user_name preenchido'
            ELSE '❌ ERRO: user_name vazio'
        END as check_usernames,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND (completion_percentage < 0 OR completion_percentage > 100)
            ) 
            THEN '✅ completion_percentage válido'
            ELSE '❌ ERRO: completion_percentage inválido'
        END as check_percentage,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT position, COUNT(*) 
                FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                GROUP BY position 
                HAVING COUNT(*) > 1
            ) 
            THEN '✅ Posições únicas'
            ELSE '❌ ERRO: Posições duplicadas'
        END as check_positions,
        
        CASE 
            WHEN (
                SELECT COUNT(*) 
                FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789'
                AND points = 20
            ) = 3
            THEN '✅ 3 usuários empatados com 20 pontos'
            ELSE '❌ Empate não detectado corretamente'
        END as check_tie
)
SELECT check_consistency as resultado FROM edge_case_validations
UNION ALL
SELECT check_usernames FROM edge_case_validations
UNION ALL
SELECT check_percentage FROM edge_case_validations
UNION ALL
SELECT check_positions FROM edge_case_validations
UNION ALL
SELECT check_tie FROM edge_case_validations;

-- ======================================
-- 🎯 VALIDAÇÃO FINAL DO DESEMPATE
-- ======================================

SELECT '🎯 VALIDAÇÃO FINAL DO DESEMPATE:' as titulo;

WITH tie_breaker_validation AS (
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND user_name = 'Usuário A (Empate)' 
                AND position = 1 AND points = 20
            ) 
            THEN '✅ Usuário A em 1º (20 pontos, mais treinos)'
            ELSE '❌ ERRO: Usuário A não está em 1º lugar'
        END as check_userA,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND user_name = 'Usuário B (Empate)' 
                AND position = 2 AND points = 20
            ) 
            THEN '✅ Usuário B em 2º (20 pontos, meio treinos)'
            ELSE '❌ ERRO: Usuário B não está em 2º lugar'
        END as check_userB,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND user_name = 'Usuário C (Empate)' 
                AND position = 3 AND points = 20
            ) 
            THEN '✅ Usuário C em 3º (20 pontos, menos treinos)'
            ELSE '❌ ERRO: Usuário C não está em 3º lugar'
        END as check_userC,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' 
                AND user_name = 'Usuário D (Menos Treinos)' 
                AND position = 4 AND points = 10
            ) 
            THEN '✅ Usuário D em 4º (10 pontos)'
            ELSE '❌ ERRO: Usuário D não está em 4º lugar'
        END as check_userD
)
SELECT check_userA as resultado FROM tie_breaker_validation
UNION ALL
SELECT check_userB FROM tie_breaker_validation
UNION ALL
SELECT check_userC FROM tie_breaker_validation
UNION ALL
SELECT check_userD FROM tie_breaker_validation;

-- ======================================
-- 🎉 RESULTADO FINAL DO TESTE DE EMPATE
-- ======================================

WITH final_tie_validation AS (
    SELECT 
        CASE 
            WHEN (
                EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' AND user_name = 'Usuário A (Empate)' AND position = 1 AND points = 20)
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' AND user_name = 'Usuário B (Empate)' AND position = 2 AND points = 20)
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' AND user_name = 'Usuário C (Empate)' AND position = 3 AND points = 20)
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'd8f032b4-1234-5678-9abc-def123456789' AND user_name = 'Usuário D (Menos Treinos)' AND position = 4 AND points = 10)
            )
            THEN '🎉 SUCESSO! CRITÉRIO DE DESEMPATE FUNCIONANDO PERFEITAMENTE!'
            ELSE '❌ FALHA! Critério de desempate não está funcionando'
        END as resultado_final_empate
)
SELECT resultado_final_empate FROM final_tie_validation; 