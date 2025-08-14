-- ========================================
-- SISTEMA DE METAS PERSONALIZÁVEIS COMPLETO
-- ========================================
-- Data: 2025-01-28
-- Objetivo: Sistema robusto para metas com modalidades check e unidade
-- Autor: IA Assistant

-- 1. ENUM para tipos de medição expandidos
DO $$ BEGIN
    CREATE TYPE personalized_goal_measurement_type AS ENUM (
        'check',           -- Check-ins (círculos clicáveis)
        'minutes',         -- Minutos
        'weight',          -- Peso (kg)
        'calories',        -- Calorias
        'liters',          -- Litros
        'days',            -- Dias
        'custom'           -- Personalizado
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. ENUM para tipos de metas pré-estabelecidas
DO $$ BEGIN
    CREATE TYPE personalized_goal_preset_type AS ENUM (
        'projeto_7_dias',   -- Projeto 7 dias (check)
        'cardio_check',     -- Cardio modalidade check (4x/semana)
        'cardio_minutes',   -- Cardio modalidade minutos (100min/semana)
        'custom'           -- Meta personalizada
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Tabela principal de metas personalizáveis
CREATE TABLE IF NOT EXISTS personalized_weekly_goals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Identificação da meta
    goal_preset_type personalized_goal_preset_type NOT NULL DEFAULT 'custom',
    goal_title VARCHAR(255) NOT NULL,
    goal_description TEXT,
    
    -- Tipo de medição
    measurement_type personalized_goal_measurement_type NOT NULL,
    
    -- Valores da meta
    target_value NUMERIC NOT NULL, -- Valor alvo (7 checks, 100 minutos, etc.)
    current_progress NUMERIC NOT NULL DEFAULT 0, -- Progresso atual
    unit_label VARCHAR(50) NOT NULL, -- Rótulo da unidade
    
    -- Configurações de incremento
    increment_step NUMERIC DEFAULT 1, -- Passo do incremento (1, 10, etc.)
    
    -- Datas da semana
    week_start_date DATE NOT NULL DEFAULT date_trunc('week', CURRENT_DATE)::date,
    week_end_date DATE NOT NULL DEFAULT (date_trunc('week', CURRENT_DATE) + interval '6 days')::date,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: uma meta ativa por usuário por semana
    CONSTRAINT unique_active_personalized_goal_per_user_week 
        UNIQUE (user_id, week_start_date) 
        DEFERRABLE INITIALLY DEFERRED
);

-- 4. Tabela para registrar check-ins individuais (modalidade check)
CREATE TABLE IF NOT EXISTS goal_check_ins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    goal_id UUID NOT NULL REFERENCES personalized_weekly_goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Data e horário do check-in
    check_in_date DATE NOT NULL DEFAULT CURRENT_DATE,
    check_in_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadados opcionais
    notes TEXT, -- Notas do usuário sobre o check-in
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: evitar duplicatas de check-in no mesmo dia
    CONSTRAINT unique_goal_checkin_per_day 
        UNIQUE (goal_id, user_id, check_in_date)
);

