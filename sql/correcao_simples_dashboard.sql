-- ========================================
-- CORREÇÃO SIMPLES: get_dashboard_core - MINUTOS MÊS ATUAL
-- ========================================
-- Versão simplificada para evitar erros

CREATE OR REPLACE FUNCTION get_dashboard_core(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_workouts INTEGER := 0;
    total_duration_month INTEGER := 0;
    days_trained_this_month INTEGER := 0;
BEGIN
    -- 1. Total de treinos (todos os tempos)
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records wr
    WHERE wr.user_id = user_id_param;

    -- 2. Minutos apenas do mês atual (CORREÇÃO PRINCIPAL)
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- 3. Dias únicos do mês atual
    SELECT COUNT(DISTINCT DATE(wr.date))
    INTO days_trained_this_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- 4. Resultado simples (sem partes complexas)
    result := json_build_object(
        'total_workouts', total_workouts,
        'total_duration', total_duration_month,  -- CORRIGIDO: apenas mês atual
        'days_trained_this_month', days_trained_this_month,
        'workouts_by_type', '{}'::jsonb,
        'recent_workouts', '[]'::json,
        'challenge_progress', json_build_object(
            'challenge_id', NULL,
            'total_points', 0,
            'check_ins', 0,
            'position', 0,
            'completion_percentage', 0
        ),
        'last_updated', NOW()
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 