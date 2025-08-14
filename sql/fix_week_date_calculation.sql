-- ========================================
-- CORREÇÃO: CÁLCULO DE DATAS DE SEMANA
-- ========================================
-- Data: 2025-07-28
-- Problema: date_trunc('week') pode começar no domingo, mas queremos segunda-feira

-- Função para calcular início da semana corretamente (sempre segunda-feira)
CREATE OR REPLACE FUNCTION get_week_start_monday(input_date DATE DEFAULT CURRENT_DATE)
RETURNS DATE AS $$
BEGIN
    -- Garantir que a semana sempre comece na segunda-feira
    RETURN input_date - (EXTRACT(DOW FROM input_date)::INTEGER - 1) * INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql;

-- Função corrigida para obter ou criar meta semanal
CREATE OR REPLACE FUNCTION get_or_create_weekly_goal_expanded(
    p_user_id UUID,
    p_goal_type goal_preset_type DEFAULT 'custom',
    p_measurement_type goal_measurement_type DEFAULT 'minutes',
    p_target_value NUMERIC DEFAULT 180,
    p_goal_title VARCHAR(255) DEFAULT 'Meta Semanal',
    p_unit_label VARCHAR(50) DEFAULT 'min'
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    goal_type goal_preset_type,
    measurement_type goal_measurement_type,
    goal_title VARCHAR(255),
    goal_description TEXT,
    target_value NUMERIC,
    current_value NUMERIC,
    unit_label VARCHAR(50),
    week_start_date DATE,
    week_end_date DATE,
    completed BOOLEAN,
    percentage_completed NUMERIC
) AS $$
DECLARE
    v_current_week_start DATE;
    v_current_week_end DATE;
    v_goal_record RECORD;
BEGIN
    -- 🔧 CORREÇÃO: Calcular início da semana SEMPRE na segunda-feira
    v_current_week_start := get_week_start_monday(CURRENT_DATE);
    v_current_week_end := (v_current_week_start + interval '6 days')::date;
    
    RAISE LOG 'WEEK CALCULATION - Input date: %, Week start: %, Week end: %', 
              CURRENT_DATE, v_current_week_start, v_current_week_end;
    
    -- Tentar encontrar meta existente para a semana atual
    SELECT * INTO v_goal_record
    FROM weekly_goals_expanded wge
    WHERE wge.user_id = p_user_id 
      AND wge.week_start_date = v_current_week_start
      AND wge.goal_type = p_goal_type
      AND wge.active = true
    ORDER BY wge.created_at DESC
    LIMIT 1;
    
    -- Se não existe, criar nova meta
    IF NOT FOUND THEN
        RAISE LOG 'Creating new goal for user % with week start %', p_user_id, v_current_week_start;
        
        INSERT INTO weekly_goals_expanded (
            user_id, 
            goal_type,
            measurement_type,
            goal_title,
            target_value,
            unit_label,
            week_start_date, 
            week_end_date
        ) VALUES (
            p_user_id, 
            p_goal_type,
            p_measurement_type,
            p_goal_title,
            p_target_value,
            p_unit_label,
            v_current_week_start, 
            v_current_week_end
        )
        RETURNING * INTO v_goal_record;
    ELSE
        RAISE LOG 'Found existing goal % for user % with week start %', 
                  v_goal_record.id, p_user_id, v_current_week_start;
    END IF;
    
    -- Calcular percentual de conclusão
    RETURN QUERY
    SELECT 
        v_goal_record.id,
        v_goal_record.user_id,
        v_goal_record.goal_type,
        v_goal_record.measurement_type,
        v_goal_record.goal_title,
        v_goal_record.goal_description,
        v_goal_record.target_value,
        v_goal_record.current_value,
        v_goal_record.unit_label,
        v_goal_record.week_start_date,
        v_goal_record.week_end_date,
        v_goal_record.completed,
        CASE 
            WHEN v_goal_record.target_value > 0 THEN 
                ROUND((v_goal_record.current_value / v_goal_record.target_value * 100)::numeric, 1)
            ELSE 0
        END as percentage_completed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permissões
GRANT EXECUTE ON FUNCTION get_week_start_monday TO authenticated;
GRANT EXECUTE ON FUNCTION get_or_create_weekly_goal_expanded TO authenticated; 