-- 5. Tabela para registrar entradas de progresso numérico (modalidade unidade)
CREATE TABLE IF NOT EXISTS goal_progress_entries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    goal_id UUID NOT NULL REFERENCES personalized_weekly_goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Valor adicionado
    value_added NUMERIC NOT NULL, -- Valor incrementado (10 min, 0.5 kg, etc.)
    entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
    entry_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadados opcionais
    notes TEXT, -- Notas do usuário sobre a entrada
    source VARCHAR(100), -- 'manual', 'workout_sync', 'automatic', etc.
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Índices para performance
CREATE INDEX IF NOT EXISTS idx_personalized_goals_user_id ON personalized_weekly_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_personalized_goals_week ON personalized_weekly_goals(week_start_date, week_end_date);
CREATE INDEX IF NOT EXISTS idx_personalized_goals_user_week ON personalized_weekly_goals(user_id, week_start_date DESC);
CREATE INDEX IF NOT EXISTS idx_personalized_goals_active ON personalized_weekly_goals(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_goal_checkins_goal_id ON goal_check_ins(goal_id);
CREATE INDEX IF NOT EXISTS idx_goal_checkins_user_date ON goal_check_ins(user_id, check_in_date DESC);

CREATE INDEX IF NOT EXISTS idx_goal_progress_goal_id ON goal_progress_entries(goal_id);
CREATE INDEX IF NOT EXISTS idx_goal_progress_user_date ON goal_progress_entries(user_id, entry_date DESC);

-- 7. Triggers para updated_at
CREATE OR REPLACE FUNCTION update_personalized_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_personalized_goals_updated_at_trigger ON personalized_weekly_goals;
CREATE TRIGGER update_personalized_goals_updated_at_trigger
    BEFORE UPDATE ON personalized_weekly_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_personalized_goals_updated_at();

-- 8. Função para atualizar progresso automaticamente após check-in
CREATE OR REPLACE FUNCTION sync_checkin_to_goal_progress()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar current_progress na meta principal
    UPDATE personalized_weekly_goals 
    SET current_progress = (
        SELECT COUNT(*) 
        FROM goal_check_ins 
        WHERE goal_id = NEW.goal_id
    ),
    is_completed = (
        SELECT COUNT(*) >= target_value
        FROM goal_check_ins 
        WHERE goal_id = NEW.goal_id
        GROUP BY target_value
        LIMIT 1
    ),
    completed_at = CASE 
        WHEN (SELECT COUNT(*) >= target_value FROM goal_check_ins WHERE goal_id = NEW.goal_id GROUP BY target_value LIMIT 1) 
        THEN NOW() 
        ELSE completed_at 
    END
    WHERE id = NEW.goal_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_checkin_to_goal_progress_trigger ON goal_check_ins;
CREATE TRIGGER sync_checkin_to_goal_progress_trigger
    AFTER INSERT OR DELETE ON goal_check_ins
    FOR EACH ROW
    EXECUTE FUNCTION sync_checkin_to_goal_progress();

-- 9. Função para atualizar progresso automaticamente após entrada numérica
CREATE OR REPLACE FUNCTION sync_progress_entry_to_goal()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar current_progress na meta principal
    UPDATE personalized_weekly_goals 
    SET current_progress = (
        SELECT COALESCE(SUM(value_added), 0)
        FROM goal_progress_entries 
        WHERE goal_id = NEW.goal_id
    ),
    is_completed = (
        SELECT COALESCE(SUM(value_added), 0) >= target_value
        FROM goal_progress_entries 
        WHERE goal_id = NEW.goal_id
        GROUP BY target_value
        LIMIT 1
    ),
    completed_at = CASE 
        WHEN (SELECT COALESCE(SUM(value_added), 0) >= target_value FROM goal_progress_entries WHERE goal_id = NEW.goal_id GROUP BY target_value LIMIT 1) 
        THEN NOW() 
        ELSE completed_at 
    END
    WHERE id = NEW.goal_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_progress_entry_to_goal_trigger ON goal_progress_entries;
CREATE TRIGGER sync_progress_entry_to_goal_trigger
    AFTER INSERT OR UPDATE OR DELETE ON goal_progress_entries
    FOR EACH ROW
    EXECUTE FUNCTION sync_progress_entry_to_goal();

-- 10. Função para registrar check-in
CREATE OR REPLACE FUNCTION register_goal_checkin(
    p_goal_id UUID,
    p_user_id UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_goal RECORD;
    v_checkin_id UUID;
    v_today DATE := CURRENT_DATE;
    v_existing_checkin BOOLEAN;
BEGIN
    -- Verificar se a meta existe e é do usuário
    SELECT * INTO v_goal 
    FROM personalized_weekly_goals 
    WHERE id = p_goal_id AND user_id = p_user_id AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Meta não encontrada ou inativa'
        );
    END IF;
    
    -- Verificar se é uma meta de check-in
    IF v_goal.measurement_type != 'check' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Esta meta não é do tipo check-in'
        );
    END IF;
    
    -- Verificar se já existe check-in hoje
    SELECT EXISTS(
        SELECT 1 FROM goal_check_ins 
        WHERE goal_id = p_goal_id 
        AND user_id = p_user_id 
        AND check_in_date = v_today
    ) INTO v_existing_checkin;
    
    IF v_existing_checkin THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Check-in já registrado para hoje'
        );
    END IF;
    
    -- Registrar check-in
    INSERT INTO goal_check_ins (goal_id, user_id, check_in_date, notes)
    VALUES (p_goal_id, p_user_id, v_today, p_notes)
    RETURNING id INTO v_checkin_id;
    
    -- Retornar sucesso com dados atualizados
    SELECT current_progress, target_value, is_completed
    INTO v_goal
    FROM personalized_weekly_goals 
    WHERE id = p_goal_id;
    
    RETURN json_build_object(
        'success', true,
        'checkin_id', v_checkin_id,
        'current_progress', v_goal.current_progress,
        'target_value', v_goal.target_value,
        'is_completed', v_goal.is_completed,
        'message', 'Check-in registrado com sucesso! ✅'
    );
