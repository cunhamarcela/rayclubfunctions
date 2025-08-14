-- ========================================
-- SISTEMA COMPLETO WEEKLY GOALS
-- ========================================
-- Data: 2025-01-27 22:15
-- Objetivo: Criar tabela e funções para weekly goals com reset automático
-- Autor: IA

-- ========================================
-- 1. CRIAR TABELA WEEKLY_GOALS
-- ========================================

-- Primeiro, drop se existir
DROP TABLE IF EXISTS weekly_goals CASCADE;

-- Criar tabela
CREATE TABLE weekly_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    goal_minutes INTEGER NOT NULL DEFAULT 180,
    current_minutes INTEGER NOT NULL DEFAULT 0,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: um registro por usuário por semana
    UNIQUE(user_id, week_start_date)
);

-- Índices para performance
CREATE INDEX idx_weekly_goals_user_id ON weekly_goals(user_id);
CREATE INDEX idx_weekly_goals_week_start ON weekly_goals(week_start_date);
CREATE INDEX idx_weekly_goals_user_week ON weekly_goals(user_id, week_start_date);

-- RLS (Row Level Security)
ALTER TABLE weekly_goals ENABLE ROW LEVEL SECURITY;

-- Policy: usuários só podem ver seus próprios registros
CREATE POLICY "Users can view own weekly goals" ON weekly_goals
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own weekly goals" ON weekly_goals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own weekly goals" ON weekly_goals
    FOR UPDATE USING (auth.uid() = user_id);

-- ========================================
-- 2. FUNÇÃO: get_or_create_weekly_goal
-- ========================================

CREATE OR REPLACE FUNCTION get_or_create_weekly_goal(user_id_param UUID)
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
    WHERE wg.user_id = user_id_param
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
            user_id_param,
            180, -- Meta padrão: 180 minutos por semana
            0,   -- Começar com 0 minutos
            current_week_start,
            current_week_end,
            FALSE
        ) RETURNING * INTO existing_goal;
        
        RAISE NOTICE '✅ Criado novo weekly goal para usuário % - Semana: % a %', 
            user_id_param, current_week_start, current_week_end;
    ELSE
        RAISE NOTICE '✅ Weekly goal existente encontrado para usuário % - Semana: % a %', 
            user_id_param, current_week_start, current_week_end;
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
-- 3. FUNÇÃO: add_workout_minutes_to_goal
-- ========================================

