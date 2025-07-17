-- =====================================================
-- ATUALIZAÇÃO COMPLETA DA FUNÇÃO get_dashboard_data
-- Para suportar o Dashboard Enhanced
-- =====================================================

-- 1. CRIAR TABELA DE NUTRIÇÃO (nutrition_tracking)
-- =====================================================
CREATE TABLE IF NOT EXISTS nutrition_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    calories_consumed INTEGER NOT NULL DEFAULT 0,
    calories_goal INTEGER NOT NULL DEFAULT 2000,
    proteins DECIMAL(10,2) NOT NULL DEFAULT 0,
    carbs DECIMAL(10,2) NOT NULL DEFAULT 0,
    fats DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir um registro único por usuário/dia
    UNIQUE (user_id, date)
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS nutrition_tracking_user_id_idx ON nutrition_tracking(user_id);
CREATE INDEX IF NOT EXISTS nutrition_tracking_date_idx ON nutrition_tracking(date);

-- Habilitar RLS
ALTER TABLE nutrition_tracking ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar seus próprios registros de nutrição"
ON nutrition_tracking FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seus próprios registros de nutrição"
ON nutrition_tracking FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios registros de nutrição"
ON nutrition_tracking FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar seus próprios registros de nutrição"
ON nutrition_tracking FOR DELETE
USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_nutrition_tracking_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_nutrition_tracking_updated_at ON nutrition_tracking;
CREATE TRIGGER trigger_nutrition_tracking_updated_at
BEFORE UPDATE ON nutrition_tracking
FOR EACH ROW
EXECUTE FUNCTION update_nutrition_tracking_updated_at();

-- 2. VERIFICAR E AJUSTAR TABELA user_goals
-- =====================================================
-- Adicionar colunas que podem estar faltando
ALTER TABLE user_goals 
ADD COLUMN IF NOT EXISTS current_value DECIMAL DEFAULT 0,
ADD COLUMN IF NOT EXISTS target_value DECIMAL DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT FALSE;

-- 3. VERIFICAR E AJUSTAR TABELA water_intake
-- =====================================================
-- Adicionar colunas que podem estar faltando
ALTER TABLE water_intake 
ADD COLUMN IF NOT EXISTS cups INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS goal INTEGER DEFAULT 8;

