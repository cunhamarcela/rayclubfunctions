-- ========================================
-- SISTEMA DE METAS POR CATEGORIA DE TREINO
-- ========================================
-- Data: 2025-01-15
-- Objetivo: Permitir que usuários definam metas específicas por tipo de treino
-- Exemplo: "120 minutos de Corrida por semana"

-- Tabela para metas por categoria de treino
CREATE TABLE IF NOT EXISTS workout_category_goals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL, -- 'corrida', 'yoga', 'funcional', etc.
    goal_minutes INTEGER NOT NULL DEFAULT 60, -- Meta em minutos por semana
    current_minutes INTEGER NOT NULL DEFAULT 0, -- Minutos acumulados na semana atual
    week_start_date DATE NOT NULL DEFAULT date_trunc('week', CURRENT_DATE)::date,
    week_end_date DATE NOT NULL DEFAULT (date_trunc('week', CURRENT_DATE) + interval '6 days')::date,
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- Permite desativar metas
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir apenas uma meta ativa por usuário/categoria/semana
    CONSTRAINT unique_category_goal_per_user_week UNIQUE (user_id, category, week_start_date)
);

-- Índices para performance
CREATE INDEX idx_workout_category_goals_user_id ON workout_category_goals(user_id);
CREATE INDEX idx_workout_category_goals_category ON workout_category_goals(category);
CREATE INDEX idx_workout_category_goals_active ON workout_category_goals(user_id, is_active);
CREATE INDEX idx_workout_category_goals_week ON workout_category_goals(user_id, week_start_date DESC);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_workout_category_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_workout_category_goals_updated_at_trigger
    BEFORE UPDATE ON workout_category_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_workout_category_goals_updated_at();

-- ========================================
-- FUNÇÕES PARA GERENCIAR METAS POR CATEGORIA
-- ========================================

-- Função para obter ou criar meta por categoria
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
        -- Buscar última meta desta categoria para copiar o valor
        SELECT goal_minutes INTO v_goal_record.goal_minutes
        FROM workout_category_goals
        WHERE user_id = p_user_id 
        AND category = p_category
        AND is_active = TRUE
        ORDER BY week_start_date DESC
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
            is_active
        ) VALUES (
            p_user_id,
            p_category,
            v_goal_record.goal_minutes,
            0,
            v_current_week_start,
            v_current_week_end,
            TRUE
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

-- Função para definir/atualizar meta por categoria
CREATE OR REPLACE FUNCTION set_category_goal(
    p_user_id UUID,
    p_category TEXT,
    p_goal_minutes INTEGER
) RETURNS workout_category_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal workout_category_goals;
BEGIN
    -- Validar entrada
    IF p_goal_minutes < 15 OR p_goal_minutes > 1440 THEN -- Entre 15 min e 24 horas
        RAISE EXCEPTION 'Meta deve estar entre 15 e 1440 minutos';
    END IF;
    
    IF p_category IS NULL OR trim(p_category) = '' THEN
        RAISE EXCEPTION 'Categoria não pode ser vazia';
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
        p_goal_minutes,
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

-- Função para adicionar minutos de treino a uma categoria específica
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
    
    -- Atualizar minutos
    UPDATE workout_category_goals
    SET 
        current_minutes = current_minutes + p_minutes,
        completed = (current_minutes + p_minutes) >= goal_minutes,
        updated_at = NOW()
    WHERE 
        user_id = p_user_id 
        AND category = lower(trim(p_category))
        AND week_start_date = v_current_week_start
        AND is_active = TRUE
    RETURNING * INTO v_updated_goal;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- Função para obter todas as metas ativas do usuário
CREATE OR REPLACE FUNCTION get_user_category_goals(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    category TEXT,
    goal_minutes INTEGER,
    current_minutes INTEGER,
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
        wcg.current_minutes,
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

-- Função para obter histórico de evolução semanal por categoria
CREATE OR REPLACE FUNCTION get_weekly_evolution_by_category(
    p_user_id UUID,
    p_category TEXT,
    p_weeks INTEGER DEFAULT 8
) RETURNS TABLE (
    week_start_date DATE,
    goal_minutes INTEGER,
    current_minutes INTEGER,
    percentage_completed NUMERIC,
    completed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wcg.week_start_date,
        wcg.goal_minutes,
        wcg.current_minutes,
        CASE 
            WHEN wcg.goal_minutes > 0 THEN 
                ROUND((wcg.current_minutes::NUMERIC / wcg.goal_minutes::NUMERIC) * 100, 2)
            ELSE 0
        END as percentage_completed,
        wcg.completed
    FROM workout_category_goals wcg
    WHERE wcg.user_id = p_user_id
    AND wcg.category = lower(trim(p_category))
    AND wcg.week_start_date >= (CURRENT_DATE - interval '1 week' * p_weeks)
    ORDER BY wcg.week_start_date DESC
    LIMIT p_weeks;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- TRIGGER PARA ATUALIZAR METAS AUTOMATICAMENTE
-- ========================================

-- Função trigger para atualizar metas quando um treino é registrado
CREATE OR REPLACE FUNCTION update_category_goals_on_workout()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar meta da categoria correspondente
    PERFORM add_workout_minutes_to_category(
        NEW.user_id,
        NEW.workout_type,
        NEW.duration_minutes
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar metas automaticamente
DROP TRIGGER IF EXISTS update_category_goals_on_workout_trigger ON workout_records;
CREATE TRIGGER update_category_goals_on_workout_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION update_category_goals_on_workout();

-- ========================================
-- POLÍTICAS DE SEGURANÇA (RLS)
-- ========================================

ALTER TABLE workout_category_goals ENABLE ROW LEVEL SECURITY;

-- Política para visualizar apenas suas próprias metas
CREATE POLICY "Users can view own category goals" ON workout_category_goals
    FOR SELECT USING (auth.uid() = user_id);

-- Política para criar suas próprias metas
CREATE POLICY "Users can create own category goals" ON workout_category_goals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para atualizar suas próprias metas
CREATE POLICY "Users can update own category goals" ON workout_category_goals
    FOR UPDATE USING (auth.uid() = user_id);

-- Política para deletar suas próprias metas
CREATE POLICY "Users can delete own category goals" ON workout_category_goals
    FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ========================================

COMMENT ON TABLE workout_category_goals IS 'Armazena metas semanais específicas por categoria de treino';
COMMENT ON COLUMN workout_category_goals.category IS 'Tipo de treino (corrida, yoga, funcional, etc.)';
COMMENT ON COLUMN workout_category_goals.goal_minutes IS 'Meta em minutos para a categoria na semana';
COMMENT ON COLUMN workout_category_goals.current_minutes IS 'Minutos acumulados na categoria na semana atual';
COMMENT ON COLUMN workout_category_goals.is_active IS 'Permite ativar/desativar metas sem excluir';

COMMENT ON FUNCTION get_or_create_category_goal IS 'Obtém meta por categoria ou cria com valores padrão';
COMMENT ON FUNCTION set_category_goal IS 'Define/atualiza meta para uma categoria específica';
COMMENT ON FUNCTION add_workout_minutes_to_category IS 'Adiciona minutos de treino à meta da categoria';
COMMENT ON FUNCTION get_user_category_goals IS 'Obtém todas as metas ativas do usuário para a semana atual';
COMMENT ON FUNCTION get_weekly_evolution_by_category IS 'Obtém evolução semanal de uma categoria específica'; 