CREATE OR REPLACE FUNCTION add_workout_minutes_to_goal(
    user_id_param UUID,
    minutes_to_add INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_week_start DATE;
    goal_record weekly_goals%ROWTYPE;
    result JSON;
BEGIN
    -- Calcular início da semana atual
    current_week_start := date_trunc('week', CURRENT_DATE);
    
    -- Buscar ou criar weekly goal para esta semana
    SELECT * INTO goal_record
    FROM get_or_create_weekly_goal(user_id_param)
    LIMIT 1;
    
    -- Adicionar minutos
    UPDATE weekly_goals
    SET 
        current_minutes = current_minutes + minutes_to_add,
        completed = (current_minutes + minutes_to_add) >= goal_minutes,
        updated_at = NOW()
    WHERE id = goal_record.id
    RETURNING * INTO goal_record;
    
    -- Preparar resultado
    result := json_build_object(
        'success', TRUE,
        'message', 'Minutos adicionados com sucesso',
        'added_minutes', minutes_to_add,
        'total_minutes', goal_record.current_minutes,
        'goal_minutes', goal_record.goal_minutes,
        'completed', goal_record.completed,
        'progress_percentage', ROUND((goal_record.current_minutes::DECIMAL / goal_record.goal_minutes * 100), 1)
    );
    
    RAISE NOTICE '✅ Adicionados % minutos. Total: %/% (%.1%)', 
        minutes_to_add, 
        goal_record.current_minutes, 
        goal_record.goal_minutes,
        (goal_record.current_minutes::DECIMAL / goal_record.goal_minutes * 100);
    
    RETURN result;
END;
$$;

-- ========================================
-- 4. FUNÇÃO: update_weekly_goal
-- ========================================

CREATE OR REPLACE FUNCTION update_weekly_goal(
    user_id_param UUID,
    new_goal_minutes INTEGER DEFAULT NULL,
    new_current_minutes INTEGER DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_week_start DATE;
    goal_record weekly_goals%ROWTYPE;
    result JSON;
BEGIN
    -- Calcular início da semana atual
    current_week_start := date_trunc('week', CURRENT_DATE);
    
    -- Buscar ou criar weekly goal para esta semana
    SELECT * INTO goal_record
    FROM get_or_create_weekly_goal(user_id_param)
    LIMIT 1;
    
    -- Atualizar campos fornecidos
    UPDATE weekly_goals
    SET 
        goal_minutes = COALESCE(new_goal_minutes, goal_minutes),
        current_minutes = COALESCE(new_current_minutes, current_minutes),
        completed = COALESCE(new_current_minutes, current_minutes) >= COALESCE(new_goal_minutes, goal_minutes),
        updated_at = NOW()
    WHERE id = goal_record.id
    RETURNING * INTO goal_record;
    
    -- Preparar resultado
    result := json_build_object(
        'success', TRUE,
        'message', 'Weekly goal atualizado com sucesso',
        'current_minutes', goal_record.current_minutes,
        'goal_minutes', goal_record.goal_minutes,
        'completed', goal_record.completed,
        'progress_percentage', ROUND((goal_record.current_minutes::DECIMAL / goal_record.goal_minutes * 100), 1)
    );
    
    RETURN result;
END;
$$;

-- ========================================
-- 5. TRIGGER: Auto-atualizar weekly goals em workout_records
-- ========================================

-- Função trigger
CREATE OR REPLACE FUNCTION update_weekly_goal_on_workout()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Só processar se workout foi completado e tem duração
    IF NEW.is_completed = TRUE AND NEW.duration_minutes > 0 THEN
        -- Adicionar minutos ao weekly goal
        PERFORM add_workout_minutes_to_goal(NEW.user_id, NEW.duration_minutes);
        
        RAISE NOTICE '🏋️ Workout completado: % minutos adicionados ao weekly goal do usuário %', 
            NEW.duration_minutes, NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Drop trigger se existir
DROP TRIGGER IF EXISTS workout_completed_update_weekly_goal ON workout_records;

-- Criar trigger
CREATE TRIGGER workout_completed_update_weekly_goal
    AFTER INSERT OR UPDATE ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION update_weekly_goal_on_workout();

-- ========================================
-- 6. FUNÇÃO: sync_existing_workouts_to_weekly_goals
-- ========================================

CREATE OR REPLACE FUNCTION sync_existing_workouts_to_weekly_goals(user_id_param UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_week_start DATE;
    current_week_end DATE;
    total_minutes INTEGER;
    workout_count INTEGER;
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
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= current_week_start
    AND date <= current_week_end;
    
    -- Buscar ou criar weekly goal
    PERFORM get_or_create_weekly_goal(user_id_param);
    
    -- Atualizar com total calculado
    PERFORM update_weekly_goal(user_id_param, NULL, total_minutes);
    
    result := json_build_object(
        'success', TRUE,
        'message', 'Sincronização concluída',
        'workouts_found', workout_count,
        'total_minutes', total_minutes,
        'week_start', current_week_start,
        'week_end', current_week_end
    );
    
    RAISE NOTICE '🔄 Sincronização: % treinos, % minutos para usuário % (semana %-%)', 
        workout_count, total_minutes, user_id_param, current_week_start, current_week_end;
    
    RETURN result;
END;
$$;

-- ========================================
-- 7. FUNÇÃO: get_weekly_goal_status
-- ========================================

CREATE OR REPLACE FUNCTION get_weekly_goal_status(user_id_param UUID)
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
    FROM get_or_create_weekly_goal(user_id_param)
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
-- COMENTÁRIOS FINAIS
-- ========================================

-- Este sistema fornece:
-- ✅ Tabela weekly_goals com RLS
-- ✅ Reset automático toda segunda-feira (date_trunc('week'))
-- ✅ Funções para buscar/criar/atualizar goals
-- ✅ Trigger automático em workout_records
-- ✅ Sincronização de dados existentes
-- ✅ Status detalhado do progresso semanal

SELECT '✅ SISTEMA WEEKLY GOALS CRIADO COM SUCESSO!' as resultado; 