-- 4. ATUALIZAR A FUNÇÃO get_dashboard_data
-- =====================================================
CREATE OR REPLACE FUNCTION get_dashboard_data(user_id_param UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSON;
    user_progress_data JSON;
    water_intake_data JSON;
    goals_data JSON;
    recent_workouts_data JSON;
    current_challenge_data JSON;
    challenge_progress_data JSON;
    redeemed_benefits_data JSON;
    nutrition_data JSON;
BEGIN
    -- Get user progress - Garantir que nenhum valor seja NULL convertendo para tipo correto
    SELECT json_build_object(
        'id', COALESCE(up.id::text, ''),
        'user_id', COALESCE(up.user_id::text, ''),
        'total_workouts', COALESCE(up.workouts, 0),
        'current_streak', COALESCE(up.current_streak, 0),
        'longest_streak', COALESCE(up.longest_streak, 0),
        'total_points', COALESCE(up.points, 0),
        'days_trained_this_month', COALESCE(up.days_trained_this_month, 0),
        'workout_types', COALESCE(
            CASE 
                WHEN up.workout_types IS NOT NULL THEN up.workout_types
                WHEN up.workouts_by_type IS NOT NULL THEN up.workouts_by_type
                ELSE '{}'::jsonb
            END, 
            '{}'::jsonb
        ),
        'created_at', COALESCE(up.created_at, NOW()),
        'updated_at', COALESCE(up.updated_at, NOW())
    )
    INTO user_progress_data
    FROM user_progress up
    WHERE up.user_id = user_id_param;

    -- Fallback para user_progress quando não encontrado
    IF user_progress_data IS NULL THEN
        user_progress_data := json_build_object(
            'id', '',
            'user_id', user_id_param::text,
            'total_workouts', 0,
            'current_streak', 0,
            'longest_streak', 0,
            'total_points', 0,
            'days_trained_this_month', 0,
            'workout_types', '{}'::jsonb,
            'created_at', NOW(),
            'updated_at', NOW()
        );
    END IF;

    -- Get water intake data for today (with fallback for empty data)
    SELECT COALESCE(
        (SELECT json_build_object(
            'id', COALESCE(wi.id::text, ''),
            'user_id', COALESCE(wi.user_id::text, ''),
            'date', wi.date,
            'cups', COALESCE(wi.cups, 0),
            'goal', COALESCE(wi.goal, 8),
            'created_at', COALESCE(wi.created_at, NOW()),
            'updated_at', COALESCE(wi.updated_at, NOW())
        )
        FROM water_intake wi
        WHERE wi.user_id = user_id_param
        AND wi.date = CURRENT_DATE
        ORDER BY wi.created_at DESC
        LIMIT 1),
        json_build_object(
            'id', '',
            'user_id', user_id_param::text,
            'date', CURRENT_DATE,
            'cups', 0,
            'goal', 8,
            'created_at', NOW(),
            'updated_at', NOW()
        )
    ) INTO water_intake_data;

    -- Get user goals (if any) - Usando uma subconsulta para evitar o erro de GROUP BY
    WITH ordered_goals AS (
        SELECT 
            g.id,
            g.title,
            g.current_value,
            g.target_value,
            g.unit,
            g.is_completed,
            g.created_at,
            g.updated_at
        FROM user_goals g
        WHERE g.user_id = user_id_param
        ORDER BY g.created_at DESC
    )
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', COALESCE(og.id::text, ''),
                'title', COALESCE(og.title, ''),
                'current_value', COALESCE(og.current_value, 0),
                'target_value', COALESCE(og.target_value, 0),
                'unit', COALESCE(og.unit, ''),
                'is_completed', COALESCE(og.is_completed, false),
                'created_at', COALESCE(og.created_at, NOW()),
                'updated_at', COALESCE(og.updated_at, NOW())
            )
        ) FROM ordered_goals og),
        '[]'::json
    ) INTO goals_data;

    -- Get recent workouts
    WITH ordered_workouts AS (
        SELECT 
            wr.id,
            wr.workout_name,
            wr.workout_type,
            wr.date,
            wr.duration_minutes,
            wr.is_completed
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        ORDER BY wr.date DESC
        LIMIT 10
    )
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', COALESCE(ow.id::text, ''),
                'workout_name', COALESCE(ow.workout_name, ''),
                'workout_type', COALESCE(ow.workout_type, ''),
                'date', ow.date,
                'duration_minutes', COALESCE(ow.duration_minutes, 0),
                'is_completed', COALESCE(ow.is_completed, false)
            )
        ) FROM ordered_workouts ow),
        '[]'::json
    ) INTO recent_workouts_data;
    
    -- Get active challenge data (preferably the official one first, then user-joined ones)
    WITH user_active_challenges AS (
        SELECT 
            c.id,
            c.title,
            c.description,
            c.image_url,
            c.start_date,
            c.end_date,
            c.points,
            c.type,
            c.is_official,
            ROW_NUMBER() OVER (
                ORDER BY 
                    c.is_official DESC, -- Official challenges first
                    c.end_date ASC -- Then by end date (soonest to end)
            ) as challenge_rank
        FROM challenges c
        JOIN challenge_participants cp ON c.id = cp.challenge_id
        WHERE 
            cp.user_id = user_id_param
            AND c.end_date >= CURRENT_DATE
            AND c.active = true
        ORDER BY challenge_rank
        LIMIT 1
    )
    SELECT 
        CASE WHEN COUNT(*) > 0 THEN
            (SELECT json_build_object(
                'id', COALESCE(uac.id::text, ''),
                'title', COALESCE(uac.title, ''),
                'description', COALESCE(uac.description, ''),
                'image_url', COALESCE(uac.image_url, ''),
                'start_date', uac.start_date,
                'end_date', uac.end_date,
                'points', COALESCE(uac.points, 0),
                'type', COALESCE(uac.type, ''),
                'is_official', COALESCE(uac.is_official, false),
                'days_remaining', EXTRACT(DAY FROM (uac.end_date - CURRENT_DATE))
            ) FROM user_active_challenges uac WHERE uac.challenge_rank = 1)
        ELSE NULL END
    INTO current_challenge_data
    FROM user_active_challenges;
    
    -- Get challenge progress for the current challenge
    SELECT 
        CASE WHEN current_challenge_data IS NOT NULL THEN
            (SELECT json_build_object(
                'id', COALESCE(cp.id::text, ''),
                'user_id', COALESCE(cp.user_id::text, ''),
                'challenge_id', COALESCE(cp.challenge_id::text, ''),
                'points', COALESCE(cp.points, 0),
                'position', COALESCE(cp.position, 0),
                'total_check_ins', COALESCE(
                    CASE 
                        WHEN cp.check_ins_count IS NOT NULL THEN cp.check_ins_count
                        WHEN cp.total_check_ins IS NOT NULL THEN cp.total_check_ins
                        ELSE 0
                    END,
                    0
                ),
                'consecutive_days', COALESCE(cp.consecutive_days, 0),
                'completion_percentage', 
                    CASE 
                        WHEN (current_challenge_data->>'points')::int > 0 THEN
                            (COALESCE(cp.points, 0)::float / (current_challenge_data->>'points')::float) * 100
                        ELSE 0
                    END
            )
            FROM challenge_progress cp
            WHERE 
                cp.challenge_id = (current_challenge_data->>'id')::uuid
                AND cp.user_id = user_id_param)
        ELSE NULL END
    INTO challenge_progress_data;
    
    -- Get redeemed benefits
    WITH ordered_benefits AS (
        SELECT 
            rb.id,
            rb.benefit_id,
            b.title as benefit_title,
            b.image_url as benefit_image_url,
            rb.redeemed_at,
            rb.expiration_date,
            rb.code as redemption_code
        FROM redeemed_benefits rb
        JOIN benefits b ON rb.benefit_id = b.id
        WHERE 
            rb.user_id = user_id_param
            AND rb.status = 'active'
        ORDER BY rb.redeemed_at DESC
        LIMIT 5
    )
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', COALESCE(ob.id::text, ''),
                'benefit_id', COALESCE(ob.benefit_id::text, ''),
                'benefit_title', COALESCE(ob.benefit_title, ''),
                'benefit_image_url', COALESCE(ob.benefit_image_url, ''),
                'redeemed_at', ob.redeemed_at,
                'expiration_date', ob.expiration_date,
                'redemption_code', COALESCE(ob.redemption_code, '')
            )
        ) FROM ordered_benefits ob),
        '[]'::json
    ) INTO redeemed_benefits_data;

    -- Get nutrition data for today
    SELECT COALESCE(
        (SELECT json_build_object(
            'id', COALESCE(nt.id::text, ''),
            'user_id', COALESCE(nt.user_id::text, ''),
            'date', nt.date,
            'calories_consumed', COALESCE(nt.calories_consumed, 0),
            'calories_goal', COALESCE(nt.calories_goal, 2000),
            'proteins', COALESCE(nt.proteins, 0),
            'carbs', COALESCE(nt.carbs, 0),
            'fats', COALESCE(nt.fats, 0),
            'created_at', COALESCE(nt.created_at, NOW()),
            'updated_at', COALESCE(nt.updated_at, NOW())
        )
        FROM nutrition_tracking nt
        WHERE nt.user_id = user_id_param
        AND nt.date = CURRENT_DATE
        ORDER BY nt.created_at DESC
        LIMIT 1),
        json_build_object(
            'id', '',
            'user_id', user_id_param::text,
            'date', CURRENT_DATE,
            'calories_consumed', 0,
            'calories_goal', 2000,
            'proteins', 0,
            'carbs', 0,
            'fats', 0,
            'created_at', NOW(),
            'updated_at', NOW()
        )
    ) INTO nutrition_data;

    -- Build final result
    result := json_build_object(
        'user_progress', user_progress_data,
        'water_intake', water_intake_data,
        'goals', goals_data,
        'recent_workouts', recent_workouts_data,
        'current_challenge', current_challenge_data,
        'challenge_progress', challenge_progress_data,
        'redeemed_benefits', redeemed_benefits_data,
        'nutrition_data', nutrition_data,
        'last_updated', CURRENT_TIMESTAMP
    );

    RETURN result;
