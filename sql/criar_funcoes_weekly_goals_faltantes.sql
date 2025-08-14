-- ========================================
-- FUNÇÕES WEEKLY GOALS FALTANTES
-- ========================================
-- Data: 2025-01-27 22:30
-- Objetivo: Criar apenas as funções que faltam (não mexer na tabela existente)

-- ========================================
-- 1. FUNÇÃO: get_or_create_weekly_goal
-- ========================================

CREATE OR REPLACE FUNCTION get_or_create_weekly_goal(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    goal_minutes INTEGER,
    current_minutes INTEGER,
    week_start_date DATE,
    week_end_date DATE,
    completed BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_week_start DATE;
    current_week_end DATE;
    existing_goal weekly_goals%ROWTYPE;
BEGIN
    -- Calcular início e fim da semana atual (segunda a domingo)
    current_week_start := date_trunc('week', CURRENT_DATE);
    current_week_end := current_week_start + interval '6 days';
    
    -- Tentar encontrar goal existente para esta semana
    SELECT * INTO existing_goal
    FROM weekly_goals wg
    WHERE wg.user_id = p_user_id
    AND wg.week_start_date = current_week_start;
    
    -- Se não encontrou, criar novo
    IF NOT FOUND THEN
        INSERT INTO weekly_goals (
            user_id,
            goal_minutes,
            current_minutes,
            week_start_date,
            week_end_date,
            completed
        ) VALUES (
            p_user_id,
            180, -- Meta padrão: 180 minutos por semana
            0,   -- Começar com 0 minutos
            current_week_start,
            current_week_end,
            FALSE
        ) RETURNING * INTO existing_goal;
        
        RAISE NOTICE '✅ Criado novo weekly goal para usuário % - Semana: % a %', 
            p_user_id, current_week_start, current_week_end;
    ELSE
        RAISE NOTICE '✅ Weekly goal existente encontrado para usuário % - Semana: % a %', 
            p_user_id, current_week_start, current_week_end;
    END IF;
    
    -- Retornar o registro (existente ou recém-criado)
    RETURN QUERY
    SELECT 
        existing_goal.id,
        existing_goal.user_id,
        existing_goal.goal_minutes,
        existing_goal.current_minutes,
        existing_goal.week_start_date,
        existing_goal.week_end_date,
        existing_goal.completed,
        existing_goal.created_at,
        existing_goal.updated_at;
END;
$$;

-- ========================================
-- 2. FUNÇÃO: get_weekly_goal_status
-- ========================================

CREATE OR REPLACE FUNCTION get_weekly_goal_status(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    goal_record weekly_goals%ROWTYPE;
    progress_percentage DECIMAL;
    result JSON;
BEGIN
    -- Buscar ou criar weekly goal
    SELECT * INTO goal_record
    FROM get_or_create_weekly_goal(p_user_id)
    LIMIT 1;
    
    -- Calcular porcentagem
    progress_percentage := ROUND((goal_record.current_minutes::DECIMAL / goal_record.goal_minutes * 100), 1);
    
    -- Preparar resultado
    result := json_build_object(
        'id', goal_record.id,
        'goal_minutes', goal_record.goal_minutes,
        'current_minutes', goal_record.current_minutes,
        'remaining_minutes', GREATEST(0, goal_record.goal_minutes - goal_record.current_minutes),
        'progress_percentage', progress_percentage,
        'completed', goal_record.completed,
        'week_start_date', goal_record.week_start_date,
        'week_end_date', goal_record.week_end_date,
        'is_current_week', goal_record.week_start_date = date_trunc('week', CURRENT_DATE)
    );
    
    RETURN result;
END;
$$;

-- ========================================
-- 3. FUNÇÃO: sync_existing_workouts_to_weekly_goals
-- ========================================

CREATE OR REPLACE FUNCTION sync_existing_workouts_to_weekly_goals(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_week_start DATE;
    current_week_end DATE;
    total_minutes INTEGER;
    workout_count INTEGER;
    goal_record weekly_goals%ROWTYPE;
    result JSON;
BEGIN
    -- Calcular semana atual
    current_week_start := date_trunc('week', CURRENT_DATE);
    current_week_end := current_week_start + interval '6 days';
    
    -- Somar minutos dos treinos desta semana
    SELECT 
        COALESCE(SUM(duration_minutes), 0),
        COUNT(*)
    INTO total_minutes, workout_count
    FROM workout_records
    WHERE user_id = p_user_id
    AND is_completed = TRUE
    AND date >= current_week_start
    AND date <= current_week_end;
    
    -- Buscar ou criar weekly goal
    SELECT * INTO goal_record
    FROM get_or_create_weekly_goal(p_user_id)
    LIMIT 1;
    
    -- Atualizar com total calculado
    UPDATE weekly_goals
    SET 
        current_minutes = total_minutes,
        completed = total_minutes >= goal_minutes,
        updated_at = NOW()
    WHERE id = goal_record.id
    RETURNING * INTO goal_record;
    
    result := json_build_object(
        'success', TRUE,
        'message', 'Sincronização concluída',
        'workouts_found', workout_count,
        'total_minutes', total_minutes,
        'week_start', current_week_start,
        'week_end', current_week_end,
        'goal_updated', TRUE
    );
    
    RAISE NOTICE '🔄 Sincronização: % treinos, % minutos para usuário % (semana %-%)', 
        workout_count, total_minutes, p_user_id, current_week_start, current_week_end;
    
    RETURN result;
END;
$$;

-- ========================================
-- 4. VERIFICAR SE TRIGGER EXISTE E CRIAR SE NECESSÁRIO
-- ========================================

-- Função trigger (melhorar a existente se necessário)
CREATE OR REPLACE FUNCTION update_weekly_goal_on_workout()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Só processar se workout foi completado e tem duração
    IF NEW.is_completed = TRUE AND NEW.duration_minutes > 0 THEN
        -- Usar função existente se disponível, senão implementar diretamente
        BEGIN
            -- Tentar usar função existente
            PERFORM add_workout_minutes_to_goal(NEW.user_id, NEW.duration_minutes);
        EXCEPTION
            WHEN others THEN
                -- Se função falhar, implementar diretamente
                UPDATE weekly_goals 
                SET 
                    current_minutes = current_minutes + NEW.duration_minutes,
                    completed = (current_minutes + NEW.duration_minutes) >= goal_minutes,
                    updated_at = NOW()
                WHERE user_id = NEW.user_id 
                AND week_start_date = date_trunc('week', NEW.date);
        END;
        
        RAISE NOTICE '🏋️ Workout completado: % minutos adicionados ao weekly goal do usuário %', 
            NEW.duration_minutes, NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Verificar se trigger existe, se não, criar
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'workout_completed_update_weekly_goal'
    ) THEN
        CREATE TRIGGER workout_completed_update_weekly_goal
            AFTER INSERT OR UPDATE ON workout_records
            FOR EACH ROW
            EXECUTE FUNCTION update_weekly_goal_on_workout();
        
        RAISE NOTICE '✅ Trigger workout_completed_update_weekly_goal criado';
    ELSE
        RAISE NOTICE '✅ Trigger workout_completed_update_weekly_goal já existe';
    END IF;
END $$;

-- ========================================
-- COMENTÁRIOS FINAIS
-- ========================================

-- Funções criadas:
-- ✅ get_or_create_weekly_goal(p_user_id UUID) → TABLE
-- ✅ get_weekly_goal_status(p_user_id UUID) → JSON
-- ✅ sync_existing_workouts_to_weekly_goals(p_user_id UUID) → JSON
-- ✅ update_weekly_goal_on_workout() → TRIGGER FUNCTION
-- ✅ Trigger automático verificado/criado

SELECT '✅ FUNÇÕES WEEKLY GOALS FALTANTES CRIADAS COM SUCESSO!' as resultado; 