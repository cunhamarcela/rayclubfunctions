-- TESTE ESPECÍFICO PARA MARCELA - IDs FORNECIDOS
-- user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- challenge_id: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- =====================================================
-- 1. VERIFICAR ESTADO ATUAL
-- =====================================================

-- Verificar dados do usuário
SELECT 
    '👤 DADOS DO USUÁRIO' as status,
    name,
    email,
    created_at
FROM profiles 
WHERE id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- Verificar dados do desafio
SELECT 
    '🏆 DADOS DO DESAFIO' as status,
    name,
    start_date,
    end_date,
    points as points_per_checkin,
    CASE 
        WHEN NOW() BETWEEN start_date AND end_date THEN 'ATIVO'
        WHEN NOW() < start_date THEN 'FUTURO'
        ELSE 'FINALIZADO'
    END as status_desafio
FROM challenges 
WHERE id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- =====================================================
-- 2. VERIFICAR PROGRESSO ATUAL
-- =====================================================

-- Progresso registrado
SELECT 
    '📊 PROGRESSO ATUAL' as status,
    points,
    check_ins_count,
    total_check_ins,
    last_check_in,
    position,
    completion_percentage,
    updated_at
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Check-ins reais na tabela
SELECT 
    '✅ CHECK-INS REAIS' as status,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT DATE(check_in_date)) as dias_unicos,
    MIN(check_in_date) as primeiro_checkin,
    MAX(check_in_date) as ultimo_checkin,
    SUM(COALESCE(points, 10)) as total_points_calculado
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Treinos relacionados
SELECT 
    '🏋️ TREINOS RELACIONADOS' as status,
    COUNT(*) as total_treinos,
    MIN(date) as primeiro_treino,
    MAX(date) as ultimo_treino,
    AVG(duration_minutes)::integer as duracao_media
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- =====================================================
-- 3. VERIFICAR CONSISTÊNCIA
-- =====================================================

-- Verificar se há check-ins órfãos para este usuário
SELECT 
    '🔍 VERIFICAÇÃO DE SAÚDE' as status,
    COUNT(*) as checkins_orfaos
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON wr.id = cci.workout_id::uuid
WHERE cci.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND wr.id IS NULL 
  AND cci.workout_id IS NOT NULL;

-- Verificar se os pontos estão corretos
WITH real_stats AS (
    SELECT 
        COUNT(DISTINCT DATE(check_in_date)) as real_checkins,
        COUNT(DISTINCT DATE(check_in_date)) * 10 as real_points
    FROM challenge_check_ins cci
    WHERE cci.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
      AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
      AND (cci.workout_id IS NULL OR EXISTS (
          SELECT 1 FROM workout_records wr 
          WHERE wr.id = cci.workout_id::uuid
      ))
),
progress_stats AS (
    SELECT 
        COALESCE(points, 0) as progress_points,
        COALESCE(check_ins_count, 0) as progress_checkins
    FROM challenge_progress
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
      AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
SELECT 
    '⚖️ COMPARAÇÃO PONTOS' as status,
    rs.real_points as pontos_reais,
    ps.progress_points as pontos_registrados,
    rs.real_checkins as checkins_reais,
    ps.progress_checkins as checkins_registrados,
    CASE 
        WHEN rs.real_points = ps.progress_points AND rs.real_checkins = ps.progress_checkins 
        THEN '✅ CONSISTENTE'
        ELSE '❌ INCONSISTENTE'
    END as status_consistencia
FROM real_stats rs, progress_stats ps;

-- =====================================================
-- 4. LISTAR CHECK-INS DETALHADAMENTE
-- =====================================================

-- Ver todos os check-ins em detalhes
SELECT 
    '📝 HISTÓRICO CHECK-INS' as status,
    check_in_date::date as data,
    workout_name,
    workout_type,
    duration_minutes,
    points,
    workout_id,
    CASE 
        WHEN workout_id IS NULL THEN '✅ Check-in manual'
        WHEN EXISTS (SELECT 1 FROM workout_records wr WHERE wr.id = workout_id::uuid) 
        THEN '✅ Treino válido'
        ELSE '❌ Treino removido'
    END as status_treino,
    created_at
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY check_in_date DESC;

-- =====================================================
-- 5. FUNÇÃO DE TESTE DE RECÁLCULO
-- =====================================================

-- Testar recálculo específico para este usuário
SELECT 
    '🔄 TESTE DE RECÁLCULO' as status,
    recalculate_challenge_progress_complete_fixed(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID
    ) as resultado_recalculo;

-- =====================================================
-- 6. VERIFICAR POSIÇÃO NO RANKING
-- =====================================================

-- Posição no ranking geral
SELECT 
    '🏅 POSIÇÃO NO RANKING' as status,
    ROW_NUMBER() OVER (ORDER BY points DESC, last_check_in ASC NULLS LAST) as posicao_real,
    cp.position as posicao_registrada,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY points DESC, last_check_in ASC NULLS LAST) = cp.position 
        THEN '✅ CORRETO'
        ELSE '❌ INCORRETO'
    END as status_ranking
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND cp.points > 0
ORDER BY cp.points DESC, cp.last_check_in ASC NULLS LAST
LIMIT 20;

