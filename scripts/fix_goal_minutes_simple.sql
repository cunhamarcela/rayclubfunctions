-- 🔧 CORREÇÃO SIMPLES: Erro "column reference goal_minutes is ambiguous" 
-- Data: 2025-01-21 às 17:05
-- Problema: Funções SQL não qualificam qual tabela usar para goal_minutes

-- Corrigir função add_workout_minutes_to_goal
CREATE OR REPLACE FUNCTION add_workout_minutes_to_goal(
    p_user_id UUID,
    p_minutes INTEGER
) RETURNS weekly_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal weekly_goals;
BEGIN
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Garantir que existe uma meta para a semana atual
    PERFORM get_or_create_weekly_goal(p_user_id);
    
    -- 🔧 CORREÇÃO: Qualificar explicitamente com nome da tabela
    UPDATE weekly_goals
    SET 
        current_minutes = weekly_goals.current_minutes + p_minutes,
        completed = (weekly_goals.current_minutes + p_minutes) >= weekly_goals.goal_minutes
    WHERE 
        weekly_goals.user_id = p_user_id 
        AND weekly_goals.week_start_date = v_current_week_start
    RETURNING * INTO v_updated_goal;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- Corrigir função add_workout_minutes_to_category
CREATE OR REPLACE FUNCTION add_workout_minutes_to_category(
    p_user_id UUID,
    p_category TEXT,
    p_minutes INTEGER
) RETURNS workout_category_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal workout_category_goals;
BEGIN
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Garantir que existe uma meta para esta categoria na semana atual
    PERFORM get_or_create_category_goal(p_user_id, p_category);
    
    -- 🔧 CORREÇÃO: Qualificar explicitamente com nome da tabela
    UPDATE workout_category_goals
    SET 
        current_minutes = workout_category_goals.current_minutes + p_minutes,
        completed = (workout_category_goals.current_minutes + p_minutes) >= workout_category_goals.goal_minutes,
        updated_at = NOW()
    WHERE 
        workout_category_goals.user_id = p_user_id 
        AND workout_category_goals.category = lower(trim(p_category))
        AND workout_category_goals.week_start_date = v_current_week_start
        AND workout_category_goals.is_active = TRUE
    RETURNING * INTO v_updated_goal;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- Log da correção
SELECT 
    '✅ CORREÇÃO APLICADA - goal_minutes ambiguity fixed' as status,
    NOW() as applied_at; 