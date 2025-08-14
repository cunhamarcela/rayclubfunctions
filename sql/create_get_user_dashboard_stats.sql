-- ========================================
-- FUNÇÃO GET_USER_DASHBOARD_STATS
-- ========================================
-- Data: 2025-01-27 21:12
-- Objetivo: Criar função que o Flutter está chamando mas que não existe
-- Solução: Usar get_dashboard_core (que já retorna dados mensais) como base

CREATE OR REPLACE FUNCTION get_user_dashboard_stats(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    dashboard_data JSON;
    result JSON;
BEGIN
    -- Buscar dados usando a função get_dashboard_core existente
    SELECT get_dashboard_core(user_id_param) INTO dashboard_data;
    
    -- Transformar para o formato esperado pelo DashboardService
    SELECT json_build_object(
        'workout_count', COALESCE((dashboard_data->>'total_workouts')::INTEGER, 0),
        'streak_days', COALESCE((dashboard_data->'challenge_progress'->>'check_ins')::INTEGER, 0),
        'total_minutes', COALESCE((dashboard_data->>'total_duration')::INTEGER, 0),
        'total_calories', 0, -- Placeholder até implementarmos cálculo de calorias
        'active_challenge_id', dashboard_data->'challenge_progress'->>'challenge_id',
        'active_challenge_name', dashboard_data->'challenge_progress'->>'challenge_title'
    ) INTO result;
    
    RETURN result;
    
EXCEPTION WHEN OTHERS THEN
    -- Em caso de erro, retornar dados vazios
    RETURN json_build_object(
        'workout_count', 0,
        'streak_days', 0,
        'total_minutes', 0,
        'total_calories', 0,
        'active_challenge_id', NULL,
        'active_challenge_name', NULL
    );
END;
$$ LANGUAGE plpgsql; 