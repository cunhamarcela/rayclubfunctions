-- ========================================
-- CORREÇÃO: get_dashboard_core - MINUTOS APENAS DO MÊS
-- ========================================
-- Data: 2025-01-22
-- Problema encontrado: Função retorna 1119 minutos (todos) em vez de 120 (julho/2025)
-- Usuário teste: Marcela (01d4a292-1873-4af6-948b-a55eed56d6b9)

-- ANTES: 1119 minutos (todos os treinos)
-- DEPOIS: 120 minutos (apenas julho/2025)

-- 1. BACKUP DA FUNÇÃO ATUAL (opcional)
-- Para reverter se necessário:
-- DROP FUNCTION IF EXISTS get_dashboard_core_backup;
-- CREATE FUNCTION get_dashboard_core_backup AS SELECT get_dashboard_core;

-- 2. APLICAR A CORREÇÃO
CREATE OR REPLACE FUNCTION get_dashboard_core(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_workouts INTEGER := 0;
    total_duration_month INTEGER := 0;  -- APENAS do mês atual
    days_trained_this_month INTEGER := 0;
    workouts_by_type JSONB := '{}'::JSONB;
    challenge_progress_data JSON;
    recent_workouts_data JSON;
BEGIN
    -- 1. Total de treinos de TODOS os tempos (mantém 24)
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records wr
    WHERE wr.user_id = user_id_param;

    -- 2. ✅ CORREÇÃO PRINCIPAL: Minutos APENAS do mês atual
    -- Filtra por ano e mês atual (julho/2025 = 120 minutos)
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- 3. Dias únicos treinados no mês atual (mantém 3)
    SELECT COUNT(DISTINCT DATE(wr.date))
    INTO days_trained_this_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- 4. Tipos de treino (baseado em todos os treinos)
    SELECT COALESCE(
        jsonb_object_agg(
            wr.workout_type, 
            type_count
        ), 
        '{}'::jsonb
    )
    INTO workouts_by_type
    FROM (
        SELECT 
            wr.workout_type,
            COUNT(*) as type_count
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        GROUP BY wr.workout_type
    ) type_stats;

    -- 5. Progresso em desafios
    WITH active_challenge AS (
        SELECT 
            c.id as challenge_id,
            c.title
        FROM challenges c
        JOIN challenge_participants cp ON c.id = cp.challenge_id
        WHERE 
            cp.user_id = user_id_param
            AND c.end_date >= CURRENT_DATE
            AND c.active = true
        ORDER BY c.is_official DESC, c.end_date ASC
        LIMIT 1
    )
    SELECT 
        CASE WHEN COUNT(*) > 0 THEN
            json_build_object(
                'challenge_id', ac.challenge_id,
                'challenge_title', ac.title,
                'total_points', COALESCE(cp.points, 0),
                'check_ins', COALESCE(
                    CASE 
                        WHEN cp.check_ins_count IS NOT NULL THEN cp.check_ins_count
                        WHEN cp.total_check_ins IS NOT NULL THEN cp.total_check_ins
                        ELSE 0
                    END, 0
                ),
                'position', COALESCE(cp.position, 0),
                'completion_percentage', COALESCE(cp.completion_percentage, 0)
            )
        ELSE 
            json_build_object(
                'challenge_id', NULL,
                'challenge_title', NULL,
                'total_points', 0,
                'check_ins', 0,
                'position', 0,
                'completion_percentage', 0
            )
        END
    INTO challenge_progress_data
    FROM active_challenge ac
    LEFT JOIN challenge_progress cp ON cp.challenge_id = ac.challenge_id AND cp.user_id = user_id_param;

    -- 6. Treinos recentes
    SELECT COALESCE(
        json_agg(
            json_build_object(
                'id', wr.id,
                'workout_name', COALESCE(wr.workout_name, 'Treino'),
                'workout_type', wr.workout_type,
                'date', wr.date,
                'duration_minutes', COALESCE(wr.duration_minutes, 0)
            )
            ORDER BY wr.date DESC
        ),
        '[]'::json
    )
    INTO recent_workouts_data
    FROM (
        SELECT * FROM workout_records wr
        WHERE wr.user_id = user_id_param
        ORDER BY wr.date DESC
        LIMIT 10
    ) wr;

    -- 7. RESULTADO FINAL CORRIGIDO
    result := json_build_object(
        'total_workouts', total_workouts,                    -- 24 (mantém)
        'total_duration', total_duration_month,              -- ✅ 120 (corrigido!)
        'days_trained_this_month', days_trained_this_month,  -- 3 (mantém)
        'workouts_by_type', workouts_by_type,
        'recent_workouts', recent_workouts_data,
        'challenge_progress', challenge_progress_data,
        'last_updated', NOW()
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. TESTE IMEDIATO DA CORREÇÃO
DO $$
DECLARE
    test_result JSON;
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9';
BEGIN
    SELECT get_dashboard_core(test_user_id) INTO test_result;
    
    RAISE NOTICE '✅ RESULTADO APÓS CORREÇÃO:';
    RAISE NOTICE '  - Total treinos: % (deve ser 24)', (test_result->>'total_workouts')::int;
    RAISE NOTICE '  - Minutos: % (deve ser 120 - apenas julho)', (test_result->>'total_duration')::int;
    RAISE NOTICE '  - Dias no mês: % (deve ser 3)', (test_result->>'days_trained_this_month')::int;
    
    -- Verificar se a correção funcionou
    IF (test_result->>'total_duration')::int = 120 THEN
        RAISE NOTICE '🎉 SUCESSO! Dashboard agora mostra minutos apenas do mês atual';
    ELSE
        RAISE NOTICE '❌ FALHA! Valor esperado: 120, obtido: %', (test_result->>'total_duration')::int;
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

-- ========================================
-- RESUMO DA CORREÇÃO
-- ========================================
/*
✅ ANTES: Dashboard mostrava 1119 minutos (todos os treinos)
✅ DEPOIS: Dashboard mostra 120 minutos (apenas julho/2025)

✅ CAMPOS MANTIDOS:
- total_workouts: 24 (todos os treinos)
- days_trained_this_month: 3 (dias únicos do mês)
- challenge_progress: dados dos desafios

✅ CAMPO CORRIGIDO:
- total_duration: agora calcula apenas do mês atual

✅ COMPATIBILIDADE:
- Mesma estrutura JSON esperada pelo Flutter
- Mesmos parâmetros da função
- Sem quebra de funcionalidade
*/ 