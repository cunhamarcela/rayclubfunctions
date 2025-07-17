-- 🎯 TESTE COMPLETO DO SISTEMA DE RANKING E CHALLENGE_PROGRESS (VERSÃO 2.0)
-- 📋 Validação completa usando SELECT para melhor visualização

-- ======================================
-- 🧹 LIMPEZA INICIAL
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    test_user_2 UUID := 'b7d234ef-89ab-4cde-f123-456789abcdef';
    test_user_3 UUID := 'c8e345f0-9abc-5def-0234-56789abcdef1'; 
BEGIN
    -- Limpar dados específicos do teste
    DELETE FROM challenge_check_ins WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = test_challenge_id;
END $$;

SELECT '🧹 LIMPEZA CONCLUÍDA' as status;

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
    -- Criar usuários de teste
    INSERT INTO profiles (id, name) VALUES 
    (test_user_1, 'Usuário Teste 1'),
    (test_user_2, 'Usuário Teste 2'),
    (test_user_3, 'Usuário Teste 3')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Garantir que desafio existe e está ativo
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        test_challenge_id, 
        'Desafio de Teste Ranking', 
        'Teste completo do sistema de ranking',
        CURRENT_DATE - INTERVAL '10 days',
        CURRENT_DATE + INTERVAL '20 days',
        true, 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active;
    
    -- Inscrever usuários no desafio
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (test_user_1, test_challenge_id, NOW() - INTERVAL '5 days'),
    (test_user_2, test_challenge_id, NOW() - INTERVAL '5 days'),
    (test_user_3, test_challenge_id, NOW() - INTERVAL '5 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
END $$;

SELECT '📊 DADOS DE TESTE PREPARADOS' as status;

-- ======================================
-- 🏋️ REGISTRAR TREINOS VÁLIDOS
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    test_user_2 UUID := 'b7d234ef-89ab-4cde-f123-456789abcdef';
    test_user_3 UUID := 'c8e345f0-9abc-5def-0234-56789abcdef1';
    workout_result JSONB;
BEGIN
    -- USUÁRIO 1: 3 treinos válidos = 30 pontos
    SELECT record_workout_basic(
        test_user_1, 'Corrida Matinal', 'cardio', 
        60, CURRENT_DATE - INTERVAL '3 days', test_challenge_id, 'TREINO-TEST-001', 'Treino intenso', gen_random_uuid()
    ) INTO workout_result;
    
    SELECT record_workout_basic(
        test_user_1, 'Musculação', 'strength', 
        50, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'TREINO-TEST-002', 'Foco em força', gen_random_uuid()
    ) INTO workout_result;
    
    SELECT record_workout_basic(
        test_user_1, 'CrossFit', 'mixed', 
        70, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'TREINO-TEST-003', 'WOD completo', gen_random_uuid()
    ) INTO workout_result;
    
    -- USUÁRIO 2: 2 treinos válidos = 20 pontos
    SELECT record_workout_basic(
        test_user_2, 'Yoga', 'flexibility', 
        45, CURRENT_DATE - INTERVAL '2 days', test_challenge_id, 'TREINO-TEST-004', 'Flexibilidade', gen_random_uuid()
    ) INTO workout_result;
    
    SELECT record_workout_basic(
        test_user_2, 'Natação', 'cardio', 
        55, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'TREINO-TEST-005', 'Cardio aquático', gen_random_uuid()
    ) INTO workout_result;
    
    -- USUÁRIO 3: 1 treino válido = 10 pontos
    SELECT record_workout_basic(
        test_user_3, 'Ciclismo', 'cardio', 
        80, CURRENT_DATE - INTERVAL '1 days', test_challenge_id, 'TREINO-TEST-006', 'Pedal longo', gen_random_uuid()
    ) INTO workout_result;
    
    -- Aguardar processamento
    PERFORM pg_sleep(2);
END $$;

SELECT '🏋️ TREINOS VÁLIDOS REGISTRADOS: User1=3, User2=2, User3=1' as status;

-- ======================================
-- 🚫 REGISTRAR TREINOS INVÁLIDOS
-- ======================================

DO $$
DECLARE
    test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
    test_user_1 UUID := '906a27bc-ccff-4c74-ad83-37692782305a';
    workout_result JSONB;
BEGIN
    -- Treino curto (< 45min) - NÃO deve pontuar
    SELECT record_workout_basic(
        test_user_1, 'Caminhada', 'cardio', 
        30, CURRENT_DATE, test_challenge_id, 'TREINO-INVALID-001', 'Muito curto', gen_random_uuid()
    ) INTO workout_result;
    
    -- Segundo treino no mesmo dia - NÃO deve pontuar
    SELECT record_workout_basic(
        test_user_1, 'Alongamento', 'flexibility', 
        60, CURRENT_DATE - INTERVAL '3 days', test_challenge_id, 'TREINO-INVALID-002', 'Segundo do dia', gen_random_uuid()
    ) INTO workout_result;
    
    PERFORM pg_sleep(1);
END $$;

SELECT '🚫 TREINOS INVÁLIDOS REGISTRADOS (não devem pontuar)' as status;

-- ======================================
-- 📈 CONTAGENS GERAIS
-- ======================================

SELECT '📈 CONTAGENS GERAIS:' as titulo;

SELECT 
    'workout_records' as tabela,
    COUNT(*) as total_registros
FROM workout_records 
WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'

UNION ALL

SELECT 
    'challenge_check_ins' as tabela,
    COUNT(*) as total_registros
FROM challenge_check_ins 
WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'

UNION ALL

SELECT 
    'challenge_progress' as tabela,
    COUNT(*) as total_registros
FROM challenge_progress 
WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';

-- ======================================
-- 📊 VALIDAÇÃO DETALHADA POR USUÁRIO
-- ======================================

SELECT '👤 VALIDAÇÃO DETALHADA POR USUÁRIO:' as titulo;

WITH expected_results AS (
    SELECT 
        '906a27bc-ccff-4c74-ad83-37692782305a'::uuid as user_id,
        'Usuário Teste 1' as expected_name,
        30 as expected_points,
        3 as expected_checkins,
        1 as expected_position
    UNION ALL
    SELECT 
        'b7d234ef-89ab-4cde-f123-456789abcdef'::uuid,
        'Usuário Teste 2',
        20,
        2,
        2
    UNION ALL
    SELECT 
        'c8e345f0-9abc-5def-0234-56789abcdef1'::uuid,
        'Usuário Teste 3',
        10,
        1,
        3
),
actual_results AS (
    SELECT 
        user_id,
        user_name,
        points,
        check_ins_count,
        position,
        completion_percentage,
        last_check_in
    FROM challenge_progress 
    WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'
)
SELECT 
    er.expected_name as usuario,
    er.expected_points as pontos_esperados,
    COALESCE(ar.points, 0) as pontos_atual,
    CASE WHEN COALESCE(ar.points, 0) = er.expected_points THEN '✅' ELSE '❌' END as pontos_ok,
    er.expected_checkins as checkins_esperados,
    COALESCE(ar.check_ins_count, 0) as checkins_atual,
    CASE WHEN COALESCE(ar.check_ins_count, 0) = er.expected_checkins THEN '✅' ELSE '❌' END as checkins_ok,
    er.expected_position as posicao_esperada,
    COALESCE(ar.position, 0) as posicao_atual,
    CASE WHEN COALESCE(ar.position, 0) = er.expected_position THEN '✅' ELSE '❌' END as posicao_ok,
    ROUND(COALESCE(ar.completion_percentage, 0), 2) as progresso_pct,
    ar.last_check_in::date as ultimo_checkin
FROM expected_results er
LEFT JOIN actual_results ar ON ar.user_id = er.user_id
ORDER BY er.expected_position;

-- ======================================
-- 🏆 RANKING FINAL COMPLETO
-- ======================================

SELECT '🏆 RANKING FINAL COMPLETO:' as titulo;

SELECT 
    ROW_NUMBER() OVER (ORDER BY points DESC, total_check_ins DESC, last_check_in ASC) as posicao_real,
    position as posicao_calculada,
    user_name as nome,
    points as pontos,
    check_ins_count as check_ins,
    total_check_ins,
    ROUND(completion_percentage, 2) as progresso_pct,
    consecutive_days as dias_consecutivos,
    last_check_in::date as ultimo_checkin,
    CASE 
        WHEN completed THEN '✅ Completo'
        ELSE '🔄 Em Progresso'
    END as status,
    created_at::date as criado_em,
    updated_at::timestamp as atualizado_em
FROM challenge_progress 
WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'
ORDER BY points DESC, total_check_ins DESC, last_check_in ASC;

-- ======================================
-- ✅ VALIDAÇÃO FINAL DE CONSISTÊNCIA
-- ======================================

SELECT '✅ VALIDAÇÃO FINAL DE CONSISTÊNCIA:' as titulo;

WITH validation_checks AS (
    SELECT 
        CASE 
            WHEN (SELECT COUNT(*) FROM challenge_progress WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675') = 3 
            THEN '✅ 3 usuários no ranking'
            ELSE '❌ Número incorreto de usuários'
        END as check_usuarios,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' 
                AND user_name = 'Usuário Teste 1' 
                AND position = 1 AND points = 30
            ) 
            THEN '✅ Usuário 1 em 1º lugar (30 pontos)'
            ELSE '❌ Usuário 1 não está correto'
        END as check_user1,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' 
                AND user_name = 'Usuário Teste 2' 
                AND position = 2 AND points = 20
            ) 
            THEN '✅ Usuário 2 em 2º lugar (20 pontos)'
            ELSE '❌ Usuário 2 não está correto'
        END as check_user2,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' 
                AND user_name = 'Usuário Teste 3' 
                AND position = 3 AND points = 10
            ) 
            THEN '✅ Usuário 3 em 3º lugar (10 pontos)'
            ELSE '❌ Usuário 3 não está correto'
        END as check_user3,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' 
                AND (check_ins_count != total_check_ins OR check_ins_count IS NULL OR total_check_ins IS NULL)
            ) 
            THEN '✅ check_ins_count = total_check_ins'
            ELSE '❌ Inconsistência nos check-ins'
        END as check_consistency,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT 1 FROM challenge_progress 
                WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' 
                AND (user_name IS NULL OR user_name = '')
            ) 
            THEN '✅ Todos têm user_name preenchido'
            ELSE '❌ user_name vazio encontrado'
        END as check_usernames,
        
        CASE 
            WHEN NOT EXISTS (
                SELECT position, COUNT(*) 
                FROM challenge_progress 
                WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' 
                GROUP BY position 
                HAVING COUNT(*) > 1
            ) 
            THEN '✅ Posições únicas no ranking'
            ELSE '❌ Posições duplicadas encontradas'
        END as check_positions
)
SELECT 
    check_usuarios as resultado
FROM validation_checks
UNION ALL
SELECT check_user1 FROM validation_checks
UNION ALL  
SELECT check_user2 FROM validation_checks
UNION ALL
SELECT check_user3 FROM validation_checks
UNION ALL
SELECT check_consistency FROM validation_checks
UNION ALL
SELECT check_usernames FROM validation_checks
UNION ALL
SELECT check_positions FROM validation_checks;

-- ======================================
-- 🎉 RESULTADO FINAL
-- ======================================

WITH final_validation AS (
    SELECT 
        CASE 
            WHEN (
                (SELECT COUNT(*) FROM challenge_progress WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675') = 3 
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' AND user_name = 'Usuário Teste 1' AND position = 1 AND points = 30)
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' AND user_name = 'Usuário Teste 2' AND position = 2 AND points = 20)
                AND EXISTS (SELECT 1 FROM challenge_progress WHERE challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675' AND user_name = 'Usuário Teste 3' AND position = 3 AND points = 10)
            )
            THEN '🎉 SUCESSO! SISTEMA DE RANKING 100% FUNCIONAL!'
            ELSE '❌ FALHA! Sistema com problemas'
        END as resultado_final
)
SELECT resultado_final FROM final_validation; 