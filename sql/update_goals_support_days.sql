-- ================================================================
-- ATUALIZAR FUNÇÃO set_category_goal PARA SUPORTAR DIAS E MINUTOS
-- ================================================================

-- Remover função existente
DROP FUNCTION IF EXISTS set_category_goal(UUID, TEXT, INTEGER);

-- Criar nova função que suporta tanto minutos quanto dias
CREATE OR REPLACE FUNCTION set_category_goal(
    p_user_id UUID,
    p_category TEXT,
    p_goal_value INTEGER,
    p_goal_type TEXT DEFAULT 'minutes' -- 'minutes' ou 'days'
) RETURNS workout_category_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal workout_category_goals;
    v_goal_minutes INTEGER;
BEGIN
    -- Validar entrada
    IF p_category IS NULL OR trim(p_category) = '' THEN
        RAISE EXCEPTION 'Categoria não pode ser vazia';
    END IF;
    
    -- Converter dias para minutos se necessário
    IF p_goal_type = 'days' THEN
        -- Para metas de dias, assumir 30 minutos por dia
        v_goal_minutes := p_goal_value * 30;
        
        -- Validar limites para dias (1-48 dias = 30-1440 minutos)
        IF p_goal_value < 1 OR p_goal_value > 48 THEN
            RAISE EXCEPTION 'Meta de dias deve estar entre 1 e 48 dias';
        END IF;
    ELSE
        -- Para minutos, usar valor direto
        v_goal_minutes := p_goal_value;
        
        -- Validar limites para minutos (15-1440 minutos)
        IF p_goal_value < 15 OR p_goal_value > 1440 THEN
            RAISE EXCEPTION 'Meta de minutos deve estar entre 15 e 1440 minutos';
        END IF;
    END IF;
    
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Atualizar ou inserir meta
    INSERT INTO workout_category_goals (
        user_id, 
        category,
        goal_minutes, 
        week_start_date, 
        week_end_date,
        is_active
    )
    VALUES (
        p_user_id, 
        lower(trim(p_category)), -- Normalizar categoria
        v_goal_minutes, -- Sempre salvar em minutos
        v_current_week_start,
        v_current_week_start + interval '6 days',
        TRUE
    )
    ON CONFLICT (user_id, category, week_start_date)
    DO UPDATE SET 
        goal_minutes = EXCLUDED.goal_minutes,
        is_active = TRUE,
        updated_at = NOW()
    RETURNING * INTO v_updated_goal;
    
    -- Verificar se já completou com a nova meta
    UPDATE workout_category_goals
    SET completed = (current_minutes >= goal_minutes)
    WHERE id = v_updated_goal.id;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- Manter compatibilidade com versão antiga (só minutos)
CREATE OR REPLACE FUNCTION set_category_goal(
    p_user_id UUID,
    p_category TEXT,
    p_goal_minutes INTEGER
) RETURNS workout_category_goals AS $$
BEGIN
    RETURN set_category_goal(p_user_id, p_category, p_goal_minutes, 'minutes');
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FUNÇÃO PARA ADICIONAR CHECK-IN DE DIAS
-- ================================================================

CREATE OR REPLACE FUNCTION add_daily_checkin(
    p_user_id UUID,
    p_category TEXT
) RETURNS workout_category_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal workout_category_goals;
BEGIN
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Buscar meta da semana atual
    SELECT * INTO v_updated_goal
    FROM workout_category_goals 
    WHERE user_id = p_user_id 
    AND category = lower(trim(p_category))
    AND week_start_date = v_current_week_start
    AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Meta não encontrada para categoria: %', p_category;
    END IF;
    
    -- Adicionar 30 minutos (equivalente a 1 dia)
    UPDATE workout_category_goals
    SET 
        current_minutes = current_minutes + 30,
        completed = (current_minutes + 30) >= goal_minutes,
        updated_at = NOW()
    WHERE id = v_updated_goal.id
    RETURNING * INTO v_updated_goal;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FUNÇÃO PARA OBTER PROGRESSO EM DIAS
-- ================================================================

CREATE OR REPLACE FUNCTION get_user_category_goals_with_days(
    p_user_id UUID
) RETURNS TABLE (
    id UUID,
    category TEXT,
    goal_minutes INTEGER,
    goal_days INTEGER,
    current_minutes INTEGER,
    current_days NUMERIC,
    percentage_completed NUMERIC,
    completed BOOLEAN,
    week_start_date DATE,
    week_end_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wcg.id,
        wcg.category,
        wcg.goal_minutes,
        (wcg.goal_minutes / 30) as goal_days, -- Converter minutos para dias
        wcg.current_minutes,
        ROUND(wcg.current_minutes::NUMERIC / 30, 1) as current_days, -- Converter minutos para dias
        CASE 
            WHEN wcg.goal_minutes > 0 THEN 
                ROUND((wcg.current_minutes::NUMERIC / wcg.goal_minutes::NUMERIC) * 100, 2)
            ELSE 0
        END as percentage_completed,
        wcg.completed,
        wcg.week_start_date,
        wcg.week_end_date
    FROM workout_category_goals wcg
    WHERE wcg.user_id = p_user_id
    AND wcg.week_start_date = date_trunc('week', CURRENT_DATE)::date
    AND wcg.is_active = TRUE
    ORDER BY wcg.category;
END;
$$ LANGUAGE plpgsql;
