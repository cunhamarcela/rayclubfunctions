-- ================================================================
-- SOLUÇÃO DEFINITIVA: REMOVER TODAS AS VERSÕES E RECRIAR LIMPA
-- ================================================================

-- 1. REMOVER TODAS AS VERSÕES POSSÍVEIS DA FUNÇÃO
DROP FUNCTION IF EXISTS set_category_goal(UUID, TEXT, INTEGER);
DROP FUNCTION IF EXISTS set_category_goal(UUID, TEXT, INTEGER, TEXT);

-- 2. CRIAR NOVA FUNÇÃO PRINCIPAL (4 PARÂMETROS)
CREATE OR REPLACE FUNCTION set_category_goal(
    p_user_id UUID,
    p_category TEXT,
    p_goal_value INTEGER,
    p_goal_type TEXT DEFAULT 'minutes'
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
    IF p_goal_type = 'dias' OR p_goal_type = 'days' THEN
        v_goal_minutes := p_goal_value * 30; -- 30 min por dia
        
        -- Validar limites para dias (1-48 dias)
        IF p_goal_value < 1 OR p_goal_value > 48 THEN
            RAISE EXCEPTION 'Meta de dias deve estar entre 1 e 48 dias';
        END IF;
    ELSE
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
        lower(trim(p_category)),
        v_goal_minutes,
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
    
    -- Verificar se já completou
    UPDATE workout_category_goals
    SET completed = (current_minutes >= goal_minutes)
    WHERE id = v_updated_goal.id;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- 3. CRIAR FUNÇÃO DE COMPATIBILIDADE (3 PARÂMETROS)
CREATE OR REPLACE FUNCTION set_category_goal(
    p_user_id UUID,
    p_category TEXT,
    p_goal_minutes INTEGER
) RETURNS workout_category_goals AS $$
BEGIN
    RETURN set_category_goal(p_user_id, p_category, p_goal_minutes, 'minutes');
END;
$$ LANGUAGE plpgsql;

-- 4. VERIFICAR SE AS FUNÇÕES FORAM CRIADAS CORRETAMENTE
SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments
FROM pg_proc 
WHERE proname = 'set_category_goal'
ORDER BY pronargs;
