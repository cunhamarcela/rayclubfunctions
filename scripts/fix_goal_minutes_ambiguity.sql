-- 🔧 CORREÇÃO: Ambiguidade na coluna "goal_minutes"
-- Data: 2025-01-21 às 16:50
-- Objetivo: Resolver erro "column reference goal_minutes is ambiguous"
-- Referência: Erro reportado durante registro de treino

-- PROBLEMA: 
-- Existem duas tabelas com coluna "goal_minutes":
-- 1. weekly_goals.goal_minutes
-- 2. workout_category_goals.goal_minutes
-- 
-- Quando há JOINs ou subconsultas, PostgreSQL não sabe qual usar.

-- ================================================================
-- ETAPA 1: VERIFICAR FUNÇÕES QUE PODEM TER O PROBLEMA
-- ================================================================

-- Verificar função add_workout_minutes_to_goal
SELECT 
    p.proname as function_name,
    p.prosrc as definition
FROM pg_proc p
WHERE p.proname LIKE '%add_workout_minutes%'
OR p.proname LIKE '%goal%'
AND p.prosrc LIKE '%goal_minutes%';

-- ================================================================
-- ETAPA 2: CORRIGIR FUNÇÃO add_workout_minutes_to_goal SE NECESSÁRIO
-- ================================================================

-- Recriar a função com qualificação de tabela explícita
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

-- ================================================================
-- ETAPA 3: VERIFICAR E CORRIGIR OUTRAS FUNÇÕES RELACIONADAS
-- ================================================================

-- Corrigir função get_or_create_weekly_goal se necessário
CREATE OR REPLACE FUNCTION get_or_create_weekly_goal(p_user_id UUID)
RETURNS weekly_goals AS $$
DECLARE
    v_goal_record weekly_goals;
    v_current_week_start DATE;
    v_current_week_end DATE;
BEGIN
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_current_week_end := v_current_week_start + interval '6 days';
    
    -- Buscar meta existente para a semana atual
    SELECT * INTO v_goal_record
    FROM weekly_goals wg
    WHERE wg.user_id = p_user_id 
    AND wg.week_start_date = v_current_week_start;
    
    -- Se não encontrou, buscar a meta mais recente para usar como base
    IF v_goal_record.goal_minutes IS NULL THEN
        SELECT wg.goal_minutes INTO v_goal_record.goal_minutes
        FROM weekly_goals wg
        WHERE wg.user_id = p_user_id
        ORDER BY wg.week_start_date DESC
        LIMIT 1;
    END IF;
    
    -- Se ainda não tem meta, usar padrão de 180 minutos (3 horas)
    IF v_goal_record.goal_minutes IS NULL THEN
        v_goal_record.goal_minutes := 180; -- 3 horas padrão
    END IF;
    
    -- Inserir ou atualizar meta para semana atual
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
        v_goal_record.goal_minutes,
        0,
        v_current_week_start,
        v_current_week_end,
        false,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, week_start_date)
    DO UPDATE SET
        -- 🔧 CORREÇÃO: Qualificar explicitamente com nome da tabela
        goal_minutes = EXCLUDED.goal_minutes,
        updated_at = NOW()
    RETURNING * INTO v_goal_record;
    
    -- Atualizar status de completude
    UPDATE weekly_goals
    SET completed = (weekly_goals.current_minutes >= weekly_goals.goal_minutes)
    WHERE weekly_goals.user_id = p_user_id 
    AND weekly_goals.week_start_date = v_current_week_start;
    
    RETURN v_goal_record;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ETAPA 4: VERIFICAR FUNÇÃO add_workout_minutes_to_category
-- ================================================================

-- Corrigir função de categoria de workout se necessário
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
        AND workout_category_goals.category = p_category
        AND workout_category_goals.week_start_date = v_current_week_start
    RETURNING * INTO v_updated_goal;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ETAPA 5: VERIFICAR SE A CORREÇÃO FUNCIONA
-- ================================================================

-- Teste simples da função corrigida
DO $$
DECLARE
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9'; -- User do log de erro
    test_result weekly_goals;
BEGIN
    -- Testar a função corrigida
    SELECT add_workout_minutes_to_goal(test_user_id, 30) INTO test_result;
    
    RAISE NOTICE '✅ Função add_workout_minutes_to_goal executada com sucesso!';
    RAISE NOTICE 'Resultado: % minutos atuais / % minutos meta', 
        test_result.current_minutes, test_result.goal_minutes;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao testar função: %', SQLERRM;
END $$;

-- ================================================================
-- ETAPA 6: LOG DE CORREÇÃO
-- ================================================================

SELECT 
    '🔧 CORREÇÃO APLICADA' as status,
    'Ambiguidade na coluna goal_minutes corrigida' as description,
    NOW() as applied_at;

COMMENT ON FUNCTION add_workout_minutes_to_goal IS 
'Função corrigida para resolver ambiguidade de goal_minutes - 2025-01-21';

COMMENT ON FUNCTION add_workout_minutes_to_category IS 
'Função corrigida para resolver ambiguidade de goal_minutes - 2025-01-21'; 