END;
$$;

-- 5. GRANT EXECUTE PERMISSION
-- =====================================================
GRANT EXECUTE ON FUNCTION get_dashboard_data(UUID) TO authenticated;

-- 6. CRIAR FUNÇÕES AUXILIARES PARA NUTRIÇÃO
-- =====================================================
-- Função para atualizar nutrição do dia
CREATE OR REPLACE FUNCTION update_nutrition_tracking(
    p_user_id UUID,
    p_calories INTEGER DEFAULT NULL,
    p_proteins DECIMAL DEFAULT NULL,
    p_carbs DECIMAL DEFAULT NULL,
    p_fats DECIMAL DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSON;
BEGIN
    -- Inserir ou atualizar registro do dia
    INSERT INTO nutrition_tracking (
        user_id,
        date,
        calories_consumed,
        proteins,
        carbs,
        fats
    ) VALUES (
        p_user_id,
        CURRENT_DATE,
        COALESCE(p_calories, 0),
        COALESCE(p_proteins, 0),
        COALESCE(p_carbs, 0),
        COALESCE(p_fats, 0)
    )
    ON CONFLICT (user_id, date) DO UPDATE SET
        calories_consumed = COALESCE(p_calories, nutrition_tracking.calories_consumed),
        proteins = COALESCE(p_proteins, nutrition_tracking.proteins),
        carbs = COALESCE(p_carbs, nutrition_tracking.carbs),
        fats = COALESCE(p_fats, nutrition_tracking.fats),
        updated_at = NOW()
    RETURNING json_build_object(
        'id', id::text,
        'user_id', user_id::text,
        'date', date,
        'calories_consumed', calories_consumed,
        'calories_goal', calories_goal,
        'proteins', proteins,
        'carbs', carbs,
        'fats', fats,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO result;

    RETURN result;
END;
$$;

-- Grant permission
GRANT EXECUTE ON FUNCTION update_nutrition_tracking(UUID, INTEGER, DECIMAL, DECIMAL, DECIMAL) TO authenticated;

-- 7. COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================
COMMENT ON TABLE nutrition_tracking IS 'Tabela para rastreamento diário de nutrição dos usuários';
COMMENT ON COLUMN nutrition_tracking.calories_consumed IS 'Total de calorias consumidas no dia';
COMMENT ON COLUMN nutrition_tracking.calories_goal IS 'Meta de calorias para o dia';
COMMENT ON COLUMN nutrition_tracking.proteins IS 'Total de proteínas consumidas em gramas';
COMMENT ON COLUMN nutrition_tracking.carbs IS 'Total de carboidratos consumidos em gramas';
COMMENT ON COLUMN nutrition_tracking.fats IS 'Total de gorduras consumidas em gramas';

COMMENT ON FUNCTION get_dashboard_data(UUID) IS 'Função principal para buscar todos os dados do dashboard enhanced, incluindo progresso, água, metas, treinos, desafios, benefícios e nutrição';
COMMENT ON FUNCTION update_nutrition_tracking(UUID, INTEGER, DECIMAL, DECIMAL, DECIMAL) IS 'Função para atualizar dados de nutrição do usuário para o dia atual'; 