END;
$$ LANGUAGE plpgsql;

-- 11. Função para adicionar progresso numérico
CREATE OR REPLACE FUNCTION add_goal_progress(
    p_goal_id UUID,
    p_user_id UUID,
    p_value_added NUMERIC,
    p_notes TEXT DEFAULT NULL,
    p_source TEXT DEFAULT 'manual'
)
RETURNS JSON AS $$
DECLARE
    v_goal RECORD;
    v_entry_id UUID;
    v_today DATE := CURRENT_DATE;
BEGIN
    -- Verificar se a meta existe e é do usuário
    SELECT * INTO v_goal 
    FROM personalized_weekly_goals 
    WHERE id = p_goal_id AND user_id = p_user_id AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Meta não encontrada ou inativa'
        );
    END IF;
    
    -- Verificar se é uma meta numérica (não check-in)
    IF v_goal.measurement_type = 'check' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Esta meta é do tipo check-in, use a função de check-in'
        );
    END IF;
    
    -- Validar valor positivo
    IF p_value_added <= 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Valor deve ser positivo'
        );
    END IF;
    
    -- Registrar entrada de progresso
    INSERT INTO goal_progress_entries (goal_id, user_id, value_added, entry_date, notes, source)
    VALUES (p_goal_id, p_user_id, p_value_added, v_today, p_notes, p_source)
    RETURNING id INTO v_entry_id;
    
    -- Retornar sucesso com dados atualizados
    SELECT current_progress, target_value, is_completed
    INTO v_goal
    FROM personalized_weekly_goals 
    WHERE id = p_goal_id;
    
    RETURN json_build_object(
        'success', true,
        'entry_id', v_entry_id,
        'value_added', p_value_added,
        'current_progress', v_goal.current_progress,
        'target_value', v_goal.target_value,
        'is_completed', v_goal.is_completed,
        'progress_percentage', ROUND((v_goal.current_progress / v_goal.target_value * 100)::NUMERIC, 1),
        'message', 'Progresso adicionado com sucesso! 🎯'
    );
END;
$$ LANGUAGE plpgsql;

-- 12. Função para criar metas pré-estabelecidas
CREATE OR REPLACE FUNCTION create_preset_goal(
    p_user_id UUID,
    p_preset_type personalized_goal_preset_type
)
RETURNS JSON AS $$
DECLARE
    v_goal_id UUID;
    v_goal_data RECORD;
BEGIN
    -- Definir dados baseados no preset
    CASE p_preset_type
        WHEN 'projeto_7_dias' THEN
            INSERT INTO personalized_weekly_goals (
                user_id, goal_preset_type, goal_title, goal_description,
                measurement_type, target_value, unit_label, increment_step
            ) VALUES (
                p_user_id, p_preset_type, 'Projeto 7 Dias', 
                'Complete 1 check-in por dia durante 7 dias',
                'check', 7, 'dias', 1
            ) RETURNING id INTO v_goal_id;
            
        WHEN 'cardio_check' THEN
            INSERT INTO personalized_weekly_goals (
                user_id, goal_preset_type, goal_title, goal_description,
                measurement_type, target_value, unit_label, increment_step
            ) VALUES (
                p_user_id, p_preset_type, 'Cardio Semanal', 
                'Faça cardio 4 vezes por semana',
                'check', 4, 'sessões', 1
            ) RETURNING id INTO v_goal_id;
            
        WHEN 'cardio_minutes' THEN
            INSERT INTO personalized_weekly_goals (
                user_id, goal_preset_type, goal_title, goal_description,
                measurement_type, target_value, unit_label, increment_step
            ) VALUES (
                p_user_id, p_preset_type, 'Cardio 100min', 
                'Acumule 100 minutos de cardio por semana',
                'minutes', 100, 'min', 10
            ) RETURNING id INTO v_goal_id;
            
        ELSE
            RETURN json_build_object(
                'success', false,
                'error', 'Tipo de preset não reconhecido'
            );
    END CASE;
    
    -- Retornar dados da meta criada
    SELECT * INTO v_goal_data 
    FROM personalized_weekly_goals 
    WHERE id = v_goal_id;
    
    RETURN json_build_object(
        'success', true,
        'goal_id', v_goal_id,
        'goal_title', v_goal_data.goal_title,
        'measurement_type', v_goal_data.measurement_type,
        'target_value', v_goal_data.target_value,
        'unit_label', v_goal_data.unit_label,
        'message', 'Meta "' || v_goal_data.goal_title || '" criada com sucesso! 🎯'
    );
