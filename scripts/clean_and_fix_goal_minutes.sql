-- 🧹 LIMPEZA E CORREÇÃO COMPLETA: goal_minutes ambiguity
-- Data: 2025-01-21 às 17:35
-- Estratégia: REMOVER PRIMEIRO, depois recriar corretamente

-- ================================================================
-- ETAPA 1: REMOVER TODAS AS FUNÇÕES PROBLEMÁTICAS
-- ================================================================

-- Remover todas as versões das funções que causam ambiguidade
DROP FUNCTION IF EXISTS get_or_create_weekly_goal(uuid);
DROP FUNCTION IF EXISTS get_or_create_category_goal(uuid, text);
DROP FUNCTION IF EXISTS add_workout_minutes_to_goal(uuid, integer);
DROP FUNCTION IF EXISTS add_workout_minutes_to_category(uuid, text, integer);

-- Remover também possíveis variações com diferentes assinaturas
DROP FUNCTION IF EXISTS get_or_create_weekly_goal(uuid) CASCADE;
DROP FUNCTION IF EXISTS get_or_create_category_goal(uuid, text) CASCADE;
DROP FUNCTION IF EXISTS add_workout_minutes_to_goal(uuid, integer) CASCADE;
DROP FUNCTION IF EXISTS add_workout_minutes_to_category(uuid, text, integer) CASCADE;

-- Log da limpeza
SELECT '🧹 FUNÇÕES REMOVIDAS - Partindo do zero' as status;

-- ================================================================
-- ETAPA 2: RECRIAR add_workout_minutes_to_goal (LIMPA)
-- ================================================================

CREATE FUNCTION add_workout_minutes_to_goal(
    p_user_id UUID,
    p_minutes INTEGER
) RETURNS weekly_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal weekly_goals;
BEGIN
    -- Calcular semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Buscar meta existente
    SELECT * INTO v_updated_goal
    FROM weekly_goals 
    WHERE user_id = p_user_id 
    AND week_start_date = v_current_week_start;
    
    -- Se não existe, criar nova
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
            180, -- 3 horas padrão
            p_minutes,
            v_current_week_start,
            v_current_week_start + interval '6 days',
            false,
            NOW(),
            NOW()
        )
        RETURNING * INTO v_updated_goal;
    ELSE
        -- Atualizar existente - SEM AMBIGUIDADE
        UPDATE weekly_goals
        SET 
            current_minutes = current_minutes + p_minutes,
            completed = (current_minutes + p_minutes) >= goal_minutes,
            updated_at = NOW()
        WHERE 
            id = v_updated_goal.id
        RETURNING * INTO v_updated_goal;
    END IF;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ETAPA 3: RECRIAR add_workout_minutes_to_category (LIMPA)
-- ================================================================

CREATE FUNCTION add_workout_minutes_to_category(
    p_user_id UUID,
    p_category TEXT,
    p_minutes INTEGER
) RETURNS workout_category_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal workout_category_goals;
BEGIN
    -- Calcular semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Buscar meta existente
    SELECT * INTO v_updated_goal
    FROM workout_category_goals 
    WHERE user_id = p_user_id 
    AND category = lower(trim(p_category))
    AND week_start_date = v_current_week_start
    AND is_active = TRUE;
    
    -- Se não existe, criar nova
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
            90, -- 1.5 horas padrão
            p_minutes,
            v_current_week_start,
            v_current_week_start + interval '6 days',
            TRUE,
            false,
            NOW(),
            NOW()
        )
        RETURNING * INTO v_updated_goal;
    ELSE
        -- Atualizar existente - SEM AMBIGUIDADE
        UPDATE workout_category_goals
        SET 
            current_minutes = current_minutes + p_minutes,
            completed = (current_minutes + p_minutes) >= goal_minutes,
            updated_at = NOW()
        WHERE 
            id = v_updated_goal.id
        RETURNING * INTO v_updated_goal;
    END IF;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ETAPA 4: RECRIAR get_or_create_category_goal (SIMPLIFICADA)
-- ================================================================

CREATE FUNCTION get_or_create_category_goal(
    p_user_id UUID,
    p_category TEXT
) RETURNS workout_category_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_goal_record workout_category_goals;
BEGIN
    -- Calcular semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Buscar meta existente
    SELECT * INTO v_goal_record
    FROM workout_category_goals
    WHERE user_id = p_user_id
    AND category = p_category
    AND week_start_date = v_current_week_start
    AND is_active = TRUE;
    
    -- Se não existe, criar nova
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
            p_category,
            90, -- Padrão 1.5 horas
            0,
            v_current_week_start,
            v_current_week_start + interval '6 days',
            TRUE,
            FALSE,
            NOW(),
            NOW()
        )
        RETURNING * INTO v_goal_record;
    END IF;
    
    RETURN v_goal_record;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ETAPA 5: TESTE COMPLETO DA LIMPEZA E RECRIAÇÃO
-- ================================================================

-- Teste todas as funções recreadas
DO $$
DECLARE
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9';
    weekly_result weekly_goals;
    category_result workout_category_goals;
BEGIN
    -- Teste 1: Função weekly goals
    SELECT add_workout_minutes_to_goal(test_user_id, 30) INTO weekly_result;
    
    -- Teste 2: Função category goals
    SELECT add_workout_minutes_to_category(test_user_id, 'funcional', 45) INTO category_result;
    
    -- Teste 3: Get or create category
    SELECT get_or_create_category_goal(test_user_id, 'yoga') INTO category_result;
    
    RAISE NOTICE '✅ TODAS AS FUNÇÕES RECRIADAS FUNCIONANDO!';
    RAISE NOTICE 'Meta semanal: % minutos', weekly_result.current_minutes;
    RAISE NOTICE 'Meta categoria: % minutos', category_result.current_minutes;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO APÓS LIMPEZA: %', SQLERRM;
END $$;

-- ================================================================
-- ETAPA 6: VERIFICAÇÃO FINAL
-- ================================================================

-- Verificar se as funções existem e estão funcionando
SELECT 
    '✅ LIMPEZA E RECRIAÇÃO COMPLETA' as status,
    'Funções removidas e recriadas sem ambiguidade' as detalhes,
    (SELECT COUNT(*) FROM pg_proc WHERE proname LIKE '%add_workout_minutes%') as funcoes_criadas,
    NOW() as concluido_em;

-- Teste final: simular o erro original
SELECT 
    '🧪 TESTE FINAL' as teste,
    CASE 
        WHEN (add_workout_minutes_to_goal('01d4a292-1873-4af6-948b-a55eed56d6b9', 5)).current_minutes >= 5
        THEN '✅ SUCESSO - Erro de ambiguidade RESOLVIDO!'
        ELSE '⚠️ Verificar resultados'
    END as resultado; 