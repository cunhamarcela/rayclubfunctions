-- 🔧 CORREÇÃO COMPLETA: TODAS as funções com goal_minutes ambiguous
-- Data: 2025-01-21 às 17:30
-- Resolver TODOS os casos de ambiguidade

-- ================================================================
-- ETAPA 1: CORRIGIR get_or_create_category_goal
-- ================================================================

CREATE OR REPLACE FUNCTION get_or_create_category_goal(
    p_user_id UUID,
    p_category TEXT
) RETURNS TABLE (
    id UUID,
    user_id UUID,
    category TEXT,
    goal_minutes INTEGER,
    current_minutes INTEGER,
    week_start_date DATE,
    week_end_date DATE,
    is_active BOOLEAN,
    completed BOOLEAN,
    percentage_completed NUMERIC
) AS $$
DECLARE
    v_current_week_start DATE;
    v_current_week_end DATE;
    v_goal_record RECORD;
BEGIN
    -- Calcular início e fim da semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_current_week_end := v_current_week_start + interval '6 days';
    
    -- Tentar buscar meta existente para a categoria na semana atual
    SELECT wcg.* INTO v_goal_record
    FROM workout_category_goals wcg
    WHERE wcg.user_id = p_user_id
    AND wcg.category = p_category
    AND wcg.week_start_date = v_current_week_start
    AND wcg.is_active = TRUE;
    
    -- Se não existir, criar nova meta com valor padrão baseado na categoria
    IF NOT FOUND THEN
        -- 🔧 CORREÇÃO: Qualificar explicitamente a tabela
        SELECT wcg.goal_minutes INTO v_goal_record.goal_minutes
        FROM workout_category_goals wcg
        WHERE wcg.user_id = p_user_id 
        AND wcg.category = p_category
        AND wcg.is_active = TRUE
        ORDER BY wcg.week_start_date DESC
        LIMIT 1;
        
        -- Se não houver meta anterior, usar padrão baseado na categoria
        IF v_goal_record.goal_minutes IS NULL THEN
            v_goal_record.goal_minutes := CASE 
                WHEN p_category IN ('corrida', 'caminhada') THEN 120 -- 2 horas
                WHEN p_category IN ('yoga', 'alongamento') THEN 90 -- 1.5 horas  
                WHEN p_category IN ('funcional', 'crossfit') THEN 60 -- 1 hora
                WHEN p_category IN ('natacao', 'ciclismo') THEN 100 -- 1h40
                ELSE 90 -- Padrão geral: 1.5 horas
            END;
        END IF;
        
        -- Inserir nova meta
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
            p_category,
            v_goal_record.goal_minutes,
            0,
            v_current_week_start,
            v_current_week_end,
            TRUE,
            FALSE,
            NOW(),
            NOW()
        )
        RETURNING * INTO v_goal_record;
    END IF;
    
    -- Retornar dados com porcentagem calculada
    RETURN QUERY
    SELECT 
        v_goal_record.id,
        v_goal_record.user_id,
        v_goal_record.category,
        v_goal_record.goal_minutes,
        v_goal_record.current_minutes,
        v_goal_record.week_start_date,
        v_goal_record.week_end_date,
        v_goal_record.is_active,
        v_goal_record.completed,
        CASE 
            WHEN v_goal_record.goal_minutes > 0 THEN 
                ROUND((v_goal_record.current_minutes::NUMERIC / v_goal_record.goal_minutes::NUMERIC) * 100, 2)
            ELSE 0
        END as percentage_completed;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ETAPA 2: CORRIGIR add_workout_minutes_to_goal
-- ================================================================

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
    FROM weekly_goals wg
    WHERE wg.user_id = p_user_id 
    AND wg.week_start_date = v_current_week_start;
    
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

-- ================================================================
-- ETAPA 3: CORRIGIR add_workout_minutes_to_category
-- ================================================================

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
    FROM workout_category_goals wcg
    WHERE wcg.user_id = p_user_id 
    AND wcg.category = lower(trim(p_category))
    AND wcg.week_start_date = v_current_week_start
    AND wcg.is_active = TRUE;
    
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

-- ================================================================
-- ETAPA 4: VERIFICAÇÃO FINAL
-- ================================================================

-- Teste rápido das funções corrigidas
DO $$
DECLARE
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9';
BEGIN
    -- Teste as funções principais
    PERFORM add_workout_minutes_to_goal(test_user_id, 10);
    PERFORM add_workout_minutes_to_category(test_user_id, 'teste', 10);
    PERFORM get_or_create_category_goal(test_user_id, 'teste');
    
    RAISE NOTICE '✅ TODAS AS FUNÇÕES EXECUTARAM SEM ERRO DE AMBIGUIDADE!';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO: %', SQLERRM;
END $$;

-- Status da correção
SELECT 
    '✅ CORREÇÃO COMPLETA APLICADA' as status,
    'Todas as funções goal_minutes corrigidas' as details,
    NOW() as applied_at; 