-- Script para corrigir o erro de conversão de tipos (Null para String)
-- Erro: type 'Null' is not a subtype of type 'String' in type cast

CREATE OR REPLACE FUNCTION get_dashboard_data(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    user_progress_data JSON;
    water_intake_data JSON;
    goals_data JSON;
    recent_workouts_data JSON;
    current_challenge_data JSON;
    challenge_progress_data JSON;
    redeemed_benefits_data JSON;
    
    -- Variáveis para verificação de existência de colunas
    has_workouts_by_type BOOLEAN;
    has_workout_types BOOLEAN;
    challenge_id_var UUID;
BEGIN
    -- Verificar se as colunas existem
    SELECT 
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workouts_by_type'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workout_types')
    INTO 
        has_workouts_by_type,
        has_workout_types;
    
    -- Construir o objeto de progresso do usuário de forma segura
    SELECT json_build_object(
        'id', up.id,
        'user_id', up.user_id,
        'total_workouts', COALESCE(up.workouts, 0),
        'current_streak', COALESCE(up.current_streak, 0),
        'longest_streak', COALESCE(up.longest_streak, 0),
        'total_points', COALESCE(up.points, 0),
        'days_trained_this_month', COALESCE(up.days_trained_this_month, 0),
        'total_duration', COALESCE(up.total_duration, 0),
        -- Usar a coluna correta para workout_types, ou um valor padrão
        'workout_types', 
            CASE 
            WHEN has_workout_types THEN COALESCE(up.workout_types, '{}'::jsonb)
            WHEN has_workouts_by_type THEN COALESCE(up.workouts_by_type, '{}'::jsonb)
            ELSE '{}'::jsonb
            END,
        'created_at', up.created_at,
        'updated_at', up.updated_at
    )
    INTO user_progress_data
    FROM user_progress up
    WHERE up.user_id = user_id_param;

    -- Se não encontrar dados do usuário, criar uma estrutura vazia
    IF user_progress_data IS NULL THEN
        user_progress_data := json_build_object(
            'id', NULL,
            'user_id', user_id_param,
            'total_workouts', 0,
            'current_streak', 0,
            'longest_streak', 0,
            'total_points', 0,
            'days_trained_this_month', 0,
            'workout_types', '{}'::jsonb,
            'total_duration', 0,
            'created_at', NULL,
            'updated_at', NULL
        );
    END IF;

    -- Get water intake data for today (with fallback for empty data)
    SELECT COALESCE(
        (SELECT json_build_object(
            'id', wi.id,
            'user_id', wi.user_id,
            'date', wi.date,
            'cups', COALESCE(wi.cups, 0),
            'goal', COALESCE(wi.goal, 8),
            'created_at', wi.created_at,
            'updated_at', wi.updated_at
        )
        FROM water_intake wi
        WHERE wi.user_id = user_id_param
        AND wi.date = CURRENT_DATE
        ORDER BY wi.created_at DESC
        LIMIT 1),
        json_build_object(
            'id', NULL,
            'user_id', user_id_param,
            'date', CURRENT_DATE,
            'cups', 0,
            'goal', 8,
            'created_at', NULL,
            'updated_at', NULL
        )
    ) INTO water_intake_data;

    -- Get user goals (if any) - CORRIGIDO: usando SELECT sem GROUP BY implícito
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', g.id,
                'title', g.title,
                'current_value', g.current_value,
                'target_value', g.target_value,
                'unit', g.unit,
                'is_completed', g.is_completed,
                'created_at', g.created_at,
                'updated_at', g.updated_at
            )
            ORDER BY g.created_at DESC
        )
        FROM user_goals g
        WHERE g.user_id = user_id_param),
        '[]'::json
    ) INTO goals_data;

    -- Get recent workouts
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', wr.id,
                'workout_name', wr.workout_name,
                'workout_type', wr.workout_type,
                'date', wr.date,
                'duration_minutes', wr.duration_minutes,
                'is_completed', wr.is_completed
            )
            ORDER BY wr.date DESC
        )
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        LIMIT 10),
        '[]'::json
    ) INTO recent_workouts_data;
    
    -- Obter desafios ativos do usuário - Abordagem mais segura contra nulos
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
        (SELECT json_build_object(
            'id', uac.id,
            'title', uac.title,
            'description', uac.description,
            'image_url', uac.image_url,
            'start_date', uac.start_date,
            'end_date', uac.end_date,
            'points', uac.points,
            'type', uac.type,
            'is_official', uac.is_official,
            'days_remaining', EXTRACT(DAY FROM (uac.end_date - CURRENT_DATE))
        )
        FROM user_active_challenges uac
        LIMIT 1)
    INTO current_challenge_data;
    
    -- IMPORTANTE: Extrair challenge_id com segurança (evitando null->>'id')
    IF current_challenge_data IS NOT NULL AND current_challenge_data->>'id' IS NOT NULL THEN
        challenge_id_var := (current_challenge_data->>'id')::UUID;
    ELSE
        challenge_id_var := NULL;
    END IF;
    
    -- Get challenge progress for the current challenge apenas se challenge_id não for null
    IF challenge_id_var IS NOT NULL THEN
        SELECT json_build_object(
            'id', cp.id,
            'user_id', cp.user_id,
            'challenge_id', cp.challenge_id,
            'points', COALESCE(cp.points, 0),
            'position', COALESCE(cp.position, 0),
            'total_check_ins', COALESCE(
                CASE 
                    WHEN cp.check_ins_count IS NOT NULL THEN cp.check_ins_count
                    WHEN cp.total_check_ins IS NOT NULL THEN cp.total_check_ins
                    ELSE 0
                END, 0),
            'consecutive_days', COALESCE(cp.consecutive_days, 0),
            'completion_percentage', COALESCE(cp.completion_percentage, 0)
        )
        INTO challenge_progress_data
        FROM challenge_progress cp
        WHERE 
            cp.challenge_id = challenge_id_var
            AND cp.user_id = user_id_param;
    ELSE
        challenge_progress_data := NULL;
    END IF;
    
    -- Get redeemed benefits - CORRIGIDO: usando SELECT sem GROUP BY implícito
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', ub.id,
                'benefit_id', ub.benefit_id,
                'benefit_title', b.title,
                'benefit_image_url', b.image_url,
                'redeemed_at', ub.redeemed_at,
                'expires_at', b.expiration_date,
                'redemption_code', ub.redemption_code
            )
            ORDER BY ub.redeemed_at DESC
        )
        FROM user_benefits ub
        JOIN benefits b ON ub.benefit_id = b.id
        WHERE 
            ub.user_id = user_id_param
            AND ub.redeemed_at IS NOT NULL
        LIMIT 5),
        '[]'::json
    ) INTO redeemed_benefits_data;

    -- Build final result
    result := json_build_object(
        'user_progress', user_progress_data,
        'water_intake', water_intake_data,
        'goals', goals_data,
        'recent_workouts', recent_workouts_data,
        'current_challenge', current_challenge_data,
        'challenge_progress', challenge_progress_data,
        'redeemed_benefits', redeemed_benefits_data,
        'last_updated', CURRENT_TIMESTAMP
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql; 