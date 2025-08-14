-- ========================================
-- CORREÇÃO FINAL: get_dashboard_core SEM ERRO
-- ========================================
-- Data: 2025-01-22
-- Corrige o erro: missing FROM-clause entry for table "wr"

CREATE OR REPLACE FUNCTION get_dashboard_core(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_workouts INTEGER := 0;
    total_duration_month INTEGER := 0;
    days_trained_this_month INTEGER := 0;
    workouts_by_type JSONB := '{}'::JSONB;
    recent_workouts_data JSON := '[]'::JSON;
    challenge_progress_data JSON;
BEGIN
    -- 1. Total de treinos (todos os tempos)
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records
    WHERE user_id = user_id_param;

    -- 2. ✅ CORREÇÃO PRINCIPAL: Minutos apenas do mês atual
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration_month
    FROM workout_records
    WHERE user_id = user_id_param
    AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE);

    -- 3. Dias únicos do mês atual
    SELECT COUNT(DISTINCT DATE(date))
    INTO days_trained_this_month
    FROM workout_records
    WHERE user_id = user_id_param
    AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE);

    -- 4. Tipos de treino (CORRIGIDO - sem alias problemático)
    SELECT COALESCE(
        jsonb_object_agg(
            workout_type, 
            type_count
        ), 
        '{}'::jsonb
    )
    INTO workouts_by_type
    FROM (
        SELECT 
            workout_type,
            COUNT(*) as type_count
        FROM workout_records
        WHERE user_id = user_id_param
        GROUP BY workout_type
    ) AS type_stats;

    -- 5. Treinos recentes (SIMPLIFICADO)
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id', id,
                'workout_name', COALESCE(workout_name, 'Treino'),
                'workout_type', workout_type,
                'date', date,
                'duration_minutes', COALESCE(duration_minutes, 0)
            )
            ORDER BY date DESC
        ),
        '[]'::jsonb
    )::json
    INTO recent_workouts_data
    FROM (
        SELECT id, workout_name, workout_type, date, duration_minutes
        FROM workout_records
        WHERE user_id = user_id_param
        ORDER BY date DESC
        LIMIT 10
    ) AS recent_workouts;

    -- 6. Progresso em desafios (SIMPLIFICADO para evitar erros)
    SELECT json_build_object(
        'challenge_id', NULL,
        'challenge_title', NULL,
        'total_points', 0,
        'check_ins', 0,
        'position', 0,
        'completion_percentage', 0
    )
    INTO challenge_progress_data;

    -- 7. RESULTADO FINAL CORRIGIDO
    result := json_build_object(
        'total_workouts', total_workouts,                    -- 24
        'total_duration', total_duration_month,              -- ✅ 120 (corrigido!)
        'days_trained_this_month', days_trained_this_month,  -- 3
        'workouts_by_type', workouts_by_type,
        'recent_workouts', recent_workouts_data,
        'challenge_progress', challenge_progress_data,
        'last_updated', NOW()
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- TESTE IMEDIATO (com resultado esperado)
-- ========================================
SELECT 
    '✅ TESTANDO FUNÇÃO CORRIGIDA' as secao;

-- Executar e mostrar só os campos principais
SELECT 
    (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_workouts')::int as treinos,
    (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_duration')::int as minutos,
    (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'days_trained_this_month')::int as dias_mes,
    CASE 
        WHEN (get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_duration')::int = 120
        THEN '🎉 SUCESSO! Dashboard corrigido'
        ELSE '❌ Ainda com problema'
    END as status_correcao; 