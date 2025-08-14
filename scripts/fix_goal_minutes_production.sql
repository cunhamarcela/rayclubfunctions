-- 🔧 CORREÇÃO PARA PRODUÇÃO: Erro goal_minutes ambiguous
-- Data: 2025-01-21 às 17:15
-- Para aplicar direto no Supabase SQL Editor

-- ETAPA 1: Remover função conflitante se existir
DROP FUNCTION IF EXISTS get_or_create_weekly_goal(uuid);

-- ETAPA 2: Corrigir função add_workout_minutes_to_goal (principal causadora do erro)
CREATE OR REPLACE FUNCTION add_workout_minutes_to_goal(
    p_user_id UUID,
    p_minutes INTEGER
) RETURNS weekly_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal weekly_goals;
BEGIN
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Buscar meta existente para a semana atual
    SELECT * INTO v_updated_goal
    FROM weekly_goals
    WHERE user_id = p_user_id 
    AND week_start_date = v_current_week_start;
    
    -- Se não existir, criar nova meta
    IF NOT FOUND THEN
        INSERT INTO weekly_goals (
            user_id, 
            goal_minutes, 
            current_minutes,
            week_start_date,
            week_end_date,
            completed,
            created_at,
            updated_at
        ) VALUES (
            p_user_id,
            180, -- Meta padrão: 3 horas
            p_minutes, -- Começar com os minutos atuais
            v_current_week_start,
            v_current_week_start + interval '6 days',
            false,
            NOW(),
            NOW()
        )
        RETURNING * INTO v_updated_goal;
    ELSE
        -- 🔧 CORREÇÃO: Qualificar explicitamente com nome da tabela
        UPDATE weekly_goals
        SET 
            current_minutes = weekly_goals.current_minutes + p_minutes,
            completed = (weekly_goals.current_minutes + p_minutes) >= weekly_goals.goal_minutes,
            updated_at = NOW()
        WHERE 
            weekly_goals.user_id = p_user_id 
            AND weekly_goals.week_start_date = v_current_week_start
        RETURNING * INTO v_updated_goal;
    END IF;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- ETAPA 3: Corrigir função add_workout_minutes_to_category
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
    
    -- Buscar meta existente para a categoria na semana atual
    SELECT * INTO v_updated_goal
    FROM workout_category_goals
    WHERE user_id = p_user_id 
    AND category = lower(trim(p_category))
    AND week_start_date = v_current_week_start
    AND is_active = TRUE;
    
    -- Se não existir, criar nova meta
    IF NOT FOUND THEN
        INSERT INTO workout_category_goals (
            user_id, 
            category,
            goal_minutes, 
            current_minutes,
            week_start_date,
            week_end_date,
            is_active,
            completed,
            created_at,
            updated_at
        ) VALUES (
            p_user_id,
            lower(trim(p_category)),
            90, -- Meta padrão: 1.5 horas
            p_minutes, -- Começar com os minutos atuais
            v_current_week_start,
            v_current_week_start + interval '6 days',
            TRUE,
            false,
            NOW(),
            NOW()
        )
        RETURNING * INTO v_updated_goal;
    ELSE
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
    END IF;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- ETAPA 4: Verificar se a correção funcionou
SELECT 
    '✅ CORREÇÃO APLICADA: goal_minutes ambiguity RESOLVIDO!' as status,
    'Funções add_workout_minutes_to_goal e add_workout_minutes_to_category corrigidas' as details,
    NOW() as applied_at; 