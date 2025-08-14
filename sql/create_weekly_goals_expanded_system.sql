-- Sistema de Metas Semanais Expandido
-- Data: 2025-01-27
-- Autor: IA Assistant
-- Objetivo: Suportar diferentes tipos de metas (minutos, dias, check-ins, peso, etc.)

-- Primeiro, criar ENUM para tipos de meta
DO $$ BEGIN
    CREATE TYPE goal_measurement_type AS ENUM (
        'minutes',          -- Minutos de treino
        'days',            -- Dias de atividade
        'checkins',        -- Check-ins/confirmações
        'weight',          -- Peso (kg)
        'repetitions',     -- Repetições/sets
        'distance',        -- Distância (km)
        'custom'           -- Personalizado
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Segundo, criar ENUM para tipos de meta pré-estabelecidos
DO $$ BEGIN
    CREATE TYPE goal_preset_type AS ENUM (
        'projeto_bruna_braga',  -- 7 dias de treino
        'cardio',              -- Meta de cardio (configurável)
        'musculacao',          -- Meta de musculação (configurável)
        'custom'               -- Meta personalizada
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Tabela expandida de metas semanais
CREATE TABLE IF NOT EXISTS weekly_goals_expanded (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Informações da meta
    goal_type goal_preset_type NOT NULL DEFAULT 'custom',
    measurement_type goal_measurement_type NOT NULL DEFAULT 'minutes',
    goal_title VARCHAR(255) NOT NULL DEFAULT 'Meta Semanal',
    goal_description TEXT,
    
    -- Valores da meta
    target_value NUMERIC NOT NULL DEFAULT 180, -- Valor alvo (minutos, dias, kg, etc.)
    current_value NUMERIC NOT NULL DEFAULT 0,  -- Valor atual
    unit_label VARCHAR(50) DEFAULT 'min',      -- Rótulo da unidade (min, dias, kg, etc.)
    
    -- Datas da semana
    week_start_date DATE NOT NULL DEFAULT date_trunc('week', CURRENT_DATE)::date,
    week_end_date DATE NOT NULL DEFAULT (date_trunc('week', CURRENT_DATE) + interval '6 days')::date,
    
    -- Status
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir apenas uma meta ativa por usuário por semana
    CONSTRAINT unique_active_goal_per_user_week UNIQUE (user_id, week_start_date, active)
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_weekly_goals_expanded_user_id ON weekly_goals_expanded(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_goals_expanded_week_dates ON weekly_goals_expanded(week_start_date, week_end_date);
CREATE INDEX IF NOT EXISTS idx_weekly_goals_expanded_user_week ON weekly_goals_expanded(user_id, week_start_date DESC);
CREATE INDEX IF NOT EXISTS idx_weekly_goals_expanded_goal_type ON weekly_goals_expanded(goal_type);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_weekly_goals_expanded_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_weekly_goals_expanded_updated_at_trigger ON weekly_goals_expanded;
CREATE TRIGGER update_weekly_goals_expanded_updated_at_trigger
    BEFORE UPDATE ON weekly_goals_expanded
    FOR EACH ROW
    EXECUTE FUNCTION update_weekly_goals_expanded_updated_at();

-- Função para obter ou criar meta semanal expandida
CREATE OR REPLACE FUNCTION get_or_create_weekly_goal_expanded(
    p_user_id UUID,
    p_goal_type goal_preset_type DEFAULT 'custom',
    p_measurement_type goal_measurement_type DEFAULT 'minutes',
    p_target_value NUMERIC DEFAULT 180,
    p_goal_title VARCHAR(255) DEFAULT 'Meta Semanal',
    p_unit_label VARCHAR(50) DEFAULT 'min'
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    goal_type goal_preset_type,
    measurement_type goal_measurement_type,
    goal_title VARCHAR(255),
    goal_description TEXT,
    target_value NUMERIC,
    current_value NUMERIC,
    unit_label VARCHAR(50),
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
    v_current_week_end := (v_current_week_start + interval '6 days')::date;
    
    -- Tentar encontrar meta existente para a semana atual
    SELECT * INTO v_goal_record
    FROM weekly_goals_expanded wge
    WHERE wge.user_id = p_user_id 
      AND wge.week_start_date = v_current_week_start
      AND wge.active = true
    ORDER BY wge.created_at DESC
    LIMIT 1;
    
    -- Se não existe, criar nova meta
    IF NOT FOUND THEN
        INSERT INTO weekly_goals_expanded (
            user_id, 
            goal_type,
            measurement_type,
            goal_title,
            target_value,
            unit_label,
            week_start_date, 
            week_end_date
        ) VALUES (
            p_user_id, 
            p_goal_type,
            p_measurement_type,
            p_goal_title,
            p_target_value,
            p_unit_label,
            v_current_week_start, 
            v_current_week_end
        )
        RETURNING * INTO v_goal_record;
    END IF;
    
    -- Retornar dados da meta com porcentagem calculada
    RETURN QUERY
    SELECT 
        v_goal_record.id,
        v_goal_record.user_id,
        v_goal_record.goal_type,
        v_goal_record.measurement_type,
        v_goal_record.goal_title,
        v_goal_record.goal_description,
        v_goal_record.target_value,
        v_goal_record.current_value,
        v_goal_record.unit_label,
        v_goal_record.week_start_date,
        v_goal_record.week_end_date,
        v_goal_record.completed,
        CASE 
            WHEN v_goal_record.target_value > 0 THEN 
                ROUND((v_goal_record.current_value / v_goal_record.target_value * 100)::NUMERIC, 1)
            ELSE 0
        END as percentage_completed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para atualizar progresso da meta
CREATE OR REPLACE FUNCTION update_weekly_goal_progress(
    p_user_id UUID,
    p_added_value NUMERIC,
    p_measurement_type goal_measurement_type DEFAULT 'minutes'
)
RETURNS BOOLEAN AS $$
DECLARE
    v_goal_record RECORD;
    v_new_current_value NUMERIC;
BEGIN
    -- Buscar meta ativa da semana atual
    SELECT * INTO v_goal_record
    FROM weekly_goals_expanded wge
    WHERE wge.user_id = p_user_id 
      AND wge.week_start_date = date_trunc('week', CURRENT_DATE)::date
      AND wge.measurement_type = p_measurement_type
      AND wge.active = true
    ORDER BY wge.created_at DESC
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Calcular novo valor
    v_new_current_value := v_goal_record.current_value + p_added_value;
    
    -- Atualizar meta
    UPDATE weekly_goals_expanded
    SET 
        current_value = v_new_current_value,
        completed = (v_new_current_value >= target_value),
        updated_at = NOW()
    WHERE id = v_goal_record.id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para criar metas pré-estabelecidas
CREATE OR REPLACE FUNCTION create_preset_weekly_goal(
    p_user_id UUID,
    p_preset_type goal_preset_type
)
RETURNS UUID AS $$
DECLARE
    v_goal_id UUID;
    v_title VARCHAR(255);
    v_description TEXT;
    v_target_value NUMERIC;
    v_measurement_type goal_measurement_type;
    v_unit_label VARCHAR(50);
BEGIN
    -- Configurar valores baseados no tipo de preset
    CASE p_preset_type
        WHEN 'projeto_bruna_braga' THEN
            v_title := 'Projeto Bruna Braga';
            v_description := 'Complete 7 dias consecutivos de treino seguindo o programa da Bruna Braga';
            v_target_value := 7;
            v_measurement_type := 'days';
            v_unit_label := 'dias';
            
        WHEN 'cardio' THEN
            v_title := 'Meta de Cardio';
            v_description := 'Meta de exercícios cardiovasculares para a semana';
            v_target_value := 150; -- 150 minutos padrão
            v_measurement_type := 'minutes';
            v_unit_label := 'min';
            
        WHEN 'musculacao' THEN
            v_title := 'Meta de Musculação';
            v_description := 'Meta de treinos de musculação para a semana';
            v_target_value := 180; -- 180 minutos padrão
            v_measurement_type := 'minutes';
            v_unit_label := 'min';
            
        ELSE -- custom
            v_title := 'Meta Personalizada';
            v_description := 'Meta personalizada definida pelo usuário';
            v_target_value := 180;
            v_measurement_type := 'minutes';
            v_unit_label := 'min';
    END CASE;
    
    -- Criar a meta usando a função existente
    SELECT gocwge.id INTO v_goal_id
    FROM get_or_create_weekly_goal_expanded(
        p_user_id,
        p_preset_type,
        v_measurement_type,
        v_target_value,
        v_title,
        v_unit_label
    ) gocwge;
    
    -- Atualizar descrição
    UPDATE weekly_goals_expanded
    SET goal_description = v_description
    WHERE id = v_goal_id;
    
    RETURN v_goal_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para listar metas do usuário
CREATE OR REPLACE FUNCTION get_user_weekly_goals(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    goal_type goal_preset_type,
    measurement_type goal_measurement_type,
    goal_title VARCHAR(255),
    goal_description TEXT,
    target_value NUMERIC,
    current_value NUMERIC,
    unit_label VARCHAR(50),
    week_start_date DATE,
    week_end_date DATE,
    completed BOOLEAN,
    percentage_completed NUMERIC,
    is_current_week BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wge.id,
        wge.goal_type,
        wge.measurement_type,
        wge.goal_title,
        wge.goal_description,
        wge.target_value,
        wge.current_value,
        wge.unit_label,
        wge.week_start_date,
        wge.week_end_date,
        wge.completed,
        CASE 
            WHEN wge.target_value > 0 THEN 
                ROUND((wge.current_value / wge.target_value * 100)::NUMERIC, 1)
            ELSE 0
        END as percentage_completed,
        (wge.week_start_date = date_trunc('week', CURRENT_DATE)::date) as is_current_week
    FROM weekly_goals_expanded wge
    WHERE wge.user_id = p_user_id 
      AND wge.active = true
    ORDER BY wge.week_start_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS (Row Level Security)
ALTER TABLE weekly_goals_expanded ENABLE ROW LEVEL SECURITY;

-- Policy para usuários autenticados verem apenas suas próprias metas
CREATE POLICY "Users can view own weekly goals" ON weekly_goals_expanded
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own weekly goals" ON weekly_goals_expanded
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own weekly goals" ON weekly_goals_expanded
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own weekly goals" ON weekly_goals_expanded
    FOR DELETE USING (auth.uid() = user_id);

-- Migração: Trigger para sincronizar com workout_records (similar ao sistema atual)
CREATE OR REPLACE FUNCTION sync_workout_to_weekly_goals_expanded()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar metas de minutos (geral)
    PERFORM update_weekly_goal_progress(
        NEW.user_id,
        NEW.duration_minutes::NUMERIC,
        'minutes'
    );
    
    -- Se é treino de cardio, atualizar meta específica de cardio
    IF NEW.category ILIKE '%cardio%' OR NEW.category ILIKE '%corrida%' OR NEW.category ILIKE '%caminhada%' THEN
        PERFORM update_weekly_goal_progress(
            NEW.user_id,
            NEW.duration_minutes::NUMERIC,
            'minutes'
        );
    END IF;
    
    -- Se é treino de musculação, atualizar meta específica de musculação
    IF NEW.category ILIKE '%musculacao%' OR NEW.category ILIKE '%funcional%' OR NEW.category ILIKE '%crossfit%' THEN
        PERFORM update_weekly_goal_progress(
            NEW.user_id,
            NEW.duration_minutes::NUMERIC,
            'minutes'
        );
    END IF;
    
    -- Para metas de dias, contar qualquer treino como +1 dia
    PERFORM update_weekly_goal_progress(
        NEW.user_id,
        1,
        'days'
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger na tabela workout_records (assumindo que existe)
DROP TRIGGER IF EXISTS sync_workout_to_weekly_goals_expanded_trigger ON workout_records;
CREATE TRIGGER sync_workout_to_weekly_goals_expanded_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION sync_workout_to_weekly_goals_expanded();

-- Reset semanal automático (cron job)
CREATE OR REPLACE FUNCTION reset_weekly_goals_expanded()
RETURNS void AS $$
BEGIN
    -- Desativar metas da semana anterior
    UPDATE weekly_goals_expanded
    SET active = false
    WHERE week_end_date < CURRENT_DATE;
    
    -- Opcional: Criar automaticamente novas metas baseadas nas anteriores
    -- (pode ser implementado conforme necessário)
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentários para documentação
COMMENT ON TABLE weekly_goals_expanded IS 'Sistema expandido de metas semanais com suporte a diferentes tipos de medição';
COMMENT ON COLUMN weekly_goals_expanded.goal_type IS 'Tipo de meta pré-estabelecida (projeto_bruna_braga, cardio, musculacao, custom)';
COMMENT ON COLUMN weekly_goals_expanded.measurement_type IS 'Tipo de medição (minutes, days, checkins, weight, etc.)';
COMMENT ON COLUMN weekly_goals_expanded.target_value IS 'Valor alvo da meta (pode ser minutos, dias, kg, etc.)';
COMMENT ON COLUMN weekly_goals_expanded.current_value IS 'Valor atual alcançado';
COMMENT ON COLUMN weekly_goals_expanded.unit_label IS 'Rótulo da unidade para exibição (min, dias, kg, etc.)'; 