-- =====================================================
-- 7. FUNÇÕES DE TESTE PARA SIMULAÇÃO
-- =====================================================

-- Função para simular criação e exclusão de treino
CREATE OR REPLACE FUNCTION test_workout_cycle_marcela()
RETURNS TABLE(
    step TEXT,
    description TEXT,
    result TEXT,
    test_timestamp TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    test_workout_id UUID;
    initial_points INTEGER;
    after_create_points INTEGER;
    after_delete_points INTEGER;
BEGIN
    -- Capturar pontos iniciais
    SELECT COALESCE(points, 0) INTO initial_points
    FROM challenge_progress
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
      AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

    -- STEP 1: Simular criação de treino
    INSERT INTO workout_records(
        id, user_id, challenge_id, workout_name, workout_type, 
        date, duration_minutes, created_at
    ) VALUES (
        gen_random_uuid(), 
        '01d4a292-1873-4af6-948b-a55eed56d6b9',
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82',
        'Teste Funcional', 'teste', 
        NOW(), 60, NOW()
    ) RETURNING id INTO test_workout_id;

    -- Simular check-in
    INSERT INTO challenge_check_ins(
        user_id, challenge_id, workout_id, check_in_date,
        workout_name, workout_type, duration_minutes, points
    ) VALUES (
        '01d4a292-1873-4af6-948b-a55eed56d6b9',
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82',
        test_workout_id::text,
        NOW(),
        'Teste Funcional', 'teste', 60, 10
    );

    -- Recalcular progresso
    PERFORM recalculate_challenge_progress_complete_fixed(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID
    );

    -- Verificar pontos após criação
    SELECT COALESCE(points, 0) INTO after_create_points
    FROM challenge_progress
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
      AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

    RETURN QUERY SELECT 
        '1. Criação'::TEXT,
        'Treino criado e check-in registrado'::TEXT,
        format('Pontos: %s → %s (+%s)', initial_points, after_create_points, after_create_points - initial_points)::TEXT,
        NOW();

    -- STEP 2: Simular exclusão usando a função corrigida
    PERFORM delete_workout_and_refresh_fixed(
        test_workout_id,
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID
    );

    -- Verificar pontos após exclusão
    SELECT COALESCE(points, 0) INTO after_delete_points
    FROM challenge_progress
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
      AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

    RETURN QUERY SELECT 
        '2. Exclusão'::TEXT,
        'Treino excluído e progresso recalculado'::TEXT,
        format('Pontos: %s → %s (%s)', after_create_points, after_delete_points, 
               CASE WHEN after_delete_points = initial_points THEN '✅ CORRETO' ELSE '❌ ERRO' END)::TEXT,
        NOW();

    RETURN QUERY SELECT 
        '3. Resultado'::TEXT,
        'Teste completo de ciclo'::TEXT,
        CASE 
            WHEN after_delete_points = initial_points 
            THEN '✅ SISTEMA FUNCIONANDO CORRETAMENTE'
            ELSE '❌ PROBLEMA NO RECÁLCULO'
        END::TEXT,
        NOW();

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 
        'ERRO'::TEXT,
        'Falha no teste'::TEXT,
        SQLERRM::TEXT,
        NOW();
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. EXECUTAR TESTE COMPLETO
-- =====================================================

-- Executar teste do ciclo completo
SELECT * FROM test_workout_cycle_marcela();

-- Limpeza
DROP FUNCTION IF EXISTS test_workout_cycle_marcela();

-- Resultado final
SELECT 
    '🎯 TESTE CONCLUÍDO' as status,
    'Sistema testado para usuário específico' as resultado,
    NOW() as timestamp; 