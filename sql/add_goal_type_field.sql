-- ================================================================
-- ADICIONAR CAMPO goal_type PARA DIFERENCIAR METAS DE DIAS E MINUTOS
-- ================================================================

-- 1. Adicionar coluna goal_type na tabela workout_category_goals
ALTER TABLE workout_category_goals 
ADD COLUMN IF NOT EXISTS goal_type VARCHAR(20) DEFAULT 'minutes';

-- 2. Adicionar comentário para documentar o campo
COMMENT ON COLUMN workout_category_goals.goal_type IS 'Tipo da meta: "minutes" para metas de minutos, "days" para metas de dias';

-- 3. Atualizar metas existentes baseado no valor goal_minutes
-- Se goal_minutes é múltiplo de 30 e >= 30, provavelmente é meta de dias
UPDATE workout_category_goals 
SET goal_type = 'days' 
WHERE goal_minutes >= 30 
  AND goal_minutes % 30 = 0 
  AND goal_minutes <= 1440; -- Máximo 48 dias

-- 4. Adicionar tabela para check-ins diários (para metas de dias)
CREATE TABLE IF NOT EXISTS daily_goal_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES workout_category_goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    checkin_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir que só pode ter um check-in por dia por meta
    UNIQUE(goal_id, checkin_date)
);

-- 5. Adicionar RLS para daily_goal_checkins
ALTER TABLE daily_goal_checkins ENABLE ROW LEVEL SECURITY;

-- 6. Política para usuários verem apenas seus próprios check-ins
CREATE POLICY "Users can view own checkins" ON daily_goal_checkins
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own checkins" ON daily_goal_checkins
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own checkins" ON daily_goal_checkins
    FOR DELETE USING (user_id = auth.uid());

-- 7. Função para fazer check-in diário
CREATE OR REPLACE FUNCTION daily_checkin(
    p_goal_id UUID,
    p_user_id UUID DEFAULT auth.uid()
) RETURNS BOOLEAN AS $$
DECLARE
    v_today DATE := CURRENT_DATE;
    v_goal_type TEXT;
    v_checkin_exists BOOLEAN;
BEGIN
    -- Verificar se a meta existe e é do tipo 'days'
    SELECT goal_type INTO v_goal_type
    FROM workout_category_goals
    WHERE id = p_goal_id AND user_id = p_user_id;
    
    IF v_goal_type IS NULL THEN
        RAISE EXCEPTION 'Meta não encontrada';
    END IF;
    
    IF v_goal_type != 'days' THEN
        RAISE EXCEPTION 'Esta meta não é do tipo dias';
    END IF;
    
    -- Verificar se já fez check-in hoje
    SELECT EXISTS(
        SELECT 1 FROM daily_goal_checkins
        WHERE goal_id = p_goal_id AND checkin_date = v_today
    ) INTO v_checkin_exists;
    
    IF v_checkin_exists THEN
        -- Se já existe, remover (toggle)
        DELETE FROM daily_goal_checkins
        WHERE goal_id = p_goal_id AND checkin_date = v_today;
        RETURN FALSE;
    ELSE
        -- Se não existe, adicionar
        INSERT INTO daily_goal_checkins (goal_id, user_id, checkin_date)
        VALUES (p_goal_id, p_user_id, v_today);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Função para obter progresso de metas de dias
CREATE OR REPLACE FUNCTION get_days_goal_progress(
    p_goal_id UUID,
    p_user_id UUID DEFAULT auth.uid()
) RETURNS JSON AS $$
DECLARE
    v_goal_record workout_category_goals;
    v_week_start DATE;
    v_week_end DATE;
    v_checkins_count INTEGER;
    v_checkin_dates DATE[];
    v_today_checked BOOLEAN;
BEGIN
    -- Buscar meta
    SELECT * INTO v_goal_record
    FROM workout_category_goals
    WHERE id = p_goal_id AND user_id = p_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Meta não encontrada';
    END IF;
    
    v_week_start := v_goal_record.week_start_date;
    v_week_end := v_goal_record.week_end_date;
    
    -- Contar check-ins da semana
    SELECT COUNT(*), ARRAY_AGG(checkin_date ORDER BY checkin_date)
    INTO v_checkins_count, v_checkin_dates
    FROM daily_goal_checkins
    WHERE goal_id = p_goal_id
      AND checkin_date BETWEEN v_week_start AND v_week_end;
    
    -- Verificar se fez check-in hoje
    SELECT EXISTS(
        SELECT 1 FROM daily_goal_checkins
        WHERE goal_id = p_goal_id AND checkin_date = CURRENT_DATE
    ) INTO v_today_checked;
    
    -- Calcular meta em dias (goal_minutes / 30)
    RETURN json_build_object(
        'goal_days', v_goal_record.goal_minutes / 30,
        'current_days', COALESCE(v_checkins_count, 0),
        'percentage_completed', 
            CASE 
                WHEN v_goal_record.goal_minutes > 0 THEN 
                    ROUND((COALESCE(v_checkins_count, 0) * 30.0 / v_goal_record.goal_minutes) * 100, 2)
                ELSE 0 
            END,
        'checkin_dates', COALESCE(v_checkin_dates, ARRAY[]::DATE[]),
        'today_checked', v_today_checked,
        'week_start', v_week_start,
        'week_end', v_week_end
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
