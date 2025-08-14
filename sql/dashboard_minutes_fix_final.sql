-- ========================================
-- CORREÇÃO: DASHBOARD - MINUTOS APENAS DO MÊS ATUAL
-- ========================================
-- Data: 2025-01-22
-- Execute este script no SQL Editor do Supabase Dashboard
-- 
-- ANTES: Campo "Minutos" mostrava total de todos os treinos (ex: 1119)
-- DEPOIS: Campo "Minutos" mostra apenas treinos do mês atual
--
-- MANTÉM: Total de treinos (24), Dias no mês (3), Check-ins (12)

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
    -- 1. Total de treinos de TODOS os tempos (mantém o valor atual de 24)
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records wr
    WHERE wr.user_id = user_id_param;

    -- 2. Minutos APENAS do mês atual (ESTA É A MUDANÇA PRINCIPAL)
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- 3. Calcular dias únicos treinados no mês atual
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

    -- 5. Buscar progresso em desafios
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

    -- 6. Buscar treinos recentes
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

    -- 7. CONSTRUIR RESULTADO FINAL
    result := json_build_object(
        'total_workouts', total_workouts,                    -- Mantém: 24
        'total_duration', total_duration_month,              -- MUDANÇA: apenas do mês atual
        'days_trained_this_month', days_trained_this_month,  -- Mantém: 3
        'workouts_by_type', workouts_by_type,
        'recent_workouts', recent_workouts_data,
        'challenge_progress', challenge_progress_data,
        'last_updated', NOW()
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- TESTE DA FUNÇÃO (Opcional)
-- ========================================
-- Descomente as linhas abaixo para testar:

/*
DO $$
DECLARE
    test_result JSON;
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9'; -- Substitua por um UUID real
BEGIN
    SELECT get_dashboard_core(test_user_id) INTO test_result;
    
    RAISE NOTICE '📊 Total de treinos: %', (test_result->>'total_workouts')::int;
    RAISE NOTICE '⏱️ Minutos do mês: %', (test_result->>'total_duration')::int;
    RAISE NOTICE '📅 Dias treinados no mês: %', (test_result->>'days_trained_this_month')::int;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro: %', SQLERRM;
END $$;
*/

-- ✅ PRONTO! A função get_dashboard_core está criada.
-- ✅ O campo "Minutos" no dashboard agora mostra apenas minutos do mês atual.
-- ✅ Os outros campos (treinos, dias no mês, check-ins) permanecem inalterados. 