END;
$$ LANGUAGE plpgsql;

-- 13. Função para obter meta ativa do usuário
CREATE OR REPLACE FUNCTION get_user_active_goal(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_goal RECORD;
    v_checkins_today INTEGER := 0;
    v_progress_today NUMERIC := 0;
BEGIN
    -- Buscar meta ativa da semana atual
    SELECT * INTO v_goal 
    FROM personalized_weekly_goals 
    WHERE user_id = p_user_id 
    AND is_active = TRUE 
    AND week_start_date = date_trunc('week', CURRENT_DATE)::date
    ORDER BY created_at DESC 
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'has_goal', false,
            'message', 'Nenhuma meta ativa encontrada para esta semana'
        );
    END IF;
    
    -- Obter dados específicos baseados no tipo
    IF v_goal.measurement_type = 'check' THEN
        SELECT COUNT(*) INTO v_checkins_today
        FROM goal_check_ins 
        WHERE goal_id = v_goal.id 
        AND check_in_date = CURRENT_DATE;
    ELSE
        SELECT COALESCE(SUM(value_added), 0) INTO v_progress_today
        FROM goal_progress_entries 
        WHERE goal_id = v_goal.id 
        AND entry_date = CURRENT_DATE;
    END IF;
    
    RETURN json_build_object(
        'success', true,
        'has_goal', true,
        'goal', json_build_object(
            'id', v_goal.id,
            'title', v_goal.goal_title,
            'description', v_goal.goal_description,
            'measurement_type', v_goal.measurement_type,
            'target_value', v_goal.target_value,
            'current_progress', v_goal.current_progress,
            'unit_label', v_goal.unit_label,
            'increment_step', v_goal.increment_step,
            'is_completed', v_goal.is_completed,
            'progress_percentage', ROUND((v_goal.current_progress / v_goal.target_value * 100)::NUMERIC, 1),
            'checkins_today', v_checkins_today,
            'progress_today', v_progress_today
        )
    );
END;
$$ LANGUAGE plpgsql;

-- 14. RLS (Row Level Security)
ALTER TABLE personalized_weekly_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_progress_entries ENABLE ROW LEVEL SECURITY;

-- Políticas para personalized_weekly_goals
CREATE POLICY "Usuários podem acessar suas próprias metas" ON personalized_weekly_goals
    FOR ALL USING (auth.uid() = user_id);

-- Políticas para goal_check_ins
CREATE POLICY "Usuários podem acessar seus próprios check-ins" ON goal_check_ins
    FOR ALL USING (auth.uid() = user_id);

-- Políticas para goal_progress_entries
CREATE POLICY "Usuários podem acessar suas próprias entradas de progresso" ON goal_progress_entries
    FOR ALL USING (auth.uid() = user_id);

-- ========================================
-- SISTEMA COMPLETO CRIADO! 🎯
-- ========================================
-- ✅ Duas modalidades: check e unidade
-- ✅ Tabelas para registros individuais
-- ✅ Funções robustas para cada operação
-- ✅ Triggers automáticos para sincronização
-- ✅ Metas pré-estabelecidas configuradas
-- ✅ Sistema de segurança (RLS) implementado
-- ======================================== 