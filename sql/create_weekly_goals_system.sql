-- Criar tabela de metas semanais
CREATE TABLE IF NOT EXISTS weekly_goals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    goal_minutes INTEGER NOT NULL DEFAULT 180, -- Meta padrão: 180 minutos (3 horas)
    current_minutes INTEGER NOT NULL DEFAULT 0, -- Minutos acumulados na semana atual
    week_start_date DATE NOT NULL DEFAULT date_trunc('week', CURRENT_DATE)::date,
    week_end_date DATE NOT NULL DEFAULT (date_trunc('week', CURRENT_DATE) + interval '6 days')::date,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir apenas uma meta ativa por usuário
    CONSTRAINT unique_active_goal_per_user UNIQUE (user_id, week_start_date)
);

-- Criar índices para performance
CREATE INDEX idx_weekly_goals_user_id ON weekly_goals(user_id);
CREATE INDEX idx_weekly_goals_week_dates ON weekly_goals(week_start_date, week_end_date);
CREATE INDEX idx_weekly_goals_user_week ON weekly_goals(user_id, week_start_date DESC);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_weekly_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_weekly_goals_updated_at_trigger
    BEFORE UPDATE ON weekly_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_weekly_goals_updated_at();

-- Função para obter ou criar meta semanal do usuário
CREATE OR REPLACE FUNCTION get_or_create_weekly_goal(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    goal_minutes INTEGER,
    current_minutes INTEGER,
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
    -- Calcular início e fim da semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_current_week_end := v_current_week_start + interval '6 days';
    
    -- Tentar buscar meta existente para a semana atual
    SELECT wg.* INTO v_goal_record
    FROM weekly_goals wg
    WHERE wg.user_id = p_user_id
    AND wg.week_start_date = v_current_week_start;
    
    -- Se não existir, criar nova meta com valor padrão
    IF NOT FOUND THEN
        -- Buscar última meta do usuário para copiar o valor
        SELECT goal_minutes INTO v_goal_record.goal_minutes
        FROM weekly_goals
        WHERE user_id = p_user_id
        ORDER BY week_start_date DESC
        LIMIT 1;
        
        -- Se não houver meta anterior, usar padrão
        IF v_goal_record.goal_minutes IS NULL THEN
            v_goal_record.goal_minutes := 180; -- 3 horas padrão
        END IF;
        
        -- Inserir nova meta
        INSERT INTO weekly_goals (
            user_id, 
            goal_minutes, 
            current_minutes,
            week_start_date,
            week_end_date
        ) VALUES (
            p_user_id,
            v_goal_record.goal_minutes,
            0,
            v_current_week_start,
            v_current_week_end
        )
        RETURNING * INTO v_goal_record;
    END IF;
    
    -- Retornar dados com porcentagem calculada
    RETURN QUERY
    SELECT 
        v_goal_record.id,
        v_goal_record.user_id,
        v_goal_record.goal_minutes,
        v_goal_record.current_minutes,
        v_goal_record.week_start_date,
        v_goal_record.week_end_date,
        v_goal_record.completed,
        CASE 
            WHEN v_goal_record.goal_minutes > 0 THEN 
                ROUND((v_goal_record.current_minutes::NUMERIC / v_goal_record.goal_minutes::NUMERIC) * 100, 2)
            ELSE 0
        END as percentage_completed;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar meta semanal do usuário
CREATE OR REPLACE FUNCTION update_weekly_goal(
    p_user_id UUID,
    p_goal_minutes INTEGER
) RETURNS weekly_goals AS $$
DECLARE
    v_current_week_start DATE;
    v_updated_goal weekly_goals;
BEGIN
    -- Validar entrada
    IF p_goal_minutes < 30 OR p_goal_minutes > 1440 THEN -- Entre 30 min e 24 horas
        RAISE EXCEPTION 'Meta deve estar entre 30 e 1440 minutos';
    END IF;
    
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    
    -- Atualizar ou inserir meta
    INSERT INTO weekly_goals (user_id, goal_minutes, week_start_date, week_end_date)
    VALUES (
        p_user_id, 
        p_goal_minutes,
        v_current_week_start,
        v_current_week_start + interval '6 days'
    )
    ON CONFLICT (user_id, week_start_date)
    DO UPDATE SET 
        goal_minutes = EXCLUDED.goal_minutes,
        updated_at = NOW()
    RETURNING * INTO v_updated_goal;
    
    -- Verificar se já completou com a nova meta
    UPDATE weekly_goals
    SET completed = (current_minutes >= goal_minutes)
    WHERE id = v_updated_goal.id;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- Função para adicionar minutos de treino à meta semanal
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
    
    -- Atualizar minutos
    UPDATE weekly_goals
    SET 
        current_minutes = current_minutes + p_minutes,
        completed = (current_minutes + p_minutes) >= goal_minutes
    WHERE 
        user_id = p_user_id 
        AND week_start_date = v_current_week_start
    RETURNING * INTO v_updated_goal;
    
    RETURN v_updated_goal;
END;
$$ LANGUAGE plpgsql;

-- Função para resetar metas semanais antigas (executar via cron job)
CREATE OR REPLACE FUNCTION reset_old_weekly_goals()
RETURNS INTEGER AS $$
DECLARE
    v_rows_updated INTEGER;
BEGIN
    -- Criar novas metas para usuários que tiveram atividade na semana anterior
    INSERT INTO weekly_goals (user_id, goal_minutes, week_start_date, week_end_date)
    SELECT DISTINCT
        wg.user_id,
        wg.goal_minutes, -- Mantém a mesma meta
        date_trunc('week', CURRENT_DATE)::date,
        date_trunc('week', CURRENT_DATE)::date + interval '6 days'
    FROM weekly_goals wg
    WHERE 
        wg.week_end_date < CURRENT_DATE -- Meta expirada
        AND NOT EXISTS ( -- Não existe meta para semana atual
            SELECT 1 
            FROM weekly_goals wg2 
            WHERE wg2.user_id = wg.user_id 
            AND wg2.week_start_date = date_trunc('week', CURRENT_DATE)::date
        )
        AND wg.current_minutes > 0; -- Usuário teve atividade
    
    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    
    RETURN v_rows_updated;
END;
$$ LANGUAGE plpgsql;

-- Função para obter histórico de metas semanais
CREATE OR REPLACE FUNCTION get_weekly_goals_history(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 12
) RETURNS TABLE (
    id UUID,
    goal_minutes INTEGER,
    current_minutes INTEGER,
    week_start_date DATE,
    week_end_date DATE,
    completed BOOLEAN,
    percentage_completed NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wg.id,
        wg.goal_minutes,
        wg.current_minutes,
        wg.week_start_date,
        wg.week_end_date,
        wg.completed,
        CASE 
            WHEN wg.goal_minutes > 0 THEN 
                ROUND((wg.current_minutes::NUMERIC / wg.goal_minutes::NUMERIC) * 100, 2)
            ELSE 0
        END as percentage_completed
    FROM weekly_goals wg
    WHERE wg.user_id = p_user_id
    ORDER BY wg.week_start_date DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- RLS Policies
ALTER TABLE weekly_goals ENABLE ROW LEVEL SECURITY;

-- Política para visualizar apenas suas próprias metas
CREATE POLICY "Users can view own weekly goals" ON weekly_goals
    FOR SELECT USING (auth.uid() = user_id);

-- Política para criar suas próprias metas
CREATE POLICY "Users can create own weekly goals" ON weekly_goals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para atualizar suas próprias metas
CREATE POLICY "Users can update own weekly goals" ON weekly_goals
    FOR UPDATE USING (auth.uid() = user_id);

-- Política para deletar suas próprias metas
CREATE POLICY "Users can delete own weekly goals" ON weekly_goals
    FOR DELETE USING (auth.uid() = user_id);

-- Comentários para documentação
COMMENT ON TABLE weekly_goals IS 'Armazena as metas semanais de minutos de treino dos usuários';
COMMENT ON COLUMN weekly_goals.goal_minutes IS 'Meta em minutos para a semana (padrão: 180 = 3 horas)';
COMMENT ON COLUMN weekly_goals.current_minutes IS 'Minutos acumulados de treino na semana atual';
COMMENT ON COLUMN weekly_goals.completed IS 'Indica se a meta foi atingida';
COMMENT ON FUNCTION get_or_create_weekly_goal IS 'Obtém a meta semanal atual ou cria uma nova com valores padrão';
COMMENT ON FUNCTION update_weekly_goal IS 'Atualiza a meta semanal do usuário (entre 30 e 1440 minutos)';
COMMENT ON FUNCTION add_workout_minutes_to_goal IS 'Adiciona minutos de treino à meta semanal atual';
COMMENT ON FUNCTION reset_old_weekly_goals IS 'Cria novas metas semanais para usuários ativos (executar via cron)'; 